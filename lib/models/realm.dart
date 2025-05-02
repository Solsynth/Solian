import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';

part 'realm.freezed.dart';
part 'realm.g.dart';

@freezed
abstract class SnRealm with _$SnRealm {
  const factory SnRealm({
    required int id,
    required String slug,
    required String name,
    required String description,
    required String? verifiedAs,
    required DateTime? verifiedAt,
    required bool isCommunity,
    required bool isPublic,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required int accountId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnRealm;

  factory SnRealm.fromJson(Map<String, dynamic> json) =>
      _$SnRealmFromJson(json);
}
