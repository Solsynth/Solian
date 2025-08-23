import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:island/widgets/post/post_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class PostShuffleScreen extends HookConsumerWidget {
  const PostShuffleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postListState = ref.watch(postListNotifierProvider(shuffle: true));
    final postListNotifier = ref.watch(
      postListNotifierProvider(shuffle: true).notifier,
    );

    final cardSwiperController = useMemoized(() => CardSwiperController(), []);

    useEffect(() {
      return cardSwiperController.dispose;
    }, []);

    const kBottomControlHeight = 64.0;

    return AppScaffold(
      appBar: AppBar(title: const Text('postShuffle').tr()),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom:
                  kBottomControlHeight + MediaQuery.of(context).padding.bottom,
            ),
            child:
                (postListState.value?.items.length ?? 0) > 0
                    ? CardSwiper(
                      controller: cardSwiperController,
                      cardsCount: postListState.value!.items.length,
                      cardBuilder: (
                        context,
                        index,
                        horizontalOffsetPercentage,
                        verticalOffsetPercentage,
                      ) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 540),
                            child: SingleChildScrollView(
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  child: PostActionableItem(
                                    item: postListState.value!.items[index],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        if (postListState.value?.hasMore ?? true) {
                          postListNotifier.fetch(
                            cursor: postListState.value?.nextCursor,
                          );
                        }
                      },
                    )
                    : Center(child: CircularProgressIndicator()),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainer,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              height: kBottomControlHeight,
              child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          cardSwiperController.undo();
                        },
                        icon: const Icon(Symbols.arrow_left_alt),
                      ),
                      IconButton(
                        onPressed: () {
                          cardSwiperController.swipe(CardSwiperDirection.right);
                        },
                        icon: const Icon(Symbols.arrow_right_alt),
                      ),
                    ],
                  ).padding(all: 8).center(),
            ),
          ),
        ],
      ),
    );
  }
}
