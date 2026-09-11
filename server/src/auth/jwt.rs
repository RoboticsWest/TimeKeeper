use anyhow::Result;
use jsonwebtoken::{DecodingKey, EncodingKey};
use once_cell::sync::OnceCell;
use serde::{Deserialize, Serialize};
use thiserror::Error;

use crate::auth::permissions::{PermissionLevel, parse_claim};

static JWT_SECRET: OnceCell<Vec<u8>> = OnceCell::new();

/// `secret_bytes` comes from the `secret` domain's `SecretRepository::get()` (which
/// generates-and-persists one on first run) - resolved by the caller so this module doesn't need
/// to know about the DB layer.
pub fn init_jwt_secret(secret_bytes: Vec<u8>) -> Result<()> {
  log::info!("Initializing JWT secret");

  if JWT_SECRET.get().is_some() {
    log::warn!("JWT_SECRET already initialized");
  } else {
    JWT_SECRET.set(secret_bytes).map_err(|_| {
      log::error!("Failed to set JWT_SECRET");
      anyhow::anyhow!("Failed to set JWT_SECRET")
    })?;
  }

  Ok(())
}

/// `permissions` is a snapshot of `"<resource_slug>:<level>"` strings, resolved from the
/// `user_permissions` view once at sign time (login/refresh) - not re-checked against the DB per
/// request, so a role change only takes effect on the user's next login.
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
  pub sub: String,
  pub permissions: Vec<String>,
  pub exp: i64,
  pub iat: i64,
}

impl Claims {
  /// Checks whether the token grants at least `required` on `resource` (ceiling semantics -
  /// `Write` satisfies a `Read` requirement, etc).
  pub fn has_permission(&self, resource: &str, required: PermissionLevel) -> bool {
    self.permissions.iter().filter_map(|c| parse_claim(c)).any(|(slug, level)| slug == resource && level >= required)
  }
}

#[derive(Debug, Error)]
pub enum AuthError {
  #[error("Token expired")]
  Expired,
  #[error("Invalid token")]
  Invalid,
  #[error("Token decoding error: {0}")]
  DecodingError(#[from] jsonwebtoken::errors::Error),
}

pub struct Auth;

impl Auth {
  fn encoding_key() -> Result<EncodingKey> {
    let Some(secret) = JWT_SECRET.get() else {
      return Err(anyhow::anyhow!("JWT_SECRET not initialized"));
    };
    Ok(EncodingKey::from_secret(secret))
  }

  fn decoding_key() -> Result<DecodingKey> {
    let Some(secret) = JWT_SECRET.get() else {
      return Err(anyhow::anyhow!("JWT_SECRET not initialized"));
    };
    Ok(DecodingKey::from_secret(secret))
  }

  pub fn generate_token(user_id: &str, permissions: &[String]) -> Result<String> {
    // Expiration time is set to 7 days from now
    let exp = match chrono::Utc::now().checked_add_signed(chrono::Duration::days(7)) {
      Some(exp) => exp.timestamp(),
      None => return Err(anyhow::anyhow!("Failed to calculate expiration time")),
    };

    let claims =
      Claims { sub: user_id.to_string(), permissions: permissions.to_vec(), exp, iat: chrono::Utc::now().timestamp() };

    let encoding_key = Self::encoding_key()?;
    let header = jsonwebtoken::Header::default();
    let token = jsonwebtoken::encode(&header, &claims, &encoding_key)?;
    Ok(token)
  }

  pub fn validate_token(token: &str) -> Result<Claims, AuthError> {
    let token_data = jsonwebtoken::decode::<Claims>(
      token,
      &Self::decoding_key().map_err(|_| AuthError::Invalid)?,
      &jsonwebtoken::Validation::default(),
    )?;

    // Check if the token is expired
    if token_data.claims.exp < chrono::Utc::now().timestamp() {
      return Err(AuthError::Expired);
    }

    Ok(token_data.claims)
  }
}
