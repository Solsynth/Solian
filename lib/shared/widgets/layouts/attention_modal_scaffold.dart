import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:island/core/services/responsive.dart';
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

  const AttentionModalScaffold({
    super.key,
    required this.child,
    required this.onDismiss,
    this.title,
    this.titleText,
    this.leading,
    this.actions = const [],
    this.showHeader = true,
    this.maxWidth = 800,
    this.maxHeightFactor = 0.85,
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
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
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
                child: widget.title ??
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
              style: IconButton.styleFrom(
                minimumSize: const Size(36, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final cardContent = Column(
      mainAxisSize: MainAxisSize.min,
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

    if (!isWideScreen(context)) {
      return SafeArea(
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: cardContent,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical:
            math.min(MediaQuery.of(context).size.height * 0.04, 32),
      ),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth ?? 800,
              maxHeight: MediaQuery.of(context).size.height *
                  (widget.maxHeightFactor ?? 0.85),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
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
