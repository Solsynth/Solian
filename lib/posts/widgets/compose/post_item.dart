import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/translate.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/discovery/widgets/discovery_feedback_widget.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/route.gr.dart';
import 'package:island/posts/compose.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/posts/widgets/compose/embed_view_renderer.dart';
import 'package:island/posts/widgets/compose/post_award_sheet.dart';
import 'package:island/posts/widgets/compose/post_pin_sheet.dart';
import 'package:island/posts/widgets/compose/post_reaction_sheet.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PostActionableItem extends HookConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isEmbedReply;
  final bool isEmbedOpenable;
  final bool isCompact;
  final bool hideAttachments;
  final bool showFeedback;
  final double? borderRadius;
  final VoidCallback? onRefresh;
  final Function(SnPost)? onUpdate;
  final VoidCallback? onOpen;
  const PostActionableItem({
    super.key,
    required this.item,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = true,
    this.isEmbedReply = true,
    this.isEmbedOpenable = false,
    this.isCompact = false,
    this.hideAttachments = false,
    this.showFeedback = false,
    this.borderRadius,
    this.onRefresh,
    this.onUpdate,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final isAuthor = useMemoized(
      () => user.value != null && item.publisher?.accountId == user.value?.id,
      [user],
    );

    final config = ref.watch(appSettingsProvider);

    final widgetItem = InkWell(
      borderRadius: borderRadius != null
          ? BorderRadius.all(Radius.circular(borderRadius!))
          : null,
      child: PostItem(
        key: key,
        item: item,
        padding: padding,
        isFullPost: isFullPost,
        isShowReference: isShowReference,
        isEmbedReply: isEmbedReply,
        isEmbedOpenable: isEmbedOpenable,
        isTextSelectable: false,
        isCompact: isCompact,
        hideAttachments: hideAttachments,
        onRefresh: onRefresh,
        onUpdate: onUpdate,
        onOpen: onOpen,
      ),
      onTap: () {
        onOpen?.call();
        context.router.push(PostDetailRoute(id: item.id));
      },
    );

    return ContextMenuWidget(
      menuProvider: (_) {
        return Menu(
          children: [
            if (isAuthor)
              MenuAction(
                title: 'edit'.tr(),
                image: MenuImage.icon(Symbols.edit),
                callback: () async {
                  final result = await PostComposeDialog.show(
                    context,
                    originalPost: item,
                  );
                  if (result != null) {
                    onRefresh?.call();
                  }
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
                    isDanger: true,
                  ).then((confirm) {
                    if (confirm) {
                      final client = ref.watch(apiClientProvider);
                      client
                          .delete('/sphere/posts/${item.id}')
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
                  ClipboardData(text: 'https://solian.app/posts/${item.id}'),
                );
              },
            ),
            MenuAction(
              title: 'reply'.tr(),
              image: MenuImage.icon(Symbols.reply),
              callback: () async {
                final result = await PostComposeDialog.show(
                  context,
                  initialState: PostComposeInitialState(replyingTo: item),
                );
                if (result != null) {
                  onRefresh?.call();
                }
              },
            ),
            MenuAction(
              title: 'forward'.tr(),
              image: MenuImage.icon(Symbols.forward),
              callback: () async {
                final result = await PostComposeDialog.show(
                  context,
                  initialState: PostComposeInitialState(forwardingTo: item),
                );
                if (result != null) {
                  onRefresh?.call();
                }
              },
            ),
            if (isAuthor && item.pinMode == null)
              MenuAction(
                title: 'pinPost'.tr(),
                image: MenuImage.icon(Symbols.keep),
                callback: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => PostPinSheet(post: item),
                  ).then((value) {
                    if (value is int) {
                      onUpdate?.call(item.copyWith(pinMode: value));
                    }
                  });
                },
              )
            else if (isAuthor && item.pinMode != null)
              MenuAction(
                title: 'unpinPost'.tr(),
                image: MenuImage.icon(Symbols.keep_off),
                callback: () {
                  showConfirmAlert('unpinPostHint'.tr(), 'unpinPost'.tr()).then(
                    (confirm) async {
                      if (confirm) {
                        final client = ref.watch(apiClientProvider);
                        try {
                          if (context.mounted) showLoadingModal(context);
                          await client.delete('/sphere/posts/${item.id}/pin');
                          onUpdate?.call(item.copyWith(pinMode: null));
                        } catch (err) {
                          showErrorAlert(err);
                        } finally {
                          if (context.mounted) hideLoadingModal(context);
                        }
                      }
                    },
                  );
                },
              ),
            MenuAction(
              title: 'award'.tr(),
              image: MenuImage.icon(Symbols.star),
              callback: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => PostAwardSheet(post: item),
                );
              },
            ),
            MenuSeparator(),
            MenuAction(
              title: 'share'.tr(),
              image: MenuImage.icon(Symbols.share),
              callback: () {
                showShareSheetLink(
                  context: context,
                  link: 'https://solian.app/posts/${item.id}',
                  title: 'sharePost'.tr(),
                  toSystem: true,
                );
              },
            ),
            if (!kIsWeb)
              MenuAction(
                title: 'sharePostPhoto'.tr(),
                image: MenuImage.icon(Symbols.share_reviews),
                callback: () {
                  sharePostAsScreenshot(context, ref, item);
                },
              ),
            MenuSeparator(),
            MenuAction(
              title: 'abuseReport'.tr(),
              image: MenuImage.icon(Symbols.flag),
              callback: () {
                showAbuseReportSheet(
                  context,
                  resourceIdentifier: 'post:${item.id}',
                );
              },
            ),
          ],
        );
      },
      child: Material(
        color: config.cardTransparency < 1
            ? Colors.transparent
            : Theme.of(context).cardTheme.color,
        borderRadius: borderRadius != null
            ? BorderRadius.all(Radius.circular(borderRadius!))
            : null,
        child: showFeedback
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetItem,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Row(
                      spacing: 8,
                      children: [
                        const Icon(Symbols.mindfulness, size: 20).opacity(0.75),
                        Expanded(
                          child: Text(
                            "Are we recommending the content you like?",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).tr().fontSize(13).opacity(0.75),
                        ),
                        DiscoveryFeedbackWidget(
                          kind: 'post',
                          referenceId: item.id,
                          showNotInterested: true,
                          showBackground: false,
                        ),
                      ],
                    ),
                  ).clipRRect(bottomLeft: 8, bottomRight: 8),
                ],
              )
            : widgetItem,
      ),
    );
  }
}

