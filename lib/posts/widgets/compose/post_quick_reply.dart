import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/me/account_settings.dart'
    as account_settings;
import 'package:island/accounts/account_pod.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/compose.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/posts/widgets/compose/publishers_modal.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PostQuickReply extends HookConsumerWidget {
  final SnPost parent;
  final VoidCallback? onPosted;
  final VoidCallback? onLaunch;
  const PostQuickReply({
    super.key,
    required this.parent,
    this.onPosted,
    this.onLaunch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishers = ref.watch(publishersManagedProvider);
    final publishingSettings = ref.watch(
      account_settings.publishingSettingsProvider,
    );

    final currentPublisher = useState<SnPublisher?>(null);

    final user = ref.watch(userInfoProvider);
    // Chaining only makes sense on the user's own posts: the server rejects
    // chaining to another publisher's post (POST_CHAIN_DIFFERENT_PUBLISHER).
    final isOwnPost =
        user.value != null &&
        (parent.publisher?.accountId == user.value?.id ||
            publishers.value?.any((p) => p.id == parent.publisher?.id) == true);

    final chainMode = useState(false);
    // Recycle safety: a reused widget must not leak the previous parent's
    // chain mode.
    useEffect(() {
      chainMode.value = false;
      return null;
    }, [parent.id]);

    void enableChainMode() {
      chainMode.value = true;
      // A chain child must share the head's publisher; prefer it when the
      // user still manages it.
      final parentPublisher = parent.publisher;
      if (parentPublisher != null &&
          (publishers.value?.any((p) => p.id == parentPublisher.id) ?? false)) {
        currentPublisher.value = parentPublisher;
      }
    }

    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        if (currentPublisher.value == null) {
          // Try to find default reply publisher from settings
          SnPublisher? defaultPublisher;
          if (publishingSettings.hasValue) {
            final defaultId = publishingSettings.value!.defaultReplyPublisherId;
            if (defaultId != null) {
              defaultPublisher = publishers.value!
                  .where((p) => p.id == defaultId)
                  .firstOrNull;
            }
          }
          // Fall back to first publisher if no default found
          currentPublisher.value = defaultPublisher ?? publishers.value!.first;
        }
      }
      return null;
    }, [publishers, publishingSettings]);

    final submitting = useState(false);

    final contentController = useTextEditingController();

    final hasContent = useState(false);
    useEffect(() {
      void updateHasContent() =>
          hasContent.value = contentController.text.isNotEmpty;
      updateHasContent();
      contentController.addListener(updateHasContent);
      return () => contentController.removeListener(updateHasContent);
    }, [contentController]);

    Future<void> performAction() async {
      if (!contentController.text.isNotEmpty) {
        return;
      }

      submitting.value = true;
      try {
        final client = ref.watch(solarNetworkClientProvider);
        // Use raw Dio call since we need to pass publisher name as query param
        await client.dio.post(
          '/sphere/posts',
          data: {
            'content': contentController.text,
            if (chainMode.value)
              'chained_post_id': parent.id
            else
              'replied_post_id': parent.id,
          },
          queryParameters: {'pub': currentPublisher.value?.name},
        );
        contentController.clear();
        onPosted?.call();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    const kInputChipHeight = 54.0;

    return publishers.when(
      data: (data) => Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: BoxConstraints(minHeight: kInputChipHeight),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwnPost && !chainMode.value && hasContent.value)
                _ChainSuggestionRow(onChain: enableChainMode),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: ProfilePictureWidget(
                      file: currentPublisher.value?.picture,
                      fallbackName: currentPublisher.value?.nick,
                      radius: (kInputChipHeight * 0.5) - 6,
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => PublisherModal(),
                      ).then((value) {
                        if (value is SnPublisher) {
                          currentPublisher.value = value;
                        }
                      });
                    },
                  ).padding(right: 12),
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        hintText: chainMode.value
                            ? 'postChainPlaceholder'.tr()
                            : 'postReplyPlaceholder'.tr(),
                        border: InputBorder.none,
                        isDense: true,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      style: TextStyle(fontSize: 14),
                      minLines: 1,
                      maxLines: 5,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                  const Gap(8),
                  if (isOwnPost)
                    IconButton(
                      onPressed: () {
                        if (chainMode.value) {
                          chainMode.value = false;
                        } else {
                          enableChainMode();
                        }
                      },
                      icon: const Icon(Symbols.link, size: 20),
                      color: chainMode.value
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      tooltip: 'chainPost'.tr(),
                      visualDensity: VisualDensity.compact,
                      constraints: BoxConstraints(
                        maxHeight: kInputChipHeight - 6,
                        minHeight: kInputChipHeight - 6,
                      ),
                    ),
                  IconButton(
                    onPressed: () async {
                      onLaunch?.call();
                      final value = await PostComposeDialog.show(
                        context,
                        initialState: PostComposeInitialState(
                          content: contentController.text,
                          replyingTo: chainMode.value ? null : parent,
                          chainingTo: chainMode.value ? parent : null,
                        ),
                      );
                      if (value != null) onPosted?.call();
                    },
                    icon: const Icon(Symbols.launch, size: 20),
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints(
                      maxHeight: kInputChipHeight - 6,
                      minHeight: kInputChipHeight - 6,
                    ),
                  ),
                  IconButton(
                    icon: submitting.value
                        ? SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : Icon(Symbols.send, size: 20),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: submitting.value ? null : performAction,
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints(
                      maxHeight: kInputChipHeight - 6,
                      minHeight: kInputChipHeight - 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

/// Nudges users replying to their own post toward a chain: a reply on your
/// own thread is usually a chain continuation instead.
class _ChainSuggestionRow extends StatelessWidget {
  final VoidCallback onChain;
  const _ChainSuggestionRow({required this.onChain});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8, right: 4),
      child: Row(
        children: [
          Icon(Symbols.link, size: 14, color: theme.colorScheme.primary),
          const Gap(6),
          Expanded(
            child: Text(
              'suggestChainInstead'.tr(),
              style: theme.textTheme.bodySmall,
            ),
          ),
          TextButton(
            onPressed: onChain,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              minimumSize: const Size(0, 28),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('chainPost'.tr()),
          ),
        ],
      ),
    );
  }
}
