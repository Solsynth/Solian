import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/main.dart';
import 'package:island/talker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void showSnackBar(String message, {SnackBarAction? action}) {
  final context = globalOverlay.currentState!.context;
  final screenWidth = MediaQuery.of(context).size.width;
  final padding = 40.0;
  final availableWidth = screenWidth - padding;

  showTopSnackBar(
    globalOverlay.currentState!,
    Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: availableWidth.clamp(0, 400),
          maxWidth: availableWidth.clamp(0, 600),
        ),
        child: Card(
          elevation: 2,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Text(message).padding(horizontal: 20, vertical: 16),
        ),
      ),
    ),
    curve: Curves.easeInOut,
    snackBarPosition: SnackBarPosition.bottom,
  );
}

OverlayEntry? _loadingOverlay;
GlobalKey<_FadeOverlayState> _loadingOverlayKey = GlobalKey();

class _FadeOverlay extends StatefulWidget {
  const _FadeOverlay({
    super.key,
    this.child,
    this.builder,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.linear,
  }) : assert(child != null || builder != null);

  final Widget? child;
  final Widget Function(BuildContext, Animation<double>)? builder;
  final Duration duration;
  final Curve curve;

  @override
  State<_FadeOverlay> createState() => _FadeOverlayState();
}

class _FadeOverlayState extends State<_FadeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> animateOut() async {
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    if (widget.builder != null) {
      return widget.builder!(context, animation);
    }
    return FadeTransition(opacity: animation, child: widget.child);
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
                    CircularProgressIndicator(year2023: false),
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
    await state.animateOut();
  }

  entry.remove();
}

String _parseRemoteError(DioException err) {
  String? message;
  if (err.response?.data is String) {
    message = err.response?.data;
  } else if (err.response?.data?['message'] != null) {
    message = <String?>[
      err.response?.data?['message']?.toString(),
      err.response?.data?['detail']?.toString(),
    ].where((e) => e != null).cast<String>().map((e) => e.trim()).join('\n');
  } else if (err.response?.data?['errors'] != null) {
    final errors = err.response?.data['errors'] as Map<String, dynamic>;
    message = errors.values
        .map(
          (ele) =>
              (ele as List<dynamic>).map((ele) => ele.toString()).join('\n'),
        )
        .join('\n');
  }
  if (message == null || message.isEmpty) message = err.response?.statusMessage;
  message ??= err.message;
  return message ?? err.toString();
}

// Track active overlay dialogs for dismissal
final List<void Function()> _activeOverlayDialogs = [];

Future<T?> showOverlayDialog<T>({
  required Widget Function(BuildContext context, void Function(T? result) close)
  builder,
  bool barrierDismissible = true,
}) {
  final completer = Completer<T?>();
  final key = GlobalKey<_FadeOverlayState>();
  late OverlayEntry entry;

  void close(T? result) async {
    if (completer.isCompleted) return;

    final state = key.currentState;
    if (state != null) {
      await state.animateOut();
    }

    entry.remove();
    _activeOverlayDialogs.remove(close);
    completer.complete(result);
  }

  entry = OverlayEntry(
    builder:
        (context) => _FadeOverlay(
          key: key,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          builder: (context, animation) {
            return Stack(
              children: [
                Positioned.fill(
                  child: FadeTransition(
                    opacity: animation,
                    child: GestureDetector(
                      onTap: barrierDismissible ? () => close(null) : null,
                      behavior: HitTestBehavior.opaque,
                      child: const ColoredBox(color: Colors.black54),
                    ),
                  ),
                ),
                Center(
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: builder(context, close),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
  );

  _activeOverlayDialogs.add(() => close(null));
  globalOverlay.currentState!.insert(entry);
  return completer.future;
}

// Close the topmost overlay dialog if any exists
bool closeTopmostOverlayDialog() {
  if (_activeOverlayDialogs.isNotEmpty) {
    final closeFunc = _activeOverlayDialogs.last;
    closeFunc();
    return true;
  }
  return false;
}

const kDialogMaxWidth = 480.0;

void showErrorAlert(dynamic err, {IconData? icon}) {
  if (err is Error) {
    talker.error('Something went wrong...', err, err.stackTrace);
  }
  final text = switch (err) {
    String _ => err,
    DioException _ => _parseRemoteError(err),
    Exception _ => err.toString(),
    _ => err.toString(),
  };

  showOverlayDialog<void>(
    builder:
        (context, close) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kDialogMaxWidth),
          child: AlertDialog(
            title: null,
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon ?? Icons.error_outline_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const Gap(16),
                Text(
                  'somethingWentWrong'.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Gap(8),
                Text(text),
                const Gap(8),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => close(null),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ),
  );
}

void showInfoAlert(String message, String title, {IconData? icon}) {
  showOverlayDialog<void>(
    builder:
        (context, close) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kDialogMaxWidth),
          child: AlertDialog(
            title: null,
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon ?? Symbols.info_rounded,
                  fill: 1,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(16),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const Gap(8),
                Text(message),
                const Gap(8),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => close(null),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ),
  );
}

Future<bool> showConfirmAlert(
  String message,
  String title, {
  IconData? icon,
  bool isDanger = false,
}) async {
  final result = await showOverlayDialog<bool>(
    builder:
        (context, close) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kDialogMaxWidth),
          child: AlertDialog(
            title: null,
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon ?? Symbols.help_rounded,
                  size: 48,
                  fill: 1,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(16),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const Gap(8),
                Text(message),
                const Gap(8),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => close(false),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              TextButton(
                onPressed: () => close(true),
                style:
                    isDanger
                        ? TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        )
                        : null,
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        ),
  );
  return result ?? false;
}
