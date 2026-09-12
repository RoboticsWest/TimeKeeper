# Contributing to TK

## Getting Started
**Prerequisites:**
- [Rust](https://rust-lang.org/tools/install/)
- [Flutter](https://docs.flutter.dev/install)
- [Pre-Commit](https://pre-commit.com/) (optional but recommended)

**Installation:**
1. Clone and install the pre-commit hooks:
   ```bash
   git clone https://github.com/CurtinFRC/TimeKeeper.git
   cd TimeKeeper
   pre-commit install
   ```
2. Build the server:
   ```bash
   cargo build
   ```
3. Install client dependencies:
   ```bash
   cd client
   flutter pub get
   ```

**Compiling**
1. Compile the server (from workspace)
   ```bash
   cargo build
   ```
2. Compile the client
- The Flutter client uses riverpod which generates code for state management and data models.
- It's recommended to run the build_runner to generate any lingering code. Or run it with `watch` to automatically regenerate code.
   ```bash
   cd client
   dart run build_runner build --delete-conflicting-outputs
   flutter build
   ```

## Project Structure
| **Directory** | **Description** |
|---------------|-----------------|
| `/database` | Postgres schema, Diesel migrations and shared DB library |
| `/server` | Server-side code |
| `/client` | Client-side code (in flutter) |
| `/docs` | Documentation for the project |
