import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/core/utils/script_display.dart';
import 'package:uzlang_mobile/domain/entities/enums.dart';

void main() {
  group('ScriptDisplay', () {
    test('кириллица: главная — чтение с заглавной, подпись — [ чтение ]', () {
      final p = ScriptDisplay.of(ScriptMode.cyrillic, 'salom', 'салом');
      expect(p.main, 'Салом');
      expect(p.sub, '[ салом ]');
    });

    test('латиница: главная — uz, подпись — [ чтение ]', () {
      final p = ScriptDisplay.of(ScriptMode.latin, 'salom', 'салом');
      expect(p.main, 'salom');
      expect(p.sub, '[ салом ]');
    });

    test('обе: главная — uz, подпись — кириллица с заглавной', () {
      final p = ScriptDisplay.of(ScriptMode.both, 'salom', 'салом');
      expect(p.main, 'salom');
      expect(p.sub, 'Салом');
    });

    test('пустое чтение не падает', () {
      final p = ScriptDisplay.of(ScriptMode.cyrillic, 'salom', '');
      expect(p.main, '');
    });
  });
}
