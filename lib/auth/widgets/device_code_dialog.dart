import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../device_code_sign_in.dart';
import '../../shared/widgets/alert.dart';

/// Runs [action] with a callback that puts a device-flow code on screen.
///
/// The web build signs in with RFC 8628's device grant: nothing in a browser
/// can hand an OAuth redirect back into the page, so the provider issues a code
/// and the app polls while the user approves it in any browser tab.
///
/// Closing the dialog only stops showing the code. The sign-in runs to its own
/// end — approved or expired — and its result still reaches [action].
Future<T> withDeviceCodeSignIn<T>(
  BuildContext context,
  Future<T> Function(DeviceAuthorizationCallback onDeviceCode) action,
) async {
  final pending = ValueNotifier<DeviceAuthorization?>(null);
  final closed = ValueNotifier(false);
  Future<void>? dialog;
  try {
    return await action((value) {
      pending.value = value;
      if (!context.mounted) return;
      dialog = showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (_) => _DeviceCodeDialog(pending: pending, closed: closed),
      );
    });
  } finally {
    closed.value = true;
    final shown = dialog;
    if (shown != null) await shown;
  }
}

class _DeviceCodeDialog extends HookWidget {
  const _DeviceCodeDialog({required this.pending, required this.closed});

  final ValueNotifier<DeviceAuthorization?> pending;

  /// Set when the sign-in has ended, however it ended. Closing the dialog
  /// early does not set it: the sign-in keeps running.
  final ValueNotifier<bool> closed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    void close() {
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;
      Navigator.of(context).pop();
    }

    useEffect(() {
      void onClosed() {
        // The sign-in can end before the route reaches the screen; the pop then
        // has to wait for the frame that pushed it.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (closed.value && context.mounted) close();
        });
      }

      closed.addListener(onClosed);
      if (closed.value) onClosed();
      return () => closed.removeListener(onClosed);
    }, const []);

    final body = ValueListenableBuilder<DeviceAuthorization?>(
      valueListenable: pending,
      builder: (context, value, _) {
        if (value == null) {
          return const LinearProgressIndicator();
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('signInOverWebDeviceCodeInstruction'.tr()),
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      value.userCode,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'copyToClipboard'.tr(),
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: value.userCode),
                      );
                      if (context.mounted) {
                        showSnackBar('copyToClipboard'.tr());
                      }
                    },
                    icon: const Icon(Symbols.content_copy, size: 18),
                  ),
                ],
              ),
            ),
            const Gap(16),
            Row(
              children: [
                const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    'signInOverWebDeviceCodeWaiting'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    return AlertDialog(
      title: Text('signInOverWebDeviceCodeTitle'.tr()),
      content: SizedBox(width: 360, child: body),
      actions: [
        TextButton(onPressed: close, child: Text('close'.tr())),
        ValueListenableBuilder<DeviceAuthorization?>(
          valueListenable: pending,
          builder: (context, value, _) => FilledButton.tonalIcon(
            onPressed: value == null
                ? null
                : () => launchUrlString(
                    value.verificationUriComplete.toString(),
                    mode: LaunchMode.externalApplication,
                  ),
            icon: const Icon(Symbols.open_in_new, size: 18),
            label: Text('signInOverWebDeviceCodeOpen'.tr()),
          ),
        ),
      ],
    );
  }
}
