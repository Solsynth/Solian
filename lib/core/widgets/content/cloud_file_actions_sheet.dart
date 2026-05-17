import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:island/core/widgets/content/file_info_sheet.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CloudFileActionsSheet extends StatelessWidget {
  final IDisplayableCloudFile item;
  final VoidCallback? onClose;

  const CloudFileActionsSheet({super.key, required this.item, this.onClose});

  static Future<T?> show<T>({
    required BuildContext context,
    required IDisplayableCloudFile item,
  }) {
    return showModalBottomSheet<T>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (context) => CloudFileActionsSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      onClose: onClose,
      titleText: item.name,
      heightFactor: 0.5,
      child: ListView(
        shrinkWrap: true,
        children: [
          const Gap(8),
          _ActionTile(
            icon: Symbols.save,
            title: 'saveToGallery'.tr(),
            subtitle: 'downloadAndSaveToDevice'.tr(),
            onTap: () => Navigator.pop(context, 'save'),
          ),
          _ActionTile(
            icon: Symbols.share,
            title: 'share'.tr(),
            subtitle: 'shareFileLink'.tr(),
            onTap: () => Navigator.pop(context, 'share'),
          ),
          _ActionTile(
            icon: Symbols.info,
            title: 'fileInfoTitle'.tr(),
            subtitle: 'viewFileDetails'.tr(),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                useRootNavigator: true,
                context: context,
                isScrollControlled: true,
                builder: (context) => FileInfoSheet(item: item),
              );
            },
          ),
          if (item.storageUrl != null)
            _ActionTile(
              icon: Symbols.open_in_new,
              title: 'openInBrowser'.tr(),
              subtitle: 'openFileInWebBrowser'.tr(),
              onTap: () {
                Navigator.pop(context);
                launchUrlString(
                  item.storageUrl!,
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          _ActionTile(
            icon: Symbols.content_copy,
            title: 'copyLink'.tr(),
            subtitle: 'copyFileLinkToClipboard'.tr(),
            onTap: () {
              Clipboard.setData(
                ClipboardData(text: item.storageUrl ?? item.id),
              );
              showSnackBar('linkCopied'.tr());
              Navigator.pop(context);
            },
          ),
          _ActionTile(
            icon: Symbols.edit,
            title: 'openInViewer'.tr(),
            subtitle: 'openInFullscreenViewer'.tr(),
            onTap: () {
              Navigator.pop(context);
              if (item is SnCloudFile) {
                context.router.push(FileDetailRoute(item: item as SnCloudFile));
              }
            },
          ),
          const Gap(16),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Symbols.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
