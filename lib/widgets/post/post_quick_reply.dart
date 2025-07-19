import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/models/publisher.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/publishers.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/post/publishers_modal.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class PostQuickReply extends HookConsumerWidget {
  final SnPost parent;
  final Function? onPosted;
  const PostQuickReply({super.key, required this.parent, this.onPosted});

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
          options: Options(headers: {'X-Pub': currentPublisher.value?.name}),
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
                    hintText: 'Post your reply',
                    border: const OutlineInputBorder(),
                    isDense: true,
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
              ),
            ],
          ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
