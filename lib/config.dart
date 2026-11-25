/// Base URL of the Django REST Framework backend.
///
/// Defaults to `http://10.0.2.2:8000`, the host machine as seen from the
/// Android emulator. Override it with
/// `--dart-define=API_BASE_URL=http://localhost:8000` when running on Chrome,
/// or with the deployed PWS domain for a release build.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
