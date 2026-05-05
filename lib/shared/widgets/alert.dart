import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/main.dart';
import 'package:island/core/config.dart';
import 'package:island/core/notification.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.dart';

import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/core/network/domain_trust.dart';
import 'package:island/shared/widgets/content/domain_trust_sheet.dart';

const double kFloatingSnackBarWidth = 400.0;

void showSnackBar(String message, {SnackBarAction? action}) {
  final messenger = globalScaffoldMessengerKey.currentState;
  if (messenger == null) return;

  final context = messenger.context;
  final screenWidth = MediaQuery.of(context).size.width;
  final wideScreen = screenWidth > kWideScreenWidth;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    wideScreen
        ? SnackBar(
            content: Text(message),
            action: action,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 1500),
            margin: EdgeInsets.only(
              left: screenWidth - kFloatingSnackBarWidth - 16,
              right: 16,
              bottom: 16,
            ),
          )
        : SnackBar(
            content: Text(message),
            action: action,
            behavior: SnackBarBehavior.fixed,
            shape: RoundedRectangleBorder(),
            duration: const Duration(milliseconds: 1500),
          ),
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
    builder: (context) => _FadeOverlay(
      key: _loadingOverlayKey,
      child: Material(
        color: Colors.black54,
        child: Center(
          child: AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  year2023: false,
                  padding: EdgeInsets.zero,
                ).width(28).height(28).padding(horizontal: 8),
                const Gap(16),
                Text('loading'.tr()),
              ],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
    builder: (context) => _FadeOverlay(
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

bool closeTopmostOverlayDialog() {
  if (_activeOverlayDialogs.isNotEmpty) {
    final closeFunc = _activeOverlayDialogs.last;
    closeFunc();
    return true;
  }
  return false;
}

const kDialogMaxWidth = 480.0;

Future<void> _playSfx(String assetPath, double volume) async {
  final player = AudioPlayer();
  await player.setVolume(volume);
  await player.setAudioSource(AudioSource.asset(assetPath));
  await player.play();
  await player.dispose();
}

void showErrorAlert(dynamic err, {IconData? icon}) {
  final context = globalOverlay.currentState!.context;
  final ref = ProviderScope.containerOf(context);
  final settings = ref.read(appSettingsProvider);
  if (settings.soundEffects) {
    unawaited(_playSfx('assets/audio/alert.reversed.wav', 0.75));
  }

  if (err is Error) {
    Logger.root.severe('Something went wrong...', err, err.stackTrace);
  }
  final text = switch (err) {
    String _ => err,
    DioException _ => _parseRemoteError(err),
    Exception _ => err.toString(),
    _ => err.toString(),
  };

  showOverlayDialog<void>(
    builder: (context, close) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: kDialogMaxWidth),
      child: AlertDialog(
        title: null,
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        content: SingleChildScrollView(
          child: Column(
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
              SelectableText(text),
              const Gap(8),
            ],
          ),
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
  final context = globalOverlay.currentState!.context;
  final ref = ProviderScope.containerOf(context);
  final settings = ref.read(appSettingsProvider);
  if (settings.soundEffects) {
    unawaited(_playSfx('assets/audio/alert.wav', 0.75));
  }

  showOverlayDialog<void>(
    builder: (context, close) => ConstrainedBox(
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
  final context = globalOverlay.currentState!.context;
  final ref = ProviderScope.containerOf(context);
  final settings = ref.read(appSettingsProvider);
  if (settings.soundEffects) {
    unawaited(_playSfx('assets/audio/alert.wav', 0.75));
  }

  final result = await showOverlayDialog<bool>(
    builder: (context, close) => ConstrainedBox(
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
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => close(true),
            style: isDanger
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

void showNotification({
  required String title,
  String content = '',
  String subtitle = '',
  Map<String, dynamic> meta = const {},
  Duration? duration,
}) {
  final context = globalOverlay.currentState!.context;
  final ref = ProviderScope.containerOf(context);
  final notification = SnNotification(
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    deletedAt: null,
    id: 'local_${DateTime.now().millisecondsSinceEpoch}',
    topic: 'local',
    title: title,
    subtitle: subtitle,
    content: content,
    meta: meta,
    priority: 0,
    viewedAt: null,
    accountId: 'local',
  );
  ref
      .read(notificationStateProvider.notifier)
      .add(notification, duration: duration);
}

Future<void> openExternalLink(Uri url, WidgetRef ref) async {
  final context = ref.read(routerProvider).navigatorKey.currentState!.context;

  showLoadingModal(context);
  final domainTrustService = ref.read(domainTrustServiceProvider);
  final result = await domainTrustService.validateUrl(url);

  if (!context.mounted) return;
  hideLoadingModal(context);

   if (result.trustLevel == DomainTrustLevel.verified) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
    return;
  }

  final decision = await showDomainTrustSheet(
    context,
    uri: url,
    result: result,
    action: DomainTrustAction.openLink,
  );

  if (decision == DomainTrustDecision.proceed) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
