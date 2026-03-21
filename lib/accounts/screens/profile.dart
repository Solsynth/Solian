import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/activity_presence.dart';
import 'package:island/accounts/widgets/account/badge.dart';
import 'package:island/accounts/widgets/account/fortune_graph.dart';
import 'package:island/accounts/widgets/account/leveling_progress.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/developers/models/developer.dart';
import 'package:island/core/config.dart';
import 'package:island/accounts/event_calendar.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/services/color.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/services/timezone/native.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/services/color_extraction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'profile.g.dart';

class _AccountBasicInfo extends StatelessWidget {
  final SnAccount data;
  final String uname;
  final AsyncValue<SnDeveloper?> accountDeveloper;

  const _AccountBasicInfo({
    required this.data,
    required this.uname,
    required this.accountDeveloper,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBackground = data.profile.background != null;
    final showBackground = isWideScreen(context) && hasBackground;

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showBackground)
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 7,
                    child: CloudImageWidget(
                      file: data.profile.background,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -24,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 3,
                      ),
                    ),
                    child: ProfilePictureWidget(
                      file: data.profile.picture,
                      radius: 32,
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: EdgeInsets.all(showBackground ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!showBackground)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: ProfilePictureWidget(
                          file: data.profile.picture,
                          radius: 40,
                        ),
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(12),
                          Row(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Flexible(
                                child: AccountName(
                                  account: data,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '@${data.name}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(4),
                          AccountStatusWidget(
                            uname: uname,
                            padding: EdgeInsets.zero,
                          ),
                          if (accountDeveloper.value != null) ...[
                            const Gap(12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 8,
                                children: [
                                  Icon(
                                    Symbols.smart_toy,
                                    size: 18,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                  Text(
                                    'botAutomatedBy'.tr(
                                      args: [
                                        accountDeveloper.value!.publisher!.nick,
                                      ],
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          SharePlus.instance.share(
                            ShareParams(
                              uri: Uri.parse(
                                'https://solian.app/@${data.name}',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Symbols.share,
                          color: theme.colorScheme.primary,
                        ),
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
  }
}

class _AccountProfileBio extends StatelessWidget {
  final SnAccount data;

  const _AccountProfileBio({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Symbols.article,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(12),
                Text(
                  'bio',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ).tr(),
              ],
            ),
            const Gap(16),
            if (data.profile.bio.isEmpty)
              Text(
                'descriptionNone',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ).tr()
            else
              MarkdownTextContent(
                content: data.profile.bio,
                linesMargin: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}

class _AccountProfileDetail extends StatelessWidget {
  final SnAccount data;

  const _AccountProfileDetail({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Symbols.badge,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(12),
                Text(
                  'about',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ).tr(),
              ],
            ),
            const Gap(12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _DetailChip(
                  icon: Symbols.calendar_month,
                  label: 'joinedAt'.tr(
                    args: [data.createdAt.formatCustom('yyyy-MM-dd')],
                  ),
                ),
                if (data.profile.birthday != null)
                  _DetailChip(
                    icon: Symbols.cake,
                    label:
                        '${data.profile.birthday!.formatCustom('yyyy-MM-dd')} · ${DateTime.now().difference(data.profile.birthday!).inDays ~/ 365} yrs',
                  ),
                if (data.profile.firstName.isNotEmpty ||
                    data.profile.middleName.isNotEmpty ||
                    data.profile.lastName.isNotEmpty)
                  _DetailChip(
                    icon: Symbols.id_card,
                    label: [
                      data.profile.firstName,
                      data.profile.middleName,
                      data.profile.lastName,
                    ].where((s) => s.isNotEmpty).join(' '),
                  ),
                _DetailChip(
                  icon: Symbols.person,
                  label:
                      '${data.profile.gender.isEmpty ? 'unspecified'.tr() : data.profile.gender} · ${data.profile.pronouns.isEmpty ? 'unspecified'.tr() : data.profile.pronouns}',
                ),
                if (data.profile.location.isNotEmpty)
                  _DetailChip(
                    icon: Symbols.location_on,
                    label: data.profile.location,
                  ),
                Tooltip(
                  message: 'creditsStatus'.tr(),
                  child: _DetailChip(
                    icon: Symbols.attribution,
                    label:
                        '${data.profile.socialCredits.toStringAsFixed(2)} pts · ${_getCreditsLevelText(data.profile.socialCreditsLevel)}',
                  ),
                ),
                _DetailChip(
                  icon: Symbols.fingerprint,
                  label: data.id,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: data.id));
                  },
                ),
              ],
            ),
            if (data.profile.timeZone.isNotEmpty && !kIsWeb) ...[
              const Gap(16),
              Builder(
                builder: (context) {
                  try {
                    final tzInfo = getTzInfo(data.profile.timeZone);
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.schedule,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'timeZone',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ).tr(),
                                const Gap(4),
                                Row(
                                  spacing: 8,
                                  children: [
                                    Text(
                                      data.profile.timeZone,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tzInfo.$2.formatCustomGlobal('HH:mm'),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      'UTC${tzInfo.$1.formatOffset()}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
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
                  } catch (e) {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCreditsLevelText(int level) {
    switch (level) {
      case -1:
        return 'socialCreditsLevelPoor'.tr();
      case 0:
        return 'socialCreditsLevelNormal'.tr();
      case 1:
        return 'socialCreditsLevelGood'.tr();
      case 2:
        return 'socialCreditsLevelExcellent'.tr();
      default:
        return 'unknown'.tr();
    }
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DetailChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
      ),
    );
  }
}

class _AccountProfileLinks extends StatelessWidget {
  final SnAccount data;

  const _AccountProfileLinks({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Symbols.link,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(12),
                Text(
                  'links',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ).tr(),
              ],
            ),
            const Gap(12),
            Column(
              spacing: 8,
              children: data.profile.links
                  .map(
                    (link) => _LinkCard(
                      name: link.name.capitalizeEachWord(),
                      url: link.url,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String name;
  final String url;

  const _LinkCard({required this.name, required this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        if (!url.startsWith('http') && !url.contains('://')) {
          launchUrlString('https://$url');
        } else {
          launchUrlString(url);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Symbols.open_in_new,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    url,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Symbols.arrow_outward,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountProfileContacts extends StatelessWidget {
  final SnAccount data;

  const _AccountProfileContacts({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final publicContacts = data.contacts.where((c) => c.isPublic).toList();
    if (publicContacts.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Symbols.contact_phone,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(12),
                Text(
                  'contactMethod',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ).tr(),
              ],
            ),
            const Gap(12),
            Column(
              spacing: 8,
              children: publicContacts
                  .map((contact) => _ContactCard(contact: contact))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final dynamic contact;

  const _ContactCard({required this.contact});

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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, size: 18, color: theme.colorScheme.primary),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    typeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    contact.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Symbols.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountPublisherList extends StatelessWidget {
  final List<SnPublisher> publishers;

  const _AccountPublisherList({required this.publishers});

  @override
  Widget build(BuildContext context) {
    if (publishers.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Symbols.verified,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Gap(12),
                Text(
                  'publishers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ).tr(),
              ],
            ),
            const Gap(16),
            ...publishers.map(
              (publisher) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PublisherCard(
                  publisher: publisher,
                  onTap: () {
                    Navigator.pop(context, true);
                    context.router.push(
                      PublisherProfileRoute(name: publisher.name),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublisherCard extends StatelessWidget {
  final SnPublisher publisher;
  final VoidCallback onTap;

  const _PublisherCard({required this.publisher, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
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
              child: ProfilePictureWidget(file: publisher.picture, radius: 24),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    publisher.nick,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    publisher.bio.isNotEmpty
                        ? publisher.bio
                              .split('\n')
                              .where((line) => line.trim().isNotEmpty)
                              .join('\n')
                        : 'descriptionNone'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Symbols.chevron_right,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  final SnAccount data;
  final AsyncValue<SnRelationship?> accountRelationship;
  final AsyncValue<SnChatRoom?> accountChat;
  final VoidCallback relationshipAction;
  final VoidCallback blockAction;
  final VoidCallback directMessageAction;

  const _AccountAction({
    required this.data,
    required this.accountRelationship,
    required this.accountChat,
    required this.relationshipAction,
    required this.blockAction,
    required this.directMessageAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlocked =
        accountRelationship.value != null &&
        accountRelationship.value!.status <= -100;
    final isFriend =
        accountRelationship.value != null &&
        accountRelationship.value!.status > -100;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: isFriend
                      ? FilledButton.tonal(
                          onPressed: null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              const Icon(Symbols.person_check, size: 18),
                              Text('added').tr(),
                            ],
                          ),
                        )
                      : FilledButton.tonal(
                          onPressed: relationshipAction,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              const Icon(Symbols.person_add, size: 18),
                              Text('addFriendShort').tr(),
                            ],
                          ),
                        ),
                ),
                Expanded(
                  child: isBlocked
                      ? FilledButton.tonal(
                          onPressed: blockAction,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              const Icon(Symbols.person_cancel, size: 18),
                              Text('unblockUser').tr(),
                            ],
                          ),
                        )
                      : OutlinedButton(
                          onPressed: blockAction,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              const Icon(Symbols.block, size: 18),
                              Text('blockUser').tr(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: directMessageAction,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6,
                      children: [
                        const Icon(Symbols.chat, size: 18),
                        Text(
                          accountChat.value == null
                              ? 'createDirectMessage'
                              : 'gotoDirectMessage',
                          maxLines: 1,
                        ).tr(),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton.filled(
                    onPressed: () {
                      showAbuseReportSheet(
                        context,
                        resourceIdentifier: 'account/${data.id}',
                      );
                    },
                    icon: const Icon(Symbols.flag, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ),
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

@riverpod
Future<SnAccount> account(Ref ref, String uname) async {
  if (uname == 'me') {
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo.hasValue && userInfo.value != null) {
      return userInfo.value!;
    }
  }
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/passport/accounts/$uname");
  return SnAccount.fromJson(resp.data);
}

@riverpod
Future<List<SnAccountBadge>> accountBadges(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/passport/accounts/$uname/badges");
  return List<SnAccountBadge>.from(
    resp.data.map((x) => SnAccountBadge.fromJson(x)),
  );
}

@riverpod
Future<Color?> accountAppbarForcegroundColor(Ref ref, String uname) async {
  try {
    final account = await ref.watch(accountProvider(uname).future);
    if (account.profile.background == null) return null;
    final colors = await ColorExtractionService.getColorsFromImage(
      CloudImageWidget.provider(
        file: account.profile.background!,
        serverUrl: ref.watch(serverUrlProvider),
      ),
    );
    if (colors.isEmpty) return null;
    final dominantColor = colors.first;
    return dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  } catch (_) {
    return null;
  }
}

@riverpod
Future<SnChatRoom?> accountDirectChat(Ref ref, String uname) async {
  final userInfo = ref.watch(userInfoProvider);
  if (userInfo.value == null) return null;
  final account = await ref.watch(accountProvider(uname).future);
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get("/messager/chat/direct/${account.id}");
    return SnChatRoom.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<SnRelationship?> accountRelationship(Ref ref, String uname) async {
  final userInfo = ref.watch(userInfoProvider);
  if (userInfo.value == null) return null;
  final account = await ref.watch(accountProvider(uname).future);
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get("/passport/relationships/${account.id}");
    return SnRelationship.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<SnDeveloper?> accountBotDeveloper(Ref ref, String uname) async {
  final account = await ref.watch(accountProvider(uname).future);
  if (account.automatedId == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get(
      "/develop/bots/${account.automatedId}/developer",
    );
    return SnDeveloper.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<List<SnPublisher>> accountPublishers(Ref ref, String id) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get('/sphere/publishers/of/$id');
    return resp.data
        .map((e) => SnPublisher.fromJson(e))
        .cast<SnPublisher>()
        .toList();
  } catch (err) {
    return [];
  }
}

@RoutePage()
class AccountProfileScreen extends HookConsumerWidget {
  final String name;
  const AccountProfileScreen({
    super.key,
    @PathParam("name") required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    final account = ref.watch(accountProvider(name));
    final accountEvents = ref.watch(
      eventCalendarProvider(
        EventCalendarQuery(uname: name, year: now.year, month: now.month),
      ),
    );
    final accountChat = ref.watch(accountDirectChatProvider(name));
    final accountRelationship = ref.watch(accountRelationshipProvider(name));
    final accountDeveloper = ref.watch(accountBotDeveloperProvider(name));

    final appbarColor = ref.watch(accountAppbarForcegroundColorProvider(name));

    final appbarShadow = Shadow(
      color: appbarColor.value?.invert ?? Colors.transparent,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    Future<void> relationshipAction() async {
      if (accountRelationship.value != null) return;
      showLoadingModal(context);
      try {
        final client = ref.watch(apiClientProvider);
        await client.post(
          '/passport/relationships/${account.value!.id}/friends',
        );
        ref.invalidate(accountRelationshipProvider(name));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> blockAction() async {
      showLoadingModal(context);
      try {
        final client = ref.watch(apiClientProvider);
        if (accountRelationship.value == null) {
          await client.post(
            '/passport/relationships/${account.value!.id}/block',
          );
        } else {
          await client.delete(
            '/passport/relationships/${account.value!.id}/block',
          );
        }
        ref.invalidate(accountRelationshipProvider(name));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> directMessageAction() async {
      if (!account.hasValue) return;
      if (accountChat.value != null) {
        context.router.push(ChatRoomRoute(id: accountChat.value!.id));
        return;
      }
      showLoadingModal(context);
      try {
        final client = ref.watch(apiClientProvider);
        final resp = await client.post(
          '/messager/chat/direct',
          data: {'related_user_id': account.value!.id},
        );
        final chat = SnChatRoom.fromJson(resp.data);
        if (context.mounted) {
          context.router.push(ChatRoomRoute(id: chat.id));
        }
        ref.invalidate(accountDirectChatProvider(name));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    final user = ref.watch(userInfoProvider);
    final isCurrentUser = useMemoized(
      () => user.value?.id == account.value?.id,
      [user, account],
    );

    return account.when(
      data: (data) {
        final accountPublishers = ref.watch(accountPublishersProvider(data.id));
        return AppScaffold(
          isNoBackground: false,
          appBar: isWideScreen(context)
              ? AppBar(
                  foregroundColor: appbarColor.value,
                  leading: AutoLeadingButton(),
                  title: Text(
                    data.nick,
                    style: TextStyle(
                      color:
                          appbarColor.value ??
                          Theme.of(context).appBarTheme.foregroundColor,
                      shadows: [appbarShadow],
                    ),
                  ),
                )
              : null,
          body: isWideScreen(context)
              ? Row(
                  spacing: 12,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 12,
                          children: [
                            _AccountBasicInfo(
                              data: data,
                              uname: name,
                              accountDeveloper: accountDeveloper,
                            ),
                            if (data.badges.isNotEmpty)
                              Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: BadgeList(badges: data.badges),
                                ),
                              ),
                            Column(
                              spacing: 12,
                              children: [
                                LevelingProgressCard(
                                  level: data.profile.level,
                                  experience: data.profile.experience,
                                  progress: data.profile.levelingProgress,
                                ),
                                if (data.profile.verification != null)
                                  Card(
                                    margin: EdgeInsets.zero,
                                    child: VerificationStatusCard(
                                      mark: data.profile.verification!,
                                    ),
                                  ),
                              ],
                            ),
                            _AccountProfileBio(data: data),
                            if (data.profile.links.isNotEmpty)
                              _AccountProfileLinks(data: data),
                            if (data.contacts.any((c) => c.isPublic))
                              _AccountProfileContacts(data: data),
                            _AccountProfileDetail(data: data),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: [
                            ActivityPresenceWidget(uname: name),
                            const SizedBox(height: 12),
                            _AccountPublisherList(
                              publishers: accountPublishers.value ?? [],
                            ),
                            const SizedBox(height: 12),
                            if (user.value != null && !isCurrentUser) ...[
                              _AccountAction(
                                data: data,
                                accountRelationship: accountRelationship,
                                accountChat: accountChat,
                                relationshipAction: relationshipAction,
                                blockAction: blockAction,
                                directMessageAction: directMessageAction,
                              ),
                              const SizedBox(height: 12),
                            ],
                            Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: FortuneGraphWidget(
                                  events: accountEvents,
                                  eventCalandarUser: data.name,
                                  margin: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).padding(horizontal: 24)
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      foregroundColor: appbarColor.value,
                      expandedHeight: 180,
                      pinned: true,
                      leading: AutoLeadingButton(),
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: data.profile.background != null
                                ? CloudImageWidget(
                                    file: data.profile.background,
                                  )
                                : Container(
                                    color: Theme.of(
                                      context,
                                    ).appBarTheme.backgroundColor,
                                  ),
                          ),
                          FlexibleSpaceBar(
                            title: Text(
                              data.nick,
                              style: TextStyle(
                                color:
                                    appbarColor.value ??
                                    Theme.of(
                                      context,
                                    ).appBarTheme.foregroundColor,
                                shadows: [appbarShadow],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        spacing: 12,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AccountBasicInfo(
                            data: data,
                            uname: name,
                            accountDeveloper: accountDeveloper,
                          ),
                          if (data.badges.isNotEmpty)
                            Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: BadgeList(badges: data.badges),
                              ),
                            ),
                          Column(
                            spacing: 12,
                            children: [
                              LevelingProgressCard(
                                level: data.profile.level,
                                experience: data.profile.experience,
                                progress: data.profile.levelingProgress,
                              ),
                              if (data.profile.verification != null)
                                Card(
                                  margin: EdgeInsets.zero,
                                  child: VerificationStatusCard(
                                    mark: data.profile.verification!,
                                  ),
                                ),
                            ],
                          ),
                          _AccountProfileBio(data: data),
                          if (data.profile.links.isNotEmpty)
                            _AccountProfileLinks(data: data),
                          if (data.contacts.any((c) => c.isPublic))
                            _AccountProfileContacts(data: data),
                          ActivityPresenceWidget(uname: name),
                          _AccountPublisherList(
                            publishers: accountPublishers.value ?? [],
                          ),
                          _AccountProfileDetail(data: data),
                          if (user.value != null && !isCurrentUser)
                            _AccountAction(
                              data: data,
                              accountRelationship: accountRelationship,
                              accountChat: accountChat,
                              relationshipAction: relationshipAction,
                              blockAction: blockAction,
                              directMessageAction: directMessageAction,
                            ),
                          Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: FortuneGraphWidget(
                                events: accountEvents,
                                eventCalandarUser: data.name,
                              ),
                            ),
                          ),
                        ],
                      ).padding(horizontal: 8, vertical: 8),
                    ),
                  ],
                ),
        );
      },
      error: (error, stackTrace) => AppScaffold(
        appBar: AppBar(leading: const AutoLeadingButton()),
        body: Center(child: Text(error.toString())),
      ),
      loading: () => AppScaffold(
        appBar: AppBar(leading: const AutoLeadingButton()),
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
