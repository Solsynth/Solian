import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/accounts/discovery.dart';
import 'package:solar_network_sdk/src/models/posts/post.dart';
import 'package:solar_network_sdk/src/models/posts/publisher.dart';
import 'package:solar_network_sdk/src/models/posts/post_category.dart';
import 'package:solar_network_sdk/src/models/posts/embed.dart';
import 'package:solar_network_sdk/src/models/posts/heatmap.dart';

/// API for posts-related endpoints (/sphere).
///
/// Handles posts, publishers, categories, tags, and related functionality.
class SphereApi extends BaseApi {
  SphereApi(super.dio);

  /// Base path for all sphere endpoints.
  static const String _basePath = '/sphere';

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
      queryParameters: {'offset': offset, 'take': take, 'sort': ?sort},
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
      data: {'content': content, if (metadata != null) ...metadata},
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
  Future<List<SnPostReaction>> getPostReactions(String postId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/posts/$postId/reactions',
    );
    return parseList(response, SnPostReaction.fromJson);
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
      data: {'name': name, if (metadata != null) ...metadata},
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
}
