import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/widgets/message_bubble_shape.dart';

void main() {
  group('MessageBubbleShape', () {
    const size = Size(200, 44);

    test('tail protrudes from the left edge only when requested', () {
      final withTail = MessageBubbleShape(showTail: true).path(size);
      expect(withTail.getBounds().left, closeTo(-5, 0.001));
      // Compact arrow: apex near the avatar's vertical center, base merged
      // into the bubble (nothing floating above or below the triangle).
      expect(withTail.contains(const Offset(-2, 17)), isTrue);
      expect(withTail.contains(const Offset(-3, 5)), isFalse);
      expect(withTail.contains(const Offset(-3, 33)), isFalse);

      final withoutTail = MessageBubbleShape().path(size);
      expect(withoutTail.getBounds().left, 0);
    });

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

    test('tail survives the connected state (first bubble of a group)', () {
      final firstInGroup = MessageBubbleShape(
        showTail: true,
        connectsBelow: true,
      ).path(size);
      expect(firstInGroup.getBounds().left, closeTo(-5, 0.001));
    });
  });

  testWidgets('golden: single bubble and connected group with tail', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 280));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Widget avatar() => Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFB9BEC9),
          ),
        );

    Widget bubble(MessageBubbleShape shape) => ClipPath(
          clipper: MessageBubbleClipper(shape),
          child: CustomPaint(
            painter: MessageBubblePainter(
              color: const Color(0xFFE4E8F0),
              shape: shape,
            ),
            child: const SizedBox(
              width: 200,
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Message text',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        );

    // Mirrors the app layout: avatar occupies the 32px gutter (0-32), the
    // bubble starts 40px in (32 + 8 gap), so the tail apex at -8 lands right
    // at the avatar's edge. Group members sit 2px apart so the squared
    // corners connect.
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
                // Single message: tail, all corners rounded.
                messageRow(
                  shape: const MessageBubbleShape(showTail: true),
                  showAvatar: true,
                  bottomGap: 8,
                ),
                // Group of three: tail + squared bottom-left on the first,
                // squared both sides in the middle, squared top-left on the
                // last.
                messageRow(
                  shape: const MessageBubbleShape(
                    showTail: true,
                    connectsBelow: true,
                  ),
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
    await tester.binding.setSurfaceSize(const Size(320, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Production structure: the attachment (ClipRRect with fixed 16px
    // corners) sits inside the bubble shape clip.
    Widget attachmentBubble(MessageBubbleShape shape) => ClipPath(
          clipper: MessageBubbleClipper(shape),
          child: CustomPaint(
            painter: MessageBubblePainter(
              color: const Color(0xFFE4E8F0),
              shape: shape,
            ),
            child: ClipRRect(
              borderRadius: shape.borderRadius,
              child: const SizedBox(
                width: 200,
                height: 60,
                child: ColoredBox(color: Color(0xFFC7D0E0)),
              ),
            ),
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
                  const MessageBubbleShape(
                    showTail: true,
                    connectsBelow: true,
                  ),
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
