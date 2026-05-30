import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/time.dart';
import 'package:gap/gap.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:url_launcher/url_launcher_string.dart';

final friendAccountMapProvider = Provider<Map<String, SnAccount>>((ref) {
  final friendsAsync = ref.watch(friendsOverviewProvider);
  final friends = friendsAsync.asData?.value;
  if (friends == null) return {};
  return {for (final f in friends) f.account.id: f.account};
});

String resolvePresenceArtworkUrl(WidgetRef ref, String imageUri) {
  if (imageUri.startsWith('sha256:')) {
    final serverURL = ref.read(serverUrlProvider);
    return '$serverURL/passport/presence/artworks/$imageUri';
  }
  return imageUri;
}

Map<String, dynamic> asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map)
    return value.map((key, value) => MapEntry(key.toString(), value));
  return const <String, dynamic>{};
}

Map<String, dynamic> normalizePresenceActivityJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized['type'] = switch (normalized['type']) {
    final int value => value,
    final String value => switch (value) {
      'Gaming' => 1,
      'Music' => 2,
      'Workout' => 3,
      _ => 0,
    },
    final num value => value.toInt(),
    _ => 0,
  };
  return normalized;
}

Map<String, dynamic> normalizeStatusJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized['attitude'] = switch (normalized['attitude']) {
    final int value => value,
    final String value => switch (value) {
      'Positive' => 0,
      'Negative' => 2,
      _ => 1,
    },
    final num value => value.toInt(),
    _ => 1,
  };
  normalized['type'] = switch (normalized['type']) {
    final int value => value,
    final String value => switch (value) {
      'Busy' => SnAccountStatusType.busy,
      'DoNotDisturb' => SnAccountStatusType.doNotDisturb,
      'Invisible' => SnAccountStatusType.invisible,
      _ => SnAccountStatusType.defaultType,
    },
    final num value => value.toInt(),
    _ => SnAccountStatusType.defaultType,
  };
  return normalized;
}

Color _getActivityColor(int type) {
  switch (type) {
    case 1:
      return Colors.purple;
    case 2:
      return Colors.green;
    case 3:
      return Colors.orange;
    default:
      return Colors.blue;
  }
}

class _SteamHeroImage extends StatelessWidget {
  final Map<String, dynamic> meta;

  const _SteamHeroImage({required this.meta});

  @override
  Widget build(BuildContext context) {
    final gameId = meta['game_id']?.toString();
    if (gameId == null) return const SizedBox.shrink();

    final heroUrl =
        'https://cdn.cloudflare.steamstatic.com/steam/apps/$gameId/library_hero.jpg';

    return CachedNetworkImage(
      imageUrl: heroUrl,
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 80,
        color: const Color(0xFF1B2838),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        height: 80,
        color: const Color(0xFF1B2838),
        child: const Center(
          child: Icon(Symbols.sports_esports, color: Colors.white70, size: 32),
        ),
      ),
    );
  }
}

class FriendPresenceItem extends ConsumerWidget {
  final SnPresenceActivity activity;
  final Map<String, dynamic> rawData;

