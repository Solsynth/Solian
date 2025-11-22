import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/site_pages.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/sites/page_form.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PageItem extends HookConsumerWidget {
  final SnPublicationPage page;
  final SnPublicationSite site;
  final String pubName;

  const PageItem({
    required this.page,
    required this.site,
    required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      elevation: 0,
      child: ListTile(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        leading: Icon(Symbols.article, color: theme.colorScheme.primary),
        title: Text(page.path ?? '/'),
        subtitle: Text(page.config?['title'] ?? 'Untitled'),
        trailing: PopupMenuButton<String>(
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Symbols.edit),
                      const Gap(16),
                      Text('edit'.tr()),
                    ],
                  ),
                ),
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
                // Open page edit dialog
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder:
                      (context) =>
                          PageForm(site: site, pubName: pubName, page: page),
                ).then((_) {
                  // Refresh pages after editing
                  ref.invalidate(sitePagesProvider(pubName, site.slug));
                });
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Delete Page'),
                        content: const Text(
                          'Are you sure you want to delete this page?',
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
                    await ref
                        .read(
                          sitePagesNotifierProvider((
                            pubName: pubName,
                            siteSlug: site.slug,
                          )).notifier,
                        )
                        .deletePage(page.id);
                    showSnackBar('Page deleted successfully');
                  } catch (e) {
                    showErrorAlert(e);
                  }
                }
                break;
            }
          },
        ),
        onTap: () {
          launchUrlString('https://${site.slug}.solian.page${page.path ?? ''}');
        },
      ),
    );
  }
}
