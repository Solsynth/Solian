import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:island_ui_foundation/src/foundation.dart';
import 'package:island_ui_foundation/src/responsive.dart';

class _AttentionModalEntry {
  final String id;
  final Widget Function(BuildContext context, VoidCallback dismiss) builder;
  final Color? barrierColor;
  final double blurSigma;
  final bool barrierDismissible;
  final Completer<void> completer;
  Route<void>? route;
  bool isDismissing = false;

  _AttentionModalEntry({
    required this.id,
    required this.builder,
    this.barrierColor,
    this.blurSigma = 5.0,
    this.barrierDismissible = false,
  }) : completer = Completer<void>();
}

final Map<String, _AttentionModalEntry> _modalEntries =
    <String, _AttentionModalEntry>{};
final List<String> _modalOrder = <String>[];

Future<void> showAttentionModal({
  required String id,
  required Widget Function(BuildContext context, VoidCallback dismiss) builder,
  Color? barrierColor,
  double blurSigma = 5.0,
  bool barrierDismissible = false,
  bool replaceIfExists = false,
}) async {
  if (replaceIfExists) {
    dismissAttentionModal(id);
  } else if (_modalEntries.containsKey(id)) {
    return _modalEntries[id]!.completer.future;
  }

  final navigator = _resolveNavigator();
  if (navigator == null) {
    return Future.error(
      StateError('Attention modal navigator is not available.'),
    );
  }

  final entry = _AttentionModalEntry(
    id: id,
    builder: builder,
    barrierColor: barrierColor,
    blurSigma: blurSigma,
    barrierDismissible: barrierDismissible,
  );

  _modalEntries[id] = entry;
  _modalOrder.add(id);

  final route = PageRouteBuilder<void>(
    settings: RouteSettings(name: 'attention-modal:$id'),
    opaque: false,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _AttentionModalRoutePage(entry: entry);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );

  entry.route = route;

  navigator.push(route).whenComplete(() {
    final tracked = _modalEntries[id];
    if (identical(tracked, entry)) {
      _modalEntries.remove(id);
      _modalOrder.remove(id);
    }
    if (!entry.completer.isCompleted) {
      entry.completer.complete();
    }
  });

  return entry.completer.future;
}

void dismissAttentionModal([String? id]) {
  if (_modalEntries.isEmpty) return;

  final targetId = id ?? (_modalOrder.isNotEmpty ? _modalOrder.last : null);
  if (targetId == null) return;

  final entry = _modalEntries[targetId];
  if (entry == null || entry.isDismissing) return;

  entry.isDismissing = true;
  final route = entry.route;
  final navigator = route?.navigator ?? _resolveNavigator();
  if (route != null && navigator != null) {
    if (route.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(route);
    }
    return;
  }

  _modalEntries.remove(targetId);
  _modalOrder.remove(targetId);
  if (!entry.completer.isCompleted) {
    entry.completer.complete();
  }
}

void dismissAllAttentionModals() {
  for (final id in List<String>.from(_modalOrder.reversed)) {
    dismissAttentionModal(id);
  }
}

NavigatorState? _resolveNavigator() {
  final navigator = IslandUIFoundation.navigatorKey?.currentState;
  if (navigator != null) return navigator;

  final overlayContext = IslandUIFoundation.overlayKey?.currentContext;
  if (overlayContext == null) return null;

  try {
    return Navigator.of(overlayContext, rootNavigator: true);
  } on FlutterError {
    return null;
  }
}

class _AttentionModalRoutePage extends StatelessWidget {
  final _AttentionModalEntry entry;

  const _AttentionModalRoutePage({required this.entry});

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    final route = ModalRoute.of(context);
    final animation = route?.animation;
    final secondaryAnimation = route?.secondaryAnimation;
    final curvedAnimation = animation == null
        ? const AlwaysStoppedAnimation<double>(1)
        : CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final stackedAnimation = secondaryAnimation == null
        ? const AlwaysStoppedAnimation<double>(0)
        : CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic);
    final barrierColor = entry.barrierColor ?? Colors.black.withOpacity(0.5);

    void dismiss() {
      dismissAttentionModal(entry.id);
    }

    return HeroControllerScope.none(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (entry.barrierDismissible) dismiss();
          },
        },
        child: Focus(
          autofocus: true,
          child: Material(
            type: MaterialType.transparency,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: entry.barrierDismissible ? dismiss : null,
                  child: wide
                      ? BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: entry.blurSigma,
                            sigmaY: entry.blurSigma,
                          ),
                          child: ColoredBox(color: barrierColor),
                        )
                      : ColoredBox(color: barrierColor),
                ),
                SafeArea(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      curvedAnimation,
                      stackedAnimation,
                    ]),
                    builder: (context, child) {
                      final enterT = curvedAnimation.value;
                      final stackedT = stackedAnimation.value;
                      final opacity = Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).transform(enterT);
                      final coveredScale = Tween<double>(
                        begin: 1.0,
                        end: 0.85,
                      ).transform(stackedT);

                      if (wide) {
                        final enterScale = Tween<double>(
                          begin: 0.92,
                          end: 1.0,
                        ).transform(enterT);
                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: enterScale * coveredScale,
                            child: child,
                          ),
                        );
                      }

                      final slideOffset = Tween<double>(
                        begin: 0.18,
                        end: 0.0,
                      ).transform(enterT);
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            slideOffset * MediaQuery.of(context).size.height,
                          ),
                          child: Transform.scale(
                            scale: coveredScale,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {},
                      child: entry.builder(context, dismiss),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
