# Analytics Tracker (mobile dashboard)

Flutter app for the analytics platform: organizations sign up or sign in, then see their projects and
(soon) analytics. Design: the "Analytics Dashboard App" canvas.

- Flutter **3.47.0** via FVM (`.fvmrc`) · state: **flutter_riverpod 3** · routing: **go_router**
- HTTP: **dio** with automatic token refresh · config: **flutter_dotenv** (`.env`)
- Translations: English + Hindi (`lib/l10n/*.arb`) · Themes: system / light / dark

## Run

1. Start the backend (`../backend`): `.venv/bin/uvicorn app.main:app --reload` (port 8000)
2. From this folder:

```bash
cp .env.example .env       # first time only; .env is not in git
fvm flutter pub get
fvm flutter run            # pick an iOS simulator or Android emulator
```

## Configuration: `.env`

Bundled with the app as an asset, so **only public settings** go here (no secrets).
`.env` is git-ignored so each machine can point at its own backend; `.env.example` lists the keys.

| Variable | Default | Notes |
|---|---|---|
| `API_BASE_URL` | `http://localhost:8000/api/v1` | iOS simulator and others |
| `API_BASE_URL_ANDROID` | `http://10.0.2.2:8000/api/v1` | Used on Android: the emulator reaches the Mac's localhost via 10.0.2.2 |
| `CONNECT_TIMEOUT_SECONDS` | `10` | |
| `RECEIVE_TIMEOUT_SECONDS` | `20` | |

On a real phone use the Mac's network address, e.g. `http://192.168.1.5:8000/api/v1`.
Restart the app (not hot reload) after changing `.env`.

## What's built

| Screen | Backend |
|---|---|
| Sign in | `POST /auth/login` |
| Create organization (you become admin) | `POST /auth/register` |
| Splash → restores the saved login | `POST /auth/refresh`, `GET /auth/me` |
| Dashboard with bottom tabs: Overview · Events · Users · Alerts · More | |
| Overview: project switcher, range (today / 7 / 30 / 90 days), KPIs with % change, events-per-day chart, top screens, top events | `GET /orgs/{id}/projects`, `GET .../insights/overview` |
| Events: search (waits 400 ms after typing), event-name chips, grouped by day, infinite scroll, tap → user | `GET .../events` (cursor), `GET .../event-definitions` |
| Users: search, All / Known / New with counts, infinite scroll, tap → user | `GET .../persons` |
| User timeline: traits, sessions / events / first seen, recent sessions as step-by-step timelines | `GET .../persons/{id}` |
| Overview, Events and Users always show **one project**: its name is under the title, tap it to switch (the choice is shared by all tabs) | — |
| Alerts: "coming soon" until its API exists | — |
| More → **Projects and API keys**: every project (platform, timezone, active keys); admins get **New project** (first key shown once) | `GET/POST /orgs/{id}/projects` |
| Project detail: details, **API keys** (admins: new key shown once with Copy, revoke with confirmation), copy-paste **SDK setup** | `GET/POST/DELETE .../api-keys` |
| More → **Members and roles**: everyone in the organization (role, joined, “You”). Admins **add** (existing account, or a new one with a temporary password), **change role** (tap the role chip) and **remove**; anyone can **leave**. Server reasons (e.g. “must keep at least one admin”) are shown as-is | `GET/POST /orgs/{id}/members`, `PATCH/DELETE .../members/{user_id}` |
| More: account, organization switcher, theme, language, sign out | `POST /auth/logout` |

## How login works

- Access token (15 min) is kept **in memory**; refresh token (7 days) in **secure storage** (Keychain / Keystore).
- `AuthInterceptor` adds `Authorization: Bearer …`. On a `401` it refreshes **once** (several failing requests
  share one refresh, since each refresh token works once) and repeats the request.
- If refreshing fails, the user is signed out and sent to Sign in. Offline at start → Sign in, tokens kept.
- Failed data loads are retried automatically **only for network errors** (1 s, 2 s, 4 s); server errors show
  "Try again" (`retryPolicy` in `core/providers.dart`).
- `go_router` redirects by sign-in state: checking → splash, signed out → sign in/register, signed in → dashboard.

## Code layout

