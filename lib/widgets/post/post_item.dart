import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:surface/providers/translation.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/types/post.dart';
import 'package:surface/types/reaction.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/account/badge.dart';
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

class OpenablePostItem extends StatelessWidget {
  final SnPost data;
  final bool showReactions;
  final bool showComments;
  final bool showMenu;
  final bool showFullPost;
  final bool showExpandableComments;
  final bool useReplace;
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
    this.showExpandableComments = false,
    this.useReplace = false,
    this.maxWidth,
    this.onChanged,
    this.onDeleted,
    this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Center(
        child: GestureDetector(
          child: PostItem(
            data: data,
            maxWidth: maxWidth,
            showComments: showComments,
            showFullPost: showFullPost,
            showExpandableComments: showExpandableComments,
            onChanged: onChanged,
            onDeleted: onDeleted,
            onSelectAnswer: onSelectAnswer,
          ),
          onTap: () {
            if (useReplace) {
              GoRouter.of(context)
                  .pushReplacementNamed('postDetail', pathParameters: {
                'slug': data.id.toString(),
              });
            } else {
              GoRouter.of(context).pushNamed('postDetail', pathParameters: {
                'slug': data.id.toString(),
              });
            }
          },
        ),
      ),
    );
  }
}

class PostItem extends StatefulWidget {
  final SnPost data;
  final bool showReactions;
  final bool showComments;
  final bool showViews;
  final bool showMenu;
  final bool showFullPost;
  final bool showAvatar;
  final bool showCompactAvatar;
  final bool showExpandableComments;
  final double? maxWidth;
  final Function(SnPost data)? onChanged;
  final Function()? onDeleted;
  final Function()? onSelectAnswer;

