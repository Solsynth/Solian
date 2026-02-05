import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/publication_site.dart';
import 'package:island/sites/site_pages.dart';
import 'package:island/sites/sites_widgets/page_form.dart';
import 'package:island/sites/sites_widgets/page_item.dart';
import 'package:material_symbols_icons/symbols.dart';

class PagesSection extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const PagesSection({super.key, required this.site, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(sitePagesProvider(pubName, site.slug));
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Symbols.article, size: 20),
                const Gap(8),
                Text(
                  'sitePages'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Open page creation dialog
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) =>
                          PageForm(site: site, pubName: pubName),
                    ).then((_) {
                      // Refresh pages after creation
                      ref.invalidate(sitePagesProvider(pubName, site.slug));
                    });
                  },
                  icon: const Icon(Symbols.add),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
              ],
            ),
            const Gap(16),
            pagesAsync.when(
              data: (pages) {
                if (pages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Symbols.article,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const Gap(16),
                          Text(
                            'noPagesYet'.tr(),
                            style: theme.textTheme.bodyLarge,
                          ),
                          const Gap(8),
                          Text(
                            'createFirstPage'.tr(),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return PageItem(page: page, site: site, pubName: pubName);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  children: [
                    Text('failedToLoadPages'.tr()),
                    const Gap(8),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(sitePagesProvider(pubName, site.slug)),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
