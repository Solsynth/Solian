import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_subscribe.dart';

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

  group('chat read receipt timestamp parsing', () {
    test('parses ISO and normalizes to UTC', () {
      expect(
        parseChatReadReceiptTimestamp('2026-08-25T10:00:00+02:00'),
        DateTime.utc(2026, 8, 25, 8),
      );
    });

    test('parses epoch milliseconds and rejects invalid values', () {
      expect(
        parseChatReadReceiptTimestamp(
          DateTime.utc(2026, 8, 25).millisecondsSinceEpoch,
        ),
        DateTime.utc(2026, 8, 25),
      );
      expect(parseChatReadReceiptTimestamp('not-a-timestamp'), isNull);
    });
  });
}
