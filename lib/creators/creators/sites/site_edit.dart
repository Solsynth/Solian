import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/creators/sites/site_detail.dart';
import 'package:island/creators/creators/sites/site_list.dart';
import 'package:island/creators/creators/sites/widgets/site_config_form.dart';
import 'package:island/creators/publication_site.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class SiteForm extends HookConsumerWidget {
  final String pubName;
  final String? siteSlug;

  const SiteForm({super.key, required this.pubName, this.siteSlug});

  Widget _buildForm(
    GlobalKey<FormState> formKey,
    TextEditingController slugController,
    TextEditingController nameController,
    TextEditingController descriptionController,
    ValueNotifier<int> modeController,
    ValueNotifier<SnPublicationSiteConfig> configController,
    Function() saveSite,
    Function() deleteSite,
    String siteSlug,
  ) {
    final formFields = Column(
      children: [
        TextFormField(
          controller: slugController,
          decoration: InputDecoration(
            labelText: 'siteSlug'.tr(),
            hintText: 'siteSlugHint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'siteSlugRequired'.tr();
            }
            final slugRegex = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');
            if (!slugRegex.hasMatch(value)) {
              return 'siteSlugInvalid'.tr();
            }
            return null;
          },
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'siteName'.tr(),
            hintText: 'siteNameHint'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'siteNameRequired'.tr();
            }
            return null;
          },
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'description'.tr(),
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: modeController.value,
          decoration: InputDecoration(
            labelText: 'siteMode'.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text('siteModeFullyManaged'.tr()),
            ),
            DropdownMenuItem(value: 1, child: Text('siteModeSelfManaged'.tr())),
          ],
          onChanged: (value) {
            if (value != null) {
              modeController.value = value;
            }
          },
        ),
        const SizedBox(height: 16),
        SiteConfigForm(
          initialConfig: configController.value,
          onChanged: (value) => configController.value = value,
        ),
      ],
    ).padding(all: 20);

    return SheetScaffold(
      titleText: 'editPublicationSite'.tr(),
      child: Builder(
        builder: (context) => SingleChildScrollView(
          child: Column(
            children: [
              Form(key: formKey, child: formFields),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: deleteSite,
                    icon: const Icon(Symbols.delete_forever),
                    label: Text('deletePublicationSite'.tr()),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ).alignment(Alignment.centerRight),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: saveSite,
                    icon: const Icon(Symbols.save),
                    label: Text('saveChanges').tr(),
                  ),
                ],
              ).padding(horizontal: 20, vertical: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final slugController = useTextEditingController();
    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final modeController = useState<int>(0); // Default to fully managed (0)
    final configController = useState<SnPublicationSiteConfig>(
      const SnPublicationSiteConfig(),
    );
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
          'mode': modeController.value,
          if (descriptionController.text.isNotEmpty)
            'description': descriptionController.text,
          'config': configController.value.toJson(),
        };

        if (siteSlug != null) {
          await client.patch('$url/$siteSlug', data: payload);
        } else {
          await client.post(url, data: payload);
        }

        // Refresh the site list
        ref.invalidate(siteListNotifierProvider(pubName));

        if (context.mounted) {
          showSnackBar('publicationSiteSavedSuccess'.tr());
          Navigator.pop(context);
        }
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isLoading.value = false;
      }
    }, [pubName, siteSlug, context]);

    final deleteSite = useCallback(() async {
      if (siteSlug == null) return; // Shouldn't happen for editing

      final confirmed = await showConfirmAlert(
        'publicationSiteDeleteConfirm'.tr(),
        'deletePublicationSite'.tr(),
        isDanger: true,
      );
      if (confirmed != true) return;

      isLoading.value = true;

      try {
        final client = ref.read(apiClientProvider);
        await client.delete('/zone/sites/$pubName/$siteSlug');

        ref.invalidate(siteListNotifierProvider(pubName));

        if (context.mounted) {
          showSnackBar('publicationSiteDeletedSuccess'.tr());
          Navigator.pop(context);
        }
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isLoading.value = false;
      }
    }, [pubName, siteSlug, context]);

    // Use Riverpod provider for loading and error states for editing
    if (siteSlug != null) {
      final editingSiteSlug =
          siteSlug!; // Assert non-null since we checked above
      final siteAsync = ref.watch(
        publicationSiteDetailProvider(pubName, editingSiteSlug),
      );

      // Initialize form fields when site data is loaded
      useEffect(() {
        if (siteAsync.value != null && nameController.text.isEmpty) {
          final site = siteAsync.value!;
          slugController.text = site.slug;
          nameController.text = site.name;
          descriptionController.text = site.description ?? '';
          modeController.value = site.mode ?? 0;
          configController.value = site.config;
        }
        return null;
      }, [siteAsync]);

      // Handle loading and error states for editing using AsyncValue
      return siteAsync.when(
        data: (_) => _buildForm(
          formKey,
          slugController,
          nameController,
          descriptionController,
          modeController,
          configController,
          saveSite,
          deleteSite,
          editingSiteSlug,
        ),
        loading: () => SheetScaffold(
          titleText: 'editPublicationSite'.tr(),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => SheetScaffold(
          titleText: 'editPublicationSite'.tr(),
          child: ResponseErrorWidget(
            error: error.toString(),
            onRetry: () {
              ref.invalidate(
                publicationSiteDetailProvider(pubName, editingSiteSlug),
              );
            },
          ),
        ),
      );
    }

    // For new sites, directly show the form

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
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: modeController.value,
          decoration: const InputDecoration(
            labelText: 'Mode',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          items: [
            DropdownMenuItem(
              value: 0,
              child: Text('siteModeFullyManaged'.tr()),
            ),
            DropdownMenuItem(value: 1, child: Text('siteModeSelfManaged'.tr())),
          ],
          onChanged: (value) {
            if (value != null) {
              modeController.value = value;
            }
          },
        ),
        const SizedBox(height: 16),
        SiteConfigForm(
          initialConfig: configController.value,
          onChanged: (value) => configController.value = value,
        ),
      ],
    ).padding(all: 20);

    final saveButton = TextButton.icon(
      onPressed: isLoading.value ? null : saveSite,
      icon: const Icon(Symbols.save),
      label: Text('saveChanges').tr(),
    ).padding(horizontal: 20, vertical: 12);

    return SheetScaffold(
      titleText: siteSlug == null
          ? 'newPublicationSite'.tr()
          : 'editPublicationSite'.tr(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Form(key: formKey, child: formFields),
            Row(
              children: [
                if (siteSlug != null) ...[
                  TextButton.icon(
                    onPressed: isLoading.value ? null : deleteSite,
                    icon: const Icon(Symbols.delete_forever),
                    label: Text('deletePublicationSite'.tr()),
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
