import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:island_ui_foundation/src/responsive.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttentionModalScaffold extends StatefulWidget {
  final Widget child;
  final Widget? title;
  final String? titleText;
  final Widget? leading;
  final List<Widget> actions;
  final VoidCallback onDismiss;
  final bool showHeader;
  final double? maxWidth;
  final double? maxHeightFactor;
  final bool forceCard;

  const AttentionModalScaffold({
    super.key,
    required this.child,
    required this.onDismiss,
    this.title,
    this.titleText,
    this.leading,
    this.actions = const [],
    this.showHeader = true,
    this.maxWidth = 640,
    this.maxHeightFactor = 0.85,
    this.forceCard = false,
  });

  @override
  State<AttentionModalScaffold> createState() => _AttentionModalScaffoldState();
}

class _AttentionModalScaffoldState extends State<AttentionModalScaffold> {
  bool _isScrolled = false;

  Widget _buildHeader(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isScrolled
            ? Theme.of(context).colorScheme.surfaceContainerHigh
            : Colors.transparent,
        borderRadius: isWideScreen(context)
            ? const BorderRadius.vertical(top: Radius.circular(28))
            : BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 8),
            ],
            if (widget.title != null || widget.titleText != null)
              Expanded(
                child:
                    widget.title ??
                    Text(
                      widget.titleText!,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              )
            else
              const Spacer(),
            ...widget.actions,
            IconButton(
              icon: Icon(
                Symbols.close,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: widget.onDismiss,
              style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final cardContent = Column(
      children: [
        if (widget.showHeader) _buildHeader(context),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              final isScrolled = notification.metrics.pixels > 0;
              if (isScrolled != _isScrolled) {
                setState(() {
                  _isScrolled = isScrolled;
                });
              }
              return false;
            },
            child: widget.child,
          ),
        ),
      ],
    );

    final wide = isWideScreen(context);
    final showAsCard = wide || widget.forceCard;

    // CRITICAL: The widget tree structure below MUST be identical regardless
    // of screen width. Only the *parameters* of the widgets change.
    //
    // If the tree structure changed (e.g. different parent widget types),
    // Flutter's reconciliation would fail to match old → new, disposing the
    // entire subtree and recreating it from scratch — which destroys state
    // in child widgets (such as the ComposeState held by hooks in
    // HookConsumerWidget). By keeping every widget type and position stable,
    // only constraints / decoration / padding are mutated, so Flutter
    // preserves the Element tree and child State objects survive layout
    // transitions.

    // Determine parameters based on layout mode
    double widthFactor;
    double effectiveMaxWidth;
    EdgeInsets verticalPadding;

    if (showAsCard) {
      // Wide / forced-card layout
      final largeWide = wide && !widget.forceCard;
      widthFactor = largeWide ? 0.8 : 0.92;
      effectiveMaxWidth = widget.maxWidth ?? 800;
      verticalPadding = EdgeInsets.symmetric(
        vertical: math.min(MediaQuery.of(context).size.height * 0.04, 32),
      );
    } else {
      // Narrow / mobile layout
      final isDesktop =
          !kIsWeb &&
          (Platform.isMacOS || Platform.isLinux || Platform.isWindows);
      widthFactor = 1.0;
      effectiveMaxWidth = double.infinity;
      verticalPadding = EdgeInsets.only(
        top: isDesktop ? 32 : 0,
      );
    }

    return SafeArea(
      child: Padding(
        padding: verticalPadding,
        child: Center(
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: effectiveMaxWidth,
                maxHeight:
                    MediaQuery.of(context).size.height *
                    (widget.maxHeightFactor ?? 0.85),
              ),
              child: Container(
                decoration: showAsCard
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                    : null,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  shape: showAsCard
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        )
                      : null,
                  clipBehavior: showAsCard ? Clip.antiAlias : Clip.none,
                  child: cardContent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }
}
