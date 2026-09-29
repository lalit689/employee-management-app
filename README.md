# Employee Management App (Flutter)

A small Employee Management mobile app built with Flutter, showing login,
an employee dashboard with search/filter, employee details, and REST API
integration using Provider for state management.

## Tech Stack
- Flutter + Dart
- Provider (state management)
- http (REST API calls)
- Free public API: [JSONPlaceholder](https://jsonplaceholder.typicode.com/) `/users` endpoint

## Features
- **Login Screen** – Local/demo login (no paid auth service) with email &
  password validation and clear error messages.
  - Demo credentials: `admin@example.com` / `admin123`
- **Employee Dashboard** – Fetches employees from JSONPlaceholder and shows
  name, ID, email, and department (mapped from the API's `company.name`
  field, since JSONPlaceholder has no literal "department" field).
- **Employee Details** – Full details screen (ID, username, email, phone,
  website, city) with back navigation.
- **REST API Integration** – Real HTTP GET request, JSON parsing, loading
  spinner, and user-friendly error handling with a Retry button.
- **Search & Filter** – Search by name (live filter) and filter by
  department using chips.
- **State Management** – `Provider` (`AuthProvider`, `EmployeeProvider`)
  cleanly separates data/business logic from the UI, exposing
  loading/success/error states.
- **Pull-to-refresh** included as a bonus.

## Known Limitations
- JSONPlaceholder does not provide profile images, so avatars are generated
  locally from the employee's initials (no extra third-party image API used,
  keeping everything free and offline-safe).
- JSONPlaceholder does not have a literal "department" field; the `company.name`
  field from the API is used as the department/category for grouping and filtering.
- Login is a local/demo login only, as permitted by the task (no backend auth).

## Project Structure
```
lib/
├── main.dart                     # App entry point, sets up Providers & theme
├── models/
│   └── employee.dart             # Employee model + JSON parsing
├── services/
│   └── api_service.dart          # HTTP calls to JSONPlaceholder, error handling
├── providers/
│   ├── auth_provider.dart        # Demo login state (loading/error/success)
│   └── employee_provider.dart    # Employee list state, search & filter logic
├── screens/
│   ├── login_screen.dart         # Login UI + validation
│   ├── dashboard_screen.dart     # Employee list, search bar, filter chips
│   └── employee_detail_screen.dart # Employee detail layout
├── widgets/
│   └── employee_card.dart        # Reusable list item widget
└── utils/
    └── validators.dart           # Email/password validation helpers
```

## API & Provider Implementation (short explanation)
- `ApiService.fetchEmployees()` sends a `GET` request to
  `https://jsonplaceholder.typicode.com/users`, parses the JSON array into a
  list of `Employee` objects, and throws a custom `ApiException` on network,
  format, or server errors.
- `EmployeeProvider` (a `ChangeNotifier`) calls `ApiService`, tracks a
  `LoadStatus` enum (`initial`, `loading`, `success`, `error`), and keeps both
  the full employee list and a filtered list (updated on every search/filter
  change). The UI (`DashboardScreen`) listens to this provider via
  `context.watch<EmployeeProvider>()` and rebuilds automatically.
- `AuthProvider` manages the demo login flow the same way, exposing
  `isLoading` and `errorMessage` so the Login screen can show a spinner or
  an inline error without any extra boilerplate in the UI.

## How to Run

### Option A: Run locally with Flutter SDK (recommended)
1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   and set up Android Studio or VS Code with the Flutter/Dart plugins.
2. Clone/download this project and open it in your editor.
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run on a connected device/emulator:
   ```
   flutter run
   ```
5. Build a release APK:
   ```
   flutter build apk --release
   ```
   The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

### Option B: Run online (no local install)
Since Flutter needs its SDK and cannot run as a single web file, use a free
cloud IDE with Flutter pre-configured, such as:
- **Replit** – create a new "Flutter" template repl and upload these files.
- **FlutLab.io** – a free browser-based Flutter IDE that can build an APK
  for you directly, without installing anything locally.
- **GitHub Codespaces** (free tier) – open this repo in a Codespace with the
  Flutter SDK installed via a `devcontainer`.

Paste in the files from this project (keeping the folder structure), run
`flutter pub get`, then `flutter run` (or use the IDE's build button to
generate an APK).

## Login Credentials (for testing)
- Email: `admin@example.com`
- Password: `admin123`