  const PostItem({
    super.key,
    required this.data,
    this.showReactions = true,
    this.showComments = true,
    this.showViews = true,
    this.showMenu = true,
    this.showFullPost = false,
    this.showAvatar = true,
    this.showCompactAvatar = false,
    this.showExpandableComments = false,
    this.maxWidth,
    this.onChanged,
    this.onDeleted,
    this.onSelectAnswer,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late String _displayText = widget.data.body['content'] ?? '';
  late String _displayTitle = widget.data.body['title'] ?? '';
  late String _displayDescription = widget.data.body['description'] ?? '';
  bool _isTranslated = false;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    final cfg = context.read<ConfigProvider>();
    if (cfg.autoTranslate) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _translateText();
      });
    }
  }

  @override
  void didUpdateWidget(covariant PostItem oldWidget) {
    _displayText = widget.data.body['content'] ?? '';
    _displayTitle = widget.data.body['title'] ?? '';
    _displayDescription = widget.data.body['description'] ?? '';
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _translateText() async {
    final ta = context.read<SnTranslator>();
    setState(() => _isTranslating = true);
    try {
      final to = EasyLocalization.of(context)!.locale.languageCode;
      final futures = List<Future<void>>.empty(growable: true);
      if (_displayTitle.isNotEmpty) {
        futures.add(ta.translate(_displayTitle, to: to).then((value) {
          _displayTitle = value;
        }));
      }
      if (_displayDescription.isNotEmpty) {
        futures.add(ta.translate(_displayDescription, to: to).then((value) {
          _displayDescription = value;
        }));
      }
      if (_displayText.isNotEmpty) {
        futures.add(ta.translate(_displayText, to: to).then((value) {
          _displayText = value;
        }));
      }
      await Future.wait(futures);
      _isTranslated = true;
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  void _onChanged(SnPost data) {
    if (widget.onChanged != null) widget.onChanged!(data);
  }

  void _doShare(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final url = 'https://solsynth.dev/posts/${widget.data.id}';
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
                child: PostShareImageWidget(data: widget.data),
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
          name: 'Solar Network Post #${widget.data.id}.png', file: imageFile);
    }

    await imageFile.delete();
  }

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();

    final ua = context.read<UserProvider>();
    final isAuthor =
        ua.isAuthorized && widget.data.publisher.accountId == ua.user?.id;
    final isParentAuthor = ua.isAuthorized &&
        widget.data.replyTo?.publisher.accountId == ua.user?.id;

    final displayableAttachments = widget.data.body['attachments']
        ?.map((e) => SnAttachment.fromJson(e))
        .cast<SnAttachment>()
        .where((ele) =>
            ele?.mediaType != SnMediaType.image ||
            widget.data.type != 'article')
        .toList();

    final cfg = context.read<ConfigProvider>();

    var attachmentSize = math.min(
        MediaQuery.of(context).size.width, widget.maxWidth ?? double.infinity);
    if ((widget.data.body['attachments']?.length ?? 0) > 1) {
      attachmentSize -= 80;
    }

    if (widget.showFullPost) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth ?? double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.showAvatar)
                      _PostAvatar(
                        data: widget.data,
                        isCompact: false,
                      ),
                    if (widget.showAvatar) const Gap(12),
                    Expanded(
                      child: Row(
                        children: [
                          if (widget.showCompactAvatar)
                            _PostAvatar(
                              data: widget.data,
                              isCompact: true,
                            ),
                          if (widget.showAvatar) const Gap(8),
                          _PostContentHeader(
                            isRelativeDate: !widget.showFullPost,
                            isCompact: false,
                            data: widget.data,
                          ),
                        ],
                      ),
                    ),
                    _PostActionPopup(
                      data: widget.data,
                      isAuthor: isAuthor,
                      isParentAuthor: isParentAuthor,
                      onShare: () => _doShare(context),
                      onShareImage: () => _doShareViaPicture(context),
                      onSelectAnswer: widget.onSelectAnswer,
                      onDeleted: () {
                        widget.onDeleted?.call();
                      },
                      onTranslate: () {
                        _translateText();
                      },
                    ),
                  ],
                ),
                const Gap(8),
                if (widget.data.body['thumbnail'] != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        child: AutoResizeUniversalImage(
                          sn.getAttachmentUrl(
                            widget.data.body['thumbnail']['rid'],
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                if (widget.data.body['video'] != null)
                  _PostVideoPlayer(data: widget.data).padding(bottom: 8),
                if (widget.data.type == 'question')
                  _PostQuestionHint(data: widget.data).padding(bottom: 8),
                if (_displayDescription.isNotEmpty || _displayTitle.isNotEmpty)
                  _PostHeadline(
                    title: _displayTitle,
                    description: _displayDescription,
                    data: widget.data,
                    isEnlarge:
                        widget.data.type == 'article' && widget.showFullPost,
                  ).padding(bottom: 8),
                if (widget.data.type == 'article' && !widget.showFullPost)
                  Text('postArticle')
                      .tr()
                      .fontSize(13)
                      .opacity(0.75)
                      .padding(bottom: 8),
                if ((_displayText.isNotEmpty) &&
                    (widget.showFullPost || widget.data.type != 'article'))
                  _PostContentBody(
                    text: _displayText,
                    data: widget.data,
                    isSelectable: widget.showFullPost,
                    isEnlarge:
                        widget.data.type == 'article' && widget.showFullPost,
                  ).padding(bottom: 6),
                if (widget.data.visibility > 0)
                  _PostVisibilityHint(data: widget.data).padding(
                    vertical: 4,
                  ),
                if (widget.data.body['content_truncated'] == true)
                  _PostTruncatedHint(data: widget.data).padding(
                    vertical: 4,
                  ),
                if (widget.data.tags.isNotEmpty)
                  _PostTagsList(data: widget.data).padding(top: 4, bottom: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    if (widget.showViews)
                      Row(
                        children: [
                          Icon(Symbols.play_circle, size: 20),
                          const Gap(4),
                          Text('postViews').plural(widget.data.totalViews),
                        ],
                      ).opacity(0.75),
                    if (_isTranslating)
                      AnimateWidgetExtensions(Row(
                        children: [
                          Icon(Symbols.translate, size: 20),
                          const Gap(4),
                          Text('translating').tr(),
                        ],
                      ))
                          .animate(onPlay: (e) => e.repeat())
                          .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                          .then()
                          .fadeOut(
                            duration: 500.ms,
                            delay: 1000.ms,
                            curve: Curves.easeIn,
                          ),
                    if (_isTranslated)
                      InkWell(
                        child: Row(
                          children: [
                            Icon(Symbols.translate, size: 20),
                            const Gap(4),
                            Text('translated').tr(),
                          ],
                        ).opacity(0.75),
                        onTap: () {
                          setState(() {
                            _displayText = widget.data.body['content'] ?? '';
                            _displayTitle = widget.data.body['title'] ?? '';
                            _displayDescription =
                                widget.data.body['description'] ?? '';
                            _isTranslated = false;
                          });
                        },
                      ),
                    if (widget.data.repostTo != null)
                      _PostQuoteContent(child: widget.data.repostTo!).padding(
                        top: 4,
                        bottom:
                            widget.data.body['attachments'].isNotEmpty ?? false
                                ? 12
                                : 0,
                      ),
                  ],
                ).padding(
                  bottom: widget.showViews || _isTranslated || _isTranslating
                      ? 8
                      : 0,
                ),
              ],
            ).padding(horizontal: 12, top: 8),
          ),
          if (displayableAttachments?.isNotEmpty ?? false)
            AttachmentList(
              data: displayableAttachments!,
              bordered: true,
              maxHeight: widget.showFullPost ? null : 480,
              minWidth: attachmentSize,
              maxWidth: attachmentSize,
              fit: widget.showFullPost ? BoxFit.cover : BoxFit.contain,
              padding: EdgeInsets.only(left: 12, right: 12),
            ),
          if (widget.data.poll != null)
            StyledWidget(Container(
              constraints:
                  BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
              child: PostPoll(poll: widget.data.poll!),
            ))
                .padding(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: 4,
                )
                .center(),
          if (widget.data.body['content'] != null &&
              (cfg.prefs.getBool(kAppExpandPostLink) ?? true))
            LinkPreviewWidget(
              text: widget.data.body['content'],
            ).padding(left: 12, right: 4),
          if (widget.showExpandableComments)
            _PostCommentIntent(
              data: widget.data,
              showAvatar: widget.showAvatar,
              maxWidth: widget.maxWidth ?? double.infinity,
            ).padding(left: 12, right: 12)
          else
            _PostFeaturedComment(data: widget.data, maxWidth: widget.maxWidth)
                .padding(left: 12, right: 12),
          if (widget.showReactions)
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: (widget.maxWidth ?? double.infinity) + 24,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _PostReactionList(
                    data: widget.data,
                    padding: EdgeInsets.only(left: 12, right: 12),
                    onChanged: _onChanged,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints:
              BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showAvatar)
                    _PostAvatar(
                      data: widget.data,
                      isCompact: false,
                    ),
                  if (widget.showAvatar) const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (widget.showCompactAvatar)
                                    _PostAvatar(
                                      data: widget.data,
                                      isCompact: true,
                                    ),
                                  if (widget.showCompactAvatar) const Gap(8),
                                  Expanded(
                                    child: _PostContentHeader(
                                      isRelativeDate: !widget.showFullPost,
                                      isCompact: true,
                                      data: widget.data,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _PostActionPopup(
                              data: widget.data,
                              isAuthor: isAuthor,
                              isParentAuthor: isParentAuthor,
                              onShare: () => _doShare(context),
                              onShareImage: () => _doShareViaPicture(context),
                              onSelectAnswer: widget.onSelectAnswer,
                              onDeleted: () {
                                widget.onDeleted?.call();
                              },
                              onTranslate: () {
                                _translateText();
                              },
                            ),
                          ],
                        ).padding(bottom: widget.showCompactAvatar ? 4 : 0),
                        if (widget.data.body['thumbnail'] != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                child: AutoResizeUniversalImage(
                                  sn.getAttachmentUrl(
                                    widget.data.body['thumbnail']['rid'],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        if (widget.data.body['video'] != null)
                          _PostVideoPlayer(data: widget.data)
                              .padding(bottom: 8),
                        if (widget.data.type == 'question')
                          _PostQuestionHint(data: widget.data)
                              .padding(bottom: 8),
                        if (_displayDescription.isNotEmpty ||
                            _displayTitle.isNotEmpty)
                          _PostHeadline(
                            title: _displayTitle,
                            description: _displayDescription,
                            data: widget.data,
                            isEnlarge: widget.data.type == 'article' &&
                                widget.showFullPost,
                          ).padding(bottom: 8),
                        if (widget.data.type == 'article' &&
                            !widget.showFullPost)
                          Text('postArticle')
                              .tr()
                              .fontSize(13)
                              .opacity(0.75)
                              .padding(bottom: 8),
                        if ((_displayText.isNotEmpty) &&
                            (widget.showFullPost ||
                                widget.data.type != 'article'))
                          _PostContentBody(
                            text: _displayText,
                            data: widget.data,
                            isSelectable: widget.showFullPost,
                            isEnlarge: widget.data.type == 'article' &&
                                widget.showFullPost,
                          ).padding(bottom: 6),
                        if (widget.data.visibility > 0)
                          _PostVisibilityHint(data: widget.data).padding(
                            vertical: 4,
                          ),
                        if (widget.data.body['content_truncated'] == true)
                          _PostTruncatedHint(data: widget.data).padding(
                            vertical: 4,
                          ),
                        if (widget.data.tags.isNotEmpty)
                          _PostTagsList(data: widget.data)
                              .padding(top: 4, bottom: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            if (widget.showViews)
                              Row(
                                children: [
                                  Icon(Symbols.play_circle, size: 20),
                                  const Gap(4),
                                  Text('postViews')
                                      .plural(widget.data.totalViews),
                                ],
                              ).opacity(0.75),
                            if (_isTranslating)
                              AnimateWidgetExtensions(Row(
                                children: [
                                  Icon(Symbols.translate, size: 20),
                                  const Gap(4),
                                  Text('translating').tr(),
                                ],
                              ))
                                  .animate(onPlay: (e) => e.repeat())
                                  .fadeIn(
                                      duration: 500.ms, curve: Curves.easeOut)
                                  .then()
                                  .fadeOut(
                                    duration: 500.ms,
                                    delay: 1000.ms,
                                    curve: Curves.easeIn,
                                  ),
                            if (_isTranslated)
                              InkWell(
                                child: Row(
                                  children: [
                                    Icon(Symbols.translate, size: 20),
                                    const Gap(4),
                                    Text('translated').tr(),
                                  ],
                                ).opacity(0.75),
                                onTap: () {
                                  setState(() {
                                    _displayText =
                                        widget.data.body['content'] ?? '';
                                    _displayTitle =
                                        widget.data.body['title'] ?? '';
                                    _displayDescription =
                                        widget.data.body['description'] ?? '';
                                    _isTranslated = false;
                                  });
                                },
                              ),
                          ],
                        ).padding(
                          bottom: (widget.showViews ||
                                      _isTranslated ||
                                      _isTranslating) &&
                                  (widget.data.repostTo != null ||
                                      (widget.data.body['attachments']
                                              ?.isNotEmpty ??
                                          false))
                              ? 8
                              : 0,
                        ),
                        if (widget.data.repostTo != null)
                          _PostQuoteContent(child: widget.data.repostTo!)
                              .padding(
                            bottom:
                                (widget.data.body['attachments']?.isNotEmpty ??
                                        false)
                                    ? 8
                                    : 0,
                          ),
                      ],
                    ),
                  )
                ],
              ).padding(horizontal: 12, top: 8),
            ],
          ),
        ),
        if (displayableAttachments?.isNotEmpty ?? false)
          AttachmentList(
            data: displayableAttachments!,
            bordered: true,
            maxHeight: widget.showFullPost ? null : 480,
            minWidth: attachmentSize,
            maxWidth: attachmentSize,
            fit: widget.showFullPost ? BoxFit.cover : BoxFit.contain,
            padding:
                EdgeInsets.only(left: widget.showAvatar ? 60 : 12, right: 12),
          ),
        if (widget.data.poll != null)
          PostPoll(poll: widget.data.poll!).padding(
            left: widget.showAvatar ? 60 : 12,
            right: 12,
            top: 12,
            bottom: 4,
          ),
        if (widget.data.body['content'] != null &&
            (cfg.prefs.getBool(kAppExpandPostLink) ?? true))
          LinkPreviewWidget(
            text: widget.data.body['content'],
          ).padding(left: widget.showAvatar ? 60 : 12, right: 4),
        if (widget.showExpandableComments)
          _PostCommentIntent(
            data: widget.data,
            maxWidth: (widget.maxWidth ?? double.infinity) -
                (widget.showAvatar ? 72 : 24),
            showAvatar: widget.showAvatar,
          ).padding(left: widget.showAvatar ? 60 : 12, right: 12)
        else if (widget.showComments)
          _PostFeaturedComment(data: widget.data, maxWidth: widget.maxWidth)
              .padding(left: widget.showAvatar ? 60 : 12, right: 12),
        if (widget.showReactions)
          Container(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth ?? double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _PostReactionList(
                data: widget.data,
                padding: EdgeInsets.only(
                  left: widget.showAvatar ? 60 : 12,
                  right: 12,
                ),
                onChanged: _onChanged,
              ),
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
          if (data.body['thumbnail'] != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: AutoResizeUniversalImage(
                  sn.getAttachmentUrl(data.body['thumbnail']['rid']),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ).padding(bottom: 8),
          Row(
            children: [
              _PostAvatar(
                data: data,
                isCompact: false,
                filterQuality: FilterQuality.high,
              ),
              const Gap(12),
              _PostContentHeader(
                data: data,
                isRelativeDate: false,
              ).padding(horizontal: 16, bottom: 8),
            ],
          ),
          if (data.type == 'question')
            _PostQuestionHint(data: data).padding(horizontal: 16, bottom: 8),
          _PostHeadline(
            data: data,
            isEnlarge: data.type == 'article',
          ).padding(horizontal: 16, bottom: 8),
          if (data.body['content']?.isNotEmpty ?? false)
            _PostContentBody(
              text: data.body['content'] ?? '',
              data: data,
              isEnlarge: data.type == 'article',
            ).padding(horizontal: 16, bottom: 8),
          if (data.repostTo != null)
            _PostQuoteContent(
              child: data.repostTo!,
              isRelativeDate: false,
            ).padding(horizontal: 16, bottom: 8),
          if (data.type != 'article' &&
              (data.body['attachments']?.isNotEmpty ?? false))
            StyledWidget(AttachmentList(
              data: data.body['attachments']
                      ?.map((e) => SnAttachment.fromJson(e))
                      .cast<SnAttachment>()
                      .toList() ??
                  [],
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

class _PostReactionList extends StatefulWidget {
  final SnPost data;
  final EdgeInsets? padding;
  final Function(SnPost) onChanged;
  const _PostReactionList({
    required this.data,
    this.padding,
    required this.onChanged,
  });

  @override
  State<_PostReactionList> createState() => _PostReactionListState();
}

class _PostReactionListState extends State<_PostReactionList> {
  bool _isSubmitting = false;
  late int _totalUpvote = widget.data.totalUpvote;
  late int _totalDownvote = widget.data.totalDownvote;
  late Map<String, int> _reactions = Map.from(widget.data.metric.reactionList);

  Future<void> _reactPost(String symbol, int attitude) async {
    if (_isSubmitting) return;

    final sn = context.read<SnNetworkProvider>();

    try {
      setState(() => _isSubmitting = true);
      final resp = await sn.client.post(
        '/cgi/co/posts/${widget.data.id}/react',
        data: {
          'symbol': symbol,
          'attitude': attitude,
        },
      );
      if (resp.statusCode == 201) {
        _reactions[symbol] = (_reactions[symbol] ?? 0) + 1;
        widget.onChanged(
          widget.data.copyWith(
            metric: widget.data.metric.copyWith(reactionList: _reactions),
          ),
        );
      } else if (resp.statusCode == 204) {
        _reactions[symbol] = (_reactions[symbol] ?? 0) - 1;
        widget.onChanged(
          widget.data.copyWith(
            metric: widget.data.metric.copyWith(reactionList: _reactions),
          ),
        );
      }
      if (attitude == 1) {
        setState(() => _totalUpvote += 1);
      } else if (attitude == 2) {
        setState(() => _totalDownvote += 1);
      }
      HapticFeedback.heavyImpact();
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: widget.padding,
        itemCount: widget.data.metric.reactionList.length + 1,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == 0) {
            final String? mostTypicalReaction = _reactions.isNotEmpty
                ? _reactions.entries
                    .reduce((a, b) => a.value > b.value ? a : b)
                    .key
                : null;

            return Row(
              children: [
                ActionChip(
                  avatar: (kTemplateReactions[mostTypicalReaction] == null)
                      ? Icon(Symbols.add_reaction, size: 20)
                      : Text(
                          kTemplateReactions[mostTypicalReaction]!.icon,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                  label: (_totalUpvote > 0 && _totalUpvote >= _totalDownvote)
                      ? Text('postReactionUpvote').plural(_totalUpvote)
                      : (_totalDownvote > 0)
                          ? Text('postReactionDownvote').plural(_totalDownvote)
                          : Text('postReact').tr(),
                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => PostReactionPopup(
                        data: widget.data,
                        onChanged: (value, attr, delta) {
                          final metric =
                              widget.data.metric.copyWith(reactionList: value);
                          if (attr == 1) {
                            _totalUpvote += delta;
                          } else if (attr == 2) {
                            _totalDownvote += delta;
                          }
                          _reactions = Map.from(metric.reactionList);
                          widget.onChanged(widget.data.copyWith(
                            totalUpvote: attr == 1
                                ? widget.data.totalUpvote + delta
                                : widget.data.totalUpvote,
                            totalDownvote: attr == 2
                                ? widget.data.totalDownvote + delta
                                : widget.data.totalDownvote,
                            metric: metric,
                          ));
                        },
                      ),
                    );
                  },
                ),
                if (_reactions.isNotEmpty) const Gap(8),
                if (_reactions.isNotEmpty)
                  SizedBox(
                    width: 1,
                    height: 20,
                    child: const VerticalDivider(width: 1),
                  ),
                if (_reactions.isNotEmpty) const Gap(4),
              ],
            );
          }

          final ele = _reactions.entries.elementAt(index - 1);
          return ActionChip(
            avatar: Text(kTemplateReactions[ele.key]!.icon),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Text(ele.key),
                Text('x${ele.value}').bold(),
              ],
            ),
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            onPressed: _isSubmitting
                ? null
                : () {
                    _reactPost(ele.key, kTemplateReactions[ele.key]!.attitude);
                  },
          );
        },
        separatorBuilder: (_, __) => const Gap(4),
      ),
    );
  }
}

