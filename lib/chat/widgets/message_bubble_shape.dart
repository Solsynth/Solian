import 'package:flutter/widgets.dart';

/// Outline of a messenger-style chat bubble.
///
/// Bubbles live on the left side of the message row, next to the avatar
/// gutter. Within a sender group, the avatar-side corners are squared where
/// consecutive bubbles meet so the group reads as one connected unit, and a
/// small tail protrudes from the avatar-side edge of the first bubble,
/// pointing at the avatar.
///
/// The tail is intentionally compact and uses an interior base when it is
/// joined to the bubble path. This keeps the pointer visually attached even
/// on translucent bubble fills.
@immutable
class MessageBubbleShape {
  /// Radius of the free (non-connecting) corners.
  final double radius;

  /// Square the top-left corner: another bubble of the same sender group sits
  /// above this one.
  final bool connectsAbove;

  /// Square the bottom-left corner: another bubble of the same sender group
  /// sits below this one.
  final bool connectsBelow;

  /// Draw the compact tail on the avatar-side edge, pointing at the avatar.
  final bool showTail;

  const MessageBubbleShape({
    this.radius = 16,
    this.connectsAbove = false,
    this.connectsBelow = false,
    this.showTail = false,
  });

  /// Corner radii for the current connection state.
  BorderRadius get borderRadius => BorderRadius.only(
        topLeft: Radius.circular(connectsAbove ? 0 : radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(connectsBelow ? 0 : radius),
        bottomRight: Radius.circular(radius),
      );

  RRect _rrect(Size size) => RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: Radius.circular(connectsAbove ? 0 : radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(connectsBelow ? 0 : radius),
        bottomRight: Radius.circular(radius),
      );

  /// The full bubble outline, including the tail protrusion.
  ///
  /// The tail is joined as a union with an interior base. Its small,
  /// wide-angle point reads as a pointer rather than a long spike, while the
  /// interior overlap prevents a hairline separation from the bubble.
  Path path(Size size) {
    final outline = Path()..addRRect(_rrect(size));
    if (!showTail) return outline;

    const baseX = 2.5;
    final tail = Path()
      ..moveTo(baseX, radius - 4)
      ..lineTo(-5, radius + 1.5)
      ..lineTo(baseX, radius + 7)
      ..close();
    return Path.combine(PathOperation.union, outline, tail);
  }
}

/// Paints a [MessageBubbleShape] filled with [color].
class MessageBubblePainter extends CustomPainter {
  final Color color;
  final MessageBubbleShape shape;

  const MessageBubblePainter({required this.color, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(shape.path(size), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant MessageBubblePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.shape != shape;
}

/// Clips bubble content (attachments, embeds) to the bubble outline so it
/// never spills past the shape or into the tail.
class MessageBubbleClipper extends CustomClipper<Path> {
  final MessageBubbleShape shape;

  const MessageBubbleClipper(this.shape);

  @override
  Path getClip(Size size) => shape.path(size);

  @override
  bool shouldReclip(covariant MessageBubbleClipper oldClipper) =>
      oldClipper.shape != shape;
}
