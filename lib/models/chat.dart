import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';
import 'package:island/models/realm.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
abstract class SnChat with _$SnChat {
  const factory SnChat({
    required int id,
    required String name,
    required String description,
    required int type,
    required bool isPublic,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required int? realmId,
    required SnRealm? realm,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnChat;

  factory SnChat.fromJson(Map<String, dynamic> json) => _$SnChatFromJson(json);
}
