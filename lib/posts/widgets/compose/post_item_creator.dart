import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/posts/screens/compose_blog.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PostItemCreator extends HookConsumerWidget {
  final Color? backgroundColor;
  final SnPost item;
  final EdgeInsets? padding;
  final bool isOpenable;
  final Function? onRefresh;
  final Function(SnPost)? onUpdate;
  final VoidCallback? onTap;
  final void Function(String)? onPostTap;

  const PostItemCreator({
    super.key,
    required this.item,
    this.backgroundColor,
    this.padding,
    this.isOpenable = true,
    this.onRefresh,
    this.onUpdate,
    this.onTap,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    return ContextMenuWidget(
      previewBuilder: contextMenuPreviewBuilder,
      menuProvider: (_) {
        return Menu(
          children: [
            MenuAction(
              title: 'edit'.tr(),
              image: MenuImage.icon(Symbols.edit),
              callback: () {
                if (item.type == 1) {
                  context.router.push(ArticleEditRoute(id: item.id)).then((
                    value,
                  ) {
                    if (value != null) {
                      onRefresh?.call();
                    }
                  });
                } else if (item.type == 2) {
                  BlogComposeDialog.show(context, originalPost: item).then((
                    value,
                  ) {
                    if (value != null) {
                      onRefresh?.call();
                    }
                  });
                } else {
                  PostComposeDialog.show(context, originalPost: item).then((
                    value,
                  ) {
                    if (value == true) {
                      onRefresh?.call();
                    }
                  });
                }
              },
            ),
            MenuAction(
              title: 'delete'.tr(),
              image: MenuImage.icon(Symbols.delete),
              callback: () {
                showConfirmAlert(
                  'deletePostHint'.tr(),
                  'deletePost'.tr(),
                  isDanger: true,
                ).then((confirm) {
                  if (confirm) {
                    final client = ref.watch(solarNetworkClientProvider);
                    client.sphere
                        .deletePost(item.id)
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
            MenuSeparator(),
            MenuAction(
              title: 'copyLink'.tr(),
              image: MenuImage.icon(Symbols.link),
              callback: () {
                Clipboard.setData(
                  ClipboardData(text: 'https://solian.app/posts/${item.id}'),
                );
              },
            ),
          ],
        );
      },
      child: Material(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (onTap != null) {
              onTap!();
              return;
            }
            if (isOpenable) {
              context.router.push(PostDetailRoute(id: item.id));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReferencedPostWidget(
                item: item,
                renderingPadding: renderingPadding,
                onPostTap: onPostTap,
              ),
              PostHeader(item: item, renderingPadding: renderingPadding),
              PostBody(item: item, renderingPadding: renderingPadding),
              const Gap(16),
              _buildAnalyticsSection(
                context,
              ).padding(horizontal: renderingPadding.horizontal),
              Gap(renderingPadding.vertical),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analytics', style: Theme.of(context).textTheme.titleSmall),
        const Gap(8),
        Card(
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  context,
                  Symbols.visibility,
                  'Views',
                  '${item.viewsUnique} / ${item.viewsTotal}',
                  'Unique / Total',
                ),
                _buildMetricItem(
                  context,
                  Symbols.thumb_up,
                  'Upvotes',
                  '${item.upvotes}',
                  null,
                ),
                _buildMetricItem(
                  context,
                  Symbols.thumb_down,
                  'Downvotes',
                  '${item.downvotes}',
                  null,
                ),
              ],
            ),
          ),
        ),
        const Gap(16),
        if (item.reactionsCount.isNotEmpty) _buildReactionsSection(context),
        if (item.meta != null && item.meta!.isNotEmpty)
          _buildMetadataSection(context),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Created: ${item.createdAt?.formatSystem() ?? ''}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            if (item.editedAt != null)
              Text(
                'Edited: ${item.editedAt!.formatSystem()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    String? subtitle,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const Gap(4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
      ],
    );
  }

  Widget _buildReactionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'reactions'.plural(
            item.reactionsCount.isNotEmpty
                ? item.reactionsCount.values.reduce((a, b) => a + b)
                : 0,
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const Gap(8),
        PostReactionList(
          item: item,
          reactions: item.reactionsCount,
          reactionsMade: item.reactionsMade,
          padding: EdgeInsets.zero,
        ),
        const Gap(16),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(16),
        Text('Metadata', style: Theme.of(context).textTheme.titleSmall),
        const Gap(8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in item.meta!.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${entry.value}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
