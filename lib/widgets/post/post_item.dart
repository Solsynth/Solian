import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_file_collection.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';

class PostItem extends HookConsumerWidget {
  final Color? backgroundColor;
  final SnPost item;
  final EdgeInsets? padding;
  final bool isOpenable;
  final Function? onRefresh;
  final Function(SnPost)? onUpdate;
  const PostItem({
    super.key,
    required this.item,
    this.backgroundColor,
    this.padding,
    this.isOpenable = true,
    this.onRefresh,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? EdgeInsets.symmetric(horizontal: 12, vertical: 16);

    final user = ref.watch(userInfoProvider);
    final isAuthor = useMemoized(
      () => user.hasValue && user.value?.id == item.publisher.accountId,
      [user],
    );

    return ContextMenuWidget(
      menuProvider: (_) {
        return Menu(
          children: [
            if (isAuthor)
              MenuAction(
                title: 'edit'.tr(),
                image: MenuImage.icon(Symbols.edit),
                callback: () {
                  context.router.push(PostEditRoute(id: item.id)).then((value) {
                    if (value != null) {
                      onRefresh?.call();
                    }
                  });
                },
              ),
            if (isAuthor)
              MenuAction(
                title: 'delete'.tr(),
                image: MenuImage.icon(Symbols.delete),
                callback: () {
                  showConfirmAlert(
                    'deletePostHint'.tr(),
                    'deletePost'.tr(),
                  ).then((confirm) {
                    if (confirm) {
                      final client = ref.watch(apiClientProvider);
                      client
                          .delete('/posts/${item.id}')
                          .catchError((err) {
                            showErrorAlert(err);
                            return err;
                          })
                          .then((_) {
                            onRefresh?.call();
                          });
                    }
                  });
                },
              ),
            if (isAuthor) MenuSeparator(),
            MenuAction(
              title: 'copyLink'.tr(),
              image: MenuImage.icon(Symbols.link),
              callback: () {
                Clipboard.setData(
                  ClipboardData(text: 'https://solsynth.dev/posts/${item.id}'),
                );
              },
            ),
          ],
        );
      },
      child: Material(
        color: backgroundColor,
        child: Padding(
          padding: renderingPadding,
          child: Column(
            spacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  GestureDetector(
                    child: ProfilePictureWidget(
                      fileId: item.publisher.pictureId,
                    ),
                    onTap: () {
                      context.router.push(
                        PublisherProfileRoute(name: item.publisher.name),
                      );
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.publisher.nick).bold(),
                          if (item.content?.isNotEmpty ?? false)
                            MarkdownTextContent(content: item.content!),
                        ],
                      ),
                      onTap: () {
                        if (isOpenable) {
                          context.router.push(PostDetailRoute(id: item.id));
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (item.attachments.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(left: 48),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: CloudFileList(files: item.attachments),
                ),
              PostReactionList(
                parentId: item.id,
                reactions: item.reactionsCount,
                padding: EdgeInsets.only(left: 48),
                onReact: (symbol, attitude, delta) {
                  final reactionsCount = Map<String, int>.from(
                    item.reactionsCount,
                  );
                  reactionsCount[symbol] =
                      (reactionsCount[symbol] ?? 0) + delta;
                  onUpdate?.call(item.copyWith(reactionsCount: reactionsCount));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostReactionList extends HookConsumerWidget {
  final String parentId;
  final Map<String, int> reactions;
  final Function(String symbol, int attitude, int delta) onReact;
  final EdgeInsets? padding;
  const PostReactionList({
    super.key,
    required this.parentId,
    required this.reactions,
    this.padding,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = useState(false);

    Future<void> reactPost(String symbol, int attitude) async {
      final client = ref.watch(apiClientProvider);
      submitting.value = true;
      await client
          .post(
            '/posts/$parentId/reactions',
            data: {'symbol': symbol, 'attitude': attitude},
          )
          .catchError((err) {
            showErrorAlert(err);
            return err;
          })
          .then((resp) {
            var isRemoving = resp.statusCode == 204;
            onReact(symbol, attitude, isRemoving ? -1 : 1);
            HapticFeedback.heavyImpact();
          });
      submitting.value = false;
    }

    return SizedBox(
      height: 28,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding ?? EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(Symbols.add_reaction),
              label: Text('react').tr(),
              visualDensity: const VisualDensity(
                horizontal: VisualDensity.minimumDensity,
                vertical: VisualDensity.minimumDensity,
              ),
              onPressed:
                  submitting.value
                      ? null
                      : () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return _PostReactionSheet(
                              reactionsCount: reactions,
                              onReact: (symbol, attitude) {
                                reactPost(symbol, attitude);
                              },
                            );
                          },
                        );
                      },
            ),
          ),
          for (final symbol in reactions.keys)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: Text(kReactionTemplates[symbol]?.icon ?? '?'),
                label: Row(
                  spacing: 4,
                  children: [
                    Text(symbol),
                    Text('x${reactions[symbol]}').bold(),
                  ],
                ),
                onPressed:
                    submitting.value
                        ? null
                        : () {
                          reactPost(
                            symbol,
                            kReactionTemplates[symbol]?.attitude ?? 0,
                          );
                        },
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PostReactionSheet extends StatelessWidget {
  final Map<String, int> reactionsCount;
  final Function(String symbol, int attitude) onReact;
  const _PostReactionSheet({
    required this.reactionsCount,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 12),
          child: Row(
            children: [
              Text(
                'reactions'.plural(
                  reactionsCount.isNotEmpty
                      ? reactionsCount.values.reduce((a, b) => a + b)
                      : 0,
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),

              IconButton(
                icon: const Icon(Symbols.close),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              _buildReactionSection(context, 'Positive Reactions', 0),
              _buildReactionSection(context, 'Neutral Reactions', 1),
              _buildReactionSection(context, 'Negative Reactions', 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionSection(
    BuildContext context,
    String title,
    int attitude,
  ) {
    final allReactions =
        kReactionTemplates.entries
            .where((entry) => entry.value.attitude == attitude)
            .map((entry) => entry.key)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title).fontSize(20).bold().padding(horizontal: 20, vertical: 12),
        SizedBox(
          height: 84,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: 100,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 2.0,
            ),
            itemCount: allReactions.length,
            itemBuilder: (context, index) {
              final symbol = allReactions[index];
              final count = reactionsCount[symbol] ?? 0;
              return InkWell(
                onTap: () {
                  onReact(symbol, attitude);
                  Navigator.pop(context);
                },
                child: GridTile(
                  header: Text(
                    kReactionTemplates[symbol]?.icon ?? '',
                    textAlign: TextAlign.center,
                  ).fontSize(24),
                  footer: Text(
                    count > 0 ? 'x$count' : '',
                    textAlign: TextAlign.center,
                  ).bold().padding(bottom: 12),
                  child: Center(
                    child: Text(symbol, textAlign: TextAlign.center),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
