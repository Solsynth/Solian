import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
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
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';
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
      'kind': kind.index,
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
  final String name;
  final String? description;
  final bool isEnabled;
  final String rendererType;
  final List<BoardWidgetField> fieldTypes;
  final List<String> requiredFields;
  final int? maxPayloadBytes;
  final bool allowMultiple;

  const BoardWidgetDefinition({
    required this.key,
    required this.name,
    this.description,
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
      name: json['name'] as String? ?? json['key'] as String? ?? '',
      description: json['description'] as String?,
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

List<AccountBoardItem> parseAccountBoardItems(List<dynamic> list) {
  final items = <AccountBoardItem>[];

  for (final json in list) {
    final map = Map<String, dynamic>.from(json as Map);
    final payloadRaw = map['payload'];

    items.add(
      AccountBoardItem(
        id: map['id'] as String?,
        order: map['order'] as int? ?? 0,
        kind: BoardWidgetKind.values[map['kind'] as int? ?? 0],
        widgetKey: map['widget_key'] as String?,
        customAppId: map['custom_app_id'] as String?,
        customAppWidgetKey: map['custom_app_widget_key'] as String?,
        isEnabled: map['is_enabled'] as bool? ?? true,
        payload: payloadRaw is Map<String, dynamic>
            ? payloadRaw
            : payloadRaw is Map
            ? Map<String, dynamic>.from(payloadRaw)
            : const {},
      ),
    );
  }

  items.sort((a, b) => a.order.compareTo(b.order));
  return items;
}

final myAccountBoardProvider = FutureProvider<List<AccountBoardItem>>((
  ref,
) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get('/passport/accounts/me/board');
  final list = response.data as List<dynamic>;
  return parseAccountBoardItems(list);
});

final accountBoardProvider =
    FutureProvider.family<List<AccountBoardItem>, String>((ref, uname) async {
      final dio = ref.watch(apiClientProvider);
      final response = await dio.get('/passport/accounts/$uname/board');
      final list = response.data as List<dynamic>;
      return parseAccountBoardItems(list);
    });

String? _payloadStringValue(Map<String, dynamic> payload, String key) {
  final value = payload[key];
  if (value is String) return value;
  if (value is Map && value['value'] is String) {
    return value['value'] as String;
  }
  return null;
}

List<String> _payloadFileIds(Map<String, dynamic> payload) {
  final fileIds = payload['file_ids'];
  if (fileIds is List) {
    final ids = fileIds.whereType<String>().toList();
    if (ids.isNotEmpty) return ids;
  }
  return [if (payload['file_id'] is String) payload['file_id'] as String];
}

final _boardImageFilesProvider = FutureProvider.autoDispose
    .family<List<SnCloudFile>, String>((ref, fileIdsKey) async {
      return ref
          .watch(solarNetworkClientProvider)
          .drive
          .getFiles(fileIdsKey.split(','));
    });

bool _isRemoteImageUri(String? value) {
  if (value == null || value.isEmpty) return false;
  final uri = Uri.tryParse(value);
  return uri != null &&
      uri.hasScheme &&
      (uri.scheme == 'http' || uri.scheme == 'https');
}

class _BoardImageView extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final double? aspectRatio;

  const _BoardImageView({
    required this.source,
    this.fit = BoxFit.cover,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final child = _isRemoteImageUri(source)
        ? CachedNetworkImage(imageUrl: source, fit: fit)
        : CloudImageWidget(fileId: source, fit: fit);

    if (aspectRatio != null) {
      return AspectRatio(aspectRatio: aspectRatio!, child: child);
    }
    return child;
  }
}

class _BoardProfileImageView extends StatelessWidget {
  final String source;
  final double radius;
  final bool isSquare;

  const _BoardProfileImageView({
    required this.source,
    required this.radius,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) {
    if (_isRemoteImageUri(source)) {
      if (isSquare) {
        return SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: CachedNetworkImage(imageUrl: source),
        );
      }
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(source),
      );
    }
    if (isSquare) {
      return SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: CloudImageWidget(fileId: source),
      );
    }
    return ProfilePictureWidget(fileId: source, radius: radius);
  }
}

