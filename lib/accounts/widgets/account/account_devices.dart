import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/services/udid.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/shared/widgets/info_row.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

part 'account_devices.g.dart';

@riverpod
Future<PaginatedResult<SnAuthDeviceWithSession>> authDevices(Ref ref) async {
  final padlockApi = ref.watch(solarNetworkClientProvider).padlock;
  final currentId = await getUdid();
  final resp = await padlockApi.getDevices();
  return PaginatedResult(
    items: resp.items.map((ele) {
      return ele.copyWith(isCurrent: ele.deviceId == currentId);
    }).toList(),
    totalCount: resp.totalCount,
    hasMore: resp.hasMore,
    cursor: resp.cursor,
  );
}

@riverpod
Future<PaginatedResult<SnAuthSession>> authSessions(
  Ref ref, {
  int? type,
}) async {
  final padlockApi = ref.watch(solarNetworkClientProvider).padlock;
  return padlockApi.getSessions(type: type);
}

@riverpod
class SessionTypeFilter extends _$SessionTypeFilter {
  @override
  int? build() => null;

  void setType(int? type) {
    state = type;
  }
}

class _DeviceCard extends StatefulWidget {
  final SnAuthDeviceWithSession device;
  final Function(String) updateDeviceLabel;
  final Function(String) logoutDevice;
  final Function(String) logoutSession;

