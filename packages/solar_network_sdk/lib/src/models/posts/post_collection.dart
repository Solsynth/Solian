import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:solar_network_sdk/src/models/drive/file.dart';
import 'package:solar_network_sdk/src/models/posts/publisher.dart';

part 'post_collection.freezed.dart';
part 'post_collection.g.dart';

@freezed
sealed class SnPostCollection with _$SnPostCollection {
  const factory SnPostCollection({
    required String id,
    required String slug,
    String? name,
    String? description,
    @JsonKey(name: 'publisher_id') required String publisherId,
    SnPublisher? publisher,
    SnCloudFileReference? background,
    SnCloudFileReference? icon,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
  }) = _SnPostCollection;

  factory SnPostCollection.fromJson(Map<String, dynamic> json) =>
      _$SnPostCollectionFromJson(json);
}
