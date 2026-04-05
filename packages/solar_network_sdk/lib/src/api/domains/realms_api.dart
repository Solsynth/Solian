import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/chat/chat.dart';
import 'package:solar_network_sdk/src/models/realms/realm.dart';

/// API for realm-related endpoints (/passport/realms).
///
/// Handles realms, members, labels, and realm management.
class RealmsApi extends BaseApi {
  RealmsApi(super.dio);

  /// Base path for all realm endpoints.
  static const String _basePath = '/passport/realms';

  // ==========================================
  // Realm endpoints
  // ==========================================

  /// Gets all realms.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnRealm>> getRealms({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      _basePath,
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnRealm.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets a specific realm by slug.
  ///
  /// [slug] - The realm slug.
  Future<SnRealm> getRealm(String slug) async {
    final response = await get<Map<String, dynamic>>('$_basePath/$slug');
    return SnRealm.fromJson(response.data!);
  }

  /// Creates a new realm.
  ///
  /// [slug] - The realm slug.
  /// [name] - The realm name.
  /// [description] - Optional description.
  /// [isPublic] - Whether the realm is public.
  Future<SnRealm> createRealm({
    required String slug,
    required String name,
    String? description,
    bool isPublic = true,
  }) async {
    final response = await post<Map<String, dynamic>>(
      _basePath,
      data: {
        'slug': slug,
        'name': name,
        'description': ?description,
        'is_public': isPublic,
      },
    );
    return SnRealm.fromJson(response.data!);
  }

  /// Updates a realm.
  ///
  /// [slug] - The realm slug.
  /// [data] - The data to update.
  Future<SnRealm> updateRealm({
    required String slug,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/$slug',
      data: data,
    );
    return SnRealm.fromJson(response.data!);
  }

  /// Deletes a realm.
  ///
  /// [slug] - The realm slug.
  Future<void> deleteRealm(String slug) async {
    await delete('$_basePath/$slug');
  }

  // ==========================================
  // Member endpoints
  // ==========================================

  /// Gets members of a realm.
  ///
  /// [slug] - The realm slug.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnRealmMember>> getMembers({
    required String slug,
    int offset = 0,
    int take = 50,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/$slug/members',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnRealmMember.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Joins a realm.
  ///
  /// [slug] - The realm slug.
  Future<void> joinRealm(String slug) async {
    await post('$_basePath/$slug/members/me');
  }

  /// Leaves a realm.
  ///
  /// [slug] - The realm slug.
  Future<void> leaveRealm(String slug) async {
    await delete('$_basePath/$slug/members/me');
  }

