import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/widgets/message_bubble_shape.dart';

void main() {
  group('MessageBubbleShape', () {
    const size = Size(200, 44);

    test('connecting corners are square, free corners stay rounded', () {
      final connected = MessageBubbleShape(
        connectsAbove: true,
        connectsBelow: true,
      ).path(size);

      // Squared avatar-side corners: 1px in from the corner is inside.
      expect(connected.contains(const Offset(1, 1)), isTrue);
      expect(connected.contains(Offset(1, size.height - 1)), isTrue);
      // Right corners are never squared.
      expect(connected.contains(Offset(size.width - 1, 1)), isFalse);
      expect(
        connected.contains(Offset(size.width - 1, size.height - 1)),
        isFalse,
      );

      final free = MessageBubbleShape().path(size);
      // 16px rounded corners: 1px in from any corner is outside.
      expect(free.contains(const Offset(1, 1)), isFalse);
      expect(free.contains(Offset(size.width - 1, 1)), isFalse);
      expect(free.contains(Offset(1, size.height - 1)), isFalse);
      expect(
        free.contains(Offset(size.width - 1, size.height - 1)),
        isFalse,
      );
    });
  });

  testWidgets('golden: single bubble and connected group', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Widget avatar() => Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFB9BEC9),
          ),
        );

    Widget bubble(MessageBubbleShape shape) => Container(
          width: 200,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE4E8F0),
            borderRadius: shape.borderRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Message text',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ),
        );

    // Mirrors the app layout: avatar in the 32px gutter, bubble 40px in,
    // group members 2px apart so the squared corners connect.
    Widget messageRow({
      required MessageBubbleShape shape,
      required bool showAvatar,
      double bottomGap = 2,
    }) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomGap),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              avatar(),
              const SizedBox(width: 8),
            ] else
              const SizedBox(width: 40),
            bubble(shape),
          ],
        ),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFF6F7F9),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              key: const Key('bubble-demo'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Single message: all corners rounded.
                messageRow(
                  shape: const MessageBubbleShape(),
                  showAvatar: true,
                  bottomGap: 8,
                ),
                // Group of three: squared bottom-left on the first, squared
                // both sides in the middle, squared top-left on the last.
                messageRow(
                  shape: const MessageBubbleShape(connectsBelow: true),
                  showAvatar: true,
                ),
                messageRow(
                  shape: const MessageBubbleShape(
                    connectsAbove: true,
                    connectsBelow: true,
                  ),
                  showAvatar: false,
                ),
                messageRow(
                  shape: const MessageBubbleShape(connectsAbove: true),
                  showAvatar: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('bubble-demo')),
      matchesGoldenFile('goldens/message_bubble_group.png'),
    );
  });

  testWidgets('golden: attachment bubbles follow the connected shape', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 220));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Production structure: the attachment keeps the bubble's connection
    // radii, and the bubble body clips to the same shape.
    Widget attachmentBubble(MessageBubbleShape shape) => Container(
          width: 200,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFE4E8F0),
            borderRadius: shape.borderRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: shape.borderRadius,
            child: const ColoredBox(color: Color(0xFFC7D0E0)),
          ),
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFFF6F7F9),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              key: const Key('attachment-demo'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                attachmentBubble(
                  const MessageBubbleShape(connectsBelow: true),
                ),
                const SizedBox(height: 2),
                attachmentBubble(
                  const MessageBubbleShape(
                    connectsAbove: true,
                    connectsBelow: true,
                  ),
                ),
                const SizedBox(height: 2),
                attachmentBubble(
                  const MessageBubbleShape(connectsAbove: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('attachment-demo')),
      matchesGoldenFile('goldens/message_bubble_attachment_group.png'),
    );
  });
}
