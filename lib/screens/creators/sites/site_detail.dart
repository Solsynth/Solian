import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/models/site_file.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/site_files.dart';
import 'package:island/pods/site_pages.dart';
import 'package:island/screens/creators/sites/site_edit.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

part 'site_detail.g.dart';

@riverpod
Future<SnPublicationSite> publicationSiteDetail(
  Ref ref,
  String pubName,
  String siteSlug,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/zone/sites/$pubName/$siteSlug');
  return SnPublicationSite.fromJson(resp.data);
}

class PublicationSiteDetailScreen extends HookConsumerWidget {
  final String siteSlug;
  final String pubName;

  const PublicationSiteDetailScreen({
    super.key,
    required this.siteSlug,
    required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siteAsync = ref.watch(
      publicationSiteDetailProvider(pubName, siteSlug),
    );

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        title: siteAsync.maybeWhen(
          data: (site) => Text(site.name),
          orElse: () => const Text('Site Details'),
        ),
        actions: [
          siteAsync.maybeWhen(
            data: (site) => _SiteActionMenu(site: site, pubName: pubName),
            orElse: () => const SizedBox.shrink(),
          ),
          const Gap(8),
        ],
      ),
      body: siteAsync.when(
        data: (site) => _SiteDetailContent(site: site, pubName: pubName),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load site',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(16),
                  Text(error.toString()),
                  const Gap(24),
                  ElevatedButton(
                    onPressed:
                        () => ref.invalidate(
                          publicationSiteDetailProvider(pubName, siteSlug),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: siteAsync.maybeWhen(
        data:
            (site) => FloatingActionButton(
              onPressed: () {
                // Create new page
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => PageForm(site: site, pubName: pubName),
                ).then((_) {
                  // Refresh pages after creation
                  ref.invalidate(sitePagesProvider(pubName, site.slug));
                });
              },
              child: const Icon(Symbols.add),
            ),
        orElse: () => null,
      ),
    );
  }
}

class FileUploadDialog extends HookConsumerWidget {
  final List<File> selectedFiles;
  final SnPublicationSite site;
  final VoidCallback onUploadComplete;

  const FileUploadDialog({
    super.key,
    required this.selectedFiles,
    required this.site,
    required this.onUploadComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final pathController = useTextEditingController(text: '/');
    final isUploading = useState(false);
    final progressStates = useState<List<Map<String, dynamic>>>(
      selectedFiles
          .map(
            (file) => {
              'fileName': file.path.split('/').last,
              'progress': 0.0,
              'status':
                  'pending', // 'pending', 'uploading', 'completed', 'error'
              'error': null,
            },
          )
          .toList(),
    );

    final uploadFile = useCallback((
      String basePath,
      File file,
      int index,
    ) async {
      try {
        progressStates.value[index]['status'] = 'uploading';
        progressStates.value = [...progressStates.value];

        final siteFilesNotifier = ref.read(
          siteFilesNotifierProvider((siteId: site.id, path: null)).notifier,
        );

        final fileName = file.path.split('/').last;
        final uploadPath =
            basePath.endsWith('/')
                ? '$basePath$fileName'
                : '$basePath/$fileName';

        await siteFilesNotifier.uploadFile(file, uploadPath);

        progressStates.value[index]['status'] = 'completed';
        progressStates.value[index]['progress'] = 1.0;
        progressStates.value = [...progressStates.value];
      } catch (e) {
        progressStates.value[index]['status'] = 'error';
        progressStates.value[index]['error'] = e.toString();
        progressStates.value = [...progressStates.value];
      }
    }, [ref, site.id, progressStates]);

    final uploadAllFiles = useCallback(
      () async {
        if (!formKey.currentState!.validate()) return;

        isUploading.value = true;

        // Reset all progress states
        for (int i = 0; i < progressStates.value.length; i++) {
          progressStates.value[i]['status'] = 'pending';
          progressStates.value[i]['progress'] = 0.0;
          progressStates.value[i]['error'] = null;
        }
        progressStates.value = [...progressStates.value];

        // Upload files sequentially (could be made parallel if needed)
        for (int i = 0; i < selectedFiles.length; i++) {
          final file = selectedFiles[i];
          await uploadFile(pathController.text, file, i);
        }

        isUploading.value = false;
        onUploadComplete();

        // Close dialog if all uploads completed successfully
        if (progressStates.value.every(
          (state) => state['status'] == 'completed',
        )) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All files uploaded successfully')),
            );
            Navigator.of(context).pop();
          }
        }
      },
      [
        uploadFile,
        isUploading,
        progressStates,
        selectedFiles,
        onUploadComplete,
        context,
        formKey,
        pathController,
      ],
    );

