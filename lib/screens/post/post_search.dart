import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';
import 'package:surface/widgets/post/post_tags_field.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class PostSearchScreen extends StatefulWidget {
  final Iterable<String>? initialTags;
  final Iterable<String>? initialCategories;

  const PostSearchScreen({super.key, this.initialTags, this.initialCategories});

  @override
  State<PostSearchScreen> createState() => _PostSearchScreenState();
}

class _PostSearchScreenState extends State<PostSearchScreen> {
  bool _isBusy = false;

  List<String> _searchTags = List.empty(growable: true);
  List<String> _searchCategories = List.empty(growable: true);

  final List<SnPost> _posts = List.empty(growable: true);
  int? _postCount;

  String _searchTerm = '';
  Duration? _lastTook;

  @override
  void initState() {
    super.initState();
    _searchTags.addAll(widget.initialTags ?? []);
    _searchCategories.addAll(widget.initialCategories ?? []);
    if (_searchTags.isNotEmpty || _searchCategories.isNotEmpty) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    if (_searchTerm.isEmpty && _searchCategories.isEmpty && _searchTags.isEmpty)
      return;
    if (_postCount != null && _posts.length >= _postCount!) return;

    setState(() => _isBusy = true);

    final stopwatch = Stopwatch()..start();

    try {
      final pt = context.read<SnPostContentProvider>();
      final result = await pt.searchPosts(
        _searchTerm,
        take: 10,
        offset: _posts.length,
        tags: _searchTags,
        categories: _searchCategories,
      );
      final List<SnPost> out = result.$1;
      _postCount = result.$2;
      _posts.addAll(out);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
      return;
    } finally {
      stopwatch.stop();
      _lastTook = stopwatch.elapsed;
    }

    if (mounted) setState(() => _isBusy = false);
  }

  void _showAdvancedSearchTune() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          PostTagsField(
            labelText: 'fieldPostTags'.tr(),
            initialTags: _searchTags,
            onUpdate: (value) {
              setState(() => _searchTags = value);
            },
          ),
          const Gap(4),
          PostCategoriesField(
            labelText: 'fieldPostCategories'.tr(),
            initialCategories: _searchCategories,
            onUpdate: (value) {
              setState(() => _searchCategories = value);
            },
          ),
        ],
      ).padding(horizontal: 24, vertical: 16),
    ).then((_) {
      _refreshPosts();
    });
  }

  Future<void> _refreshPosts() {
    _postCount = null;
    _posts.clear();
    return _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    const labelShadows = <Shadow>[
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 8.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    ];

    return AppScaffold(
      appBar: AppBar(
        title: Text('screenPostSearch').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.tune),
            onPressed: _showAdvancedSearchTune,
          ),
          const Gap(8),
        ],
      ),
      body: Stack(
        children: [
          InfiniteList(
            padding: const EdgeInsets.only(top: 100 + 8),
            itemCount: _posts.length,
            isLoading: _isBusy,
            hasReachedMax: _postCount != null && _posts.length >= _postCount!,
            onFetchData: () {
              _fetchPosts();
            },
            itemBuilder: (context, idx) {
              return OpenablePostItem(
                data: _posts[idx],
                maxWidth: 640,
                onChanged: (data) {
                  setState(() => _posts[idx] = data);
                },
                onDeleted: () {
                  _refreshPosts();
                },
              );
            },
            separatorBuilder: (_, __) => const Divider().padding(vertical: 2),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                SearchBar(
                  elevation: const WidgetStatePropertyAll(1),
                  leading: const Icon(Symbols.search),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 24),
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onChanged: (value) {
                    _searchTerm = value;
                  },
                  onSubmitted: (value) {
                    _searchTerm = value;
                    _refreshPosts();
                  },
                ),
                if (_lastTook != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.summarize,
                        color: Colors.white,
                        shadows: labelShadows,
                        size: 16,
                      ),
                      const Gap(4),
                      Text(
                        'postSearchResult'.plural(_postCount ?? 0),
                        style: TextStyle(
                          color: Colors.white,
                          shadows: labelShadows,
                          fontSize: 13,
                        ),
                      ),
                      const Gap(8),
                      Icon(
                        Symbols.pace,
                        color: Colors.white,
                        shadows: labelShadows,
                        size: 16,
                      ),
                      const Gap(4),
                      Text(
                        'postSearchTook'.tr(args: [
                          '${(_lastTook!.inMilliseconds / 1000).toStringAsFixed(3)}s',
                        ]),
                        style: TextStyle(
                          color: Colors.white,
                          shadows: labelShadows,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ).padding(vertical: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
