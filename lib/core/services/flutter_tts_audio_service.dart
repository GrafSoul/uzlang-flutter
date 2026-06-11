import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import 'audio_service.dart';
import 'settings_service.dart';

/// Бесплатная озвучка через системный TTS устройства (как Web Speech в
/// React-версии: `speechSynthesis` + узбекский голос).
///
/// Файлы не генерируются и не хранятся — синтез идёт на лету средствами ОС,
/// поэтому стоимость нулевая. Уважает настройку [SettingsService.soundEnabled].
///
/// Закалено под реальные устройства: инициализация ленивая (не на старте
/// приложения), каждый нативный вызов под таймаутом — зависший движок TTS
/// (бывает на Xiaomi/HyperOS) не может заморозить ни урок, ни запуск.
class FlutterTtsAudioService implements AudioService {
  /// Создаёт сервис поверх [_settings] (флаг звука) и [FlutterTts].
  FlutterTtsAudioService(this._settings);

  final SettingsService _settings;
  final FlutterTts _tts = FlutterTts();

  /// Язык озвучки — узбекский (как `utterance.lang = 'uz-UZ'` в React).
  static const String _lang = 'uz-UZ';

  /// Темп речи. В Web Speech использовалось `rate = 0.92` по шкале, где 1.0 —
  /// норма. flutter_tts ожидает 0..1, где 0.5 — норма, поэтому ≈ 0.46.
  static const double _rate = 0.46;

  /// Потолок ожидания любого нативного вызова TTS.
  static const Duration _nativeTimeout = Duration(seconds: 4);

  /// Идущая/завершённая инициализация, либо `null`, если ещё не начиналась.
  Future<bool>? _init;

  /// Ленивая инициализация движка. `false` — движок недоступен/завис,
  /// озвучка отключается до конца сеанса (приложение работает дальше).
  Future<bool> _ensureReady() {
    return _init ??= _configure();
  }

  Future<bool> _configure() async {
    try {
      await _tts.setSpeechRate(_rate).timeout(_nativeTimeout);
      final available = await _tts
          .isLanguageAvailable(_lang)
          .timeout(_nativeTimeout, onTimeout: () => false);
      if (available == true || available == 1) {
        await _tts.setLanguage(_lang).timeout(_nativeTimeout);
      }
      return true;
    } catch (_) {
      // Движок TTS отсутствует или завис — озвучка молча выключена.
      return false;
    }
  }

  @override
  Future<void> playWord(String latinText) async {
    if (!_settings.soundEnabled) return;
    final text = latinText.trim();
    if (text.isEmpty) return;
    if (!await _ensureReady()) return;
    try {
      await _tts.stop().timeout(_nativeTimeout);
      // Без awaitSpeakCompletion: speak ставит фразу в очередь и сразу
      // возвращается (как speechSynthesis.speak в вебе).
      await _tts.speak(text).timeout(_nativeTimeout);
    } catch (_) {
      // Сбой синтеза не должен ронять урок — озвучка опциональна.
    }
  }

  @override
  Future<void> stop() async {
    if (_init == null) return; // движок не трогали — нечего останавливать
    if (!await _ensureReady()) return;
    try {
      await _tts.stop().timeout(_nativeTimeout);
    } catch (_) {
      // Игнорируем: остановка не критична.
    }
  }
}