```
lib/
├── main.dart                       loads .env + SharedPreferences, starts ProviderScope
├── app.dart                        MaterialApp.router: theme, dark theme, locale, l10n delegates
├── core/
│   ├── config/app_config.dart      reads .env
│   ├── network/                    ApiClient (envelope → data / ApiException), AuthInterceptor, TokenRefresher
│   ├── storage/token_storage.dart  access token in memory, refresh token in secure storage
│   ├── settings/                   themeModeProvider, localeProvider (saved in SharedPreferences)
│   ├── theme/                      AppTheme (light/dark), AppColors (extra design colors)
│   ├── router/                     routes + redirect by auth state + bottom-tab shell
│   ├── widgets/app_widgets.dart    LabeledTextField, ErrorBanner, EmptyState, AppLogo
│   └── providers.dart              Dio, ApiClient, TokenStorage, config providers
├── features/
│   ├── auth/                       data (repository) · domain (models) · application (AuthController) · presentation (screens)
│   ├── workspace/                  selected organization + its projects (WorkspaceController)
│   ├── dashboard/                  DashboardShell: the bottom NavigationBar
│   ├── insights/                   overview API + overviewProvider (per project + range)
│   ├── explorer/                   events / persons API + paged controllers (EventFeedController, PersonListController)
│   ├── projects/                   create project, API keys (ApiKeysController), canManageProjectsProvider
│   ├── members/                    team list, add / change role / remove / leave (MembersController)
│   ├── overview/ events/ users/ alerts/ more/ splash/
└── l10n/                           app_en.arb, app_hi.arb → generated/ (fvm flutter gen-l10n)
```

## Translations

Add a text: put the key in `lib/l10n/app_en.arb` **and** `app_hi.arb`, then `fvm flutter gen-l10n`
(also runs on `pub get` / build). Use it with `AppLocalizations.of(context).yourKey`.
Add a language: create `app_<code>.arb` and add the `Locale` to `LocaleNotifier.supported`.

## Tests

```bash
fvm flutter analyze
fvm flutter test                 # 116 tests
fvm flutter test --coverage      # writes coverage/lcov.info (~97% of app code, translations excluded)
```

Tests run the real repositories, interceptor and screens against `test/helpers/fake_server.dart`, a fake backend
plugged into Dio (same `{"status", "data"/"error"}` responses), so no network is needed.

| File | Covers |
|---|---|
| `test/core/app_config_test.dart` | `.env` parsing, Android URL, defaults |
| `test/core/api_client_test.dart` | envelope → data, server / network / unexpected errors |
| `test/core/auth_interceptor_test.dart` | bearer token, refresh + retry, one shared refresh, session expiry, no refresh on login, offline while refreshing keeps the login, no refresh loop |
| `test/features/auth_controller_test.dart` | restore (none / valid / expired / offline), sign in, register, sign out (online/offline) |
| `test/features/settings_test.dart` | theme and language saved and restored |
| `test/features/validators_test.dart` | form rules |
| `test/widgets/auth_screens_test.dart` | sign-in and register screens: validation, server errors, offline, success |
| `test/widgets/dashboard_test.dart` | saved login, project switch, empty states, tabs, dark theme, Hindi, sign out |
| `test/widgets/analytics_screens_test.dart` | overview KPIs / % change / chart / top lists / range / empty / retry; events list, chips, debounced search, cursor paging, tap → user; users list, counts, filter, timeline |
| `test/widgets/projects_screens_test.dart` | More → projects, admin vs viewer, keys list, new key shown once + copy, revoke, new project + its key, server errors, selection kept on reload |
| `test/widgets/members_screen_test.dart` | members list + You tag, viewer restrictions, add member (new / existing account, 400 / 409 in the form, password check), change role, last-admin 409, remove with confirm, leave → session refresh + Overview |
| `test/core/formatters_test.dart` | numbers, durations, % change, relative times, Hindi |
| `test/features/explorer_providers_test.dart` | paging rules: cursor (events) and offset (users), end of list, a failed page waits for pull-to-refresh, filters sent |
| `test/widgets/states_test.dart` | workspace / feed / users / user / members / API keys failing + retry, offline, no project / no organization, users paging + debounced search, switch organization, super admin badge |

A failed "load more" no longer retries on every scroll: the list shows "Couldn't load more. Pull down to
refresh." and waits for pull-to-refresh (fixed Oct 2026; covered in both files above).
