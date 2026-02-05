import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/accounts/accounts_models/account.dart';

part 'publisher.freezed.dart';
part 'publisher.g.dart';

@freezed
sealed class SnPublisher with _$SnPublisher {
  const factory SnPublisher({
    @Default('') String id,
    @Default(0) int type,
    @Default('') String name,
    @Default('') String nick,
    @Default('') String bio,
    SnCloudFile? picture,
    SnCloudFile? background,
    SnAccount? account,
    String? accountId,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
    DateTime? deletedAt,
    String? realmId,
    SnVerificationMark? verification,
  }) = _SnPublisher;

  factory SnPublisher.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherFromJson(json);
}

@freezed
sealed class SnPublisherMember with _$SnPublisherMember {
  const factory SnPublisherMember({
    required String publisherId,
    required SnPublisher? publisher,
    required String accountId,
    required SnAccount? account,
    required int role,
    required DateTime? joinedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _SnPublisherMember;

  factory SnPublisherMember.fromJson(Map<String, dynamic> json) =>
      _$SnPublisherMemberFromJson(json);
}
