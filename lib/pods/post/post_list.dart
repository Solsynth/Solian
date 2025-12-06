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

final postListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<PostListNotifier, List<SnPost>, PostListQuery>(
      PostListNotifier.new,
    );

class PostListNotifier extends AsyncNotifier<List<SnPost>>
    with AsyncPaginationController<SnPost> {
  final PostListQuery arg;
  PostListNotifier(this.arg);

  static const int pageSize = 20;

  @override
  Future<List<SnPost>> fetch() async {
    final client = ref.read(apiClientProvider);

    final queryParams = {
      'offset': fetchedCount,
      'take': pageSize,
      'replies': arg.includeReplies,
      'orderDesc': arg.orderDesc,
      if (arg.shuffle) 'shuffle': arg.shuffle,
      if (arg.pubName != null) 'pub': arg.pubName,
      if (arg.realm != null) 'realm': arg.realm,
      if (arg.type != null) 'type': arg.type,
      if (arg.tags != null) 'tags': arg.tags,
      if (arg.categories != null) 'categories': arg.categories,
      if (arg.pinned != null) 'pinned': arg.pinned,
      if (arg.order != null) 'order': arg.order,
      if (arg.periodStart != null) 'periodStart': arg.periodStart,
      if (arg.periodEnd != null) 'periodEnd': arg.periodEnd,
      if (arg.queryTerm != null) 'query': arg.queryTerm,
      if (arg.mediaOnly != null) 'media': arg.mediaOnly,
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