  /// Gets the current user's membership in a realm.
  ///
  /// [slug] - The realm slug.
  Future<SnRealmMember> getMyMembership(String slug) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/$slug/members/me',
    );
    return SnRealmMember.fromJson(response.data!);
  }

  /// Updates the current user's membership.
  ///
  /// [slug] - The realm slug.
  /// [data] - The data to update (e.g., nick, bio).
  Future<SnRealmMember> updateMyMembership({
    required String slug,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/$slug/members/me',
      data: data,
    );
    return SnRealmMember.fromJson(response.data!);
  }

  /// Kicks a member from a realm.
  ///
  /// [slug] - The realm slug.
  /// [accountId] - The account ID to kick.
  Future<void> kickMember({
    required String slug,
    required String accountId,
  }) async {
    await delete('$_basePath/$slug/members/$accountId');
  }

  /// Updates a member's role.
  ///
  /// [slug] - The realm slug.
  /// [accountId] - The account ID.
  /// [role] - The new role.
  Future<SnRealmMember> updateMemberRole({
    required String slug,
    required String accountId,
    required int role,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/$slug/members/$accountId/role',
      data: {'role': role},
    );
    return SnRealmMember.fromJson(response.data!);
  }

  // ==========================================
  // Label endpoints
  // ==========================================

  /// Gets labels for a realm.
  ///
  /// [slug] - The realm slug.
  Future<List<SnRealmLabel>> getLabels(String slug) async {
    final response = await get<List<dynamic>>('$_basePath/$slug/labels');
    return parseList(response, SnRealmLabel.fromJson);
  }

  /// Creates a new label.
  ///
  /// [slug] - The realm slug.
  /// [name] - The label name.
  /// [description] - Optional description.
  /// [color] - Optional color.
  Future<SnRealmLabel> createLabel({
    required String slug,
    required String name,
    String? description,
    String? color,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/$slug/labels',
      data: {'name': name, 'description': ?description, 'color': ?color},
    );
    return SnRealmLabel.fromJson(response.data!);
  }

  /// Updates a label.
  ///
  /// [slug] - The realm slug.
  /// [labelId] - The label ID.
  /// [data] - The data to update.
  Future<SnRealmLabel> updateLabel({
    required String slug,
    required String labelId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/$slug/labels/$labelId',
      data: data,
    );
    return SnRealmLabel.fromJson(response.data!);
  }

  /// Deletes a label.
  ///
  /// [slug] - The realm slug.
  /// [labelId] - The label ID.
  Future<void> deleteLabel({
    required String slug,
    required String labelId,
  }) async {
    await delete('$_basePath/$slug/labels/$labelId');
  }

  /// Assigns a label to a member.
  ///
  /// [slug] - The realm slug.
  /// [accountId] - The account ID.
  /// [labelId] - The label ID.
  Future<void> assignLabel({
    required String slug,
    required String accountId,
    required String labelId,
  }) async {
    await post(
      '$_basePath/$slug/members/$accountId/label',
      data: {'label_id': labelId},
    );
  }

  /// Removes a label from a member.
  ///
  /// [slug] - The realm slug.
  /// [accountId] - The account ID.
  Future<void> removeLabel({
    required String slug,
    required String accountId,
  }) async {
    await delete('$_basePath/$slug/members/$accountId/label');
  }

  // ==========================================
  // Boost endpoints
  // ==========================================

  /// Gets boost status for a realm.
  ///
  /// [slug] - The realm slug.
  Future<Map<String, dynamic>> getBoostStatus(String slug) async {
    final response = await get<Map<String, dynamic>>('$_basePath/$slug/boosts');
    return response.data!;
  }

  /// Gets boost leaderboard for a realm.
  ///
  /// [slug] - The realm slug.
  /// [take] - Number of items to return.
  Future<List<dynamic>> getBoostLeaderboard({
    required String slug,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/$slug/boosts/leaderboard',
      queryParameters: {'take': take},
    );
    return response.data ?? [];
  }

  /// Boosts a realm.
  ///
  /// [slug] - The realm slug.
  /// [amount] - The boost amount.
  Future<Map<String, dynamic>> boostRealm({
    required String slug,
    required double amount,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/$slug/boosts',
      data: {'amount': amount},
    );
    return response.data!;
  }

  // ==========================================
  // Chat endpoints
  // ==========================================

  /// Gets the chat room for a realm.
  ///
  /// [slug] - The realm slug.
  Future<List<SnChatRoom>> getRealmChat(String slug) async {
    final response = await get<List<dynamic>>('/messager/realms/$slug/chat');
    return response.data!
        .map((e) => SnChatRoom.fromJson(e))
        .cast<SnChatRoom>()
        .toList();
  }

  // ==========================================
  // Feed endpoints
  // ==========================================

  /// Gets the feed for a realm.
  ///
  /// [slug] - The realm slug.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<dynamic>> getRealmFeed({
    required String slug,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/$slug/feed',
      queryParameters: {'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    return PaginatedResult(items: response.data ?? [], totalCount: totalCount);
  }

  // ==========================================
  // Search endpoints
  // ==========================================

  /// Searches realms.
  ///
  /// [query] - The search query.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<PaginatedResult<SnRealm>> searchRealms({
    required String query,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/search',
      queryParameters: {'q': query, 'offset': offset, 'take': take},
    );
    final totalCount = getTotalCount(response.headers);
    final items = parseList(response, SnRealm.fromJson);
    return PaginatedResult(items: items, totalCount: totalCount);
  }

  /// Gets trending realms.
  ///
  /// [limit] - Number of realms to return.
  Future<List<SnRealm>> getTrendingRealms({int limit = 10}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/trending',
      queryParameters: {'limit': limit},
    );
    return parseList(response, SnRealm.fromJson);
  }

  /// Gets recommended realms.
  ///
  /// [limit] - Number of realms to return.
  Future<List<SnRealm>> getRecommendedRealms({int limit = 10}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/recommended',
      queryParameters: {'limit': limit},
    );
    return parseList(response, SnRealm.fromJson);
  }
}
