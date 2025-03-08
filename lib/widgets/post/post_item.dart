import 'dart:io';
import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:relative_time/relative_time.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/screens/post/post_detail.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/types/post.dart';
import 'package:surface/types/reaction.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/attachment/attachment_item.dart';
import 'package:surface/widgets/attachment/attachment_list.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/link_preview.dart';
import 'package:surface/widgets/markdown_content.dart';
import 'package:gap/gap.dart';
import 'package:surface/widgets/post/post_comment_list.dart';
import 'package:surface/widgets/post/post_meta_editor.dart';
import 'package:surface/widgets/post/post_poll.dart';
import 'package:surface/widgets/post/post_reaction.dart';
import 'package:surface/widgets/post/publisher_popover.dart';
import 'package:surface/widgets/universal_image.dart';
import 'package:xml/xml.dart';

import '../../screens/account/profile_page.dart' show kBadgesMeta;

class OpenablePostItem extends StatelessWidget {
  final SnPost data;
  final bool showReactions;
  final bool showComments;
  final bool showMenu;
  final bool showFullPost;
  final double? maxWidth;
  final Function(SnPost data)? onChanged;
  final Function()? onDeleted;
  final Function()? onSelectAnswer;

  const OpenablePostItem({
    super.key,
    required this.data,
    this.showReactions = true,
    this.showComments = true,
    this.showMenu = true,
    this.showFullPost = false,
    this.maxWidth,
    this.onChanged,
    this.onDeleted,
    this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = context.read<ConfigProvider>();

    return Center(
      child: OpenContainer(
        closedBuilder: (_, __) => Container(
          constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
          child: PostItem(
            data: data,
            maxWidth: maxWidth,
            showComments: showComments,
            showFullPost: showFullPost,
            onChanged: onChanged,
            onDeleted: onDeleted,
            onSelectAnswer: onSelectAnswer,
          ),
        ),
        openBuilder: (_, close) => PostDetailScreen(
          slug: data.id.toString(),
          preload: data,
          onBack: close,
        ),
        openColor: Colors.transparent,
        openElevation: 0,
        transitionType: ContainerTransitionType.fade,
        closedColor:
            Theme.of(context).colorScheme.surfaceContainerLow.withOpacity(
                  cfg.prefs.getBool(kAppBackgroundStoreKey) == true ? 0.75 : 1,
                ),
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}

class PostItem extends StatelessWidget {
  final SnPost data;
  final bool showReactions;
  final bool showComments;
  final bool showMenu;
  final bool showFullPost;
  final double? maxWidth;
  final Function(SnPost data)? onChanged;
  final Function()? onDeleted;
  final Function()? onSelectAnswer;

  const PostItem({
    super.key,
    required this.data,
    this.showReactions = true,
    this.showComments = true,
    this.showMenu = true,
    this.showFullPost = false,
    this.maxWidth,
    this.onChanged,
    this.onDeleted,
    this.onSelectAnswer,
  });

  void _onChanged(SnPost data) {
    if (onChanged != null) onChanged!(data);
  }

  void _doShare(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final url = 'https://solsynth.dev/posts/${data.id}';
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Share.shareUri(Uri.parse(url),
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      Share.share(url,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }

  void _doShareViaPicture(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    final controller = ScreenshotController();
    final capturedImage = await controller.captureFromLongWidget(
      InheritedTheme.captureAll(
        context,
        MediaQuery(
          data: MediaQuery.of(context),
          child: Material(
            child: MultiProvider(
              providers: [
                // Create a copy of environments
                Provider<SnNetworkProvider>(create: (_) => context.read()),
                Provider<UserDirectoryProvider>(create: (_) => context.read()),
              ],
              child: ResponsiveBreakpoints.builder(
                breakpoints: ResponsiveBreakpoints.of(context).breakpoints,
                child: PostShareImageWidget(data: data),
              ),
            ),
          ),
        ),
      ),
      pixelRatio: 3,
      context: context,
    );

    if (kIsWeb) return;

    final directory = await getTemporaryDirectory();
    final imageFile = await File(
      '${directory.path}/sn-share-via-image-${DateTime.now().millisecondsSinceEpoch}.png',
    ).create();
    await imageFile.writeAsBytes(capturedImage);

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } else {
      await FileSaver.instance.saveFile(
          name: 'Solar Network Post #${data.id}.png', file: imageFile);
    }

    await imageFile.delete();
  }

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();

    final ua = context.read<UserProvider>();
    final isAuthor = ua.isAuthorized && data.publisher.accountId == ua.user?.id;

    // Video full view
    if (showFullPost &&
        data.type == 'video' &&
        ResponsiveBreakpoints.of(context).largerThan(TABLET)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostContentHeader(
                  data: data,
                  isAuthor: isAuthor,
                  isRelativeDate: !showFullPost,
                  onShare: () => _doShare(context),
                  onShareImage: () => _doShareViaPicture(context),
                  onSelectAnswer: onSelectAnswer,
                  onDeleted: () {
                    onDeleted?.call();
                  },
                ).padding(bottom: 8),
                if (data.preload?.video != null)
                  _PostVideoPlayer(data: data).padding(bottom: 8),
                _PostHeadline(data: data).padding(horizontal: 4, bottom: 8),
                _PostFeaturedComment(data: data),
                _PostBottomAction(
                  data: data,
                  showComments: true,
                  showReactions: showReactions,
                  onShare: () => _doShare(context),
                  onShareImage: () => _doShareViaPicture(context),
                  onChanged: _onChanged,
                ),
              ],
            ),
          ),
          const Gap(4),
          SizedBox(
            width: 340,
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                PostCommentSliverList(
                  parentPost: data,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Article headline preview
    if (!showFullPost && data.type == 'article') {
      return Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PostContentHeader(
              data: data,
              isAuthor: isAuthor,
              isRelativeDate: !showFullPost,
              onShare: () => _doShare(context),
              onShareImage: () => _doShareViaPicture(context),
              onSelectAnswer: onSelectAnswer,
              onDeleted: () {
                onDeleted?.call();
              },
            ).padding(horizontal: 12, top: 8, bottom: 8),
            if (data.preload?.video != null)
              _PostVideoPlayer(data: data).padding(horizontal: 12, bottom: 8),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 4, left: 12, right: 12),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.preload?.thumbnail != null)
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: AutoResizeUniversalImage(
                          sn.getAttachmentUrl(data.preload!.thumbnail!.rid),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const Gap(8),
                  _PostHeadline(data: data).padding(horizontal: 14),
                  const Gap(4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.visibility > 0) _PostVisibilityHint(data: data),
                      _PostTruncatedHint(data: data),
                      if (data.tags.isNotEmpty) _PostTagsList(data: data),
                    ],
                  ).padding(horizontal: 12),
                  const Gap(8),
                ],
              ),
            ),
            Text('postArticle')
                .tr()
                .fontSize(13)
                .opacity(0.75)
                .padding(horizontal: 24, bottom: 8),
            _PostFeaturedComment(data: data, maxWidth: maxWidth)
                .padding(horizontal: 12),
            _PostBottomAction(
              data: data,
              showComments: showComments,
              showReactions: showReactions,
              onShare: () => _doShare(context),
              onShareImage: () => _doShareViaPicture(context),
              onChanged: _onChanged,
            ).padding(left: 8, right: 14),
          ],
        ),
      ).center();
    }

    final displayableAttachments = data.preload?.attachments
        ?.where((ele) =>
            ele?.mediaType != SnMediaType.image || data.type != 'article')
        .toList();

    final cfg = context.read<ConfigProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PostContentHeader(
                isAuthor: isAuthor,
                isRelativeDate: !showFullPost,
                data: data,
                showMenu: showMenu,
                onShare: () => _doShare(context),
                onShareImage: () => _doShareViaPicture(context),
                onSelectAnswer: onSelectAnswer,
                onDeleted: () {
                  onDeleted?.call();
                },
              ).padding(horizontal: 12, vertical: 8),
              if (data.preload?.video != null)
                _PostVideoPlayer(data: data).padding(horizontal: 12, bottom: 8),
              if (data.type == 'question')
                _PostQuestionHint(data: data)
                    .padding(horizontal: 16, bottom: 8),
              if (data.body['title'] != null ||
                  data.body['description'] != null)
                _PostHeadline(
                  data: data,
                  isEnlarge: data.type == 'article' && showFullPost,
                ).padding(horizontal: 16, bottom: 8),
              if (data.body['content']?.isNotEmpty ?? false)
                _PostContentBody(
                  data: data,
                  isSelectable: showFullPost,
                  isEnlarge: data.type == 'article' && showFullPost,
                ).padding(horizontal: 16, bottom: 6),
              if (data.repostTo != null)
                _PostQuoteContent(child: data.repostTo!).padding(
                  horizontal: 12,
                  bottom:
                      data.preload?.attachments?.isNotEmpty ?? false ? 12 : 0,
                ),
              if (data.visibility > 0)
                _PostVisibilityHint(data: data).padding(
                  horizontal: 16,
                  vertical: 4,
                ),
              if (data.body['content_truncated'] == true)
                _PostTruncatedHint(data: data).padding(
                  horizontal: 16,
                  vertical: 4,
                ),
              if (data.tags.isNotEmpty)
                _PostTagsList(data: data)
                    .padding(horizontal: 16, top: 4, bottom: 6),
            ],
          ),
        ),
        if (displayableAttachments?.isNotEmpty ?? false)
          AttachmentList(
            data: displayableAttachments!,
            bordered: true,
            maxHeight: showFullPost ? null : 480,
            maxWidth: MediaQuery.of(context).size.width - 20,
            fit: showFullPost ? BoxFit.cover : BoxFit.contain,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        if (data.preload?.poll != null)
          PostPoll(poll: data.preload!.poll!)
              .padding(horizontal: 12, vertical: 4),
        if (data.body['content'] != null &&
            (cfg.prefs.getBool(kAppExpandPostLink) ?? true))
          LinkPreviewWidget(
            text: data.body['content'],
          ).padding(horizontal: 4),
        _PostFeaturedComment(data: data, maxWidth: maxWidth)
            .padding(horizontal: 12),
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
          child: Column(
            children: [
              _PostBottomAction(
                data: data,
                showComments: showComments,
                showReactions: showReactions,
                onShare: () => _doShare(context),
                onShareImage: () => _doShareViaPicture(context),
                onChanged: _onChanged,
              ).padding(left: 8, right: 14),
            ],
          ),
        ),
      ],
    );
  }
}

