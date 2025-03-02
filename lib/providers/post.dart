import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_realm.dart';
import 'package:surface/providers/user_directory.dart';
import 'package:surface/types/poll.dart';
import 'package:surface/types/post.dart';
import 'package:surface/types/realm.dart';

class SnPostContentProvider {
  late final SnNetworkProvider _sn;
  late final UserDirectoryProvider _ud;
  late final SnAttachmentProvider _attach;
  late final SnRealmProvider _realm;

  SnPostContentProvider(BuildContext context) {
    _sn = context.read<SnNetworkProvider>();
    _ud = context.read<UserDirectoryProvider>();
    _attach = context.read<SnAttachmentProvider>();
    _realm = context.read<SnRealmProvider>();
  }

  Future<SnPoll> _fetchPoll(int id) async {
    final resp = await _sn.client.get('/cgi/co/polls/$id');
    return SnPoll.fromJson(resp.data);
  }

  Future<List<SnPost>> _preloadRelatedDataInBatch(List<SnPost> out) async {
    Set<String> rids = {};
    Set<int> uids = {};
    for (var i = 0; i < out.length; i++) {
      rids.addAll(out[i].body['attachments']?.cast<String>() ?? []);
      if (out[i].body['thumbnail'] != null) {
        rids.add(out[i].body['thumbnail']);
      }
      if (out[i].body['video'] != null) {
        rids.add(out[i].body['video']);
      }
      if (out[i].repostTo != null) {
        out[i] = out[i].copyWith(
          repostTo: await _preloadRelatedDataSingle(out[i].repostTo!),
        );
      }
      if (out[i].publisher.type == 0) {
        uids.add(out[i].publisher.accountId);
      }
    }

    final attachments = await _attach.getMultiple(rids.toList());
    for (var i = 0; i < out.length; i++) {
      SnPoll? poll;
      SnRealm? realm;
      if (out[i].pollId != null) {
        poll = await _fetchPoll(out[i].pollId!);
      }
      if (out[i].realmId != null) {
        realm = await _realm.getRealm(out[i].realmId!);
      }

      out[i] = out[i].copyWith(
        preload: SnPostPreload(
          thumbnail: attachments.where((ele) => ele?.rid == out[i].body['thumbnail']).firstOrNull,
          attachments: attachments.where((ele) => out[i].body['attachments']?.contains(ele?.rid) ?? false).toList(),
          video: attachments.where((ele) => ele?.rid == out[i].body['video']).firstOrNull,
          poll: poll,
          realm: realm,
        ),
      );
    }

    uids.addAll(attachments.where((ele) => ele != null).map((ele) => ele!.accountId));
    await _ud.listAccount(uids);

    return out;
  }

  Future<SnPost> _preloadRelatedDataSingle(SnPost out) async {
    Set<String> rids = {};
    Set<int> uids = {};
    rids.addAll(out.body['attachments']?.cast<String>() ?? []);
    if (out.body['thumbnail'] != null) {
      rids.add(out.body['thumbnail']);
    }
    if (out.body['video'] != null) {
      rids.add(out.body['video']);
    }
    if (out.repostTo != null) {
      out = out.copyWith(
        repostTo: await _preloadRelatedDataSingle(out.repostTo!),
      );
    }
    if (out.publisher.type == 0) {
      uids.add(out.publisher.accountId);
    }

    final attachments = await _attach.getMultiple(rids.toList());

    SnPoll? poll;
    SnRealm? realm;
    if (out.pollId != null) {
      poll = await _fetchPoll(out.pollId!);
    }
    if (out.realmId != null) {
      realm = await _realm.getRealm(out.realmId!);
    }

    out = out.copyWith(
      preload: SnPostPreload(
        thumbnail: attachments.where((ele) => ele?.rid == out.body['thumbnail']).firstOrNull,
        attachments: attachments.where((ele) => out.body['attachments']?.contains(ele?.rid) ?? false).toList(),
        video: attachments.where((ele) => ele?.rid == out.body['video']).firstOrNull,
        poll: poll,
        realm: realm,
      ),
    );

    uids.addAll(attachments.where((ele) => ele != null).map((ele) => ele!.accountId));
    await _ud.listAccount(uids);

    return out;
  }

  Future<List<SnPost>> listRecommendations() async {
    final resp = await _sn.client.get('/cgi/co/recommendations');
    final out = _preloadRelatedDataInBatch(
      List.from(resp.data.map((ele) => SnPost.fromJson(ele))),
    );
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
  }) async {
    final resp = await _sn.client.get('/cgi/co/posts', queryParameters: {
      'take': take,
      'offset': offset,
      if (type != null) 'type': type,
      if (author != null) 'author': author,
      if (tags?.isNotEmpty ?? false) 'tags': tags!.join(','),
      if (categories?.isNotEmpty ?? false) 'categories': categories!.join(','),
      if (realm != null) 'realm': realm,
      if (channel != null) 'channel': channel,
    });
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
    final resp = await _sn.client.get('/cgi/co/posts/$parentId/replies', queryParameters: {
      'take': take,
      'offset': offset,
    });
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
    final resp = await _sn.client.get('/cgi/co/posts/search', queryParameters: {
      'take': take,
      'offset': offset,
      'probe': searchTerm,
      if (tags?.isNotEmpty ?? false) 'tags': tags!.join(','),
      if (categories?.isNotEmpty ?? false) 'categories': categories!.join(','),
    });
    final List<SnPost> out = await _preloadRelatedDataInBatch(
      List.from(resp.data['data']?.map((e) => SnPost.fromJson(e)) ?? []),
    );

    return (out, resp.data['count'] as int);
  }

  Future<SnPost> getPost(dynamic id) async {
    final resp = await _sn.client.get('/cgi/co/posts/$id');
    final out = _preloadRelatedDataSingle(
      SnPost.fromJson(resp.data),
    );
    return out;
  }
}
