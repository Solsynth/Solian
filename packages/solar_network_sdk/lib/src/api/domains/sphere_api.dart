import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/accounts/discovery.dart';
import 'package:solar_network_sdk/src/models/accounts/publishing_settings.dart';
import 'package:solar_network_sdk/src/models/posts/post.dart';
import 'package:solar_network_sdk/src/models/posts/post_tag.dart';
import 'package:solar_network_sdk/src/models/posts/publisher.dart';
import 'package:solar_network_sdk/src/models/posts/post_category.dart';
import 'package:solar_network_sdk/src/models/posts/embed.dart';
import 'package:solar_network_sdk/src/models/posts/heatmap.dart';
import 'package:solar_network_sdk/src/models/posts/post_collection.dart';
import 'package:solar_network_sdk/src/models/posts/tag_quota.dart';
import 'package:solar_network_sdk/src/models/posts/publisher_rating_record.dart';
import 'package:solar_network_sdk/src/models/posts/publisher_leaderboard.dart';

/// API for posts-related endpoints (/sphere).
///
/// Handles posts, publishers, categories, tags, and related functionality.
class SphereApi extends BaseApi {
  SphereApi(super.dio);

  /// Base path for all sphere endpoints.
  static const String _basePath = '/sphere';

  /// Base path for publisher-scoped endpoints behind gateway.
  ///
  /// Collections live under `/sphere/pub/...`.
  static const String _pubBasePath = '/sphere';

  // ==========================================
  // Post endpoints
  // ==========================================

