import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';

import 'package:island/route.gr.dart';
import 'package:island/creators/screens/poll/poll_list.dart';
import 'package:island/core/widgets/embeds/link.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/wallets/widgets/fund_envelope.dart';
import 'package:island/accounts/meet_service.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class EmbedListWidget extends ConsumerStatefulWidget {
  final List<dynamic> embeds;
  final bool isInteractive;
  final bool isFullPost;
  final EdgeInsets renderingPadding;
  final double? maxWidth;

  const EmbedListWidget({
    super.key,
    required this.embeds,
    this.isInteractive = true,
    this.isFullPost = false,
    this.renderingPadding = EdgeInsets.zero,
    this.maxWidth,
  });

  @override
  ConsumerState<EmbedListWidget> createState() => _EmbedListWidgetState();
}

class _EmbedListWidgetState extends ConsumerState<EmbedListWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(appSettingsProvider);
      setState(() {
        _isExpanded = settings.linkCollapseMode == 'expand';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final linkEmbeds = widget.embeds.where((e) => e['type'] == 'link').toList();
    final otherEmbeds = widget.embeds
        .where((e) => e['type'] != 'link')
        .toList();
    final theme = Theme.of(context);

    return Column(
      children: [
        if (linkEmbeds.isNotEmpty)
          Container(
            margin: EdgeInsets.only(
              top: 8,
              left: widget.renderingPadding.horizontal,
              right: widget.renderingPadding.horizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with expand/collapse
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.link,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const Gap(8),
                        Text(
                          'embedLinks'.plural(linkEmbeds.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _isExpanded ? 'collapse'.tr() : 'expand'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Animated content
                AnimatedCrossFade(
                  firstChild: _buildExpandedContent(linkEmbeds),
                  secondChild: _buildCollapsedContent(linkEmbeds),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ...otherEmbeds.map(
          (embedData) => switch (embedData['type']) {
            'poll' => _PollEmbedCard(
              pollId: embedData['id']?.toString(),
              margin: EdgeInsets.symmetric(
                horizontal: widget.renderingPadding.horizontal,
                vertical: 8,
              ),
              isInteractive: widget.isInteractive,
            ),
            'fund' =>
              embedData['id'] == null
                  ? const Text('Fund envelope was unavailable...')
                  : FundEnvelopeWidget(
                      fundId: embedData['id'],
                      margin: EdgeInsets.symmetric(
                        horizontal: widget.renderingPadding.horizontal,
                        vertical: 8,
                      ),
                    ),

            'location' => _LocationEmbedCard(
              name: embedData['name']?.toString(),
              address: embedData['address']?.toString(),
              wkt: embedData['wkt']?.toString(),
              margin: EdgeInsets.symmetric(
                horizontal: widget.renderingPadding.horizontal,
                vertical: 8,
              ),
            ),
            'meet' =>
              embedData['id'] == null
                  ? const Text('Meet was unavailable...')
                  : _MeetEmbedCard(
                      meetId: embedData['id'],
                      margin: EdgeInsets.symmetric(
                        horizontal: widget.renderingPadding.horizontal,
                        vertical: 8,
                      ),
                    ),
            'calendar_event' =>
              embedData['id'] == null
                  ? const Text('Calendar event was unavailable...')
                  : _CalendarEventEmbedCard(
                      eventId: embedData['id'],
                      margin: EdgeInsets.symmetric(
                        horizontal: widget.renderingPadding.horizontal,
                        vertical: 8,
                      ),
                    ),
            'notable_day' =>
              embedData['id'] == null
                  ? const Text('Notable day was unavailable...')
                  : _NotableDayEmbedCard(
                      notableDayId: embedData['id'],
                      margin: EdgeInsets.symmetric(
                        horizontal: widget.renderingPadding.horizontal,
                        vertical: 8,
                      ),
                    ),
            _ => Text('Unable show embed: ${embedData['type']}'),
          },
        ),
      ],
    );
  }

  Widget _buildExpandedContent(List<dynamic> linkEmbeds) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: linkEmbeds.length == 1
          ? EmbedLinkWidget(link: SnScrappedLink.fromJson(linkEmbeds.first))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: linkEmbeds
                    .map(
                      (embedData) => SizedBox(
                        width: 180,
                        child: EmbedLinkWidget(
                          link: SnScrappedLink.fromJson(embedData),
                          margin: const EdgeInsets.only(right: 8),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }

  Widget _buildCollapsedContent(List<dynamic> linkEmbeds) {
    if (linkEmbeds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: EmbedLinkWidget(
        link: SnScrappedLink.fromJson(linkEmbeds.first),
        isCompact: true,
      ),
    );
  }

  });

class _LocationEmbedCard extends ConsumerWidget {
  final String? name;
  final String? address;
  final String? wkt;
  final EdgeInsets margin;

  const _LocationEmbedCard({
    this.name,
    this.address,
    this.wkt,
    required this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLocationDetailSheet(
          context,
          name: name,
          address: address,
          wkt: wkt,
        ),
        child: _LocationEmbedContent(
          name: name,
          address: address,
          wkt: wkt,
          theme: theme,
          colorScheme: colorScheme,
        ),
      ),
    );
  }
}

void _showLocationDetailSheet(
  BuildContext context, {
  String? name,
  String? address,
  String? wkt,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) =>
        _LocationDetailSheet(name: name, address: address, wkt: wkt),
  );
}

class _LocationDetailSheet extends StatelessWidget {
  final String? name;
  final String? address;
  final String? wkt;

  const _LocationDetailSheet({this.name, this.address, this.wkt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    LatLng? point;
    if (wkt != null) {
      final match = RegExp(
        r'POINT\s*\(([\d.-]+)\s+([\d.-]+)\)',
      ).firstMatch(wkt!);
      if (match != null) {
        final lon = double.tryParse(match.group(1)!);
        final lat = double.tryParse(match.group(2)!);
        if (lat != null && lon != null) {
          point = LatLng(lat, lon);
        }
      }
    }

    return SheetScaffold(
      titleText: name ?? 'location'.tr(),
      heightFactor: 0.75,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (point != null)
            Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 250,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.island.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (name != null)
            Card(
              elevation: 0,
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Symbols.location_on,
                      size: 32,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (address != null)
                            Text(
                              address!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (point != null) ...[
            const SizedBox(height: 16),
            Text(
              'coordinates'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              color: colorScheme.surface,
              child: Column(
                children: [
                  _buildDetailTile(
                    context,
                    icon: Icons.arrow_upward,
                    title: 'latitude'.tr(),
                    subtitle: point.latitude.toStringAsFixed(6),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 16,
                    color: colorScheme.outlineVariant,
                  ),
                  _buildDetailTile(
                    context,
                    icon: Icons.arrow_forward,
                    title: 'longitude'.tr(),
                    subtitle: point.longitude.toStringAsFixed(6),
                  ),
                  if (!kIsWeb) ...[
                    const Divider(height: 1),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final p = point;
                            if (p != null) {
                              _openLocationInMaps(
                                context,
                                point: p,
                                title: name,
                              );
                            }
                          },
                          icon: const Icon(Icons.map, size: 18),
                          label: Text('openInMaps'.tr()),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

Future<void> _openLocationInMaps(
  BuildContext context, {
  required LatLng point,
  String? title,
}) async {
  if (kIsWeb) {
    showSnackBar('openInMapsUnavailableOnWeb'.tr());
    return;
  }
  final availableMaps = await MapLauncher.installedMaps;
  if (availableMaps.isEmpty) return;

  if (availableMaps.length == 1) {
    await availableMaps.first.showDirections(
      destination: Coords(point.latitude, point.longitude),
      destinationTitle: title ?? 'location'.tr(),
    );
    return;
  }

  if (!context.mounted) return;
  final selected = await showModalBottomSheet<AvailableMap>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'openInMaps'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          ...availableMaps.map(
            (map) => ListTile(
              leading: Icon(
                Symbols.map,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(map.mapName),
              onTap: () => Navigator.pop(context, map),
            ),
          ),
        ],
      ),
    ),
  );

  if (selected != null) {
    await selected.showDirections(
      destination: Coords(point.latitude, point.longitude),
      destinationTitle: title ?? 'location'.tr(),
    );
  }
}

class _LocationMapPreview extends StatelessWidget {
  final String wkt;

  const _LocationMapPreview({required this.wkt});

  @override
  Widget build(BuildContext context) {
    LatLng? point;
    final match = RegExp(r'POINT\s*\(([\d.-]+)\s+([\d.-]+)\)').firstMatch(wkt);
    if (match != null) {
      final lon = double.tryParse(match.group(1)!);
      final lat = double.tryParse(match.group(2)!);
      if (lat != null && lon != null) {
        point = LatLng(lat, lon);
      }
    }
    if (point == null) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.island.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
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

class _LocationEmbedContent extends StatelessWidget {
  final String? name;
  final String? address;
  final String? wkt;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _LocationEmbedContent({
    this.name,
    this.address,
    this.wkt,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    LatLng? point;
    if (wkt != null) {
      final match = RegExp(
        r'POINT\s*\(([\d.-]+)\s+([\d.-]+)\)',
      ).firstMatch(wkt!);
      if (match != null) {
        final lon = double.tryParse(match.group(1)!);
        final lat = double.tryParse(match.group(2)!);
        if (lat != null && lon != null) {
          point = LatLng(lat, lon);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (point != null)
          SizedBox(
            height: 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.island.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Symbols.location_on,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null)
                      Text(
                        name!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (address != null) ...[
                      if (name != null) const SizedBox(height: 4),
                      Text(
                        address!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (point != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Symbols.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }
}

class _PollEmbedCard extends ConsumerWidget {
  final String? pollId;
  final EdgeInsets margin;
  final bool isInteractive;

  const _PollEmbedCard({
    required this.pollId,
    required this.margin,
    required this.isInteractive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pollId == null) {
      return Card(
        margin: margin,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Poll was unavailable...'),
        ),
      );
    }

    final pollAsync = ref.watch(pollWithStatsProvider(pollId!));

    return Card(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      child: pollAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Failed to load poll: $error'),
        ),
        data: (poll) => InkWell(
          onTap: isInteractive
              ? () => context.router.push(PollSubmitRoute(pollId: pollId!))
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (poll.title != null)
                  Text(
                    poll.title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (poll.description != null && poll.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      poll.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Text(
                        '${poll.questions.length} question${poll.questions.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (poll.userAnswer != null &&
                          poll.userAnswer!.answer.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      if (isInteractive)
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MeetEmbedCard extends ConsumerWidget {
  final String meetId;
  final EdgeInsets margin;

  const _MeetEmbedCard({required this.meetId, required this.margin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetAsync = ref.watch(meetDetailProvider(meetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: margin,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMeetDetailSheet(context, ref, meetId),
        child: meetAsync.when(
          data: (meet) {
            LatLng? point;
            if (meet.locationWkt != null) {
              final match = RegExp(
                r'POINT\s*\(([\d.-]+)\s+([\d.-]+)\)',
              ).firstMatch(meet.locationWkt!);
              if (match != null) {
                final lon = double.tryParse(match.group(1)!);
                final lat = double.tryParse(match.group(2)!);
                if (lat != null && lon != null) {
                  point = LatLng(lat, lon);
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (point != null)
                  SizedBox(
                    height: 120,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: point,
                          initialZoom: 14,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.island.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: point,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          Symbols.groups,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    meet.notes ?? 'untitledMeet'.tr(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _MeetStatusChip(status: meet.status),
                              ],
                            ),
                            if (meet.host != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'hostedBy'.tr(args: [meet.host!.nick]),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (meet.locationName != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Symbols.location_on,
                                    size: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      meet.locationName!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (meet.locationAddress != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                meet.locationAddress!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Symbols.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('meetUnavailable'.tr()),
          ),
        ),
      ),
    );
  }
}

void _showMeetDetailSheet(BuildContext context, WidgetRef ref, String meetId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _MeetDetailSheet(meetId: meetId),
  );
}

class _MeetDetailSheet extends ConsumerWidget {
  final String meetId;

  const _MeetDetailSheet({required this.meetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetAsync = ref.watch(meetDetailProvider(meetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return meetAsync.when(
      data: (meet) {
        return SheetScaffold(
          titleText: meet.notes ?? 'untitledMeet'.tr(),
          heightFactor: 0.75,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Host and Status header
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.onPrimaryContainer
                            .withOpacity(0.1),
                        child: Icon(
                          Symbols.groups,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (meet.host != null)
                              Text(
                                meet.host!.nick,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Text(
                              meet.notes ?? 'untitledMeet'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MeetStatusChip(status: meet.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Location info
              if (meet.locationName != null ||
                  meet.locationAddress != null ||
                  meet.locationWkt != null) ...[
                Text(
                  'location'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      if (meet.locationWkt != null)
                        _LocationMapPreview(wkt: meet.locationWkt!),
                      if (meet.locationName != null)
                        _buildDetailTile(
                          context,
                          icon: Symbols.location_on,
                          title: 'locationName'.tr(),
                          subtitle: meet.locationName!,
                        ),
                      if (meet.locationName != null &&
                          meet.locationAddress != null)
                        Divider(
                          height: 1,
                          indent: 56,
                          endIndent: 16,
                          color: colorScheme.outlineVariant,
                        ),
                      if (meet.locationAddress != null)
                        _buildDetailTile(
                          context,
                          icon: Symbols.map,
                          title: 'locationAddress'.tr(),
                          subtitle: meet.locationAddress!,
                        ),
                      if (meet.locationWkt != null && !kIsWeb) ...[
                        const Divider(height: 1),
                        SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final match = RegExp(
                                  r'POINT\s*\(([\d.-]+)\s+([\d.-]+)\)',
                                ).firstMatch(meet.locationWkt!);
                                if (match != null) {
                                  final lon = double.tryParse(match.group(1)!);
                                  final lat = double.tryParse(match.group(2)!);
                                  if (lat != null && lon != null) {
                                    _openLocationInMaps(
                                      context,
                                      point: LatLng(lat, lon),
                                      title: meet.locationName,
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.map, size: 18),
                              label: Text('openInMaps'.tr()),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              // Participants
              if (meet.participants.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'participants'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surface,
                  child: Column(
                    children: [
                      _buildDetailTile(
                        context,
                        icon: Symbols.person,
                        title: 'totalParticipants'.tr(),
                        subtitle: '${meet.participants.length}',
                      ),
                    ],
                  ),
                ),
              ],
              // Meet notes
              if (meet.notes != null) ...[
                const SizedBox(height: 16),
                Text(
                  'notes'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Symbols.description,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            meet.notes!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => SheetScaffold(
        titleText: 'loading'.tr(),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => SheetScaffold(
        titleText: 'errorGeneric'.tr(),
        child: Center(child: Text('meetUnavailable'.tr())),
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MeetStatusChip extends StatelessWidget {
  final SnMeetStatus status;

  const _MeetStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (Color bg, Color fg, String label) = switch (status) {
      SnMeetStatus.active => (
        Colors.green.withOpacity(0.15),
        Colors.green,
        'active'.tr(),
      ),
      SnMeetStatus.completed => (
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
        'completed'.tr(),
      ),
      SnMeetStatus.expired => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        'expired'.tr(),
      ),
      SnMeetStatus.cancelled => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        'cancelled'.tr(),
      ),
      SnMeetStatus.unknown => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
        'unknown'.tr(),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

final calendarEventDetailProvider = FutureProvider.autoDispose
    .family<SnUserCalendarEvent, (String, String)>((ref, params) async {
      final (username, eventId) = params;
      final client = ref.watch(solarNetworkClientProvider);
      return client.accounts.getUserCalendarEvent(username, eventId);
    });

final accountByIdProvider = FutureProvider.autoDispose
    .family<SnAccount, String>((ref, accountId) async {
      final client = ref.watch(solarNetworkClientProvider);
      return client.accounts.getAccountById(accountId);
    });

class _CalendarEventEmbedCard extends ConsumerWidget {
  final String eventId;
  final EdgeInsets margin;

  const _CalendarEventEmbedCard({required this.eventId, required this.margin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // First fetch the event using the authenticated endpoint to get the account
    final eventAsync = ref.watch(
      calendarEventDetailProvider(('unknown', eventId)),
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: margin,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final event = eventAsync.value;
          if (event?.account == null) return;

          // Navigate to the event detail page using the account username
          context.router.push(
            CalendarEventDetailRoute(
              username: event!.account!.name,
              eventId: eventId,
            ),
          );
        },
        child: eventAsync.when(
          data: (event) {
            final now = DateTime.now();
            final isPast = event.startTime.isBefore(now);
            final daysDiff = event.startTime.difference(now).inDays;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.background != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: CloudFileWidget(
                        item: event.background!,
                        fit: BoxFit.cover,
                        useInternalGate: false,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: event.icon != null
                            ? ClipOval(
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CloudFileWidget(
                                    item: event.icon!,
                                    fit: BoxFit.cover,
                                    useInternalGate: false,
                                  ),
                                ),
                              )
                            : Icon(
                                Symbols.calendar_month,
                                color: colorScheme.onPrimaryContainer,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat.yMMMd().format(event.startTime),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (event.description != null &&
                                event.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                event.description!,
                                style: theme.textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPast
                                    ? colorScheme.surfaceContainerHighest
                                    : colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isPast
                                    ? 'countdownPast'.tr(
                                        args: ['${daysDiff.abs()}d'],
                                      )
                                    : 'countdownFuture'.tr(
                                        args: ['${daysDiff}d'],
                                      ),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isPast
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Symbols.chevron_right,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('calendarEventUnavailable'.tr()),
          ),
        ),
      ),
    );
  }
}

class _NotableDayEmbedCard extends StatelessWidget {
  final String notableDayId;
  final EdgeInsets margin;

  const _NotableDayEmbedCard({
    required this.notableDayId,
    required this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Notable days don't have a detail endpoint, so we show a simple card
    // The notable day data should come from the embed itself
    return Card(
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.tertiaryContainer,
              child: Icon(
                Symbols.celebration,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'notableDay'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'notableDayEmbedHint'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Symbols.celebration, color: colorScheme.tertiary),
          ],
        ),
      ),
    );
  }
}