class PostItem extends HookConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isEmbedReply;
  final bool isEmbedOpenable;
  final bool isTextSelectable;
  final bool isTranslatable;
  final bool isCompact;
  final bool hideAttachments;
  final double? textScale;
  final VoidCallback? onRefresh;
  final Function(SnPost)? onUpdate;
  final VoidCallback? onOpen;
  const PostItem({
    super.key,
    required this.item,
    this.padding,
    this.isFullPost = false,
    this.isShowReference = true,
    this.isEmbedReply = true,
    this.isEmbedOpenable = false,
    this.isTextSelectable = true,
    this.isTranslatable = true,
    this.isCompact = false,
    this.hideAttachments = false,
    this.textScale,
    this.onRefresh,
    this.onUpdate,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    final postLanguage = item.content != null && isTranslatable
        ? ref.watch(detectStringLanguageProvider(item.content!))
        : null;

    final currentLanguage = isTranslatable ? context.locale.toString() : null;
    final translatableLanguage = postLanguage != null && isTranslatable
        ? postLanguage.substring(0, 2) != currentLanguage!.substring(0, 2)
        : false;

    final translating = useState(false);
    final translatedText = useState<String?>(null);

    Future<void> translate() async {
      if (!isTranslatable) return;
      if (translatedText.value != null) {
        translatedText.value = null;
        return;
      }

      if (translating.value) return;
      if (item.content == null) return;
      translating.value = true;
      try {
        final text = await ref.watch(
          translateStringProvider(
            TranslateQuery(
              text: item.content!,
              lang: currentLanguage!.substring(0, 2),
            ),
          ).future,
        );
        translatedText.value = text;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        translating.value = false;
      }
    }

    final translatedWidget = (translatedText.value?.isNotEmpty ?? false)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: Divider()),
                  const Gap(8),
                  const Text('translated').tr().fontSize(11).opacity(0.75),
                ],
              ),
              MarkdownTextContent(
                textStyle: TextStyle(
                  fontSize:
                      Theme.of(context).textTheme.bodyMedium!.fontSize! *
                      (textScale ?? 1),
                ),
                content: translatedText.value!,
                isSelectable: isTextSelectable,
                attachments: item.attachments,
                noMentionChip: item.fediverseUri != null,
              ),
            ],
          )
        : null;

    final translatableWidget = (isTranslatable && translatableLanguage)
        ? Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: translating.value ? null : translate,
              style: ButtonStyle(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 2),
                ),
                visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                foregroundColor: WidgetStatePropertyAll(
                  translatedText.value == null ? null : Colors.grey,
                ),
              ),
              icon: const Icon(Symbols.translate),
              label: translatedText.value != null
                  ? const Text('translated').tr()
                  : translating.value
                  ? const Text('translating').tr()
                  : const Text('translate').tr(),
            ),
          )
        : null;

    final translationSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [?translatedWidget, ?translatableWidget],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isShowReference ||
            !(item.forwardedGone ||
                item.repliedGone ||
                item.forwardedPost != null ||
                item.repliedPost != null))
          Gap(renderingPadding.vertical),
        if (isShowReference)
          ReferencedPostWidget(item: item, renderingPadding: renderingPadding),
        PostHeader(
          item: item,
          isFullPost: isFullPost,
          isCompact: isCompact,
          renderingPadding: renderingPadding,
          showUpperLine:
              isShowReference &&
              (item.repliedPost != null || item.forwardedPost != null),
        ),
        PostBody(
          item: item,
          textScale: textScale,
          isFullPost: isFullPost,
          isTextSelectable: isTextSelectable,
          translationSection: translationSection,
          renderingPadding: renderingPadding,
          hideAttachments: hideAttachments,
        ),
        if (item.embedView != null)
          EmbedViewRenderer(
            embedView: item.embedView!,
            maxHeight: 400,
            borderRadius: BorderRadius.circular(12),
          ).padding(horizontal: renderingPadding.horizontal, vertical: 8),
        PostReactionList(
          padding: EdgeInsets.only(
            left: renderingPadding.horizontal,
            right: renderingPadding.horizontal,
            top: 8,
          ),
          parentId: item.id,
          reactions: item.reactionsCount,
          reactionsMade: item.reactionsMade,
          onReact: (symbol, attitude, delta) {
            final reactionsCount = Map<String, int>.from(item.reactionsCount);
            reactionsCount[symbol] = (reactionsCount[symbol] ?? 0) + delta;
            final reactionsMade = Map<String, bool>.from(item.reactionsMade);
            reactionsMade[symbol] = delta == 1 ? true : false;
            onUpdate?.call(
              item.copyWith(
                reactionsCount: reactionsCount,
                reactionsMade: reactionsMade,
              ),
            );
          },
        ),
        if (item.repliesCount > 0 && isEmbedReply)
          PostReplyPreview(
            parent: item,
            isOpenable: isEmbedOpenable,
            onOpen: onOpen,
          ).padding(horizontal: renderingPadding.horizontal, top: 8),
        Gap(renderingPadding.vertical),
      ],
    );
  }
}

