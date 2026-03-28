import 'package:objectbox/objectbox.dart';

@Entity()
class RealmEntity {
  RealmEntity({
    this.obxId = 0,
    required this.uid,
    required this.slug,
    this.name,
    this.description,
    this.verifiedAs,
    this.verifiedAtMs,
    required this.isCommunity,
    required this.isPublic,
    this.pictureJson,
    this.backgroundJson,
    this.accountId,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });

  @Id()
  int obxId;

  @Unique()
  String uid;

  String slug;
  String? name;
  String? description;
  String? verifiedAs;
  int? verifiedAtMs;
  bool isCommunity;
  bool isPublic;
  String? pictureJson;
  String? backgroundJson;
  String? accountId;
  int createdAtMs;
  int updatedAtMs;
  int? deletedAtMs;
}

@Entity()
class ChatRoomEntity {
  ChatRoomEntity({
    this.obxId = 0,
    required this.uid,
    this.name,
    this.description,
    required this.type,
    this.isPublic = false,
    this.isCommunity = false,
    this.pictureJson,
    this.backgroundJson,
    this.realmId,
    this.accountId,
    this.isPinned = false,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });

  @Id()
  int obxId;

  @Unique()
  String uid;

  String? name;
  String? description;
  int type;
  bool isPublic;
  bool isCommunity;
  String? pictureJson;
  String? backgroundJson;
  String? realmId;
  String? accountId;
  bool isPinned;
  int createdAtMs;
  int updatedAtMs;
  int? deletedAtMs;
}

@Entity()
class ChatMemberEntity {
  ChatMemberEntity({
    this.obxId = 0,
    required this.uid,
    required this.chatRoomId,
    required this.accountId,
    required this.accountJson,
    this.nick,
    required this.notify,
    this.joinedAtMs,
    this.breakUntilMs,
    this.timeoutUntilMs,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });

  @Id()
  int obxId;

  @Unique()
  String uid;

  @Index()
  String chatRoomId;

  @Index()
  String accountId;

  String accountJson;
  String? nick;
  int notify;
  int? joinedAtMs;
  int? breakUntilMs;
  int? timeoutUntilMs;
  int createdAtMs;
  int updatedAtMs;
  int? deletedAtMs;
}

@Entity()
class ChatMessageEntity {
  ChatMessageEntity({
    this.obxId = 0,
    required this.uid,
    required this.roomId,
    required this.senderId,
    this.content,
    this.clientMessageId,
    this.nonce,
    required this.dataJson,
    required this.createdAtMs,
    required this.status,
    this.isDeleted = false,
    this.updatedAtMs,
    this.deletedAtMs,
    this.type = 'text',
    this.metaJson = '{}',
    this.membersMentionedJson = '[]',
    this.editedAtMs,
    this.attachmentsJson = '[]',
    this.reactionsJson = '[]',
    this.repliedMessageId,
    this.forwardedMessageId,
  });

  @Id()
  int obxId;

  @Unique()
  String uid;

  @Index()
  String roomId;

  @Index()
  String senderId;

  String? content;
  String? clientMessageId;
  String? nonce;
  String dataJson;

  @Index()
  int createdAtMs;

  int status;
  bool isDeleted;
  int? updatedAtMs;
  int? deletedAtMs;
  String type;
  String metaJson;
  String membersMentionedJson;
  int? editedAtMs;
  String attachmentsJson;
  String reactionsJson;
  String? repliedMessageId;
  String? forwardedMessageId;
}

@Entity()
class PostDraftEntity {
  PostDraftEntity({
    this.obxId = 0,
    required this.uid,
    this.title,
    this.description,
    this.content,
    required this.visibility,
    required this.type,
    required this.lastModifiedMs,
    required this.postDataJson,
  });

  @Id()
  int obxId;

  @Unique()
  String uid;

  String? title;
  String? description;
  String? content;
  int visibility;
  int type;

  @Index()
  int lastModifiedMs;

  String postDataJson;
}
