import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/services/udid.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/hooks/material_hooks.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

part 'account_devices.g.dart';

class AuthDevicesNotifier
    extends AsyncNotifier<PaginationState<SnAuthDeviceWithSession>>
    with AsyncPaginationController<SnAuthDeviceWithSession> {
  static const int pageSize = 50;

  @override
  FutureOr<PaginationState<SnAuthDeviceWithSession>> build() async {
    final items = await fetch();
    final resolvedTotal = totalCount;
    final more = resolvedTotal == null
        ? items.isNotEmpty
        : items.length < resolvedTotal;
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: resolvedTotal,
      hasMore: more,
      cursor: null,
    );
  }

  @override
  Future<List<SnAuthDeviceWithSession>> fetch() async {
    final stargateApi = ref.read(solarNetworkClientProvider).stargate;
    final currentId = await getUdid();
    final result = await stargateApi.getDevices(
      offset: fetchedCount,
      take: pageSize,
    );
    totalCount = result.totalCount;
    return result.items.map((ele) {
      return ele.copyWith(isCurrent: ele.deviceId == currentId);
    }).toList();
  }
}

final authDevicesProvider = AsyncNotifierProvider.autoDispose(
  AuthDevicesNotifier.new,
);

/// Provider for root sessions only (sessions without parent or with children)
@riverpod
Future<PaginatedResult<SnAuthSession>> authSessions(
  Ref ref, {
  int? type,
}) async {
  final stargateApi = ref.watch(solarNetworkClientProvider).stargate;
  // Get only root sessions (exclude children for tree view starting points)
  return stargateApi.getSessions(type: type, includeChildren: false);
}

/// Provider for child sessions of a specific parent session
@riverpod
Future<List<SnAuthSession>> sessionChildren(Ref ref, String parentId) async {
  final stargateApi = ref.watch(solarNetworkClientProvider).stargate;
  final result = await stargateApi.getSessionChildren(parentId);
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

// ---------------------------------------------------------------------------
// Shared visual grammar
//
// Every credential surface in this file speaks the same sentence:
//
//     <glyph>  <name>                        <status>   <affordance>
//              <meta · meta · meta>
//
// Counts live in the meta line, not in pills; timestamps and addresses are one
// tap away instead of being printed on every row. A grouped surface holds the
// rows and hairlines separate them, so one screen holds many times the
// credentials the old per-item cards did without turning into a wall.
// ---------------------------------------------------------------------------

const double _kRowGutter = 16;
const double _kGroupMaxWidth = 720;

/// Status green that survives both themes.
///
/// The dark scheme sits on a near-black surface where `green.shade800` is
/// invisible, so the ink flips with the brightness while the hue stays put.
Color _liveColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF6FD39A)
        : const Color(0xFF2E7D48);

EdgeInsets _pageGutter(BuildContext context, {double vertical = 0}) {
  final width = MediaQuery.sizeOf(context).width;
  final gutter = width > _kGroupMaxWidth + 40
      ? (width - _kGroupMaxWidth) / 2
      : _kRowGutter;
  return EdgeInsets.symmetric(horizontal: gutter, vertical: vertical);
}

IconData _platformIcon(int platform) {
  return switch (platform) {
    1 => Symbols.web,
    2 => Symbols.phone_iphone,
    3 => Symbols.phone_android,
    4 => Symbols.laptop_mac,
    5 => Symbols.window,
    6 => Symbols.computer,
    _ => Symbols.device_unknown,
  };
}

String _platformLabel(int platform) {
  return switch (platform) {
    1 => 'Web',
    2 => 'iOS',
    3 => 'Android',
    4 => 'macOS',
    5 => 'Windows',
    6 => 'Linux',
    _ => 'Unknown',
  };
}

IconData _sessionTypeIcon(int type) {
  return switch (type) {
    1 => Symbols.link, // OAuth
    2 => Symbols.account_circle, // OIDC
    _ => Symbols.key, // Login
  };
}

/// One segment of a meta line. Emphasis is a token, not a different size:
/// the line keeps its rhythm and only the ink changes.
class _Meta {
  final String text;
  final bool emphasized;

  const _Meta(this.text, {this.emphasized = false});
}

/// `macOS · 3 sessions · active 2h ago` — one quiet line per row.
///
/// Separators are drawn as text so the line can be laid out and ellipsised as
/// a single run; a narrow sheet trims the tail instead of wrapping.
class _MetaLine extends StatelessWidget {
  final List<_Meta> parts;

