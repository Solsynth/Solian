import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class FileInfoSheet extends StatelessWidget {
  final IDisplayableCloudFile item;
  final VoidCallback? onClose;
  const FileInfoSheet({super.key, required this.item, this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exifData = item.fileMeta['exif'];

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
                        item.mimeType,
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
            ).padding(horizontal: 24, vertical: 16),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Symbols.tag),
              title: Text('ID').tr(),
              subtitle: Text(
                item.id,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.name));
                  showSnackBar('fileNameCopied'.tr());
                },
              ),
            ),
            ListTile(
              leading: const Icon(Symbols.launch),
              title: Text('openInBrowser').tr(),
              subtitle: Text('https://solian.app/files/${item.id}'),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                launchUrlString(
                  'https://solian.app/files/${item.id}',
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            if (exifData.isNotEmpty) ...[
              const Divider(height: 1),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 24),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
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
                  tilePadding: const EdgeInsets.symmetric(horizontal: 24),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
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
                  tilePadding: const EdgeInsets.symmetric(horizontal: 24),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
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
}
