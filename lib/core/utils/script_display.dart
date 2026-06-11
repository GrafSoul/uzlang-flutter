import '../../domain/entities/enums.dart';

/// Пара строк карточки: главное написание и подпись под ним.
typedef ScriptPair = ({String main, String sub});

/// Отображение слова/фразы по выбранной письменности.
///
/// Контент хранит `uz` (латиница) и `reading` (кириллическое чтение).
/// Варианты соответствуют примерам дизайн-системы:
/// кириллица — «Салом · [ салом ]», латиница — «Salom · [ салом ]»,
/// обе — «Salom · Салом».
abstract final class ScriptDisplay {
  ScriptDisplay._();

  /// Возвращает главную строку и подпись для режима [mode].
  static ScriptPair of(ScriptMode mode, String uz, String reading) {
    switch (mode) {
      case ScriptMode.cyrillic:
        return (main: _capitalize(reading), sub: '[ $reading ]');
      case ScriptMode.latin:
        return (main: uz, sub: '[ $reading ]');
      case ScriptMode.both:
        return (main: uz, sub: _capitalize(reading));
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
