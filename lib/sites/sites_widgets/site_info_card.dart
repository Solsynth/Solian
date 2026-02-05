import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/creators/publication_site.dart';
import 'package:island/core/services/time.dart';
import 'package:island/shared/widgets/info_row.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SiteInfoCard extends StatelessWidget {
  final SnPublicationSite site;

  const SiteInfoCard({super.key, required this.site});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
            InfoRow(label: 'name'.tr(), value: site.name, icon: Symbols.title),
            const Gap(8),
            InfoRow(
              label: 'slug'.tr(),
              value: site.slug,
              icon: Symbols.tag,
              monospace: true,
            ),
            const Gap(8),
            InfoRow(
              label: 'siteDomain'.tr(),
              value: '${site.slug}.solian.page',
              icon: Symbols.globe,
              monospace: true,
              onTap: () {
                final url = 'https://${site.slug}.solian.page';
                launchUrlString(url);
              },
            ),
            const Gap(8),
            InfoRow(
              label: 'siteMode'.tr(),
              value: site.mode == 0
                  ? 'siteModeFullyManaged'.tr()
                  : 'siteModeSelfManaged'.tr(),
              icon: Symbols.settings,
            ),
            if (site.description != null && site.description!.isNotEmpty) ...[
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
    );
  }
}
