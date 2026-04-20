import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
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
import 'package:latlong2/latlong.dart' as latlong;
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

/// Provider for root sessions only (sessions without parent or with children)
@riverpod
Future<PaginatedResult<SnAuthSession>> authSessions(
  Ref ref, {
  int? type,
}) async {
  final padlockApi = ref.watch(solarNetworkClientProvider).padlock;
  // Get only root sessions (exclude children for tree view starting points)
  return padlockApi.getSessions(type: type, includeChildren: false);
}

/// Provider for child sessions of a specific parent session
@riverpod
Future<List<SnAuthSession>> sessionChildren(Ref ref, String parentId) async {
  final padlockApi = ref.watch(solarNetworkClientProvider).padlock;
  final result = await padlockApi.getSessionChildren(parentId);
  return result.items;
}

@riverpod
class SessionTypeFilter extends _$SessionTypeFilter {
  @override
  int? build() => null;

  void setType(int? type) {
    state = type;
  }
}

/// Provider to track expanded sessions
@riverpod
class ExpandedSessions extends _$ExpandedSessions {
  @override
  Set<String> build() => {};

  void toggle(String sessionId) {
    if (state.contains(sessionId)) {
      state = {...state}..remove(sessionId);
    } else {
      state = {...state}..add(sessionId);
    }
  }

  bool isExpanded(String sessionId) => state.contains(sessionId);
}

class _DeviceCard extends StatelessWidget {
  final SnAuthDeviceWithSession device;
  final VoidCallback onTap;

