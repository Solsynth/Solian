import 'package:flutter/material.dart';
import 'package:island/plugins/widgets/plugin_ui_bridge.dart';
import 'package:island/plugins/widgets/plugin_pane_host.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:logging/logging.dart';

final _log = Logger('PluginPane');

class PluginPane extends StatefulWidget {
  final PluginPaneData data;
  final PluginPaneHost host;

  const PluginPane({
    super.key,
    required this.data,
    required this.host,
  });

  @override
  State<PluginPane> createState() => _PluginPaneState();
}

class _PluginPaneState extends State<PluginPane>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  late Size _size;
  late bool _minimized;
  late AnimationController _animController;
  late Animation<double> _heightFactor;
  final _minWidth = 260.0;
  final _minHeight = 160.0;
  final _titleBarHeight = 40.0;
  final _resizeHandleSize = 14.0;

  @override
  void initState() {
    super.initState();
    _position = widget.data.position;
    _size = widget.data.size;
    _minimized = widget.data.minimized;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
      value: _minimized ? 0.0 : 1.0,
    );
    _heightFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleMinimize() {
    setState(() => _minimized = !_minimized);
    widget.host.toggleMinimize(widget.data.id);
    if (_minimized) {
      _animController.reverse();
    } else {
      _animController.forward();
    }
  }

  void _onCallback(String callback, [String? value]) {
    final runtime = PluginManager().plugins[widget.data.pluginId]?.runtime;
    if (runtime == null) return;
    final result = runtime.callFunction(
      callback,
      value == null ? null : [value],
    );
    final descriptor = result is String
        ? PluginUiRenderer.parse(result)
        : result is Map && result['type'] is String
            ? PluginUiDescriptor(
                type: result['type'] as String,
                data: result.map(
                  (key, value) => MapEntry(key.toString(), value),
                ),
              )
            : null;
    if (descriptor != null) {
      widget.host.updateDescriptor(widget.data.id, descriptor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onTap: () => widget.host.bringToFront(widget.data.id),
        child: AnimatedBuilder(
          animation: _heightFactor,
          builder: (context, child) {
            final bodyHeight = _size.height - _titleBarHeight;
            final displayHeight =
                _titleBarHeight + bodyHeight * _heightFactor.value;
            return Container(
              width: _size.width,
              height: displayHeight + _resizeHandleSize + 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                surfaceTintColor: colorScheme.surfaceTint,
                elevation: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTitleBar(theme),
                      if (_heightFactor.value > 0.01)
                        FadeTransition(
                          opacity: _heightFactor,
                          child: SizedBox(
                            width: _size.width,
                            height: bodyHeight * _heightFactor.value,
                            child: _buildBody(context),
                          ),
                        ),
                      if (_heightFactor.value > 0.5)
                        _buildResizeHandle(theme),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final hasBody = widget.data.descriptor != null;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _position = Offset(
            _position.dx + details.delta.dx,
            _position.dy + details.delta.dy,
          );
        });
      },
      onPanEnd: (_) => widget.host.updatePosition(
        widget.data.id,
        _position,
      ),
      child: Container(
        height: _titleBarHeight,
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHighest.withOpacity(0.8),
              colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${widget.data.pluginName}${widget.data.title.isNotEmpty ? ' - ${widget.data.title}' : ''}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasBody)
              _PaneButton(
                icon: _minimized ? Symbols.open_in_full : Symbols.minimize,
                tooltip: _minimized ? 'Expand' : 'Minimize',
                onTap: _toggleMinimize,
              ),
            _PaneButton(
              icon: Symbols.close,
              tooltip: 'Close',
              onTap: () => widget.host.removePane(widget.data.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final descriptor = widget.data.descriptor;
    if (descriptor == null) {
      return Center(
        child: Text(
          'No content',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PluginUiRenderer(
        descriptor: descriptor,
        onCallback: _onCallback,
      ),
    );
  }

  Widget _buildResizeHandle(ThemeData theme) {
    return Align(
      alignment: Alignment.bottomRight,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _size = Size(
              (_size.width + details.delta.dx).clamp(_minWidth, 1200),
              (_size.height + details.delta.dy).clamp(_minHeight, 1200),
            );
          });
        },
        onPanEnd: (_) => widget.host.updateSize(widget.data.id, _size),
        child: Container(
          width: _resizeHandleSize + 4,
          height: _resizeHandleSize + 4,
          margin: const EdgeInsets.only(right: 2, bottom: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(8),
              topLeft: Radius.circular(4),
            ),
          ),
          child: Icon(
            Symbols.drag_indicator,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _PaneButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _PaneButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
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