  const _MetaLine(this.parts);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.35,
    );
    final strong = base?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w600,
    );
    final separator = '  ·  ';

    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) spans.add(TextSpan(text: separator, style: base));
      spans.add(
        TextSpan(
          text: parts[i].text,
          style: parts[i].emphasized ? strong : base,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// A rounded surface that holds a run of rows, separated by hairlines that
/// start where the row text starts rather than at the card edge.
class _GroupBox extends StatelessWidget {
  final List<Widget> children;

  const _GroupBox({required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final last = children.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SolRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != last)
              Divider(
                height: 1,
                thickness: 1,
                indent: 68,
                endIndent: 12,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

/// A labelled section heading inside a scrolling sheet.
class _SectionLabel extends StatelessWidget {
  final String label;
  final String? trailing;

  const _SectionLabel({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    final color = _liveColor(context);
    return Tooltip(
      message: 'online'.tr(),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// The signature of this page: one dot per credential the device holds.
///
/// Reading order is "alive first": online credentials lead, the current one
/// is a filled primary dot with a ring, trusted ones are hollow, and expired
/// or idle ones are the quietest ink. Anything past [max] collapses into
/// `+N`, so a device with forty browser sessions still prints one glyph.
class _SessionDots extends StatelessWidget {
  /// How many dots a row is willing to show before it starts counting.
  static const int _max = 4;

  final List<SnAuthSession> sessions;

  const _SessionDots({required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final idle = colorScheme.outline.withValues(alpha: 0.5);

    int rank(SnAuthSession s) => s.isCurrent ? 0 : (s.isOnline ? 1 : 2);
    final ordered = [...sessions]..sort((a, b) => rank(a).compareTo(rank(b)));
    final shown = ordered.take(_max).toList();
    final overflow = ordered.length - shown.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final session in shown)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _SessionDot(session: session, idle: idle),
          ),
        if (overflow > 0)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              '+$overflow',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}

/// A single credential, in ring-plus-fill rather than four different hues:
/// filled = live, hollow = trusted but idle, faint = idle and untrusted.
class _SessionDot extends StatelessWidget {
  final SnAuthSession session;
  final Color idle;

  const _SessionDot({required this.session, required this.idle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (session.trusted && !session.isCurrent) {
      return Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.tertiary, width: 1.6),
        ),
      );
    }

    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: session.isCurrent
            ? colorScheme.primary
            : session.isOnline
            ? colorScheme.primary.withValues(alpha: 0.45)
            : idle,
        boxShadow: session.isCurrent
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 5,
                ),
              ]
            : null,
      ),
    );
  }
}

/// Field row used inside an expanded credential: label, value, no icon plate.
class _FieldLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FieldLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: colorScheme.outline),
          const Gap(8),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A device as one row: identity, one meta line, one dot cluster.
class _DeviceRow extends StatelessWidget {
  final SnAuthDeviceWithSession device;
  final VoidCallback onTap;

  const _DeviceRow({required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isCurrent = device.isCurrent;
    final name = device.deviceLabel ?? device.deviceName;

    final lastGranted = device.sessions.isEmpty
        ? null
        : device.sessions
              .map((s) => s.lastGrantedAt)
              .reduce((a, b) => a.isAfter(b) ? a : b);

    // The dots below already count the credentials, and the glyph says which
    // platform this is, so the caption spends its slots on what neither can:
    // whether this is the device you are holding, and when it was last used.
    final meta = <_Meta>[
      if (isCurrent) _Meta('authCurrentShort'.tr(), emphasized: true),
      if (lastGranted != null) _Meta(lastGranted.formatRelative(context)),
    ];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_kRowGutter, 14, 8, 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCurrent
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(SolRadius.sm),
              ),
              child: Icon(
                _platformIcon(device.platform),
                size: 20,
                color: isCurrent
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (device.trusted) ...[
                        const Gap(6),
                        Icon(
                          Symbols.verified,
                          size: 14,
                          color: colorScheme.tertiary,
                        ),
                      ],
                      if (device.isOnline) ...[
                        const Gap(6),
                        const _LiveDot(),
                      ],
                    ],
                  ),
                  const Gap(3),
                  Row(
                    children: [
                      Expanded(child: _MetaLine(meta)),
                      if (device.sessions.isNotEmpty) ...[
                        const Gap(8),
                        _SessionDots(sessions: device.sessions),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Gap(4),
            Icon(
              Symbols.chevron_right,
              size: 20,
              color: colorScheme.outline.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

/// One credential. Collapsed it is three lines of information; expanded it
/// adds the provenance fields and the action that kills it.
class _SessionTile extends HookConsumerWidget {
  final SnAuthSession session;
  final void Function(String) logoutSession;
  final int depth;

  /// Whether this credential can expand into child credentials.
  final bool allowChildren;

  const _SessionTile({
    required this.session,
    required this.logoutSession,
    this.depth = 0,
    this.allowChildren = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final childrenExpanded = allowChildren
        ? ref.watch(expandedSessionsProvider).contains(session.id)
        : false;
    final hasChildren = allowChildren && (session.childrenCount ?? 0) > 0;
    final childrenAsync = hasChildren && childrenExpanded
        ? ref.watch(sessionChildrenProvider(session.id))
        : null;

    final detailsExpanded = useState(false);
    final isCurrent = session.isCurrent;
    final location = session.location?.city;

    final title = session.label ?? session.userAgent ?? 'unknown'.tr();
    final chevronTurns = detailsExpanded.value ? 0.5 : 0.0;
    final childTurns = childrenExpanded ? 0.5 : 0.0;

    final meta = <_Meta>[
      if (isCurrent) _Meta('authCurrentSession'.tr(), emphasized: true),
      // Place before recency: where a credential came from is what you scan
      // for when hunting an unknown sign-in; the time is supporting detail.
      if (location != null && location.isNotEmpty) _Meta(location),
      _Meta(session.lastGrantedAt.toLocal().formatRelative(context)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => detailsExpanded.value = !detailsExpanded.value,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              _kRowGutter + depth * 16,
              12,
              8,
              12,
            ),
            child: Row(
              children: [
                if (hasChildren)
                  InkWell(
                    onTap: () => ref
                        .read(expandedSessionsProvider.notifier)
                        .toggle(session.id),
                    borderRadius: BorderRadius.circular(SolRadius.pill),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedRotation(
                        turns: childTurns,
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 180),
                        child: Icon(
                          Symbols.expand_more,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 2),
                const Gap(10),
                Icon(
                  _sessionTypeIcon(session.type),
                  size: 16,
                  color: isCurrent
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (session.trusted) ...[
                            const Gap(6),
                            Icon(
                              Symbols.verified,
                              size: 14,
                              color: colorScheme.tertiary,
                            ),
                          ],
                          if (session.isOnline) ...[
                            const Gap(6),
                            const _LiveDot(),
                          ],
                        ],
                      ),
                      const Gap(3),
                      _MetaLine(meta),
                    ],
                  ),
                ),
                const Gap(8),
                AnimatedRotation(
                  turns: chevronTurns,
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  child: Icon(
                    Symbols.expand_more,
                    size: 20,
                    color: colorScheme.outline.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: detailsExpanded.value
              ? Padding(
                  padding: EdgeInsets.fromLTRB(
                    _kRowGutter + depth * 16 + 28,
                    0,
                    _kRowGutter,
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLine(
                        icon: Symbols.join,
                        label: 'createdAt'.tr(args: ['']).trim(),
                        value: session.createdAt.toLocal().formatSystem(),
                      ),
                      _FieldLine(
                        icon: Symbols.pin_drop,
                        label: 'location'.tr(),
                        value: (location == null || location.isEmpty)
                            ? 'unknown'.tr()
                            : location,
                      ),
                      _FieldLine(
                        icon: Symbols.dns,
                        label: 'ipAddress'.tr(),
                        value: session.ipAddress ?? 'unknown'.tr(),
                      ),
                      if (session.expiredAt != null)
                        _FieldLine(
                          icon: Symbols.schedule,
                          label: 'expiresAt'.tr(),
                          value: session.expiredAt!.toLocal().formatSystem(),
                        ),
                      if (!isCurrent) ...[
                        const Gap(8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => logoutSession(session.id),
                            icon: const Icon(Symbols.logout, size: 18),
                            label: Text('authSessionLogout'.tr()),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        if (hasChildren && childrenExpanded && childrenAsync != null)
          childrenAsync.when(
            // Children stay flat inside the parent's group: an indent rail
            // says "issued by this credential" without nesting another card.
            data: (children) => Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    width: 2,
                  ),
                ),
              ),
              margin: EdgeInsets.only(
                left: _kRowGutter + depth * 16 + 20,
                right: 12,
                bottom: 4,
              ),
              child: Column(
                children: [
                  for (final child in children)
                    _SessionTile(
                      session: child,
                      logoutSession: logoutSession,
                      depth: depth + 1,
                      allowChildren: false,
                    ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.fromLTRB(28, 4, 16, 12),
              child: Text(
                'Error loading children',
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}

/// Device detail sheet: identity first, then the places it signed in from,
/// then the credentials themselves.
class _DeviceDetailSheet extends HookConsumerWidget {
  final SnAuthDeviceWithSession device;

  const _DeviceDetailSheet({required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapController = useMemoized(() => MapController());

    final sessionsWithLocation = device.sessions
        .where(
          (s) => s.location?.latitude != null && s.location?.longitude != null,
        )
        .toList();

    final center = useMemoized(() {
      if (sessionsWithLocation.isEmpty) return latlong.LatLng(0, 0);
      final latitudes = sessionsWithLocation.map((s) => s.location!.latitude!);
      final longitudes = sessionsWithLocation.map(
        (s) => s.location!.longitude!,
      );
      return latlong.LatLng(
        latitudes.reduce((a, b) => a + b) / latitudes.length,
        longitudes.reduce((a, b) => a + b) / longitudes.length,
      );
    }, [sessionsWithLocation]);


    Future<void> logoutSession(String sessionId) async {
      final confirm = await showConfirmAlert(
        'authSessionLogoutHint'.tr(),
        'authSessionLogout'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final stargateApi = ref.read(solarNetworkClientProvider).stargate;
        await withSudoRetry(
          context,
          ref,
          () => stargateApi.revokeSession(sessionId),
        );
        ref.invalidate(authDevicesProvider);
        ref.invalidate(authSessionsProvider);
        if (context.mounted) Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> logoutDevice() async {
      final confirm = await showConfirmAlert(
        'authDeviceLogoutHint'.tr(),
        'authDeviceLogout'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final stargateApi = ref.read(solarNetworkClientProvider).stargate;
        await withSudoRetry(
          context,
          ref,
          () => stargateApi.revokeDevice(device.deviceId),
        );
        ref.invalidate(authDevicesProvider);
        if (context.mounted) Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> updateDeviceLabel() async {
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
        final stargateApi = ref.read(solarNetworkClientProvider).stargate;
        await stargateApi.updateDeviceLabel(device.deviceId, label);
        ref.invalidate(authDevicesProvider);
        if (context.mounted) Navigator.pop(context, true);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    final gutter = _pageGutter(context);

    return SheetScaffold(
      titleText: device.deviceLabel ?? device.deviceName,
      actions: [
        IconButton(
          icon: const Icon(Symbols.edit),
          tooltip: 'authDeviceEditLabel'.tr(),
          onPressed: updateDeviceLabel,
        ),
        if (!device.isCurrent)
          IconButton(
            icon: const Icon(Symbols.logout),
            tooltip: 'authDeviceLogout'.tr(),
            onPressed: logoutDevice,
          ),
      ],
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: gutter.copyWith(top: 4),
            sliver: SliverToBoxAdapter(child: _DeviceHeader(device: device)),
          ),

          // Where this device signed in from. A band, not a hero: the map
          // answers one question and then gets out of the way.
          SliverPadding(
            padding: gutter.copyWith(top: 16),
            sliver: SliverToBoxAdapter(
              child: _LocationBand(
                sessions: sessionsWithLocation,
                mapController: mapController,
                center: center,
              ),
            ),
          ),

          SliverPadding(
            padding: gutter.copyWith(top: 20),
            sliver: SliverToBoxAdapter(
              child: _SectionLabel(
                label: 'authSessions'.tr(),
                trailing: 'authSessionsCount'.plural(device.sessions.length),
              ),
            ),
          ),

          SliverPadding(
            padding: gutter.copyWith(bottom: 24),
            sliver: SliverToBoxAdapter(
              child: device.sessions.isEmpty
                  ? EmptyState(
                      icon: Symbols.key_off,
                      title: 'dataEmpty'.tr(),
                      compact: true,
                    )
                  : _GroupBox(
                      children: [
                        for (final session in device.sessions)
                          _SessionTile(
                            session: session,
                            logoutSession: logoutSession,
                            allowChildren: false,
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Identity block of the detail sheet: what this device is, and how many
/// credentials it is holding right now.
class _DeviceHeader extends StatelessWidget {
  final SnAuthDeviceWithSession device;

  const _DeviceHeader({required this.device});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isCurrent = device.isCurrent;

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isCurrent
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(SolRadius.md),
          ),
          child: Icon(
            _platformIcon(device.platform),
            size: 26,
            color: isCurrent
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      device.deviceName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (device.trusted) ...[
                    const Gap(6),
                    Tooltip(
                      message: 'authTrusted'.tr(),
                      child: Icon(
                        Symbols.verified,
                        size: 16,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(4),
              _MetaLine([
                if (isCurrent)
                  _Meta('authDeviceCurrent'.tr(), emphasized: true),
                _Meta(_platformLabel(device.platform)),
                _Meta('authSessionsCount'.plural(device.sessions.length)),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

/// Recent sign-in locations as a compact map band.
class _LocationBand extends StatelessWidget {
  final List<SnAuthSession> sessions;
  final MapController mapController;
  final latlong.LatLng center;

  const _LocationBand({
    required this.sessions,
    required this.mapController,
    required this.center,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(SolRadius.card),
        ),
        child: Row(
          children: [
            Icon(
              Symbols.location_off,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                'noLocationData'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(SolRadius.card),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 3,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
              ),
              children: [
                TileLayer(
                  retinaMode: true,
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'Solian/1.0 (+https://solian.app, contact: lily@solsynth.dev)',
                ),
                RichAttributionWidget(
                  popupInitialDisplayDuration: const Duration(seconds: 0),
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
                  markers: sessions.map((session) {
                    final loc = session.location!;
                    return Marker(
                      point: latlong.LatLng(loc.latitude!, loc.longitude!),
                      width: 96,
                      height: 54,
                      alignment: Alignment.topCenter,
                      child: _SessionMapPin(
                        session: session,
                        isCurrent: session.isCurrent,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Row(
                children: [
                  _MapButton(
                    icon: Symbols.add,
                    onPressed: () => mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 1,
                    ),
                  ),
                  const Gap(6),
                  _MapButton(
                    icon: Symbols.remove,
                    onPressed: () => mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 1,
                    ),
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

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(SolRadius.pill),
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(SolRadius.pill),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

/// Map pin for a session
class _SessionMapPin extends StatelessWidget {
  final SnAuthSession session;
  final bool isCurrent;

  const _SessionMapPin({required this.session, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isCurrent ? colorScheme.primary : colorScheme.tertiary;
    final onColor = isCurrent ? colorScheme.onPrimary : colorScheme.onTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.inverseSurface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(SolRadius.xs),
          ),
          child: Text(
            session.location?.city ?? 'unknown'.tr(),
            style: TextStyle(
              color: colorScheme.onInverseSurface,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Gap(3),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: colorScheme.surface, width: 2.5),
          ),
          child: Icon(_sessionTypeIcon(session.type), color: onColor, size: 17),
        ),
      ],
    );
  }
}

class AccountSessionSheet extends HookConsumerWidget {
  final int initialIndex;

  const AccountSessionSheet({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authDevices = ref.watch(authDevicesProvider);
    final sessionType = ref.watch(sessionTypeFilterProvider);
    final authSessions = ref.watch(authSessionsProvider(type: sessionType));

    Future<void> logoutSession(String sessionId) async {
      final confirm = await showConfirmAlert(
        'authSessionLogoutHint'.tr(),
        'authSessionLogout'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final stargateApi = ref.read(solarNetworkClientProvider).stargate;
        await withSudoRetry(
          context,
          ref,
          () => stargateApi.revokeSession(sessionId),
        );
        // Invalidate all session-related providers
        ref.invalidate(authSessionsProvider);
        ref.invalidate(authDevicesProvider);
        // Also invalidate expanded session children
        ref.invalidate(sessionChildrenProvider(sessionId));
        if (context.mounted) Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> logoutAllOtherSessions() async {
      final confirm = await showConfirmAlert(
        'authLogoutAllOtherSessionsHint'.tr(),
        'authLogoutAllOtherSessions'.tr(),
        isDanger: true,
      );
      if (!confirm || !context.mounted) return;
      try {
        final stargateApi = ref.read(solarNetworkClientProvider).stargate;
        await stargateApi.revokeAllOtherSessions();
        // Clear expanded sessions since they might be invalidated
        ref.invalidate(authSessionsProvider);
        ref.invalidate(authDevicesProvider);
        ref.invalidate(expandedSessionsProvider);
        if (context.mounted) Navigator.pop(context);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> updateDeviceLabel(String deviceId) async {
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
        final stargateApi = ref.read(solarNetworkClientProvider).stargate;
        await stargateApi.updateDeviceLabel(deviceId, label);
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
      ).then((value) {
        if (value == true) {
          ref.invalidate(authDevicesProvider);
          ref.invalidate(authSessionsProvider);
        }
      });
    }

    final wideScreen = isWideScreen(context);
    final tabController = useMaterialTabController(
      initialIndex: initialIndex,
      initialLength: 2,
    );

    return SheetScaffold(
      titleText: 'authSessions'.tr(),
      child: Column(
        children: [
          Padding(
            padding: _pageGutter(context),
            child: TabBar(
              controller: tabController,
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Symbols.devices, size: 17),
                      const Gap(7),
                      Text('authDevicesTab'.tr()),
                    ],
                  ),
                ),
                Tab(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Symbols.key, size: 17),
                      const Gap(7),
                      Text('authSessionsTab'.tr()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(4),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _DevicesTab(
                  authDevices: authDevices,
                  wideScreen: wideScreen,
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
                  onTypeChanged: (type) =>
                      ref.read(sessionTypeFilterProvider.notifier).setType(type),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DevicesTab extends StatefulWidget {
  final AsyncValue<PaginationState<SnAuthDeviceWithSession>> authDevices;
  final bool wideScreen;
  final Function(String) updateDeviceLabel;
  final Function(String) logoutSession;
  final Function(SnAuthDeviceWithSession) onDeviceTap;
  final WidgetRef ref;

  const _DevicesTab({
    required this.authDevices,
    required this.wideScreen,
    required this.updateDeviceLabel,
    required this.logoutSession,
    required this.onDeviceTap,
    required this.ref,
  });

  @override
  State<_DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<_DevicesTab> {
  bool _webExpanded = false;

  Widget _buildDeviceItem(
    BuildContext context,
    SnAuthDeviceWithSession device,
  ) {
    final row = _DeviceRow(
      device: device,
      onTap: () => widget.onDeviceTap(device),
    );

    if (widget.wideScreen) return row;

    return Dismissible(
      key: Key('device-${device.id}'),
      direction: device.isCurrent
          ? DismissDirection.none
          : DismissDirection.horizontal,
      background: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Symbols.edit,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Symbols.logout,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          widget.updateDeviceLabel(device.deviceId);
          return false;
        }
        final confirm = await showConfirmAlert(
          'authDeviceLogoutHint'.tr(),
          'authDeviceLogout'.tr(),
          isDanger: true,
        );
        if (confirm && context.mounted) {
          try {
            showLoadingModal(context);
            final stargateApi = widget.ref
                .read(solarNetworkClientProvider)
                .stargate;
            await withSudoRetry(
              context,
              widget.ref,
              () => stargateApi.revokeDevice(device.deviceId),
              onBeforePrompt: () => hideLoadingModal(context),
            );
            widget.ref.invalidate(authDevicesProvider);
          } catch (err) {
            showErrorAlert(err);
          } finally {
            if (context.mounted) hideLoadingModal(context);
          }
        }
        return confirm;
      },
      child: row,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return widget.authDevices.when(
      data: (data) {
        if (data.items.isEmpty && !data.isLoading) {
          return ExtendedRefreshIndicator(
            onRefresh: () =>
                Future.sync(() => widget.ref.invalidate(authDevicesProvider)),
            child: EmptyState(
              icon: Symbols.devices_other,
              title: 'dataEmpty'.tr(),
              description: 'authSessionsDescription'.tr(),
              compact: true,
            ),
          );
        }

        final nativeDevices = data.items.where((d) => d.platform != 1).toList();
        final webDevices = data.items.where((d) => d.platform == 1).toList();
        final isLoadingMore = data.isLoading && data.items.isNotEmpty;
        final gutter = _pageGutter(context);

        return ExtendedRefreshIndicator(
          onRefresh: () =>
              Future.sync(() => widget.ref.invalidate(authDevicesProvider)),
          child: ListView(
            padding: EdgeInsets.only(top: 4, bottom: 24),
            children: [
              if (nativeDevices.isNotEmpty)
                Padding(
                  padding: gutter,
                  child: _GroupBox(
                    children: [
                      for (final device in nativeDevices)
                        _buildDeviceItem(context, device),
                    ],
                  ),
                ),

              if (webDevices.isNotEmpty) ...[
                Padding(
                  padding: gutter.copyWith(top: 20, bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _webExpanded = !_webExpanded),
                    borderRadius: BorderRadius.circular(SolRadius.sm),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.public,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              'authWebBrowsers'.tr(),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                            ),
                          ),
                          Text(
                            '${webDevices.length}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colorScheme.outline,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                          const Gap(4),
                          AnimatedRotation(
                            turns: _webExpanded ? 0.5 : 0,
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 180),
                            child: Icon(
                              Symbols.expand_more,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_webExpanded)
                  Padding(
                    padding: gutter,
                    child: _GroupBox(
                      children: [
                        for (final device in webDevices)
                          _buildDeviceItem(context, device),
                      ],
                    ),
                  ),
              ],

              if (data.hasMore)
                Padding(
                  padding: gutter.copyWith(top: 12),
                  child: Center(
                    child: isLoadingMore
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: () => widget.ref
                                .read(authDevicesProvider.notifier)
                                .fetchFurther(),
                            child: Text('loadMore'.tr()),
                          ),
                  ),
                ),
            ],
          ),
        );
      },
      error: (err, _) => ResponseErrorWidget(
        error: err,
        onRetry: () => widget.ref.invalidate(authDevicesProvider),
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
    final gutter = _pageGutter(context);

    return authSessions.when(
      data: (data) => Column(
        children: [
          Padding(
            padding: gutter.copyWith(top: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  _filterChip(context, 'all'.tr(), null),
                  _filterChip(context, 'sessionTypeLogin'.tr(), 0),
                  _filterChip(context, 'sessionTypeOAuth'.tr(), 1),
                  _filterChip(context, 'sessionTypeOidc'.tr(), 2),
                  _filterChip(context, 'sessionTypeApiKey'.tr(), 3),
                ],
              ),
            ),
          ),
          Expanded(
            child: ExtendedRefreshIndicator(
              onRefresh: () =>
                  Future.sync(() => ref.invalidate(authSessionsProvider)),
              child: data.items.isEmpty
                  ? EmptyState(
                      icon: Symbols.key_off,
                      title: 'dataEmpty'.tr(),
                      compact: true,
                    )
                  : _buildGroupedSessionList(context, data.items),
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

  Widget _filterChip(BuildContext context, String label, int? type) {
    return FilterChip(
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolRadius.pill),
      ),
      label: Text(label),
      selected: selectedType == type,
      onSelected: (_) => onTypeChanged(type),
    );
  }

  Widget _buildGroupedSessionList(
    BuildContext context,
    List<SnAuthSession> sessions,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final gutter = _pageGutter(context);
    final browserSessions = sessions
        .where((s) => s.category == 'browser')
        .toList();
    final deviceSessions = sessions
        .where((s) => s.category != 'browser')
        .toList();
    final others = sessions.where((s) => !s.isCurrent).length;
    final online = sessions.where((s) => s.isOnline).length;

    return ListView(
      padding: EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: gutter.copyWith(top: 12, bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  [
                    'authSessionsCount'.plural(sessions.length),
                    if (online > 0)
                      'friendsOnlineCount'.tr(args: ['$online']),
                  ].join('  ·  '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (deviceSessions.isNotEmpty)
          Padding(
            padding: gutter,
            child: _GroupBox(
              children: [
                for (final session in deviceSessions)
                  _SessionTile(
                    session: session,
                    logoutSession: logoutSession,
                  ),
              ],
            ),
          ),

        if (browserSessions.isNotEmpty) ...[
          Padding(
            padding: gutter.copyWith(top: 20, bottom: 8),
            child: _SectionLabel(
              label: 'authWebBrowsers'.tr(),
              trailing: 'authSessionsCount'.plural(browserSessions.length),
            ),
          ),
          Padding(
            padding: gutter,
            child: _GroupBox(
              children: [
                for (final session in browserSessions)
                  _SessionTile(
                    session: session,
                    logoutSession: logoutSession,
                  ),
              ],
            ),
          ),
        ],

        if (others > 0)
          Padding(
            padding: gutter.copyWith(top: 20),
            child: Center(
              child: TextButton.icon(
                onPressed: logoutAllOtherSessions,
                icon: const Icon(Symbols.logout, size: 18),
                label: Text('authLogoutAllOtherSessions'.tr()),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
