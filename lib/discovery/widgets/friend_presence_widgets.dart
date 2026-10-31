import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/accounts/utils/account_status_utils.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:url_launcher/url_launcher_string.dart';

final friendAccountMapProvider = Provider<Map<String, SnAccount>>((ref) {
  final friendsAsync = ref.watch(friendsOverviewProvider);
  final friends = friendsAsync.asData?.value;
  if (friends == null) return {};
  return {for (final f in friends) f.account.id: f.account};
});

Map<String, dynamic> asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}

/// Normalizes legacy discovery-feed payloads: `type` may arrive as the old int
/// enum or a PascalCase string; both become the free-form lowercase slug.
Map<String, dynamic> normalizePresenceActivityJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized['type'] = switch (normalized['type']) {
    final String value => switch (value) {
      'Gaming' => 'gaming',
      'Music' => 'music',
      'Workout' => 'workout',
      _ => value.toLowerCase(),
    },
    final int value => switch (value) {
      1 => 'gaming',
      2 => 'music',
      3 => 'workout',
      _ => 'unknown',
    },
    final num value => switch (value.toInt()) {
      1 => 'gaming',
      2 => 'music',
      3 => 'workout',
      _ => 'unknown',
    },
    _ => 'unknown',
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

Color _getActivityColor(String type) {
  switch (type) {
    case 'gaming':
      return Colors.purple;
    case 'music':
      return Colors.green;
    case 'workout':
    case 'fitness':
      return Colors.orange;
    default:
      return Colors.blue;
  }
}

String _resolveActivityStatusKey(String type, bool isActive) {
  if (!isActive) {
    return switch (type) {
      'gaming' => 'presenceTypePlayed',
      'music' => 'presenceTypeListened',
      _ => presenceActivityTypeKey(type),
    };
  }
  return presenceActivityTypeKey(type);
}

/// Avatar plus the row's single presence overlay: the activity glyph while
/// something is playing, a bare tinted dot otherwise. Presence is drawn here
/// and nowhere else in the row, so the same state is never also spelled out as
/// a chip.
class _PresenceAvatar extends StatelessWidget {
  final SnAccount? account;

  /// Tint of the overlay and of the placeholder avatar.
  final Color color;

  /// Glyph inside the overlay badge; null paints a bare dot (account status).
  final IconData? overlayIcon;

  /// Glyph used when the account itself could not be resolved.
  final IconData fallbackIcon;
  final double pointFill;

  const _PresenceAvatar({
    required this.account,
    required this.color,
    required this.fallbackIcon,
    this.overlayIcon,
    this.pointFill = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (account != null)
          ProfilePictureWidget(
            file: account!.profile.picture,
            fallbackName: account!.nick,
            radius: 18,
          )
        else
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              fallbackIcon,
              size: 18,
              color: color,
              fill: pointFill,
            ),
          ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
            child: overlayIcon == null
                ? null
                : Icon(
                    overlayIcon,
                    size: 10,
                    color: Colors.white,
                    fill: pointFill,
                  ),
          ),
        ),
      ],
    );
  }
}

/// One muted identity line: who the row is about, and how long ago it happened.
class _PresenceMetaLine extends StatelessWidget {
  final SnAccount? account;
  final DateTime at;

  const _PresenceMetaLine({required this.account, required this.at});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        if (account != null) ...[
          Flexible(
            child: AccountName(
              account: account!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
              hideOverlay: true,
            ),
          ),
          const Gap(4),
          Text(
            '·',
            style: theme.textTheme.labelMedium?.copyWith(
              color: muted.withOpacity(0.5),
            ),
          ),
          const Gap(4),
        ],
        Text(
          at.toLocal().formatRelative(context),
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// The row's payload on one line, with its link affordance if the source gave
/// one. [secondary] renders a subtitle: smaller and muted.
class _PresenceTitleLine extends StatelessWidget {
  final String text;
  final String? url;
  final bool secondary;

  const _PresenceTitleLine({
    required this.text,
    this.url,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = secondary
        ? theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )
        : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);

    return Row(
      spacing: 4,
      children: [
        Flexible(
          child: Text(
            text,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (url != null && url!.isNotEmpty)
          GestureDetector(
            onTap: () => launchUrlString(url!),
            child: Icon(
              Symbols.launch_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

/// A friend's current activity ("now playing"): what they are doing, with the
/// activity type carried entirely by the avatar overlay.
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
    final title = (activity.title?.trim().isNotEmpty ?? false)
        ? activity.title!
        : _resolveActivityStatusKey(activity.type, isActive).tr();
    final subtitle = activity.subtitle?.trim();

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PresenceAvatar(
            account: account,
            color: _getActivityColor(activity.type),
            overlayIcon: presenceActivityIcon(activity.type),
            fallbackIcon: presenceActivityIcon(activity.type),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _PresenceMetaLine(account: account, at: activity.createdAt),
                _PresenceTitleLine(text: title, url: activity.titleUrl),
                if (subtitle != null && subtitle.isNotEmpty)
                  _PresenceTitleLine(
                    text: subtitle,
                    url: activity.subtitleUrl,
                    secondary: true,
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

/// A friend's account status change. The dot on the avatar is the state; the
/// label is the human wording of it, so the row never says both twice.
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

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PresenceAvatar(
            account: account,
            color: getStatusIndicatorColor(status),
            fallbackIcon: getStatusIndicatorIcon(status),
            pointFill: getStatusIndicatorFill(status),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _PresenceMetaLine(account: account, at: createdAt),
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
