import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class ExtendedRefreshIndicator extends StatefulWidget {
  final Widget child;
  final RefreshCallback onRefresh;

  const ExtendedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<ExtendedRefreshIndicator> createState() =>
      _ExtendedRefreshIndicatorState();
}

class _ExtendedRefreshIndicatorState extends State<ExtendedRefreshIndicator> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
            const RefreshIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyR):
            const RefreshIntent(),
        LogicalKeySet(LogicalKeyboardKey.f5): const RefreshIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          RefreshIntent: CallbackAction<RefreshIntent>(
            onInvoke: (RefreshIntent intent) => widget.onRefresh(),
          ),
        },
        child: Focus(
          focusNode: _focusNode,
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
