import 'package:flutter/widgets.dart';

/// Outline of a messenger-style chat bubble.
///
/// Bubbles live on the left side of the message row, next to the avatar
/// gutter. Within a sender group, the avatar-side corners are squared where
/// consecutive bubbles meet so the group reads as one connected unit; free
/// corners keep [radius].
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

  const MessageBubbleShape({
    this.radius = 16,
    this.connectsAbove = false,
    this.connectsBelow = false,
  });

  /// Corner radii for the current connection state.
  BorderRadius get borderRadius => BorderRadius.only(
        topLeft: Radius.circular(connectsAbove ? 0 : radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(connectsBelow ? 0 : radius),
        bottomRight: Radius.circular(radius),
      );

  /// The bubble outline: the body rectangle with the connection-aware
  /// corners.
  Path path(Size size) => Path()..addRRect(_rrect(size));

  RRect _rrect(Size size) => RRect.fromRectAndCorners(
        Offset.zero & size,
        topLeft: Radius.circular(connectsAbove ? 0 : radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(connectsBelow ? 0 : radius),
        bottomRight: Radius.circular(radius),
      );
}
