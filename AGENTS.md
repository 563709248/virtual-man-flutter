# AI Friend App Contributor Guide

## Project Overview

This repository is a Flutter application for an AI friend chat experience. The
application entry point is `lib/main.dart`.

## Repository Layout

- `lib/config/`: API configuration.
- `lib/models/`: data models.
- `lib/pages/`: screen widgets and user-facing flows.
- `lib/services/`: HTTP, authentication, chat, and logging behavior.
- `test/`: Flutter widget and unit tests.
- Platform directories (`android/`, `ios/`, `linux/`, `macos/`, `web/`, and
  `windows/`) are generated Flutter runner projects. Avoid editing them unless
  a platform-specific change is required.

## Development Commands

Run these commands from the repository root:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Before submitting changes, run `dart format .`, then run analysis and the
relevant tests.

## Implementation Conventions

- Follow the lints in `analysis_options.yaml` and the existing Dart style.
- Keep UI concerns in `pages`, data representations in `models`, and network
  or persistence behavior in `services`.
- Prefer typed models and explicit error handling at service boundaries.
- Reuse the shared Dio client in `services/api_service.dart` for API requests.
- Keep API endpoints and base URL configuration centralized in `config`.
- Do not commit secrets, tokens, user data, generated build output, or local
  IDE settings.

## Testing Guidance

- Add or update focused tests for behavior changes, especially service
  serialization, authentication flows, and user-visible chat behavior.
- Use widget tests for screen interactions and unit tests for models and
  services where possible.
- If an end-to-end backend is unavailable, mock network dependencies rather
  than making tests depend on a live API.

## Change Discipline

- Keep changes scoped to the requested behavior; do not refactor unrelated
  files.
- Preserve existing user changes in a dirty worktree.
- Document new configuration values and their required environment setup in
  the README when applicable.
