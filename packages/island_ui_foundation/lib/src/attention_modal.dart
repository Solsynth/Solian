import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:island_ui_foundation/src/foundation.dart';

class _AttentionModalEntry {
  final String id;
  final Widget Function(BuildContext context, VoidCallback dismiss) builder;
  final Color? barrierColor;
  final double blurSigma;
  final bool barrierDismissible;
  final Completer<void> completer;

  _AttentionModalEntry({
    required this.id,
    required this.builder,
    this.barrierColor,
    this.blurSigma = 5.0,
    this.barrierDismissible = false,
  }) : completer = Completer<void>();
}

final ValueNotifier<List<_AttentionModalEntry>> _modalStack =
    ValueNotifier<List<_AttentionModalEntry>>([]);
OverlayEntry? _overlayEntry;

Future<void> showAttentionModal({
  required String id,
  required Widget Function(BuildContext context, VoidCallback dismiss) builder,
  Color? barrierColor,
  double blurSigma = 5.0,
  bool barrierDismissible = false,
  bool replaceIfExists = false,
}) {
  if (replaceIfExists) {
    final idx = _modalStack.value.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final removed = _modalStack.value[idx];
      _modalStack.value = [
        ..._modalStack.value.sublist(0, idx),
        ..._modalStack.value.sublist(idx + 1),
      ];
      if (!removed.completer.isCompleted) {
        removed.completer.complete();
      }
    }
  }

  final entry = _AttentionModalEntry(
    id: id,
    builder: builder,
    barrierColor: barrierColor,
    blurSigma: blurSigma,
    barrierDismissible: barrierDismissible,
  );
  _modalStack.value = [..._modalStack.value, entry];
  _syncOverlay();
  return entry.completer.future;
}

void dismissAttentionModal([String? id]) {
  if (_modalStack.value.isEmpty) return;

  _AttentionModalEntry? removed;
  if (id != null) {
    final idx = _modalStack.value.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    removed = _modalStack.value[idx];
    _modalStack.value = [
      ..._modalStack.value.sublist(0, idx),
      ..._modalStack.value.sublist(idx + 1),
    ];
  } else {
    removed = _modalStack.value.last;
    _modalStack.value = _modalStack.value.sublist(
      0,
      _modalStack.value.length - 1,
    );
  }

  if (!removed.completer.isCompleted) {
    removed.completer.complete();
  }
  _syncOverlay();
}

void dismissAllAttentionModals() {
  for (final entry in _modalStack.value) {
    if (!entry.completer.isCompleted) {
      entry.completer.complete();
    }
  }
  _modalStack.value = [];
  _syncOverlay();
}

void _syncOverlay() {
  final overlayKey = IslandUIFoundation.overlayKey;
  if (overlayKey == null) return;

  if (_modalStack.value.isEmpty) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  } else if (_overlayEntry == null) {
    _overlayEntry = OverlayEntry(
      builder: (_) => const _AttentionModalHost(),
    );
    overlayKey.currentState?.insert(_overlayEntry!);
  }
}

class _AttentionModalHost extends StatefulWidget {
  const _AttentionModalHost();

  @override
  State<_AttentionModalHost> createState() => _AttentionModalHostState();
}

class _AttentionModalHostState extends State<_AttentionModalHost>
    with TickerProviderStateMixin {
  final Map<String, AnimationController> _controllers = {};
  final FocusNode _focusNode = FocusNode(debugLabel: 'AttentionModalHost');
  String? _dismissingId;

  @override
  void initState() {
    super.initState();
    _modalStack.addListener(_onStackChanged);
    _syncControllers(_modalStack.value);
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _modalStack.removeListener(_onStackChanged);
    _focusNode.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onStackChanged() {
    _syncControllers(_modalStack.value);
    _focusNode.requestFocus();
    setState(() {});
  }

  void _syncControllers(List<_AttentionModalEntry> stack) {
    final currentIds = stack.map((e) => e.id).toSet();

    for (final entry in stack) {
      if (entry.id == _dismissingId) continue;
      if (!_controllers.containsKey(entry.id)) {
        _controllers[entry.id] = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        );
        _controllers[entry.id]!.forward();
      }
    }

    _controllers.keys
        .where((id) => !currentIds.contains(id))
        .toList()
        .forEach((id) {
      _controllers[id]?.dispose();
      _controllers.remove(id);
    });
  }

  void _handleDismiss(String id) {
    if (_dismissingId != null) return;
    _dismissingId = id;
    final controller = _controllers[id];
    if (controller != null) {
      controller.reverse().then((_) {
        _controllers.remove(id)?.dispose();
        _dismissingId = null;
        if (_modalStack.value.isNotEmpty) {
          final stillExists = _modalStack.value.any((e) => e.id == id);
          if (stillExists) {
            dismissAttentionModal(id);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stack = _modalStack.value;
    if (stack.isEmpty) return const SizedBox.shrink();

    final topEntry = stack.last;

    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            topEntry.barrierDismissible) {
          _handleDismiss(topEntry.id);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () {
          if (topEntry.barrierDismissible) {
            _handleDismiss(topEntry.id);
          }
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: stack.first.blurSigma,
            sigmaY: stack.first.blurSigma,
          ),
          child: Container(
            color:
                stack.first.barrierColor ?? Colors.black.withOpacity(0.5),
            child: Stack(
              children: [
                for (var i = 0; i < stack.length; i++)
                  _buildEntry(
                    stack[i],
                    depth: i,
                    isTop: i == stack.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntry(
    _AttentionModalEntry entry, {
    required int depth,
    required bool isTop,
  }) {
    final targetScale = (1.0 - depth * 0.15).clamp(0.4, 1.0);
    final controller = _controllers[entry.id];
    final dismiss = isTop ? () => _handleDismiss(entry.id) : () {};

    return IgnorePointer(
      ignoring: !isTop,
      child: Center(
        child: AnimatedBuilder(
          animation: controller ?? const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            final progress = controller?.value ?? 1.0;
            final scale = targetScale *
                Tween<double>(begin: 0.8, end: 1.0).transform(progress);
            final opacity =
                Tween<double>(begin: 0.0, end: 1.0).transform(progress);

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: isTop ? () {} : null,
            behavior: isTop ? null : HitTestBehavior.deferToChild,
            child: HeroControllerScope.none(
              child: Navigator(
                pages: [
                  MaterialPage(
                    child: entry.builder(context, dismiss),
                  ),
                ],
                onPopPage: (route, result) => route.didPop(result),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