Map<String, dynamic>? _payloadFieldValue(
  Map<String, dynamic> payload,
  String key,
) {
  final value = payload[key];
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

bool _isReservedPayloadField(String key) =>
    key == 'image' || key == 'background';

final boardWidgetDefinitionProvider =
    FutureProvider.family<
      ({BoardWidgetApp app, BoardWidgetDefinition definition})?,
      ({String appId, String widgetKey})
    >((ref, arg) async {
      final apps = await ref.watch(boardWidgetAppsProvider.future);
      for (final app in apps) {
        if (app.id != arg.appId) continue;
        for (final definition in app.boardWidgets) {
          if (definition.key == arg.widgetKey) {
            return (app: app, definition: definition);
          }
        }
      }
      return null;
    });

@riverpod
Future<List<BoardWidgetApp>> boardWidgetApps(Ref ref) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get('/develop/apps/board');
  final list = response.data as List<dynamic>;
  return list
      .map((e) => BoardWidgetApp.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<BoardWidgetApp?> boardWidgetByAppSlug(Ref ref, String slug) async {
  final dio = ref.watch(apiClientProvider);
  final response = await dio.get(
    '/develop/apps/board',
    queryParameters: {'slug': slug},
  );
  final list = response.data as List<dynamic>;
  if (list.isEmpty) return null;
  return BoardWidgetApp.fromJson(list.first as Map<String, dynamic>);
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
      final payload = item.payload;
      if (item.customAppId == null && item.customAppWidgetKey == 'text') {
        return _BoardWidgetCard(
          background: _payloadStringValue(payload, 'background'),
          image: _payloadStringValue(payload, 'image'),
          isCompact: isCompact,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: MarkdownTextContent(
              content: _payloadStringValue(payload, 'content') ?? '',
            ),
          ),
        );
      }
      if (item.customAppId == null && item.customAppWidgetKey == 'attachment') {
        final fileIds = (payload['file_ids'] is List)
            ? (payload['file_ids'] as List).whereType<String>().toList()
            : [if (payload['file_id'] is String) payload['file_id'] as String];
        return _BoardWidgetCard(
          background: _payloadStringValue(payload, 'background'),
          image: _payloadStringValue(payload, 'image'),
          isCompact: isCompact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: fileIds
                .map(
                  (id) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CloudImageWidget(fileId: id),
                  ),
                )
                .toList(),
          ),
        );
      }
      return _CustomAppBoardWidget(
        appId: item.customAppId ?? '',
        widgetKey: item.customAppWidgetKey ?? '',
        background: _payloadStringValue(payload, 'background'),
        image: _payloadStringValue(payload, 'image'),
        payload: payload,
        isConfigured: payload.isNotEmpty,
      );
    }

    final widgetKey = item.widgetKey ?? '';
    final payload = item.payload;
    final background = _payloadStringValue(payload, 'background');
    final image = _payloadStringValue(payload, 'image');

    final hasPadding = item.kind == .prebuilt && widgetKey != 'image';

    return _BoardWidgetCard(
      background: background,
      image: image,
      isCompact: isCompact,
      child: Padding(
        padding: hasPadding ? const EdgeInsets.all(16) : .zero,
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
          'text' => MarkdownTextContent(
            content: _payloadStringValue(payload, 'content') ?? '',
          ),
          'image' => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_ImageBoardWidget(fileIds: _payloadFileIds(payload))],
          ),
          _ => _UnknownWidget(keyLabel: widgetKey),
        },
      ),
    );
  }
}

class _ImageBoardWidget extends ConsumerWidget {
  final List<String> fileIds;

