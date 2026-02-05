import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/post/post_list.dart';
import 'package:island/posts/posts_widgets/post/post_item.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:styled_widget/styled_widget.dart';

const kShufflePostListId = 'shuffle';

class _ShufflePageNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void updatePage(int page) => state = page;
}

final _shufflePageProvider = NotifierProvider<_ShufflePageNotifier, int>(
  _ShufflePageNotifier.new,
);

class PostShuffleScreen extends HookConsumerWidget {
  const PostShuffleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const query = PostListQuery(shuffle: true);
    final cfg = PostListQueryConfig(
      id: kShufflePostListId,
      initialFilter: query,
    );
    final postListState = ref.watch(postListProvider(cfg));
    final postListNotifier = ref.watch(postListProvider(cfg).notifier);

    final savedPage = ref.watch(_shufflePageProvider);
    final pageNotifier = ref.watch(_shufflePageProvider.notifier);

    final pageController = usePageController(initialPage: savedPage);

    useEffect(() {
      return pageController.dispose;
    }, []);

    final items = postListState.value?.items ?? [];

    useEffect(() {
      void listener() {
        if (!pageController.hasClients) return;
        final page = pageController.page?.round() ?? 0;
        if (page != savedPage) {
          pageNotifier.updatePage(page);
        }
        if (page >= items.length - 3 && !postListNotifier.fetchedAll) {
          postListNotifier.fetchFurther();
        }
      }

      pageController.addListener(listener);
      return () => pageController.removeListener(listener);
    }, [items.length, postListNotifier.fetchedAll]);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: const Text('postShuffle').tr()),
      body: Builder(
        builder: (context) {
          if (items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              PageView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: PostActionableItem(
                        item: items[index],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                    ).center(),
                  );
                },
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          final currentPage = pageController.page?.round() ?? 0;
                          if (currentPage > 0) {
                            pageController.animateToPage(
                              currentPage - 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        icon: Icon(
                          Icons.keyboard_double_arrow_up,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'swipeToExplore'.tr(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final currentPage = pageController.page?.round() ?? 0;
                          if (currentPage < items.length - 1) {
                            pageController.animateToPage(
                              currentPage + 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        icon: Icon(
                          Icons.keyboard_double_arrow_down,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
