import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/creators/sites/site_detail.dart';
import 'package:island/creators/creators/sites/site_edit.dart';
import 'package:island/creators/publication_site.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class SiteActionMenu extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const SiteActionMenu({super.key, required this.site, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
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
              builder: (context) =>
                  SiteForm(pubName: pubName, siteSlug: site.slug),
            ).then((_) {
              // Refresh site data after potential edit
              ref.invalidate(publicationSiteDetailProvider(pubName, site.slug));
            });
            break;
          case 'delete':
            final confirmed = await showConfirmAlert(
              'publicationSiteDeleteConfirm'.tr(),
              'deleteSite'.tr(),
              isDanger: true,
            );

            if (confirmed == true) {
              try {
                final client = ref.read(apiClientProvider);
                await client.delete('/zone/sites/$pubName/${site.slug}');
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
