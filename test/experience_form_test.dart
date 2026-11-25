import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

import 'test_helpers.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

/// The test font draws every glyph as a square as wide as its font size, so the
/// DrawerHeader text overflows in tests even though it fits with a real font.
/// Ignore only that overflow; every other error still fails the test.
void ignoreTestFontOverflow() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
      return;
    }
    originalOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = originalOnError);
}

Future<void> openFormFromCard(WidgetTester tester) async {
  await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));
  await tester.tap(find.text('Tambah Experience'));
  await tester.pumpAndSettle();
  // The menu SnackBar follows us to the new route; hide it so it does not
  // cover the Simpan button.
  ScaffoldMessenger.of(tester.element(find.byType(ExperienceFormPage)))
      .hideCurrentSnackBar();
  await tester.pumpAndSettle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Opens the date picker from [label] and chooses [day] of the shown month.
Future<void> pickDay(WidgetTester tester, String label, int day) async {
  await tapVisible(tester, field(label));
  await tester.tap(find.text('$day'));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Tambah Experience card pushes the form and back returns to menu',
    (WidgetTester tester) async {
      await openFormFromCard(tester);

      expect(find.byType(ExperienceFormPage), findsOneWidget);
      expect(find.text('Add Experience Form'), findsOneWidget);

      // push() keeps the menu underneath, so the system back button (Android
      // back / browser back) pops to it. The AppBar shows the drawer icon
      // instead of a back arrow, so simulate the system back action.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ExperienceFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    },
  );

  testWidgets('drawer opens the experience form and Home returns to menu', (
    WidgetTester tester,
  ) async {
    ignoreTestFontOverflow();
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);

    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    expect(find.byType(ExperienceFormPage), findsOneWidget);

    // The same drawer is available on the form page.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ExperienceFormPage), findsNothing);
  });

  testWidgets('Simpan with invalid input shows errors and no dialog', (
    WidgetTester tester,
  ) async {
    await openFormFromCard(tester);

    // Whitespace-only title and an invalid URL.
    await tester.enterText(field('Judul Experience'), '   ');
    await tester.enterText(field('Thumbnail (opsional)'), 'bukan-url');
    // End date before start date.
    await pickDay(tester, 'Tanggal Mulai', 20);
    await pickDay(tester, 'Tanggal Selesai', 10);

    await tapVisible(tester, find.text('Simpan'));

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Judul tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(
      find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Thumbnail harus berupa URL yang diawali http:// atau https://',
      ),
      findsOneWidget,
    );
  });

  testWidgets('empty dates are rejected until picked or marked ongoing', (
    WidgetTester tester,
  ) async {
    await openFormFromCard(tester);

    await tapVisible(tester, find.text('Simpan'));
    expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
    expect(
      find.text('Pilih tanggal selesai atau aktifkan "Masih berjalan"!'),
      findsOneWidget,
    );

    // Picking a date or turning on "Masih berjalan" clears the error at once,
    // without pressing Simpan again.
    await pickDay(tester, 'Tanggal Mulai', 15);
    expect(find.text('Tanggal mulai wajib dipilih!'), findsNothing);

    await tapVisible(tester, find.text('Masih berjalan'));
    expect(
      find.text('Pilih tanggal selesai atau aktifkan "Masih berjalan"!'),
      findsNothing,
    );
  });

  testWidgets('valid input shows the summary dialog and OK resets the form', (
    WidgetTester tester,
  ) async {
    await openFormFromCard(tester);

    await tester.enterText(field('Judul Experience'), 'Asisten Dosen PBP');
    await tester.enterText(field('Deskripsi'), 'Membimbing lab Flutter');
    await tapVisible(tester, find.text('Full-Time'));
    await tester.tap(find.text('Part-Time').last);
    await tester.pumpAndSettle();
    await pickDay(tester, 'Tanggal Mulai', 10);
    await tapVisible(tester, find.text('Masih berjalan'));
    await tester.enterText(
      field('Thumbnail (opsional)'),
      'https://example.com/pbp.png',
    );

    await tapVisible(tester, find.text('Simpan'));

    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Judul: Asisten Dosen PBP'), findsOneWidget);
    expect(find.text('Deskripsi: Membimbing lab Flutter'), findsOneWidget);
    expect(find.text('Kategori: Part-Time'), findsOneWidget);
    expect(
      find.text('Periode: 10/$month/${now.year} - sekarang'),
      findsOneWidget,
    );
    expect(find.text('Thumbnail: https://example.com/pbp.png'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    // Back on the form, every field is cleared again.
    expect(find.text('Asisten Dosen PBP'), findsNothing);
    expect(find.text('10/$month/${now.year}'), findsNothing);
    expect(find.text('Full-Time'), findsOneWidget);
  });
}
