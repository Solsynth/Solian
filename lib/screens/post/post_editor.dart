import 'dart:io';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/types/post.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/attachment/attachment_input.dart';
import 'package:surface/widgets/attachment/attachment_item.dart';
import 'package:surface/widgets/attachment/pending_attachment_alt.dart';
import 'package:surface/widgets/attachment/pending_attachment_boost.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/markdown_content.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_media_pending_list.dart';
import 'package:surface/widgets/post/post_meta_editor.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:provider/provider.dart';
import 'package:surface/widgets/post/post_poll_editor.dart';
import 'package:uuid/uuid.dart';

import '../../providers/sn_realm.dart';

class PostEditorExtra {
  final String? text;
  final String? title;
  final String? description;
  final List<PostWriteMedia>? attachments;

  const PostEditorExtra({
    this.text,
    this.title,
    this.description,
    this.attachments,
  });
}

class PostEditorScreen extends StatefulWidget {
  final String mode;
  final int? postEditId;
  final int? postReplyId;
  final int? postRepostId;
  final PostEditorExtra? extraProps;

  const PostEditorScreen({
    super.key,
    required this.mode,
    required this.postEditId,
    required this.postReplyId,
    required this.postRepostId,
    this.extraProps,
  });

  @override
  State<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  late final PostWriteController _writeController = PostWriteController(
    doLoadFromTemporary: widget.postEditId == null,
  );

  bool _isFetching = false;

  bool get _isLoading => _isFetching || _writeController.isLoading;

  List<SnPublisher>? _publishers;
  List<SnRealm>? _realms;

