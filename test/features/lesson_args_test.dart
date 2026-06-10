import 'package:flutter_test/flutter_test.dart';
import 'package:uzlang_mobile/domain/entities/topic.dart';
import 'package:uzlang_mobile/features/learn/lesson_args.dart';

void main() {
  const topic = Topic(
    id: 1,
    key: 'basics',
    title: 'Основы',
    description: '',
    sortOrder: 0,
  );

  group('LessonArgs', () {
    test('по умолчанию — поток слов', () {
      const args = LessonArgs(topic: topic, blockIndex: 0);

      expect(args.isPhrase, isFalse);
      expect(args.blockNumber, 1);
    });

    test('next() сохраняет поток фраз и двигает индекс', () {
      const args = LessonArgs(topic: topic, blockIndex: 1, isPhrase: true);

      final next = args.next();

      expect(next.blockIndex, 2);
      expect(next.blockNumber, 3);
      expect(next.isPhrase, isTrue);
      expect(next.topic.id, topic.id);
    });
  });
}
