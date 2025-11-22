import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/widgets/sites/file_management_section.dart';
import 'package:island/widgets/sites/file_management_action_section.dart';
import 'package:island/widgets/sites/info_row.dart';
import 'package:island/widgets/sites/pages_section.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/screens/creators/sites/site_detail.dart';

class SiteDetailContent extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const SiteDetailContent({
    super.key,
    required this.site,
    required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ExtendedRefreshIndicator(
      onRefresh:
          () async =>
              ref.invalidate(publicationSiteDetailProvider(pubName, site.slug)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Site Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'siteInformation'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(16),
                    InfoRow(
                      label: 'name'.tr(),
                      value: site.name,
                      icon: Symbols.title,
                    ),
                    const Gap(8),
                    InfoRow(
                      label: 'slug'.tr(),
                      value: site.slug,
                      icon: Symbols.tag,
                      monospace: true,
                    ),
                    const Gap(8),
                    InfoRow(
                      label: 'Mode',
                      value:
                          site.mode == 0
                              ? 'siteModeFullyManaged'.tr()
                              : 'siteModeSelfManaged'.tr(),
                      icon: Symbols.settings,
                    ),
                    if (site.description != null &&
                        site.description!.isNotEmpty) ...[
                      const Gap(8),
                      InfoRow(
                        label: 'description'.tr(),
                        value: site.description!,
                        icon: Symbols.description,
                      ),
                    ],
                    const Gap(8),
                    InfoRow(
                      label: 'siteCreated'.tr(),
                      value: site.createdAt.formatSystem(),
                      icon: Symbols.calendar_add_on,
                    ),
                    const Gap(8),
                    InfoRow(
                      label: 'siteUpdated'.tr(),
                      value: site.updatedAt.formatSystem(),
                      icon: Symbols.update,
                    ),
                  ],
                ),
              ),
            ),
            const Gap(8),
            if (site.mode == 1) // Self-Managed only
              FileManagementActionSection(site: site, pubName: pubName),
            // Pages Section
            PagesSection(site: site, pubName: pubName),
            FileManagementSection(site: site, pubName: pubName),
          ],
        ),
      ),
    );
  }
}
