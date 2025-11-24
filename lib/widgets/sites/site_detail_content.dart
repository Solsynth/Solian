import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/widgets/sites/file_management_section.dart';
import 'package:island/widgets/sites/file_management_action_section.dart';
import 'package:island/widgets/sites/site_info_card.dart';
import 'package:island/widgets/sites/pages_section.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
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
            SiteInfoCard(site: site),
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
