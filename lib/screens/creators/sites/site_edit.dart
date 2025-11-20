import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/sites/site_list.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class SiteForm extends HookConsumerWidget {
  final String pubName;
  final String? siteId;

  const SiteForm({super.key, required this.pubName, this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final slugController = useTextEditingController();
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final isLoading = useState(false);

    final saveSite = useCallback(() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        final client = ref.read(apiClientProvider);
        final url = '/zone/sites/$pubName';
        final payload = <String, dynamic>{
          'slug': slugController.text,
          'name': nameController.text,
          if (descriptionController.text.isNotEmpty)
            'description': descriptionController.text,
        };

        if (siteId != null) {
          await client.patch('$url/$siteId', data: payload);
        } else {
          await client.post(url, data: payload);
        }

        // Refresh the site list
        ref.invalidate(siteListNotifierProvider(pubName));

        if (context.mounted) {
          showSnackBar('Publication site saved successfully');
          Navigator.pop(context);
        }
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isLoading.value = false;
      }
    }, [pubName, siteId, context]);

    final deleteSite = useCallback(() async {
      final confirmed = await showConfirmAlert(
        'Are you sure you want to delete this publication site? This action cannot be undone.',
        'Delete Publication Site',
      );
      if (confirmed != true) return;

      isLoading.value = true;

      try {
        final client = ref.read(apiClientProvider);
        await client.delete('/zone/sites/${siteId!}');

        ref.invalidate(siteListNotifierProvider(pubName));

        if (context.mounted) {
          showSnackBar('Publication site deleted successfully');
          Navigator.pop(context);
        }
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isLoading.value = false;
      }
    }, [pubName, siteId, context]);

    // Handle loading and error states for editing
    final isFetchLoading = useState(siteId != null);
    final site = useState<SnPublicationSite?>(null);
    final errorMessage = useState<String?>(null);

    useEffect(() {
      if (siteId == null) return;

      Future<void> fetchSite() async {
        try {
          final client = ref.read(apiClientProvider);
          final response = await client.get('/zone/sites/$siteId');
          final fetchedSite = SnPublicationSite.fromJson(response.data);
          site.value = fetchedSite;

          // Initialize form fields if they're empty and we have a site
          if (nameController.text.isEmpty) {
            slugController.text = fetchedSite.slug;
            nameController.text = fetchedSite.name;
            descriptionController.text = fetchedSite.description ?? '';
          }
        } catch (e) {
          errorMessage.value = e.toString();
        } finally {
          isFetchLoading.value = false;
        }
      }

      fetchSite();
      return null;
    }, [siteId]);

    if (siteId != null && isFetchLoading.value) {
      return const SheetScaffold(
        titleText: 'Edit Publication Site',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (siteId != null && errorMessage.value != null) {
      return SheetScaffold(
        titleText: 'Edit Publication Site',
        child: ResponseErrorWidget(
          error: errorMessage.value!,
          onRetry: () {
            isFetchLoading.value = true;
            errorMessage.value = null;
            // Refetch
            useEffect(() {
              Future<void> fetchSite() async {
                try {
                  final client = ref.read(apiClientProvider);
                  final response = await client.get('/zone/sites/$siteId');
                  final fetchedSite = SnPublicationSite.fromJson(response.data);
                  site.value = fetchedSite;
                  slugController.text = fetchedSite.slug;
                  nameController.text = fetchedSite.name;
                  descriptionController.text = fetchedSite.description ?? '';
                } catch (e) {
                  errorMessage.value = e.toString();
                } finally {
                  isFetchLoading.value = false;
                }
              }

              fetchSite();
              return null;
            }, ['$siteId-${DateTime.now().millisecondsSinceEpoch}']);
          },
        ),
      );
    }

    final formFields = Column(
      children: [
        TextFormField(
          controller: slugController,
          decoration: const InputDecoration(
            labelText: 'Slug',
            hintText: 'my-site',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a slug';
            }
            final slugRegex = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
            if (!slugRegex.hasMatch(value)) {
              return 'Slug can only contain lowercase letters, numbers, and dashes';
            }
            return null;
          },
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Site Name',
            hintText: 'My Publication Site',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a site name';
            }
            return null;
          },
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          maxLines: 3,
        ),
      ],
    ).padding(all: 20);

    final saveButton = TextButton.icon(
      onPressed: isLoading.value ? null : saveSite,
      icon: const Icon(Symbols.save),
      label: Text('saveChanges').tr(),
    ).padding(horizontal: 20, vertical: 12);

    return SheetScaffold(
      titleText:
          siteId == null ? 'New Publication Site' : 'Edit Publication Site',
      child: SingleChildScrollView(
        child: Column(
          children: [
            Form(key: formKey, child: formFields),
            Row(
              children: [
                if (siteId != null) ...[
                  TextButton.icon(
                    onPressed: isLoading.value ? null : deleteSite,
                    icon: const Icon(Symbols.delete_forever),
                    label: const Text('Delete Publication Site'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ).alignment(Alignment.centerRight),
                  const SizedBox(height: 16),
                ],
                const Spacer(),
                saveButton,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