class PostReactionList extends HookConsumerWidget {
  final String parentId;
  final Map<String, int> reactions;
  final Map<String, bool> reactionsMade;
  final Function(String symbol, int attitude, int delta)? onReact;
  final EdgeInsets? padding;
  const PostReactionList({
    super.key,
    required this.parentId,
    required this.reactions,
    required this.reactionsMade,
    this.padding,
    this.onReact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = useState(false);

    Future<void> reactPost(String symbol, int attitude) async {
      final client = ref.watch(apiClientProvider);
      submitting.value = true;
      await client
          .post(
            '/sphere/posts/$parentId/reactions',
            data: {'symbol': symbol, 'attitude': attitude},
          )
          .catchError((err) {
            showErrorAlert(err);
            return err;
          })
          .then((resp) {
            var isRemoving = resp.statusCode == 204;
            onReact?.call(symbol, attitude, isRemoving ? -1 : 1);
            HapticFeedback.heavyImpact();
          });
      submitting.value = false;
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding ?? EdgeInsets.zero,
        children: [
          if (onReact != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Symbols.add_reaction),
                label: const Text('react').tr(),
                visualDensity: const VisualDensity(
                  horizontal: VisualDensity.minimumDensity,
                  vertical: VisualDensity.minimumDensity,
                ),
                onPressed: submitting.value
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return PostReactionSheet(
                              reactionsCount: reactions,
                              reactionsMade: reactionsMade,
                              onReact: (symbol, attitude) {
                                reactPost(symbol, attitude);
                              },
                              postId: parentId,
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
                avatar: buildReactionIcon(symbol, 24),
                label: Row(
                  spacing: 4,
                  children: [
                    Text(ReactInfo.getTranslationKey(symbol)).tr(),
                    Text('x${reactions[symbol]}').bold(),
                  ],
                ),
                backgroundColor: (reactionsMade[symbol] ?? false)
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : null,
                onPressed: submitting.value
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
