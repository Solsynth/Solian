import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/creators/publishers_form.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/posts/posts_models/publisher.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/compose.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/posts/posts_widgets/post/publishers_modal.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/posts/posts_widgets/compose_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

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

    final currentPublisher = useState<SnPublisher?>(null);

    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        currentPublisher.value = publishers.value!.first;
      }
      return null;
    }, [publishers]);

    final submitting = useState(false);

    final contentController = useTextEditingController();

    Future<void> performAction() async {
      if (!contentController.text.isNotEmpty) {
        return;
      }

      submitting.value = true;
      try {
        final client = ref.watch(apiClientProvider);
        await client.post(
          '/sphere/posts',
          data: {
            'content': contentController.text,
            'replied_post_id': parent.id,
          },
          queryParameters: {'pub': currentPublisher.value?.name},
        );
        contentController.clear();
        onPosted?.call();
        eventBus.fire(PostCreatedEvent());
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
                    hintText: 'postReplyPlaceholder'.tr(),
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
              IconButton(
                onPressed: () async {
                  onLaunch?.call();
                  final value = await PostComposeSheet.show(
                    context,
                    initialState: PostComposeInitialState(
                      content: contentController.text,
                      replyingTo: parent,
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
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