  /// Gets a post by ID.
  ///
  /// [postId] - The post ID.
  Future<SnPost> getPost(String postId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/posts/$postId',
    );
    return SnPost.fromJson(response.data!);
  }

  // ==========================================
  // Post collection endpoints
  // ==========================================

  /// Lists collections owned by a publisher.
  Future<List<SnPostCollection>> listPublisherCollections(
    String publisherName,
  ) async {
    final response = await get<List<dynamic>>(
      '$_pubBasePath/publishers/$publisherName/collections',
    );
    return parseList(response, SnPostCollection.fromJson);
  }

  /// Gets a collection by slug.
  Future<SnPostCollection> getPublisherCollection({
    required String publisherName,
    required String slug,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug',
    );
    return SnPostCollection.fromJson(response.data!);
  }

  /// Creates a collection.
  Future<SnPostCollection> createPublisherCollection({
    required String publisherName,
    required String slug,
    String? name,
    String? description,
    String? backgroundId,
    String? iconId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_pubBasePath/publishers/$publisherName/collections',
      data: {
        'slug': slug,
        'name': name,
        'description': description,
        'background_id': backgroundId,
        'icon_id': iconId,
      }..removeWhere((_, v) => v == null),
    );
    return SnPostCollection.fromJson(response.data!);
  }

  /// Updates a collection.
  Future<SnPostCollection> updatePublisherCollection({
    required String publisherName,
    required String slug,
    String? name,
    String? description,
    String? backgroundId,
    bool clearBackground = false,
    String? iconId,
    bool clearIcon = false,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (clearBackground) {
      data['background_id'] = null;
    } else if (backgroundId != null) {
      data['background_id'] = backgroundId;
    }
    if (clearIcon) {
      data['icon_id'] = null;
    } else if (iconId != null) {
      data['icon_id'] = iconId;
    }
    final response = await patch<Map<String, dynamic>>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug',
      data: data,
    );
    return SnPostCollection.fromJson(response.data!);
  }

  /// Deletes a collection.
  Future<void> deletePublisherCollection({
    required String publisherName,
    required String slug,
  }) async {
    await delete('$_pubBasePath/publishers/$publisherName/collections/$slug');
  }

  /// Lists posts in a collection.
  Future<PaginatedResult<SnPost>> listPublisherCollectionPosts({
    required String publisherName,
    required String slug,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug/posts',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPost.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Reorders collection posts.
  Future<void> reorderPublisherCollectionPosts({
    required String publisherName,
    required String slug,
    required List<String> postIds,
  }) async {
    await put<void>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug/posts/reorder',
      data: {'post_ids': postIds},
    );
  }

  /// Gets previous visible post in collection order.
  Future<SnPost> getPublisherCollectionPrevPost({
    required String publisherName,
    required String slug,
    required String postId,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug/posts/$postId/prev',
    );
    return SnPost.fromJson(response.data!);
  }

  /// Gets next visible post in collection order.
  Future<SnPost> getPublisherCollectionNextPost({
    required String publisherName,
    required String slug,
    required String postId,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug/posts/$postId/next',
    );
    return SnPost.fromJson(response.data!);
  }

  /// Adds a post to a collection.
  ///
  /// If [order] is null, the server appends to the end.
  Future<void> addPostToCollection({
    required String publisherName,
    required String slug,
    required String postId,
    int? order,
  }) async {
    await post<void>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug/posts',
      data: {'post_id': postId, 'order': order}
        ..removeWhere((_, v) => v == null),
    );
  }

  /// Removes a post from a collection.
  Future<void> removePostFromCollection({
    required String publisherName,
    required String slug,
    required String postId,
  }) async {
    await delete<void>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug/posts/$postId',
    );
  }

  /// Batch adds posts to a collection.
  Future<void> batchAddPostsToCollection({
    required String publisherName,
    required String slug,
    required List<String> postIds,
  }) async {
    await post<void>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug/posts/batch',
      data: {'post_ids': postIds},
    );
  }

  /// Batch removes posts from a collection.
  Future<void> batchRemovePostsFromCollection({
    required String publisherName,
    required String slug,
    required List<String> postIds,
  }) async {
    await post<void>(
      '$_pubBasePath/publishers/$publisherName/collections/$slug/posts/batch/remove',
      data: {'post_ids': postIds},
    );
  }

  /// Batch deletes posts.
  Future<void> batchDeletePosts(List<String> postIds) async {
    await post<void>(
      '$_basePath/posts/batch/delete',
      data: {'post_ids': postIds},
    );
  }

  /// Batch updates post visibility.
  Future<void> batchUpdatePostVisibility({
    required List<String> postIds,
    String? visibility,
    DateTime? draftedAt,
    DateTime? publishedAt,
  }) async {
    await post<void>(
      '$_basePath/posts/batch/visibility',
      data: {
        'post_ids': postIds,
        'visibility': visibility,
        'drafted_at': draftedAt?.toUtc().toIso8601String(),
        'published_at': publishedAt?.toUtc().toIso8601String(),
      }..removeWhere((_, value) => value == null),
    );
  }

  /// Gets a list of posts.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  /// [sort] - Sort order.
  Future<PaginatedResult<SnPost>> getPosts({
    int offset = 0,
    int take = 20,
    String? sort,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/posts',
      queryParameters: {'offset': offset, 'take': take, 'sort': sort}
        ..removeWhere((_, v) => v == null),
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPost.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Creates a new post.
  ///
  /// [content] - The post content.
  /// [metadata] - Optional metadata.
  Future<SnPost> createPost({
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/posts',
      data: {'content': content, ...?metadata},
    );
    return SnPost.fromJson(response.data!);
  }

  /// Updates a post.
  ///
  /// [postId] - The post ID.
  /// [data] - The data to update.
  Future<SnPost> updatePost({
    required String postId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/posts/$postId',
      data: data,
    );
    return SnPost.fromJson(response.data!);
  }

  /// Deletes a post.
  ///
  /// [postId] - The post ID.
  Future<void> deletePost(String postId) async {
    await delete('$_basePath/posts/$postId');
  }

  /// Pins a post.
  ///
  /// [postId] - The post ID.
  Future<void> pinPost(String postId) async {
    await post('$_basePath/posts/$postId/pin');
  }

  /// Unpins a post.
  ///
  /// [postId] - The post ID.
  Future<void> unpinPost(String postId) async {
    await delete('$_basePath/posts/$postId/pin');
  }

  /// Boosts/reposts a post.
  ///
  /// [postId] - The post ID.
  Future<void> boostPost(String postId) async {
    await post('$_basePath/posts/$postId/boost');
  }

  /// Unboosts a post.
  ///
  /// [postId] - The post ID.
  Future<void> unboostPost(String postId) async {
    await delete('$_basePath/posts/$postId/boost');
  }

  /// Gets the current user's bookmark for a post.
  ///
  /// [postId] - The post ID.
  /// Returns the bookmark if it exists, or null.
  Future<SnPostBookmark?> getPostBookmark(String postId) async {
    final response = await get<dynamic>('$_basePath/posts/$postId/bookmark');
    if (response.statusCode == 204) return null;
    return SnPostBookmark.fromJson(response.data as Map<String, dynamic>);
  }

  /// Bookmarks a post.
  ///
  /// [postId] - The post ID.
  /// Returns the bookmark record.
  Future<SnPostBookmark> bookmarkPost(String postId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/posts/$postId/bookmark',
    );
    return SnPostBookmark.fromJson(response.data!);
  }

  /// Removes a bookmark from a post.
  ///
  /// [postId] - The post ID.
  Future<void> unbookmarkPost(String postId) async {
    await delete('$_basePath/posts/$postId/bookmark');
  }

  /// Gets the current user's bookmarked posts.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  /// [order] - Sort order (e.g. "created").
  Future<PaginatedResult<SnPost>> getBookmarks({
    int offset = 0,
    int take = 20,
    String? order,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/posts/bookmarks',
      queryParameters: {'offset': offset, 'take': take, 'order': ?order},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPost.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets replies to a post.
  ///
  /// [postId] - The post ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPost>> getPostReplies({
    required String postId,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/posts/$postId/replies',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPost.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets featured replies to a post.
  ///
  /// [postId] - The post ID.
  Future<List<SnPost>> getFeaturedReplies(String postId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/posts/$postId/replies/featured',
    );
    return parseList(response, SnPost.fromJson);
  }

  /// Creates a reply to a post.
  ///
  /// [postId] - The post ID.
  /// [content] - The reply content.
  Future<SnPost> createReply({
    required String postId,
    required String content,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/posts/$postId/replies',
      data: {'content': content},
    );
    return SnPost.fromJson(response.data!);
  }

  /// Gets reactions for a post.
  ///
  /// [postId] - The post ID.
  /// [symbol] - Optional emoji symbol to filter by.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  /// [order] - Sort order ("created" or default by symbol).
  Future<PaginatedResult<SnPostReaction>> getPostReactions({
    required String postId,
    String? symbol,
    int offset = 0,
    int take = 20,
    String? order,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/posts/$postId/reactions',
      queryParameters: {
        'offset': offset,
        'take': take,
        'symbol': ?symbol,
        'order': ?order,
      },
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPostReaction.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Adds a reaction to a post.
  ///
  /// [postId] - The post ID.
  /// [reactionType] - The reaction type (emoji).
  Future<void> addReaction({
    required String postId,
    required String reactionType,
  }) async {
    await post(
      '$_basePath/posts/$postId/reactions',
      data: {'type': reactionType},
    );
  }

  /// Removes a reaction from a post.
  ///
  /// [postId] - The post ID.
  Future<void> removeReaction(String postId) async {
    await delete('$_basePath/posts/$postId/reactions');
  }

  /// Gets visible reactions made by a specific user.
  ///
  /// [name] - The local username.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  /// [order] - Sort order ("created" or default).
  Future<PaginatedResult<UserReactionListingItem>> getUserReactions({
    required String name,
    int offset = 0,
    int take = 20,
    String? order,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/posts/reactions/users/$name',
      queryParameters: {'offset': offset, 'take': take, 'order': ?order},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(
      response,
      (json) => UserReactionListingItem.fromJson(json),
    );
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets awards for a post.
  ///
  /// [postId] - The post ID.
  Future<List<SnPostAward>> getPostAwards(String postId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/posts/$postId/awards',
    );
    return parseList(response, SnPostAward.fromJson);
  }

  /// Gives an award to a post.
  ///
  /// [postId] - The post ID.
  /// [awardType] - The award type.
  Future<void> giveAward({
    required String postId,
    required String awardType,
  }) async {
    await post('$_basePath/posts/$postId/awards', data: {'type': awardType});
  }

  /// Gets the heatmap for posts.
  ///
  /// [username] - Optional username to filter by.
  /// [year] - Optional year filter.
  /// [month] - Optional month filter.
  Future<SnHeatmap> getPostHeatmap({
    String? username,
    int? year,
    int? month,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/posts/heatmap',
      queryParameters: {'username': ?username, 'year': ?year, 'month': ?month},
    );
    return SnHeatmap.fromJson(response.data!);
  }

  // ==========================================
  // Publisher endpoints
  // ==========================================

  /// Gets a publisher by username.
  ///
  /// [username] - The publisher username.
  Future<SnPublisher> getPublisher(String username) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/publishers/$username',
    );
    return SnPublisher.fromJson(response.data!);
  }

  /// Creates a new publisher.
  ///
  /// [name] - The publisher name.
  /// [metadata] - Optional metadata.
  Future<SnPublisher> createPublisher({
    required String name,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/publishers',
      data: {'name': name, ...?metadata},
    );
    return SnPublisher.fromJson(response.data!);
  }

  /// Updates a publisher.
  ///
  /// [username] - The publisher username.
  /// [data] - The data to update.
  Future<SnPublisher> updatePublisher({
    required String username,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/publishers/$username',
      data: data,
    );
    return SnPublisher.fromJson(response.data!);
  }

  /// Deletes a publisher.
  ///
  /// [username] - The publisher username.
  Future<void> deletePublisher(String username) async {
    await delete('$_basePath/publishers/$username');
  }

  /// Gets posts by a publisher.
  ///
  /// [username] - The publisher username.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPost>> getPublisherPosts({
    required String username,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/publishers/$username/posts',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPost.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets the subscription status for a publisher.
  ///
  /// [username] - The publisher username.
  Future<SnPublisherSubscriptionStatus> getPublisherSubscriptionStatus(
    String username,
  ) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/publishers/$username/subscription',
    );
    return SnPublisherSubscriptionStatus.fromJson(response.data!);
  }

  /// Subscribes to a publisher.
  ///
  /// [username] - The publisher username.
  Future<void> subscribeToPublisher(String username) async {
    await post('$_basePath/publishers/$username/subscribe');
  }

  /// Unsubscribes from a publisher.
  ///
  /// [username] - The publisher username.
  Future<void> unsubscribeFromPublisher(String username) async {
    await post('$_basePath/publishers/$username/unsubscribe');
  }

  /// Gets a publisher's current rating score.
  ///
  /// [name] - The publisher name.
  Future<double> getPublisherRating(String name) async {
    final response = await get<double>('$_basePath/publishers/$name/rating');
    return response.data!;
  }

  /// Gets a paginated list of rating history records for a publisher.
  ///
  /// [name] - The publisher name.
  /// [take] - Number of items to take (default: 20).
  /// [offset] - Pagination offset (default: 0).
  Future<PaginatedResult<SnPublisherRatingRecord>> getPublisherRatingHistory(
    String name, {
    int take = 20,
    int offset = 0,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/publishers/$name/rating/history',
      queryParameters: {'take': take, 'offset': offset},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPublisherRatingRecord.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a publisher's rating overview with percentile and grade.
  ///
  /// [name] - The publisher name.
  Future<SnPublisherRatingOverview> getPublisherRatingOverview(
    String name,
  ) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/publishers/$name/rating/overview',
    );
    return SnPublisherRatingOverview.fromJson(response.data!);
  }

  /// Gets the publisher leaderboard sorted by rating descending.
  ///
  /// [take] - Number of items to take (default: 20).
  /// [offset] - Pagination offset (default: 0).
  Future<PaginatedResult<SnPublisherLeaderboardEntry>> getPublisherLeaderboard({
    int take = 20,
    int offset = 0,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/publishers/leaderboard',
      queryParameters: {'take': take, 'offset': offset},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPublisherLeaderboardEntry.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets publisher features.
  ///
  /// [username] - The publisher username.
  Future<List<SnPostFeaturedRecord>> getPublisherFeatures(
    String username,
  ) async {
    final response = await get<List<dynamic>>(
      '$_basePath/publishers/$username/features',
    );
    return parseList(response, SnPostFeaturedRecord.fromJson);
  }

  /// Gets publisher heatmap.
  ///
  /// [username] - The publisher username.
  Future<SnHeatmap> getPublisherHeatmap(String username) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/publishers/$username/heatmap',
    );
    return SnHeatmap.fromJson(response.data!);
  }

  // ==========================================
  // Category endpoints
  // ==========================================

  /// Gets all categories.
  Future<List<SnPostCategory>> getCategories() async {
    final response = await get<List<dynamic>>('$_basePath/categories');
    return parseList(response, SnPostCategory.fromJson);
  }

  /// Gets a category by slug.
  ///
  /// [slug] - The category slug.
  Future<SnPostCategory> getCategory(String slug) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/categories/$slug',
    );
    return SnPostCategory.fromJson(response.data!);
  }

  /// Gets posts in a category.
  ///
  /// [slug] - The category slug.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPost>> getCategoryPosts({
    required String slug,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/categories/$slug/posts',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPost.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Subscribes to a category.
  ///
  /// [slug] - The category slug.
  Future<void> subscribeToCategory(String slug) async {
    await post('$_basePath/categories/$slug/subscribe');
  }

  /// Unsubscribes from a category.
  ///
  /// [slug] - The category slug.
  Future<void> unsubscribeFromCategory(String slug) async {
    await post('$_basePath/categories/$slug/unsubscribe');
  }

  /// Gets subscription status for a category.
  ///
  /// [slug] - The category slug.
  Future<SnCategorySubscription> getCategorySubscriptionStatus(
    String slug,
  ) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/categories/$slug/subscription',
    );
    return SnCategorySubscription.fromJson(response.data!);
  }

  // ==========================================
  // Tag endpoints
  // ==========================================

  /// Gets posts by a tag.
  ///
  /// [tag] - The tag name.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPost>> getPostsByTag({
    required String tag,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/tags/$tag/posts',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPost.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a tag by slug.
  ///
  /// [slug] - The tag slug.
  Future<SnPostTag> getTag(String slug) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/posts/tags/$slug',
    );
    return SnPostTag.fromJson(response.data!);
  }

  /// Creates a new tag.
  ///
  /// [slug] - Unique tag identifier.
  /// [name] - Display name (optional).
  /// [description] - Tag description (optional).
  /// [publisherName] - Publisher name to associate with the tag.
  Future<SnPostTag> createTag({
    required String slug,
    String? name,
    String? description,
    String? publisherName,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/posts/tags',
      queryParameters: {'pub': ?publisherName},
      data: {'slug': slug, 'name': ?name, 'description': ?description},
    );
    return SnPostTag.fromJson(response.data!);
  }

  /// Updates a tag.
  ///
  /// [slug] - The tag slug.
  /// [name] - New display name (optional).
  /// [description] - New description (optional).
  /// [publisherName] - Publisher name for authorization.
  Future<SnPostTag> updateTag({
    required String slug,
    String? name,
    String? description,
    String? publisherName,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/posts/tags/$slug',
      queryParameters: {'pub': ?publisherName},
      data: {'name': ?name, 'description': ?description},
    );
    return SnPostTag.fromJson(response.data!);
  }

  /// Claims ownership of an unowned tag.
  ///
  /// [slug] - The tag slug to claim.
  /// [publisherName] - Publisher name that will own the tag.
  Future<SnPostTag> claimTag({
    required String slug,
    String? publisherName,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/posts/tags/$slug/claim',
      queryParameters: {'pub': ?publisherName},
    );
    return SnPostTag.fromJson(response.data!);
  }

  /// Gets the protected tag quota for a publisher.
  ///
  /// [slug] - The tag slug.
  /// [publisherName] - Publisher name to check quota for.
  Future<SnTagQuota> getProtectedTagQuota({
    required String slug,
    String? publisherName,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/posts/tags/$slug/quota',
      queryParameters: {'pub': ?publisherName},
    );
    return SnTagQuota.fromJson(response.data!);
  }

  // ==========================================
  // Admin tag endpoints
  // ==========================================

  /// Assigns a tag to a publisher (admin only).
  ///
  /// [slug] - The tag slug.
  /// [publisherId] - The publisher ID to assign ownership to.
  Future<SnPostTag> assignTagOwnership({
    required String slug,
    required String publisherId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/admin/posts/tags/$slug/assign',
      data: {'publisher_id': publisherId},
    );
    return SnPostTag.fromJson(response.data!);
  }

  /// Toggles protected status on a tag (admin only).
  ///
  /// [slug] - The tag slug.
  /// [isProtected] - Whether the tag should be protected.
  Future<SnPostTag> toggleTagProtection({
    required String slug,
    required bool isProtected,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/admin/posts/tags/$slug/protect',
      data: {'is_protected': isProtected},
    );
    return SnPostTag.fromJson(response.data!);
  }

  /// Sets or removes event status on a tag (admin only).
  ///
  /// [slug] - The tag slug.
  /// [isEvent] - Whether the tag is an event tag.
  /// [endsAt] - When the event tag expires (required if isEvent is true).
  Future<SnPostTag> setTagEventStatus({
    required String slug,
    required bool isEvent,
    DateTime? endsAt,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/admin/posts/tags/$slug/event',
      data: {
        'is_event': isEvent,
        if (endsAt != null) 'ends_at': endsAt.toIso8601String(),
      },
    );
    return SnPostTag.fromJson(response.data!);
  }

  /// Updates a tag as admin (admin only).
  ///
  /// [slug] - The tag slug.
  /// [name] - New display name (optional).
  /// [description] - New description (optional).
  Future<SnPostTag> adminUpdateTag({
    required String slug,
    String? name,
    String? description,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/admin/posts/tags/$slug',
      data: {'name': ?name, 'description': ?description},
    );
    return SnPostTag.fromJson(response.data!);
  }

  // ==========================================
  // Timeline endpoints
  // ==========================================

  /// Gets the home timeline.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPost>> getHomeTimeline({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/timeline/home',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPost.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  // ==========================================
  // Search endpoints
  // ==========================================

  /// Searches posts.
  ///
  /// [query] - The search query.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPost>> searchPosts({
    required String query,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/search/posts',
      queryParameters: {'q': query, 'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPost.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Searches publishers.
  ///
  /// [query] - The search query.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnPublisher>> searchPublishers({
    required String query,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/search/publishers',
      queryParameters: {'q': query, 'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnPublisher.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  // ==========================================
  // Embed endpoints
  // ==========================================

  /// Gets a link preview/scraped data.
  ///
  /// [url] - The URL to scrape.
  Future<SnScrappedLink> getLinkPreview(String url) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/embed/preview',
      queryParameters: {'url': url},
    );
    return SnScrappedLink.fromJson(response.data!);
  }

  /// Gets publishers associated with an account.
  ///
  /// [accountId] - The account ID.
  Future<List<SnPublisher>> getAccountPublishers(String accountId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/publishers/of/$accountId',
    );
    return parseList(response, SnPublisher.fromJson);
  }

  // ==========================================
  // Discovery endpoints
  // ==========================================

  /// Gets the discovery profile.
  Future<SnDiscoveryProfile> getDiscoveryProfile() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/timeline/discovery/profile',
    );
    return SnDiscoveryProfile.fromJson(response.data!);
  }

  /// Resets the discovery profile.
  Future<void> resetDiscoveryProfile() async {
    await post('$_basePath/timeline/discovery/reset');
  }

  // ==========================================
  // Publishing settings endpoints
  // ==========================================

  /// Gets the account publishing settings.
  Future<SnPublishingSettings> getPublishingSettings() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/account/publishing',
    );
    return SnPublishingSettings.fromJson(response.data!);
  }

  /// Updates the account publishing settings.
  ///
  /// [defaultPostingPublisherId] - Default publisher for creating posts.
  /// [defaultReplyPublisherId] - Default publisher for replies.
  /// [defaultFediversePublisherId] - Default publisher with Fediverse actor.
  Future<SnPublishingSettings> updatePublishingSettings({
    String? defaultPostingPublisherId,
    String? defaultReplyPublisherId,
    String? defaultFediversePublisherId,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/account/publishing',
      data: {
        'default_posting_publisher_id': defaultPostingPublisherId,
        'default_reply_publisher_id': defaultReplyPublisherId,
        'default_fediverse_publisher_id': defaultFediversePublisherId,
      },
    );
    return SnPublishingSettings.fromJson(response.data!);
  }

  // ==========================================
  // Fediverse endpoints
  // ==========================================

  /// Gets the Fediverse availability for publishers.
  ///
  /// Returns publishers owned by the user that have Fediverse enabled.
  Future<SnFediverseAvailabilityResponse> getFediverseAvailability() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/fediverse/actors/availability',
    );
    return SnFediverseAvailabilityResponse.fromJson(response.data!);
  }
}
