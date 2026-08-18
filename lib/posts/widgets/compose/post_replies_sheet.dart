import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/posts/widgets/compose/post_quick_reply.dart';
import 'package:island/posts/widgets/compose/post_replies.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PostRepliesSheet extends HookConsumerWidget {
  final SnPost post;

  /// When provided, this sheet is embedded inline (e.g. in a tunable sidebar
  /// panel) instead of shown as a modal: [onClose] dismisses it, opening a
  /// nested reply dismisses it, and the quick-reply launch keeps the panel
  /// open while the compose dialog opens on top.
  final VoidCallback? onClose;

  const PostRepliesSheet({super.key, required this.post, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final repliesKey = useState(0);
    final order = useState<String>('created_at');
    final orderDesc = useState<bool>(true);
    final query = postRepliesQuery(
      post.id.toString(),
      order: order.value,
      orderDesc: orderDesc.value,
    );

    return SheetScaffold(
      titleText: 'repliesCount'.plural(post.repliesCount),
      onClose: onClose,
      heightFactor: onClose != null ? 1 : 0.8,
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Sort replies',
          onSelected: (value) {
            if (value == 'toggle_direction') {
              orderDesc.value = !orderDesc.value;
            } else {
              order.value = value;
            }
            repliesKey.value++;
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'popularity',
              child: Row(
                spacing: 8,
                children: [
                  if (order.value == 'popularity')
                    Icon(
                      orderDesc.value
                          ? Symbols.arrow_downward
                          : Symbols.arrow_upward,
                      size: 18,
                    )
                  else
                    const SizedBox(width: 18),
                  const Text('Popularity'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'created_at',
              child: Row(
                spacing: 8,
                children: [
                  if (order.value == 'created_at')
                    Icon(
                      orderDesc.value
                          ? Symbols.arrow_downward
                          : Symbols.arrow_upward,
                      size: 18,
                    )
                  else
                    const SizedBox(width: 18),
                  const Text('Date'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'date',
              child: Row(
                spacing: 8,
                children: [
                  if (order.value == 'date')
                    Icon(
                      orderDesc.value
                          ? Symbols.arrow_downward
                          : Symbols.arrow_upward,
                      size: 18,
                    )
                  else
                    const SizedBox(width: 18),
                  const Text('Trending date'),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'toggle_direction',
              child: Row(
                spacing: 8,
                children: [
                  Icon(
                    orderDesc.value
                        ? Symbols.arrow_downward
                        : Symbols.arrow_upward,
                    size: 18,
                  ),
                  Text(orderDesc.value ? 'Newest first' : 'Oldest first'),
                ],
              ),
            ),
          ],
          icon: const Icon(Symbols.sort),
        ),
      ],
      child: Stack(
        children: [
          CustomScrollView(
            key: ValueKey('post-replies-sheet-${repliesKey.value}'),
            slivers: [
              PostRepliesList(
                postId: query.postId,
                order: query.order,
                orderDesc: query.orderDesc,
                onOpen: onClose ?? () {
                  Navigator.pop(context);
                },
              ),
              SliverGap(80),
            ],
          ),
          if (user.value != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child:
                  PostQuickReply(
                    parent: post,
                    onPosted: () {
                      repliesKey.value++;
                      ref.read(postRepliesProvider(query).notifier).refresh();
                    },
                    onLaunch: onClose != null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                  ).padding(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    top: 8,
                    horizontal: 16,
                  ),
            ),
        ],
      ),
    );
  }
}
