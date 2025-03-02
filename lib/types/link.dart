import 'package:freezed_annotation/freezed_annotation.dart';

part 'link.g.dart';
part 'link.freezed.dart';

@freezed
abstract class SnLinkMeta with _$SnLinkMeta {
  const SnLinkMeta._();

  const factory SnLinkMeta({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
    required String entryId,
    required String? icon,
    required String url,
    required String? title,
    required String? image,
    required String? video,
    required String? audio,
    required String? description,
    required String? siteName,
    required String? type,
  }) = _SnLinkMeta;

  factory SnLinkMeta.fromJson(Map<String, dynamic> json) => _$SnLinkMetaFromJson(json);
}
