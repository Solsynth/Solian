import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/screens/post/post_editor.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';

class PostMiniEditor extends StatefulWidget {
  final int? postReplyId;
  final Function? onPost;
  final Function? onExpand;

  const PostMiniEditor(
      {super.key, this.postReplyId, this.onPost, this.onExpand});

  @override
  State<PostMiniEditor> createState() => _PostMiniEditorState();
}

class _PostMiniEditorState extends State<PostMiniEditor> {
  final PostWriteController _writeController =
      PostWriteController(doLoadFromTemporary: false);

  bool _isFetching = false;

  bool get _isLoading => _isFetching || _writeController.isLoading;

  List<SnPublisher>? _publishers;

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

  @override
  void initState() {
    super.initState();
    _fetchPublishers();
    _writeController.fetchRelatedPost(
      context,
      replying: widget.postReplyId,
    );
  }

  @override
  void dispose() {
    _writeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _writeController,
        builder: (context, _) {
          return Column(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2<SnPublisher>(
                  isExpanded: true,
                  hint: Text(
                    'fieldPostPublisher',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ).tr(),
                  items: <DropdownMenuItem<SnPublisher>>[
                    ...(_publishers?.map(
                          (item) => DropdownMenuItem<SnPublisher>(
                            enabled: _writeController.editingPost == null,
                            value: item,
                            child: Row(
                              children: [
                                AccountImage(content: item.avatar, radius: 16),
                                const Gap(8),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.nick).textStyle(
                                          Theme.of(context)
                                              .textTheme
                                              .bodyMedium!),
                                      Text('@${item.name}')
                                          .textStyle(Theme.of(context)
                                              .textTheme
                                              .bodySmall!)
                                          .fontSize(12),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) ??
                        []),
                    DropdownMenuItem<SnPublisher>(
                      value: null,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.transparent,
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
                            child: const Icon(Symbols.add),
                          ),
                          const Gap(8),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('publishersNew').tr().textStyle(
                                    Theme.of(context).textTheme.bodyMedium!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  value: _writeController.publisher,
                  onChanged: (SnPublisher? value) {
                    if (value == null) {
                      GoRouter.of(context)
                          .pushNamed('accountPublisherNew')
                          .then((value) {
                        if (value == true) {
                          _publishers = null;
                          _fetchPublishers();
                        }
                      });
                    } else {
                      _writeController.setPublisher(value);
                      final config = context.read<ConfigProvider>();
                      config.prefs.setInt('int_last_publisher_id', value.id);
                    }
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.only(right: 16),
                    height: 48,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 48,
                  ),
                ),
              ),
              const Divider(height: 1),
              const Gap(8),
              Expanded(
                child: TextField(
                  controller: _writeController.contentController,
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
                ),
              ),
              const Gap(8),
              LoadingIndicator(isActive: _isLoading),
              if (_writeController.isBusy && _writeController.progress != null)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _writeController.progress),
                  duration: Duration(milliseconds: 300),
                  builder: (context, value, _) =>
                      LinearProgressIndicator(value: value, minHeight: 2),
                )
              else if (_writeController.isBusy)
                const LinearProgressIndicator(value: null, minHeight: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Symbols.launch,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      GoRouter.of(context).pushNamed(
                        'postEditor',
                        extra: PostEditorExtra(
                          text: _writeController.contentController.text,
                        ),
                        queryParameters: {
                          if (widget.postReplyId != null)
                            'replying': widget.postReplyId.toString(),
                          'mode': 'stories',
                        },
                      );
                      widget.onExpand?.call();
                    },
                  ),
                  TextButton.icon(
                    onPressed: (_writeController.isBusy ||
                            _writeController.publisher == null)
                        ? null
                        : () {
                            _writeController.sendPost(context).then((_) {
                              if (!context.mounted) return;
                              if (widget.onPost != null) widget.onPost!();
                              context.showSnackbar('postPosted'.tr());
                              _writeController.reset();
                            });
                          },
                    icon: const Icon(Symbols.send),
                    label: Text('postPublish').tr(),
                  ),
                ],
              ).padding(left: 12, right: 16, bottom: 4),
            ],
          );
        });
  }
}
