import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:styled_widget/styled_widget.dart';

export 'content/alert.native.dart'
    if (dart.library.html) 'content/alert.web.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), action: action));
}

void clearSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).clearSnackBars();
}

OverlayEntry? _loadingOverlay;
GlobalKey<_FadeOverlayState> _loadingOverlayKey = GlobalKey();

class _FadeOverlay extends StatefulWidget {
  const _FadeOverlay({super.key, required this.child});
  final Widget child;

  @override
  State<_FadeOverlay> createState() => _FadeOverlayState();
}

class _FadeOverlayState extends State<_FadeOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: widget.child,
    );
  }
}

void showLoadingModal(BuildContext context) {
  if (_loadingOverlay != null) return;

  _loadingOverlay = OverlayEntry(
    builder:
        (context) => _FadeOverlay(
          key: _loadingOverlayKey,
          child: Material(
            color: Colors.black54,
            child: Center(
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                elevation: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(year2023: true),
                    const Gap(24),
                    Text('loading'.tr()),
                  ],
                ).padding(all: 32),
              ),
            ),
          ),
        ),
  );

  Overlay.of(context).insert(_loadingOverlay!);
}

void hideLoadingModal(BuildContext context) async {
  if (_loadingOverlay == null) return;

  final entry = _loadingOverlay!;
  _loadingOverlay = null;

  final state = entry.mounted ? _loadingOverlayKey.currentState : null;

  if (state != null) {
    // ignore: invalid_use_of_protected_member
    state.setState(() => state._visible = false);
    await Future.delayed(const Duration(milliseconds: 200));
  }

  entry.remove();
}