class PostShareImageWidget extends StatelessWidget {
  const PostShareImageWidget({
    super.key,
    required this.data,
  });

  final SnPost data;

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();

    return SizedBox(
      width: 480,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.preload?.thumbnail != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: AutoResizeUniversalImage(
                  sn.getAttachmentUrl(data.preload!.thumbnail!.rid),
                  fit: BoxFit.cover,
                ),
              ),
            ).padding(bottom: 8),
          _PostContentHeader(
            isAuthor: false,
            data: data,
            onDeleted: () {},
            onShare: () {},
            onShareImage: () {},
            showMenu: false,
            isRelativeDate: false,
          ).padding(horizontal: 16, bottom: 8),
          if (data.type == 'question')
            _PostQuestionHint(data: data).padding(horizontal: 16, bottom: 8),
          _PostHeadline(
            data: data,
            isEnlarge: data.type == 'article',
          ).padding(horizontal: 16, bottom: 8),
          if (data.body['content']?.isNotEmpty ?? false)
            _PostContentBody(
              data: data,
              isEnlarge: data.type == 'article',
            ).padding(horizontal: 16, bottom: 8),
          if (data.repostTo != null)
            _PostQuoteContent(
              child: data.repostTo!,
              isRelativeDate: false,
            ).padding(horizontal: 16, bottom: 8),
          if (data.type != 'article' &&
              (data.preload?.attachments?.isNotEmpty ?? false))
            StyledWidget(AttachmentList(
              data: data.preload!.attachments!,
              columned: true,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            )).padding(horizontal: 16, bottom: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.visibility > 0) _PostVisibilityHint(data: data),
              if (data.body['content_truncated'] == true)
                _PostTruncatedHint(data: data),
            ],
          ).padding(horizontal: 16),
          _PostBottomAction(
            data: data,
            showComments: true,
            showReactions: true,
            onShare: () {},
            onShareImage: () {},
            onChanged: (SnPost data) {},
          ).padding(left: 8, right: 14),
          const Divider(height: 1),
          const Gap(12),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data.aliasPrefix} / ${data.alias ?? '#${data.id}'}',
                              style: GoogleFonts.robotoMono(fontSize: 17),
                            ),
                            const Gap(2),
                            Text(
                              switch (data.type) {
                                'article' => 'postArticle'.tr(),
                                _ => 'postStory'.tr(),
                              },
                              style: GoogleFonts.robotoMono(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (data.body['content_truncated'] == true)
                        Text(
                          'postImageShareReadMore'.tr(),
                          style: GoogleFonts.robotoMono(fontSize: 11),
                        ),
                      Text(
                        'postImageShareAds',
                        style: GoogleFonts.robotoMono(fontSize: 13),
                      ).tr(),
                    ],
                  ),
                ),
                QrImageView(
                  padding: EdgeInsets.zero,
                  data: 'https://solsynth.dev/posts/${data.id}',
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  version: QrVersions.auto,
                  size: 100,
                  gapless: true,
                  embeddedImage:
                      AssetImage('assets/icon/icon-light-radius.png'),
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(28, 28),
                  ),
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.circle,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                )
              ],
            ),
          ).padding(left: 16, right: 32, vertical: 8),
        ],
      ).padding(vertical: 16),
    );
  }
}

