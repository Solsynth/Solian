import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/webfeed.dart';
import 'package:island/pods/webfeed.dart';
import 'package:island/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class WebFeedNewScreen extends StatelessWidget {
  final String pubName;
  const WebFeedNewScreen({super.key, required this.pubName});

  @override
  Widget build(BuildContext context) {
    return WebFeedEditScreen(pubName: pubName, feedId: null);
  }
}

class WebFeedEditScreen extends HookConsumerWidget {
  final String pubName;
  final String? feedId;

  const WebFeedEditScreen({super.key, required this.pubName, this.feedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final titleController = useTextEditingController();
    final urlController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final isLoading = useState(false);
    final isScrapEnabled = useState(false);

    final saveFeed = useCallback(() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        final feed = WebFeed(
          id: feedId ?? '',
          title: titleController.text,
          url: urlController.text,
          description: descriptionController.text,
          config: WebFeedConfig(scrapPage: isScrapEnabled.value),
          publisherId: pubName,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          deletedAt: null,
        );

        await ref
            .read(
              webFeedNotifierProvider((
                pubName: pubName,
                feedId: feedId,
              )).notifier,
            )
            .saveFeed(feed);

        // Refresh the feed list
        ref.invalidate(webFeedListProvider(pubName));

        if (context.mounted) {
          showSnackBar('Web feed saved successfully');
          context.pop();
        }
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isLoading.value = false;
      }
    }, [pubName, feedId, isScrapEnabled.value, context]);

    final deleteFeed = useCallback(() async {
      final confirmed = await showConfirmAlert(
        'Are you sure you want to delete this web feed? This action cannot be undone.',
        'Delete Web Feed',
      );
      if (confirmed != true) return;

      isLoading.value = true;

      try {
        await ref
            .read(
              webFeedNotifierProvider((
                pubName: pubName,
                feedId: feedId!,
              )).notifier,
            )
            .deleteFeed();

        ref.invalidate(webFeedListProvider(pubName));

        if (context.mounted) {
          showSnackBar('Web feed deleted successfully');
          context.pop();
        }
      } catch (e) {
        showErrorAlert(e);
      } finally {
        isLoading.value = false;
      }
    }, [pubName, feedId, context, ref]);

    final feedAsync = ref.watch(
      webFeedNotifierProvider((pubName: pubName, feedId: feedId)),
    );

    return feedAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: $error')),
          ),
      data: (feed) {
        // Initialize form fields if they're empty and we have a feed
        if (titleController.text.isEmpty) {
          titleController.text = feed.title;
          urlController.text = feed.url;
          descriptionController.text = feed.description ?? '';
          isScrapEnabled.value = feed.config.scrapPage;
        }

        return _buildForm(
          context,
          formKey: formKey,
          titleController: titleController,
          urlController: urlController,
          descriptionController: descriptionController,
          isScrapEnabled: isScrapEnabled.value,
          onScrapEnabledChanged: (value) => isScrapEnabled.value = value,
          onSave: saveFeed,
          onDelete: deleteFeed,
          isLoading: isLoading.value,
          ref: ref,
          hasFeedId: feedId != null,
        );
      },
    );
  }

  Widget _buildForm(
    BuildContext context, {
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
    required TextEditingController titleController,
    required TextEditingController urlController,
    required TextEditingController descriptionController,
    required bool isScrapEnabled,
    required ValueChanged<bool> onScrapEnabledChanged,
    required VoidCallback onSave,
    required VoidCallback onDelete,
    required bool isLoading,
    required bool hasFeedId,
  }) {
    final scrapNow = useCallback(() async {
      showLoadingModal(context);
      try {
        await ref
            .read(
              webFeedNotifierProvider((
                pubName: pubName,
                feedId: feedId!,
              )).notifier,
            )
            .scrapFeed();

        if (context.mounted) {
          showSnackBar('Feed scraping successfully.');
        }
      } catch (e) {
        showErrorAlert(e);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }, [pubName, feedId, ref, context]);

    return Scaffold(
      appBar: AppBar(
        title: Text(hasFeedId ? 'Edit Web Feed' : 'New Web Feed'),
        actions: [
          if (hasFeedId)
            IconButton(
              icon: const Icon(Symbols.delete_forever),
              onPressed: isLoading ? null : onDelete,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://example.com/feed',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a URL';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasAbsolutePath) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
                onTapOutside:
                    (_) => FocusManager.instance.primaryFocus?.unfocus(),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Scrape web page for content'),
                      subtitle: const Text(
                        'When enabled, the system will attempt to extract full content from the web page',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      value: isScrapEnabled,
                      onChanged: onScrapEnabledChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (hasFeedId) ...[
                FilledButton.tonalIcon(
                  onPressed: isLoading ? null : scrapNow,
                  icon: const Icon(Symbols.refresh),
                  label: const Text('Scrape Now'),
                ).alignment(Alignment.centerRight),
                const SizedBox(height: 16),
              ],
              FilledButton.icon(
                onPressed: isLoading ? null : onSave,
                icon: const Icon(Symbols.save),
                label: Text('saveChanges').tr(),
              ).alignment(Alignment.centerRight),
            ],
          ).padding(all: 20),
        ),
      ),
    );
  }
}
