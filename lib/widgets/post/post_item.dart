import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/translate.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/screens/posts/compose.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/markdown.dart';
import 'package:island/widgets/content/image.dart';
import 'package:island/widgets/post/post_item_screenshot.dart';
import 'package:island/widgets/post/post_award_sheet.dart';
import 'package:island/widgets/post/post_pin_sheet.dart';
import 'package:island/widgets/post/post_shared.dart';
import 'package:island/widgets/post/embed_view_renderer.dart';
import 'package:island/widgets/post/post_reaction_sheet.dart';
import 'package:island/widgets/safety/abuse_report_helper.dart';
import 'package:island/widgets/share/share_sheet.dart';
import 'package:island/widgets/post/compose_dialog.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';

const kAvailableStickers = {
  'angry',
  'clap',
  'confuse',
  'pray',
  'thumb_up',
  'party',
};

bool _getReactionImageAvailable(String symbol) {
  return kAvailableStickers.contains(symbol);
}

Widget _buildReactionIcon(String symbol, double size, {double iconSize = 24}) {
  if (_getReactionImageAvailable(symbol)) {
    return Image.asset(
      'assets/images/stickers/$symbol.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
  } else {
    return Text(
      kReactionTemplates[symbol]?.icon ?? '',
      style: TextStyle(fontSize: iconSize),
    );
  }
}

class PostActionableItem extends HookConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isEmbedReply;
  final bool isEmbedOpenable;
  final bool isCompact;
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
    this.borderRadius,
    this.onRefresh,
    this.onUpdate,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final isAuthor = useMemoized(
      () => user.value != null && user.value?.id == item.publisher.accountId,
      [user],
    );

    final widgetItem = InkWell(
      borderRadius:
          borderRadius != null
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
        onRefresh: onRefresh,
        onUpdate: onUpdate,
        onOpen: onOpen,
      ),
      onTap: () {
        onOpen?.call();
        context.pushNamed('postDetail', pathParameters: {'id': item.id});
      },
    );

    final screenshotController = useMemoized(() => ScreenshotController(), []);

    void shareAsScreenshot() async {
      if (kIsWeb) return;
      showLoadingModal(context);
      await screenshotController
          .captureFromWidget(
            ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(
                  ref.watch(sharedPreferencesProvider),
                ),
              ],
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SizedBox(
                  width: 520,
                  child: PostItemScreenshot(item: item, isFullPost: isFullPost),
                ),
              ),
            ),
            context: context,
            pixelRatio: MediaQuery.of(context).devicePixelRatio,
            delay: const Duration(seconds: 1),
          )
          .then((Uint8List? image) async {
            if (image == null) return;
            final directory = await getTemporaryDirectory();
            final imagePath =
                await File('${directory.path}/image.png').create();
            await imagePath.writeAsBytes(image);

            if (!context.mounted) return;
            hideLoadingModal(context);
            final box = context.findRenderObject() as RenderBox?;
            await Share.shareXFiles([
              XFile(imagePath.path),
            ], sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
          })
          .catchError((err) {
            if (context.mounted) hideLoadingModal(context);
            showErrorAlert(err);
          });
    }

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
                  shareAsScreenshot();
                },
              ),
            MenuSeparator(),
            MenuAction(
              title: 'abuseReport'.tr(),
              image: MenuImage.icon(Symbols.flag),
              callback: () {
                showAbuseReportSheet(
                  context,
                  resourceIdentifier: 'post/${item.id}',
                );
              },
            ),
          ],
        );
      },
      child: Material(
        color: Theme.of(context).cardTheme.color,
        borderRadius:
            borderRadius != null
                ? BorderRadius.all(Radius.circular(borderRadius!))
                : null,
        child: widgetItem,
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
    this.onRefresh,
    this.onUpdate,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderingPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 8);

    final reacting = useState(false);

    Future<void> reactPost(String symbol, int attitude) async {
      final client = ref.watch(apiClientProvider);
      reacting.value = true;
      await client
          .post(
            '/sphere/posts/${item.id}/reactions',
            data: {'symbol': symbol, 'attitude': attitude},
          )
          .catchError((err) {
            showErrorAlert(err);
            return err;
          })
          .then((resp) {
            final isRemoving = resp.statusCode == 204;
            final delta = isRemoving ? -1 : 1;
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
            HapticFeedback.heavyImpact();
          });
      reacting.value = false;
    }

    final mostReaction =
        item.reactionsCount.isEmpty
            ? null
            : item.reactionsCount.entries
                .sortedBy((e) => e.value)
                .map((e) => e.key)
                .last;

    final postLanguage =
        item.content != null && isTranslatable
            ? ref.watch(detectStringLanguageProvider(item.content!))
            : null;

    final currentLanguage = isTranslatable ? context.locale.toString() : null;
    final translatableLanguage =
        postLanguage != null && isTranslatable
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

    final translatedWidget =
        (translatedText.value?.isNotEmpty ?? false)
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
                  content: translatedText.value!,
                  isSelectable: isTextSelectable,
                  attachments: item.attachments,
                ),
              ],
            )
            : null;

    final translatableWidget =
        (isTranslatable && translatableLanguage)
            ? Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: translating.value ? null : translate,
                style: ButtonStyle(
                  padding: const WidgetStatePropertyAll(EdgeInsets.zero),
                  visualDensity: const VisualDensity(
                    horizontal: 0,
                    vertical: -4,
                  ),
                  foregroundColor: WidgetStatePropertyAll(
                    translatedText.value == null ? null : Colors.grey,
                  ),
                ),
                icon: const Icon(Symbols.translate),
                label:
                    translatedText.value != null
                        ? const Text('translated').tr()
                        : translating.value
                        ? const Text('translating').tr()
                        : const Text('translate').tr(),
              ),
            )
            : null;

    final translationSection = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (translatedWidget != null) translatedWidget,
        if (translatableWidget != null) translatableWidget,
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(renderingPadding.vertical),
        PostHeader(
          item: item,
          isFullPost: isFullPost,
          isCompact: isCompact,
          renderingPadding: renderingPadding,
          trailing:
              isCompact
                  ? null
                  : SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      icon:
                          mostReaction == null
                              ? const Icon(Symbols.add_reaction)
                              : Badge(
                                label: Center(
                                  child: Text(
                                    'x${item.reactionsCount[mostReaction]}',
                                    style: const TextStyle(fontSize: 11),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                offset: const Offset(4, 20),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.75),
                                textColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                child:
                                    mostReaction.contains('+')
                                        ? HookConsumer(
                                          builder: (context, ref, child) {
                                            final baseUrl = ref.watch(
                                              serverUrlProvider,
                                            );
                                            final stickerUri =
                                                '$baseUrl/sphere/stickers/lookup/$mostReaction/open';
                                            return SizedBox(
                                              width: 32,
                                              height: 32,
                                              child:
                                                  UniversalImage(
                                                    uri: stickerUri,
                                                    width: 28,
                                                    height: 28,
                                                    fit: BoxFit.contain,
                                                  ).center(),
                                            );
                                          },
                                        )
                                        : _buildReactionIcon(
                                          mostReaction,
                                          32,
                                        ).padding(
                                          bottom:
                                              _getReactionImageAvailable(
                                                    mostReaction,
                                                  )
                                                  ? 2
                                                  : 0,
                                        ),
                              ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          (item.reactionsMade[mostReaction] ?? false)
                              ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5)
                              : null,
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          builder: (BuildContext context) {
                            return PostReactionSheet(
                              reactionsCount: item.reactionsCount,
                              reactionsMade: item.reactionsMade,
                              onReact: (symbol, attitude) {
                                reactPost(symbol, attitude);
                              },
                              postId: item.id,
                            );
                          },
                        );
                      },
                      padding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(
                        horizontal: -3,
                        vertical: -3,
                      ),
                    ),
                  ),
        ),
        PostBody(
          item: item,
          isFullPost: isFullPost,
          isTextSelectable: isTextSelectable,
          translationSection: translationSection,
          renderingPadding: renderingPadding,
        ),
        if (item.embedView != null)
          EmbedViewRenderer(
            embedView: item.embedView!,
            maxHeight: 400,
            borderRadius: BorderRadius.circular(12),
          ).padding(horizontal: renderingPadding.horizontal, vertical: 8),
        if (isShowReference)
          ReferencedPostWidget(item: item, renderingPadding: renderingPadding),
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
                onPressed:
                    submitting.value
                        ? null
                        : () {
                          showModalBottomSheet(
                            context: context,
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
                avatar: _buildReactionIcon(symbol, 24),
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