class _PostQuestionHint extends StatelessWidget {
  final SnPost data;

  const _PostQuestionHint({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(data.body['answer'] == null ? Symbols.help : Symbols.check_circle,
            size: 20),
        const Gap(4),
        if (data.body['answer'] == null &&
            data.body['reward']?.toDouble() != null)
          Text('postQuestionUnansweredWithReward'.tr(args: [
            '${data.body['reward']}',
          ])).opacity(0.75)
        else if (data.body['answer'] == null)
          Text('postQuestionUnanswered'.tr()).opacity(0.75)
        else
          Text('postQuestionAnswered'.tr()).opacity(0.75),
      ],
    ).opacity(0.75);
  }
}

class _PostBottomAction extends StatelessWidget {
  final SnPost data;
  final bool showComments;
  final bool showReactions;
  final Function(SnPost data) onChanged;
  final Function() onShare, onShareImage;

  const _PostBottomAction({
    required this.data,
    required this.showComments,
    required this.showReactions,
    required this.onChanged,
    required this.onShare,
    required this.onShareImage,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface.withAlpha(
          (255 * 0.8).round(),
        );

    final String? mostTypicalReaction = data.metric.reactionList.isNotEmpty
        ? data.metric.reactionList.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (showReactions || showComments)
          Row(
            spacing: 8,
            children: [
              if (showReactions)
                InkWell(
                  child: Row(
                    children: [
                      if (mostTypicalReaction == null ||
                          kTemplateReactions[mostTypicalReaction] == null)
                        Icon(Symbols.add_reaction, size: 20, color: iconColor)
                      else
                        Text(
                          kTemplateReactions[mostTypicalReaction]!.icon,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                      const Gap(8),
                      if (data.totalUpvote > 0 &&
                          data.totalUpvote >= data.totalDownvote)
                        Text('postReactionUpvote').plural(
                          data.totalUpvote,
                        )
                      else if (data.totalDownvote > 0)
                        Text('postReactionDownvote').plural(
                          data.totalDownvote,
                        )
                      else
                        Text('postReact').tr(),
                    ],
                  ).padding(horizontal: 8, vertical: 8),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => PostReactionPopup(
                        data: data,
                        onChanged: (value, attr, delta) {
                          onChanged(data.copyWith(
                            totalUpvote: attr == 1
                                ? data.totalUpvote + delta
                                : data.totalUpvote,
                            totalDownvote: attr == 2
                                ? data.totalDownvote + delta
                                : data.totalDownvote,
                            metric: data.metric.copyWith(reactionList: value),
                          ));
                        },
                      ),
                    );
                  },
                ),
              if (showComments)
                InkWell(
                  child: Row(
                    children: [
                      Icon(Symbols.comment, size: 20, color: iconColor),
                      const Gap(8),
                      Text('postComments').plural(data.metric.replyCount),
                    ],
                  ).padding(horizontal: 8, vertical: 8),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      builder: (context) => PostCommentListPopup(
                        post: data,
                        commentCount: data.metric.replyCount,
                      ),
                    );
                  },
                ),
              InkWell(
                child: Row(
                  children: [
                    Icon(Symbols.play_circle, size: 20, color: iconColor),
                    const Gap(8),
                    Text('postViews').plural(data.totalViews),
                  ],
                ),
              ),
            ],
          ),
        InkWell(
          onTap: onShare,
          onLongPress: onShareImage,
          child: Icon(
            Symbols.share,
            size: 20,
            color: iconColor,
          ).padding(horizontal: 8, vertical: 8),
        ),
      ],
    );
  }
}

