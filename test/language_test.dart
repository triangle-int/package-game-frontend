import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/l10n/app_text.dart';
import 'package:package_flutter/l10n/language.dart';
import 'package:package_flutter/l10n/translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('game text follows the app language', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('ru'),
      supportedLocales: [Locale('en'), Locale('ru')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: AppText('Factory')),
    ));
    expect(find.text('Фабрика'), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('en'),
      supportedLocales: [Locale('en'), Locale('ru')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(body: AppText('Factory')),
    ));
    expect(find.text('Factory'), findsWidgets);
  });

  test('language selection persists and is restored', () async {
    SharedPreferences.setMockInitialValues({});
    final first = ProviderContainer();
    await first.read(languageProvider.notifier).setLanguage('ru');
    expect(first.read(languageProvider), const Locale('ru'));
    first.dispose();
    final second = ProviderContainer();
    second.read(languageProvider);
    await Future<void>.delayed(Duration.zero);
    expect(second.read(languageProvider), const Locale('ru'));
    second.dispose();
  });

  test('dynamic text preserves values', () {
    expect(translateRussian('Warehouse #3'), 'Склад №3');
    expect(translateRussian('Level 5'), 'Уровень 5');
  });
}