    return SheetScaffold(
      titleText: 'Upload Files',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload path field
              TextFormField(
                controller: pathController,
                decoration: const InputDecoration(
                  labelText: 'Upload Path',
                  hintText: '/ (root) or /assets/images/',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an upload path';
                  }
                  if (!value.startsWith('/') && value != '/') {
                    return 'Path must start with /';
                  }
                  if (value.contains(' ')) {
                    return 'Path cannot contain spaces';
                  }
                  if (value.contains('//')) {
                    return 'Path cannot have consecutive slashes';
                  }
                  return null;
                },
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const Gap(20),
              Text(
                'Ready to upload ${selectedFiles.length} file${selectedFiles.length == 1 ? '' : 's'}:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(16),
              ...selectedFiles.map((file) {
                final index = selectedFiles.indexOf(file);
                final progressState = progressStates.value[index];
                final fileName = file.path.split('/').last;
                final fileSize = file.lengthSync();
                final fileSizeText =
                    fileSize < 1024 * 1024
                        ? '${(fileSize / 1024).toStringAsFixed(1)} KB'
                        : '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.description,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                fileName,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              fileSizeText,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (progressState['status'] == 'uploading') ...[
                          const Gap(8),
                          LinearProgressIndicator(
                            value: progressState['progress'],
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          const Gap(4),
                          Text(
                            'Uploading... ${(progressState['progress'] * 100).toStringAsFixed(0)}%',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ] else if (progressState['status'] == 'completed') ...[
                          const Gap(8),
                          Row(
                            children: [
                              Icon(
                                Symbols.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const Gap(4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ] else if (progressState['status'] == 'error') ...[
                          const Gap(8),
                          Row(
                            children: [
                              Icon(Symbols.error, color: Colors.red, size: 16),
                              const Gap(4),
                              Expanded(
                                child: Text(
                                  progressState['error'] ?? 'Upload failed',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Show the final upload path when not uploading
                        if (!isUploading.value &&
                            progressState['status'] != 'uploading') ...[
                          const Gap(8),
                          Text(
                            'Will upload to: ${pathController.text.endsWith('/') ? pathController.text : '${pathController.text}/'}$fileName',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isUploading.value
                              ? null
                              : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isUploading.value ? null : uploadAllFiles,
                      child: Text(
                        isUploading.value
                            ? 'Uploading...'
                            : 'Upload ${selectedFiles.length} File${selectedFiles.length == 1 ? '' : 's'}',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PageForm extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;
  final SnPublicationPage? page; // null for create, non-null for edit

  const PageForm({
    super.key,
    required this.site,
    required this.pubName,
    this.page,
  });

  int _getPageType(SnPublicationPage? page) {
    if (page == null) return 0; // Default to HTML
    // Check config structure to determine type
    return page.config?.containsKey('target') == true ? 1 : 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final pathController = useTextEditingController(text: page?.path ?? '/');

    // Determine initial type and create appropriate controllers
    final initialType = _getPageType(page);
    final pageType = useState(initialType);

    final htmlController = useTextEditingController(
      text:
          pageType.value == 0
              ? (page?.config?['html'] ?? page?.config?['content'] ?? '')
              : '',
    );
    final titleController = useTextEditingController(
      text: pageType.value == 0 ? (page?.config?['title'] ?? '') : '',
    );
    final targetController = useTextEditingController(
      text: pageType.value == 1 ? (page?.config?['target'] ?? '') : '',
    );

    final isLoading = useState(false);

    // Update controllers when page type changes
    useEffect(() {
      pageType.addListener(() {
        if (pageType.value == 0) {
          // HTML mode
          htmlController.text =
              page?.config?['html'] ?? page?.config?['content'] ?? '';
          titleController.text = page?.config?['title'] ?? '';
          targetController.clear();
        } else {
          // Redirect mode
          htmlController.clear();
          titleController.clear();
          targetController.text = page?.config?['target'] ?? '';
        }
      });
      return null;
    }, [pageType]);

    // Initialize form fields when page data is loaded
    useEffect(() {
      if (page?.path != null && pathController.text == '/') {
        pathController.text = page!.path!;
        if (pageType.value == 0) {
          htmlController.text =
              page!.config?['html'] ?? page!.config?['content'] ?? '';
          titleController.text = page!.config?['title'] ?? '';
        } else {
          targetController.text = page!.config?['target'] ?? '';
        }
      }
      return null;
    }, [page]);

    final savePage = useCallback(() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        final pagesNotifier = ref.read(
          sitePagesNotifierProvider((
            pubName: pubName,
            siteSlug: site.slug,
          )).notifier,
        );

        late final Map<String, dynamic> pageData;

        if (pageType.value == 0) {
          // HTML page
          pageData = {
            'type': 0,
            'path': pathController.text,
            'config': {
              'title': titleController.text,
              'html': htmlController.text,
            },
          };
        } else {
          // Redirect page
          pageData = {
            'type': 1,
            'path': pathController.text,
            'config': {'target': targetController.text},
          };
        }

        if (page == null) {
          // Create new page
          await pagesNotifier.createPage(pageData);
        } else {
          // Update existing page
          await pagesNotifier.updatePage(page!.id, pageData);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                page == null
                    ? 'Page created successfully'
                    : 'Page updated successfully',
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save page: ${e.toString()}')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }, [pageType, pubName, site.slug, page]);

    final deletePage = useCallback(() async {
      if (page == null) return; // Shouldn't happen for editing

      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Delete Page'),
              content: const Text('Are you sure you want to delete this page?'),
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
      if (confirmed != true) return;

      isLoading.value = true;

      try {
        final pagesNotifier = ref.read(
          sitePagesNotifierProvider((
            pubName: pubName,
            siteSlug: site.slug,
          )).notifier,
        );

        await pagesNotifier.deletePage(page!.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Page deleted successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete page')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }, [pubName, site.slug, page, context]);

    return SheetScaffold(
      titleText: page == null ? 'Create Page' : 'Edit Page',
      child: Builder(
        builder:
            (context) => SingleChildScrollView(
              child: Column(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // Page type selector
                        DropdownButtonFormField<int>(
                          value: pageType.value,
                          decoration: const InputDecoration(
                            labelText: 'Page Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 0,
                              child: Row(
                                children: [
                                  Icon(Symbols.code, size: 20),
                                  Gap(8),
                                  Text('HTML Page'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(Symbols.link, size: 20),
                                  Gap(8),
                                  Text('Redirect Page'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              pageType.value = value;
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a page type';
                            }
                            return null;
                          },
                        ).padding(all: 20),
                        // Conditional form fields based on page type
                        if (pageType.value == 0) ...[
                          // HTML Page fields
                          TextFormField(
                            controller: pathController,
                            decoration: const InputDecoration(
                              labelText: 'Page Path',
                              hintText: '/about, /contact, etc.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a page path';
                              }
                              if (!RegExp(
                                r'^[a-zA-Z0-9\-/_]+$',
                              ).hasMatch(value)) {
                                return 'Page path can only contain letters, numbers, hyphens, underscores, and slashes';
                              }
                              if (!value.startsWith('/')) {
                                return 'Page path must start with /';
                              }
                              if (value.contains('//')) {
                                return 'Page path cannot have consecutive slashes';
                              }
                              return null;
                            },
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ).padding(horizontal: 20),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              labelText: 'Page Title',
                              hintText: 'About Us, Contact, etc.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a page title';
                              }
                              return null;
                            },
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ).padding(horizontal: 20),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: htmlController,
                            decoration: const InputDecoration(
                              labelText: 'Page Content (HTML)',
                              hintText:
                                  '<h1>Hello World</h1><p>This is my page content...</p>',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 10,
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter HTML content for the page';
                              }
                              return null;
                            },
                          ).padding(horizontal: 20),
                        ] else ...[
                          // Redirect Page fields
                          TextFormField(
                            controller: pathController,
                            decoration: const InputDecoration(
                              labelText: 'Page Path',
                              hintText: '/old-page, /redirect, etc.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              prefixText: '/',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a page path';
                              }
                              if (!RegExp(
                                r'^[a-zA-Z0-9\-/_]+$',
                              ).hasMatch(value)) {
                                return 'Page path can only contain letters, numbers, hyphens, underscores, and slashes';
                              }
                              if (!value.startsWith('/')) {
                                return 'Page path must start with /';
                              }
                              if (value.contains('//')) {
                                return 'Page path cannot have consecutive slashes';
                              }
                              return null;
                            },
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ).padding(horizontal: 20),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: targetController,
                            decoration: const InputDecoration(
                              labelText: 'Redirect Target',
                              hintText: '/new-page, https://example.com, etc.',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a redirect target';
                              }
                              if (!value.startsWith('/') &&
                                  !value.startsWith('http://') &&
                                  !value.startsWith('https://')) {
                                return 'Target must be a relative path (/) or absolute URL (http/https)';
                              }
                              return null;
                            },
                            onTapOutside:
                                (_) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                          ).padding(horizontal: 20),
                        ],
                      ],
                    ).padding(vertical: 20),
                  ),
                  Row(
                    children: [
                      if (page != null) ...[
                        TextButton.icon(
                          onPressed: deletePage,
                          icon: const Icon(Symbols.delete_forever),
                          label: const Text('Delete Page'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ).alignment(Alignment.centerRight),
                        const Spacer(),
                      ] else
                        const Spacer(),
                      TextButton.icon(
                        onPressed: savePage,
                        icon: const Icon(Symbols.save),
                        label: const Text('Save Page'),
                      ),
                    ],
                  ).padding(horizontal: 20, vertical: 12),
                ],
              ),
            ),
      ),
    );
  }
}

class _PagesSection extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const _PagesSection({required this.site, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(sitePagesProvider(pubName, site.slug));
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Symbols.article, size: 20),
                const Gap(8),
                Text(
                  'Pages',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Open page creation dialog
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder:
                          (context) => PageForm(site: site, pubName: pubName),
                    ).then((_) {
                      // Refresh pages after creation
                      ref.invalidate(sitePagesProvider(pubName, site.slug));
                    });
                  },
                  icon: const Icon(Symbols.add),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
              ],
            ),
            const Gap(16),
            pagesAsync.when(
              data: (pages) {
                if (pages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Symbols.article,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const Gap(16),
                          Text(
                            'No pages yet',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const Gap(8),
                          Text(
                            'Create your first page to get started',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return _PageItem(page: page, site: site, pubName: pubName);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      children: [
                        Text('Failed to load pages'),
                        const Gap(8),
                        ElevatedButton(
                          onPressed:
                              () => ref.invalidate(
                                sitePagesProvider(pubName, site.slug),
                              ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageItem extends HookConsumerWidget {
  final SnPublicationPage page;
  final SnPublicationSite site;
  final String pubName;

  const _PageItem({
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
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Page deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete page')),
                      );
                    }
                  }
                }
                break;
            }
          },
        ),
        onTap: () {
          // TODO: Open page preview or edit
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening page: ${page.path ?? '/'}')),
          );
        },
      ),
    );
  }
}

class _FileManagementSection extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const _FileManagementSection({required this.site, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(siteFilesProvider(siteId: site.id));
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Symbols.folder, size: 20),
                const Gap(8),
                Text(
                  'File Management',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    // Open file upload dialog
                    final selectedFiles = await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                      type: FileType.any,
                    );

                    if (selectedFiles == null || selectedFiles.files.isEmpty) {
                      return; // User canceled
                    }

                    if (!context.mounted) return;

                    // Show upload dialog for path specification
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder:
                          (context) => FileUploadDialog(
                            selectedFiles:
                                selectedFiles.files
                                    .map((f) => File(f.path!))
                                    .toList(),
                            site: site,
                            onUploadComplete: () {
                              // Refresh file list
                              ref.invalidate(
                                siteFilesProvider(siteId: site.id),
                              );
                            },
                          ),
                    );
                  },
                  icon: const Icon(Symbols.upload),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
              ],
            ),
            const Gap(16),
            filesAsync.when(
              data: (files) {
                if (files.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Symbols.folder,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                          const Gap(16),
                          Text(
                            'No files uploaded yet',
                            style: theme.textTheme.bodyLarge,
                          ),
                          const Gap(8),
                          Text(
                            'Upload your first file to get started',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return _FileItem(file: file, site: site);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      children: [
                        Text('Failed to load files'),
                        const Gap(8),
                        ElevatedButton(
                          onPressed:
                              () => ref.invalidate(
                                siteFilesProvider(siteId: site.id),
                              ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileItem extends HookConsumerWidget {
  final SnSiteFileEntry file;
  final SnPublicationSite site;

  const _FileItem({required this.file, required this.site});

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
        leading: Icon(
          file.isDirectory ? Symbols.folder : Symbols.description,
          color: theme.colorScheme.primary,
        ),
        title: Text(file.relativePath),
        subtitle: Text(
          file.isDirectory
              ? 'Directory'
              : '${(file.size / 1024).toStringAsFixed(1)} KB',
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'download',
                  child: Row(
                    children: [
                      const Icon(Symbols.download),
                      const Gap(16),
                      Text('Download'),
                    ],
                  ),
                ),
                if (!file.isDirectory) ...[
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Symbols.edit),
                        const Gap(16),
                        Text('Edit Content'),
                      ],
                    ),
                  ),
                ],
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Symbols.delete, color: Colors.red),
                      const Gap(16),
                      Text('Delete').textColor(Colors.red),
                    ],
                  ),
                ),
              ],
          onSelected: (value) async {
            switch (value) {
              case 'download':
                // TODO: Implement file download
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading ${file.relativePath}')),
                );
                break;
              case 'edit':
                // TODO: Implement file editing
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editing ${file.relativePath}')),
                );
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Delete File'),
                        content: Text(
                          'Are you sure you want to delete "${file.relativePath}"?',
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
                          siteFilesNotifierProvider((
                            siteId: site.id,
                            path: null,
                          )).notifier,
                        )
                        .deleteFile(file.relativePath);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File deleted successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete file')),
                      );
                    }
                  }
                }
                break;
            }
          },
        ),
        onTap: () {
          if (file.isDirectory) {
            // TODO: Navigate into directory
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening directory: ${file.relativePath}'),
              ),
            );
          } else {
            // TODO: Open file preview/editor
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening file: ${file.relativePath}')),
            );
          }
        },
      ),
    );
  }
}

