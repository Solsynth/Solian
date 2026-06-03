import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

IconData _platformIcon(int? platform) {
  return switch (platform) {
    2 => Symbols.phone_iphone,
    3 => Symbols.phone_android,
    4 => Symbols.computer,
    5 => Symbols.computer,
    6 => Symbols.computer,
    1 => Symbols.language,
    _ => Symbols.devices,
  };
}

String _platformName(int? platform) {
  return switch (platform) {
    2 => 'platformIos'.tr(),
    3 => 'platformAndroid'.tr(),
    4 => 'platformMacos'.tr(),
    5 => 'platformWindows'.tr(),
    6 => 'platformLinux'.tr(),
    1 => 'platformWeb'.tr(),
    _ => 'platformUnknown'.tr(),
  };
}

class ChallengeApprovalSheet extends HookConsumerWidget {
  final SnAuthChallenge challenge;
  final VoidCallback? onResolved;

  const ChallengeApprovalSheet({
    super.key,
    required this.challenge,
    this.onResolved,
  });

  static Future<void> show(
    BuildContext context,
    SnAuthChallenge challenge, {
    VoidCallback? onResolved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => ChallengeApprovalSheet(
        challenge: challenge,
        onResolved: onResolved,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final pinController = useTextEditingController();
    final remaining = useState<int?>(null);
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    useEffect(() {
      if (challenge.expiredAt == null) return null;
      final expiry = challenge.expiredAt!;
      void updateRemaining() {
        final diff = expiry.difference(DateTime.now());
        remaining.value = diff.inSeconds > 0 ? diff.inSeconds : 0;
      }

      updateRemaining();
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        updateRemaining();
      });
      return timer.cancel;
    }, [challenge.expiredAt]);

    final expired = remaining.value != null && remaining.value! <= 0;

    Future<void> performApprove() async {
      isBusy.value = true;
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.auth.approveChallenge(
          challengeId: challenge.id,
          pinCode: pinController.text.isNotEmpty ? pinController.text : null,
        );
        if (context.mounted) {
          showSnackBar('challengeApprovedByYou'.tr(
            args: [challenge.deviceName ?? 'unknown'.tr()],
          ));
          Navigator.pop(context);
          onResolved?.call();
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> performDecline() async {
      isBusy.value = true;
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.auth.declineChallenge(
          challengeId: challenge.id,
          pinCode: pinController.text.isNotEmpty ? pinController.text : null,
        );
        if (context.mounted) {
          showSnackBar('challengeDeclinedByYou'.tr(
            args: [challenge.deviceName ?? 'unknown'.tr()],
          ));
          Navigator.pop(context);
          onResolved?.call();
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        isBusy.value = false;
      }
    }

    return SheetScaffold(
      titleText: 'challengePendingTitle'.tr(),
      heightFactor: isMobile ? 0.95 : 0.82,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _platformIcon(challenge.platform),
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    challenge.deviceName ?? 'unknownDevice'.tr(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    _platformName(challenge.platform),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Symbols.language,
                        label: 'challengeIpAddress'.tr(),
                        value: challenge.ipAddress,
                      ),
                      _DetailRow(
                        icon: Symbols.schedule,
                        label: 'challengeRequested'.tr(),
                        value: RelativeTime(context).format(challenge.createdAt),
                      ),
                      if (remaining.value != null)
                        _DetailRow(
                          icon: Symbols.timer,
                          label: 'challengeExpiresIn'.tr(),
                          value: 'challengeSeconds'.tr(
                            args: ['${remaining.value}'],
                          ),
                          valueColor: remaining.value! < 60
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(
                            (255 * 0.3).round(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withAlpha(
                              (255 * 0.3).round(),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.info,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'challengeApprovalHint'.tr(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'challengePinLabel'.tr(),
                          hintText: 'challengePinHint'.tr(),
                          prefixIcon: const Icon(Symbols.pin),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (expired)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.timer_off,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'challengeExpired'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy.value ? null : performDecline,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: isBusy.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text('challengeDecline'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBusy.value ? null : performApprove,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isBusy.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text('challengeApprove'.tr()),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value ?? '—',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