class _PostHeadline extends StatelessWidget {
  final SnPost data;
  final bool isEnlarge;

  const _PostHeadline({
    required this.data,
    this.isEnlarge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEnlarge) {
      final sn = context.read<SnNetworkProvider>();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.preload?.thumbnail != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: AutoResizeUniversalImage(
                    sn.getAttachmentUrl(data.preload!.thumbnail!.rid),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (data.body['title'] != null)
            Text(
              data.body['title'],
              style: Theme.of(context).textTheme.titleMedium,
              textScaler: TextScaler.linear(1.4),
            ),
          if (data.body['description'] != null)
            Text(
              data.body['description'],
              style: Theme.of(context).textTheme.bodyMedium,
              textScaler: TextScaler.linear(1.1),
            ),
          if (data.body['description'] != null) const Gap(8) else const Gap(4),
          Row(
            children: [
              Text(
                'articleWrittenAt'.tr(
                  args: [
                    DateFormat('y/M/d HH:mm').format(data.createdAt.toLocal())
                  ],
                ),
                style: TextStyle(fontSize: 13),
              ),
              const Gap(8),
              if (data.editedAt != null)
                Text(
                  'articleEditedAt'.tr(
                    args: [
                      DateFormat('y/M/d HH:mm').format(data.editedAt!.toLocal())
                    ],
                  ),
                  style: TextStyle(fontSize: 13),
                ),
            ],
          ).opacity(0.75),
          const Gap(8),
          const Divider(height: 1, thickness: 1),
          const Gap(8),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.body['title'] != null)
          Text(
            data.body['title'],
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (data.body['description'] != null)
          Text(
            data.body['description'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }
}

class _PostContentHeader extends StatelessWidget {
  final SnPost data;
  final bool isAuthor;
  final bool isCompact;
  final bool isRelativeDate;
  final bool showMenu;
  final Function onDeleted;
  final Function() onShare, onShareImage;
  final Function()? onSelectAnswer;

  const _PostContentHeader({
    required this.data,
    required this.isAuthor,
    this.isCompact = false,
    this.isRelativeDate = true,
    this.showMenu = true,
    required this.onDeleted,
    required this.onShare,
    required this.onShareImage,
    this.onSelectAnswer,
  });

  Future<void> _deletePost(BuildContext context) async {
    final confirm = await context.showConfirmDialog(
      'postDelete'.tr(args: ['#${data.id}']),
      'postDeleteDescription'.tr(),
    );

    if (!confirm) return;
    if (!context.mounted) return;

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.delete('/cgi/co/posts/${data.id}', queryParameters: {
        'publisherId': data.publisherId,
      });
      if (!context.mounted) return;
      context.showSnackbar('postDeleted'.tr(args: ['#${data.id}']));
    } catch (err) {
      if (!context.mounted) return;
      context.showErrorDialog(err);
    }
  }

  Future<void> _flagPost(BuildContext context) async {
    final confirm = await context.showConfirmDialog(
      'flagPost'.tr(),
      'flagPostDescription'.tr(),
    );
    if (!confirm) return;
    if (!context.mounted) return;

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post('/cgi/co/posts/${data.id}/flag');
      if (!context.mounted) return;
      context.showSnackbar('postFlagged'.tr());
    } catch (err) {
      if (!context.mounted) return;
      context.showErrorDialog(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ud = context.read<UserDirectoryProvider>();
    final user = data.publisher.type == 0
        ? ud.getFromCache(data.publisher.accountId)
        : null;

    return Row(
      children: [
        GestureDetector(
          child: AccountImage(
            content: data.publisher.avatar,
            radius: isCompact ? 12 : 20,
            borderRadius: data.publisher.type == 1 ? (isCompact ? 4 : 8) : 20,
            badge: (user?.badges.isNotEmpty ?? false)
                ? Icon(
                    kBadgesMeta[user!.badges.first.type]?.$2 ??
                        Symbols.question_mark,
                    color: kBadgesMeta[user.badges.first.type]?.$3,
                    fill: 1,
                    size: 18,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 5.0,
                        color: Color.fromARGB(200, 0, 0, 0),
                      ),
                    ],
                  )
                : null,
          ),
          onTap: () {
            showPopover(
              backgroundColor: Theme.of(context).colorScheme.surface,
              context: context,
              transition: PopoverTransition.other,
              bodyBuilder: (context) => SizedBox(
                width: math.min(400, MediaQuery.of(context).size.width - 10),
                child: PublisherPopoverCard(
                  data: data.publisher,
                ),
              ),
              direction: PopoverDirection.bottom,
              arrowHeight: 5,
              arrowWidth: 15,
              arrowDxOffset: -190,
            );
          },
        ),
        Gap(isCompact ? 8 : 12),
        if (isCompact)
          Row(
            children: [
              Text(data.publisher.nick).bold(),
              const Gap(4),
              Row(
                children: [
                  Text('@${data.publisher.name}').fontSize(13),
                  const Gap(4),
                  Text(
                    isRelativeDate
                        ? RelativeTime(context).format(
                            (data.publishedAt ?? data.createdAt).toLocal())
                        : DateFormat('y/M/d HH:mm').format(
                            (data.publishedAt ?? data.createdAt).toLocal()),
                  ).fontSize(13),
                ],
              ).opacity(0.8),
            ],
          )
        else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.publisher.nick).bold(),
                Row(
                  children: [
                    Text('@${data.publisher.name}').fontSize(13),
                    const Gap(4),
                    Text(
                      isRelativeDate
                          ? RelativeTime(context).format(
                              (data.publishedAt ?? data.createdAt).toLocal())
                          : DateFormat('y/M/d HH:mm').format(
                              (data.publishedAt ?? data.createdAt).toLocal()),
                    ).fontSize(13),
                  ],
                ).opacity(0.8),
              ],
            ),
          ),
        if (showMenu)
          PopupMenuButton(
            icon: const Icon(Symbols.more_horiz),
            style: const ButtonStyle(
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              if (isAuthor && onSelectAnswer != null)
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Symbols.check_circle),
                      const Gap(16),
                      Text('postQuestionAnswerSelect').tr(),
                    ],
                  ),
                  onTap: () {
                    onSelectAnswer?.call();
                  },
                ),
              if (isAuthor && onSelectAnswer != null) PopupMenuDivider(),
              if (isAuthor)
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Symbols.edit),
                      const Gap(16),
                      Text('edit').tr(),
                    ],
                  ),
                  onTap: () {
                    GoRouter.of(context).pushNamed(
                      'postEditor',
                      queryParameters: {
                        'editing': data.id.toString(),
                        'mode': data.typePlural,
                      },
                    );
                  },
                ),
              if (isAuthor)
                PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Symbols.delete),
                      const Gap(16),
                      Text('delete').tr(),
                    ],
                  ),
                  onTap: () => _deletePost(context),
                ),
              if (isAuthor) const PopupMenuDivider(),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.reply),
                    const Gap(16),
                    Text('replyPost').tr(),
                  ],
                ),
                onTap: () {
                  GoRouter.of(context).pushNamed(
                    'postEditor',
                    queryParameters: {
                      'replying': data.id.toString(),
                      'mode': data.typePlural,
                    },
                  );
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.forward),
                    const Gap(16),
                    Text('repost').tr(),
                  ],
                ),
                onTap: () {
                  GoRouter.of(context).pushNamed(
                    'postEditor',
                    queryParameters: {
                      'reposting': data.id.toString(),
                      'mode': 'stories',
                    },
                  );
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.book_4_spark),
                    const Gap(16),
                    Text('postGetInsight').tr(),
                  ],
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => _PostGetInsightPopup(postId: data.id),
                  );
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: onShare,
                child: Row(
                  children: [
                    const Icon(Symbols.share),
                    const Gap(16),
                    Text('postShare').tr(),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: onShareImage,
                child: Row(
                  children: [
                    const Icon(Symbols.share_reviews),
                    const Gap(16),
                    Text('postShareImage').tr(),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.flag),
                    const Gap(16),
                    Text('flagPostAction').tr(),
                  ],
                ),
                onTap: () {
                  _flagPost(context);
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Symbols.report),
                    const Gap(16),
                    Text('report').tr(),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => _PostAbuseReportDialog(
                      data: data,
                    ),
                  ).then((value) {
                    if (value == true && context.mounted) {
                      context.showSnackbar('abuseReportSubmitted'.tr());
                    }
                  });
                },
              ),
            ],
          ),
      ],
    );
  }
}

