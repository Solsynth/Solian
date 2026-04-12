import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/main.dart';
import 'package:material_symbols_icons/symbols.dart';

class OverlayState {
  final Offset position;
  final Size size;
  final bool isExpanded;
  final bool isCollapsed;

  const OverlayState({
    this.position = const Offset(16, 80),
    this.size = const Size(400, 500),
    this.isExpanded = true,
    this.isCollapsed = false,
  });

  OverlayState copyWith({
    Offset? position,
    Size? size,
    bool? isExpanded,
    bool? isCollapsed,
  }) {
    return OverlayState(
      position: position ?? this.position,
      size: size ?? this.size,
      isExpanded: isExpanded ?? this.isExpanded,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }
}

class OverlayNotifier extends Notifier<OverlayState> {
  @override
  OverlayState build() => const OverlayState();

  void updatePosition(Offset delta) {
    state = state.copyWith(
      position: Offset(
        state.position.dx + delta.dx,
        state.position.dy + delta.dy,
      ),
    );
  }

  void setPosition(Offset position) {
    state = state.copyWith(position: position);
  }

  void updateSize(Size delta, {Size? minSize, Size? maxSize}) {
    final minW = minSize?.width ?? 280.0;
    final minH = minSize?.height ?? 300.0;
    final maxW = maxSize?.width ?? 600.0;
    final maxH = maxSize?.height ?? 800.0;

    final newWidth = (state.size.width + delta.width).clamp(minW, maxW);
    final newHeight = (state.size.height + delta.height).clamp(minH, maxH);
    state = state.copyWith(size: Size(newWidth, newHeight));
  }

  void setExpanded(bool value) {
    state = state.copyWith(isExpanded: value);
  }

  void setCollapsed(bool value) {
    state = state.copyWith(isCollapsed: value);
  }

  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void toggleCollapsed() {
    state = state.copyWith(isCollapsed: !state.isCollapsed);
  }
}

final overlayStateProvider = NotifierProvider<OverlayNotifier, OverlayState>(
  OverlayNotifier.new,
);

class OverlayScaffold extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context) headerBuilder;
  final Widget Function(BuildContext context) contentBuilder;
  final Widget? leading;
  final String? title;
  final List<Widget> headerActions;
  final Size initialPosition;
  final Size initialSize;
  final bool initialCollapsed;
  final bool resizable;
  final bool minimizable;
  final double collapsedWidth;
  final double collapsedHeight;
  final Size minSize;
  final Size maxSize;

  const OverlayScaffold({
    super.key,
    required this.headerBuilder,
    required this.contentBuilder,
    this.leading,
    this.title,
    this.headerActions = const [],
    this.initialPosition = const Size(16, 80),
    this.initialSize = const Size(400, 500),
    this.initialCollapsed = false,
    this.resizable = true,
    this.minimizable = false,
    this.collapsedWidth = 140,
    this.collapsedHeight = 140,
    this.minSize = const Size(280, 300),
    this.maxSize = const Size(600, 800),
  });

  @override
  ConsumerState<OverlayScaffold> createState() => _OverlayScaffoldState();
}