class _PostHeadline extends StatelessWidget {
  final String? title;
  final String? description;
  final SnPost data;
  final bool isEnlarge;

  const _PostHeadline({
    this.title,
    this.description,
    required this.data,
    this.isEnlarge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEnlarge) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.body['title'] != null || (title?.isNotEmpty ?? false))
            Text(
              title ?? data.body['title'],
              style: Theme.of(context).textTheme.titleMedium,
              textScaler: TextScaler.linear(1.4),
            ),
          if (data.body['description'] != null ||
              (description?.isNotEmpty ?? false))
            Text(
              description ?? data.body['description'],
              style: Theme.of(context).textTheme.bodyMedium,
              textScaler: TextScaler.linear(1.1),
            ),
          if (data.body['description'] != null ||
              (description?.isNotEmpty ?? false))
            const Gap(8)
          else
            const Gap(4),
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
        if (data.body['title'] != null || (title?.isNotEmpty ?? false))
          Text(
            title ?? data.body['title'],
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (data.body['description'] != null ||
            (description?.isNotEmpty ?? false))
          Text(
            description ?? data.body['description'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }
}

class _PostAvatar extends StatelessWidget {
  final SnPost data;
  final bool isCompact;
  final FilterQuality? filterQuality;
  const _PostAvatar({
    required this.data,
    required this.isCompact,
    this.filterQuality,
  });

  @override
  Widget build(BuildContext context) {
    final ud = context.read<UserDirectoryProvider>();
    final user = data.publisher.type == 0
        ? ud.getFromCache(data.publisher.accountId)
        : null;

    return GestureDetector(
      child: data.realm == null
          ? AccountImage(
              filterQuality: filterQuality,
              content: data.publisher.avatar,
              radius: isCompact ? 12 : 20,
              borderRadius: data.publisher.type == 1 ? (isCompact ? 4 : 8) : 20,
              badge: (user?.badges.isNotEmpty ?? false)
                  ? AccountBadge(
                      badge: user!.badges.first,
                      radius: 16,
                      padding: EdgeInsets.all(2),
                    )
                  : null,
            )
          : AccountImage(
              filterQuality: filterQuality,
              content: data.realm!.avatar,
              radius: isCompact ? 12 : 20,
              borderRadius: isCompact ? 4 : 8,
              badgeOffset: Offset(-6, -4),
              badge: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: AccountImage(
                  content: data.publisher.avatar,
                  radius: 10,
                ),
              ),
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
    );
  }
}

class _PostActionPopup extends StatelessWidget {
  final SnPost data;
  final bool isAuthor;
  final bool isParentAuthor;
  final Function onDeleted;
  final Function() onShare, onShareImage;
  final Function()? onSelectAnswer;
  final Function()? onTranslate;
  const _PostActionPopup({
    required this.data,
    required this.isAuthor,
    required this.isParentAuthor,
    required this.onDeleted,
    required this.onShare,
    required this.onShareImage,
    this.onTranslate,
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
      onDeleted.call();
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
    return SizedBox(
      height: 20,
      child: PopupMenuButton(
        icon: const Icon(Symbols.more_horiz, size: 20),
        style: const ButtonStyle(
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
        ),
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          if (onTranslate != null)
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Symbols.translate),
                  const Gap(16),
                  Text('translate').tr(),
                ],
              ),
              onTap: () {
                onTranslate?.call();
              },
            ),
          if (onTranslate != null) PopupMenuDivider(),
          if (isParentAuthor && onSelectAnswer != null)
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
          if (isParentAuthor && onSelectAnswer != null) PopupMenuDivider(),
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
    );
  }
}

