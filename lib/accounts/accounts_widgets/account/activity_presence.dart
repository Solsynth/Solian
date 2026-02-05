import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/models/activity.dart';
import 'package:island/activity/activity_rpc.dart';
import 'package:island/core/widgets/content/image.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'activity_presence.g.dart';

@riverpod
Future<Map<String, String>?> discordAssets(
  Ref ref,
  SnPresenceActivity activity,
) async {
  final hasDiscordSmall =
      activity.smallImage != null &&
      activity.smallImage!.startsWith('discord:');
  final hasDiscordLarge =
      activity.largeImage != null &&
      activity.largeImage!.startsWith('discord:');

  if (hasDiscordSmall || hasDiscordLarge) {
    final dio = Dio();
    final response = await dio.get(
      'https://discordapp.com/api/oauth2/applications/${activity.manualId}/assets',
    );
    final data = response.data as List<dynamic>;
    return {
      for (final item in data) item['name'] as String: item['id'] as String,
    };
  }

  return null;
}

@riverpod
Future<String?> discordAssetsUrl(
  Ref ref,
  SnPresenceActivity activity,
  String key,
) async {
  final assets = await ref.watch(discordAssetsProvider(activity).future);
  if (assets != null && assets.containsKey(key)) {
    final assetId = assets[key]!;
    return 'https://cdn.discordapp.com/app-assets/${activity.manualId}/$assetId.png';
  }
  return null;
}

const kPresenceActivityTypes = [
  'unknown',
  'presenceTypeGaming',
  'presenceTypeMusic',
  'presenceTypeWorkout',
];

const kPresenceActivityIcons = <IconData>[
  Symbols.question_mark_rounded,
  Symbols.play_arrow_rounded,
  Symbols.music_note_rounded,
  Symbols.running_with_errors,
];

class ActivityPresenceWidget extends StatefulWidget {
  final String uname;
  final bool isCompact;
  final EdgeInsets compactPadding;

  const ActivityPresenceWidget({
    super.key,
    required this.uname,
    this.isCompact = false,
    this.compactPadding = EdgeInsets.zero,
  });

  @override
  State<ActivityPresenceWidget> createState() => _ActivityPresenceWidgetState();
}

