use std::pin::Pin;

use tokio_stream::{
  Stream, StreamExt,
  wrappers::{BroadcastStream, errors::BroadcastStreamRecvError},
};
use tonic::{Request, Response, Result, Status};

use crate::{
  auth::{
    auth_helpers::{require_auth, require_permission},
    jwt::Auth,
  },
  core::{
    db::DEFAULT_ADMIN_USERNAME,
    events::{ChangeEvent, EVENT_BUS},
    shutdown::with_shutdown,
  },
  generated::{
    api::{
      CreateUserRequest, CreateUserResponse, DeleteUserRequest, DeleteUserResponse, LoginRequest, LoginResponse,
      StreamUsersRequest, StreamUsersResponse, UpdateAdminPasswordRequest, UpdateAdminPasswordResponse,
      UpdateUserRequest, UpdateUserResponse, UserResponse, ValidateTokenRequest, ValidateTokenResponse,
      user_service_server::UserService,
    },
    common::{Role, SyncType},
    db::User,
  },
  modules::user::UserRepository,
};

pub struct UserApi;

fn get_all_users() -> std::result::Result<Vec<UserResponse>, Status> {
  User::get_all()
    .map_err(|e| Status::internal(format!("Failed to get users: {}", e)))?
    .into_iter()
    .filter(|(_, user)| user.username != DEFAULT_ADMIN_USERNAME)
    .map(|(id, user)| Ok(UserResponse { id, username: user.username, roles: user.roles }))
    .collect()
}

#[tonic::async_trait]
impl UserService for UserApi {
  async fn login(&self, request: Request<LoginRequest>) -> Result<Response<LoginResponse>, Status> {
    let request = request.into_inner();

    // standard checks
    if request.username.is_empty() || request.password.is_empty() {
      return Err(Status::invalid_argument("Username or Password empty"));
    }

    let users = match User::get_by_username(&request.username) {
      Ok(u) => u,
      Err(e) => return Err(Status::internal(e.to_string())),
    };

    if users.is_empty() {
      log::error!("User not found: {}", request.username);
      return Err(Status::not_found("User not found"));
    }

    // check user and password (against any potential users)
    let (id, user) = if let Some((id, user)) = users.iter().find(|(_, user)| user.password == request.password) {
      (id, user.clone())
    } else {
      log::error!("Invalid password for user: {}", request.username);
      return Err(Status::unauthenticated("Invalid username or password"));
    };

    // Generate JWT
    let roles: Vec<Role> = user.roles().collect();
    let token = match Auth::generate_token(id, &roles) {
      Ok(t) => t,
      Err(e) => return Err(Status::internal(e.to_string())),
    };

    Ok(Response::new(LoginResponse { token, roles: user.roles }))
  }

  async fn validate_token(
    &self,
    request: Request<ValidateTokenRequest>,
  ) -> Result<Response<ValidateTokenResponse>, Status> {
    require_auth(&request)?;
    Ok(Response::new(ValidateTokenResponse {}))
  }

  async fn update_admin_password(
    &self,
    request: Request<UpdateAdminPasswordRequest>,
  ) -> Result<Response<UpdateAdminPasswordResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    match User::set_admin_password(&request.password) {
      Ok(()) => Ok(Response::new(UpdateAdminPasswordResponse {})),
      Err(e) => Err(Status::internal(e.to_string())),
    }
  }

  // Stream

  type StreamUsersStream = Pin<Box<dyn Stream<Item = Result<StreamUsersResponse, Status>> + Send>>;

  async fn stream_users(
    &self,
    request: Request<StreamUsersRequest>,
  ) -> Result<Response<Self::StreamUsersStream>, Status> {
    require_permission(&request, Role::Admin)?;
    let initial = get_all_users()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<User>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to user events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => data.and_then(|user| {
          if user.username == DEFAULT_ADMIN_USERNAME {
            return None;
          }
          Some(Ok(StreamUsersResponse {
            users: vec![UserResponse { id, username: user.username, roles: user.roles }],
            sync_type: SyncType::Partial as i32,
          }))
        }),
        ChangeEvent::Table => match get_all_users() {
          Ok(users) => Some(Ok(StreamUsersResponse { users, sync_type: SyncType::Full as i32 })),
          Err(e) => {
            log::error!("Failed to get all users after table change: {}", e);
            None
          }
        },
        _ => None,
      },
      Err(BroadcastStreamRecvError::Lagged(n)) => {
        log::warn!("Client lagged by {} messages", n);
        None
      }
    });

    let full_stream =
      tokio_stream::once(Ok(StreamUsersResponse { users: initial, sync_type: SyncType::Full as i32 })).chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  // Create / Update

  async fn create_user(&self, request: Request<CreateUserRequest>) -> Result<Response<CreateUserResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.username.is_empty() || request.password.is_empty() {
      return Err(Status::invalid_argument("Username and password are required"));
    }

    if request.username == DEFAULT_ADMIN_USERNAME {
      return Err(Status::invalid_argument("Cannot create a user with the reserved admin username"));
    }

    let existing = User::get_by_username(&request.username)
      .map_err(|e| Status::internal(format!("Failed to check username: {}", e)))?;

    if !existing.is_empty() {
      return Err(Status::already_exists("A user with that username already exists"));
    }

    let user = User { username: request.username, password: request.password, roles: request.roles };

    User::add(&user).map_err(|e| Status::internal(format!("Failed to create user: {}", e)))?;

    Ok(Response::new(CreateUserResponse {}))
  }

  async fn update_user(&self, request: Request<UpdateUserRequest>) -> Result<Response<UpdateUserResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("User ID is required"));
    }

    let existing = User::get(&request.id).map_err(|e| Status::internal(format!("Failed to get user: {}", e)))?;

    let Some(mut user) = existing else {
      return Err(Status::not_found("User not found"));
    };

    if user.username == DEFAULT_ADMIN_USERNAME {
      return Err(Status::permission_denied("Cannot modify the default admin user"));
    }

    if !request.username.is_empty() {
      user.username = request.username;
    }

    if !request.password.is_empty() {
      user.password = request.password;
    }

    user.roles = request.roles;

    User::update(&request.id, &user).map_err(|e| Status::internal(format!("Failed to update user: {}", e)))?;

    Ok(Response::new(UpdateUserResponse {}))
  }

  async fn delete_user(&self, request: Request<DeleteUserRequest>) -> Result<Response<DeleteUserResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("User ID is required"));
    }

    let existing = User::get(&request.id).map_err(|e| Status::internal(format!("Failed to get user: {}", e)))?;

    let Some(user) = existing else {
      return Err(Status::not_found("User not found"));
    };

    if user.username == DEFAULT_ADMIN_USERNAME {
      return Err(Status::permission_denied("Cannot delete the default admin user"));
    }

    User::remove(&request.id).map_err(|e| Status::internal(format!("Failed to delete user: {}", e)))?;

    Ok(Response::new(DeleteUserResponse {}))
  }
}