class _PostContentHeader extends StatelessWidget {
  final SnPost data;
  final bool isCompact;
  final bool isRelativeDate;

  const _PostContentHeader({
    required this.data,
    this.isCompact = false,
    this.isRelativeDate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Row(
        children: [
          Flexible(
            child: Text(
              data.publisher.nick,
              maxLines: 1,
            ).bold(),
          ),
          const Gap(4),
          Flexible(
            child: Text(
              isRelativeDate
                  ? RelativeTime(context)
                      .format((data.publishedAt ?? data.createdAt).toLocal())
                  : DateFormat('y/M/d HH:mm')
                      .format((data.publishedAt ?? data.createdAt).toLocal()),
              maxLines: 1,
              overflow: TextOverflow.fade,
            ).fontSize(13).opacity(0.8),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(data.publisher.nick).bold(),
              if (data.realm != null)
                const Icon(Symbols.arrow_right, size: 16)
                    .padding(horizontal: 2)
                    .opacity(0.5),
              if (data.realm != null) Text(data.realm!.name),
            ],
          ),
          Row(
            children: [
              Text(
                '@${data.publisher.name}',
                maxLines: 1,
              ).fontSize(13),
              const Gap(4),
              Text(
                isRelativeDate
                    ? RelativeTime(context)
                        .format((data.publishedAt ?? data.createdAt).toLocal())
                    : DateFormat('y/M/d HH:mm')
                        .format((data.publishedAt ?? data.createdAt).toLocal()),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ).fontSize(13),
            ],
          ).opacity(0.8),
        ],
      );
    }
  }
}

