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
    // The single action button *is* chain or reply, decided by ownership:
    // chaining to a post the user does not control is rejected by the server
    // (POST_CHAIN_DIFFERENT_PUBLISHER), so there is nothing to toggle.
    final isChain =
        user.value != null &&
        (parent.publisher?.accountId == user.value?.id ||
            publishers.value?.any((p) => p.id == parent.publisher?.id) == true);

    useEffect(() {
      final managed = publishers.value;
      if (managed == null || managed.isEmpty) return null;
      // A chain child must share the head's publisher; prefer it when the
      // user still manages it.
      final headPublisher = parent.publisher;
      if (isChain &&
          headPublisher != null &&
          managed.any((p) => p.id == headPublisher.id)) {
        currentPublisher.value = headPublisher;
        return null;
      }
      if (currentPublisher.value == null) {
        // Try to find default reply publisher from settings
        SnPublisher? defaultPublisher;
        if (publishingSettings.hasValue) {
          final defaultId = publishingSettings.value!.defaultReplyPublisherId;
          if (defaultId != null) {
            defaultPublisher = managed
                .where((p) => p.id == defaultId)
                .firstOrNull;
          }
        }
        // Fall back to first publisher if no default found
        currentPublisher.value = defaultPublisher ?? managed.first;
      }
      return null;
    }, [publishers, publishingSettings, isChain]);

    final submitting = useState(false);

    final contentController = useTextEditingController();

    Future<void> performAction() async {
      if (contentController.text.isEmpty) {
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
            if (isChain)
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
          child: Row(
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
                    hintText: isChain
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
              // One action button, typed by ownership: chain on the user's own
              // posts, reply everywhere else.
              IconButton(
                onPressed: () async {
                  onLaunch?.call();
                  final value = await PostComposeDialog.show(
                    context,
                    initialState: PostComposeInitialState(
                      content: contentController.text,
                      replyingTo: isChain ? null : parent,
                      chainingTo: isChain ? parent : null,
                    ),
                  );
                  if (value != null) onPosted?.call();
                },
                icon: Icon(isChain ? Symbols.link : Symbols.reply, size: 20),
                tooltip: isChain ? 'chainPost'.tr() : 'reply'.tr(),
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
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
