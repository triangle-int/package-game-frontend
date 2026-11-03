import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/l10n/app_text.dart';
import 'package:package_flutter/presentation/map/building_menu_frame.dart';

void main() {
  testWidgets('building menu opens compact and can be dragged up',
      (tester) async {
    final user = User(
      id: 1,
      firebaseId: 'dev',
      nickname: 'Builder',
      avatar: '🧑‍🔧',
      money: BigInt.zero,
      gems: BigInt.zero,
      level: 1,
      experience: BigInt.zero,
    );
    const market = Building.market(
      id: 4,
      geohex: 'XM488541',
      geohash: 'ucfv',
      level: 1,
      commission: 0.1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showBuildingMenuSheet(
                  context: context,
                  building: market,
                  currentUser: user,
                  buildingEmoji: '🏬',
                  details: const SizedBox(
                    height: 500,
                    child: Center(child: Text('Market details')),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    Finder appText(String text) => find.byWidgetPredicate(
          (widget) => widget is AppText && widget.data == text,
        );
    expect(appText('Auto market'), findsOneWidget);
    expect(appText('Level 1'), findsOneWidget);
    expect(appText('Public market'), findsOneWidget);

    final sheet = find.byKey(const Key('building-menu-sheet'));
    final compactTop = tester.getTopLeft(sheet).dy;

    await tester.drag(
      find.byKey(const Key('building-menu-drag-handle')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(sheet).dy, lessThan(compactTop - 200));
  });
}