class _PostContentBody extends StatelessWidget {
  final String text;
  final SnPost data;
  final bool isEnlarge;
  final bool isSelectable;

  const _PostContentBody({
    required this.text,
    required this.data,
    this.isEnlarge = false,
    this.isSelectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = MarkdownTextContent(
      isAutoWarp: data.type == 'story',
      isEnlargeSticker:
          RegExp(r"^:([-\w]+):$").hasMatch(data.body['content'] ?? ''),
      textScaler: isEnlarge ? TextScaler.linear(1.1) : null,
      content: text,
      attachments: data.body['attachments']
              ?.map((e) => SnAttachment.fromJson(e))
              .cast<SnAttachment>()
              .toList() ??
          [],
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
                Row(
                  children: [
                    _PostAvatar(
                      data: child,
                      isCompact: true,
                    ),
                    const Gap(8),
                    _PostContentHeader(
                      data: child,
                      isCompact: true,
                      isRelativeDate: isRelativeDate,
                    ),
                  ],
                ).padding(bottom: 4),
                _PostContentBody(
                  data: child,
                  text: child.body['content'] ?? '',
                ),
                if (child.visibility > 0)
                  _PostVisibilityHint(data: child).padding(top: 4),
              ],
            ).padding(horizontal: 16),
            if (child.type != 'article' &&
                (child.body['attachments']?.isNotEmpty ?? false))
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: AttachmentList(
                  data: child.body['attachments']!,
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

class _PostCommentIntent extends StatefulWidget {
  final SnPost data;
  final bool showAvatar;
  final double maxWidth;
  const _PostCommentIntent({
    required this.data,
    this.showAvatar = false,
    required this.maxWidth,
  });

  @override
  State<_PostCommentIntent> createState() => _PostCommentIntentState();
}

class _PostCommentIntentState extends State<_PostCommentIntent> {
  bool _isBusy = false;
  int? _totalCount;
  final List<SnPost> _comments = List.empty(growable: true);

  bool get _isAllLoaded =>
      _totalCount != null && _comments.length >= _totalCount!;

  Future<void> _fetchComments() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get(
        '/cgi/co/posts/${widget.data.id}/replies',
        queryParameters: {
          'take': 10,
          'offset': _comments.length,
        },
      );
      _totalCount = resp.data['count'];
      _comments.addAll(
        resp.data['data'].map((ele) => SnPost.fromJson(ele)).cast<SnPost>(),
      );
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: Column(
        children: [
          if (_comments.isNotEmpty)
            Card(
              elevation: 4,
              margin: EdgeInsets.zero,
              child: Column(
                spacing: 8,
                children: [
                  for (final ele in _comments)
                    InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: PostItem(
                        data: ele,
                        showAvatar: false,
                        showCompactAvatar: true,
                        showExpandableComments: true,
                        showReactions: false,
                        showViews: false,
                        maxWidth: double.infinity,
                      ).padding(vertical: 8, left: 6),
                      onTap: () {
                        GoRouter.of(context).pushNamed(
                          'postDetail',
                          pathParameters: {'slug': ele.id.toString()},
                          extra: ele,
                        );
                      },
                    ),
                ],
              ),
            ).padding(vertical: 8),
          Row(
            children: [
              Transform.flip(
                flipX: true,
                child: const Icon(Symbols.comment, size: 20),
              ),
              const Gap(4),
              Text(
                  'postCommentsDetailed'.plural(widget.data.metric.replyCount)),
              if (widget.data.metric.replyCount > 0 && !_isAllLoaded)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: IconButton(
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Symbols.expand_more, size: 18),
                    onPressed: _isBusy
                        ? null
                        : () {
                            _fetchComments();
                          },
                  ),
                ).padding(left: 8),
            ],
          ).opacity(0.75).padding(horizontal: widget.showAvatar ? 4 : 0),
        ],
      ),
    );
  }
}

