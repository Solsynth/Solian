import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/core/utils/file_icon_utils.dart';
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
    const tileHorizontalPadding = 18.0;
    final exifData = item.fileMeta['exif'];
    final file = item is SnCloudFile ? item as SnCloudFile : null;
    final hash = item.hash;
    final permissionStatus = file?.permissionStatus;
    final childrenCount = file?.childrenCount ?? 0;
    final mimeTypeLabel = file?.isFolder == true
        ? 'folder'.tr()
        : item.mimeType;
    return SheetScaffold(
      onClose: onClose,
      title: Row(
        children: [
          Icon(Symbols.info, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text('fileInfoTitle'.tr()),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.55,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: file == null
                        ? Icon(
                            Symbols.insert_drive_file,
                            size: 30,
                            color: theme.colorScheme.primary,
                          )
                        : getFileIcon(file, size: 30, tinyPreview: false),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mimeTypeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.name.isEmpty ? 'untitled'.tr() : item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _FileInfoBadge(
                              icon: Symbols.data_usage,
                              label: formatFileSize(item.size),
                            ),
                            if (permissionStatus != null)
                              _FileInfoBadge(
                                icon: permissionStatus.readable
                                    ? Symbols.lock_open
                                    : Symbols.lock,
                                label: permissionStatus.visibility.tr(),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _FileInfoMetric(
                      label: 'mimeType'.tr(),
                      value: mimeTypeLabel,
                    ),
                  ),
                  const SizedBox(height: 36, child: VerticalDivider()),
                  Expanded(
                    child: _FileInfoMetric(
                      label: 'fileSize'.tr(),
                      value: formatFileSize(item.size),
                    ),
                  ),
                  if (hash != null && hash.isNotEmpty) ...[
                    const SizedBox(height: 36, child: VerticalDivider()),
                    Expanded(
                      child: GestureDetector(
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: hash));
                          showSnackBar('fileHashCopied'.tr());
                        },
                        child: _FileInfoMetric(
                          label: 'fileHash'.tr(),
                          value: hash.length > 6
                              ? '${hash.substring(0, 6)}...'
                              : hash,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Symbols.tag),
              title: Text('ID').tr(),
              subtitle: Text(
                item.id,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: tileHorizontalPadding,
              ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: tileHorizontalPadding,
              ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: tileHorizontalPadding,
                ),
                onTap: () {
                  launchUrlString(
                    'https://solian.app/files/${item.id}',
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            if (file != null) ...[
              const Divider(height: 1),
              if (file.usage case final usage?)
                ListTile(
                  leading: const Icon(Symbols.asterisk),
                  title: Text('fileUsage').tr(),
                  subtitle: Text(usage),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: tileHorizontalPadding,
                  ),
                ),
              if (file.applicationType case final applicationType?)
                ListTile(
                  leading: const Icon(Symbols.category),
                  title: Text('applicationType').tr(),
                  subtitle: Text(applicationType),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: tileHorizontalPadding,
                  ),
                ),
              ListTile(
                leading: Icon(
                  permissionStatus?.readable == true
                      ? Symbols.lock_open
                      : Symbols.lock,
                  color: theme.colorScheme.primary,
                ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: tileHorizontalPadding,
                ),
              ),
              ListTile(
                leading: const Icon(Symbols.folder_copy),
                title: const Text('children').tr(),
                subtitle: Text(childrenCount.toString()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: tileHorizontalPadding,
                ),
              ),
            ],
            if (exifData is Map && exifData.isNotEmpty) ...[
              const Divider(height: 1),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: tileHorizontalPadding,
                  ),
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
                              horizontal: tileHorizontalPadding,
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
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: tileHorizontalPadding,
                  ),
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
                              horizontal: tileHorizontalPadding,
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
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: tileHorizontalPadding,
                  ),
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
                              horizontal: tileHorizontalPadding,
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

class _FileInfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FileInfoBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: scheme.onSurface),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileInfoMetric extends StatelessWidget {
  final String label;
  final String value;

  const _FileInfoMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PermissionRuleTile extends StatelessWidget {
  final SnFilePermission permission;
  final VoidCallback onRemove;

  const _PermissionRuleTile({required this.permission, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subjectLabel = permission.subjectId.isEmpty
        ? permission.subjectType.tr()
        : permission.subjectId;
    final icon = switch (permission.permission) {
      'manage' => Symbols.admin_panel_settings,
      'write' => Symbols.edit,
      _ => Symbols.visibility,
    };
    final permissionLabel = switch (permission.permission) {
      'read' => 'filePermissionRead'.tr(),
      'write' => 'filePermissionWrite'.tr(),
      _ => permission.permission.tr(),
    };
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: scheme.primary),
      title: Text(subjectLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${permission.subjectType.tr()} · $permissionLabel'),
      trailing: IconButton(
        tooltip: 'delete'.tr(),
        onPressed: onRemove,
        icon: const Icon(Symbols.close, size: 19),
      ),
    );
  }
}

class _PermissionSectionLabel extends StatelessWidget {
  final String title;
  final String? trailing;

  const _PermissionSectionLabel({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            Text(
              trailing!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PermissionEmptyState extends StatelessWidget {
  const _PermissionEmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 34),
      child: Column(
        children: [
          Icon(Symbols.rule, size: 34, color: scheme.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            'private'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class FilePermissionEditorSheet extends HookConsumerWidget {
  final SnCloudFile file;

  const FilePermissionEditorSheet({super.key, required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
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

    final inherited = file.permissionStatus?.inheritedFrom != null;
    final visibility = file.permissionStatus?.visibility.tr() ?? 'public'.tr();

    return SheetScaffold(
      title: Row(
        children: [
          Icon(Symbols.lock, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'permissions'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              file.isFolder ? Symbols.folder : Symbols.insert_drive_file,
              color: scheme.primary,
            ),
            title: Text(
              file.name.isEmpty ? 'untitled'.tr() : file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              [
                visibility,
                if (inherited) 'inheritedFromParent'.tr(),
              ].join(' · '),
            ),
          ),
          _PermissionSectionLabel(title: 'filePermissionAddRule'.tr()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  avatar: const Icon(Symbols.public, size: 17),
                  label: Text('public').tr(),
                  selected: subjectType.value == 'public',
                  onSelected: (_) => subjectType.value = 'public',
                ),
                ChoiceChip(
                  avatar: const Icon(Symbols.lock, size: 17),
                  label: Text('private').tr(),
                  selected: subjectType.value == 'private',
                  onSelected: (_) => subjectType.value = 'private',
                ),
                ChoiceChip(
                  avatar: const Icon(Symbols.person, size: 17),
                  label: Text('account').tr(),
                  selected: subjectType.value == 'account',
                  onSelected: (_) => subjectType.value = 'account',
                ),
                ChoiceChip(
                  avatar: const Icon(Symbols.key, size: 17),
                  label: Text('scope').tr(),
                  selected: subjectType.value == 'scope',
                  onSelected: (_) => subjectType.value = 'scope',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text('filePermissionRead').tr(),
                  selected: permission.value == 'read',
                  onSelected: (_) => permission.value = 'read',
                ),
                ChoiceChip(
                  label: Text('filePermissionWrite').tr(),
                  selected: permission.value == 'write',
                  onSelected: (_) => permission.value = 'write',
                ),
                ChoiceChip(
                  label: Text('manage').tr(),
                  selected: permission.value == 'manage',
                  onSelected: (_) => permission.value = 'manage',
                ),
              ],
            ),
          ),
          if (subjectType.value == 'scope') ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: subjectIdController,
                decoration: InputDecoration(
                  labelText: 'scope'.tr(),
                  hintText: 'files.manage',
                  prefixIcon: const Icon(Symbols.key),
                  isDense: true,
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: OutlinedButton.icon(
              onPressed: addRule,
              icon: const Icon(Symbols.add),
              label: Text('add').tr(),
            ),
          ),
          const Divider(height: 24),
          _PermissionSectionLabel(
            title: 'filePermissionCurrentRules'.tr(),
            trailing: '${workingItems.value.length}',
          ),
          Expanded(
            child: permissionsAsync.when(
              data: (_) => workingItems.value.isEmpty
                  ? const SingleChildScrollView(child: _PermissionEmptyState())
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: workingItems.value.length,
                      itemBuilder: (context, index) {
                        final perm = workingItems.value[index];
                        return _PermissionRuleTile(
                          permission: perm,
                          onRemove: () {
                            workingItems.value = List.of(workingItems.value)
                              ..removeAt(index);
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error.toString(), textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('cancel').tr(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: save,
                      child: Text('save').tr(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
