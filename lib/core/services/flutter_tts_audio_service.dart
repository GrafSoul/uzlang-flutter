import 'package:flutter_tts/flutter_tts.dart';

import 'audio_service.dart';
import 'settings_service.dart';

/// Бесплатная озвучка через системный TTS устройства (как Web Speech в
/// React-версии: `speechSynthesis` + узбекский голос).
///
/// Файлы не генерируются и не хранятся — синтез идёт на лету средствами ОС,
/// поэтому стоимость нулевая. Уважает настройку [SettingsService.soundEnabled].
class FlutterTtsAudioService implements AudioService {
  /// Создаёт сервис поверх [_settings] (флаг звука) и [FlutterTts].
  FlutterTtsAudioService(this._settings) {
    _configure();
  }

  final SettingsService _settings;
  final FlutterTts _tts = FlutterTts();

  /// Язык озвучки — узбекский (как `utterance.lang = 'uz-UZ'` в React).
  static const String _lang = 'uz-UZ';

  /// Темп речи. В Web Speech использовалось `rate = 0.92` по шкале 0..1+,
  /// где 1.0 — норма. flutter_tts ожидает 0..1, где 0.5 — норма, поэтому
  /// 0.92 нормального темпа ≈ 0.46.
  static const double _rate = 0.46;

  Future<void> _configure() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(_rate);
    final available = await _isLanguageAvailable();
    if (available) {
      await _tts.setLanguage(_lang);
    }
  }

  Future<bool> _isLanguageAvailable() async {
    try {
      final result = await _tts.isLanguageAvailable(_lang);
      return result == true || result == 1;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> playWord(String latinText) async {
    if (!_settings.soundEnabled) return;
    final text = latinText.trim();
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();
}
