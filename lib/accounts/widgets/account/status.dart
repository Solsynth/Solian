import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/profile.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/accounts/widgets/account/status_creation.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/activity_utils.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'status.g.dart';

final currentAccountStatusProvider =
    NotifierProvider<CurrentAccountStatusNotifier, SnAccountStatus?>(
      CurrentAccountStatusNotifier.new,
    );

class CurrentAccountStatusNotifier extends Notifier<SnAccountStatus?> {
  @override
  SnAccountStatus? build() {
    return null;
  }

  void setStatus(SnAccountStatus status) {
    state = status;
  }

  void clearStatus() {
    state = null;
  }
}

@riverpod
Future<SnAccountStatus?> accountStatus(Ref ref, String uname) async {
  final userInfo = ref.watch(userInfoProvider);
  if (uname == 'me' ||
      (userInfo.value != null && uname == userInfo.value!.name)) {
    final local = ref.watch(currentAccountStatusProvider);
    if (local != null) {
      return local;
    }
  }
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get('/passport/accounts/$uname/statuses');
    return SnAccountStatus.fromJson(resp.data);
  } catch (err) {
    if (err is DioException) {
      if (err.response?.statusCode == 404) {
        return null;
      }
    }
    rethrow;
  }
}

class AccountStatusCreationWidget extends HookConsumerWidget {
  final String uname;
  final EdgeInsets? padding;
  const AccountStatusCreationWidget({
    super.key,
    required this.uname,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatus = ref.watch(accountStatusProvider(uname));

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      child: userStatus.when(
        data: (status) => (status?.isCustomized ?? false)
            ? AccountStatusWidget(uname: uname, padding: padding)
            : _StatusCallToActionCard(padding: padding),
        error: (error, _) => _StatusStateCard(
          padding: padding,
          icon: Symbols.error,
          title: 'Status unavailable',
          subtitle: '$error',
        ),
        loading: () => _StatusStateCard(
          padding: padding,
          icon: Symbols.more_horiz,
          title: 'loading'.tr(),
          subtitle: 'Fetching current status',
        ),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => AccountStatusCreationSheet(
            initialStatus: (userStatus.value?.isCustomized ?? false)
                ? userStatus.value
                : null,
          ),
        );
      },
    );
  }
}

class AccountStatusWidget extends HookConsumerWidget {
  final String uname;
  final EdgeInsets? padding;
  const AccountStatusWidget({super.key, required this.uname, this.padding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    final localStatus = ref.watch(currentAccountStatusProvider);
    final status =
        (uname == 'me' ||
            (userInfo.value != null &&
                uname == userInfo.value!.name &&
                localStatus != null))
        ? AsyncValue.data(localStatus)
        : ref.watch(accountStatusProvider(uname));
    final account = ref.watch(accountProvider(uname));
    final statusValue = status.value;
    if (statusValue == null) {
      return _StatusStateCard(
        padding: padding,
        icon: Symbols.circle,
        title: getStatusDisplayLabel(context, statusValue),
        subtitle: 'No custom status set',
      ).opacity(0.85);
    }

    return _StatusDisplayCard(
      status: statusValue,
      padding: padding,
      trailingText:
          getActivitySubtitle(statusValue.meta) ??
          ((!(statusValue.isOnline) &&
                  account.value?.profile.lastSeenAt != null)
              ? account.value!.profile.lastSeenAt!.formatRelative(context)
              : null),
      onLongPress: statusValue.isCustomized
          ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Activity Details'),
                  content: buildActivityDetails(status.value),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          : null,
    ).opacity(statusValue.isCustomized ? 1 : 0.85);
  }
}

class AccountStatusLabel extends StatelessWidget {
  final SnAccountStatus status;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  const AccountStatusLabel({
    super.key,
    required this.status,
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        getActivityTitle(status.label, status.meta) ??
        getStatusDisplayLabel(context, status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (status.icon != null)
          ClipOval(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CloudFileWidget(
                item: status.icon!,
                fit: BoxFit.cover,
                useInternalGate: false,
              ),
            ),
          ).padding(right: 4)
        else
          Icon(
            getStatusIndicatorIcon(status),
            fill: getStatusIndicatorFill(status),
            color: getStatusIndicatorColor(status),
            size: 14,
          ).padding(right: 4),
        Flexible(
          child: Text(
            title,
            style: style,
            maxLines: maxLines,
            overflow: overflow,
          ).fontSize(13),
        ),
      ],
    );
  }
}

