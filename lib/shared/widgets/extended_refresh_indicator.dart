import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';

class ExtendedRefreshIndicator extends HookConsumerWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  final Axis axis;
  final bool showHoverRefresh;
  final double hoverActivationExtent;
  final double leadingEdgeInset;
  final String? hoverRefreshLabel;

  const ExtendedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.axis = Axis.vertical,
    this.showHoverRefresh = true,
    this.hoverActivationExtent = 72,
    this.leadingEdgeInset = 0,
    this.hoverRefreshLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHoverActionVisible = useState(false);
    final scrollOffset = useState(0.0);
    final scrollChild =
        axis == Axis.vertical
            ? RefreshIndicator(onRefresh: onRefresh, child: child)
            : child;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (kIsWeb || event is! KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        final isRefreshKey = event.logicalKey == LogicalKeyboardKey.keyR;
        final isRefreshModifier = Platform.isMacOS
            ? HardwareKeyboard.instance.isMetaPressed
            : HardwareKeyboard.instance.isControlPressed;

        if (isRefreshKey && isRefreshModifier) {
          onRefresh();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: LayoutBuilder(
        builder: (context, _) {
          final verticalActionTop =
              (leadingEdgeInset + 12 - scrollOffset.value).clamp(
                12.0,
                leadingEdgeInset + 12,
              );
          final horizontalActionLeft = leadingEdgeInset + 12;

          bool isInHoverActivationZone(Offset localPosition) {
            if (axis == Axis.vertical) {
              final zoneTop = verticalActionTop - 12;
              return localPosition.dy >= zoneTop &&
                  localPosition.dy <= zoneTop + hoverActivationExtent;
            }

            final zoneLeft = horizontalActionLeft - 12;
            return localPosition.dx >= zoneLeft &&
                localPosition.dx <= zoneLeft + hoverActivationExtent;
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis != axis) return false;
              final nextOffset = notification.metrics.pixels.clamp(
                0.0,
                double.infinity,
              );
              if (scrollOffset.value != nextOffset) {
                scrollOffset.value = nextOffset;
              }
              return false;
            },
            child: MouseRegion(
              onHover:
                  (event) => isHoverActionVisible.value =
                      isInHoverActivationZone(event.localPosition),
              onExit: (_) => isHoverActionVisible.value = false,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: scrollChild),
                  if (showHoverRefresh)
                    if (axis == Axis.vertical)
                      Positioned(
                        top: verticalActionTop,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: HoverEdgeAction(
                            axis: Axis.vertical,
                            leading: true,
                            isVisible: isHoverActionVisible.value,
                            onTap: () => onRefresh(),
                            shape: const StadiumBorder(),
                            constraints: const BoxConstraints(minHeight: 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: _RefreshActionContent(
                              label: hoverRefreshLabel,
                            ),
                          ),
                        ),
                      )
                    else
                      Positioned(
                        left: horizontalActionLeft,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: HoverEdgeAction(
                            axis: Axis.horizontal,
                            leading: true,
                            isVisible: isHoverActionVisible.value,
                            onTap: () => onRefresh(),
                            shape: const StadiumBorder(),
                            constraints: const BoxConstraints(minHeight: 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: _RefreshActionContent(
                              label: hoverRefreshLabel,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RefreshActionContent extends StatelessWidget {
  const _RefreshActionContent({required this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.refresh, color: Colors.white, size: 16),
        if (label != null && label!.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(label!, style: textStyle),
        ],
      ],
    );
  }
}
