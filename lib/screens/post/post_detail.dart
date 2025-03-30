import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_comment_list.dart';
import 'package:surface/widgets/post/post_item.dart';

class PostDetailScreen extends StatefulWidget {
  final String slug;
  final SnPost? preload;
  final Function? onBack;

  const PostDetailScreen(
      {super.key, required this.slug, this.preload, this.onBack});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _isBusy = false;

  SnPost? _data;

  void _fetchPost() async {
    setState(() => _isBusy = true);

    try {
      final pt = context.read<SnPostContentProvider>();
      final post = await pt.getPost(widget.slug);
      if (!mounted) return;
      _data = post;
    } catch (err) {
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.preload != null) {
      _data = widget.preload;
    }
    _fetchPost();
  }

  final GlobalKey<PostCommentSliverListState> _childListKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();

    final double maxWidth = _data?.type == 'video' ? double.infinity : 640;

    return AppScaffold(
      noBackground: ResponsiveScaffold.getIsExpand(context),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!.call();
            }
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop(context);
              return;
            }
            GoRouter.of(context).replaceNamed('explore');
          },
        ),
        title: _data?.body['title'] != null
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    text: _data?.body['title'] ?? 'postNoun'.tr(),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).appBarTheme.foregroundColor!,
                        ),
                  ),
                  const TextSpan(text: '\n'),
                  TextSpan(
                    text: 'postDetail'.tr(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).appBarTheme.foregroundColor!,
                        ),
                  ),
                ]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : Text('postDetail').tr(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: LoadingIndicator(isActive: _isBusy),
          ),
          if (_data != null)
            SliverToBoxAdapter(
              child: PostItem(
                data: _data!,
                maxWidth: maxWidth,
                showComments: false,
                showFullPost: true,
                onChanged: (data) {
                  setState(() => _data = data);
                },
                onDeleted: () {
                  Navigator.pop(context);
                },
              ),
            ),
          if (_data != null)
            SliverToBoxAdapter(
              child: Divider(height: 1).padding(top: 8),
            ),
          if (_data != null)
            SliverToBoxAdapter(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Symbols.comment, size: 24),
                    const Gap(16),
                    Text('postCommentsDetailed')
                        .plural(_data!.metric.replyCount)
                        .textStyle(Theme.of(context).textTheme.titleLarge!),
                  ],
                ).padding(horizontal: 20, vertical: 12).center(),
              ),
            ),
          if (_data != null && ua.isAuthorized)
            SliverToBoxAdapter(
              child: PostCommentQuickAction(
                parentPost: _data!,
                maxWidth: maxWidth,
                onPosted: () {
                  setState(() {
                    _data = _data!.copyWith(
                      metric: _data!.metric.copyWith(
                        replyCount: _data!.metric.replyCount + 1,
                      ),
                    );
                  });
                  _childListKey.currentState!.refresh();
                },
              ),
            ),
          if (_data != null) SliverGap(8),
          if (_data != null)
            PostCommentSliverList(
              key: _childListKey,
              parentPost: _data!,
              maxWidth: maxWidth,
            ),
          if (_data != null)
            SliverGap(math.max(MediaQuery.of(context).padding.bottom, 16)),
        ],
      ),
    );
  }
}