class _ActivityPresenceWidgetState extends State<ActivityPresenceWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _startProgress = 0.0;
  double _endProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(_progressController);
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  List<Widget> _buildImages(WidgetRef ref, SnPresenceActivity activity) {
    final List<Widget> images = [];

    if (activity.largeImage != null) {
      if (activity.largeImage!.startsWith('discord:')) {
        final key = activity.largeImage!.substring('discord:'.length);
        final urlAsync = ref.watch(discordAssetsUrlProvider(activity, key));
        images.add(
          urlAsync.when(
            data: (url) => url != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      width: 64,
                      height: 64,
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        );
      } else {
        images.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: UniversalImage(
              uri: activity.largeImage!,
              width: 64,
              height: 64,
            ),
          ),
        );
      }
    }

    if (activity.smallImage != null) {
      if (activity.smallImage!.startsWith('discord:')) {
        final key = activity.smallImage!.substring('discord:'.length);
        final urlAsync = ref.watch(discordAssetsUrlProvider(activity, key));
        images.add(
          urlAsync.when(
            data: (url) => url != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      width: 32,
                      height: 32,
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        );
      } else {
        images.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: UniversalImage(
              uri: activity.smallImage!,
              width: 32,
              height: 32,
            ),
          ),
        );
      }
    }

    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final activitiesAsync = ref.watch(
          presenceActivitiesProvider(widget.uname),
        );

        if (widget.isCompact) {
          return activitiesAsync.when(
            data: (activities) {
              if (activities.isEmpty) return const SizedBox.shrink();
              final activity = activities.first;
              return Padding(
                padding: widget.compactPadding,
                child: Row(
                  spacing: 8,
                  children: [
                    if (activity.largeImage != null)
                      activity.largeImage!.startsWith('discord:')
                          ? ref
                                .watch(
                                  discordAssetsUrlProvider(
                                    activity,
                                    activity.largeImage!.substring(
                                      'discord:'.length,
                                    ),
                                  ),
                                )
                                .when(
                                  data: (url) => url != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: url,
                                            width: 32,
                                            height: 32,
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  loading: () => const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  error: (error, stack) =>
                                      const SizedBox.shrink(),
                                )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: UniversalImage(
                                uri: activity.largeImage!,
                                width: 32,
                                height: 32,
                              ),
                            ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (activity.title?.isEmpty ?? true)
                                ? 'unknown'.tr()
                                : activity.title!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).fontSize(13),
                          Row(
                            children: [
                              Text(
                                kPresenceActivityTypes[activity.type],
                              ).tr().fontSize(11),
                              Icon(
                                kPresenceActivityIcons[activity.type],
                                size: 15,
                                fill: 1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        final now = DateTime.now();

                        if (activity.manualId == 'spotify' &&
                            activity.meta != null) {
                          final meta = activity.meta as Map<String, dynamic>;
                          final progressMs = meta['progress_ms'] as int? ?? 0;
                          final durationMs =
                              meta['track_duration_ms'] as int? ?? 1;
                          final elapsed = now
                              .difference(activity.createdAt)
                              .inMilliseconds;
                          final currentProgressMs =
                              (progressMs + elapsed) % durationMs;
                          final progressValue = currentProgressMs / durationMs;
                          if (progressValue != _endProgress) {
                            _startProgress = _endProgress;
                            _endProgress = progressValue;
                            _progressAnimation = Tween<double>(
                              begin: _startProgress,
                              end: _endProgress,
                            ).animate(_progressController);
                            _progressController.forward(from: 0.0);
                          }
                          return AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              final animatedValue = _progressAnimation.value;
                              final animatedProgressMs =
                                  (animatedValue * durationMs).toInt();
                              final currentMin = animatedProgressMs ~/ 60000;
                              final currentSec =
                                  (animatedProgressMs % 60000) ~/ 1000;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 2,
                                children: [
                                  Text(
                                    '${currentMin.toString().padLeft(2, '0')}:${currentSec.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: LinearProgressIndicator(
                                      value: animatedValue,
                                      backgroundColor: Colors.grey.shade300,
                                      stopIndicatorColor: Colors.green,
                                      trackGap: 0,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green,
                                      ),
                                    ),
                                  ).padding(top: 2),
                                ],
                              );
                            },
                          );
                        } else {
                          final duration = now.difference(activity.createdAt);
                          final hours = duration.inHours.toString().padLeft(
                            2,
                            '0',
                          );
                          final minutes = (duration.inMinutes % 60)
                              .toString()
                              .padLeft(2, '0');
                          final seconds = (duration.inSeconds % 60)
                              .toString()
                              .padLeft(2, '0');
                          return Text(
                            '$hours:$minutes:$seconds',
                          ).textColor(Colors.green).fontSize(12);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          );
        }

        return activitiesAsync.when(
          data: (activities) => Card(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  'activities',
                ).tr().bold().padding(horizontal: 16, vertical: 4),
                if (activities.isEmpty)
                  Row(
                    spacing: 4,
                    children: [
                      const Icon(Symbols.inbox, size: 16),
                      Text('dataEmpty').tr().fontSize(13),
                    ],
                  ).opacity(0.75).padding(horizontal: 16, bottom: 8),
                ...activities.map((activity) {
                  final images = _buildImages(ref, activity);

                  return Stack(
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (images.isNotEmpty)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  spacing: 8,
                                  children: images,
                                ).padding(vertical: 4),
                              Row(
                                spacing: 2,
                                children: [
                                  Flexible(
                                    child: Text(
                                      (activity.title?.isEmpty ?? true)
                                          ? 'unknown'.tr()
                                          : activity.title!,
                                    ),
                                  ),
                                  if (activity.titleUrl != null &&
                                      activity.titleUrl!.isNotEmpty)
                                    IconButton(
                                      visualDensity: const VisualDensity(
                                        vertical: -4,
                                      ),
                                      onPressed: () {
                                        launchUrlString(activity.titleUrl!);
                                      },
                                      icon: const Icon(Symbols.launch_rounded),
                                      iconSize: 16,
                                      padding: EdgeInsets.all(4),
                                      constraints: const BoxConstraints(
                                        maxWidth: 28,
                                        maxHeight: 28,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 4,
                                children: [
                                  Text(
                                    kPresenceActivityTypes[activity.type],
                                  ).tr(),
                                  Icon(
                                    kPresenceActivityIcons[activity.type],
                                    size: 16,
                                    fill: 1,
                                  ),
                                ],
                              ),
                              if (activity.manualId == 'spotify' &&
                                  activity.meta != null)
                                StreamBuilder(
                                  stream: Stream.periodic(
                                    const Duration(seconds: 1),
                                  ),
                                  builder: (context, snapshot) {
                                    final now = DateTime.now();
                                    final meta =
                                        activity.meta as Map<String, dynamic>;
                                    final progressMs =
                                        meta['progress_ms'] as int? ?? 0;
                                    final durationMs =
                                        meta['track_duration_ms'] as int? ?? 1;
                                    final elapsed = now
                                        .difference(activity.createdAt)
                                        .inMilliseconds;
                                    final currentProgressMs =
                                        (progressMs + elapsed) % durationMs;
                                    final progressValue =
                                        currentProgressMs / durationMs;
                                    if (progressValue != _endProgress) {
                                      _startProgress = _endProgress;
                                      _endProgress = progressValue;
                                      _progressAnimation = Tween<double>(
                                        begin: _startProgress,
                                        end: _endProgress,
                                      ).animate(_progressController);
                                      _progressController.forward(from: 0.0);
                                    }
                                    return AnimatedBuilder(
                                      animation: _progressAnimation,
                                      builder: (context, child) {
                                        final animatedValue =
                                            _progressAnimation.value;
                                        final animatedProgressMs =
                                            (animatedValue * durationMs)
                                                .toInt();
                                        final currentMin =
                                            animatedProgressMs ~/ 60000;
                                        final currentSec =
                                            (animatedProgressMs % 60000) ~/
                                            1000;
                                        final totalMin = durationMs ~/ 60000;
                                        final totalSec =
                                            (durationMs % 60000) ~/ 1000;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 4,
                                          children: [
                                            LinearProgressIndicator(
                                              value: animatedValue,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              trackGap: 0,
                                              stopIndicatorColor: Colors.green,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.green,
                                                  ),
                                            ).padding(top: 3),
                                            Text(
                                              '${currentMin.toString().padLeft(2, '0')}:${currentSec.toString().padLeft(2, '0')} / ${totalMin.toString().padLeft(2, '0')}:${totalSec.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              else
                                StreamBuilder(
                                  stream: Stream.periodic(
                                    const Duration(seconds: 1),
                                  ),
                                  builder: (context, snapshot) {
                                    final now = DateTime.now();

                                    final duration = now.difference(
                                      activity.createdAt,
                                    );
                                    final hours = duration.inHours
                                        .toString()
                                        .padLeft(2, '0');
                                    final minutes = (duration.inMinutes % 60)
                                        .toString()
                                        .padLeft(2, '0');
                                    final seconds = (duration.inSeconds % 60)
                                        .toString()
                                        .padLeft(2, '0');
                                    return Text(
                                      '$hours:$minutes:$seconds',
                                    ).textColor(Colors.green);
                                  },
                                ),
                              if (activity.subtitle?.isNotEmpty ?? false)
                                Row(
                                  spacing: 2,
                                  children: [
                                    Flexible(child: Text(activity.subtitle!)),
                                    if (activity.titleUrl != null &&
                                        activity.titleUrl!.isNotEmpty)
                                      IconButton(
                                        visualDensity: const VisualDensity(
                                          vertical: -4,
                                        ),
                                        onPressed: () {
                                          launchUrlString(activity.titleUrl!);
                                        },
                                        icon: const Icon(
                                          Symbols.launch_rounded,
                                        ),
                                        iconSize: 16,
                                        padding: EdgeInsets.all(4),
                                        constraints: const BoxConstraints(
                                          maxWidth: 28,
                                          maxHeight: 28,
                                        ),
                                      ),
                                  ],
                                ),
                              if (activity.caption?.isNotEmpty ?? false)
                                Text(activity.caption!),
                            ],
                          ),
                        ),
                      ).padding(horizontal: 8),
                      if (activity.manualId == 'spotify')
                        Positioned(
                          top: 16,
                          right: 24,
                          child: Tooltip(
                            message: 'Listening on Spotify',
                            child: Image.asset(
                              'assets/images/oidc/spotify.png',
                              width: 24,
                              height: 24,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ).padding(horizontal: 8, top: 8, bottom: 16),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading activities: $error')),
        );
      },
    );
  }
}
