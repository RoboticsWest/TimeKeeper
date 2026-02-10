use std::pin::Pin;

use tokio_stream::{
  Stream, StreamExt,
  wrappers::{BroadcastStream, errors::BroadcastStreamRecvError},
};
use tonic::{Request, Response, Result, Status};

use crate::{
  auth::auth_helpers::require_permission,
  core::{
    events::{ChangeEvent, EVENT_BUS},
    shutdown::with_shutdown,
  },
  generated::{
    api::{
      CreateTeamMemberRequest, CreateTeamMemberResponse, DeleteTeamMemberRequest, DeleteTeamMemberResponse,
      GetMentorsRequest, GetMentorsResponse, GetStudentsRequest, GetStudentsResponse, GetTeamMembersRequest,
      GetTeamMembersResponse, StreamMentorsRequest, StreamMentorsResponse, StreamStudentsRequest,
      StreamStudentsResponse, StreamTeamMembersRequest, StreamTeamMembersResponse, TeamMemberResponse,
      UpdateTeamMemberRequest, UpdateTeamMemberResponse, UploadMentorCsvRequest, UploadMentorCsvResponse,
      UploadStudentCsvRequest, UploadStudentCsvResponse, team_member_service_server::TeamMemberService,
    },
    common::{Role, SyncType},
    db::{TeamMember, TeamMemberType},
  },
  modules::team_member::{TeamMemberImportList, TeamMemberRepository},
};

pub struct TeamMemberApi;

fn get_all_members() -> std::result::Result<Vec<TeamMemberResponse>, Status> {
  TeamMember::get_all()
    .map_err(|e| Status::internal(format!("Failed to get team members: {}", e)))?
    .into_iter()
    .map(|(id, member)| Ok(TeamMemberResponse { id, team_member: Some(member) }))
    .collect()
}

fn filter_by_type(members: Vec<TeamMemberResponse>, member_type: TeamMemberType) -> Vec<TeamMemberResponse> {
  members.into_iter().filter(|r| r.team_member.as_ref().is_some_and(|m| m.member_type == member_type as i32)).collect()
}

#[tonic::async_trait]
impl TeamMemberService for TeamMemberApi {
  async fn upload_student_csv(
    &self,
    request: Request<UploadStudentCsvRequest>,
  ) -> Result<Response<UploadStudentCsvResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let bytes = request.into_inner().csv_data;
    let csv_string = String::from_utf8_lossy(&bytes);

    let import = match TeamMemberImportList::from_csv(&csv_string) {
      Ok(import) => import,
      Err(err) => return Err(Status::invalid_argument(err.to_string())),
    };

    for member in import.members {
      let existing = match TeamMember::get_by_name(&member.first_name, &member.last_name) {
        Ok(existing) => existing,
        Err(err) => {
          log::error!("Database error checking team member {} {}: {}", member.first_name, member.last_name, err);
          return Err(Status::internal(err.to_string()));
        }
      };

      if !existing.is_empty() {
        continue;
      }

      let new_member = TeamMember {
        first_name: member.first_name,
        last_name: member.last_name,
        member_type: TeamMemberType::Student as i32,
        alias: member.alias,
        secondary_alias: member.secondary_alias,
      };

      match TeamMember::add(&new_member) {
        Ok(_) => {}
        Err(err) => {
          log::error!("Database error adding team member {} {}: {}", new_member.first_name, new_member.last_name, err);
          return Err(Status::internal(err.to_string()));
        }
      }
    }

