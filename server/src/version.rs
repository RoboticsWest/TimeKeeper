//! Version reporting, so a client can tell the user it is out of date.
//!
//! There is no OTA update path for a Flutter desktop binary that is worth having — replacing a
//! running executable in place is fragile on every platform and differs on all three. So the
//! client does not update itself: it compares its own version against the server's and, when
//! the server is meaningfully newer, points the user at the release page.
//!
//! "Meaningfully" means a major or minor difference. A patch bump is routinely a server-side
//! typo fix that does not require anyone to reinstall a client, and nagging every desktop in
//! the building about it teaches people to dismiss the dialog without reading it.

use async_graphql::{Context, Object, Result, SimpleObject};

/// The release version, injected by `build.rs` from `vars.yml`.
pub const TK_VERSION: &str = env!("TK_VERSION");

/// Where a user goes to get the current build.
pub const RELEASES_URL: &str = "https://github.com/RoboticsWest/TimeKeeper/releases/latest";

/// A `major.minor.patch` triple. Anything unparseable becomes `0.0.0`, which the comparison
/// treats as "unknown" and therefore never prompts on.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Default)]
pub struct Version {
  pub major: u32,
  pub minor: u32,
  pub patch: u32,
}

impl Version {
  pub fn parse(text: &str) -> Self {
    // Tolerate a leading "v" and a trailing build suffix ("1.0.0+1", "3.0.2-rc1").
    let cleaned = text.trim().trim_start_matches('v');
    let core = cleaned.split(['+', '-']).next().unwrap_or("");
    let mut parts = core.split('.').map(|p| p.parse::<u32>().unwrap_or(0));
    Self { major: parts.next().unwrap_or(0), minor: parts.next().unwrap_or(0), patch: parts.next().unwrap_or(0) }
  }

  fn is_unknown(self) -> bool {
    self == Self::default()
  }

  /// Whether `self` is a major/minor release ahead of `other`.
  ///
  /// Patch differences deliberately do not count. An unknown version on either side never
  /// counts either: a locally built client has no meaningful version, and telling a developer
  /// their debug build is out of date every few hours is pure noise.
  pub fn is_update_required_over(self, other: Self) -> bool {
    if self.is_unknown() || other.is_unknown() {
      return false;
    }
    (self.major, self.minor) > (other.major, other.minor)
  }
}

/// What the client needs to decide whether to prompt.
#[derive(SimpleObject)]
pub struct VersionInfo {
  /// The server's version, which is also the version of the matching client release.
  pub version: String,
  /// Where to download the current build.
  pub releases_url: String,
}

#[derive(Default)]
pub struct VersionQuery;

#[Object]
impl VersionQuery {
  /// The running server's version.
  ///
  /// Deliberately unauthenticated: the login screen needs it too, and a version number is not
  /// sensitive — it is already printed on the public releases page.
  async fn version_info(&self, _ctx: &Context<'_>) -> Result<VersionInfo> {
    Ok(VersionInfo { version: TK_VERSION.to_string(), releases_url: RELEASES_URL.to_string() })
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn parses_a_plain_triple() {
    assert_eq!(Version::parse("3.0.2"), Version { major: 3, minor: 0, patch: 2 });
  }

  #[test]
  fn tolerates_a_v_prefix_and_build_suffix() {
    assert_eq!(Version::parse("v3.0.2"), Version { major: 3, minor: 0, patch: 2 });
    assert_eq!(Version::parse("1.0.0+1"), Version { major: 1, minor: 0, patch: 0 });
    assert_eq!(Version::parse("3.1.0-rc1"), Version { major: 3, minor: 1, patch: 0 });
  }

  #[test]
  fn garbage_parses_as_unknown() {
    assert_eq!(Version::parse("not-a-version"), Version::default());
    assert_eq!(Version::parse(""), Version::default());
  }

  #[test]
  fn a_minor_bump_requires_an_update() {
    assert!(Version::parse("3.1.0").is_update_required_over(Version::parse("3.0.2")));
  }

  #[test]
  fn a_major_bump_requires_an_update() {
    assert!(Version::parse("4.0.0").is_update_required_over(Version::parse("3.9.9")));
  }

  /// The whole point of the major/minor rule: a typo fix must not nag every desktop.
  #[test]
  fn a_patch_bump_does_not() {
    assert!(!Version::parse("3.0.3").is_update_required_over(Version::parse("3.0.2")));
    assert!(!Version::parse("3.0.9").is_update_required_over(Version::parse("3.0.0")));
  }

  #[test]
  fn an_equal_or_newer_client_is_never_prompted() {
    assert!(!Version::parse("3.0.2").is_update_required_over(Version::parse("3.0.2")));
    assert!(!Version::parse("3.0.2").is_update_required_over(Version::parse("3.1.0")));
  }

  #[test]
  fn an_unknown_version_on_either_side_never_prompts() {
    assert!(!Version::parse("0.0.0").is_update_required_over(Version::parse("3.0.2")));
    assert!(!Version::parse("3.0.2").is_update_required_over(Version::parse("0.0.0")));
  }
}
