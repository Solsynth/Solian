import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/activity/activity_rpc.dart';
import 'package:island/accounts/widgets/account/badge.dart';
import 'package:island/accounts/widgets/account/fortune_graph.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'board.g.dart';

enum BoardWidgetKind { prebuilt, customApp }

class BoardWidgetPayload {
  final String? background;
  final String? image;

  const BoardWidgetPayload({this.background, this.image});

  factory BoardWidgetPayload.fromJson(Map<String, dynamic> json) {
    return BoardWidgetPayload(
      background: json['background'] as String?,
      image: json['image'] as String?,
    );
  }
}

class AccountBoardItem {
  final String? id;
  final int order;
  final BoardWidgetKind kind;
  final String? widgetKey;
  final String? customAppId;
  final String? customAppWidgetKey;
  final bool isEnabled;
  final Map<String, dynamic> payload;

  const AccountBoardItem({
    this.id,
    required this.order,
    required this.kind,
    this.widgetKey,
    this.customAppId,
    this.customAppWidgetKey,
    this.isEnabled = true,
    this.payload = const {},
  });

  AccountBoardItem copyWith({
    String? id,
    int? order,
    BoardWidgetKind? kind,
    String? widgetKey,
    String? customAppId,
    String? customAppWidgetKey,
    bool? isEnabled,
    Map<String, dynamic>? payload,
  }) {
    return AccountBoardItem(
      id: id ?? this.id,
      order: order ?? this.order,
      kind: kind ?? this.kind,
      widgetKey: widgetKey ?? this.widgetKey,
      customAppId: customAppId ?? this.customAppId,
      customAppWidgetKey: customAppWidgetKey ?? this.customAppWidgetKey,
      isEnabled: isEnabled ?? this.isEnabled,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'order': order,
      'kind': kind == BoardWidgetKind.customApp ? 'custom_app' : 'prebuilt',
      if (widgetKey != null) 'widget_key': widgetKey,
      if (customAppId != null) 'custom_app_id': customAppId,
      if (customAppWidgetKey != null)
        'custom_app_widget_key': customAppWidgetKey,
      'is_enabled': isEnabled,
      'payload': payload,
    };
  }
}

class BoardWidgetField {
  final String name;
  final String type;
  final String label;
  final String format;
  final bool required;

  const BoardWidgetField({
    required this.name,
    required this.type,
    required this.label,
    this.format = '',
    this.required = false,
  });

  factory BoardWidgetField.fromJson(Map<String, dynamic> json) {
    return BoardWidgetField(
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'string',
      label: json['label'] as String? ?? '',
      format: json['format'] as String? ?? '',
      required: json['required'] as bool? ?? false,
    );
  }
}

class BoardWidgetDefinition {
  final String key;
  final bool isEnabled;
  final String rendererType;
  final List<BoardWidgetField> fieldTypes;
  final List<String> requiredFields;
  final int? maxPayloadBytes;
  final bool allowMultiple;

  const BoardWidgetDefinition({
    required this.key,
    this.isEnabled = true,
    this.rendererType = '',
    this.fieldTypes = const [],
    this.requiredFields = const [],
    this.maxPayloadBytes,
    this.allowMultiple = false,
  });

