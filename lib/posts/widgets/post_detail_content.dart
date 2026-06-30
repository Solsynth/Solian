import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/translate.dart';
import 'package:island/core/widgets/content/cloud_file_lightbox.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_quick_reply.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const postDetailMaxWidth = 640.0;
const _postDetailAttachmentMaxHeight = 760.0;

typedef PostDetailActionBuilder =
    Widget Function(
      BuildContext context,
      Future<void> Function(String text) onTranslate,
    );

IDisplayableCloudFile? _getPostThumbnail(SnPost post) {
  final thumbnailId = post.meta?['thumbnail'] as String?;
  if (thumbnailId == null) return null;
  try {
    return post.attachments.firstWhere((a) => a.id == thumbnailId);
  } catch (_) {
    return null;
  }
}

bool _isMediaPost(SnPost post) {
  return post.type == 0 && post.attachments.isNotEmpty;
}

class _PostDetailMediaBackdrop extends ConsumerWidget {
  final IDisplayableCloudFile file;

  const _PostDetailMediaBackdrop({required this.file});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final isImage = file.mimeType.startsWith('image');
    final isVideo = file.mimeType.startsWith('video');
    final thumbnailUri =
        file.storageUrl ?? '$serverUrl/drive/files/${file.id}?thumbnail=true';

    Widget child;
    if (isImage && file.blurhash?.isNotEmpty == true) {
      child = BlurHash(hash: file.blurhash!);
    } else if (isImage) {
      child = Stack(
        fit: StackFit.expand,
        children: [
          CloudFileWidget(
            item: file,
            fit: BoxFit.cover,
            noBlurhash: true,
            useInternalGate: false,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.black38),
          ),
        ],
      );
    } else if (isVideo) {
      child = Stack(
        fit: StackFit.expand,
        children: [
          UniversalImage(uri: thumbnailUri, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.black38),
          ),
        ],
      );
    } else {
      child = const ColoredBox(color: Colors.black);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: child),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0x66000000)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PostDetailMediaBadge extends StatelessWidget {
  final int current;
  final int total;

  const _PostDetailMediaBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '$current/$total',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PostDetailMediaArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Alignment alignment;

  const _PostDetailMediaArrowButton({
    required this.icon,
    required this.onTap,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: onTap == null ? 0.35 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Material(
            color: Colors.black45,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostDetailMediaCarousel extends HookConsumerWidget {
  final SnPost post;
  final double maxHeight;

  const _PostDetailMediaCarousel({required this.post, required this.maxHeight});

  String _heroTag(String fileId) => 'post-detail-media-${post.id}-$fileId';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);
    final pageController = usePageController();
    final currentFile = post.attachments[currentIndex.value];
    final mediaQuery = MediaQuery.of(context);
    final currentIsAudio = currentFile.mimeType.startsWith('audio');
    final currentIsVideo = currentFile.mimeType.startsWith('video');
    final ratio = (currentFile.ratio?.toDouble() ?? 1.0).clamp(0.5, 2.5);
    final imageFiles = useMemoized(
      () => post.attachments.where((file) => file.mimeType.startsWith('image')),
      [post.attachments],
    );

    void openMediaAt(int index) {
      final file = post.attachments[index];
      if (file.mimeType.startsWith('image')) {
        final viewableFiles = imageFiles.toList();
        final viewableIndex = viewableFiles.indexWhere(
          (item) => item.id == file.id,
        );
        if (viewableIndex != -1) {
          context.pushTransparentRoute(
            CloudFileLightbox(
              items: viewableFiles,
              initialIndex: viewableIndex,
              heroTag: _heroTag(file.id),
              sourcePost: post,
            ),
            rootNavigator: true,
          );
          return;
        }
      }
      context.router.push(FileDetailRoute(id: file.id, sourcePost: post));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaQuery.size.width;
        final effectiveMaxHeight = currentIsVideo
            ? (mediaQuery.size.height * 0.58).clamp(320.0, maxHeight)
            : maxHeight;
        final height = currentIsAudio
            ? 160.0
            : (availableWidth / ratio).clamp(280.0, effectiveMaxHeight);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: _PostDetailMediaBackdrop(file: currentFile)),
              PageView.builder(
                controller: pageController,
                itemCount: post.attachments.length,
                onPageChanged: (index) => currentIndex.value = index,
                itemBuilder: (context, index) {
                  final file = post.attachments[index];
                  final itemRatio = (file.ratio?.toDouble() ?? 1.0).clamp(
                    0.5,
                    2.5,
                  );
                  final isAudio = file.mimeType.startsWith('audio');

                  Widget content = CloudFileWidget(
                    item: file,
                    heroTag: _heroTag(file.id),
                    fit: BoxFit.contain,
                    noBlurhash: true,
                    useInternalGate: false,
                    sourcePost: post,
                  );

                  if (isAudio) {
                    content = SizedBox(height: 160, child: content);
                  } else {
                    content = AspectRatio(aspectRatio: itemRatio, child: content);
                  }

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => openMediaAt(index),
                      child: Center(child: content),
                    ),
                  );
                },
              ),
              if (post.attachments.length > 1)
                Positioned(
                  left: 16,
                  top: 16,
                  child: _PostDetailMediaBadge(
                    current: currentIndex.value + 1,
                    total: post.attachments.length,
                  ),
                ),
              if (post.attachments.length > 1)
                _PostDetailMediaArrowButton(
                  icon: Icons.chevron_left,
                  alignment: Alignment.centerLeft,
                  onTap: currentIndex.value > 0
                      ? () => pageController.previousPage(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                        )
                      : null,
                ),
              if (post.attachments.length > 1)
                _PostDetailMediaArrowButton(
                  icon: Icons.chevron_right,
                  alignment: Alignment.centerRight,
                  onTap: currentIndex.value < post.attachments.length - 1
                      ? () => pageController.nextPage(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                        )
                      : null,
                ),
            ],
          ),
        );
      },
    );
  }
}