class _PostContentBody extends StatelessWidget {
  final SnPost data;
  final bool isEnlarge;
  final bool isSelectable;

  const _PostContentBody({
    required this.data,
    this.isEnlarge = false,
    this.isSelectable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.body['content'] == null) return const SizedBox.shrink();
    final content = MarkdownTextContent(
      isAutoWarp: data.type == 'story',
      isEnlargeSticker:
          RegExp(r"^:([-\w]+):$").hasMatch(data.body['content'] ?? ''),
      textScaler: isEnlarge ? TextScaler.linear(1.1) : null,
      content: data.body['content'],
      attachments: data.preload?.attachments,
    );

    if (isSelectable) {
      return SelectionArea(child: content);
    }
    return content;
  }
}

class _PostQuoteContent extends StatelessWidget {
  final SnPost child;
  final bool isRelativeDate;

  const _PostQuoteContent({
    this.isRelativeDate = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            Column(
              children: [
                _PostContentHeader(
                  isAuthor: false,
                  data: child,
                  isCompact: true,
                  isRelativeDate: isRelativeDate,
                  showMenu: false,
                  onShare: () {},
                  onShareImage: () {},
                  onDeleted: () {},
                ).padding(bottom: 4),
                _PostContentBody(data: child),
                if (child.visibility > 0)
                  _PostVisibilityHint(data: child).padding(top: 4),
              ],
            ).padding(horizontal: 16),
            if (child.type != 'article' &&
                (child.preload?.attachments?.isNotEmpty ?? false))
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: AttachmentList(
                  data: child.preload!.attachments!,
                  maxHeight: 360,
                  minWidth: 640,
                  fit: BoxFit.contain,
                  gridded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ).padding(
                top: 8,
                bottom: 12,
              )
            else
              const Gap(8),
          ],
        ),
      ),
      onTap: () {
        GoRouter.of(context).pushNamed('postDetail', pathParameters: {
          'slug': child.id.toString(),
        });
      },
    );
  }
}

