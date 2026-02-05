import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account/profile.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/accounts/accounts_widgets/account/status_creation.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/accounts_pod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/activity_utils.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

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
    final resp = await apiClient.get('/pass/accounts/$uname/statuses');
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
        padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: userStatus.when(
        data: (status) => (status?.isCustomized ?? false)
            ? Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AccountStatusWidget(
                  uname: uname,
                  padding: renderPadding,
                ),
              )
            : Padding(
                padding: renderPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Symbols.keyboard_arrow_up),
                        SizedBox(width: 4),
                        Text('Create Status').tr(),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap to set your current activity and let others know what you\'re up to',
                      style: TextStyle(fontSize: 12),
                    ).tr().opacity(0.75),
                  ],
                ),
              ).opacity(0.85),
        error: (error, _) => Padding(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          child: Row(
            spacing: 4,
            children: [Icon(Symbols.close), Text('Error: $error')],
          ),
        ).opacity(0.85),
        loading: () => Padding(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          child: Row(
            spacing: 4,
            children: [Icon(Symbols.more_vert), Text('loading').tr()],
          ),
        ).opacity(0.85),
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

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 27, vertical: 4),
      child: Row(
        spacing: 4,
        children: [
          if (status.value?.isOnline ?? false)
            Icon(
              Symbols.circle,
              fill: 1,
              color: Colors.green,
              size: 16,
            ).padding(right: 4)
          else
            Icon(
              Symbols.circle,
              color: Colors.grey,
              size: 16,
            ).padding(right: 4),
          if (status.value?.isCustomized ?? false)
            Flexible(
              child: GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Activity Details'),
                      content: buildActivityDetails(status.value),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: Tooltip(
                  richMessage: getActivityFullMessage(status.value),
                  child: Text(
                    getActivityTitle(status.value?.label, status.value?.meta) ??
                        'unknown'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
          else
            Flexible(
              child: Text(
                (status.value?.label ?? 'offline').toLowerCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).tr(),
            ),
          if (getActivitySubtitle(status.value?.meta) != null)
            Flexible(
              child: Text(
                getActivitySubtitle(status.value?.meta)!,
              ).opacity(0.75),
            )
          else if (!(status.value?.isOnline ?? false) &&
              account.value?.profile.lastSeenAt != null)
            Flexible(
              child: Text(
                account.value!.profile.lastSeenAt!.formatRelative(context),
              ).opacity(0.75),
            ),
        ],
      ),
    ).opacity((status.value?.isCustomized ?? false) ? 1 : 0.85);
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Symbols.circle,
          fill: 1,
          color: status.isOnline ? Colors.green : Colors.grey,
          size: 14,
        ).padding(right: 4),
        Flexible(
          child: Text(
            status.label,
            style: style,
            maxLines: maxLines,
            overflow: overflow,
          ).fontSize(13),
        ),
      ],
    );
  }
}
