import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/activitypub.dart';
import 'package:island/pods/network.dart';

final activityPubServiceProvider = Provider<ActivityPubService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ActivityPubService(client);
});

class ActivityPubService {
  final Dio _client;

  ActivityPubService(this._client);

  Future<void> followRemoteUser(String targetActorUri) async {
    final response = await _client.post(
      '/sphere/activitypub/follow',
      data: {'target_actor_uri': targetActorUri},
    );
    final followResponse = SnActivityPubFollowResponse.fromJson(response.data);
    if (!followResponse.success) {
      throw Exception(followResponse.message);
    }
  }

  Future<void> unfollowRemoteUser(String targetActorUri) async {
    final response = await _client.post(
      '/sphere/activitypub/unfollow',
      data: {'target_actor_uri': targetActorUri},
    );
    final followResponse = SnActivityPubFollowResponse.fromJson(response.data);
    if (!followResponse.success) {
      throw Exception(followResponse.message);
    }
  }

  Future<List<SnActivityPubUser>> getFollowing({int limit = 50}) async {
    final response = await _client.get(
      '/sphere/activitypub/following',
      queryParameters: {'limit': limit},
    );
    final users = (response.data as List<dynamic>)
        .map((json) => SnActivityPubUser.fromJson(json))
        .toList();
    return users;
  }

  Future<List<SnActivityPubUser>> getFollowers({int limit = 50}) async {
    final response = await _client.get(
      '/sphere/activitypub/followers',
      queryParameters: {'limit': limit},
    );
    final users = (response.data as List<dynamic>)
        .map((json) => SnActivityPubUser.fromJson(json))
        .toList();
    return users;
  }

  Future<List<SnActivityPubActor>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    final response = await _client.get(
      '/sphere/activitypub/search',
      queryParameters: {'query': query, 'limit': limit},
    );
    final users = (response.data as List<dynamic>)
        .map((json) => SnActivityPubActor.fromJson(json))
        .toList();
    return users;
  }
}