class _PostTagsList extends StatelessWidget {
  final SnPost data;

  const _PostTagsList({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: data.categories
              .map(
                (ele) => InkWell(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Symbols.category, size: 20),
                      const Gap(4),
                      Text(
                        'postCategory${ele.alias.capitalize()}'.trExists()
                            ? 'postCategory${ele.alias.capitalize()}'.tr()
                            : ele.alias,
                        style: GoogleFonts.robotoMono(),
                      ),
                    ],
                  ),
                  onTap: () {
                    GoRouter.of(context).pushNamed(
                      'postSearch',
                      queryParameters: {
                        'categories': ele.alias,
                      },
                    );
                  },
                ),
              )
              .toList(),
        ).opacity(0.8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: data.tags
              .map(
                (ele) => InkWell(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Symbols.label, size: 20),
                      const Gap(4),
                      Text(ele.alias, style: GoogleFonts.robotoMono()),
                    ],
                  ),
                  onTap: () {
                    GoRouter.of(context).pushNamed(
                      'postSearch',
                      queryParameters: {
                        'tags': ele.alias,
                      },
                    );
                  },
                ),
              )
              .toList(),
        ).opacity(0.8),
      ],
    );
  }
}

class _PostVisibilityHint extends StatelessWidget {
  final SnPost data;

