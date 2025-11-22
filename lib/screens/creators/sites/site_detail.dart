import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/site_pages.dart';
import 'package:island/widgets/sites/page_form.dart';
import 'package:island/widgets/sites/site_action_menu.dart';
import 'package:island/widgets/sites/site_detail_content.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/widgets/sites/info_row.dart';
import 'package:island/widgets/sites/pages_section.dart';
import 'package:island/widgets/sites/file_management_section.dart';
import 'package:island/widgets/sites/file_management_action_section.dart';
import 'package:island/services/responsive.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'site_detail.g.dart';

@riverpod
Future<SnPublicationSite> publicationSiteDetail(
  Ref ref,
  String pubName,
  String siteSlug,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/zone/sites/$pubName/$siteSlug');
  return SnPublicationSite.fromJson(resp.data);
}

class PublicationSiteDetailScreen extends HookConsumerWidget {
  final String siteSlug;
  final String pubName;

  const PublicationSiteDetailScreen({
    super.key,
    required this.siteSlug,
    required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siteAsync = ref.watch(
      publicationSiteDetailProvider(pubName, siteSlug),
    );

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: siteAsync.maybeWhen(
          data: (site) => Text(site.name),
          orElse: () => Text('siteDetails'.tr()),
        ),
        actions: [
          siteAsync.maybeWhen(
            data: (site) => SiteActionMenu(site: site, pubName: pubName),
            orElse: () => const SizedBox.shrink(),
          ),
          const Gap(8),
        ],
      ),
      body: siteAsync.when(
        data: (site) {
          final theme = Theme.of(context);
          if (isWideScreen(context)) {
            return ExtendedRefreshIndicator(
              onRefresh:
                  () async => ref.invalidate(
                    publicationSiteDetailProvider(pubName, site.slug),
                  ),
              child: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PagesSection(site: site, pubName: pubName),
                          if (site.mode == 1) // Self-Managed only
                            FileManagementSection(site: site, pubName: pubName),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'siteInformation'.tr(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
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
                                    label: 'siteDomain'.tr(),
                                    value: '${site.slug}.solian.page',
                                    icon: Symbols.globe,
                                    monospace: true,
                                    onTap: () {
                                      final url =
                                          'https://${site.slug}.solian.page';
                                      launchUrlString(url);
                                    },
                                  ),
                                  const Gap(8),
                                  InfoRow(
                                    label: 'siteMode'.tr(),
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
                            FileManagementActionSection(
                              site: site,
                              pubName: pubName,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).padding(horizontal: 12),
            );
          } else {
            return SiteDetailContent(site: site, pubName: pubName);
          }
        },
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'failedToLoadSite'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(16),
                  Text(error.toString()),
                  const Gap(24),
                  ElevatedButton(
                    onPressed:
                        () => ref.invalidate(
                          publicationSiteDetailProvider(pubName, siteSlug),
                        ),
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: siteAsync.maybeWhen(
        data:
            (site) => FloatingActionButton(
              onPressed: () {
                // Create new page
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PageForm(site: site, pubName: pubName),
                ).then((_) {
                  // Refresh pages after creation
                  ref.invalidate(sitePagesProvider(pubName, site.slug));
                });
              },
              child: const Icon(Symbols.add),
            ),
        orElse: () => null,
      ),
    );
  }
}
