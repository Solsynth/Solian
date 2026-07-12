import 'package:auto_route/auto_route.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/core/network.dart';
import 'package:island/core/translate.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/posts/pods/bookmarks.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/discovery/discovery_feedback_service.dart';
import 'package:island/posts/widgets/compose/compose_dialog.dart';
import 'package:island/route.gr.dart';
import 'package:island/posts/compose.dart';
import 'package:island/core/utils/share_utils.dart';
import 'package:island/posts/widgets/compose/embed_view_renderer.dart';
import 'package:island/posts/widgets/compose/post_award_sheet.dart';
import 'package:island/posts/widgets/compose/post_collections_sheet.dart';
import 'package:island/posts/widgets/compose/post_pin_sheet.dart';
import 'package:island/posts/widgets/compose/post_reaction_sheet.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/sharing/share_sheet.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PostActionableItem extends HookConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isEmbedReply;
  final bool isEmbedOpenable;
  final bool isCompact;
  final bool hideAttachments;
  final double? borderRadius;
  final VoidCallback? onRefresh;
  final Function(SnPost)? onUpdate;
  final VoidCallback? onOpen;
  final VoidCallback? onTap;
  final void Function(String)? onPostTap;
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
    this.borderRadius,
    this.onRefresh,
    this.onUpdate,
    this.onOpen,
    this.onTap,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final publishersManaged = ref.watch(publishersManagedProvider);
    final isAuthor = useMemoized(
      () =>
          user.value != null &&
          (item.publisher?.accountId == user.value?.id ||
              publishersManaged.value?.any((p) => p.id == item.publisher?.id) ==
                  true),
      [user, publishersManaged],
    );

    void Function() getMenuAction(String action) {
      switch (action) {
        case 'edit':
          return () async {
            final result = await PostComposeDialog.show(
              context,
              originalPost: item,
            );
            if (result != null) {
              onRefresh?.call();
            }
          };
        case 'delete':
          return () {
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
          };
        case 'copyLink':
          return () {
            Clipboard.setData(
              ClipboardData(text: 'https://solian.app/posts/${item.id}'),
            );
          };
        case 'reply':
          return () async {
            if (item.fediverseUri != null) {
              final hasIdentity = ref.read(hasFediverseIdentityProvider);
              if (!hasIdentity) {
                await showFediverseInteractionHint(
                  context,
                  'fediverseInteractionHint',
                );
                return;
              }
            }
            final result = await PostComposeDialog.show(
              context,
              initialState: PostComposeInitialState(replyingTo: item),
            );
            if (result != null) {
              onRefresh?.call();
            }
          };
        case 'forward':
          return () async {
            if (item.fediverseUri != null) {
              final hasIdentity = ref.read(hasFediverseIdentityProvider);
              if (!hasIdentity) {
                await showFediverseInteractionHint(
                  context,
                  'fediverseInteractionHint',
                );
                return;
              }
            }
            final result = await PostComposeDialog.show(
              context,
              initialState: PostComposeInitialState(forwardingTo: item),
            );
            if (result != null) {
              onRefresh?.call();
            }
          };
        case 'pin':
          return () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => PostPinSheet(post: item),
            ).then((value) {
              if (value is int) {
                onUpdate?.call(item.copyWith(pinMode: value));
              }
            });
          };
        case 'unpin':
          return () {
            showConfirmAlert('unpinPostHint'.tr(), 'unpinPost'.tr()).then((
              confirm,
            ) async {
              if (confirm) {
                final client = ref.watch(solarNetworkClientProvider);
                try {
                  if (context.mounted) showLoadingModal(context);
                  await client.sphere.unpinPost(item.id);
                  onUpdate?.call(item.copyWith(pinMode: null));
                } catch (err) {
                  showErrorAlert(err);
                } finally {
                  if (context.mounted) hideLoadingModal(context);
                }
              }
            });
          };
        case 'award':
          return () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) => PostAwardSheet(post: item),
            );
          };
        case 'boost':
          return () async {
            if (item.fediverseUri != null) {
              final hasIdentity = ref.read(hasFediverseIdentityProvider);
              if (!hasIdentity) {
                await showFediverseInteractionHint(
                  context,
                  'fediverseInteractionHint',
                );
                return;
              }
            }
            final client = ref.read(solarNetworkClientProvider);
            try {
              if (context.mounted) showLoadingModal(context);
              await client.sphere.boostPost(item.id);
              onRefresh?.call();
            } catch (err) {
              showErrorAlert(err);
            } finally {
              if (context.mounted) hideLoadingModal(context);
            }
          };
        case 'share':
          return () {
            showShareSheetLink(
              context: context,
              link: 'https://solian.app/posts/${item.id}',
              title: 'sharePost'.tr(),
              toSystem: true,
            );
          };
        case 'sharePhoto':
          return () {
            sharePostAsScreenshot(context, ref, item);
          };
        case 'openBrowser':
          return () {
            launchUrlString(item.fediverseUri!);
          };
        case 'showMoreLikeThis':
          return () async {
            try {
              final service = ref.read(discoveryFeedbackServiceProvider);
              await service.submitFeedback(
                kind: DiscoveryFeedbackKind.post,
                referenceId: item.id,
                feedback: DiscoveryFeedbackValue.positive,
              );
              if (context.mounted) {
                showSnackBar('Thanks for your feedback!');
              }
            } catch (err) {
              showErrorAlert(err);
            }
          };
        case 'showLessLikeThis':
          return () async {
            try {
              final service = ref.read(discoveryFeedbackServiceProvider);
              await service.submitFeedback(
                kind: DiscoveryFeedbackKind.post,
                referenceId: item.id,
                feedback: DiscoveryFeedbackValue.negative,
              );
              if (context.mounted) {
                showSnackBar('Thanks for your feedback!');
              }
            } catch (err) {
              showErrorAlert(err);
            }
          };
        case 'notInterested':
          return () async {
            try {
              final service = ref.read(discoveryFeedbackServiceProvider);
              await service.markUninterested(
                kind: 'post',
                referenceId: item.id,
              );
              onRefresh?.call();
            } catch (err) {
              showErrorAlert(err);
            }
          };
        case 'report':
          return () {
            showAbuseReportSheet(
              context,
              resourceIdentifier: 'post:${item.id}',
            );
          };
        case 'collections':
          return () =>
              showPostCollectionsSheet(context, item, onChanged: onRefresh);
        case 'bookmark':
          return () async {
            try {
              await toggleBookmark(
                ref,
                postId: item.id,
                currentlyBookmarked: item.isBookmarked,
              );
              onUpdate?.call(item.copyWith(isBookmarked: !item.isBookmarked));
            } catch (err) {
              showErrorAlert(err);
            }
          };
        default:
          return () {};
      }
    }

    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    void showPostActionSheet() {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        builder: (context) => PostActionSheet(
          item: item,
          isAuthor: isAuthor,
          onAction: (action) {
            Navigator.pop(context);
            getMenuAction(action)();
          },
        ),
      );
    }

    final trailing = isMobile
        ? IconButton(
            icon: const Icon(Symbols.more_horiz),
            style: ButtonStyle(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
              minimumSize: const WidgetStatePropertyAll(Size(32, 32)),
            ),
            onPressed: showPostActionSheet,
          )
        : IconButton(
            icon: const Icon(Symbols.more_horiz),
            style: ButtonStyle(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
              minimumSize: const WidgetStatePropertyAll(Size(32, 32)),
            ),
            onPressed: showPostActionSheet,
          );

    final widgetItem = ContextMenuWidget(
      previewBuilder: contextMenuPreviewBuilder,
      menuProvider: (_) {
        return Menu(
          children: [
            if (isAuthor)
              MenuAction(
                title: 'edit'.tr(),
                image: MenuImage.icon(Symbols.edit),
                callback: () => getMenuAction('edit')(),
              ),
            if (isAuthor)
              MenuAction(
                title: 'delete'.tr(),
                image: MenuImage.icon(Symbols.delete),
                callback: () => getMenuAction('delete')(),
              ),
            MenuAction(
              title: 'copyLink'.tr(),
              image: MenuImage.icon(Symbols.link),
              callback: () => getMenuAction('copyLink')(),
            ),
            MenuAction(
              title: 'reply'.tr(),
              image: MenuImage.icon(Symbols.reply),
              callback: () => getMenuAction('reply')(),
            ),
            MenuAction(
              title: 'forward'.tr(),
              image: MenuImage.icon(Symbols.forward),
              callback: () => getMenuAction('forward')(),
            ),
            if (isAuthor && item.pinMode == null)
              MenuAction(
                title: 'pinPost'.tr(),
                image: MenuImage.icon(Symbols.keep),
                callback: () => getMenuAction('pin')(),
              ),
            if (isAuthor && item.pinMode != null)
              MenuAction(
                title: 'unpinPost'.tr(),
                image: MenuImage.icon(Symbols.keep_off),
                callback: () => getMenuAction('unpin')(),
              ),
            MenuAction(
              title: 'award'.tr(),
              image: MenuImage.icon(Symbols.star),
              callback: () => getMenuAction('award')(),
            ),
            MenuAction(
              title: 'boosts'.tr(),
              image: MenuImage.icon(Symbols.repeat),
              callback: () => getMenuAction('boost')(),
            ),
            MenuAction(
              title: item.isBookmarked ? 'unbookmark'.tr() : 'bookmark'.tr(),
              image: MenuImage.icon(
                item.isBookmarked ? Symbols.bookmark_added : Symbols.bookmark,
              ),
              callback: () => getMenuAction('bookmark')(),
            ),
            MenuAction(
              title: 'share'.tr(),
              image: MenuImage.icon(Symbols.share),
              callback: () => getMenuAction('share')(),
            ),
            if (isAuthor)
              MenuAction(
                title: 'collections'.tr(),
                image: MenuImage.icon(Symbols.collections),
                callback: () => getMenuAction('collections')(),
              ),
            if (!kIsWeb)
              MenuAction(
                title: 'sharePostPhoto'.tr(),
                image: MenuImage.icon(Symbols.share_reviews),
                callback: () => getMenuAction('sharePhoto')(),
              ),
            if (item.fediverseUri != null)
              MenuAction(
                title: 'openInBrowser'.tr(),
                image: MenuImage.icon(Symbols.open_in_new),
                callback: () => getMenuAction('openBrowser')(),
              ),
            MenuAction(
              title: 'showMoreLikeThis'.tr(),
              image: MenuImage.icon(Symbols.thumb_up),
              callback: () => getMenuAction('showMoreLikeThis')(),
            ),
            MenuAction(
              title: 'showLessLikeThis'.tr(),
              image: MenuImage.icon(Symbols.thumb_down),
              callback: () => getMenuAction('showLessLikeThis')(),
            ),
            MenuAction(
              title: 'notInterested'.tr(),
              image: MenuImage.icon(Symbols.hide_source),
              callback: () => getMenuAction('notInterested')(),
            ),
            MenuAction(
              title: 'abuseReport'.tr(),
              image: MenuImage.icon(Symbols.flag),
              callback: () => getMenuAction('report')(),
            ),
          ],
        );
      },
      child: InkWell(
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
          trailing: trailing,
          onPostTap: onPostTap,
        ),
        onTap: () {
          if (onTap != null) {
            onTap!();
            return;
          }
          onOpen?.call();
          context.router.push(PostDetailRoute(id: item.id));
        },
      ),
    );

    return widgetItem;
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
  final Widget? trailing;
  final void Function(String)? onPostTap;
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
    this.trailing,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hookResult = PluginHooks().runBeforePostDisplay(this.item.toJson());
    SnPost displayItem = this.item;
    try {
      displayItem = SnPost.fromJson(hookResult.data!);
    } catch (_) {
      // Invalid plugin output must not prevent the original post rendering.
    }
    final item = displayItem;
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

    if (hookResult.cancelled) return const SizedBox.shrink();

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
          ReferencedPostWidget(
            item: item,
            renderingPadding: renderingPadding,
            onPostTap: onPostTap,
          ),
        if (item.sponsored)
          Padding(
            padding: EdgeInsets.only(
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
              bottom: 6,
            ),
            child: const Align(
              alignment: Alignment.centerLeft,
              child: SponsoredBadge(),
            ),
          ),
        PostHeader(
          item: item,
          isFullPost: isFullPost,
          isCompact: isCompact,
          renderingPadding: renderingPadding,
          showUpperLine:
              isShowReference &&
              (item.repliedPost != null || item.forwardedPost != null),
          trailing: trailing,
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
          item: item,
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
            onPostTap: onPostTap,
          ).padding(horizontal: renderingPadding.horizontal, top: 8),
        Gap(renderingPadding.vertical),
      ],
    );
  }
}

