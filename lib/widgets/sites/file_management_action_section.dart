import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/pods/site_files.dart';
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
                'File Actions',
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
                    title: const Text('Purge Files'),
                    subtitle: const Text(
                      'Remove all uploaded files from the site',
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onTap: () => _purgeFiles(context, ref),
                  ),
                  const Gap(8),
                  ListTile(
                    leading: Icon(
                      Symbols.upload,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Deploy Site'),
                    subtitle: const Text(
                      'Upload and deploy a new version from ZIP archive',
                    ),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Purge'),
            content: const Text(
              'This will permanently delete all files uploaded to this site. This action cannot be undone. Are you sure you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Purge All Files'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.delete('/zone/sites/${site.id}/files/purge');
      if (context.mounted) {
        showSnackBar('All files purged successfully');
        // Refresh the file management section
        ref.invalidate(siteFilesProvider(siteId: site.id));
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar('Failed to purge files: $e');
      }
    }
  }

  Future<void> _deploySite(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return; // User canceled
    }

    final file = File(result.files.first.path!);

    try {
      final apiClient = ref.read(apiClientProvider);

      // Create multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: result.files.first.name,
          contentType: MediaType('application', 'zip'),
        ),
      });

      await apiClient.post(
        '/zone/sites/${site.id}/files/deploy',
        data: formData,
      );

      if (context.mounted) {
        showSnackBar('Site deployed successfully');
        // Refresh the file management section
        ref.invalidate(siteFilesProvider(siteId: site.id));
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar('Failed to deploy site: $e');
      }
    }
  }
}
