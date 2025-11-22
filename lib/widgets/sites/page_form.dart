import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/site_pages.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

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
      child: SingleChildScrollView(
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
                        borderRadius: BorderRadius.all(Radius.circular(12)),
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
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a page path';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9\-/_]+$').hasMatch(value)) {
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
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ).padding(horizontal: 20),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Page Title',
                        hintText: 'About Us, Contact, etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a page title';
                        }
                        return null;
                      },
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ).padding(horizontal: 20),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: htmlController,
                      decoration: const InputDecoration(
                        labelText: 'Page Content (HTML)',
                        hintText:
                            '<h1>Hello World</h1><p>This is my page content...</p>',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 10,
                      onTapOutside:
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a page path';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9\-/_]+$').hasMatch(value)) {
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
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ).padding(horizontal: 20),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: targetController,
                      decoration: const InputDecoration(
                        labelText: 'Redirect Target',
                        hintText: '/new-page, https://example.com, etc.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
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
                          (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    ).padding(horizontal: 20),
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
                    ).padding(horizontal: 20, vertical: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
