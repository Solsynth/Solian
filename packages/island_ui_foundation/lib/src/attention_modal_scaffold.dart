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

    if (!isWideScreen(context) && !widget.forceCard) {
      final isDesktop =
          !kIsWeb &&
          (Platform.isMacOS || Platform.isLinux || Platform.isWindows);
      final content = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height *
              (widget.maxHeightFactor ?? 0.85),
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: cardContent,
        ),
      );
      final paddedContent = isDesktop
          ? Padding(padding: const EdgeInsets.only(top: 32), child: content)
          : content;
      return SafeArea(child: paddedContent);
    }

    final wide = isWideScreen(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: math.min(MediaQuery.of(context).size.height * 0.04, 32),
      ),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: wide ? 0.8 : 0.92,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth ?? 800,
              maxHeight:
                  MediaQuery.of(context).size.height *
                  (widget.maxHeightFactor ?? 0.85),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                child: cardContent,
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
