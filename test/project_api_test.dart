import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'test_helpers.dart';

const _projectJson = {
  'id': 7,
  'title': 'MyPortfolio',
  'role': 'Full-stack developer',
  'description': 'Website portofolio Django',
  'year': '2026',
  'github_url': 'https://github.com/6avier/myportofolio',
  'demo_url': null,
  'star_count': 2,
  'is_starred': false,
  'starred_by_names': 'a, b',
};

/// A fake backend that records requests and answers like the Django API.
class FakeBackend {
  FakeBackend({
    this.projects = const [_projectJson],
    this.createStatus = 201,
    this.listStatus = 200,
  });

  List<Map<String, dynamic>> projects;
  int createStatus;
  int listStatus;
  final requests = <http.Request>[];

  ApiClient client() => fakeApiClient((request) async {
    requests.add(request);
    final path = request.url.path;
    if (path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['password'] == 'secret') {
        return http.Response(jsonEncode({'token': 'abc123'}), 200);
      }
      return http.Response('{"non_field_errors": ["bad"]}', 400);
    }
    if (path == '/api/v1/auth/logout/') return http.Response('', 204);
    if (path == '/api/v1/projects/' && request.method == 'GET') {
      return http.Response(jsonEncode(projects), listStatus);
    }
    if (path == '/api/v1/projects/' && request.method == 'POST') {
      if (createStatus != 201) return http.Response('{}', createStatus);
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({...body, 'id': 99, 'star_count': 0}),
        201,
      );
    }
    return http.Response('not found', 404);
  });
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void hideSnackBar(WidgetTester tester) {
  ScaffoldMessenger.of(tester.element(find.byType(Scaffold).last))
      .hideCurrentSnackBar();
}

Future<void> login(WidgetTester tester, {String password = 'secret'}) async {
  expect(find.byType(LoginScreen), findsOneWidget);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Username'),
    'owner',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Password'),
    password,
  );
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

Future<void> fillProjectForm(WidgetTester tester) async {
  Finder field(String label) => find.widgetWithText(TextFormField, label);
  await tester.enterText(field('Title'), 'Mobile app');
  await tester.enterText(field('Role'), 'Flutter developer');
  await tester.enterText(field('Description'), 'Dibuat dengan Flutter');
  await tester.enterText(field('Year'), '2026');
  await tester.enterText(
    field('GitHub URL (opsional)'),
    'https://github.com/6avier/myportofolio_mobile',
  );
}

