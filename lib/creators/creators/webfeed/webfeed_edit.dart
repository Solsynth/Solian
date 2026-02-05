import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/discovery/discovery_models/webfeed.dart';
import 'package:island/discovery/webfeed.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class WebfeedForm extends HookConsumerWidget {
  final String pubName;
  final String? feedId;

  const WebfeedForm({super.key, required this.pubName, this.feedId});

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
        final feed = SnWebFeed(
          id: feedId ?? '',
          title: titleController.text,
          url: urlController.text,
          description: descriptionController.text,
          config: SnWebFeedConfig(scrapPage: isScrapEnabled.value),
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
        isDanger: true,
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ResponseErrorWidget(
        error: error,
        onRetry: () => ref.invalidate(
          webFeedNotifierProvider((pubName: pubName, feedId: feedId)),
        ),
      ),
      data: (feed) {
        // Initialize form fields if they're empty and we have a feed
        if (titleController.text.isEmpty) {
          titleController.text = feed.title;
          urlController.text = feed.url;
          descriptionController.text = feed.description ?? '';
          isScrapEnabled.value = feed.config.scrapPage;
        }

        final scrapNow = useCallback(() async {
          isLoading.value = true;
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
            if (context.mounted) isLoading.value = false;
          }
        }, [pubName, feedId, ref, context, isLoading]);

        final formFields = Column(
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com/feed',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
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
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
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
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
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
                    value: isScrapEnabled.value,
                    onChanged: (value) => isScrapEnabled.value = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (feedId != null) ...[
              TextButton.icon(
                onPressed: isLoading.value ? null : scrapNow,
                icon: const Icon(Symbols.refresh),
                label: const Text('Scrape Now'),
              ).alignment(Alignment.centerRight),
              const SizedBox(height: 16),
            ],
          ],
        ).padding(all: 20);

        final formWidget = Form(
          key: formKey,
          child: SingleChildScrollView(child: formFields),
        );

        final buttonsRow = Row(
          children: [
            if (feedId != null)
              TextButton.icon(
                onPressed: isLoading.value ? null : deleteFeed,
                icon: const Icon(Symbols.delete_forever),
                label: const Text('Delete Web Feed'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            const Spacer(),
            TextButton.icon(
              onPressed: isLoading.value ? null : saveFeed,
              icon: const Icon(Symbols.save),
              label: Text('saveChanges').tr(),
            ),
          ],
        ).padding(horizontal: 20, vertical: 12);

        return Column(
          children: [
            Expanded(child: formWidget),
            buttonsRow,
          ],
        );
      },
    );
  }
}
