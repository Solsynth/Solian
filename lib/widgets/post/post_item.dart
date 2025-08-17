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
import 'package:island/widgets/post/post_item_screenshot.dart';
import 'package:island/widgets/post/post_shared.dart';
import 'package:island/widgets/safety/abuse_report_helper.dart';
import 'package:island/widgets/share/share_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:super_context_menu/super_context_menu.dart';

class PostActionableItem extends HookConsumerWidget {
  final SnPost item;
  final EdgeInsets? padding;
  final bool isFullPost;
  final bool isShowReference;
  final bool isEmbedReply;
  final bool isEmbedOpenable;
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
                callback: () {
                  context
                      .pushNamed('postEdit', pathParameters: {'id': item.id})
                      .then((value) {
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
              callback: () {
                context.pushNamed(
                  'postCompose',
                  extra: PostComposeInitialState(replyingTo: item),
                );
              },
            ),
            MenuAction(
              title: 'forward'.tr(),
              image: MenuImage.icon(Symbols.forward),
              callback: () {
                context.pushNamed(
                  'postCompose',
                  extra: PostComposeInitialState(forwardingTo: item),
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
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
            onUpdate?.call(item.copyWith(reactionsCount: reactionsCount));
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
          renderingPadding: renderingPadding,
          trailing: IconButton(
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
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      child: Text(
                        kReactionTemplates[mostReaction]?.icon ?? '',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                (item.reactionsMade[mostReaction] ?? false)
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                    : null,
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                builder: (BuildContext context) {
                  return _PostReactionSheet(
                    reactionsCount: item.reactionsCount,
                    reactionsMade: item.reactionsMade,
                    onReact: (symbol, attitude) {
                      reactPost(symbol, attitude);
                    },
                  );
                },
              );
            },
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
          ),
        ),
        PostBody(
          item: item,
          isFullPost: isFullPost,
          isTextSelectable: isTextSelectable,
          translationSection: translationSection,
          renderingPadding: renderingPadding,
        ),
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
      height: 28,
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
                              return _PostReactionSheet(
                                reactionsCount: reactions,
                                reactionsMade: reactionsMade,
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
  final Map<String, bool> reactionsMade;
  final Function(String symbol, int attitude) onReact;
  const _PostReactionSheet({
    required this.reactionsCount,
    required this.reactionsMade,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
            left: 20,
            right: 16,
            bottom: 12,
          ),
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
              _buildReactionSection(
                context,
                Symbols.mood,
                'reactionPositive'.tr(),
                0,
              ),
              _buildReactionSection(
                context,
                Symbols.sentiment_neutral,
                'reactionNeutral'.tr(),
                1,
              ),
              _buildReactionSection(
                context,
                Symbols.mood_bad,
                'reactionNegative'.tr(),
                2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionSection(
    BuildContext context,
    IconData icon,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [Icon(icon), Text(title).fontSize(17).bold()],
        ).padding(horizontal: 24, top: 16, bottom: 6),
        SizedBox(
          height: 120,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: 120,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allReactions.length,
            itemBuilder: (context, index) {
              final symbol = allReactions[index];
              final count = reactionsCount[symbol] ?? 0;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color:
                    (reactionsMade[symbol] ?? false)
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerLowest,
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: () {
                    onReact(symbol, attitude);
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        kReactionTemplates[symbol]?.icon ?? '',
                        textAlign: TextAlign.center,
                      ).fontSize(24),
                      Text(
                        ReactInfo.getTranslationKey(symbol),
                        textAlign: TextAlign.center,
                      ).tr(),
                      if (count > 0)
                        Text(
                          'x$count',
                          textAlign: TextAlign.center,
                        ).bold().padding(bottom: 4)
                      else
                        const Gap(20),
                    ],
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
