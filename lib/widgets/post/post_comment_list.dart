import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:surface/widgets/post/post_mini_editor.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class PostCommentQuickAction extends StatelessWidget {
  final double? maxWidth;
  final SnPost parentPost;
  final Function? onPosted;

  const PostCommentQuickAction(
      {super.key, this.maxWidth, required this.parentPost, this.onPosted});

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Container(
      height: 240,
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      margin: ResponsiveBreakpoints.of(context).largerThan(MOBILE)
          ? const EdgeInsets.symmetric(vertical: 8)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: ResponsiveBreakpoints.of(context).largerThan(MOBILE)
            ? const BorderRadius.all(Radius.circular(8))
            : BorderRadius.zero,
        border: ResponsiveBreakpoints.of(context).largerThan(MOBILE)
            ? Border.all(
                color: Theme.of(context).dividerColor,
                width: 1 / devicePixelRatio,
              )
            : Border.symmetric(
                horizontal: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1 / devicePixelRatio,
                ),
              ),
      ),
      child: PostMiniEditor(
        postReplyId: parentPost.id,
        onPost: () {
          onPosted?.call();
        },
      ),
    );
  }
}

class PostCommentSliverList extends StatefulWidget {
  final SnPost parentPost;
  final double? maxWidth;
  final Function(SnPost)? onSelectAnswer;

  const PostCommentSliverList({
    super.key,
    required this.parentPost,
    this.maxWidth,
    this.onSelectAnswer,
  });

  @override
  State<PostCommentSliverList> createState() => PostCommentSliverListState();
}

class PostCommentSliverListState extends State<PostCommentSliverList> {
  bool _isBusy = true;

  final List<SnPost> _posts = List.empty(growable: true);
  int? _postCount;

  Future<void> _fetchPosts() async {
    if (_postCount != null && _posts.length >= _postCount!) return;

    setState(() => _isBusy = true);

    final pt = context.read<SnPostContentProvider>();
    final result = await pt.listPostReplies(widget.parentPost.id);
    final List<SnPost> out = result.$1;

    if (!mounted) return;

    _postCount = result.$2;
    _posts.addAll(out);

    if (mounted) setState(() => _isBusy = false);
  }

  Future<void> _selectAnswer(SnPost answer) async {
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client
          .put('/cgi/co/questions/${widget.parentPost.id}/answer', data: {
        'publisher': widget.parentPost.publisherId,
        'answer_id': answer.id,
      });
      if (!mounted) return;
      await refresh();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  Future<void> refresh() async {
    _posts.clear();
    _postCount = null;
    _fetchPosts();
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return SliverInfiniteList(
      itemCount: _posts.length,
      isLoading: _isBusy,
      hasReachedMax: _postCount != null && _posts.length >= _postCount!,
      onFetchData: _fetchPosts,
      itemBuilder: (context, idx) {
        return GestureDetector(
          child: PostItem(
            data: _posts[idx],
            maxWidth: widget.maxWidth,
            showExpandableComments: true,
            onSelectAnswer: widget.parentPost.type == 'question'
                ? () => _selectAnswer(_posts[idx])
                : null,
            onChanged: (data) {
              setState(() => _posts[idx] = data);
            },
            onDeleted: () {
              _posts.clear();
              _fetchPosts();
            },
          ),
          onTap: () {
            Navigator.pop(context);
            GoRouter.of(context).pushNamed(
              'postDetail',
              pathParameters: {'slug': _posts[idx].id.toString()},
              extra: _posts[idx],
            );
          },
        );
      },
      separatorBuilder: (context, index) =>
          const Divider().padding(vertical: 2),
    );
  }
}

class PostCommentListPopup extends StatefulWidget {
  final SnPost post;
  final int commentCount;
  final int depth;

  const PostCommentListPopup({
    super.key,
    required this.post,
    this.commentCount = 0,
    this.depth = 1,
  });

  @override
  State<PostCommentListPopup> createState() => _PostCommentListPopupState();
}

class _PostCommentListPopupState extends State<PostCommentListPopup> {
  final GlobalKey<PostCommentSliverListState> _childListKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Symbols.comment, size: 24),
              const Gap(16),
              Text('postCommentsDetailed')
                  .plural(widget.commentCount)
                  .textStyle(Theme.of(context).textTheme.titleLarge!),
            ],
          ).padding(horizontal: 20, top: 16, bottom: 12),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (ua.isAuthorized)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      height: 240,
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1 / devicePixelRatio,
                          ),
                        ),
                      ),
                      child: PostMiniEditor(
                        postReplyId: widget.post.id,
                        onPost: () {
                          _childListKey.currentState!.refresh();
                        },
                        onExpand: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                PostCommentSliverList(
                  parentPost: widget.post,
                  key: _childListKey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
