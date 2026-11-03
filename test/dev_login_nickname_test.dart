import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/presentation/user/create_dev_user_page.dart';

void main() {
  testWidgets('development login asks for a nickname and validates it', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: CreateDevUserPage()),
    ));
    expect(find.text('Choose a nickname'), findsWidgets);
    expect(find.text('Defuser'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'ab');
    await tester.tap(find.text('Continue').last);
    await tester.pump();
    expect(find.text('Nickname must be between 3 and 15 characters.'), findsWidgets);
  });
}