void main() {
  group('Project model', () {
    test('maps snake_case JSON and skips read-only fields in toJson', () {
      final project = Project.fromJson(_projectJson);
      expect(project.id, 7);
      expect(project.githubUrl, 'https://github.com/6avier/myportofolio');
      expect(project.demoUrl, isNull);
      expect(project.starCount, 2);

      final json = project.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('star_count'), isFalse);
      expect(json['github_url'], 'https://github.com/6avier/myportofolio');
    });
  });

  group('ApiClient', () {
    test('createProject sends the token header and JSON body', () async {
      final backend = FakeBackend();
      const project = Project(
        title: 'T',
        role: 'R',
        description: 'D',
        year: '2026',
      );
      final created = await backend.client().createProject(
        project,
        token: 'abc123',
      );

      final request = backend.requests.single;
      expect(request.method, 'POST');
      expect(request.headers['Authorization'], 'Token abc123');
      expect(jsonDecode(request.body), {
        'title': 'T',
        'role': 'R',
        'description': 'D',
        'year': '2026',
        'github_url': null,
        'demo_url': null,
      });
      expect(created.id, 99);
    });

    test('non-2xx responses throw ApiException', () async {
      final backend = FakeBackend(listStatus: 500);
      expect(
        backend.client().getProjects(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  testWidgets('Lihat Proyek lists projects from the API and opens a detail', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().client()));

    await tapVisible(tester, find.text('Lihat Proyek'));
    expect(find.byType(ProjectListScreen), findsOneWidget);
    expect(find.text('MyPortfolio'), findsOneWidget);

    await tester.tap(find.text('MyPortfolio'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('Full-stack developer'), findsOneWidget);
    expect(find.text('2 star'), findsOneWidget);
    expect(find.text('https://github.com/6avier/myportofolio'), findsOneWidget);
    // demo_url is null, so there is no Demo link.
    expect(find.text('Demo'), findsNothing);
  });

  testWidgets('project list shows an empty message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(apiClient: FakeBackend(projects: []).client()),
    );
    await tapVisible(tester, find.text('Lihat Proyek'));
    expect(find.text('No projects found.'), findsOneWidget);
  });

  testWidgets('project list shows an error and Retry loads again', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend(listStatus: 500);
    await tester.pumpWidget(MyApp(apiClient: backend.client()));
    await tapVisible(tester, find.text('Lihat Proyek'));

    expect(find.textContaining('Gagal memuat proyek'), findsOneWidget);
    expect(find.textContaining('Server sedang bermasalah'), findsOneWidget);

    backend.listStatus = 200;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('MyPortfolio'), findsOneWidget);
  });

  testWidgets('Tambah Proyek asks to log in first, then opens the form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().client()));

    await tapVisible(tester, find.text('Tambah Proyek'));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);

    // Wrong password keeps the user on the login screen.
    await login(tester, password: 'wrong');
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.textContaining('Username atau password salah'), findsOneWidget);

    await login(tester);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });

  testWidgets('leaving the login screen does not open the form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: FakeBackend().client()));
    await tapVisible(tester, find.text('Tambah Proyek'));
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsNothing);
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('project form validates, POSTs with the token, shows a dialog', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.client()));
    await tapVisible(tester, find.text('Tambah Proyek'));
    await login(tester);
    hideSnackBar(tester);
    await tester.pumpAndSettle();

    // Empty required fields and a bad URL block the request.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Demo URL (opsional)'),
      'bukan-url',
    );
    await tapVisible(tester, find.text('Save'));
    expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Role tidak boleh kosong!'), findsOneWidget);
    expect(
      find.text('URL harus diawali http:// atau https://'),
      findsOneWidget,
    );
    expect(backend.requests.where((r) => r.method == 'POST').length, 1);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Demo URL (opsional)'),
      '',
    );
    await fillProjectForm(tester);
    await tapVisible(tester, find.text('Save'));

    final post = backend.requests.last;
    expect(post.url.path, '/api/v1/projects/');
    expect(post.headers['Authorization'], 'Token abc123');
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('ID: 99'), findsOneWidget);
    expect(find.text('Judul: Mobile app'), findsOneWidget);
    expect(find.text('Demo: -'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Mobile app'), findsNothing);
  });

  testWidgets('a 401 on save logs out and asks to log in again', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend(createStatus: 401);
    await tester.pumpWidget(MyApp(apiClient: backend.client()));
    await tapVisible(tester, find.text('Tambah Proyek'));
    await login(tester);
    hideSnackBar(tester);
    await tester.pumpAndSettle();

    await fillProjectForm(tester);
    await tapVisible(tester, find.text('Save'));

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      backend.requests.any((r) => r.url.path == '/api/v1/auth/logout/'),
      isTrue,
    );
  });

  testWidgets('drawer shows Login or Logout and guards Add Project', (
    WidgetTester tester,
  ) async {
    ignoreTestFontOverflow();
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.client()));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    await login(tester);
    expect(find.byType(ProjectFormPage), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Login'), findsNothing);
    await tester.tap(find.widgetWithText(ListTile, 'Logout'));
    await tester.pumpAndSettle();
    expect(backend.requests.last.url.path, '/api/v1/auth/logout/');
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('Logout card logs out when logged in', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend();
    await tester.pumpWidget(MyApp(apiClient: backend.client()));
    await tapVisible(tester, find.text('Tambah Proyek'));
    await login(tester);
    // The form has a drawer instead of a back arrow; use the system back.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Logout'));
    expect(backend.requests.last.url.path, '/api/v1/auth/logout/');
    expect(find.text('Kamu berhasil logout.'), findsOneWidget);
  });
}
