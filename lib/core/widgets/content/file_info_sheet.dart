import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/drive/file_permissions.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FileInfoSheet extends ConsumerWidget {
  final IDisplayableCloudFile item;
  final VoidCallback? onClose;

  const FileInfoSheet({super.key, required this.item, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exifData = item.fileMeta['exif'];
    final file = item is SnCloudFile ? item as SnCloudFile : null;
    final permissionStatus = file?.permissionStatus;
    final childrenCount = file?.childrenCount ?? 0;
    final mimeTypeLabel = file?.isFolder == true
        ? 'folder'.tr()
        : item.mimeType;

    return SheetScaffold(
      onClose: onClose,
      titleText: 'fileInfoTitle'.tr(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('mimeType').tr(),
                      Text(
                        mimeTypeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28, child: const VerticalDivider()),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('fileSize').tr(),
                      Text(
                        formatFileSize(item.size),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.hash != null)
                  SizedBox(height: 28, child: const VerticalDivider()),
                if (item.hash != null)
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('fileHash').tr(),
                          Text(
                            '${item.hash!.substring(0, 6)}...',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: item.hash!));
                        showSnackBar('fileHashCopied'.tr());
                      },
                    ),
                  ),
              ],
            ).padding(horizontal: 16, vertical: 12),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Symbols.tag),
              title: Text('ID').tr(),
              subtitle: Text(
                item.id,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.id));
                  showSnackBar('fileIdCopied'.tr());
                },
              ),
            ),
            ListTile(
              leading: const Icon(Symbols.file_present),
              title: Text('Name').tr(),
              subtitle: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.name));
                  showSnackBar('fileNameCopied'.tr());
                },
              ),
            ),
            if (file?.isFolder != true)
              ListTile(
                leading: const Icon(Symbols.launch),
                title: Text('openInBrowser').tr(),
                subtitle: Text('https://solian.app/files/${item.id}'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                onTap: () {
                  launchUrlString(
                    'https://solian.app/files/${item.id}',
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            if (file != null) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Symbols.lock),
                title: Text('permissions').tr(),
                subtitle: Text(
                  [
                    permissionStatus == null
                        ? 'public'.tr()
                        : permissionStatus.visibility.tr(),
                    if (permissionStatus?.inheritedFrom != null)
                      'inheritedFromParent'.tr(),
                  ].join(' · '),
                ),
                trailing: TextButton(
                  onPressed: () => _showPermissionManager(context, ref, file),
                  child: Text('manage').tr(),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              ListTile(
                leading: const Icon(Symbols.folder_copy),
                title: const Text('children').tr(),
                subtitle: Text(childrenCount.toString()),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ],
            if (exifData is Map && exifData.isNotEmpty) ...[
              const Divider(height: 1),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    'exifData'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...exifData.entries.map(
                          (entry) => ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            title: Text(
                              entry.key.contains('-')
                                  ? entry.key.split('-').last
                                  : entry.key,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ).bold(),
                            subtitle: Text(
                              '${entry.value}'.isNotEmpty
                                  ? '${entry.value}'
                                  : 'N/A',
                              style: theme.textTheme.bodyMedium,
                            ),
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: '${entry.value}'),
                              );
                              showSnackBar('valueCopied'.tr());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (item.fileMeta.isNotEmpty) ...[
              const Divider(height: 1),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    'fileMetadata'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...item.fileMeta.entries.map(
                          (entry) => ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            title: Text(
                              entry.key,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ).bold(),
                            subtitle: Text(
                              jsonEncode(entry.value),
                              style: theme.textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: jsonEncode(entry.value)),
                              );
                              showSnackBar('valueCopied'.tr());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (item.userMeta.isNotEmpty) ...[
              const Divider(height: 1),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(
                    'userMetadata'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...item.userMeta.entries.map(
                          (entry) => ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            title: Text(
                              entry.key,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ).bold(),
                            subtitle: Text(
                              jsonEncode(entry.value),
                              style: theme.textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: jsonEncode(entry.value)),
                              );
                              showSnackBar('valueCopied'.tr());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showPermissionManager(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile file,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => FilePermissionEditorSheet(file: file),
    );
    ref.invalidate(driveFileInfoProvider(file.id));
    ref.invalidate(driveFilePermissionsProvider(file.id));
  }
}

class FilePermissionEditorSheet extends HookConsumerWidget {
  final SnCloudFile file;

  const FilePermissionEditorSheet({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(driveFilePermissionsProvider(file.id));
    final workingItems = useState<List<SnFilePermission>>([]);
    final loaded = useState(false);
    final subjectType = useState('public');
    final subjectIdController = useTextEditingController();
    final permission = useState('read');

    useEffect(() {
      permissionsAsync.whenData((items) {
        if (!loaded.value) {
          workingItems.value = List.of(items);
          loaded.value = true;
        }
      });
      return null;
    }, [permissionsAsync]);

    Future<void> addRule() async {
      if (subjectType.value == 'public' || subjectType.value == 'private') {
        workingItems.value = [
          ...workingItems.value,
          SnFilePermission(
            id: null,
            fileId: file.id,
            subjectType: subjectType.value,
            subjectId: '',
            permission: permission.value,
            createdAt: null,
            updatedAt: null,
            deletedAt: null,
          ),
        ];
        return;
      }

      if (subjectType.value == 'account') {
        final account = await showModalBottomSheet<SnAccount>(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          builder: (context) => const AccountPickerSheet(),
        );
        if (account == null) return;
        workingItems.value = [
          ...workingItems.value,
          SnFilePermission(
            id: null,
            fileId: file.id,
            subjectType: 'account',
            subjectId: account.id,
            permission: permission.value,
            createdAt: null,
            updatedAt: null,
            deletedAt: null,
          ),
        ];
        return;
      }

      final subjectId = subjectIdController.text.trim();
      if (subjectId.isEmpty) return;
      workingItems.value = [
        ...workingItems.value,
        SnFilePermission(
          id: null,
          fileId: file.id,
          subjectType: 'scope',
          subjectId: subjectId,
          permission: permission.value,
          createdAt: null,
          updatedAt: null,
          deletedAt: null,
        ),
      ];
      subjectIdController.clear();
    }

    Future<void> save() async {
      showLoadingModal(context);
      try {
        await ref
            .read(solarNetworkClientProvider)
            .drive
            .updateFilePermissions(file.id, workingItems.value);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        showSnackBar('save'.tr());
      } catch (error) {
        showSnackBar(error.toString());
      } finally {
        if (context.mounted) {
          hideLoadingModal(context);
        }
      }
    }

    return SheetScaffold(
      titleText: 'permissions'.tr(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  file.permissionStatus?.visibility.tr() ?? 'public'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (file.permissionStatus?.inheritedFrom != null)
                  Text(
                    'inheritedFromParent'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('public').tr(),
                      selected: subjectType.value == 'public',
                      onSelected: (_) => subjectType.value = 'public',
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('private').tr(),
                      selected: subjectType.value == 'private',
                      onSelected: (_) => subjectType.value = 'private',
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('account'),
                      selected: subjectType.value == 'account',
                      onSelected: (_) => subjectType.value = 'account',
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('scope'),
                      selected: subjectType.value == 'scope',
                      onSelected: (_) => subjectType.value = 'scope',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('read'),
                      selected: permission.value == 'read',
                      onSelected: (_) => permission.value = 'read',
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('write'),
                      selected: permission.value == 'write',
                      onSelected: (_) => permission.value = 'write',
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('manage'),
                      selected: permission.value == 'manage',
                      onSelected: (_) => permission.value = 'manage',
                    ),
                  ],
                ),
                if (subjectType.value == 'scope') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: subjectIdController,
                    decoration: const InputDecoration(
                      hintText: 'files.manage',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: addRule,
                      icon: const Icon(Symbols.add),
                      label: Text('add').tr(),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('cancel').tr(),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: save, child: Text('save').tr()),
                  ],
                ),
              ],
            ).padding(horizontal: 20),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: permissionsAsync.when(
                data: (_) => ListView.builder(
                  itemCount: workingItems.value.length,
                  itemBuilder: (context, index) {
                    final perm = workingItems.value[index];
                    return ListTile(
                      title: Text('${perm.subjectType} · ${perm.permission}'),
                      subtitle: Text(
                        perm.subjectId.isEmpty ? 'all' : perm.subjectId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Symbols.close),
                        onPressed: () {
                          workingItems.value = List.of(workingItems.value)
                            ..removeAt(index);
                        },
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text(error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileInspectorSheet extends ConsumerWidget {
  const FileInspectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(driveInspectorFileProvider);
    if (file == null) {
      return const Center(child: Text('No file selected'));
    }
    return FileInfoSheet(
      item: file,
      onClose: () =>
          ref.read(driveInspectorFileProvider.notifier).setFile(null),
    );
  }
}
