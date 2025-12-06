import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';

part 'post_list.freezed.dart';

@freezed
sealed class PostListQuery with _$PostListQuery {
  const factory PostListQuery({
    String? pubName,
    String? realm,
    int? type,
    List<String>? categories,
    List<String>? tags,
    bool? pinned,
    @Default(false) bool shuffle,
    bool? includeReplies,
    bool? mediaOnly,
    String? queryTerm,
    String? order,
    int? periodStart,
    int? periodEnd,
    @Default(true) bool orderDesc,
  }) = _PostListQuery;
}

final postListProvider = AsyncNotifierProvider.autoDispose.family(
  PostListNotifier.new,
);

class PostListNotifier extends AsyncNotifier<List<SnPost>>
    with
        AsyncPaginationController<SnPost>,
        AsyncPaginationFilter<PostListQuery, SnPost> {
  static const int pageSize = 20;

  final String? id;
  PostListNotifier(this.id);

  @override
  PostListQuery currentFilter = PostListQuery();

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {
      'offset': fetchedCount,
      'take': pageSize,
      'replies': currentFilter.includeReplies,
      'orderDesc': currentFilter.orderDesc,
      if (currentFilter.shuffle) 'shuffle': currentFilter.shuffle,
      if (currentFilter.pubName != null) 'pub': currentFilter.pubName,
      if (currentFilter.realm != null) 'realm': currentFilter.realm,
      if (currentFilter.type != null) 'type': currentFilter.type,
      if (currentFilter.tags != null) 'tags': currentFilter.tags,
      if (currentFilter.categories != null)
        'categories': currentFilter.categories,
      if (currentFilter.pinned != null) 'pinned': currentFilter.pinned,
      if (currentFilter.order != null) 'order': currentFilter.order,
      if (currentFilter.periodStart != null)
        'periodStart': currentFilter.periodStart,
      if (currentFilter.periodEnd != null) 'periodEnd': currentFilter.periodEnd,
      if (currentFilter.queryTerm != null) 'query': currentFilter.queryTerm,
      if (currentFilter.mediaOnly != null) 'media': currentFilter.mediaOnly,
    };

    final response = await client.get(
      '/sphere/posts',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    return data.map((json) => SnPost.fromJson(json)).toList();
  }
}
