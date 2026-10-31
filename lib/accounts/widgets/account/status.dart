import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/profile.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/accounts/widgets/account/status_card.dart';
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
    final resp = await apiClient.get('/stargate/accounts/$uname/statuses');
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
    final renderPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: userStatus.when(
        data: (status) => (status?.isCustomized ?? false)
            ? AccountStatusWidget(uname: uname, padding: renderPadding)
            : Padding(
                padding: renderPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Symbols.keyboard_arrow_up_rounded),
                        const SizedBox(width: 4),
                        Text('statusCreate'.tr()),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'statusCreateHint'.tr(),
                      style: const TextStyle(fontSize: 12),
                    ).opacity(0.75),
                  ],
                ),
              ).opacity(0.85),
        error: (error, _) => _StatusStateCard(
          padding: renderPadding,
          icon: Symbols.error_rounded,
          title: 'statusUnavailable'.tr(),
          subtitle: '$error',
        ),
        loading: () => _StatusStateCard(
          padding: renderPadding,
          icon: Symbols.more_horiz_rounded,
          title: 'loading'.tr(),
          subtitle: 'statusFetching'.tr(),
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
        icon: Symbols.circle_rounded,
        title: getStatusDisplayLabel(context, statusValue),
        subtitle: 'statusNoCustom'.tr(),
      ).opacity(0.85);
    }

    final hasMedia = statusValue.icon != null || statusValue.background != null;
    if (!hasMedia) {
      return AccountStatusInline(
        indicatorIcon: getStatusIndicatorIcon(statusValue),
        indicatorFill: getStatusIndicatorFill(statusValue),
        indicatorColor: getStatusIndicatorColor(statusValue),
        title:
            getActivityTitle(statusValue.label, statusValue.meta) ??
            getStatusDisplayLabel(context, statusValue),
        titleTooltip: statusValue.isCustomized
            ? getActivityFullMessage(statusValue)
            : null,
        onLongPress: statusValue.isCustomized
            ? () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('activityDetails'.tr()),
                    content: buildActivityDetails(status.value),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('close'.tr()),
                      ),
                    ],
                  ),
                );
              }
            : null,
        showIdleBadge: statusValue.isIdleOrOnline,
        attitude: statusValue.attitude,
        meta:
            getActivitySubtitle(statusValue.meta) ??
            getStatusOnlineDeviceLabel(statusValue) ??
            ((!statusValue.isOnline &&
                    account.value?.profile.lastSeenAt != null)
                ? account.value!.profile.lastSeenAt!.formatRelative(context)
                : null),
        padding: padding,
      ).opacity(statusValue.isCustomized ? 1 : 0.85);
    }

    return _StatusDisplayCard(
      status: statusValue,
      padding: padding,
      trailingText:
          getActivitySubtitle(statusValue.meta) ??
          getStatusOnlineDeviceLabel(statusValue) ??
          ((!(statusValue.isOnline) &&
                  account.value?.profile.lastSeenAt != null)
              ? account.value!.profile.lastSeenAt!.formatRelative(context)
              : null),
      onLongPress: statusValue.isCustomized
          ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('activityDetails'.tr()),
                  content: buildActivityDetails(status.value),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('close'.tr()),
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
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
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
    final hasBackground = status.background != null;
    final typeLabel = getStatusDisplayLabel(context, status);
    final symbol = status.symbol;

    return AccountStatusCard(
      title: getActivityTitle(status.label, status.meta) ?? typeLabel,
      subtitle: (symbol?.isNotEmpty ?? false) ? symbol : typeLabel,
      trailingText: trailingText,
      icon: status.icon,
      background: status.background,
      indicatorIcon: getStatusIndicatorIcon(status),
      indicatorFill: getStatusIndicatorFill(status),
      indicatorColor: getStatusIndicatorColor(status),
      attitude: status.attitude,
      showIdleBadge: status.isIdleOrOnline,
      margin: hasBackground
          ? EdgeInsets.zero
          : (padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      onLongPress: onLongPress,
    );
  }
}
