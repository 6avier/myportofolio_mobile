import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

import 'test_helpers.dart';

import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

void main() {
  testWidgets('home page shows the owner info cards and menu buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text('2506656886'), findsOneWidget);
    expect(find.text('Kemas Xavier Alvaresyah'), findsOneWidget);
    expect(find.text('PBP C'), findsOneWidget);

    expect(find.byType(ItemCard), findsNWidgets(5));
    expect(find.text('Lihat Experience'), findsOneWidget);
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Experience'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('every menu card has its own background color from its model', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));

    final cards = tester.widgetList<ItemCard>(find.byType(ItemCard)).toList();
    final colors = cards.map((card) {
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byWidget(card),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, card.item.color);
      return material.color;
    }).toSet();

    expect(colors.length, cards.length);
  });

  testWidgets('tapping a menu card shows a SnackBar with its name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: fakeApiClient()));
    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.text('Lihat Experience'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Kamu telah menekan tombol Lihat Experience!'),
      findsOneWidget,
    );

    // A second tap replaces the current SnackBar instead of stacking them.
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Kamu telah menekan tombol Logout!'), findsOneWidget);
  });
}