class _OverlayScaffoldState extends ConsumerState<OverlayScaffold>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  late Size _size;
  late bool _isCollapsed;
  late AnimationController _animController;
  late Animation<double> _expandAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _position = Offset(
      widget.initialPosition.width,
      widget.initialPosition.height,
    );
    _size = widget.initialSize;
    _isCollapsed = widget.initialCollapsed;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
      value: _isCollapsed ? 0.0 : 1.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleCollapsed() {
    setState(() => _isCollapsed = !_isCollapsed);
    if (_isCollapsed) {
      _animController.reverse();
    } else {
      _animController.forward();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final overlayWidth = _isCollapsed ? widget.collapsedWidth : _size.width;
    final overlayHeight = _isCollapsed ? widget.collapsedHeight : _size.height;

    setState(() {
      _position = Offset(
        (_position.dx + details.delta.dx).clamp(
          0,
          screenSize.width - overlayWidth,
        ),
        (_position.dy + details.delta.dy).clamp(
          0,
          screenSize.height - overlayHeight,
        ),
      );
    });
  }

  void _onResizeUpdate(DragUpdateDetails details) {
    setState(() {
      final newWidth = (_size.width + details.delta.dx).clamp(
        widget.minSize.width,
        widget.maxSize.width,
      );
      final newHeight = (_size.height + details.delta.dy).clamp(
        widget.minSize.height,
        widget.maxSize.height,
      );
      _size = Size(newWidth, newHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentWidth =
        widget.collapsedWidth +
        (_size.width - widget.collapsedWidth) * _expandAnim.value;
    final currentHeight =
        widget.collapsedHeight +
        (_size.height - widget.collapsedHeight) * _expandAnim.value;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: FadeTransition(
        opacity: _fadeAnim.value == 0 ? AlwaysStoppedAnimation(1.0) : _fadeAnim,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            onTap: widget.minimizable && _isCollapsed ? _toggleCollapsed : null,
            child: SizedBox(
              width: currentWidth,
              height: currentHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildPanelContainer(context),
                  ),
                  if (widget.resizable && !_isCollapsed) ...[
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: _buildResizeHandle(theme),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelContainer(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _isCollapsed
            ? _buildCollapsedContent(context)
            : _buildExpandedContent(context),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    return Column(
      children: [
        widget.headerBuilder(context),
        Container(height: 1, color: Theme.of(context).dividerColor),
        Expanded(child: widget.contentBuilder(context)),
      ],
    );
  }

  Widget _buildCollapsedContent(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      child: widget.minimizable
          ? _buildCollapsedWithActions(context, theme)
          : widget.contentBuilder(context),
    );
  }

  Widget _buildCollapsedWithActions(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: _toggleCollapsed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.leading != null)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.leading is Icon
                    ? (widget.leading as Icon).icon
                    : Icons.chat_bubble,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
          if (widget.title != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.title!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Icon(
            Icons.expand_more,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildResizeHandle(ThemeData theme) {
    return GestureDetector(
      onPanUpdate: _onResizeUpdate,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Icon(Icons.drag_handle, size: 14),
      ),
    );
  }
}

class OverlayHeader extends StatelessWidget {
  final Widget? leading;
  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;
  final bool showExpandButton;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onClose;
  final Color? accentColor;

  const OverlayHeader({
    super.key,
    this.leading,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.showExpandButton = false,
    this.isExpanded = true,
    this.onToggleExpand,
    this.onClose,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color, color.withOpacity(0.6)],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          if (titleWidget != null)
            titleWidget!
          else if (title != null)
            Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            )
          else
            const Spacer(),
          ...actions,
          if (showExpandButton) ...[
            OverlayHeaderButton(
              icon: isExpanded ? Symbols.minimize : Symbols.open_in_full,
              tooltip: isExpanded ? 'Minimize' : 'Expand',
              onTap: onToggleExpand,
            ),
            const SizedBox(width: 2),
          ],
          if (onClose != null) ...[
            OverlayHeaderButton(
              icon: Symbols.close,
              tooltip: 'Close',
              onTap: onClose,
            ),
          ],
        ],
      ),
    );
  }
}

class OverlayHeaderButton extends StatelessWidget {
  final dynamic icon;
  final String tooltip;
  final VoidCallback? onTap;

  const OverlayHeaderButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class OverlayActions {
  static Widget collapse({
    required VoidCallback onTap,
    bool isCollapsed = false,
  }) {
    return OverlayHeaderButton(
      icon: isCollapsed ? Symbols.open_in_full : Symbols.minimize,
      tooltip: isCollapsed ? 'Expand' : 'Minimize',
      onTap: onTap,
    );
  }

  static Widget close({required VoidCallback onTap, String tooltip = 'Close'}) {
    return OverlayHeaderButton(
      icon: Symbols.close,
      tooltip: tooltip,
      onTap: onTap,
    );
  }

  static Widget expand({required VoidCallback onTap, bool isExpanded = true}) {
    return OverlayHeaderButton(
      icon: isExpanded ? Symbols.minimize : Symbols.open_in_full,
      tooltip: isExpanded ? 'Minimize' : 'Expand',
      onTap: onTap,
    );
  }

  static Widget refresh({
    required VoidCallback onTap,
    String tooltip = 'Refresh',
  }) {
    return OverlayHeaderButton(
      icon: Symbols.refresh,
      tooltip: tooltip,
      onTap: onTap,
    );
  }
}

OverlayEntry createOverlayEntry({
  required Widget Function(BuildContext context) builder,
}) {
  return OverlayEntry(builder: builder);
}

void insertOverlay(OverlayEntry entry) {
  globalOverlay.currentState?.insert(entry);
}

void removeOverlay(OverlayEntry? entry) {
  entry?.remove();
}
