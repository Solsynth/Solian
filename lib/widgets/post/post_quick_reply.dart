import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/models/publisher.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/publishers.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/publishers_modal.dart';
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
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return publishers.when(
      data:
          (data) => Row(
            spacing: 8,
            children: [
              GestureDetector(
                child: ProfilePictureWidget(
                  fileId: currentPublisher.value?.picture?.id,
                  radius: 16,
                ),
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => PublisherModal(),
                  ).then((value) {
                    if (value is SnPublisher) currentPublisher.value = value;
                  });
                },
              ).padding(right: 4),
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
                      vertical: 8,
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  maxLines: null,
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
              IconButton(
                onPressed: () {
                  onLaunch?.call();
                  GoRouter.of(context)
                      .pushNamed(
                        'postCompose',
                        extra: PostComposeInitialState(
                          content: contentController.text,
                          replyingTo: parent,
                        ),
                      )
                      .then((value) {
                        if (value != null) onPosted?.call();
                      });
                },
                icon: const Icon(Symbols.launch, size: 20),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                icon:
                    submitting.value
                        ? SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        )
                        : Icon(Symbols.send, size: 20),
                color: Theme.of(context).colorScheme.primary,
                onPressed: submitting.value ? null : performAction,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