  factory BoardWidgetDefinition.fromJson(Map<String, dynamic> json) {
    return BoardWidgetDefinition(
      key: json['key'] as String? ?? '',
      isEnabled: json['is_enabled'] as bool? ?? true,
      rendererType: json['renderer_type'] as String? ?? '',
      fieldTypes:
          (json['field_types'] as List<dynamic>?)
              ?.map((e) => BoardWidgetField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requiredFields:
          (json['required_fields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      maxPayloadBytes: json['max_payload_bytes'] as int?,
      allowMultiple: json['allow_multiple'] as bool? ?? false,
    );
  }
}

class BoardWidgetApp {
  final String id;
  final String slug;
  final String name;
  final String? description;
  final String? pictureId;
  final List<BoardWidgetDefinition> boardWidgets;

  const BoardWidgetApp({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.pictureId,
    this.boardWidgets = const [],
  });

  factory BoardWidgetApp.fromJson(Map<String, dynamic> json) {
    return BoardWidgetApp(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      pictureId: json['picture'] as String?,
      boardWidgets:
          (json['board_widgets'] as List<dynamic>?)
              ?.map(
                (e) =>
                    BoardWidgetDefinition.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

@riverpod
Future<List<BoardWidgetApp>> boardWidgetApps(Ref ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get('/develop/apps/board');
  final list = response.data as List<dynamic>;
  return list
      .map((e) => BoardWidgetApp.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// Renders a list of board items for an account.
class AccountBoard extends StatelessWidget {
  final SnAccount account;
  final List<AccountBoardItem> items;
  final String uname;
  final List<SnPublisher> publishers;
  final bool isCompact;

  const AccountBoard({
    super.key,
    required this.account,
    required this.items,
    required this.uname,
    this.publishers = const [],
    this.isCompact = false,
  });

  static List<AccountBoardItem> defaultBoard() {
    return const [
      AccountBoardItem(
        order: 0,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'activity',
      ),
      AccountBoardItem(
        order: 1,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'badges',
      ),
      AccountBoardItem(
        order: 2,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'leveling',
      ),
      AccountBoardItem(
        order: 3,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'social_credits',
      ),
      AccountBoardItem(
        order: 4,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'contacts',
      ),
      AccountBoardItem(
        order: 5,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'publishers',
      ),
      AccountBoardItem(
        order: 6,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'notable_days',
      ),
      AccountBoardItem(
        order: 7,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'verification',
      ),
      AccountBoardItem(
        order: 8,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'links',
      ),
      AccountBoardItem(
        order: 9,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: 'fortune',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = [...items]..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sortedItems
          .where((item) => item.isEnabled)
          .map((item) => _buildItem(context, item))
          .toList(),
    );
  }

  Widget _buildItem(BuildContext context, AccountBoardItem item) {
    if (item.kind == BoardWidgetKind.customApp) {
      return _CustomAppBoardWidget(
        appId: item.customAppId ?? '',
        widgetKey: item.customAppWidgetKey ?? '',
        background: item.payload['background'] as String?,
        image: item.payload['image'] as String?,
      );
    }

    final widgetKey = item.widgetKey ?? '';
    final payload = item.payload;
    final background = payload['background'] as String?;
    final image = payload['image'] as String?;

    return _BoardWidgetCard(
      background: background,
      image: image,
      isCompact: isCompact,
      child: switch (widgetKey) {
        'badges' => _BadgesBoardWidget(
          badges: account.badges,
          showCount: payload['show_count'] as bool? ?? true,
        ),
        'bio' => _BioBoardWidget(
          bio: account.profile.bio,
          maxLines: payload['max_lines'] as int? ?? 5,
        ),
        'links' => _LinksBoardWidget(
          links: account.profile.links,
          showIcons: payload['show_icons'] as bool? ?? true,
        ),
        'notable_days' => _NotableDaysBoardWidget(
          account: account,
          showBirthday: payload['show_birthday'] as bool? ?? true,
          showJoined: payload['show_joined'] as bool? ?? true,
        ),
        'social_credits' => _SocialCreditsBoardWidget(
          credits: account.profile.socialCredits,
          creditsLevel: account.profile.socialCreditsLevel,
          showGraph: payload['show_graph'] as bool? ?? false,
        ),
        'leveling' => _LevelingBoardWidget(
          level: account.profile.level,
          experience: account.profile.experience,
          progress: account.profile.levelingProgress,
        ),
        'verification' => _VerificationBoardWidget(
          verification: account.profile.verification,
        ),
        'contacts' => _ContactsBoardWidget(contacts: account.contacts),
        'publishers' => _PublishersBoardWidget(publishers: publishers),
        'fortune' => _FortuneBoardWidget(
          uname: uname,
          accountName: account.name,
        ),
        'activity' => _ActivityBoardWidget(uname: uname),
        _ => _UnknownWidget(keyLabel: widgetKey),
      },
    );
  }
}

class _BoardWidgetCard extends StatelessWidget {
  final String? background;
  final String? image;
  final Widget child;
  final bool isCompact;

  const _BoardWidgetCard({
    this.background,
    this.image,
    required this.child,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = child;

    if (image != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CloudImageWidget(
              fileId: image,
              fit: BoxFit.cover,
              aspectRatio: 16 / 5,
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      );
    } else {
      content = Padding(padding: const EdgeInsets.all(16), child: child);
    }

    if (background != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CloudImageWidget(fileId: background, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            elevation: 0,
            child: content,
          ),
        ],
      );
    }

    return Card(margin: EdgeInsets.zero, child: content);
  }
}

class _BadgesBoardWidget extends StatelessWidget {
  final List<SnAccountBadge> badges;
  final bool showCount;

  const _BadgesBoardWidget({required this.badges, this.showCount = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Symbols.stars, size: 18, color: theme.colorScheme.primary),
            const Gap(8),
            Text(
              'badges'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showCount && badges.isNotEmpty) ...[
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${badges.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (badges.isNotEmpty) ...[
          const Gap(12),
          BadgeList(badges: badges),
        ] else ...[
          const Gap(8),
          Text(
            'badgesNone'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _BioBoardWidget extends StatelessWidget {
  final String bio;
  final int maxLines;

  const _BioBoardWidget({required this.bio, this.maxLines = 5});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.description,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const Gap(8),
            Text(
              'bio',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).tr(),
          ],
        ),
        const Gap(8),
        if (bio.isNotEmpty)
          MarkdownTextContent(content: bio, linesMargin: EdgeInsets.zero)
        else
          Text(
            'bioEmpty'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _LinksBoardWidget extends StatelessWidget {
  final List<ProfileLink> links;
  final bool showIcons;

  const _LinksBoardWidget({required this.links, this.showIcons = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Symbols.link, size: 18, color: theme.colorScheme.primary),
            const Gap(8),
            Text(
              'links'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (links.isNotEmpty) ...[
          const Gap(12),
          Column(
            spacing: 8,
            children: links
                .map(
                  (link) => _LinkTile(
                    name: link.name.capitalizeEachWord(),
                    url: link.url,
                    showIcon: showIcons,
                  ),
                )
                .toList(),
          ),
        ] else ...[
          const Gap(8),
          Text(
            'linksEmpty'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  final String name;
  final String url;
  final bool showIcon;

  const _LinkTile({
    required this.name,
    required this.url,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        final target = (!url.startsWith('http') && !url.contains('://'))
            ? 'https://$url'
            : url;
        launchUrlString(target);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (showIcon)
              Icon(
                Symbols.open_in_new,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            if (showIcon) const Gap(8),
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Symbols.arrow_outward,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotableDaysBoardWidget extends StatelessWidget {
  final SnAccount account;
  final bool showBirthday;
  final bool showJoined;

  const _NotableDaysBoardWidget({
    required this.account,
    this.showBirthday = true,
    this.showJoined = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.calendar_today,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const Gap(8),
            Text(
              'notableDay'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (showJoined)
              _NotableDayChip(
                icon: Symbols.calendar_month,
                label: 'joinedAt'.tr(
                  args: [account.createdAt.formatCustom('yyyy-MM-dd')],
                ),
              ),
            if (showBirthday && account.profile.birthday != null) ...[
              _NotableDayChip(
                icon: Symbols.cake,
                label: account.profile.birthday!.formatCustom('yyyy-MM-dd'),
              ),
              _NotableDayChip(
                icon: Symbols.timer,
                label:
                    '${now.difference(account.profile.birthday!).inDays ~/ 365} yrs',
              ),
            ],
            if (account.profile.timeZone.isNotEmpty)
              _NotableDayChip(
                icon: Symbols.schedule,
                label: account.profile.timeZone,
              ),
          ],
        ),
      ],
    );
  }
}

class _NotableDayChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NotableDayChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialCreditsBoardWidget extends StatelessWidget {
  final double credits;
  final int creditsLevel;
  final bool showGraph;

  const _SocialCreditsBoardWidget({
    required this.credits,
    required this.creditsLevel,
    this.showGraph = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelLabel = switch (creditsLevel) {
      -1 => 'socialCreditsLevelPoor'.tr(),
      0 => 'socialCreditsLevelNormal'.tr(),
      1 => 'socialCreditsLevelGood'.tr(),
      2 => 'socialCreditsLevelExcellent'.tr(),
      _ => 'unknown'.tr(),
    };
    final levelColor = switch (creditsLevel) {
      -1 => Colors.red,
      1 => Colors.green,
      2 => Colors.amber.shade700,
      _ => theme.colorScheme.primary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.attribution,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const Gap(8),
            Text(
              'socialCredits'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          spacing: 12,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Symbols.stars, color: levelColor, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  credits.toStringAsFixed(2),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
                Text(
                  levelLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (showGraph) ...[
          const Gap(16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: (credits / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(levelColor),
            ),
          ),
        ],
      ],
    );
  }
}

class _LevelingBoardWidget extends StatelessWidget {
  final int level;
  final int experience;
  final double progress;

  const _LevelingBoardWidget({
    required this.level,
    required this.experience,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.trending_up,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const Gap(8),
            Text(
              'leveling'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Gap(12),
        Row(
          spacing: 12,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$level',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'levelingProgressLevel'.tr(args: ['$level']),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    '${_formatExp(experience)} XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatExp(int exp) {
    if (exp >= 1000000) return '${(exp / 1000000).toStringAsFixed(1)}M';
    if (exp >= 1000) return '${(exp / 1000).toStringAsFixed(1)}K';
    return exp.toString();
  }
}

class _VerificationBoardWidget extends StatelessWidget {
  final SnVerificationMark? verification;

  const _VerificationBoardWidget({this.verification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Symbols.verified, size: 18, color: theme.colorScheme.primary),
            const Gap(8),
            Text(
              'verification'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Gap(12),
        if (verification != null)
          VerificationStatusCard(mark: verification!)
        else
          Text(
            'verificationNone'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _ContactsBoardWidget extends StatelessWidget {
  final List<dynamic> contacts;

  const _ContactsBoardWidget({required this.contacts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final publicContacts = contacts.where((c) => c.isPublic).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.contact_phone,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const Gap(8),
            Text(
              'contactMethod',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).tr(),
          ],
        ),
        if (publicContacts.isNotEmpty) ...[
          const Gap(12),
          Column(
            spacing: 8,
            children: publicContacts
                .map((contact) => _BoardContactTile(contact: contact))
                .toList(),
          ),
        ] else ...[
          const Gap(8),
          Text(
            'contactsEmpty'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _BoardContactTile extends StatelessWidget {
  final dynamic contact;

  const _BoardContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconData = switch (contact.type) {
      0 => Symbols.mail,
      1 => Symbols.phone,
      _ => Symbols.home,
    };
    final typeLabel = switch (contact.type) {
      0 => 'contactMethodTypeEmail'.tr(),
      1 => 'contactMethodTypePhone'.tr(),
      _ => 'contactMethodTypeAddress'.tr(),
    };

    return InkWell(
      onTap: () {
        switch (contact.type) {
          case 0:
            launchUrlString('mailto:${contact.content}');
          case 1:
            launchUrlString('tel:${contact.content}');
          default:
            Clipboard.setData(ClipboardData(text: contact.content));
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(iconData, size: 16, color: theme.colorScheme.primary),
            const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    typeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Symbols.chevron_right,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishersBoardWidget extends StatelessWidget {
  final List<SnPublisher> publishers;

  const _PublishersBoardWidget({required this.publishers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Symbols.smart_toy, size: 18, color: theme.colorScheme.primary),
            const Gap(8),
            Text(
              'publishers'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (publishers.isNotEmpty) ...[
          const Gap(12),
          Column(
            spacing: 8,
            children: publishers
                .map((p) => _BoardPublisherTile(publisher: p))
                .toList(),
          ),
        ] else ...[
          const Gap(8),
          Text(
            'descriptionNone'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _BoardPublisherTile extends StatelessWidget {
  final SnPublisher publisher;

  const _BoardPublisherTile({required this.publisher});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: ProfilePictureWidget(file: publisher.picture, radius: 18),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              publisher.nick,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FortuneBoardWidget extends HookConsumerWidget {
  final String uname;
  final String accountName;

  const _FortuneBoardWidget({required this.uname, required this.accountName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final events = ref.watch(
      eventCalendarProvider(
        EventCalendarQuery(uname: uname, year: now.year, month: now.month),
      ),
    );

    return FortuneGraphWidget(
      events: events,
      eventCalandarUser: accountName,
      margin: EdgeInsets.zero,
      noPadding: true,
    );
  }
}

class _ActivityBoardWidget extends HookConsumerWidget {
  final String uname;

  const _ActivityBoardWidget({required this.uname});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activitiesAsync = ref.watch(presenceActivitiesProvider(uname));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Symbols.podcasts, size: 18, color: theme.colorScheme.primary),
            const Gap(8),
            Text(
              'activityPresence',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).tr(),
          ],
        ),
        const Gap(12),
        activitiesAsync.when(
          data: (activities) {
            if (activities.isEmpty) {
              return Text(
                'activityPresenceEmpty'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return ActivityPresenceWidget(uname: uname);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CustomAppBoardWidget extends StatelessWidget {
  final String appId;
  final String widgetKey;
  final String? background;
  final String? image;

  const _CustomAppBoardWidget({
    required this.appId,
    required this.widgetKey,
    this.background,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Symbols.extension,
                    size: 20,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'boardCustomAppWidget'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$appId / $widgetKey',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(12),
            Text(
              'boardCustomAppWidgetDescription'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnknownWidget extends StatelessWidget {
  final String keyLabel;

  const _UnknownWidget({required this.keyLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.question_mark,
              size: 18,
              color: theme.colorScheme.error,
            ),
            const Gap(8),
            Text(
              'boardUnknownWidget'.tr(args: [keyLabel]),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
