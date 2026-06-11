import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/core/services/flutter_tts_audio_service.dart';

void main() {
  group('Транслитерация узбекской латиницы под турецкий голос', () {
    test('диграфы и спецбуквы', () {
      expect(FlutterTtsAudioService.toTurkish('yaxshi'), 'yahşi');
      expect(FlutterTtsAudioService.toTurkish('choy'), 'çoy');
      expect(FlutterTtsAudioService.toTurkish('juda'), 'cuda');
      expect(FlutterTtsAudioService.toTurkish('qalay'), 'kalay');
      expect(FlutterTtsAudioService.toTurkish("to'g'ri"), 'toğri');
    });

    test('заглавные и апострофы', () {
      expect(FlutterTtsAudioService.toTurkish('Shahar'), 'Şahar');
      expect(FlutterTtsAudioService.toTurkish("a'lo"), 'alo');
    });
  });
}
