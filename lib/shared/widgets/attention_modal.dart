import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/main.dart';

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
  if (_modalStack.value.isEmpty) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  } else if (_overlayEntry == null) {
    _overlayEntry = OverlayEntry(
      builder: (_) => const _AttentionModalHost(),
    );
    globalOverlay.currentState?.insert(_overlayEntry!);
  }
}

class _AttentionModalHost extends HookWidget {
  const _AttentionModalHost();

  @override
  Widget build(BuildContext context) {
    final stack = useValueListenable(_modalStack);
    final topEntry = stack.isNotEmpty ? stack.last : null;

    final prevTopId = useRef<String?>(null);
    final isDismissing = useRef(false);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    final scaleAnimation = useAnimation(
      Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      ),
    );
    final opacityAnimation = useAnimation(
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      ),
    );

    useEffect(() {
      if (topEntry != null && topEntry.id != prevTopId.value) {
        if (isDismissing.value) {
          final dismissedId = prevTopId.value;
          isDismissing.value = false;
          if (dismissedId != null) {
            dismissAttentionModal(dismissedId);
          }
        }
        animationController.reset();
        animationController.forward();
        prevTopId.value = topEntry.id;
      }
      return null;
    }, [topEntry?.id]);

    final handleDismiss = useCallback(() {
      if (topEntry == null || isDismissing.value) return;
      isDismissing.value = true;
      final id = topEntry.id;
      animationController.reverse().then((_) {
        isDismissing.value = false;
        if (_modalStack.value.isNotEmpty &&
            _modalStack.value.last.id == id) {
          dismissAttentionModal(id);
        }
      });
    }, [topEntry?.id]);

    if (topEntry == null) return const SizedBox.shrink();

    return KeyboardListener(
      focusNode: useFocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            topEntry.barrierDismissible) {
          handleDismiss();
        }
      },
      child: GestureDetector(
        onTap: () {
          if (topEntry.barrierDismissible) {
            handleDismiss();
          }
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: topEntry.blurSigma,
            sigmaY: topEntry.blurSigma,
          ),
          child: Container(
            color: topEntry.barrierColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) => Opacity(
                  opacity: opacityAnimation,
                  child: Transform.scale(
                    scale: scaleAnimation,
                    child: child,
                  ),
                ),
                child: topEntry.builder(context, handleDismiss),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
