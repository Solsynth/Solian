import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/core/widgets/content/file_info_sheet.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CloudFileActionsSheet extends ConsumerWidget {
  final IDisplayableCloudFile item;
  final VoidCallback? onClose;
  final ValueChanged<SnCloudFile>? onRenamed;
  final VoidCallback? onRevealParentFolder;

  const CloudFileActionsSheet({
    super.key,
    required this.item,
    this.onClose,
    this.onRenamed,
    this.onRevealParentFolder,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required IDisplayableCloudFile item,
    ValueChanged<SnCloudFile>? onRenamed,
    VoidCallback? onRevealParentFolder,
  }) {
    return showModalBottomSheet<T>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (context) => CloudFileActionsSheet(
        item: item,
        onRenamed: onRenamed,
        onRevealParentFolder: onRevealParentFolder,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploader = ref.read(driveFileUploaderProvider);
    final rootContext = Navigator.of(context, rootNavigator: true).context;

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
            onTap: () => Navigator.pop(context, 'save'),
          ),
          if (item is SnCloudFile)
            _ActionTile(
              icon: Symbols.edit,
              title: 'rename'.tr(),
              onTap: () async {
                Navigator.pop(context);
                await Future<void>.delayed(Duration.zero);
                if (!rootContext.mounted) return;
                await _showRenameSheet(
                  rootContext,
                  uploader,
                  item as SnCloudFile,
                  onRenamed,
                );
              },
            ),
          _ActionTile(
            icon: Symbols.share,
            title: 'share'.tr(),
            onTap: () => Navigator.pop(context, 'share'),
          ),
          _ActionTile(
            icon: Symbols.info,
            title: 'fileInfoTitle'.tr(),
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
          if (item is SnCloudFile && onRevealParentFolder != null)
            _ActionTile(
              icon: Symbols.folder_open,
              title: 'revealParentFolder'.tr(),
              onTap: () {
                Navigator.pop(context);
                onRevealParentFolder?.call();
              },
            ),
          if (item.storageUrl != null)
            _ActionTile(
              icon: Symbols.open_in_new,
              title: 'openInBrowser'.tr(),
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
            onTap: () => Navigator.pop(context, 'open_in_viewer'),
          ),
          const Gap(16),
        ],
      ),
    );
  }

  static Future<void> showRenameSheet({
    required BuildContext context,
    required SnCloudFile file,
    required ValueChanged<SnCloudFile>? onRenamed,
  }) async {
    final uploader = ProviderScope.containerOf(context).read(driveFileUploaderProvider);
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    if (!rootContext.mounted) return;
    await _showRenameSheet(rootContext, uploader, file, onRenamed);
  }

  static Future<void> _showRenameSheet(
    BuildContext context,
    FileUploader uploader,
    SnCloudFile file,
    ValueChanged<SnCloudFile>? onRenamed,
  ) async {
    final nameController = TextEditingController(text: file.name);
    String? errorMessage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SheetScaffold(
          heightFactor: 0.4,
          titleText: 'rename'.tr(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'fileName'.tr(),
                    errorText: errorMessage,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('cancel'.tr()),
                    ),
                    const Gap(8),
                    TextButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        if (newName.isEmpty) {
                          setState(() {
                            errorMessage = 'fieldCannotBeEmpty'.tr();
                          });
                          return;
                        }

                        try {
                          showLoadingModal(context);
                          final renamedFile = await uploader.renameFile(
                            file.id,
                            newName,
                          );
                          onRenamed?.call(renamedFile);
                          if (context.mounted) {
                            Navigator.pop(context);
                            showSnackBar('fileRenamed'.tr());
                          }
                        } catch (err) {
                          showErrorAlert(err);
                        } finally {
                          if (context.mounted) hideLoadingModal(context);
                        }
                      },
                      child: Text('rename'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
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
      trailing: const Icon(Symbols.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
