import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:island/creators/publication_site.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/sites/site_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class FileManagementActionSection extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const FileManagementActionSection({
    super.key,
    required this.site,
    required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'fileActions'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).padding(horizontal: 16, top: 16),
              Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Symbols.delete_forever,
                      color: theme.colorScheme.error,
                    ),
                    title: Text('purgeFiles'.tr()),
                    subtitle: Text('purgeFilesDescription'.tr()),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onTap: () => _purgeFiles(context, ref),
                  ),
                  const Gap(8),
                  ListTile(
                    leading: Icon(
                      Symbols.upload,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text('deploySite'.tr()),
                    subtitle: Text('deploySiteDescription'.tr()),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onTap: () => _deploySite(context, ref),
                  ),
                ],
              ).padding(vertical: 8),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _purgeFiles(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmAlert(
      'purgeFilesConfirm'.tr(),
      'confirmPurge'.tr(),
      isDanger: true,
    );

    if (confirmed != true) return;

    try {
      final client = ref.read(solarNetworkClientProvider);
      await client.dio.delete('/zone/sites/${site.id}/files/purge');
      if (context.mounted) {
        showSnackBar('allFilesPurgedSuccess'.tr());
        // Refresh the file management section
        ref.invalidate(siteFilesProvider(siteId: site.id));
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar('failedToPurgeFiles'.tr(args: [e.toString()]));
      }
    }
  }

  Future<void> _deploySite(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return; // User canceled
    }

    final file = File(result.files.first.path!);

    try {
      final client = ref.read(solarNetworkClientProvider);

      // Create multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: result.files.first.name,
          contentType: MediaType('application', 'zip'),
        ),
      });

      await client.dio.post(
        '/zone/sites/${site.id}/files/deploy',
        data: formData,
      );

      if (context.mounted) {
        showSnackBar('siteDeployedSuccess'.tr());
        // Refresh the file management section
        ref.invalidate(siteFilesProvider(siteId: site.id));
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar('failedToDeploySite'.tr(args: [e.toString()]));
      }
    }
  }
}