    Ok(Response::new(UploadStudentCsvResponse {}))
  }

  async fn upload_mentor_csv(
    &self,
    request: Request<UploadMentorCsvRequest>,
  ) -> Result<Response<UploadMentorCsvResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let bytes = request.into_inner().csv_data;
    let csv_string = String::from_utf8_lossy(&bytes);

    let import = match TeamMemberImportList::from_csv(&csv_string) {
      Ok(import) => import,
      Err(err) => return Err(Status::invalid_argument(err.to_string())),
    };

    for member in import.members {
      let existing = match TeamMember::get_by_name(&member.first_name, &member.last_name) {
        Ok(existing) => existing,
        Err(err) => {
          log::error!("Database error checking team member {} {}: {}", member.first_name, member.last_name, err);
          return Err(Status::internal(err.to_string()));
        }
      };

      if !existing.is_empty() {
        continue;
      }

      let new_member = TeamMember {
        first_name: member.first_name,
        last_name: member.last_name,
        member_type: TeamMemberType::Mentor as i32,
        alias: member.alias,
        secondary_alias: member.secondary_alias,
      };

      match TeamMember::add(&new_member) {
        Ok(_) => {}
        Err(err) => {
          log::error!("Database error adding team member {} {}: {}", new_member.first_name, new_member.last_name, err);
          return Err(Status::internal(err.to_string()));
        }
      }
    }

    Ok(Response::new(UploadMentorCsvResponse {}))
  }

  // Getters

  async fn get_team_members(
    &self,
    _request: Request<GetTeamMembersRequest>,
  ) -> Result<Response<GetTeamMembersResponse>, Status> {
    let team_members = get_all_members()?;
    Ok(Response::new(GetTeamMembersResponse { team_members }))
  }

  async fn get_students(&self, _request: Request<GetStudentsRequest>) -> Result<Response<GetStudentsResponse>, Status> {
    let members = get_all_members()?;
    let students = filter_by_type(members, TeamMemberType::Student);
    Ok(Response::new(GetStudentsResponse { students }))
  }

  async fn get_mentors(&self, _request: Request<GetMentorsRequest>) -> Result<Response<GetMentorsResponse>, Status> {
    let members = get_all_members()?;
    let mentors = filter_by_type(members, TeamMemberType::Mentor);
    Ok(Response::new(GetMentorsResponse { mentors }))
  }

  // Streams

  type StreamTeamMembersStream = Pin<Box<dyn Stream<Item = Result<StreamTeamMembersResponse, Status>> + Send>>;

  async fn stream_team_members(
    &self,
    _request: Request<StreamTeamMembersRequest>,
  ) -> Result<Response<Self::StreamTeamMembersStream>, Status> {
    let initial = get_all_members()?;

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<TeamMember>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to team member events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => data.map(|member| {
          Ok(StreamTeamMembersResponse {
            team_members: vec![TeamMemberResponse { id, team_member: Some(member) }],
            sync_type: SyncType::Partial as i32,
          })
        }),
        ChangeEvent::Table => match get_all_members() {
          Ok(members) => {
            Some(Ok(StreamTeamMembersResponse { team_members: members, sync_type: SyncType::Full as i32 }))
          }
          Err(e) => {
            log::error!("Failed to get all team members after table change: {}", e);
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
      tokio_stream::once(Ok(StreamTeamMembersResponse { team_members: initial, sync_type: SyncType::Full as i32 }))
        .chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  type StreamStudentsStream = Pin<Box<dyn Stream<Item = Result<StreamStudentsResponse, Status>> + Send>>;

  async fn stream_students(
    &self,
    _request: Request<StreamStudentsRequest>,
  ) -> Result<Response<Self::StreamStudentsStream>, Status> {
    let initial = filter_by_type(get_all_members()?, TeamMemberType::Student);

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<TeamMember>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to student events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => data.and_then(|member| {
          if member.member_type == TeamMemberType::Student as i32 {
            Some(Ok(StreamStudentsResponse {
              students: vec![TeamMemberResponse { id, team_member: Some(member) }],
              sync_type: SyncType::Partial as i32,
            }))
          } else {
            None
          }
        }),
        ChangeEvent::Table => match get_all_members() {
          Ok(members) => {
            let students = filter_by_type(members, TeamMemberType::Student);
            Some(Ok(StreamStudentsResponse { students, sync_type: SyncType::Full as i32 }))
          }
          Err(e) => {
            log::error!("Failed to get students after table change: {}", e);
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
      tokio_stream::once(Ok(StreamStudentsResponse { students: initial, sync_type: SyncType::Full as i32 }))
        .chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  type StreamMentorsStream = Pin<Box<dyn Stream<Item = Result<StreamMentorsResponse, Status>> + Send>>;

  async fn stream_mentors(
    &self,
    _request: Request<StreamMentorsRequest>,
  ) -> Result<Response<Self::StreamMentorsStream>, Status> {
    let initial = filter_by_type(get_all_members()?, TeamMemberType::Mentor);

    let Some(event_bus) = EVENT_BUS.get() else {
      return Err(Status::internal("Event bus not initialized"));
    };

    let rx = event_bus
      .subscribe::<TeamMember>()
      .map_err(|e| Status::internal(format!("Failed to subscribe to mentor events: {}", e)))?;

    let stream = BroadcastStream::new(rx).filter_map(|result| match result {
      Ok(event) => match event {
        ChangeEvent::Record { id, data, .. } => data.and_then(|member| {
          if member.member_type == TeamMemberType::Mentor as i32 {
            Some(Ok(StreamMentorsResponse {
              mentors: vec![TeamMemberResponse { id, team_member: Some(member) }],
              sync_type: SyncType::Partial as i32,
            }))
          } else {
            None
          }
        }),
        ChangeEvent::Table => match get_all_members() {
          Ok(members) => {
            let mentors = filter_by_type(members, TeamMemberType::Mentor);
            Some(Ok(StreamMentorsResponse { mentors, sync_type: SyncType::Full as i32 }))
          }
          Err(e) => {
            log::error!("Failed to get mentors after table change: {}", e);
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
      tokio_stream::once(Ok(StreamMentorsResponse { mentors: initial, sync_type: SyncType::Full as i32 }))
        .chain(stream);
    let full_stream = with_shutdown(full_stream);

    Ok(Response::new(Box::pin(full_stream)))
  }

  // Create / Update / Delete

  async fn create_team_member(
    &self,
    request: Request<CreateTeamMemberRequest>,
  ) -> Result<Response<CreateTeamMemberResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.first_name.is_empty() || request.last_name.is_empty() {
      return Err(Status::invalid_argument("First name and last name are required"));
    }

    let member = TeamMember {
      first_name: request.first_name,
      last_name: request.last_name,
      member_type: request.member_type,
      alias: request.alias,
      secondary_alias: request.secondary_alias,
    };

    TeamMember::add(&member).map_err(|e| Status::internal(format!("Failed to create team member: {}", e)))?;

    Ok(Response::new(CreateTeamMemberResponse {}))
  }

  async fn update_team_member(
    &self,
    request: Request<UpdateTeamMemberRequest>,
  ) -> Result<Response<UpdateTeamMemberResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("Team member ID is required"));
    }

    let existing =
      TeamMember::get(&request.id).map_err(|e| Status::internal(format!("Failed to get team member: {}", e)))?;

    let Some(_) = existing else {
      return Err(Status::not_found("Team member not found"));
    };

    let member = TeamMember {
      first_name: request.first_name,
      last_name: request.last_name,
      member_type: request.member_type,
      alias: request.alias,
      secondary_alias: request.secondary_alias,
    };

    TeamMember::update(&request.id, &member)
      .map_err(|e| Status::internal(format!("Failed to update team member: {}", e)))?;

    Ok(Response::new(UpdateTeamMemberResponse {}))
  }

  async fn delete_team_member(
    &self,
    request: Request<DeleteTeamMemberRequest>,
  ) -> Result<Response<DeleteTeamMemberResponse>, Status> {
    require_permission(&request, Role::Admin)?;
    let request = request.into_inner();

    if request.id.is_empty() {
      return Err(Status::invalid_argument("Team member ID is required"));
    }

    let existing =
      TeamMember::get(&request.id).map_err(|e| Status::internal(format!("Failed to get team member: {}", e)))?;

    if existing.is_none() {
      return Err(Status::not_found("Team member not found"));
    }

    TeamMember::remove(&request.id).map_err(|e| Status::internal(format!("Failed to delete team member: {}", e)))?;

    Ok(Response::new(DeleteTeamMemberResponse {}))
  }
}