  const _PostVisibilityHint({required this.data});

  static const List<IconData> kVisibilityIcons = [
    Symbols.public,
    Symbols.group,
    Symbols.person_check,
    Symbols.person_remove,
    Symbols.lock,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(kVisibilityIcons[data.visibility], size: 20),
        const Gap(4),
        Text(kPostVisibilityLevel[data.visibility] ?? 'postVisibilityAll').tr(),
      ],
    ).opacity(0.75);
  }
}

class _PostTruncatedHint extends StatelessWidget {
  final SnPost data;

  const _PostTruncatedHint({required this.data});

  static const int kHumanReadSpeed = 238;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          if (data.body['content_length'] != null)
            Row(
              children: [
                const Icon(Symbols.timer, size: 20),
                const Gap(4),
                Text('postReadEstimate').tr(args: [
                  '${Duration(
                    seconds: (data.body['content_length'] as num).toDouble() *
                        60 ~/
                        kHumanReadSpeed,
                  ).inSeconds}s',
                ]),
              ],
            ),
          if (data.body['content_length'] != null)
            Row(
              children: [
                const Icon(Symbols.height, size: 20),
                const Gap(4),
                Text(
                  'postTotalLength'.plural(data.body['content_length']),
                )
              ],
            ),
        ],
      ).opacity(0.75),
    );
  }
}

class _PostFeaturedComment extends StatefulWidget {
  final SnPost data;
  final double? maxWidth;

  const _PostFeaturedComment({required this.data, this.maxWidth});

  @override
  State<_PostFeaturedComment> createState() => _PostFeaturedCommentState();
}

class _PostFeaturedCommentState extends State<_PostFeaturedComment> {
  SnPost? _featuredComment;
  bool _isAnswer = false;

  Future<void> _fetchComments() async {
    // If this is a answered question, fetch the answer instead
    if (widget.data.type == 'question' && widget.data.body['answer'] != null) {
      final sn = context.read<SnNetworkProvider>();
      final resp =
          await sn.client.get('/cgi/co/posts/${widget.data.body['answer']}');
      _isAnswer = true;
      setState(() => _featuredComment = SnPost.fromJson(resp.data));
      return;
    }

    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get(
          '/cgi/co/posts/${widget.data.id}/replies/featured',
          queryParameters: {
            'take': 1,
          });
      setState(() => _featuredComment = SnPost.fromJson(resp.data[0]));
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.data.metric.replyCount > 0) {
      _fetchComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.metric.replyCount == 0) return const SizedBox.shrink();
    if (_featuredComment == null) return const SizedBox.shrink();

