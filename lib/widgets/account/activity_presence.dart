import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/activity.dart';
import 'package:island/pods/activity/activity_rpc.dart';
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

const kPresenseActivityTypes = [
  'unknown',
  'presenceTypeGaming',
  'presenceTypeMusic',
  'presenceTypeWorkout',
];

const kPresenseActivityIcons = <IconData>[
  Symbols.question_mark_rounded,
  Symbols.play_arrow_rounded,
  Symbols.music_note_rounded,
  Symbols.running_with_errors,
];

class ActivityPresenceWidget extends ConsumerWidget {
  final String uname;

  const ActivityPresenceWidget({super.key, required this.uname});

  List<Widget> _buildDiscordImages(WidgetRef ref, SnPresenceActivity activity) {
    final List<Widget> images = [];

    if (activity.largeImage != null &&
        activity.largeImage!.startsWith('discord:')) {
      final key = activity.largeImage!.substring('discord:'.length);
      final urlAsync = ref.watch(discordAssetsUrlProvider(activity, key));
      images.add(
        urlAsync.when(
          data:
              (url) =>
                  url != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          width: 64,
                          height: 64,
                        ),
                      )
                      : const SizedBox.shrink(),
          loading:
              () => const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      );
    }

    if (activity.smallImage != null &&
        activity.smallImage!.startsWith('discord:')) {
      final key = activity.smallImage!.substring('discord:'.length);
      final urlAsync = ref.watch(discordAssetsUrlProvider(activity, key));
      images.add(
        urlAsync.when(
          data:
              (url) =>
                  url != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          width: 32,
                          height: 32,
                        ),
                      )
                      : const SizedBox.shrink(),
          loading:
              () => const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      );
    }

    return images;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(presenceActivitiesProvider(uname));

    return activitiesAsync.when(
      data:
          (activities) => Card(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  'activities',
                ).tr().bold().padding(horizontal: 8, vertical: 4),
                if (activities.isEmpty)
                  Row(
                    spacing: 4,
                    children: [
                      const Icon(Symbols.inbox, size: 16),
                      Text('dataEmpty').tr().fontSize(13),
                    ],
                  ).opacity(0.75).padding(horizontal: 8),
                ...activities.map((activity) {
                  final dcImages = _buildDiscordImages(ref, activity);

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dcImages.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 8,
                              children: dcImages,
                            ).padding(vertical: 4),
                          Text(
                            (activity.title?.isEmpty ?? true)
                                ? 'unknown'.tr()
                                : activity.title!,
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 4,
                            children: [
                              Text(kPresenseActivityTypes[activity.type]).tr(),
                              Icon(
                                kPresenseActivityIcons[activity.type],
                                size: 16,
                                fill: 1,
                              ),
                            ],
                          ),
                          StreamBuilder(
                            stream: Stream.periodic(const Duration(seconds: 1)),
                            builder: (context, snapshot) {
                              final now = DateTime.now();

                              // Check if lease has expired and refresh if needed
                              if (now.isAfter(activity.leaseExpiresAt)) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  ref.invalidate(presenceActivitiesProvider(uname));
                                });
                              }

                              final duration = now.difference(
                                activity.createdAt,
                              );
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
                              ).textColor(Colors.green);
                            },
                          ),
                          if (activity.subtitle?.isNotEmpty ?? false)
                            Text(activity.subtitle!),
                          if (activity.caption?.isNotEmpty ?? false)
                            Text(activity.caption!),
                          if ((activity.titleUrl?.isNotEmpty ?? false) ||
                              (activity.subtitleUrl?.isNotEmpty ?? false))
                            Row(
                              spacing: 8,
                              children: [
                                if (activity.titleUrl != null && activity.titleUrl!.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () => launchUrlString(activity.titleUrl!),
                                    icon: const Icon(Symbols.link, size: 16),
                                    label: const Text('Open Title Link'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                if (activity.subtitleUrl != null && activity.subtitleUrl!.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () => launchUrlString(activity.subtitleUrl!),
                                    icon: const Icon(Symbols.link, size: 16),
                                    label: const Text('Open Subtitle Link'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ).padding(all: 8),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading activities: $error')),
    );
  }
}