class _SiteDetailContent extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const _SiteDetailContent({required this.site, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ExtendedRefreshIndicator(
      onRefresh:
          () async =>
              ref.invalidate(publicationSiteDetailProvider(pubName, site.slug)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Site Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Site Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(16),
                    _InfoRow(
                      label: 'Name',
                      value: site.name,
                      icon: Symbols.title,
                    ),
                    const Gap(8),
                    _InfoRow(
                      label: 'Slug',
                      value: site.slug,
                      icon: Symbols.tag,
                      monospace: true,
                    ),
                    const Gap(8),
                    _InfoRow(
                      label: 'Mode',
                      value: site.mode == 0 ? 'Fully Managed' : 'Self-Managed',
                      icon: Symbols.settings,
                    ),
                    if (site.description != null &&
                        site.description!.isNotEmpty) ...[
                      const Gap(8),
                      _InfoRow(
                        label: 'Description',
                        value: site.description!,
                        icon: Symbols.description,
                      ),
                    ],
                    const Gap(8),
                    _InfoRow(
                      label: 'Created',
                      value: site.createdAt.formatSystem(),
                      icon: Symbols.calendar_add_on,
                    ),
                    const Gap(8),
                    _InfoRow(
                      label: 'Updated',
                      value: site.updatedAt.formatSystem(),
                      icon: Symbols.update,
                    ),
                  ],
                ),
              ),
            ),
            // Pages Section
            _PagesSection(site: site, pubName: pubName),
            _FileManagementSection(site: site, pubName: pubName),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool monospace;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const Gap(12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style:
                monospace
                    ? GoogleFonts.robotoMono(fontSize: 14)
                    : Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _SiteActionMenu extends HookConsumerWidget {
  final SnPublicationSite site;
  final String pubName;

  const _SiteActionMenu({required this.site, required this.pubName});

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
                    title: const Text('Delete Site'),
                    content: const Text(
                      'Are you sure you want to delete this publication site? This action cannot be undone.',
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
                final client = ref.read(apiClientProvider);
                await client.delete('/zone/sites/${site.id}');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Site deleted successfully')),
                  );
                  // Navigate back to list
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete site')),
                  );
                }
              }
            }
            break;
        }
      },
    );
  }
}
