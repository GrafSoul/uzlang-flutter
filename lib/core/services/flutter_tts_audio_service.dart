import 'dart:async';

import 'package:flutter/foundation.dart';
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

      // Ищем узбекский: сперва точные локали, затем любой `uz*` из списка
      // языков движка. Без находки остаёмся на голосе по умолчанию
      // (латиница прозвучит неточно) — и честно пишем это в лог.
      String? uzLang;
      for (final candidate in const ['uz-UZ', 'uz']) {
        final ok = await _tts
            .isLanguageAvailable(candidate)
            .timeout(_nativeTimeout, onTimeout: () => false);
        if (ok == true || ok == 1) {
          uzLang = candidate;
          break;
        }
      }
      if (uzLang == null) {
        final langs = await _tts.getLanguages
            .timeout(_nativeTimeout, onTimeout: () => <dynamic>[]);
        final list = (langs as List?)?.map((e) => '$e').toList() ?? const [];
        uzLang = list.cast<String?>().firstWhere(
              (l) => l!.toLowerCase().startsWith('uz'),
              orElse: () => null,
            );
        debugPrint('TTS: языки движка (${list.length}): '
            '${list.where((l) => l.toLowerCase().startsWith("u")).join(", ")}');
      }
      if (uzLang != null) {
        await _tts.setLanguage(uzLang).timeout(_nativeTimeout);
        debugPrint('TTS: узбекский найден и установлен ($uzLang)');
      } else {
        debugPrint('TTS: узбекского голоса НЕТ — используется голос '
            'движка по умолчанию');
      }
      return true;
    } catch (e) {
      // Движок TTS отсутствует или завис — озвучка молча выключена.
      debugPrint('TTS: инициализация не удалась: $e');
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
