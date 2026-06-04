// Smoke-тест виджета дизайн-системы (без полного bootstrap приложения).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/core/theme/theme.dart';
import 'package:uzlang_mobile/features/shared/widgets/widgets.dart';

void main() {
  testWidgets('PrimaryButton строится и реагирует на нажатие',
      (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: PrimaryButton(
            label: 'Продолжить',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Продолжить'), findsOneWidget);

    await tester.tap(find.text('Продолжить'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