class PostDetailContent extends HookConsumerWidget {
  final String postId;
  final SnPost post;
  final Widget? trailing;
  final void Function(String)? onPostTap;
  final double maxWidth;
  final Future<void> Function() onRefresh;
  final ValueChanged<SnPost?> onUpdate;
  final VoidCallback onReplyPosted;
  final Widget? threadSection;
  final Widget? collectionSection;
  final Widget? realmSection;
  final Widget interactionsSection;
  final PostDetailActionBuilder actionBuilder;

  const PostDetailContent({
    super.key,
    required this.postId,
    required this.post,
    required this.onRefresh,
    required this.onUpdate,
    required this.onReplyPosted,
    required this.interactionsSection,
    required this.actionBuilder,
    this.trailing,
    this.onPostTap,
    this.maxWidth = postDetailMaxWidth,
    this.threadSection,
    this.collectionSection,
    this.realmSection,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final translating = useState(false);
    final translatedText = useState<String?>(null);
    final currentLanguage = context.locale.toString();
    final isMediaPost = _isMediaPost(post);
    final thumbnail = post.type == 1 ? _getPostThumbnail(post) : null;

    Future<void> translatePost(String text) async {
      if (translatedText.value != null) {
        translatedText.value = null;
        return;
      }
      if (translating.value) return;
      translating.value = true;
      try {
        final result = await ref.read(
          translateStringProvider(
            TranslateQuery(text: text, lang: currentLanguage.substring(0, 2)),
          ).future,
        );
        translatedText.value = result;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        translating.value = false;
      }
    }

    Widget wrapContent(Widget child) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ExtendedRefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            slivers: [
              if (isMediaPost)
                SliverToBoxAdapter(
                  child: wrapContent(
                    ClipRect(
                      child: _PostDetailMediaCarousel(
                        post: post,
                        maxHeight: _postDetailAttachmentMaxHeight,
                      ),
                    ),
                  ),
                ),
              if (thumbnail != null)
                SliverToBoxAdapter(
                  child: wrapContent(
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: CloudFileList(
                        files: [thumbnail],
                        sourcePost: post,
                        maxHeight: _postDetailAttachmentMaxHeight,
                        padding: EdgeInsets.zero,
                        disableConstraint: true,
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: wrapContent(
                  PostItem(
                    item: post,
                    isFullPost: true,
                    isEmbedReply: false,
                    isTranslatable: false,
                    hideAttachments: isMediaPost,
                    textScale: post.type == 1 ? 1.2 : 1.1,
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                    onUpdate: onUpdate,
                    trailing: trailing,
                    onPostTap: onPostTap,
                  ),
                ),
              ),
              if (threadSection != null)
                SliverToBoxAdapter(
                  child: wrapContent(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: threadSection!,
                    ),
                  ),
                ),
              if (collectionSection != null)
                SliverToBoxAdapter(
                  child: wrapContent(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: collectionSection!,
                    ),
                  ),
                ),
              if (realmSection != null)
                SliverToBoxAdapter(
                  child: wrapContent(
                    realmSection!.padding(horizontal: 16, vertical: 8),
                  ),
                ),
              if (translatedText.value != null || translating.value)
                SliverToBoxAdapter(
                  child: wrapContent(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: buildPostTranslationSection(
                        context: context,
                        item: post,
                        isTextSelectable: true,
                        textScale: post.type == 1 ? 1.2 : 1.1,
                        translatedText: translatedText.value,
                        isTranslating: translating.value,
                        onTranslate: () => translatePost(post.content ?? ''),
                        showTranslateButton: false,
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: wrapContent(actionBuilder(context, translatePost)),
              ),
              interactionsSection,
              SliverGap(MediaQuery.of(context).padding.bottom + 80),
            ],
          ),
        ),
        if (user.value != null)
          Positioned(
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            child: wrapContent(
              PostQuickReply(parent: post, onPosted: onReplyPosted),
            ),
          ),
      ],
    );
  }
}