  const _ImageBoardWidget({required this.fileIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (fileIds.isEmpty) return const SizedBox.shrink();

    final files = ref.watch(_boardImageFilesProvider(fileIds.join(',')));

    return files.when(
      data: (files) => CloudFileList(
        files: files,
        maxWidth: double.infinity,
        borderRadius: 12,
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
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
    final imageSource = image;
    final backgroundSource = background;

    Widget content = child;

    if (imageSource != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: _BoardImageView(
              source: imageSource,
              fit: BoxFit.cover,
              aspectRatio: 16 / 5,
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      );
    } else {
      content = child;
    }

    if (backgroundSource != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _BoardImageView(
                source: backgroundSource,
                fit: BoxFit.cover,
              ),
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

  String _displayUrl(String url) {
    try {
      final target = (!url.startsWith('http') && !url.contains('://'))
          ? 'https://$url'
          : url;
      final uri = Uri.parse(target);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showIcon)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Symbols.open_in_new,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
            if (showIcon) const Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Text(
                    _displayUrl(url),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Symbols.arrow_outward,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
          VerificationStatusCard(mark: verification!, noPadding: true)
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

    return InkWell(
      onTap: () {
        context.router.push(PublisherProfileRoute(name: publisher.name));
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
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

class _CustomPayloadField {
  final String name;
  final String label;
  final Object? value;

  const _CustomPayloadField({
    required this.name,
    required this.label,
    required this.value,
  });
}

List<_CustomPayloadField> _collectCustomPayloadFields(
  Map<String, dynamic> payload,
  BoardWidgetDefinition definition,
) {
  final fields = <_CustomPayloadField>[];
  final seenKeys = <String>{};

  for (final field in definition.fieldTypes) {
    if (_isReservedPayloadField(field.name)) continue;
    final payloadField = _payloadFieldValue(payload, field.name);
    if (payloadField == null) continue;
    fields.add(
      _CustomPayloadField(
        name: field.name,
        label: (payloadField['label'] as String?) ?? field.label,
        value: payloadField['value'],
      ),
    );
    seenKeys.add(field.name);
  }

  for (final entry in payload.entries) {
    if (_isReservedPayloadField(entry.key) || seenKeys.contains(entry.key)) {
      continue;
    }
    final payloadField = _payloadFieldValue(payload, entry.key);
    if (payloadField == null) continue;
    fields.add(
      _CustomPayloadField(
        name: entry.key,
        label: (payloadField['label'] as String?) ?? entry.key,
        value: payloadField['value'],
      ),
    );
  }

  return fields;
}

String _stringifyCustomPayloadValue(Object? value) {
  if (value == null) return '-';
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  if (value is Map<String, dynamic> && value['value'] != null) {
    return _stringifyCustomPayloadValue(value['value']);
  }
  if (value is List<dynamic>) {
    return value.map((e) => '·  ${e.toString()}').join('\n');
  }
  return value.toString();
}

class _CustomAppBoardWidget extends ConsumerWidget {
  final String appId;
  final String widgetKey;
  final String? background;
  final String? image;
  final Map<String, dynamic> payload;
  final bool isConfigured;

  const _CustomAppBoardWidget({
    required this.appId,
    required this.widgetKey,
    this.background,
    this.image,
    required this.payload,
    this.isConfigured = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final definitionAsync = ref.watch(
      boardWidgetDefinitionProvider((appId: appId, widgetKey: widgetKey)),
    );

    return _BoardWidgetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildCustomContent(context, theme, definitionAsync)],
      ),
    );
  }

  Widget _buildCustomContent(
    BuildContext context,
    ThemeData theme,
    AsyncValue<({BoardWidgetApp app, BoardWidgetDefinition definition})?>
    definitionAsync,
  ) {
    if (!isConfigured) {
      return Text(
        'boardWidgetNotConfigured'.tr(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }

    return definitionAsync.when(
      data: (resolved) {
        if (resolved == null) {
          return Text(
            'boardCustomAppWidgetDescription'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        final fields = _collectCustomPayloadFields(
          payload,
          resolved.definition,
        );
        if (fields.isEmpty) {
          return Text(
            'boardWidgetNotConfigured'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          );
        }

        final footer = _CustomWidgetFooter(
          text: [resolved.app.name, resolved.definition.name].join(' · '),
          description: resolved.definition.description,
          layout: resolved.definition.rendererType,
        );

        return switch (resolved.definition.rendererType) {
          'hero' => _CustomHeroBoardLayout(
            fields: fields,
            background: background,
            image: image,
            footer: footer,
          ),
          'inline' => _CustomInlineBoardLayout(
            fields: fields,
            image: image,
            footer: footer,
          ),
          'grid' => _CustomGridBoardLayout(
            fields: fields,
            background: background,
            image: image,
            footer: footer,
          ),
          'data' => _CustomDataBoardLayout(
            fields: fields,
            image: image,
            footer: footer,
          ),
          'list' => _CustomListBoardLayout(
            fields: fields,
            image: image,
            footer: footer,
          ),
          _ => _CustomListBoardLayout(
            fields: fields,
            image: image,
            footer: footer,
          ),
        };
      },
      loading: () => Text(
        'loading'.tr(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      error: (_, _) => Text(
        'boardCustomAppWidgetDescription'.tr(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CustomHeroBoardLayout extends StatelessWidget {
  final List<_CustomPayloadField> fields;
  final String? background;
  final String? image;
  final Widget footer;

  const _CustomHeroBoardLayout({
    required this.fields,
    this.background,
    this.image,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heroField = fields.first;
    final remainingCount = fields.length - 1;
    final backgroundSource = background;
    final imageSource = image;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (imageSource != null) ...[
          Align(
            alignment: .centerLeft,
            child: _BoardProfileImageView(source: imageSource, radius: 28),
          ),
          const Gap(12),
        ],
        Text(
          heroField.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: backgroundSource != null
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(4),
        Text(
          _stringifyCustomPayloadValue(heroField.value),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        if (remainingCount > 0) ...[
          const Gap(8),
          Text(
            '+$remainingCount',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const Gap(6),
        footer,
      ],
    );

    if (backgroundSource != null) {
      return Container(
        constraints: const BoxConstraints(minHeight: 132),
        child: Stack(
          children: [
            Positioned.fill(
              child: _BoardImageView(
                source: backgroundSource,
                fit: BoxFit.cover,
              ).clipRRect(all: 8),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.08),
                      theme.colorScheme.surface.withOpacity(0.82),
                    ],
                  ),
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(12), child: body),
          ],
        ),
      );
    }

    return body;
  }
}

class _CustomInlineBoardLayout extends StatelessWidget {
  final List<_CustomPayloadField> fields;
  final String? image;
  final Widget footer;

  const _CustomInlineBoardLayout({
    required this.fields,
    this.image,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mainField = fields.first;
    final remainingCount = fields.length - 1;
    final imageSource = image;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (imageSource != null) ...[
          _BoardProfileImageView(
            source: imageSource,
            radius: 44,
            isSquare: true,
          ).clipRRect(topLeft: 8, bottomLeft: 8),
          const Gap(12),
        ],
        Expanded(
          child: SizedBox(
            height: 44 * 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainField.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _stringifyCustomPayloadValue(mainField.value),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (remainingCount > 0) ...[
                      const Gap(6),
                      Flexible(
                        child: Text(
                          '+$remainingCount',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(6),
                const Spacer(),
                Align(alignment: .bottomLeft, child: footer),
              ],
            ).padding(vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _CustomDataBoardLayout extends StatelessWidget {
  final List<_CustomPayloadField> fields;
  final String? image;
  final Widget footer;

  const _CustomDataBoardLayout({
    required this.fields,
    this.image,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageSource = image;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (imageSource != null)
              Container(
                constraints: const BoxConstraints(minWidth: 132, maxWidth: 220),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _BoardImageView(
                  source: imageSource,
                  fit: BoxFit.cover,
                  aspectRatio: 1,
                ),
              ),
            ...fields.map(
              (field) => Container(
                constraints: const BoxConstraints(minWidth: 132, maxWidth: 220),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.45,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _stringifyCustomPayloadValue(field.value),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const Gap(8),
        footer,
      ],
    );
  }
}

class _CustomGridBoardLayout extends StatelessWidget {
  final List<_CustomPayloadField> fields;
  final String? background;
  final String? image;
  final Widget footer;

  const _CustomGridBoardLayout({
    required this.fields,
    this.background,
    this.image,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleFields = _buildGridFields(fields).take(6).toList();
    final backgroundSource = background;
    final imageSource = image;
    final rows = <List<_CustomPayloadField>>[];

    for (var i = 0; i < visibleFields.length; i += 3) {
      rows.add(
        visibleFields.sublist(
          i,
          i + 3 > visibleFields.length ? visibleFields.length : i + 3,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (backgroundSource != null || imageSource != null) ...[
          SizedBox(
            height: 132,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (backgroundSource != null)
                  _BoardImageView(
                    source: backgroundSource,
                    fit: BoxFit.cover,
                  ).clipRRect(topLeft: 8, topRight: 8)
                else
                  Container(color: theme.colorScheme.surfaceContainerHighest),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.08),
                        Colors.black.withOpacity(0.28),
                      ],
                    ),
                  ),
                ),
                if (imageSource != null)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: _BoardImageView(
                          source: imageSource,
                          fit: BoxFit.cover,
                        ).clipRRect(all: 99),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(12),
        ],
        Column(
          mainAxisSize: MainAxisSize.min,
          children: rows
              .asMap()
              .entries
              .map(
                (entry) => Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key == rows.length - 1 ? 0 : 10,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (
                        var index = 0;
                        index < entry.value.length;
                        index++
                      ) ...[
                        if (index > 0) const Gap(10),
                        Expanded(
                          child: _CustomGridFieldTile(
                            field: entry.value[index],
                            theme: theme,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .toList(),
        ).padding(horizontal: 8),
        const Gap(8),
        footer.padding(horizontal: 18, vertical: 8),
      ],
    );
  }
}

class _CustomGridFieldTile extends StatelessWidget {
  final _CustomPayloadField field;
  final ThemeData theme;

  const _CustomGridFieldTile({required this.field, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 56),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              field.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(4),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _CustomPayloadValueView(
                  value: field.value,
                  maxLines: 2,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<_CustomPayloadField> _buildGridFields(List<_CustomPayloadField> fields) {
  final expanded = <_CustomPayloadField>[];

  for (final field in fields) {
    if (field.name == 'data' && field.value is Map) {
      final entries = Map<String, dynamic>.from(field.value as Map).entries;
      for (final entry in entries) {
        expanded.add(
          _CustomPayloadField(
            name: entry.key,
            label: entry.key,
            value: entry.value,
          ),
        );
      }
      continue;
    }

    expanded.add(field);
  }

  return expanded;
}

class _CustomListBoardLayout extends StatelessWidget {
  final List<_CustomPayloadField> fields;
  final String? image;
  final Widget footer;

  const _CustomListBoardLayout({
    required this.fields,
    this.image,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final imageSource = image;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imageSource != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _BoardImageView(
              source: imageSource,
              fit: BoxFit.cover,
              aspectRatio: 16 / 7,
            ),
          ),
          const Gap(12),
        ],
        ...fields.map(
          (field) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CustomFieldRow(field: field),
          ),
        ),
        footer,
      ],
    );
  }
}

class _CustomWidgetFooter extends StatelessWidget {
  final String text;
  final String? description;
  final String layout;

  const _CustomWidgetFooter({
    required this.text,
    this.description,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: [
        'boardCustomAppWidgetFooterProvided'.tr(),
        if (description != null && description!.trim().isNotEmpty)
          description!.trim(),
        if (kDebugMode)
          'boardCustomAppWidgetFooterLayout'.tr(
            args: [layout.isEmpty ? 'default' : layout],
          ),
      ].join('\n'),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CustomFieldRow extends StatelessWidget {
  final _CustomPayloadField field;

  const _CustomFieldRow({required this.field});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            field.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: _CustomPayloadValueView(
              value: field.value,
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomPayloadValueView extends StatelessWidget {
  final Object? value;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final int? maxLines;

  const _CustomPayloadValueView({
    required this.value,
    this.textAlign = TextAlign.left,
    this.textStyle,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle =
        textStyle ??
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);

    if (value is List) {
      final items = value as List;
      return Column(
        crossAxisAlignment: textAlign == TextAlign.right
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _CustomPayloadValueView(
                  value: item,
                  textAlign: textAlign,
                  textStyle: effectiveStyle,
                  maxLines: maxLines,
                ),
              ),
            )
            .toList(),
      );
    }

    if (value is Map) {
      final entries = Map<String, dynamic>.from(value as Map).entries.toList();
      return Column(
        crossAxisAlignment: textAlign == TextAlign.right
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: effectiveStyle,
                      textAlign: textAlign,
                    ),
                    Flexible(
                      child: _CustomPayloadValueView(
                        value: entry.value,
                        textAlign: textAlign,
                        textStyle: effectiveStyle,
                        maxLines: maxLines,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    }

    return Text(
      _stringifyCustomPayloadValue(value),
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
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