class _StatusCallToActionCard extends StatelessWidget {
  final EdgeInsets? padding;

  const _StatusCallToActionCard({this.padding});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Symbols.add_reaction, color: colorScheme.onPrimaryContainer),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'statusCreate'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(2),
                Text(
                  'Tap to set your current activity and let others know what you\'re up to',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ).tr(),
              ],
            ),
          ),
          Icon(Symbols.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _StatusStateCard extends StatelessWidget {
  final EdgeInsets? padding;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatusStateCard({
    this.padding,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDisplayCard extends StatelessWidget {
  final SnAccountStatus status;
  final EdgeInsets? padding;
  final String? trailingText;
  final VoidCallback? onLongPress;

  const _StatusDisplayCard({
    required this.status,
    this.padding,
    this.trailingText,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasBackground = status.background != null;
    final title =
        getActivityTitle(status.label, status.meta) ??
        getStatusDisplayLabel(context, status);
    final subtitle = (status.symbol?.isNotEmpty ?? false)
        ? status.symbol
        : getStatusDisplayLabel(context, status);
    final textShadow = hasBackground
        ? const [
            Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
          ]
        : null;
    final indicatorColor = getStatusIndicatorColor(status);

    Widget leading = status.icon != null
        ? ProfilePictureWidget(
            file: status.icon,
            radius: hasBackground ? 24 : 20,
            borderRadius: hasBackground ? 14 : 12,
            fallbackIcon: getStatusIndicatorIcon(status),
            fallbackColor: hasBackground ? Colors.white : null,
          )
        : Container(
            width: hasBackground ? 48 : 40,
            height: hasBackground ? 48 : 40,
            decoration: BoxDecoration(
              color: hasBackground
                  ? Colors.white24
                  : colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(hasBackground ? 14 : 12),
            ),
            child: Icon(
              getStatusIndicatorIcon(status),
              fill: getStatusIndicatorFill(status),
              color: hasBackground
                  ? Colors.white
                  : indicatorColor == Colors.transparent
                  ? colorScheme.onPrimaryContainer
                  : indicatorColor,
            ),
          );

    Widget card = Container(
      margin:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (hasBackground)
              Positioned.fill(
                child: CloudImageWidget(
                  file: status.background,
                  aspectRatio: 16 / 9,
                  noBlurhash: true,
                ),
              ),
            if (hasBackground)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.38),
                      ],
                    ),
                  ),
                ),
              ),
            Align(
              alignment: hasBackground
                  ? Alignment.bottomLeft
                  : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    leading,
                    const Gap(12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: hasBackground ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: hasBackground ? Colors.white : null,
                                  shadows: textShadow,
                                ),
                          ),
                          if ((subtitle?.isNotEmpty ?? false))
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: hasBackground
                                        ? Colors.white.withOpacity(0.92)
                                        : colorScheme.onSurfaceVariant,
                                    shadows: textShadow,
                                  ),
                            ),
                          if ((trailingText?.isNotEmpty ?? false))
                            Text(
                              trailingText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: hasBackground
                                        ? Colors.white.withOpacity(0.82)
                                        : colorScheme.onSurfaceVariant,
                                    shadows: textShadow,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    if (status.isIdleOrOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: hasBackground
                              ? Colors.white24
                              : Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'idle'.tr(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: hasBackground
                                    ? Colors.white
                                    : Colors.amber.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onLongPress != null) {
      card = GestureDetector(onLongPress: onLongPress, child: card);
    }

    if (hasBackground) {
      return AspectRatio(aspectRatio: 16 / 9, child: card);
    }

    return card;
  }
}