  const _DeviceCard({required this.device, required this.onTap});

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                    child: Icon(switch (device.platform) {
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
                                device.deviceLabel ?? device.deviceName,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (device.isCurrent) ...[
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
                            if (device.sessions.isNotEmpty) ...[
                              Gap(8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Symbols.key,
                                      size: 12,
                                      color: colorScheme.onSecondaryContainer,
                                    ),
                                    Gap(4),
                                    Text(
                                      '${device.sessions.length}',
                                      style: TextStyle(
                                        color: colorScheme.onSecondaryContainer,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (device.sessions.isNotEmpty)
                          Text(
                            'lastActiveAt'.tr(
                              args: [
                                device.sessions.first.createdAt.formatSystem(),
                              ],
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
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

/// Device detail sheet with map and session list
class _DeviceDetailSheet extends HookConsumerWidget {
  final SnAuthDeviceWithSession device;

  const _DeviceDetailSheet({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mapController = useMemoized(() => MapController());

    // Get sessions with location data
    final sessionsWithLocation = device.sessions
        .where(
          (s) => s.location?.latitude != null && s.location?.longitude != null,
        )
        .toList();

    // Calculate map center
    final center = useMemoized(() {
      if (sessionsWithLocation.isEmpty) {
        return latlong.LatLng(0, 0);
      }
      final latitudes = sessionsWithLocation.map((s) => s.location!.latitude!);
      final longitudes = sessionsWithLocation.map(
        (s) => s.location!.longitude!,
      );
      return latlong.LatLng(
        latitudes.reduce((a, b) => a + b) / latitudes.length,
        longitudes.reduce((a, b) => a + b) / longitudes.length,
      );
    }, [sessionsWithLocation]);

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
        // Invalidate providers to refresh data
        ref.invalidate(authDevicesProvider);
        ref.invalidate(authSessionsProvider);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void logoutDevice() async {
      final confirm = await showConfirmAlert(
        'authDeviceLogoutHint'.tr(),
        'authDeviceLogout'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final padlockApi = ref.read(solarNetworkClientProvider).padlock;
        await padlockApi.revokeDevice(device.deviceId);
        ref.invalidate(authDevicesProvider);
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void updateDeviceLabel() async {
      final controller = TextEditingController(text: device.deviceLabel);
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
        await padlockApi.updateDeviceLabel(device.deviceId, label);
        ref.invalidate(authDevicesProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return SheetScaffold(
      titleText: device.deviceLabel ?? device.deviceName,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'authDeviceEditLabel'.tr(),
          onPressed: updateDeviceLabel,
        ),
        if (!device.isCurrent)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'authDeviceLogout'.tr(),
            onPressed: logoutDevice,
          ),
      ],
      child: CustomScrollView(
        slivers: [
          // Map section
          if (sessionsWithLocation.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 3,
                        interactionOptions: const InteractionOptions(
                          flags:
                              InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                        ),
                      ),
                      children: [
                        TileLayer(
                          retinaMode: true,
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'Solian/1.0 (+https://solian.app, contact: lily@solsynth.dev)',
                        ),
                        RichAttributionWidget(
                          popupInitialDisplayDuration: const Duration(
                            seconds: 0,
                          ),
                          animationConfig: const ScaleRAWA(),
                          showFlutterMapAttribution: false,
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                              onTap: () {},
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: sessionsWithLocation.map((session) {
                            final loc = session.location!;
                            return Marker(
                              point: latlong.LatLng(
                                loc.latitude!,
                                loc.longitude!,
                              ),
                              width: 48,
                              height: 48,
                              child: _SessionMapPin(
                                session: session,
                                isCurrent: session.isCurrent,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Zoom controls
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'device_zoom_in',
                            onPressed: () => mapController.move(
                              mapController.camera.center,
                              mapController.camera.zoom + 1,
                            ),
                            child: const Icon(Symbols.add),
                          ),
                          const Gap(8),
                          FloatingActionButton.small(
                            heroTag: 'device_zoom_out',
                            onPressed: () => mapController.move(
                              mapController.camera.center,
                              mapController.camera.zoom - 1,
                            ),
                            child: const Icon(Symbols.remove),
                          ),
                        ],
                      ),
                    ),
                    // Session count badge
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.location_on,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const Gap(6),
                            Text(
                              '${sessionsWithLocation.length} ${sessionsWithLocation.length == 1 ? 'location'.tr() : 'locations'.tr()}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.location_off,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const Gap(8),
                      Text(
                        'noLocationData'.tr(),
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          SliverGap(16),

          // Device info section (now scrollable)
          SliverToBoxAdapter(child: _DeviceInfoCard(device: device)),

          // Session list header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                spacing: 8,
                children: [
                  const Icon(Symbols.key, size: 18,),
                  Text(
                    'authSessions'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ).padding(horizontal: 8),
            ),
          ),

          // Session list
          SliverList.builder(
            itemCount: device.sessions.length,
            itemBuilder: (context, index) {
              final session = device.sessions[index];
              return _SessionListItem(
                session: session,
                onLogout: () => logoutSession(session.id),
              );
            },
          ),

          // Bottom padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}

/// Map pin widget for a session
class _SessionMapPin extends StatelessWidget {
  final SnAuthSession session;
  final bool isCurrent;

  const _SessionMapPin({required this.session, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use high contrast colors
    final color = isCurrent ? colorScheme.primary : colorScheme.tertiary;
    final onColor = isCurrent ? colorScheme.onPrimary : colorScheme.onTertiary;

    return SizedBox(
      width: 80,
      height: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label with high contrast background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              session.location?.city ?? 'Unknown',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(3),
          // Pin marker with shadow for depth
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getSessionTypeIcon(session.type),
              color: onColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSessionTypeIcon(int type) {
    return switch (type) {
      0 => Symbols.key, // Login
      1 => Symbols.link, // OAuth
      2 => Symbols.account_circle, // OIDC
      _ => Symbols.key,
    };
  }
}

/// Device info card showing detailed device information
class _DeviceInfoCard extends StatelessWidget {
  final SnAuthDeviceWithSession device;

  const _DeviceInfoCard({required this.device});

  String _getPlatformLabel(int platform) {
    return switch (platform) {
      0 => 'Unknown',
      1 => 'Web',
      2 => 'iOS',
      3 => 'Android',
      4 => 'macOS',
      5 => 'Windows',
      6 => 'Linux',
      _ => 'Unknown',
    };
  }

  IconData _getPlatformIcon(int platform) {
    return switch (platform) {
      0 => Symbols.device_unknown,
      1 => Symbols.web,
      2 => Symbols.phone_iphone,
      3 => Symbols.phone_android,
      4 => Symbols.laptop_mac,
      5 => Symbols.window,
      6 => Symbols.computer,
      _ => Symbols.device_unknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform and device name header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPlatformIcon(device.platform),
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getPlatformLabel(device.platform),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            // Device details grid
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Symbols.devices,
                    label: 'deviceId'.tr(),
                    value: device.deviceId.substring(
                      0,
                      device.deviceId.length > 12 ? 12 : device.deviceId.length,
                    ),
                    valueTooltip: device.deviceId,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _InfoTile(
                    icon: Symbols.key,
                    label: 'activeSessions'.tr(),
                    value: '${device.sessions.length}',
                  ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Symbols.calendar_today,
                    label: 'firstSeen'.tr(),
                    value: device.sessions.isNotEmpty
                        ? device.sessions.first.createdAt.formatSystem()
                        : '-',
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _InfoTile(
                    icon: Symbols.update,
                    label: 'lastActive'.tr(),
                    value: device.sessions.isNotEmpty
                        ? device.sessions
                              .map((s) => s.lastGrantedAt)
                              .reduce((a, b) => a.isAfter(b) ? a : b)
                              .formatSystem()
                        : '-',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Info tile for device info card - Material Design 3
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? valueTooltip;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
                const Gap(8),
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Gap(4),
            Tooltip(
              message: valueTooltip ?? value,
              child: Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Session list item for device detail sheet
class _SessionListItem extends StatelessWidget {
  final SnAuthSession session;
  final VoidCallback onLogout;

  const _SessionListItem({required this.session, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: session.isCurrent
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSessionTypeIcon(session.type),
                    color: session.isCurrent
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 18,
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
                          if ((session.childrenCount ?? 0) > 0) ...[
                            Gap(8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${session.childrenCount}',
                                style: TextStyle(
                                  color: colorScheme.onSecondaryContainer,
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
                    onPressed: onLogout,
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

  IconData _getSessionTypeIcon(int type) {
    return switch (type) {
      0 => Symbols.key, // Login
      1 => Symbols.link, // OAuth
      2 => Symbols.account_circle, // OIDC
      _ => Symbols.key,
    };
  }
}

/// Widget to display a session with expandable children
class _SessionTreeTile extends HookConsumerWidget {
  final SnAuthSession session;
  final Function(String) logoutSession;
  final int depth;

  const _SessionTreeTile({
    required this.session,
    required this.logoutSession,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExpanded = ref.watch(expandedSessionsProvider).contains(session.id);
    final hasChildren = (session.childrenCount ?? 0) > 0;
    final childrenAsync = hasChildren && isExpanded
        ? ref.watch(sessionChildrenProvider(session.id))
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(
            left: 16 + (depth * 24),
            right: 16,
            top: 6,
            bottom: 6,
          ),
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
                    if (hasChildren)
                      GestureDetector(
                        onTap: () => ref
                            .read(expandedSessionsProvider.notifier)
                            .toggle(session.id),
                        child: AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      SizedBox(width: 20),
                    Gap(8),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: session.isCurrent
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSessionTypeIcon(session.type),
                        color: session.isCurrent
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        size: 18,
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
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
                              if (hasChildren) ...[
                                Gap(8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${session.childrenCount}',
                                    style: TextStyle(
                                      color: colorScheme.onSecondaryContainer,
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
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
        ),
        // Child sessions
        if (hasChildren && isExpanded && childrenAsync != null)
          childrenAsync.when(
            data: (children) => Column(
              children: children
                  .map(
                    (child) => _SessionTreeTile(
                      session: child,
                      logoutSession: logoutSession,
                      depth: depth + 1,
                    ),
                  )
                  .toList(),
            ),
            loading: () => Padding(
              padding: EdgeInsets.only(left: 16 + (depth * 24) + 48),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, _) => Padding(
              padding: EdgeInsets.only(left: 16 + (depth * 24) + 48),
              child: Text(
                'Error loading children',
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  IconData _getSessionTypeIcon(int type) {
    return switch (type) {
      0 => Symbols.key, // Login
      1 => Symbols.link, // OAuth
      2 => Symbols.account_circle, // OIDC
      _ => Symbols.key,
    };
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
        // Invalidate all session-related providers
        ref.invalidate(authSessionsProvider);
        ref.invalidate(authDevicesProvider);
        // Also invalidate expanded session children
        ref.invalidate(sessionChildrenProvider(sessionId));
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
        // Clear expanded sessions since they might be invalidated
        ref.invalidate(authSessionsProvider);
        ref.invalidate(authDevicesProvider);
        ref.invalidate(expandedSessionsProvider);
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

    void showDeviceDetail(SnAuthDeviceWithSession device) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => _DeviceDetailSheet(device: device),
      );
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
                    onDeviceTap: showDeviceDetail,
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
  final Function(SnAuthDeviceWithSession) onDeviceTap;
  final WidgetRef ref;

  const _DevicesTab({
    required this.authDevices,
    required this.wideScreen,
    required this.logoutDevice,
    required this.updateDeviceLabel,
    required this.logoutSession,
    required this.onDeviceTap,
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
                        onTap: () => onDeviceTap(device),
                      ),
                    );
                  }
                  return _DeviceCard(
                    device: device,
                    onTap: () => onDeviceTap(device),
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
          // Filter chips and logout all button in the same row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                        FilterChip(
                          label: Text('sessionTypeApiKey'.tr()),
                          selected: selectedType == 3,
                          onSelected: (_) => onTypeChanged(3),
                        ),
                      ],
                    ),
                  ),
                ),
                if (data.items.where((s) => !s.isCurrent).isNotEmpty) ...[
                  const Gap(12),
                  FilledButton.icon(
                    onPressed: logoutAllOtherSessions,
                    icon: const Icon(Icons.logout),
                    label: Text('authLogoutAllOtherSessions'.tr()),
                  ),
                ],
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
                        // Use tree tile for sessions with potential children
                        return _SessionTreeTile(
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