Widget buildPostTranslationSection({
  required BuildContext context,
  required SnPost item,
  required bool isTextSelectable,
  required double? textScale,
  required String? translatedText,
  required bool isTranslating,
  required VoidCallback? onTranslate,
  bool showTranslateButton = true,
}) {
  final theme = Theme.of(context);
  final translatedWidget = (translatedText?.isNotEmpty ?? false)
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
                    theme.textTheme.bodyMedium!.fontSize! * (textScale ?? 1),
              ),
              content: translatedText!,
              isSelectable: isTextSelectable,
              attachments: item.attachments,
              noMentionChip: item.fediverseUri != null,
            ),
          ],
        )
      : null;

  final translationStatusWidget = isTranslating
      ? const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : null;

  final translatableWidget = onTranslate != null
      ? Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: isTranslating ? null : onTranslate,
            style: ButtonStyle(
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 2),
              ),
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              foregroundColor: WidgetStatePropertyAll(
                translatedText == null ? null : Colors.grey,
              ),
            ),
            icon: const Icon(Symbols.translate),
            label: translatedText != null
                ? const Text('translated').tr()
                : isTranslating
                ? const Text('translating').tr()
                : const Text('translate').tr(),
          ),
        )
      : null;

  final children = <Widget>[];
  if (translationStatusWidget != null) {
    children.add(
      Row(
        children: [
          const Expanded(child: Divider()),
          const Gap(8),
          translationStatusWidget,
        ],
      ),
    );
  }
  if (translatedWidget != null) {
    children.add(translatedWidget);
  }
  if (showTranslateButton && translatableWidget != null) {
    children.add(translatableWidget);
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );
}

