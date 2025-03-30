import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/post.dart';
import 'package:surface/types/post.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:surface/widgets/post/post_item.dart';

class PostShuffleScreen extends StatefulWidget {
  const PostShuffleScreen({super.key});

  @override
  State<PostShuffleScreen> createState() => _PostShuffleScreenState();
}

class _PostShuffleScreenState extends State<PostShuffleScreen> {
  late final CardSwiperController _cardController = CardSwiperController();

  bool _isBusy = false;
  final List<SnPost> _posts = List.empty(growable: true);

  Future<void> _fetchPosts() async {
    _posts.clear();
    setState(() => _isBusy = true);
    try {
      final pt = context.read<SnPostContentProvider>();
      final result =
          await pt.listPosts(take: 10, offset: _posts.length, isShuffle: true);
      _posts.addAll(result.$1);
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
    _fetchPosts();
  }

  @override
  void dispose() {
    super.dispose();
    _cardController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text('postShuffle').tr()),
      body: Stack(
        children: [
          Column(
            children: [
              if (_isBusy || _posts.isEmpty)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: CardSwiper(
                    controller: _cardController,
                    isLoop: false,
                    padding: EdgeInsets.zero,
                    cardsCount: _posts.length,
                    cardBuilder: (context, idx, _, __) {
                      final ele = _posts[idx];
                      return SingleChildScrollView(
                        child: Center(
                          child: Card(
                            color: Theme.of(context).colorScheme.surface,
                            child: OpenablePostItem(
                              key: ValueKey(ele),
                              data: ele,
                              maxWidth: 640,
                              useReplace: true,
                              onChanged: (ele) {
                                _posts[idx] = ele;
                                setState(() {});
                              },
                              onDeleted: () {
                                _fetchPosts();
                              },
                            ).padding(all: 8),
                          ).padding(
                            all: 24,
                            bottom:
                                MediaQuery.of(context).padding.bottom + 16 + 50,
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      _fetchPosts();
                    },
                  ),
                ),
            ],
          ),
          if (!_isBusy && _posts.isNotEmpty)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    icon: const Icon(Symbols.next_plan),
                    color: Theme.of(context).colorScheme.onPrimary,
                    onPressed: () {
                      _cardController.swipe(CardSwiperDirection.right);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