  Future<void> _fetchPublishers() async {
    setState(() => _isFetching = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      final config = context.read<ConfigProvider>();
      final resp = await sn.client.get('/cgi/co/publishers/me');
      _publishers = List<SnPublisher>.from(
        resp.data?.map((e) => SnPublisher.fromJson(e)) ?? [],
      );
      final beforeId = config.prefs.getInt('int_last_publisher_id');
      _writeController.setPublisher(
          _publishers?.where((ele) => ele.id == beforeId).firstOrNull ??
              _publishers?.firstOrNull);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isFetching = false);
    }
  }

  Future<void> _fetchRealms() async {
    final rels = context.read<SnRealmProvider>();
    try {
      _realms = await rels.listAvailableRealms();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  void _updateMeta() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PostMetaEditor(controller: _writeController),
      useRootNavigator: true,
    );
  }

  final HotKey _pasteHotKey = HotKey(
    key: PhysicalKeyboardKey.keyV,
    modifiers: [
      (!kIsWeb && Platform.isMacOS)
          ? HotKeyModifier.meta
          : HotKeyModifier.control
    ],
    scope: HotKeyScope.inapp,
  );

  void _registerHotKey() {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return;
    hotKeyManager.register(_pasteHotKey, keyDownHandler: (_) async {
      final imageBytes = await Pasteboard.image;
      if (imageBytes == null) return;
      _writeController.addAttachments([
        PostWriteMedia.fromBytes(
          imageBytes,
          'attachmentPastedImage'.tr(),
          SnMediaType.image,
        ),
      ]);
      setState(() {});
    });
  }

  void _showPublisherPopup() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PostPublisherPopup(
        controller: _writeController,
        publishers: _publishers,
        onUpdate: () {
          _fetchPublishers();
        },
      ),
    );
  }

  void _showRealmPopup() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PostRealmPopup(
        controller: _writeController,
        realms: _realms,
        onUpdate: () {
          _fetchRealms();
        },
      ),
    );
  }

  void _showPollEditorDialog() async {
    final poll = await showDialog<dynamic>(
      context: context,
      builder: (context) => PollEditorDialog(
        poll: _writeController.poll,
      ),
    );
    if (poll == null) return;
    if (!mounted) return;

    if (poll == false) {
      _writeController.setPoll(null);
    } else {
      _writeController.setPoll(poll);
    }
  }

  void _showThumbnailEditorDialog() async {
    final attachment = await showDialog<SnAttachment?>(
      context: context,
      builder: (context) => AttachmentInputDialog(
        title: 'postThumbnail'.tr(),
        pool: 'interactive',
        mediaType: SnMediaType.image,
      ),
    );
    if (!context.mounted) return;
    if (attachment == null) return;
    _writeController.setThumbnail(attachment);
  }

  @override
  void dispose() {
    _writeController.dispose();
    if (!kIsWeb && !(Platform.isAndroid || Platform.isIOS)) {
      hotKeyManager.unregister(_pasteHotKey);
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _registerHotKey();
    if (!PostWriteController.kTitleMap.keys.contains(widget.mode)) {
      context.showErrorDialog('Unknown post type');
      Navigator.pop(context);
    } else {
      _writeController.setMode(widget.mode);
    }
    _fetchRealms();
    _fetchPublishers();
    _writeController.fetchRelatedPost(
      context,
      editing: widget.postEditId,
      replying: widget.postReplyId,
      reposting: widget.postRepostId,
    );
    if (widget.extraProps != null) {
      _writeController.contentController.text = widget.extraProps!.text ?? '';
      _writeController.titleController.text = widget.extraProps!.title ?? '';
      _writeController.descriptionController.text =
          widget.extraProps!.description ?? '';
      _writeController.addAttachments(widget.extraProps!.attachments ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _writeController,
      builder: (context, _) {
        return AppScaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: [
                TextSpan(
                  text: _writeController.title.isNotEmpty
                      ? _writeController.title
                      : 'untitled'.tr(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).appBarTheme.foregroundColor!,
                      ),
                ),
                const TextSpan(text: '\n'),
                TextSpan(
                  text: PostWriteController.kTitleMap[widget.mode]!.tr(),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).appBarTheme.foregroundColor!,
                      ),
                ),
              ]),
              maxLines: 2,
            ),
            actions: [
              IconButton(
                icon: const Icon(Symbols.tune),
                onPressed: _writeController.isBusy ? null : _updateMeta,
              ),
              const Gap(8),
            ],
          ),
          body: Column(
            children: [
              if (_writeController.editingPost != null)
                Container(
                  padding: const EdgeInsets.only(
                      top: 4, bottom: 4, left: 20, right: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1 / MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit, size: 16),
                      const Gap(10),
                      Text('postEditingNotice').tr(args: [
                        '@${_writeController.editingPost!.publisher.name}'
                      ]),
                    ],
                  ),
                ),
              if (_writeController.replyingPost != null)
                Container(
                  padding: const EdgeInsets.only(
                      top: 4, bottom: 4, left: 20, right: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1 / MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Symbols.reply, size: 16),
                      const Gap(10),
                      Text('@${_writeController.replyingPost!.publisher.name}')
                          .bold(),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          _writeController.replyingPost!.body['content'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_writeController.repostingPost != null)
                Container(
                  padding: const EdgeInsets.only(
                      top: 4, bottom: 4, left: 20, right: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1 / MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Symbols.forward, size: 16),
                      const Gap(10),
                      Text('@${_writeController.repostingPost!.publisher.name}')
                          .bold(),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          _writeController.repostingPost!.body['content'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 160),
                      child: StyledWidget(switch (_writeController.mode) {
                        'stories' => _PostStoryEditor(
                            controller: _writeController,
                            onTapPublisher: _showPublisherPopup,
                            onTapRealm: _showRealmPopup,
                          ),
                        'articles' => _PostArticleEditor(
                            controller: _writeController,
                            onTapPublisher: _showPublisherPopup,
                            onTapRealm: _showRealmPopup,
                          ),
                        'questions' => _PostQuestionEditor(
                            controller: _writeController,
                            onTapPublisher: _showPublisherPopup,
                            onTapRealm: _showRealmPopup,
                          ),
                        'videos' => _PostVideoEditor(
                            controller: _writeController,
                            onTapPublisher: _showPublisherPopup,
                            onTapRealm: _showRealmPopup,
                          ),
                        _ => const Placeholder(),
                      })
                          .padding(top: 8),
                    ),
                    if (_writeController.attachments.isNotEmpty ||
                        _writeController.thumbnail != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: PostMediaPendingList(
                          attachments: _writeController.attachments,
                          isBusy: _writeController.isBusy,
                          onUpload: (int idx) async {
                            await _writeController.uploadSingleAttachment(
                                context, idx);
                          },
                          onInsertLink: (int idx) async {
                            _writeController.contentController.text +=
                                '\n![](solink://attachments/${_writeController.attachments[idx].attachment!.rid})';
                          },
                          onUpdate:
                              (int idx, PostWriteMedia updatedMedia) async {
                            _writeController.setIsBusy(true);
                            try {
                              _writeController.setAttachmentAt(
                                  idx, updatedMedia);
                            } finally {
                              _writeController.setIsBusy(false);
                            }
                          },
                          onRemove: (int idx) async {
                            _writeController.setIsBusy(true);
                            try {
                              _writeController.removeAttachmentAt(idx);
                            } finally {
                              _writeController.setIsBusy(false);
                            }
                          },
                          onUpdateBusy: (state) =>
                              _writeController.setIsBusy(state),
                        ).padding(bottom: 8),
                      ),
                  ],
                ),
              ),
              Material(
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_writeController.isBusy &&
                        _writeController.progress != null)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _writeController.progress),
                        duration: Duration(milliseconds: 300),
                        builder: (context, value, _) =>
                            LinearProgressIndicator(value: value, minHeight: 2),
                      )
                    else if (_writeController.isBusy)
                      const LinearProgressIndicator(value: null, minHeight: 2),
                    LoadingIndicator(isActive: _isLoading),
                    const Gap(4),
                    Container(
                      child: _writeController.temporaryRestored
                          ? Container(
                              padding: const EdgeInsets.only(
                                  top: 4, bottom: 4, left: 28, right: 22),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1 /
                                        MediaQuery.of(context).devicePixelRatio,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.restore, size: 20),
                                  const Gap(8),
                                  Expanded(
                                      child:
                                          Text('postLocalDraftRestored').tr()),
                                  InkWell(
                                    child: Text('dialogDismiss').tr(),
                                    onTap: () {
                                      _writeController.reset();
                                    },
                                  ),
                                ],
                              ))
                          : const SizedBox.shrink(),
                    )
                        .height(_writeController.temporaryRestored ? 32 : 0,
                            animate: true)
                        .animate(const Duration(milliseconds: 300),
                            Curves.fastLinearToSlowEaseIn),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: _PostEditorActionScrollBehavior(),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Row(
                                children: [
                                  AddPostMediaButton(
                                    onAdd: (items) {
                                      setState(() {
                                        _writeController.addAttachments(items);
                                      });
                                    },
                                  ),
                                  if (_writeController.mode == 'stories')
                                    IconButton(
                                      icon: Icon(Symbols.poll,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            _writeController.poll == null
                                                ? null
                                                : WidgetStatePropertyAll(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainer),
                                      ),
                                      onPressed: () {
                                        _showPollEditorDialog();
                                      },
                                    ),
                                  if (_writeController.mode == 'articles')
                                    IconButton(
                                      icon: Icon(Symbols.full_coverage,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            _writeController.thumbnail == null
                                                ? null
                                                : WidgetStatePropertyAll(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainer),
                                      ),
                                      onPressed: () {
                                        if (_writeController.thumbnail !=
                                            null) {
                                          _writeController.setThumbnail(null);
                                          return;
                                        }
                                        _showThumbnailEditorDialog();
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: (_writeController.isBusy ||
                                  _writeController.publisher == null)
                              ? null
                              : () {
                                  _writeController.sendPost(context).then((_) {
                                    if (!context.mounted) return;
                                    Navigator.pop(context, true);
                                  });
                                },
                          icon: const Icon(Symbols.send),
                          label: Text('postPublish').tr(),
                        ),
                      ],
                    ).padding(horizontal: 16),
                  ],
                ).padding(
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PostEditorActionScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _PostPublisherPopup extends StatelessWidget {
  final PostWriteController controller;
  final List<SnPublisher>? publishers;
  final Function onUpdate;

  const _PostPublisherPopup(
      {required this.controller, this.publishers, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Symbols.face, size: 24),
            const Gap(16),
            Text('accountPublishers',
                    style: Theme.of(context).textTheme.titleLarge)
                .tr(),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        ListTile(
          leading: const Icon(Symbols.add),
          title: Text('publishersNew').tr(),
          subtitle: Text('publisherNewSubtitle').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          onTap: () {
            GoRouter.of(context).pushNamed('accountPublisherNew').then((value) {
              if (value == true) {
                onUpdate();
              }
            });
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: publishers?.length ?? 0,
            itemBuilder: (context, idx) {
              final publisher = publishers![idx];
              return ListTile(
                title: Text(publisher.nick),
                subtitle: Text('@${publisher.name}'),
                leading: AccountImage(content: publisher.avatar, radius: 18),
                onTap: () {
                  controller.setPublisher(publisher);
                  Navigator.pop(context, true);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PostRealmPopup extends StatelessWidget {
  final PostWriteController controller;
  final List<SnRealm>? realms;
  final Function onUpdate;

  const _PostRealmPopup(
      {required this.controller, this.realms, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Symbols.face, size: 24),
            const Gap(16),
            Text('accountRealms', style: Theme.of(context).textTheme.titleLarge)
                .tr(),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        ListTile(
          leading: const Icon(Symbols.close),
          title: Text('postInGlobal').tr(),
          subtitle: Text('postInGlobalDescription').tr(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          onTap: () {
            controller.setRealm(null);
            Navigator.pop(context, true);
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: realms?.length ?? 0,
            itemBuilder: (context, idx) {
              final realm = realms![idx];
              return ListTile(
                title: Text(realm.name),
                subtitle: Text('@${realm.alias}'),
                leading: AccountImage(content: realm.avatar, radius: 18),
                onTap: () {
                  controller.setRealm(realm);
                  Navigator.pop(context, true);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PostStoryEditor extends StatelessWidget {
  final PostWriteController controller;
  final Function? onTapPublisher;
  final Function? onTapRealm;

  const _PostStoryEditor(
      {required this.controller, this.onTapPublisher, this.onTapRealm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(maxWidth: 640),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Material(
                elevation: 2,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: GestureDetector(
                  onTap: () {
                    onTapPublisher?.call();
                  },
                  child: AccountImage(
                    content: controller.publisher?.avatar,
                  ),
                ),
              ),
              const Gap(11),
              Material(
                elevation: 1,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: GestureDetector(
                  onTap: () {
                    onTapRealm?.call();
                  },
                  child: AccountImage(
                    content: controller.realm?.avatar,
                    fallbackWidget: const Icon(Symbols.globe, size: 20),
                    radius: 14,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                const Gap(6),
                TextField(
                  controller: controller.titleController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'fieldPostTitle'.tr(),
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(horizontal: 16),
                const Gap(8),
                TextField(
                  controller: controller.contentController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'fieldPostContent'.tr(),
                    hintStyle: TextStyle(fontSize: 14),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    border: InputBorder.none,
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  contentInsertionConfiguration:
                      controller.contentInsertionConfiguration,
                ),
              ],
            ),
          ),
        ],
      ).padding(bottom: 8),
    );
  }
}

class _PostArticleEditor extends StatelessWidget {
  final PostWriteController controller;
  final Function? onTapPublisher;
  final Function? onTapRealm;

  const _PostArticleEditor(
      {required this.controller, this.onTapPublisher, this.onTapRealm});

  @override
  Widget build(BuildContext context) {
    final editorWidgets = <Widget>[
      Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: InkWell(
          child: Row(
            children: [
              AccountImage(content: controller.publisher?.avatar, radius: 20),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.publisher?.nick ?? 'loading'.tr()).bold(),
                    Text('@${controller.publisher?.name}'),
                  ],
                ),
              ),
              Material(
                elevation: 1,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: GestureDetector(
                  onTap: () {
                    onTapRealm?.call();
                  },
                  child: AccountImage(
                    content: controller.realm?.avatar,
                    fallbackWidget: const Icon(Symbols.globe, size: 20),
                    radius: 14,
                  ),
                ),
              ),
              const Gap(8),
            ],
          ).padding(horizontal: 12, vertical: 8),
          onTap: () {
            onTapPublisher?.call();
          },
        ),
      ),
      const Gap(16),
      TextField(
        controller: controller.titleController,
        decoration: InputDecoration.collapsed(
          hintText: 'fieldPostTitle'.tr(),
          border: InputBorder.none,
        ),
        style: Theme.of(context).textTheme.titleLarge,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      ).padding(horizontal: 16),
      const Gap(8),
      TextField(
        controller: controller.descriptionController,
        decoration: InputDecoration.collapsed(
          hintText: 'fieldPostDescription'.tr(),
          border: InputBorder.none,
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: Theme.of(context).textTheme.bodyLarge,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        contentInsertionConfiguration: controller.contentInsertionConfiguration,
      ).padding(horizontal: 16),
      if (controller.thumbnail != null)
        Container(
          margin: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: AttachmentItem(
                data: controller.thumbnail!.attachment!,
                heroTag: "post-editor-thumbnail-preview",
              ),
            ),
          ),
        ),
    ];

    if (ResponsiveBreakpoints.of(context).largerThan(MOBILE)) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 640 * 2 + 8),
        child: Column(
          children: [
            ...editorWidgets,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.contentController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'fieldPostContent'.tr(),
                      hintStyle: TextStyle(fontSize: 14),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    contentInsertionConfiguration:
                        controller.contentInsertionConfiguration,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: MarkdownTextContent(
                    content: controller.contentController.text,
                  ).padding(horizontal: 24),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...editorWidgets,
        Container(
          padding: const EdgeInsets.only(top: 8),
          constraints: const BoxConstraints(maxWidth: 640),
          child: TextField(
            controller: controller.contentController,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'fieldPostContent'.tr(),
              hintStyle: TextStyle(fontSize: 14),
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              border: InputBorder.none,
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            contentInsertionConfiguration:
                controller.contentInsertionConfiguration,
          ),
        ),
      ],
    );
  }
}

class _PostQuestionEditor extends StatelessWidget {
  final PostWriteController controller;
  final Function? onTapPublisher;
  final Function? onTapRealm;

  const _PostQuestionEditor(
      {required this.controller, this.onTapPublisher, this.onTapRealm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(maxWidth: 640),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Material(
                elevation: 2,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: GestureDetector(
                  onTap: () {
                    onTapPublisher?.call();
                  },
                  child: AccountImage(
                    content: controller.publisher?.avatar,
                  ),
                ),
              ),
              const Gap(11),
              Material(
                elevation: 1,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: GestureDetector(
                  onTap: () {
                    onTapRealm?.call();
                  },
                  child: AccountImage(
                    content: controller.realm?.avatar,
                    fallbackWidget: const Icon(Symbols.globe, size: 20),
                    radius: 14,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                const Gap(6),
                TextField(
                  controller: controller.titleController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'fieldPostTitle'.tr(),
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(horizontal: 16),
                const Gap(8),
                TextField(
                  controller: controller.rewardController,
                  decoration: InputDecoration(
                    hintText: 'fieldPostQuestionReward'.tr(),
                    suffixText: 'walletCurrencyShort'.tr(),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(horizontal: 16),
                const Gap(8),
                TextField(
                  controller: controller.contentController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'fieldPostContent'.tr(),
                    hintStyle: TextStyle(fontSize: 14),
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    border: InputBorder.none,
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  contentInsertionConfiguration:
                      controller.contentInsertionConfiguration,
                ),
              ],
            ),
          ),
        ],
      ).padding(top: 8),
    );
  }
}

class _PostVideoEditor extends StatelessWidget {
  final PostWriteController controller;
  final Function? onTapPublisher;
  final Function? onTapRealm;

  const _PostVideoEditor(
      {required this.controller, this.onTapPublisher, this.onTapRealm});

  void _selectVideo(BuildContext context) async {
    final video = await showDialog<SnAttachment?>(
      context: context,
      builder: (context) => AttachmentInputDialog(
        title: 'postVideoUpload'.tr(),
        pool: 'interactive',
        mediaType: SnMediaType.video,
      ),
    );
    if (!context.mounted) return;
    if (video == null) return;
    controller.setVideoAttachment(video);
  }

  void _setAlt(BuildContext context) async {
    if (controller.videoAttachment == null) return;

    final result = await showDialog<SnAttachment?>(
      context: context,
      builder: (context) => PendingAttachmentAltDialog(
          media: PostWriteMedia(controller.videoAttachment)),
    );
    if (result == null) return;

    controller.setVideoAttachment(result);
  }

  Future<void> _createBoost(BuildContext context) async {
    if (controller.videoAttachment == null) return;

    final result = await showDialog<SnAttachmentBoost?>(
      context: context,
      builder: (context) => PendingAttachmentBoostDialog(
          media: PostWriteMedia(controller.videoAttachment)),
    );
    if (result == null) return;

    final newAttach = controller.videoAttachment!.copyWith(
      boosts: [...controller.videoAttachment!.boosts, result],
    );

    controller.setVideoAttachment(newAttach);
  }

  void _setThumbnail(BuildContext context) async {
    if (controller.videoAttachment == null) return;

    final thumbnail = await showDialog<SnAttachment?>(
      context: context,
      builder: (context) => AttachmentInputDialog(
        title: 'attachmentSetThumbnail'.tr(),
        pool: 'interactive',
        analyzeNow: true,
      ),
    );
    if (thumbnail == null) return;
    if (!context.mounted) return;

    try {
      final attach = context.read<SnAttachmentProvider>();
      final newAttach = await attach.updateOne(
        controller.videoAttachment!,
        thumbnailId: thumbnail.id,
      );
      controller.setVideoAttachment(newAttach);
    } catch (err) {
      if (!context.mounted) return;
      context.showErrorDialog(err);
    }
  }

  Future<void> _deleteAttachment(BuildContext context) async {
    if (controller.videoAttachment == null) return;

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client
          .delete('/cgi/uc/attachments/${controller.videoAttachment!.id}');
      controller.setVideoAttachment(null);
    } catch (err) {
      if (!context.mounted) return;
      context.showErrorDialog(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(maxWidth: 640),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Material(
                elevation: 2,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: GestureDetector(
                  onTap: () {
                    onTapPublisher?.call();
                  },
                  child: AccountImage(
                    content: controller.publisher?.avatar,
                  ),
                ),
              ),
              const Gap(11),
              Material(
                elevation: 1,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                child: GestureDetector(
                  onTap: () {
                    onTapRealm?.call();
                  },
                  child: AccountImage(
                    content: controller.realm?.avatar,
                    fallbackWidget: const Icon(Symbols.globe, size: 20),
                    radius: 14,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                const Gap(6),
                TextField(
                  controller: controller.titleController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'fieldPostTitle'.tr(),
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(horizontal: 16),
                const Gap(8),
                TextField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'fieldPostDescription'.tr(),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: Theme.of(context).textTheme.bodyLarge,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ).padding(horizontal: 16),
                const Gap(12),
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: ContextMenuRegion(
                    contextMenu: ContextMenu(
                      entries: [
                        MenuItem(
                          label: 'attachmentSetAlt'.tr(),
                          icon: Symbols.description,
                          onSelected: () {
                            _setAlt(context);
                          },
                        ),
                        MenuItem(
                          label: 'attachmentBoost'.tr(),
                          icon: Symbols.bolt,
                          onSelected: () {
                            _createBoost(context);
                          },
                        ),
                        MenuItem(
                          label: 'attachmentSetThumbnail'.tr(),
                          icon: Symbols.image,
                          onSelected: () {
                            _setThumbnail(context);
                          },
                        ),
                        MenuItem(
                          label: 'attachmentCopyRandomId'.tr(),
                          icon: Symbols.content_copy,
                          onSelected: () {
                            Clipboard.setData(ClipboardData(
                                text: controller.videoAttachment!.rid));
                          },
                        ),
                        MenuItem(
                          label: 'delete'.tr(),
                          icon: Symbols.delete,
                          onSelected: () => _deleteAttachment(context),
                        ),
                        MenuItem(
                          label: 'unlink'.tr(),
                          icon: Symbols.link_off,
                          onSelected: () {
                            controller.setVideoAttachment(null);
                          },
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: controller.videoAttachment == null
                          ? () => _selectVideo(context)
                          : null,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: controller.videoAttachment == null
                            ? Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add),
                                    const Gap(4),
                                    Text('postVideoUpload'.tr()),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AttachmentItem(
                                  data: controller.videoAttachment!,
                                  heroTag: const Uuid().v4(),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
