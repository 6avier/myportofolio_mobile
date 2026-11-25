import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

import 'test_helpers.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

void main() {
  testWidgets('home page shows the owner info cards and menu buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text('2506656886'), findsOneWidget);
    expect(find.text('Kemas Xavier Alvaresyah'), findsOneWidget);
    expect(find.text('PBP C'), findsOneWidget);

    expect(find.byType(ItemCard), findsNWidgets(4));
    expect(find.text('Lihat Experience'), findsOneWidget);
    expect(find.text('Tambah Experience'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('every menu card has its own background color from its model',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    final cards = tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();
    final colors = cards.map((card) {
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byWidget(card),
          matching: find.byType(Material),
        ).first,
      );
      expect(material.color, card.item.color);
      return material.color;
    }).toSet();

    expect(colors.length, cards.length);
  });

  testWidgets('tapping a menu card shows a SnackBar with its name',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));
    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.text('Lihat Experience'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
        find.text('Kamu telah menekan tombol Lihat Experience!'), findsOneWidget);

    // A second tap replaces the current SnackBar instead of stacking them.
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
  });

  testWidgets('Tambah Proyek opens the project form and Save validates it',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    await tester.ensureVisible(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);

    // The menu SnackBar follows us to the new route; hide it so it does not
    // cover the Save button.
    ScaffoldMessenger.of(tester.element(find.byType(ProjectFormPage)))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    // Empty required fields block the dialog and show error messages.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'MyPortfolio');
    await tester.enterText(fields.at(1), 'Aplikasi portofolio pribadi');
    await tester.enterText(fields.at(2), 'Flutter, Django');
    await tester.enterText(fields.at(3), 'https://example.com');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: MyPortfolio'), findsOneWidget);
    expect(find.text('Deskripsi: Aplikasi portofolio pribadi'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
    expect(find.text('Tautan: https://example.com'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('drawer navigates between home and the project form',
      (WidgetTester tester) async {
    // The test font draws every glyph as a square as wide as its font size, so
    // the DrawerHeader text wraps far more than with a real font and overflows.
    // Ignore only that overflow; every other error still fails the test.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Explore personal projects and experiences!'),
        findsOneWidget);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });
}
