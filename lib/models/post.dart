import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
abstract class SnPost with _$SnPost {
  const factory SnPost({
    required int id,
    required String? title,
    required String? description,
    required String? language,
    required DateTime? editedAt,
    required DateTime publishedAt,
    required int visibility,
    required String content,
    required int type,
    required Map<String, dynamic>? meta,
    required int viewsUnique,
    required int viewsTotal,
    required int upvotes,
    required int downvotes,
    required dynamic threadedPostId,
    required dynamic threadedPost,
    required dynamic repliedPostId,
    required dynamic repliedPost,
    required dynamic forwardedPostId,
    required dynamic forwardedPost,
    required List<SnCloudFile> attachments,
    required SnPublisher publisher,
    required List<dynamic> reactions,
    required List<dynamic> tags,
    required List<dynamic> categories,
    required List<dynamic> collections,
    required bool empty,
    required DateTime createdAt,
    required DateTime updatedAt,
    required dynamic deletedAt,
  }) = _SnPost;

  factory SnPost.fromJson(Map<String, dynamic> json) => _$SnPostFromJson(json);
}

@freezed
abstract class SnPublisher with _$SnPublisher {
  const factory SnPublisher({
    required int id,
    required int publisherType,
    required String name,
    required String nick,
    required String bio,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required int accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnPublisher;

  factory SnPublisher.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherFromJson(json);
}
