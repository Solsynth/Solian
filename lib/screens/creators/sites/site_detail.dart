import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/sites/site_edit.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

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
          orElse: () => const Text('Site Details'),
        ),
        actions: [
          siteAsync.maybeWhen(
            data: (site) => _SiteActionMenu(site: site, pubName: pubName),
            orElse: () => const SizedBox.shrink(),
          ),
          const Gap(8),
        ],
      ),
      body: siteAsync.when(
        data: (site) => _SiteDetailContent(site: site, pubName: pubName),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load site',
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
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add page creation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add page feature coming soon')),
          );
        },
        child: const Icon(Symbols.add),
      ),
    );
  }
}

class _SiteDetailContent extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const _SiteDetailContent({required this.site, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return RefreshIndicator(
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
                      'Site Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(16),
                    _InfoRow(
                      label: 'Name',
                      value: site.name,
                      icon: Symbols.title,
                    ),
                    const Gap(8),
                    _InfoRow(
                      label: 'Slug',
                      value: site.slug,
                      icon: Symbols.tag,
                      monospace: true,
                    ),
                    const Gap(8),
                    _InfoRow(
                      label: 'Mode',
                      value: site.mode == 0 ? 'Fully Managed' : 'Self-Managed',
                      icon: Symbols.settings,
                    ),
                    if (site.description != null &&
                        site.description!.isNotEmpty) ...[
                      const Gap(8),
                      _InfoRow(
                        label: 'Description',
                        value: site.description!,
                        icon: Symbols.description,
                      ),
                    ],
                    const Gap(8),
                    _InfoRow(
                      label: 'Pages',
                      value: '${site.pages.length}',
                      icon: Symbols.article,
                    ),
                    const Gap(8),
                    _InfoRow(
                      label: 'Created',
                      value: site.createdAt.formatSystem(),
                      icon: Symbols.calendar_add_on,
                    ),
                    const Gap(8),
                    _InfoRow(
                      label: 'Updated',
                      value: site.updatedAt.formatSystem(),
                      icon: Symbols.update,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool monospace;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const Gap(12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style:
                monospace
                    ? GoogleFonts.robotoMono(fontSize: 14)
                    : Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _SiteActionMenu extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const _SiteActionMenu({required this.site, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Symbols.edit,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const Gap(16),
                  Text('edit'.tr()),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Symbols.delete, color: Colors.red),
                  const Gap(16),
                  Text('delete'.tr()).textColor(Colors.red),
                ],
              ),
            ),
          ],
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder:
                  (context) => SiteForm(pubName: pubName, siteSlug: site.slug),
            ).then((_) {
              // Refresh site data after potential edit
              ref.invalidate(publicationSiteDetailProvider(pubName, site.slug));
            });
            break;
          case 'delete':
            final confirmed = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Delete Site'),
                    content: const Text(
                      'Are you sure you want to delete this publication site? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
            );

            if (confirmed == true) {
              try {
                final client = ref.read(apiClientProvider);
                await client.delete('/zone/sites/${site.id}');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Site deleted successfully')),
                  );
                  // Navigate back to list
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete site')),
                  );
                }
              }
            }
            break;
        }
      },
    );
  }
}