  const FriendPresenceItem({
    super.key,
    required this.activity,
    required this.rawData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userInfo = ref.watch(userInfoProvider);
    final currentUser = userInfo.value;
    final friendMap = ref.watch(friendAccountMapProvider);
    final account = currentUser?.id == activity.accountId
        ? currentUser
        : (friendMap[activity.accountId] ?? activity.account);
    final isActive =
        (rawData['is_active'] as bool?) ??
        (activity.deletedAt == null &&
            activity.leaseExpiresAt.isAfter(DateTime.now()));
    final providerKey =
        (rawData['provider'] as String?) ??
        (activity.meta?['provider']?.toString());
    final isSpotify = providerKey == 'spotify';
    final isSteam = providerKey == 'steam';

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSteam && activity.meta != null)
          _SteamHeroImage(meta: activity.meta as Map<String, dynamic>),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarStack(theme, account, isSpotify, isSteam),
              if (_hasArtwork(activity) && !isSteam)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: resolvePresenceArtworkUrl(
                      ref,
                      activity.largeImage ?? activity.smallImage!,
                    ),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (account != null) ...[
                      Row(
                        children: [
                          Flexible(
                            child: AccountName(
                              account: account,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                              hideOverlay: true,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            '·',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.5),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            activity.createdAt.toLocal().formatRelative(
                              context,
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                    Row(
                      spacing: 6,
                      children: [
                        Flexible(
                          child: Text(
                            activity.title ?? 'unknown'.tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (activity.titleUrl != null &&
                            activity.titleUrl!.isNotEmpty)
                          GestureDetector(
                            onTap: () => launchUrlString(activity.titleUrl!),
                            child: Icon(
                              Symbols.launch_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    if (activity.subtitle != null &&
                        activity.subtitle!.isNotEmpty) ...[
                      const Gap(2),
                      Row(
                        spacing: 4,
                        children: [
                          Flexible(
                            child: Text(
                              activity.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (activity.subtitleUrl != null &&
                              activity.subtitleUrl!.isNotEmpty)
                            GestureDetector(
                              onTap: () =>
                                  launchUrlString(activity.subtitleUrl!),
                              child: Icon(
                                Symbols.launch_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (activity.caption != null &&
                        activity.caption!.isNotEmpty) ...[
                      const Gap(2),
                      Text(
                        activity.caption!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Gap(6),
                    Row(
                      spacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            kPresenceActivityTypes[activity.type],
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ).tr(),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'presenceOngoing',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ).tr(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (account != null) {
      return AccountPfcRegion(uname: account.name, child: content);
    }
    return content;
  }

  Widget _buildAvatarStack(
    ThemeData theme,
    SnAccount? account,
    bool isSpotify,
    bool isSteam,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (account != null)
          ProfilePictureWidget(file: account.profile.picture, radius: 18)
        else
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              kPresenceActivityIcons[activity.type],
              size: 18,
              color: _getActivityColor(activity.type),
            ),
          ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type),
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 2),
            ),
            child: Icon(
              kPresenceActivityIcons[activity.type],
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
        if (isSpotify)
          Positioned(
            right: -6,
            top: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.music_note,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        if (isSteam)
          Positioned(
            right: -6,
            top: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFF1B2838),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Symbols.sports_esports,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  static bool _hasArtwork(SnPresenceActivity activity) {
    return activity.largeImage != null || activity.smallImage != null;
  }
}

class FriendStatusItem extends ConsumerWidget {
  final SnAccountStatus status;
  final DateTime createdAt;

  const FriendStatusItem({
    super.key,
    required this.status,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userInfo = ref.watch(userInfoProvider);
    final currentUser = userInfo.value;
    final friendMap = ref.watch(friendAccountMapProvider);
    final account = currentUser?.id == status.accountId
        ? currentUser
        : (friendMap[status.accountId] ?? status.account);
    final displayLabel = getStatusDisplayLabel(context, status);
    final displaySymbol = getStatusDisplaySymbol(status);
    final indicatorColor = getStatusIndicatorColor(status);
    final indicatorIcon = getStatusIndicatorIcon(status);
    final indicatorFill = getStatusIndicatorFill(status);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (account != null)
                ProfilePictureWidget(file: account.profile.picture, radius: 18)
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: indicatorColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    indicatorIcon,
                    size: 18,
                    color: indicatorColor,
                    fill: indicatorFill,
                  ),
                ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    indicatorIcon,
                    size: 10,
                    color: Colors.white,
                    fill: indicatorFill,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (account != null) ...[
                  Row(
                    children: [
                      Flexible(
                        child: AccountName(
                          account: account,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          hideOverlay: true,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        '·',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.5,
                          ),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        createdAt.toLocal().formatRelative(context),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                Row(
                  spacing: 6,
                  children: [
                    if (displaySymbol != null)
                      Text(displaySymbol, style: const TextStyle(fontSize: 16)),
                    Flexible(
                      child: Text(
                        displayLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Gap(2),
                Text(
                  getStatusTypeLabel(context, status),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(6),
                Row(
                  spacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.isOnline ? 'online'.tr() : 'offline'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    if (status.isAutomated)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'bot',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ).tr(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (account != null) {
      return AccountPfcRegion(uname: account.name, child: content);
    }
    return content;
  }
}
