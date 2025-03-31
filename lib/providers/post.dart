import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/post.dart';

class SnPostContentProvider {
  late final SnNetworkProvider _sn;

  SnPostContentProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
  }

  Future<List<SnPost>> _preloadRelatedDataInBatch(List<SnPost> out) async {
    return out;
  }

  Future<SnPost> _preloadRelatedDataSingle(SnPost out) async {
    return out;
  }

  Future<List<SnPost>> listRecommendations() async {
    final resp = await _sn.client.get(
      '/cgi/co/recommendations',
      options: Options(headers: {
        'X-API-Version': '2',
      }),
    );
    final out = _preloadRelatedDataInBatch(
      List.from(resp.data.map((ele) => SnPost.fromJson(ele))),
    );
    return out;
  }

  Future<List<SnFeedEntry>> getFeed({int take = 20, DateTime? cursor}) async {
    final resp = await _sn.client.get(
      '/cgi/co/recommendations/feed',
      queryParameters: {
        'take': take,
        if (cursor != null) 'cursor': cursor.toUtc().millisecondsSinceEpoch,
      },
      options: Options(headers: {'X-API-Version': '2'}),
    );
    final List<SnFeedEntry> out =
        List.from(resp.data.map((ele) => SnFeedEntry.fromJson(ele)));

    List<SnPost> posts = List.empty(growable: true);
    for (var idx = 0; idx < out.length; idx++) {
      final ele = out[idx];
      if (ele.type == 'interactive.post') {
        posts.add(SnPost.fromJson(ele.data));
      }
    }
    posts = await _preloadRelatedDataInBatch(posts);

    var postsIdx = 0;
    for (var idx = 0; idx < out.length; idx++) {
      final ele = out[idx];
      if (ele.type == 'interactive.post') {
        out[idx] = ele.copyWith(data: posts[postsIdx].toJson());
        postsIdx++;
      }
    }

    return out;
  }

  Future<(List<SnPost>, int)> listPosts({
    int take = 10,
    int offset = 0,
    String? type,
    String? author,
    Iterable<String>? categories,
    Iterable<String>? tags,
    String? realm,
    String? channel,
    bool isDraft = false,
    bool isShuffle = false,
  }) async {
    final resp = await _sn.client.get(
      isShuffle
          ? '/cgi/co/recommendations/shuffle'
          : '/cgi/co/posts${isDraft ? '/drafts' : ''}',
      queryParameters: {
        'take': take,
        'offset': offset,
        if (type != null) 'type': type,
        if (author != null) 'author': author,
        if (tags?.isNotEmpty ?? false) 'tags': tags!.join(','),
        if (categories?.isNotEmpty ?? false)
          'categories': categories!.join(','),
        if (realm != null) 'realm': realm,
        if (channel != null) 'channel': channel,
      },
      options: Options(headers: {
        'X-API-Version': '2',
      }),
    );
    final List<SnPost> out = await _preloadRelatedDataInBatch(
      List.from(resp.data['data']?.map((e) => SnPost.fromJson(e)) ?? []),
    );

    return (out, resp.data['count'] as int);
  }

  Future<(List<SnPost>, int)> listPostReplies(
    dynamic parentId, {
    int take = 10,
    int offset = 0,
  }) async {
    final resp = await _sn.client.get(
      '/cgi/co/posts/$parentId/replies',
      queryParameters: {
        'take': take,
        'offset': offset,
      },
      options: Options(headers: {
        'X-API-Version': '2',
      }),
    );
    final List<SnPost> out = await _preloadRelatedDataInBatch(
      List.from(resp.data['data']?.map((e) => SnPost.fromJson(e)) ?? []),
    );

    return (out, resp.data['count'] as int);
  }

  Future<(List<SnPost>, int)> searchPosts(
    String searchTerm, {
    int take = 10,
    int offset = 0,
    Iterable<String>? tags,
    Iterable<String>? categories,
  }) async {
    final resp = await _sn.client.get(
      '/cgi/co/posts/search',
      queryParameters: {
        'take': take,
        'offset': offset,
        'probe': searchTerm,
        if (tags?.isNotEmpty ?? false) 'tags': tags!.join(','),
        if (categories?.isNotEmpty ?? false)
          'categories': categories!.join(','),
      },
      options: Options(headers: {
        'X-API-Version': '2',
      }),
    );
    final List<SnPost> out = await _preloadRelatedDataInBatch(
      List.from(resp.data['data']?.map((e) => SnPost.fromJson(e)) ?? []),
    );

    return (out, resp.data['count'] as int);
  }

  Future<SnPost> getPost(dynamic id) async {
    final resp = await _sn.client.get(
      '/cgi/co/posts/$id',
      options: Options(headers: {
        'X-API-Version': '2',
      }),
    );
    final out = _preloadRelatedDataSingle(
      SnPost.fromJson(resp.data),
    );
    return out;
  }

  Future<SnPost> completePostData(SnPost post) async {
    final out = await _preloadRelatedDataSingle(post);
    return out;
  }
}
