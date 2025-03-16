import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class PostDraftBox extends StatefulWidget {
  const PostDraftBox({super.key});

  @override
  State<PostDraftBox> createState() => _PostDraftBoxState();
}

class _PostDraftBoxState extends State<PostDraftBox> {
  bool _isBusy = false;
  final List<SnPost> _posts = List.empty(growable: true);
  int? _totalCount;

  Future<void> _fetchPosts() async {
    setState(() => _isBusy = true);
    try {
      final pt = context.read<SnPostContentProvider>();
      final resp = await pt.listPosts(
        take: 10,
        offset: _posts.length,
        isDraft: true,
      );
      final out = resp.$1;
      _totalCount = resp.$2;
      if (!mounted) return;
      _posts.addAll(out);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('postDraftBox').tr(),
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                _posts.clear();
                return _fetchPosts();
              },
              child: InfiniteList(
                padding: EdgeInsets.only(top: 8),
                hasReachedMax:
                    _totalCount != null && _posts.length >= _totalCount!,
                itemCount: _posts.length,
                onFetchData: () => _fetchPosts(),
                itemBuilder: (context, idx) {
                  final ele = _posts[idx];
                  return OpenablePostItem(
                    data: ele,
                    onChanged: (data) {
                      _posts[idx] = data;
                    },
                    onDeleted: () {
                      _posts.clear();
                      _fetchPosts();
                    },
                  );
                },
                separatorBuilder: (_, __) =>
                    const Divider().padding(vertical: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
