// Базовый smoke-тест витрины дизайн-системы (Фаза 1).

import 'package:flutter_test/flutter_test.dart';

import 'package:uzlang_mobile/main.dart';

void main() {
  testWidgets('Витрина DS строится и показывает карточку слова',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UzLangApp());

    // Заголовок витрины и карточка слова (латиница + перевод) видны сверху.
    expect(find.text('UzLang · Design System'), findsOneWidget);
    expect(find.text('Salom'), findsOneWidget);
    expect(find.text('Здравствуйте'), findsOneWidget);
  });
}
