/// Воспроизведение озвучки слов и фраз (абстракция).
///
/// В V1 — заглушка [NoopAudioService]. Позже подключается `just_audio` с
/// заранее сгенерированными TTS-файлами; интерфейс остаётся прежним.
abstract interface class AudioService {
  /// Проигрывает озвучку по латинскому тексту [latinText].
  Future<void> playWord(String latinText);

  /// Останавливает воспроизведение.
  Future<void> stop();
}

/// Заглушка аудио на этапе V1 (ничего не воспроизводит).
class NoopAudioService implements AudioService {
  /// Создаёт заглушку.
  const NoopAudioService();

  @override
  Future<void> playWord(String latinText) async {}

  @override
  Future<void> stop() async {}
}
