import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/services/udid.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/shared/widgets/info_row.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';

part 'account_devices.g.dart';

@riverpod
Future<List<SnAuthDeviceWithSession>> authDevices(Ref ref) async {
  final resp = await ref
      .watch(apiClientProvider)
      .get('/pass/accounts/me/devices');
  final currentId = await getUdid();
  final data = resp.data.map<SnAuthDeviceWithSession>((e) {
    final ele = SnAuthDeviceWithSession.fromJson(e);
    return ele.copyWith(isCurrent: ele.deviceId == currentId);
  }).toList();
  return data;
}

class _DeviceListTile extends StatelessWidget {
  final SnAuthDeviceWithSession device;
  final Function(String) updateDeviceLabel;
  final Function(String) logoutDevice;
  final Function(String) logoutSession;

  const _DeviceListTile({
    required this.device,
    required this.updateDeviceLabel,
    required this.logoutDevice,
    required this.logoutSession,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        spacing: 8,
        children: [
          Flexible(child: Text(device.deviceLabel ?? device.deviceName)),
          if (device.isCurrent)
            Row(
              children: [
                Badge(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  label: Text(
                    'authDeviceCurrent'.tr(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (device.sessions.isNotEmpty)
            Text(
              'lastActiveAt'.tr(
                args: [device.sessions.first.createdAt.formatSystem()],
              ),
            ),
        ],
      ),
      leading: Icon(switch (device.platform) {
        0 => Icons.device_unknown, // Unidentified
        1 => Icons.web, // Web
        2 => Icons.phone_iphone, // iOS
        3 => Icons.phone_android, // Android
        4 => Icons.laptop_mac, // macOS
        5 => Icons.window, // Windows
        6 => Icons.computer, // Linux
        _ => Icons.device_unknown, // fallback
      }).padding(top: 4),
      trailing: isWideScreen(context)
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  tooltip: 'authDeviceEditLabel'.tr(),
                  onPressed: () => updateDeviceLabel(device.deviceId),
                ),
                if (!device.isCurrent)
                  IconButton(
                    icon: Icon(Icons.logout),
                    tooltip: 'authDeviceLogout'.tr(),
                    onPressed: () => logoutDevice(device.deviceId),
                  ),
              ],
            )
          : null,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('authDeviceChallenges'.tr()),
        ),
        ...device.sessions
            .map(
              (session) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        InfoRow(
                          label: 'createdAt'.tr(
                            args: [session.createdAt.toLocal().formatSystem()],
                          ),
                          icon: Symbols.join,
                        ),
                        InfoRow(
                          label: 'lastActiveAt'.tr(
                            args: [
                              session.lastGrantedAt.toLocal().formatSystem(),
                            ],
                          ),
                          icon: Symbols.refresh_rounded,
                        ),
                        InfoRow(
                          label:
                              '${'location'.tr()} ${session.location?.city ?? 'unknown'.tr()}',
                          icon: Symbols.pin_drop,
                        ),
                        InfoRow(
                          label:
                              '${'ipAddress'.tr()} ${session.ipAddress ?? 'unknown'.tr()}',
                          icon: Symbols.dns,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout),
                    tooltip: 'authSessionLogout'.tr(),
                    onPressed: () => logoutSession(session.id),
                  ),
                  const Gap(4),
                ],
              ).padding(horizontal: 20, vertical: 8),
            )
            .expand((element) => [element, const Divider(height: 1)])
            .toList()
          ..removeLast(),
      ],
    );
  }
}

class AccountSessionSheet extends HookConsumerWidget {
  const AccountSessionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authDevices = ref.watch(authDevicesProvider);

    void logoutDevice(String sessionId) async {
      final confirm = await showConfirmAlert(
        'authDeviceLogoutHint'.tr(),
        'authDeviceLogout'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.delete('/pass/accounts/me/devices/$sessionId');
        ref.invalidate(authDevicesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void logoutSession(String sessionId) async {
      final confirm = await showConfirmAlert(
        'authSessionLogoutHint'.tr(),
        'authSessionLogout'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.delete('/pass/accounts/me/sessions/$sessionId');
        ref.invalidate(authDevicesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void updateDeviceLabel(String sessionId) async {
      final controller = TextEditingController();
      final label = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('authDeviceLabelTitle'.tr()),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              hintText: 'authDeviceLabelHint'.tr(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('confirm'.tr()),
            ),
          ],
        ),
      );
      if (label == null || label.isEmpty || !context.mounted) return;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.patch(
          '/pass/accounts/me/devices/$sessionId/label',
          data: jsonEncode(label),
        );
        ref.invalidate(authDevicesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    final wideScreen = isWideScreen(context);

    return SheetScaffold(
      titleText: 'authSessions'.tr(),
      child: Column(
        children: [
          if (!wideScreen)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const Icon(Symbols.info, size: 16).padding(top: 2),
                  Flexible(
                    child: Text(
                      'authDeviceHint'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: authDevices.when(
              data: (data) => ExtendedRefreshIndicator(
                onRefresh: () =>
                    Future.sync(() => ref.invalidate(authDevicesProvider)),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final device = data[index];
                    if (wideScreen) {
                      return _DeviceListTile(
                        device: device,
                        updateDeviceLabel: updateDeviceLabel,
                        logoutDevice: logoutDevice,
                        logoutSession: logoutSession,
                      );
                    } else {
                      return Dismissible(
                        key: Key('device-${device.id}'),
                        direction: device.isCurrent
                            ? DismissDirection.startToEnd
                            : DismissDirection.horizontal,
                        background: Container(
                          color: Colors.blue,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.edit, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.logout, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            updateDeviceLabel(device.deviceId);
                            return false;
                          } else {
                            final confirm = await showConfirmAlert(
                              'authDeviceLogoutHint'.tr(),
                              'authDeviceLogout'.tr(),
                              isDanger: true,
                            );
                            if (confirm && context.mounted) {
                              try {
                                showLoadingModal(context);
                                final apiClient = ref.watch(apiClientProvider);
                                await apiClient.delete(
                                  '/pass/accounts/me/devices/${device.deviceId}',
                                );
                                ref.invalidate(authDevicesProvider);
                              } catch (err) {
                                showErrorAlert(err);
                              } finally {
                                if (context.mounted) {
                                  hideLoadingModal(context);
                                }
                              }
                            }
                            return confirm;
                          }
                        },
                        child: _DeviceListTile(
                          device: device,
                          updateDeviceLabel: updateDeviceLabel,
                          logoutDevice: logoutDevice,
                          logoutSession: logoutSession,
                        ),
                      );
                    }
                  },
                ),
              ),
              error: (err, _) => ResponseErrorWidget(
                error: err,
                onRetry: () => ref.invalidate(authDevicesProvider),
              ),
              loading: () => ResponseLoadingWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
