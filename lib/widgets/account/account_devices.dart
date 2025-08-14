import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/account.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/responsive.dart';
import 'package:island/services/udid.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/response.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'account_devices.g.dart';

@riverpod
Future<List<SnAuthDeviceWithChallenge>> authDevices(Ref ref) async {
  final resp = await ref
      .watch(apiClientProvider)
      .get('/id/accounts/me/devices');
  final currentId = await getUdid();
  final data =
      resp.data.map<SnAuthDeviceWithChallenge>((e) {
        final ele = SnAuthDeviceWithChallenge.fromJson(e);
        return ele.copyWith(isCurrent: ele.deviceId == currentId);
      }).toList();
  return data;
}

class _DeviceListTile extends StatelessWidget {
  final SnAuthDeviceWithChallenge device;
  final Function(String) updateDeviceLabel;
  final Function(String) logoutDevice;

  const _DeviceListTile({
    required this.device,
    required this.updateDeviceLabel,
    required this.logoutDevice,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'lastActiveAt'.tr(
              args: [
                DateFormat().format(
                  device.challenges.first.createdAt.toLocal(),
                ),
              ],
            ),
          ),
          Text(device.challenges.first.ipAddress),
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
            ).padding(top: 4),
        ],
      ),
      title: Text(device.deviceLabel ?? device.deviceName),
      trailing:
          isWideScreen(context)
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
      );
      if (!confirm || !context.mounted) return;
      try {
        final apiClient = ref.watch(apiClientProvider);
        await apiClient.delete('/id/accounts/me/devices/$sessionId');
        ref.invalidate(authDevicesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void updateDeviceLabel(String sessionId) async {
      final controller = TextEditingController();
      final label = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
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
          '/id/accounts/me/devices/$sessionId/label',
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
      child: authDevices.when(
        data:
            (data) => RefreshIndicator(
              onRefresh:
                  () => Future.sync(() => ref.invalidate(authDevicesProvider)),
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
                    );
                  } else {
                    return Dismissible(
                      key: Key('device-${device.id}'),
                      direction:
                          device.isCurrent
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
                          );
                          if (confirm && context.mounted) {
                            logoutDevice(device.deviceId);
                          }
                          return false; // Don't dismiss
                        }
                      },
                      child: _DeviceListTile(
                        device: device,
                        updateDeviceLabel: updateDeviceLabel,
                        logoutDevice: logoutDevice,
                      ),
                    );
                  }
                },
              ),
            ),
        error:
            (err, _) => ResponseErrorWidget(
              error: err,
              onRetry: () => ref.invalidate(authDevicesProvider),
            ),
        loading: () => ResponseLoadingWidget(),
      ),
    );
  }
}
