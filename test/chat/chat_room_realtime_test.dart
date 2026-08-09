import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/pods/chat_room.dart';

void main() {
  group('chat realtime envelope classification', () {
    test('treats messages.new update payloads as mutations', () {
      expect(
        isChatMessageMutationEnvelope('messages.new', 'messages.update'),
        isTrue,
      );
    });

    test('treats sync payloads as mutations', () {
      for (final type in const [
        'messages.sync.file',
        'messages.sync.finalize',
        'messages.sync.links',
      ]) {
        expect(isChatMessageMutationEnvelope('messages.new', type), isTrue);
      }
    });

    test(
      'does not classify ordinary messages or typed envelopes as mutations',
      () {
        expect(isChatMessageMutationEnvelope('messages.new', 'text'), isFalse);
        expect(
          isChatMessageMutationEnvelope('messages.update', 'messages.update'),
          isFalse,
        );
      },
    );
  });
}