class _PostFeaturedComment extends StatefulWidget {
  final SnPost data;
  final double? maxWidth;

  const _PostFeaturedComment({
    required this.data,
    this.maxWidth,
  });

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
    final ua = context.read<UserProvider>();

    return Container(
      constraints: BoxConstraints(maxWidth: widget.maxWidth ?? double.infinity),
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      child: Material(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: _isAnswer
            ? Colors.green.withOpacity(0.5)
            : Theme.of(context).colorScheme.surfaceContainer,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          onTap: () {
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
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
                  Transform.flip(
                    flipX: !_isAnswer,
                    child: Icon(
                      _isAnswer ? Symbols.task_alt : Symbols.reply,
                      size: 20,
                    ),
                  ),
                  const Gap(10),
                  Text(
                    _isAnswer
                        ? 'postQuestionAnswerTitle'.tr()
                        : 'postComments'.plural(widget.data.metric.replyCount),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontSize: 15),
                  ),
                ],
              ),
              const Gap(4),
              if (_featuredComment != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AccountImage(
                      content: _featuredComment!.publisher.avatar,
                      radius: 12,
                    ),
                    const Gap(8),
                    Expanded(
                      child: MarkdownTextContent(
                        content: _featuredComment!.body['content'],
                        isAutoWarp: true,
                      ),
                    )
                  ],
                )
              else
                Row(
                  children: [
                    AccountImage(
                      content: ua.user?.avatar,
                      radius: 12,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16),
                          ),
                        ),
                        child: Text('postCommentAdd').tr(),
                      ),
                    ),
                  ],
                ),
            ],
          ).padding(horizontal: 16, vertical: 8),
        ),
      ),
    );
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
            data: data.body['video'],
            heroTag: 'post-video-${data.id}',
          ),
        ),
      ),
    );
  }
}
