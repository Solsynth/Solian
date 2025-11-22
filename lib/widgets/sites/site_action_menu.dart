import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/sites/site_detail.dart';
import 'package:island/screens/creators/sites/site_edit.dart';
import 'package:island/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class SiteActionMenu extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const SiteActionMenu({super.key, required this.site, required this.pubName});

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
                    title: Text('deleteSite'.tr()),
                    content: Text('publicationSiteDeleteConfirm'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('cancel'.tr()),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('delete'.tr()),
                      ),
                    ],
                  ),
            );

            if (confirmed == true) {
              try {
                final client = ref.read(apiClientProvider);
                await client.delete('/zone/sites/${site.id}');
                if (context.mounted) {
                  showSnackBar('siteDeletedSuccess'.tr());
                  Navigator.of(context).pop();
                }
              } catch (e) {
                showErrorAlert(e);
              }
            }
            break;
        }
      },
    );
  }
}
