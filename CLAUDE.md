# analytics_tracker (mobile dashboard app)

Flutter MOBILE app (Android/iOS only, never a web layout) for the analytics backend in `../backend`.
Design: Claude Design canvas https://claude.ai/artifact/67ynBwj6CHUaPhLSauFDep. Full docs: `README.md`.

- Flutter **3.47.0 via FVM**: always `fvm flutter ...`. Keep `fvm flutter analyze` at 0 issues and `fvm flutter test` green.
- State: **flutter_riverpod 3** (Notifier/AsyncNotifier, no codegen). Routing: go_router (redirect by auth state,
  StatefulShellRoute for the bottom tabs). HTTP: dio via `ApiClient` (backend envelope `{"status","data"/"error"}`).
- Config in `.env` (flutter_dotenv, bundled asset: public values only). Translations: `lib/l10n/app_en.arb` + `app_hi.arb`
  (every user-facing string; run `fvm flutter gen-l10n`). Theme: `core/theme` (light/dark) + `themeModeProvider`.
- Layout per feature: `data/` repository → `application/` controller → `presentation/` screens.
- Tests use `test/helpers/fake_server.dart` (fake Dio adapter) + `makeContainer` / `pumpApp`. For a live check,
  set `HttpOverrides.global = null` against the backend on port 8001 and delete that test + `@demo-hack.io` data after.
- Built: sign in, register, splash/restore, bottom tabs, Overview (insights API), Events (feed, chips, search, cursor
  paging), Users (list, filters) + user timeline (`/events/user/:id`, `/users/:id`), More (+ `/more/projects`,
  `/more/projects/:id`: create project, API keys), `/more/members` (add / role / remove / leave; own role change or
  leaving calls `refreshSession()`). Alerts is "coming soon". Admin-only UI via `isOrganizationAdminProvider`.
- Riverpod `retryPolicy` retries only network errors. Paged lists: `PagedState` + `loadMore()` on scroll; after a failed page, `loadMore` waits for pull-to-refresh.
- 116 tests (~97% coverage); new screens need error/empty-state tests too (see `test/widgets/states_test.dart`).
- **Guardrails** (`.claude/settings.json` + `.claude/hooks/guard.py`, changed by people only): blocked = editing/reading `.env` and keys, `lib/l10n/generated/`, `pubspec.lock`, destructive shell commands; asks a person = `git push`, `pub add/upgrade`. After code edits, `flutter analyze` + `flutter test` must pass before finishing (Stop hook). If blocked, don't work around it: tell the user.
- User preferences: OOP, explain *why*, one step at a time, update README when behaviour changes.
