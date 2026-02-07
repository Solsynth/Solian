import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/publication_site.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:island/sites/site_pages.dart';
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
    if (page.config?.containsKey('filter') == true ||
        page.config?.containsKey('layout') == true) {
      return 2; // Post Page
    }
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
      text: pageType.value == 0
          ? (page?.config?['html'] ?? page?.config?['content'] ?? '')
          : '',
    );
    final titleController = useTextEditingController(
      text: pageType.value == 0 ? (page?.config?['title'] ?? '') : '',
    );
    final targetController = useTextEditingController(
      text: pageType.value == 1 ? (page?.config?['target'] ?? '') : '',
    );

    // Post Page Controllers
    final filterPubNameController = useTextEditingController(
      text: pageType.value == 2
          ? (page?.config?['filter']?['pub_name'] ?? '')
          : '',
    );
    final filterOrderByController = useTextEditingController(
      text: pageType.value == 2
          ? (page?.config?['filter']?['order_by'] ?? '')
          : '',
    );
    final filterOrderDesc = useState(
      pageType.value == 2
          ? (page?.config?['filter']?['order_desc'] ?? true)
          : true,
    );
    final filterTypes = useState<List<int>>(
      (page?.config?['filter']?['types'] as List?)?.cast<int>() ?? [0],
    );

    final layoutTitleController = useTextEditingController(
      text: pageType.value == 2
          ? (page?.config?['layout']?['title'] ?? '')
          : '',
    );
    final layoutDescriptionController = useTextEditingController(
      text: pageType.value == 2
          ? (page?.config?['layout']?['description'] ?? '')
          : '',
    );
    final layoutShowPub = useState(
      pageType.value == 2
          ? (page?.config?['layout']?['show_pub'] ?? true)
          : true,
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
          filterPubNameController.clear();
          filterOrderByController.clear();
          layoutTitleController.clear();
          layoutDescriptionController.clear();
        } else if (pageType.value == 1) {
          // Redirect mode
          htmlController.clear();
          titleController.clear();
          targetController.text = page?.config?['target'] ?? '';
          filterPubNameController.clear();
          filterOrderByController.clear();
          layoutTitleController.clear();
          layoutDescriptionController.clear();
        } else if (pageType.value == 2) {
          // Post Page mode
          htmlController.clear();
          titleController.clear();
          targetController.clear();
          filterPubNameController.text =
              page?.config?['filter']?['pub_name'] ?? '';
          filterOrderByController.text =
              page?.config?['filter']?['order_by'] ?? '';
          filterOrderDesc.value =
              page?.config?['filter']?['order_desc'] ?? true;
          filterTypes.value =
              (page?.config?['filter']?['types'] as List?)?.cast<int>() ?? [0];
          layoutTitleController.text = page?.config?['layout']?['title'] ?? '';
          layoutDescriptionController.text =
              page?.config?['layout']?['description'] ?? '';
          layoutShowPub.value = page?.config?['layout']?['show_pub'] ?? true;
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
        } else if (pageType.value == 1) {
          targetController.text = page!.config?['target'] ?? '';
        } else if (pageType.value == 2) {
          filterPubNameController.text =
              page!.config?['filter']?['pub_name'] ?? '';
          filterOrderByController.text =
              page!.config?['filter']?['order_by'] ?? '';
          filterOrderDesc.value =
              page!.config?['filter']?['order_desc'] ?? true;
          filterTypes.value =
              (page!.config?['filter']?['types'] as List?)?.cast<int>() ?? [0];
          layoutTitleController.text = page!.config?['layout']?['title'] ?? '';
          layoutDescriptionController.text =
              page!.config?['layout']?['description'] ?? '';
          layoutShowPub.value = page!.config?['layout']?['show_pub'] ?? true;
        }
      }
      return null;
    }, [page]);

    final savePage = useCallback(
      () async {
        if (!formKey.currentState!.validate()) return;

        isLoading.value = true;

        try {
          final provider = sitePagesNotifierProvider((
            pubName: pubName,
            siteSlug: site.slug,
          ));
          final pagesNotifier = ref.read(provider.notifier);

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
          } else if (pageType.value == 1) {
            // Redirect page
            pageData = {
              'type': 1,
              'path': pathController.text,
              'config': {'target': targetController.text},
            };
          } else {
            // Post Page
            pageData = {
              'type': 2,
              'path': pathController.text,
              'config': {
                'filter': {
                  if (filterPubNameController.text.isNotEmpty)
                    'pub_name': filterPubNameController.text,
                  if (filterOrderByController.text.isNotEmpty)
                    'order_by': filterOrderByController.text,
                  'order_desc': filterOrderDesc.value,
                  'types': filterTypes.value,
                },
                'layout': {
                  if (layoutTitleController.text.isNotEmpty)
                    'title': layoutTitleController.text,
                  if (layoutDescriptionController.text.isNotEmpty)
                    'description': layoutDescriptionController.text,
                  'show_pub': layoutShowPub.value,
                },
              },
            };
          }

          if (page == null) {
            // Create new page
            await pagesNotifier.createPage(pageData);
          } else {
            // Update existing page
            await pagesNotifier.updatePage(page!.id, pageData);
          }
          ref.invalidate(provider);

          if (context.mounted) {
            showSnackBar(
              page == null
                  ? 'Page created successfully'
                  : 'Page updated successfully',
            );
            Navigator.pop(context);
          }
        } catch (e) {
          showErrorAlert(e);
        } finally {
          isLoading.value = false;
        }
      },
      [
        pageType,
        pubName,
        site.slug,
        page,
        filterOrderDesc.value,
        filterTypes.value,
        layoutShowPub.value,
      ],
    );

    final deletePage = useCallback(() async {
      if (page == null) return; // Shouldn't happen for editing

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
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
          showSnackBar('Page deleted successfully');
          Navigator.pop(context);
        }
      } catch (e) {
        showErrorAlert(e);
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
                      DropdownMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(Symbols.article, size: 20),
                            Gap(8),
                            Text('Post Page'),
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

                  // Common "Path" field for all types
                  TextFormField(
                    controller: pathController,
                    decoration: const InputDecoration(
                      labelText: 'Page Path',
                      hintText: '/about, /posts, etc.',
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
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ).padding(horizontal: 20),
                  const SizedBox(height: 16),

                  // Conditional form fields based on page type
                  if (pageType.value == 0) ...[
                    // HTML Page fields
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
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
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
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter HTML content for the page';
                        }
                        return null;
                      },
                    ).padding(horizontal: 20),
                  ] else if (pageType.value == 1) ...[
                    // Redirect Page fields
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
                            // ignore: use_string_starts_with_pattern
                            !value.startsWith('http://') &&
                            // ignore: use_string_starts_with_pattern
                            !value.startsWith('https://')) {
                          return 'Target must be a relative path (/) or absolute URL (http/https)';
                        }
                        return null;
                      },
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ).padding(horizontal: 20),
                  ] else if (pageType.value == 2) ...[
                    // Post Page fields
                    const Text(
                      'Filter Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ).alignment(Alignment.centerLeft).padding(horizontal: 24),
                    const Gap(8),
                    TextFormField(
                      controller: filterPubNameController,
                      decoration: const InputDecoration(
                        labelText: 'Publication Name (Optional)',
                        hintText: 'Filter by publication name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ).padding(horizontal: 20),
                    const Gap(16),
                    TextFormField(
                      controller: filterOrderByController,
                      decoration: const InputDecoration(
                        labelText: 'Order By (Optional)',
                        hintText: 'e.g. published_at',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ).padding(horizontal: 20),
                    const Gap(8),
                    SwitchListTile(
                      value: filterOrderDesc.value,
                      onChanged: (value) => filterOrderDesc.value = value,
                      title: const Text('Order Descending'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                    const Gap(8),
                    const Text(
                      'Content Types',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ).alignment(Alignment.centerLeft).padding(horizontal: 24),
                    const Gap(4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      children: [
                        FilterChip(
                          label: const Text('Regular Post'),
                          selected: filterTypes.value.contains(0),
                          onSelected: (selected) {
                            final types = [...filterTypes.value];
                            if (selected) {
                              types.add(0);
                            } else {
                              types.remove(0);
                            }
                            filterTypes.value = types;
                          },
                        ),
                        FilterChip(
                          label: const Text('Article'),
                          selected: filterTypes.value.contains(1),
                          onSelected: (selected) {
                            final types = [...filterTypes.value];
                            if (selected) {
                              types.add(1);
                            } else {
                              types.remove(1);
                            }
                            filterTypes.value = types;
                          },
                        ),
                      ],
                    ).padding(horizontal: 20),
                    const Gap(24),
                    const Text(
                      'Layout Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ).alignment(Alignment.centerLeft).padding(horizontal: 24),
                    const Gap(8),
                    TextFormField(
                      controller: layoutTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Title (Optional)',
                        hintText: 'Page Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ).padding(horizontal: 20),
                    const Gap(16),
                    TextFormField(
                      controller: layoutDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'Page Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ).padding(horizontal: 20),
                    const Gap(8),
                    SwitchListTile(
                      value: layoutShowPub.value,
                      onChanged: (value) => layoutShowPub.value = value,
                      title: const Text('Show Publication Info'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ],

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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
