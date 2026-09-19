//! Embeds the project version into the binary at compile time.
//!
//! `vars.yml` at the workspace root is the single source of truth for the release version —
//! CI reads it to tag `v<version>` and to name the GitHub release. `Cargo.toml`'s own version
//! is not kept in step with it (and `pubspec.yaml`'s is not either), so reading it here keeps
//! the number the server reports identical to the one on the release the user would download.
//!
//! Parsed by hand rather than with a YAML crate: this is one key in a five-line file, and a
//! build-dependency for it would be paid on every clean build of the workspace.

use std::path::Path;

fn main() {
  let vars_path = Path::new("..").join("vars.yml");
  println!("cargo:rerun-if-changed={}", vars_path.display());

  let version = std::fs::read_to_string(&vars_path).ok().and_then(|text| parse_tk_version(&text));

  if let Some(version) = version {
    println!("cargo:rustc-env=TK_VERSION={version}");
  } else {
    // Not fatal: a source tree without vars.yml still has to build. "0.0.0" is the agreed
    // "unknown version" sentinel, and the update check treats it as "do not nag".
    println!("cargo:warning=Could not read tk_version from vars.yml; reporting 0.0.0");
    println!("cargo:rustc-env=TK_VERSION=0.0.0");
  }
}

/// Pulls `value:` out of the `tk_version` entry.
///
/// ```yaml
/// variables:
///   - name: tk_version
///     value: 3.0.2
/// ```
fn parse_tk_version(text: &str) -> Option<String> {
  let mut lines = text.lines();
  while let Some(line) = lines.next() {
    if line.split('#').next().unwrap_or("").contains("name: tk_version") {
      for following in lines.by_ref().take(3) {
        if let Some((_, value)) = following.split_once("value:") {
          let value = value.split('#').next().unwrap_or("").trim().trim_matches('"').trim_matches('\'');
          if !value.is_empty() {
            return Some(value.to_string());
          }
        }
      }
      return None;
    }
  }
  None
}
