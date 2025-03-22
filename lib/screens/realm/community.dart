import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/screens/post/post_editor.dart';
import 'package:surface/types/post.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class RealmCommunityScreen extends StatefulWidget {
  final String alias;
  const RealmCommunityScreen({super.key, required this.alias});

  @override
  State<RealmCommunityScreen> createState() => _RealmCommunityScreenState();
}

class _RealmCommunityScreenState extends State<RealmCommunityScreen> {
  SnRealm? _realm;

  Future<void> _fetchRealm() async {
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/realms/${widget.alias}');
      _realm = SnRealm.fromJson(resp.data);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
      rethrow;
    } finally {
      setState(() {});
    }
  }

  bool _isBusy = false;
  int? _totalCount;
  final List<SnPost> _posts = List.empty(growable: true);

  Future<void> _fetchPosts() async {
    setState(() => _isBusy = true);

    try {
      final pt = context.read<SnPostContentProvider>();
      final out = await pt.listPosts(
        take: 10,
        offset: _posts.length,
        realm: _realm?.id.toString(),
      );
      _totalCount = out.$2;
      _posts.addAll(out.$1);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRealm();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(_realm?.name ?? 'loading'.tr()),
      ),
      floatingActionButton: _realm != null
          ? FloatingActionButton(
              child: const Icon(Symbols.edit),
              onPressed: () {
                GoRouter.of(context).pushNamed(
                  'postEditor',
                  extra: PostEditorExtra(realm: _realm!),
                );
              },
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_realm == null)
            Expanded(
              child: Center(
                child: CircularProgressIndicator().center(),
              ),
            ),
          if (_realm != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('realmCommunity'.tr(args: [_realm!.name]))
                    .fontSize(17)
                    .padding(horizontal: 20, bottom: 4),
                Text('postTotalCount'.plural(_totalCount ?? 0))
                    .fontSize(13)
                    .opacity(0.8)
                    .padding(horizontal: 20, bottom: 4),
              ],
            ).padding(horizontal: 20, vertical: 16),
          const Divider(height: 1),
          if (_realm != null)
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: RefreshIndicator(
                  onRefresh: _fetchPosts,
                  child: InfiniteList(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _posts.length,
                    isLoading: _isBusy,
                    hasReachedMax:
                        _totalCount != null && _posts.length >= _totalCount!,
                    onFetchData: _fetchPosts,
                    itemBuilder: (context, idx) {
                      final post = _posts[idx];
                      return OpenablePostItem(
                        data: post,
                        maxWidth: 640,
                        onChanged: (data) {
                          setState(() => _posts[idx] = data);
                        },
                        onDeleted: () {
                          setState(() => _posts.removeAt(idx));
                        },
                      );
                    },
                    separatorBuilder: (_, __) =>
                        const Divider().padding(vertical: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
