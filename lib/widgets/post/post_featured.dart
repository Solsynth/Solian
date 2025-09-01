import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/widgets/post/post_item.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/pods/config.dart'; // Import config.dart for shared preferences keys and provider

part 'post_featured.g.dart';

@riverpod
Future<List<SnPost>> featuredPosts(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/posts/featured');
  return resp.data.map((e) => SnPost.fromJson(e)).cast<SnPost>().toList();
}

class PostFeaturedList extends HookConsumerWidget {
  const PostFeaturedList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredPostsAsync = ref.watch(featuredPostsProvider);

    final pageViewController = usePageController();
    final prefs = ref.watch(sharedPreferencesProvider);
    final pageViewCurrent = useState(0);
    final previousFirstPostId = useState<String?>(null);
    final storedCollapsedId = useState<String?>(
      prefs.getString(kFeaturedPostsCollapsedId),
    );
    final isCollapsed = useState(false);

    useEffect(() {
      pageViewController.addListener(() {
        pageViewCurrent.value = pageViewController.page?.round() ?? 0;
      });
      return null;
    }, [pageViewController]);

    // Log isCollapsed state changes
    useEffect(() {
      debugPrint(
        'PostFeaturedList: isCollapsed changed to ${isCollapsed.value}',
      );
      return null;
    }, [isCollapsed.value]);

    useEffect(() {
      if (featuredPostsAsync.hasValue && featuredPostsAsync.value!.isNotEmpty) {
        final currentFirstPostId = featuredPostsAsync.value!.first.id;
        debugPrint(
          'PostFeaturedList: Current first post ID: $currentFirstPostId',
        );
        debugPrint(
          'PostFeaturedList: Previous first post ID: ${previousFirstPostId.value}',
        );
        debugPrint(
          'PostFeaturedList: Stored collapsed ID: ${storedCollapsedId.value}',
        );

        if (previousFirstPostId.value == null) {
          // Initial load
          previousFirstPostId.value = currentFirstPostId;
          isCollapsed.value = (storedCollapsedId.value == currentFirstPostId);
          debugPrint(
            'PostFeaturedList: Initial load. isCollapsed set to ${isCollapsed.value}',
          );
        } else if (previousFirstPostId.value != currentFirstPostId) {
          // First post changed, expand by default
          previousFirstPostId.value = currentFirstPostId;
          isCollapsed.value = false;
          prefs.remove(
            kFeaturedPostsCollapsedId,
          ); // Clear stored ID if post changes
          debugPrint(
            'PostFeaturedList: First post changed. isCollapsed set to false.',
          );
        } else {
          // Same first post, maintain current collapse state
          // No change needed for isCollapsed.value unless manually toggled
          debugPrint(
            'PostFeaturedList: Same first post. Maintaining current collapse state.',
          );
        }
      } else {
        debugPrint(
          'PostFeaturedList: featuredPostsAsync has no value or is empty.',
        );
      }
      return null;
    }, [featuredPostsAsync.value]);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Row(
              spacing: 8,
              children: [
                const Icon(Symbols.highlight),
                const Text('highlightPost').tr(),
                Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    pageViewController.animateToPage(
                      pageViewCurrent.value - 1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Symbols.arrow_left),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    pageViewController.animateToPage(
                      pageViewCurrent.value + 1,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Symbols.arrow_right),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    isCollapsed.value = !isCollapsed.value;
                    debugPrint(
                      'PostFeaturedList: Manual toggle. isCollapsed set to ${isCollapsed.value}',
                    );
                    if (isCollapsed.value &&
                        featuredPostsAsync.hasValue &&
                        featuredPostsAsync.value!.isNotEmpty) {
                      prefs.setString(
                        kFeaturedPostsCollapsedId,
                        featuredPostsAsync.value!.first.id,
                      );
                      debugPrint(
                        'PostFeaturedList: Stored collapsed ID: ${featuredPostsAsync.value!.first.id}',
                      );
                    } else {
                      prefs.remove(kFeaturedPostsCollapsedId);
                      debugPrint(
                        'PostFeaturedList: Removed stored collapsed ID.',
                      );
                    }
                  },
                  icon: Icon(
                    isCollapsed.value
                        ? Symbols.expand_more
                        : Symbols.expand_less,
                  ),
                ),
              ],
            ).padding(horizontal: 16, vertical: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Visibility(
                visible: !isCollapsed.value,
                child: featuredPostsAsync.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data: (posts) {
                    return SizedBox(
                      height: 320,
                      child: PageView.builder(
                        controller: pageViewController,
                        scrollDirection: Axis.horizontal,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return SingleChildScrollView(
                            child: PostActionableItem(
                              item: posts[index],
                              borderRadius: 8,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