  const _DeviceCard({
    required this.device,
    required this.updateDeviceLabel,
    required this.logoutDevice,
    required this.logoutSession,
  });

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(switch (widget.device.platform) {
                    0 => Icons.device_unknown,
                    1 => Icons.web,
                    2 => Icons.phone_iphone,
                    3 => Icons.phone_android,
                    4 => Icons.laptop_mac,
                    5 => Icons.window,
                    6 => Icons.computer,
                    _ => Icons.device_unknown,
                  }, color: colorScheme.onPrimaryContainer),
                ),
                Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.device.deviceLabel ??
                                  widget.device.deviceName,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.device.isCurrent) ...[
                            Gap(8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'authDeviceCurrent'.tr(),
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.device.sessions.isNotEmpty)
                        Text(
                          'lastActiveAt'.tr(
                            args: [
                              widget.device.sessions.first.createdAt
                                  .formatSystem(),
                            ],
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isWideScreen(context))
                      IconButton(
                        icon: Icon(Icons.edit),
                        tooltip: 'authDeviceEditLabel'.tr(),
                        onPressed: () =>
                            widget.updateDeviceLabel(widget.device.deviceId),
                      ),
                    if (!widget.device.isCurrent && isWideScreen(context))
                      IconButton(
                        icon: Icon(Icons.logout),
                        tooltip: 'authDeviceLogout'.tr(),
                        onPressed: () =>
                            widget.logoutDevice(widget.device.deviceId),
                      ),
                  ],
                ),
              ],
            ),
            if (widget.device.sessions.isNotEmpty) ...[
              Gap(12),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.key,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      Gap(8),
                      Text(
                        '${widget.device.sessions.length} ${'sessions'.tr()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Spacer(),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ).padding(horizontal: 4),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                clipBehavior: Clip.hardEdge,
                child: _isExpanded ? Column(
                  children: [
                    const Gap(8),
                    Card.outlined(
                      child: Column(
                        children: [
                          ...widget.device.sessions.map(
                            (session) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          session.userAgent ?? 'unknown'.tr(),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${session.ipAddress ?? 'unknown'.tr()} • ${session.location?.city ?? 'unknown'.tr()}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!session.isCurrent)
                                    IconButton(
                                      icon: const Icon(Icons.logout, size: 20),
                                      tooltip: 'authSessionLogout'.tr(),
                                      onPressed: () =>
                                          widget.logoutSession(session.id),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).padding(left: 16, right: 8, vertical: 8),
                    ),
                  ],
                ) : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SessionListTile extends StatelessWidget {
  final SnAuthSession session;
  final Function(String) logoutSession;

  const _SessionListTile({required this.session, required this.logoutSession});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: session.isCurrent
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.key,
                    color: session.isCurrent
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              session.label ??
                                  session.userAgent ??
                                  'unknown'.tr(),
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (session.isCurrent) ...[
                            Gap(8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'authCurrentSession'.tr(),
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'lastActiveAt'.tr(
                          args: [
                            session.lastGrantedAt.toLocal().formatSystem(),
                          ],
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!session.isCurrent)
                  IconButton(
                    icon: Icon(Icons.logout),
                    tooltip: 'authSessionLogout'.tr(),
                    onPressed: () => logoutSession(session.id),
                  ),
              ],
            ),
            Gap(12),
            InfoRow(
              label: 'createdAt'.tr(
                args: [session.createdAt.toLocal().formatSystem()],
              ),
              icon: Symbols.join,
            ),
            Gap(4),
            InfoRow(
              label:
                  '${'location'.tr()} ${session.location?.city ?? 'unknown'.tr()}',
              icon: Symbols.pin_drop,
            ),
            Gap(4),
            InfoRow(
              label:
                  '${'ipAddress'.tr()} ${session.ipAddress ?? 'unknown'.tr()}',
              icon: Symbols.dns,
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSessionSheet extends HookConsumerWidget {
  const AccountSessionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authDevices = ref.watch(authDevicesProvider);
    final sessionType = ref.watch(sessionTypeFilterProvider);
    final authSessions = ref.watch(authSessionsProvider(type: sessionType));

    void logoutDevice(String deviceId) async {
      final confirm = await showConfirmAlert(
        'authDeviceLogoutHint'.tr(),
        'authDeviceLogout'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final padlockApi = ref.read(solarNetworkClientProvider).padlock;
        await padlockApi.revokeDevice(deviceId);
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
        final padlockApi = ref.read(solarNetworkClientProvider).padlock;
        await padlockApi.revokeSession(sessionId);
        ref.invalidate(authSessionsProvider);
        ref.invalidate(authDevicesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void logoutAllOtherSessions() async {
      final confirm = await showConfirmAlert(
        'authLogoutAllOtherSessionsHint'.tr(),
        'authLogoutAllOtherSessions'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final padlockApi = ref.read(solarNetworkClientProvider).padlock;
        await padlockApi.revokeAllOtherSessions();
        ref.invalidate(authSessionsProvider);
        ref.invalidate(authDevicesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void updateDeviceLabel(String deviceId) async {
      final controller = TextEditingController();
      final label = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('authDeviceLabelTitle'.tr()),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'authDeviceLabelHint'.tr(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('confirm'.tr()),
            ),
          ],
        ),
      );
      if (label == null || label.isEmpty || !context.mounted) return;
      try {
        final padlockApi = ref.read(solarNetworkClientProvider).padlock;
        await padlockApi.updateDeviceLabel(deviceId, label);
        ref.invalidate(authDevicesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    final wideScreen = isWideScreen(context);

    return SheetScaffold(
      titleText: 'authSessions'.tr(),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.devices, size: 18),
                      Gap(8),
                      Text('authDevicesTab'.tr()),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.key, size: 18),
                      Gap(8),
                      Text('authSessionsTab'.tr()),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _DevicesTab(
                    authDevices: authDevices,
                    wideScreen: wideScreen,
                    logoutDevice: logoutDevice,
                    updateDeviceLabel: updateDeviceLabel,
                    logoutSession: logoutSession,
                    ref: ref,
                  ),
                  _SessionsTab(
                    authSessions: authSessions,
                    logoutSession: logoutSession,
                    logoutAllOtherSessions: logoutAllOtherSessions,
                    ref: ref,
                    selectedType: sessionType,
                    onTypeChanged: (type) => ref
                        .read(sessionTypeFilterProvider.notifier)
                        .setType(type),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevicesTab extends StatelessWidget {
  final AsyncValue<PaginatedResult<SnAuthDeviceWithSession>> authDevices;
  final bool wideScreen;
  final Function(String) logoutDevice;
  final Function(String) updateDeviceLabel;
  final Function(String) logoutSession;
  final WidgetRef ref;

  const _DevicesTab({
    required this.authDevices,
    required this.wideScreen,
    required this.logoutDevice,
    required this.updateDeviceLabel,
    required this.logoutSession,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return authDevices.when(
      data: (data) => ExtendedRefreshIndicator(
        onRefresh: () => Future.sync(() => ref.invalidate(authDevicesProvider)),
        child: data.items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.devices_other,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Gap(16),
                    Text(
                      'dataEmpty'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.only(bottom: 16, top: 8),
                itemCount: data.items.length,
                itemBuilder: (context, index) {
                  final device = data.items[index];
                  if (!wideScreen) {
                    return Dismissible(
                      key: Key('device-${device.id}'),
                      direction: device.isCurrent
                          ? DismissDirection.none
                          : DismissDirection.horizontal,
                      background: Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Theme.of(context).colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
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
                              final padlockApi = ref
                                  .read(solarNetworkClientProvider)
                                  .padlock;
                              await padlockApi.revokeDevice(device.deviceId);
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
                      child: _DeviceCard(
                        device: device,
                        updateDeviceLabel: updateDeviceLabel,
                        logoutDevice: logoutDevice,
                        logoutSession: logoutSession,
                      ),
                    );
                  }
                  return _DeviceCard(
                    device: device,
                    updateDeviceLabel: updateDeviceLabel,
                    logoutDevice: logoutDevice,
                    logoutSession: logoutSession,
                  );
                },
              ),
      ),
      error: (err, _) => ResponseErrorWidget(
        error: err,
        onRetry: () => ref.invalidate(authDevicesProvider),
      ),
      loading: () => ResponseLoadingWidget(),
    );
  }
}

class _SessionsTab extends StatelessWidget {
  final AsyncValue<PaginatedResult<SnAuthSession>> authSessions;
  final Function(String) logoutSession;
  final Function() logoutAllOtherSessions;
  final WidgetRef ref;
  final int? selectedType;
  final Function(int?) onTypeChanged;

  const _SessionsTab({
    required this.authSessions,
    required this.logoutSession,
    required this.logoutAllOtherSessions,
    required this.ref,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return authSessions.when(
      data: (data) => Column(
        children: [
          if (data.items.where((s) => !s.isCurrent).isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: logoutAllOtherSessions,
                icon: Icon(Icons.logout),
                label: Text('authLogoutAllOtherSessions'.tr()),
              ),
            ).padding(horizontal: 16, top: 16, bottom: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: Text('all'.tr()),
                  selected: selectedType == null,
                  onSelected: (_) => onTypeChanged(null),
                ),
                FilterChip(
                  label: Text('sessionTypeLogin'.tr()),
                  selected: selectedType == 0,
                  onSelected: (_) => onTypeChanged(0),
                ),
                FilterChip(
                  label: Text('sessionTypeOAuth'.tr()),
                  selected: selectedType == 1,
                  onSelected: (_) => onTypeChanged(1),
                ),
                FilterChip(
                  label: Text('sessionTypeOidc'.tr()),
                  selected: selectedType == 2,
                  onSelected: (_) => onTypeChanged(2),
                ),
              ],
            ),
          ),
          Expanded(
            child: ExtendedRefreshIndicator(
              onRefresh: () =>
                  Future.sync(() => ref.invalidate(authSessionsProvider)),
              child: data.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.key_off,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          Gap(16),
                          Text(
                            'dataEmpty'.tr(),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 16),
                      itemCount: data.items.length,
                      itemBuilder: (context, index) {
                        final session = data.items[index];
                        return _SessionListTile(
                          session: session,
                          logoutSession: logoutSession,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      error: (err, _) => ResponseErrorWidget(
        error: err,
        onRetry: () => ref.invalidate(authSessionsProvider),
      ),
      loading: () => ResponseLoadingWidget(),
    );
  }
}