    final sn = context.read<SnNetworkProvider>();

    return AnimateWidgetExtensions(Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: _isAnswer
            ? Colors.green.withOpacity(0.5)
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          onTap: () {
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              builder: (context) => PostCommentListPopup(
                post: widget.data,
                commentCount: widget.data.metric.replyCount,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Gap(2),
                  Icon(_isAnswer ? Symbols.task_alt : Symbols.prompt_suggestion,
                      size: 20),
                  const Gap(10),
                  Text(
                    _isAnswer
                        ? 'postQuestionAnswerTitle'
                        : 'postFeaturedComment',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 15),
                  ).tr(),
                ],
              ),
              const Gap(4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: UniversalImage.provider(
                      sn.getAttachmentUrl(_featuredComment!.publisher.avatar),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: MarkdownTextContent(
                      content: _featuredComment!.body['content'],
                      isAutoWarp: true,
                    ),
                  )
                ],
              ),
            ],
          ).padding(horizontal: 16, vertical: 8),
        ),
      ),
    )).animate().fadeIn(duration: 300.ms, curve: Curves.easeInOut);
  }
}

class _PostAbuseReportDialog extends StatefulWidget {
  final SnPost data;

  const _PostAbuseReportDialog({required this.data});

  @override
  State<_PostAbuseReportDialog> createState() => _PostAbuseReportDialogState();
}

class _PostAbuseReportDialogState extends State<_PostAbuseReportDialog> {
  bool _isBusy = false;

  final _reasonController = TextEditingController();

  @override
  dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _performAction() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post(
        '/cgi/id/reports/abuse',
        data: {
          'resource': 'post:${widget.data.id}',
          'reason': _reasonController.text,
        },
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('postAbuseReport'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('postAbuseReportDescription'.tr()),
          const Gap(12),
          TextField(
            controller: _reasonController,
            maxLength: null,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'abuseReportReason'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isBusy ? null : () => Navigator.pop(context),
          child: Text('dialogDismiss').tr(),
        ),
        TextButton(
          onPressed: _isBusy ? null : _performAction,
          child: Text('submit').tr(),
        ),
      ],
    );
  }
}

class _PostGetInsightPopup extends StatefulWidget {
  final int postId;

  const _PostGetInsightPopup({required this.postId});

  @override
  State<_PostGetInsightPopup> createState() => _PostGetInsightPopupState();
}

class _PostGetInsightPopupState extends State<_PostGetInsightPopup> {
  String? _response;
  String? _thinkingProcess;

  Future<void> _fetchResponse() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/co/posts/${widget.postId}/insight',
          options: Options(
            sendTimeout: const Duration(minutes: 10),
            receiveTimeout: const Duration(minutes: 10),
          ));
      final out = resp.data['response'] as String;

      try {
        final document = XmlDocument.parse(out);
        _thinkingProcess = document.getElement('think')?.innerText.trim();
      } catch (_) {
        // ignore
      }

      RegExp cleanThinkingRegExp = RegExp(r'<think>[\s\S]*?</think>');
      setState(
          () => _response = out.replaceAll(cleanThinkingRegExp, '').trim());
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Symbols.book_4_spark, size: 24),
            const Gap(16),
            Text('postGetInsightTitle',
                    style: Theme.of(context).textTheme.titleLarge)
                .tr(),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        const Gap(4),
        Text('postGetInsightDescription',
                style: Theme.of(context).textTheme.bodySmall)
            .tr()
            .padding(horizontal: 20),
        const Gap(4),
        if (_response == null)
          Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_thinkingProcess != null && _thinkingProcess!.isNotEmpty)
                    ExpansionTile(
                      leading: const Icon(Symbols.info),
                      title: Text('aiThinkingProcess'.tr()),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                      collapsedBackgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                      minTileHeight: 32,
                      children: [
                        SelectableText(
                          _thinkingProcess!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontStyle: FontStyle.italic),
                        ).padding(horizontal: 20, vertical: 8),
                      ],
                    ).padding(vertical: 8),
                  SelectionArea(
                    child: MarkdownTextContent(
                      content: _response!,
                    ),
                  ).padding(horizontal: 20, top: 8),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PostVideoPlayer extends StatelessWidget {
  final SnPost data;

  const _PostVideoPlayer({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: AttachmentItem(
              data: data.preload!.video!, heroTag: 'post-video-${data.id}'),
        ),
      ),
    );
  }
}