class PostActionSheet extends StatelessWidget {
  final SnPost item;
  final bool isAuthor;
  final Function(String) onAction;

  const PostActionSheet({
    super.key,
    required this.item,
    required this.isAuthor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final primaryActions = <Widget>[
      _PostActionListTile(
        leading: Icon(Symbols.reply),
        title: Text('reply'.tr()),
        onTap: () => onAction('reply'),
      ),
      _PostActionListTile(
        leading: Icon(Symbols.forward),
        title: Text('forward'.tr()),
        onTap: () => onAction('forward'),
      ),
      _PostActionListTile(
        leading: Icon(Symbols.link),
        title: Text('copyLink'.tr()),
        onTap: () => onAction('copyLink'),
      ),
      _PostActionListTile(
        leading: Icon(Symbols.star),
        title: Text('award'.tr()),
        onTap: () => onAction('award'),
      ),
      _PostActionListTile(
        leading: Icon(Symbols.repeat),
        title: Text('boosts'.tr()),
        onTap: () => onAction('boost'),
      ),
      _PostActionListTile(
        leading: Icon(
          item.isBookmarked ? Symbols.bookmark_added : Symbols.bookmark,
        ),
        title: Text(item.isBookmarked ? 'unbookmark'.tr() : 'bookmark'.tr()),
        onTap: () => onAction('bookmark'),
      ),
      _PostActionListTile(
        leading: Icon(Symbols.share),
        title: Text('share'.tr()),
        onTap: () => onAction('share'),
      ),
      if (!kIsWeb)
        _PostActionListTile(
          leading: Icon(Symbols.share_reviews),
          title: Text('sharePostPhoto'.tr()),
          onTap: () => onAction('sharePhoto'),
        ),
      if (item.fediverseUri != null)
        _PostActionListTile(
          leading: Icon(Symbols.open_in_new),
          title: Text('openInBrowser'.tr()),
          onTap: () => onAction('openBrowser'),
        ),
    ];

    final authorActions = <Widget>[
      if (isAuthor)
        _PostActionListTile(
          leading: Icon(Symbols.edit),
          title: Text('edit'.tr()),
          onTap: () => onAction('edit'),
        ),
      if (isAuthor && item.pinMode == null)
        _PostActionListTile(
          leading: Icon(Symbols.keep),
          title: Text('pinPost'.tr()),
          onTap: () => onAction('pin'),
        ),
      if (isAuthor && item.pinMode != null)
        _PostActionListTile(
          leading: Icon(Symbols.keep_off),
          title: Text('unpinPost'.tr()),
          onTap: () => onAction('unpin'),
        ),
      if (isAuthor)
        _PostActionListTile(
          leading: Icon(Symbols.collections),
          title: Text('collections'.tr()),
          onTap: () => onAction('collections'),
        ),
      if (isAuthor)
        _PostActionListTile(
          leading: Icon(Symbols.delete),
          title: Text('delete'.tr()),
          onTap: () => onAction('delete'),
          isDanger: true,
        ),
    ];

    final feedbackActions = <Widget>[
      _PostActionListTile(
        leading: Icon(Symbols.thumb_up),
        title: Text('showMoreLikeThis'.tr()),
        onTap: () => onAction('showMoreLikeThis'),
      ),
      _PostActionListTile(
        leading: Icon(Symbols.thumb_down),
        title: Text('showLessLikeThis'.tr()),
        onTap: () => onAction('showLessLikeThis'),
      ),
      _PostActionListTile(
        leading: Icon(Symbols.hide_source),
        title: Text('notInterested'.tr()),
        onTap: () => onAction('notInterested'),
      ),
    ];

    final reportActions = <Widget>[
      _PostActionListTile(
        leading: Icon(Symbols.flag),
        title: Text('abuseReport'.tr()),
        onTap: () => onAction('report'),
      ),
    ];

    return SheetScaffold(
      titleText: 'postActions'.tr(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (primaryActions.isNotEmpty)
              _PostActionSection(children: primaryActions),
            if (authorActions.isNotEmpty)
              _PostActionSection(children: authorActions),
            if (feedbackActions.isNotEmpty)
              _PostActionSection(children: feedbackActions),
            if (reportActions.isNotEmpty)
              _PostActionSection(children: reportActions),
            Gap(MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }
}

class _PostActionSection extends StatelessWidget {
  final List<Widget> children;

  const _PostActionSection({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _PostActionListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback onTap;
  final bool isDanger;

  const _PostActionListTile({
    required this.leading,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isDanger
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground),
          child: IconTheme.merge(
            data: IconThemeData(color: foreground),
            child: Row(
              children: [
                SizedBox(width: 24, height: 24, child: leading),
                const Gap(12),
                Expanded(child: title),
                Icon(
                  Symbols.chevron_right,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostReactionList extends HookConsumerWidget {
  final SnPost item;
  final Map<String, int> reactions;
  final Map<String, bool> reactionsMade;
  final Function(String symbol, int attitude, int delta)? onReact;
  final EdgeInsets? padding;
  const PostReactionList({
    super.key,
    required this.item,
    required this.reactions,
    required this.reactionsMade,
    this.padding,
    this.onReact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitting = useState(false);

    Future<void> reactPost(String symbol, int attitude) async {
      final client = ref.watch(solarNetworkClientProvider);
      submitting.value = true;
      await client.dio
          .post(
            '/sphere/posts/${item.id}/reactions',
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
                        if (item.fediverseUri != null) {
                          final hasIdentity = ref.read(
                            hasFediverseIdentityProvider,
                          );
                          if (!hasIdentity) {
                            showFediverseInteractionHint(
                              context,
                              'fediverseInteractionHint',
                            );
                            return;
                          }
                        }
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
                              postId: item.id,
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

Future<void> showFediverseInteractionHint(
  BuildContext context,
  String hintKey,
) async {
  showOverlayDialog<void>(
    builder: (_, close) => ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: AlertDialog(
        title: null,
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Symbols.language,
              fill: 1,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Gap(16),
            Text(
              'fediverseInteractionHintTitle'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(8),
            Text(hintKey).tr(),
          ],
        ),
        actions: [
          TextButton(onPressed: () => close(null), child: Text('cancel'.tr())),
          FilledButton(
            onPressed: () {
              close(null);
              context.router.navigate(const CreatorHubRoute());
            },
            child: Text('learnMore'.tr()),
          ),
        ],
      ),
    ),
  );
}
