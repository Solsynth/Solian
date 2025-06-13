import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/user.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/account/profile.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/status_creation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'status.g.dart';

@riverpod
Future<SnAccountStatus?> accountStatus(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get('/accounts/$uname/statuses');
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
      borderRadius: BorderRadius.circular(8),
      child: userStatus.when(
        data:
            (status) =>
                (status?.isCustomized ?? false)
                    ? Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: AccountStatusWidget(uname: uname),
                    )
                    : Padding(
                      padding:
                          padding ??
                          EdgeInsets.symmetric(horizontal: 27, vertical: 4),
                      child: Row(
                        spacing: 4,
                        children: [
                          Icon(Symbols.keyboard_arrow_up),
                          Text('statusCreateHint').tr(),
                        ],
                      ),
                    ).opacity(0.85),
        error:
            (error, _) => Padding(
              padding:
                  padding ?? EdgeInsets.symmetric(horizontal: 26, vertical: 4),
              child: Row(
                spacing: 4,
                children: [Icon(Symbols.close), Text('Error: $error')],
              ),
            ).opacity(0.85),
        loading:
            () => Padding(
              padding:
                  padding ?? EdgeInsets.symmetric(horizontal: 26, vertical: 4),
              child: Row(
                spacing: 4,
                children: [Icon(Symbols.more_vert), Text('loading').tr()],
              ),
            ).opacity(0.85),
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder:
              (context) => AccountStatusCreationSheet(
                initialStatus:
                    (userStatus.value?.isCustomized ?? false)
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
    final status = ref.watch(accountStatusProvider(uname));
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
            Text(status.value?.label ?? 'unknown'.tr())
          else
            Text((status.value?.label ?? 'offline').toLowerCase()).tr(),
          if (!(status.value?.isOnline ?? false) &&
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
