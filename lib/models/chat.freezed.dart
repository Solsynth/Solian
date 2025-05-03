// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnChat {

 int get id; String get name; String get description; int get type; bool get isPublic; SnCloudFile? get picture; SnCloudFile? get background; int? get realmId; SnRealm? get realm; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatCopyWith<SnChat> get copyWith => _$SnChatCopyWithImpl<SnChat>(this as SnChat, _$identity);

  /// Serializes this SnChat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChat&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,isPublic,picture,background,realmId,realm,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnChat(id: $id, name: $name, description: $description, type: $type, isPublic: $isPublic, picture: $picture, background: $background, realmId: $realmId, realm: $realm, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnChatCopyWith<$Res>  {
  factory $SnChatCopyWith(SnChat value, $Res Function(SnChat) _then) = _$SnChatCopyWithImpl;
@useResult
$Res call({
 int id, String name, String description, int type, bool isPublic, SnCloudFile? picture, SnCloudFile? background, int? realmId, SnRealm? realm, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnCloudFileCopyWith<$Res>? get picture;$SnCloudFileCopyWith<$Res>? get background;$SnRealmCopyWith<$Res>? get realm;

}
/// @nodoc
class _$SnChatCopyWithImpl<$Res>
    implements $SnChatCopyWith<$Res> {
  _$SnChatCopyWithImpl(this._self, this._then);

  final SnChat _self;
  final $Res Function(SnChat) _then;

/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? isPublic = null,Object? picture = freezed,Object? background = freezed,Object? realmId = freezed,Object? realm = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as int?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
    return null;
  }

  return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
    return _then(_self.copyWith(realm: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _SnChat implements SnChat {
  const _SnChat({required this.id, required this.name, required this.description, required this.type, required this.isPublic, required this.picture, required this.background, required this.realmId, required this.realm, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnChat.fromJson(Map<String, dynamic> json) => _$SnChatFromJson(json);

@override final  int id;
@override final  String name;
@override final  String description;
@override final  int type;
@override final  bool isPublic;
@override final  SnCloudFile? picture;
@override final  SnCloudFile? background;
@override final  int? realmId;
@override final  SnRealm? realm;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnChatCopyWith<_SnChat> get copyWith => __$SnChatCopyWithImpl<_SnChat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnChatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChat&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,isPublic,picture,background,realmId,realm,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnChat(id: $id, name: $name, description: $description, type: $type, isPublic: $isPublic, picture: $picture, background: $background, realmId: $realmId, realm: $realm, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnChatCopyWith<$Res> implements $SnChatCopyWith<$Res> {
  factory _$SnChatCopyWith(_SnChat value, $Res Function(_SnChat) _then) = __$SnChatCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String description, int type, bool isPublic, SnCloudFile? picture, SnCloudFile? background, int? realmId, SnRealm? realm, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnCloudFileCopyWith<$Res>? get picture;@override $SnCloudFileCopyWith<$Res>? get background;@override $SnRealmCopyWith<$Res>? get realm;

}
/// @nodoc
class __$SnChatCopyWithImpl<$Res>
    implements _$SnChatCopyWith<$Res> {
  __$SnChatCopyWithImpl(this._self, this._then);

  final _SnChat _self;
  final $Res Function(_SnChat) _then;

/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? isPublic = null,Object? picture = freezed,Object? background = freezed,Object? realmId = freezed,Object? realm = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnChat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as int?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnChat
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmCopyWith<$Res>? get realm {
    if (_self.realm == null) {
    return null;
  }

  return $SnRealmCopyWith<$Res>(_self.realm!, (value) {
    return _then(_self.copyWith(realm: value));
  });
}
}


/// @nodoc
mixin _$SnChatMessage {

 DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String get id; String? get content; String? get nonce; Map<String, dynamic> get meta; List<String> get membersMetioned; DateTime? get editedAt; List<SnCloudFile> get attachments; List<SnChatReaction> get reactions; String? get repliedMessageId; SnChatMessage? get repliedMessage; String? get forwardedMessageId; SnChatMessage? get forwardedMessage; String get senderId; SnChatMember get sender; int get chatRoomId;
/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatMessageCopyWith<SnChatMessage> get copyWith => _$SnChatMessageCopyWithImpl<SnChatMessage>(this as SnChatMessage, _$identity);

  /// Serializes this SnChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChatMessage&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&const DeepCollectionEquality().equals(other.meta, meta)&&const DeepCollectionEquality().equals(other.membersMetioned, membersMetioned)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.repliedMessageId, repliedMessageId) || other.repliedMessageId == repliedMessageId)&&(identical(other.repliedMessage, repliedMessage) || other.repliedMessage == repliedMessage)&&(identical(other.forwardedMessageId, forwardedMessageId) || other.forwardedMessageId == forwardedMessageId)&&(identical(other.forwardedMessage, forwardedMessage) || other.forwardedMessage == forwardedMessage)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,content,nonce,const DeepCollectionEquality().hash(meta),const DeepCollectionEquality().hash(membersMetioned),editedAt,const DeepCollectionEquality().hash(attachments),const DeepCollectionEquality().hash(reactions),repliedMessageId,repliedMessage,forwardedMessageId,forwardedMessage,senderId,sender,chatRoomId);

@override
String toString() {
  return 'SnChatMessage(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, content: $content, nonce: $nonce, meta: $meta, membersMetioned: $membersMetioned, editedAt: $editedAt, attachments: $attachments, reactions: $reactions, repliedMessageId: $repliedMessageId, repliedMessage: $repliedMessage, forwardedMessageId: $forwardedMessageId, forwardedMessage: $forwardedMessage, senderId: $senderId, sender: $sender, chatRoomId: $chatRoomId)';
}


}

/// @nodoc
abstract mixin class $SnChatMessageCopyWith<$Res>  {
  factory $SnChatMessageCopyWith(SnChatMessage value, $Res Function(SnChatMessage) _then) = _$SnChatMessageCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String? content, String? nonce, Map<String, dynamic> meta, List<String> membersMetioned, DateTime? editedAt, List<SnCloudFile> attachments, List<SnChatReaction> reactions, String? repliedMessageId, SnChatMessage? repliedMessage, String? forwardedMessageId, SnChatMessage? forwardedMessage, String senderId, SnChatMember sender, int chatRoomId
});


$SnChatMessageCopyWith<$Res>? get repliedMessage;$SnChatMessageCopyWith<$Res>? get forwardedMessage;$SnChatMemberCopyWith<$Res> get sender;

}
/// @nodoc
class _$SnChatMessageCopyWithImpl<$Res>
    implements $SnChatMessageCopyWith<$Res> {
  _$SnChatMessageCopyWithImpl(this._self, this._then);

  final SnChatMessage _self;
  final $Res Function(SnChatMessage) _then;

/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? content = freezed,Object? nonce = freezed,Object? meta = null,Object? membersMetioned = null,Object? editedAt = freezed,Object? attachments = null,Object? reactions = null,Object? repliedMessageId = freezed,Object? repliedMessage = freezed,Object? forwardedMessageId = freezed,Object? forwardedMessage = freezed,Object? senderId = null,Object? sender = null,Object? chatRoomId = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,membersMetioned: null == membersMetioned ? _self.membersMetioned : membersMetioned // ignore: cast_nullable_to_non_nullable
as List<String>,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<SnChatReaction>,repliedMessageId: freezed == repliedMessageId ? _self.repliedMessageId : repliedMessageId // ignore: cast_nullable_to_non_nullable
as String?,repliedMessage: freezed == repliedMessage ? _self.repliedMessage : repliedMessage // ignore: cast_nullable_to_non_nullable
as SnChatMessage?,forwardedMessageId: freezed == forwardedMessageId ? _self.forwardedMessageId : forwardedMessageId // ignore: cast_nullable_to_non_nullable
as String?,forwardedMessage: freezed == forwardedMessage ? _self.forwardedMessage : forwardedMessage // ignore: cast_nullable_to_non_nullable
as SnChatMessage?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnChatMember,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMessageCopyWith<$Res>? get repliedMessage {
    if (_self.repliedMessage == null) {
    return null;
  }

  return $SnChatMessageCopyWith<$Res>(_self.repliedMessage!, (value) {
    return _then(_self.copyWith(repliedMessage: value));
  });
}/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMessageCopyWith<$Res>? get forwardedMessage {
    if (_self.forwardedMessage == null) {
    return null;
  }

  return $SnChatMessageCopyWith<$Res>(_self.forwardedMessage!, (value) {
    return _then(_self.copyWith(forwardedMessage: value));
  });
}/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMemberCopyWith<$Res> get sender {
  
  return $SnChatMemberCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _SnChatMessage implements SnChatMessage {
  const _SnChatMessage({required this.createdAt, required this.updatedAt, this.deletedAt, required this.id, this.content, this.nonce, final  Map<String, dynamic> meta = const {}, final  List<String> membersMetioned = const [], this.editedAt, final  List<SnCloudFile> attachments = const [], final  List<SnChatReaction> reactions = const [], this.repliedMessageId, this.repliedMessage, this.forwardedMessageId, this.forwardedMessage, required this.senderId, required this.sender, required this.chatRoomId}): _meta = meta,_membersMetioned = membersMetioned,_attachments = attachments,_reactions = reactions;
  factory _SnChatMessage.fromJson(Map<String, dynamic> json) => _$SnChatMessageFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  String id;
@override final  String? content;
@override final  String? nonce;
 final  Map<String, dynamic> _meta;
@override@JsonKey() Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

 final  List<String> _membersMetioned;
@override@JsonKey() List<String> get membersMetioned {
  if (_membersMetioned is EqualUnmodifiableListView) return _membersMetioned;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_membersMetioned);
}

@override final  DateTime? editedAt;
 final  List<SnCloudFile> _attachments;
@override@JsonKey() List<SnCloudFile> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

 final  List<SnChatReaction> _reactions;
@override@JsonKey() List<SnChatReaction> get reactions {
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactions);
}

@override final  String? repliedMessageId;
@override final  SnChatMessage? repliedMessage;
@override final  String? forwardedMessageId;
@override final  SnChatMessage? forwardedMessage;
@override final  String senderId;
@override final  SnChatMember sender;
@override final  int chatRoomId;

/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnChatMessageCopyWith<_SnChatMessage> get copyWith => __$SnChatMessageCopyWithImpl<_SnChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChatMessage&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&const DeepCollectionEquality().equals(other._meta, _meta)&&const DeepCollectionEquality().equals(other._membersMetioned, _membersMetioned)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.repliedMessageId, repliedMessageId) || other.repliedMessageId == repliedMessageId)&&(identical(other.repliedMessage, repliedMessage) || other.repliedMessage == repliedMessage)&&(identical(other.forwardedMessageId, forwardedMessageId) || other.forwardedMessageId == forwardedMessageId)&&(identical(other.forwardedMessage, forwardedMessage) || other.forwardedMessage == forwardedMessage)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,content,nonce,const DeepCollectionEquality().hash(_meta),const DeepCollectionEquality().hash(_membersMetioned),editedAt,const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_reactions),repliedMessageId,repliedMessage,forwardedMessageId,forwardedMessage,senderId,sender,chatRoomId);

@override
String toString() {
  return 'SnChatMessage(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, content: $content, nonce: $nonce, meta: $meta, membersMetioned: $membersMetioned, editedAt: $editedAt, attachments: $attachments, reactions: $reactions, repliedMessageId: $repliedMessageId, repliedMessage: $repliedMessage, forwardedMessageId: $forwardedMessageId, forwardedMessage: $forwardedMessage, senderId: $senderId, sender: $sender, chatRoomId: $chatRoomId)';
}


}

/// @nodoc
abstract mixin class _$SnChatMessageCopyWith<$Res> implements $SnChatMessageCopyWith<$Res> {
  factory _$SnChatMessageCopyWith(_SnChatMessage value, $Res Function(_SnChatMessage) _then) = __$SnChatMessageCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String? content, String? nonce, Map<String, dynamic> meta, List<String> membersMetioned, DateTime? editedAt, List<SnCloudFile> attachments, List<SnChatReaction> reactions, String? repliedMessageId, SnChatMessage? repliedMessage, String? forwardedMessageId, SnChatMessage? forwardedMessage, String senderId, SnChatMember sender, int chatRoomId
});


@override $SnChatMessageCopyWith<$Res>? get repliedMessage;@override $SnChatMessageCopyWith<$Res>? get forwardedMessage;@override $SnChatMemberCopyWith<$Res> get sender;

}
/// @nodoc
class __$SnChatMessageCopyWithImpl<$Res>
    implements _$SnChatMessageCopyWith<$Res> {
  __$SnChatMessageCopyWithImpl(this._self, this._then);

  final _SnChatMessage _self;
  final $Res Function(_SnChatMessage) _then;

/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? content = freezed,Object? nonce = freezed,Object? meta = null,Object? membersMetioned = null,Object? editedAt = freezed,Object? attachments = null,Object? reactions = null,Object? repliedMessageId = freezed,Object? repliedMessage = freezed,Object? forwardedMessageId = freezed,Object? forwardedMessage = freezed,Object? senderId = null,Object? sender = null,Object? chatRoomId = null,}) {
  return _then(_SnChatMessage(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,membersMetioned: null == membersMetioned ? _self._membersMetioned : membersMetioned // ignore: cast_nullable_to_non_nullable
as List<String>,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<SnChatReaction>,repliedMessageId: freezed == repliedMessageId ? _self.repliedMessageId : repliedMessageId // ignore: cast_nullable_to_non_nullable
as String?,repliedMessage: freezed == repliedMessage ? _self.repliedMessage : repliedMessage // ignore: cast_nullable_to_non_nullable
as SnChatMessage?,forwardedMessageId: freezed == forwardedMessageId ? _self.forwardedMessageId : forwardedMessageId // ignore: cast_nullable_to_non_nullable
as String?,forwardedMessage: freezed == forwardedMessage ? _self.forwardedMessage : forwardedMessage // ignore: cast_nullable_to_non_nullable
as SnChatMessage?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnChatMember,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMessageCopyWith<$Res>? get repliedMessage {
    if (_self.repliedMessage == null) {
    return null;
  }

  return $SnChatMessageCopyWith<$Res>(_self.repliedMessage!, (value) {
    return _then(_self.copyWith(repliedMessage: value));
  });
}/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMessageCopyWith<$Res>? get forwardedMessage {
    if (_self.forwardedMessage == null) {
    return null;
  }

  return $SnChatMessageCopyWith<$Res>(_self.forwardedMessage!, (value) {
    return _then(_self.copyWith(forwardedMessage: value));
  });
}/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMemberCopyWith<$Res> get sender {
  
  return $SnChatMemberCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// @nodoc
mixin _$SnChatReaction {

 DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String get id; String get messageId; String get senderId; SnChatMember get sender; String get symbol; int get attitude;
/// Create a copy of SnChatReaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatReactionCopyWith<SnChatReaction> get copyWith => _$SnChatReactionCopyWithImpl<SnChatReaction>(this as SnChatReaction, _$identity);

  /// Serializes this SnChatReaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChatReaction&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.attitude, attitude) || other.attitude == attitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,messageId,senderId,sender,symbol,attitude);

@override
String toString() {
  return 'SnChatReaction(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, messageId: $messageId, senderId: $senderId, sender: $sender, symbol: $symbol, attitude: $attitude)';
}


}

/// @nodoc
abstract mixin class $SnChatReactionCopyWith<$Res>  {
  factory $SnChatReactionCopyWith(SnChatReaction value, $Res Function(SnChatReaction) _then) = _$SnChatReactionCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String messageId, String senderId, SnChatMember sender, String symbol, int attitude
});


$SnChatMemberCopyWith<$Res> get sender;

}
/// @nodoc
class _$SnChatReactionCopyWithImpl<$Res>
    implements $SnChatReactionCopyWith<$Res> {
  _$SnChatReactionCopyWithImpl(this._self, this._then);

  final SnChatReaction _self;
  final $Res Function(SnChatReaction) _then;

/// Create a copy of SnChatReaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? messageId = null,Object? senderId = null,Object? sender = null,Object? symbol = null,Object? attitude = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnChatMember,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SnChatReaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMemberCopyWith<$Res> get sender {
  
  return $SnChatMemberCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// @nodoc
@JsonSerializable()

class _SnChatReaction implements SnChatReaction {
  const _SnChatReaction({required this.createdAt, required this.updatedAt, required this.deletedAt, required this.id, required this.messageId, required this.senderId, required this.sender, required this.symbol, required this.attitude});
  factory _SnChatReaction.fromJson(Map<String, dynamic> json) => _$SnChatReactionFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  String id;
@override final  String messageId;
@override final  String senderId;
@override final  SnChatMember sender;
@override final  String symbol;
@override final  int attitude;

/// Create a copy of SnChatReaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnChatReactionCopyWith<_SnChatReaction> get copyWith => __$SnChatReactionCopyWithImpl<_SnChatReaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnChatReactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChatReaction&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.attitude, attitude) || other.attitude == attitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,messageId,senderId,sender,symbol,attitude);

@override
String toString() {
  return 'SnChatReaction(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, messageId: $messageId, senderId: $senderId, sender: $sender, symbol: $symbol, attitude: $attitude)';
}


}

/// @nodoc
abstract mixin class _$SnChatReactionCopyWith<$Res> implements $SnChatReactionCopyWith<$Res> {
  factory _$SnChatReactionCopyWith(_SnChatReaction value, $Res Function(_SnChatReaction) _then) = __$SnChatReactionCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String messageId, String senderId, SnChatMember sender, String symbol, int attitude
});


@override $SnChatMemberCopyWith<$Res> get sender;

}
/// @nodoc
class __$SnChatReactionCopyWithImpl<$Res>
    implements _$SnChatReactionCopyWith<$Res> {
  __$SnChatReactionCopyWithImpl(this._self, this._then);

  final _SnChatReaction _self;
  final $Res Function(_SnChatReaction) _then;

/// Create a copy of SnChatReaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? messageId = null,Object? senderId = null,Object? sender = null,Object? symbol = null,Object? attitude = null,}) {
  return _then(_SnChatReaction(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnChatMember,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SnChatReaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMemberCopyWith<$Res> get sender {
  
  return $SnChatMemberCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// @nodoc
mixin _$SnChatMember {

 DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String get id; int get chatRoomId; int get accountId; String? get nick; int get role; int get notify; DateTime? get joinedAt; bool get isBot;
/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatMemberCopyWith<SnChatMember> get copyWith => _$SnChatMemberCopyWithImpl<SnChatMember>(this as SnChatMember, _$identity);

  /// Serializes this SnChatMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChatMember&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.role, role) || other.role == role)&&(identical(other.notify, notify) || other.notify == notify)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.isBot, isBot) || other.isBot == isBot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,chatRoomId,accountId,nick,role,notify,joinedAt,isBot);

@override
String toString() {
  return 'SnChatMember(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, chatRoomId: $chatRoomId, accountId: $accountId, nick: $nick, role: $role, notify: $notify, joinedAt: $joinedAt, isBot: $isBot)';
}


}

/// @nodoc
abstract mixin class $SnChatMemberCopyWith<$Res>  {
  factory $SnChatMemberCopyWith(SnChatMember value, $Res Function(SnChatMember) _then) = _$SnChatMemberCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, int chatRoomId, int accountId, String? nick, int role, int notify, DateTime? joinedAt, bool isBot
});




}
/// @nodoc
class _$SnChatMemberCopyWithImpl<$Res>
    implements $SnChatMemberCopyWith<$Res> {
  _$SnChatMemberCopyWithImpl(this._self, this._then);

  final SnChatMember _self;
  final $Res Function(SnChatMember) _then;

/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? chatRoomId = null,Object? accountId = null,Object? nick = freezed,Object? role = null,Object? notify = null,Object? joinedAt = freezed,Object? isBot = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,nick: freezed == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as int,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _SnChatMember implements SnChatMember {
  const _SnChatMember({required this.createdAt, required this.updatedAt, required this.deletedAt, required this.id, required this.chatRoomId, required this.accountId, required this.nick, required this.role, required this.notify, required this.joinedAt, required this.isBot});
  factory _SnChatMember.fromJson(Map<String, dynamic> json) => _$SnChatMemberFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  String id;
@override final  int chatRoomId;
@override final  int accountId;
@override final  String? nick;
@override final  int role;
@override final  int notify;
@override final  DateTime? joinedAt;
@override final  bool isBot;

/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnChatMemberCopyWith<_SnChatMember> get copyWith => __$SnChatMemberCopyWithImpl<_SnChatMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnChatMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChatMember&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.role, role) || other.role == role)&&(identical(other.notify, notify) || other.notify == notify)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.isBot, isBot) || other.isBot == isBot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,chatRoomId,accountId,nick,role,notify,joinedAt,isBot);

@override
String toString() {
  return 'SnChatMember(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, chatRoomId: $chatRoomId, accountId: $accountId, nick: $nick, role: $role, notify: $notify, joinedAt: $joinedAt, isBot: $isBot)';
}


}

/// @nodoc
abstract mixin class _$SnChatMemberCopyWith<$Res> implements $SnChatMemberCopyWith<$Res> {
  factory _$SnChatMemberCopyWith(_SnChatMember value, $Res Function(_SnChatMember) _then) = __$SnChatMemberCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, int chatRoomId, int accountId, String? nick, int role, int notify, DateTime? joinedAt, bool isBot
});




}
/// @nodoc
class __$SnChatMemberCopyWithImpl<$Res>
    implements _$SnChatMemberCopyWith<$Res> {
  __$SnChatMemberCopyWithImpl(this._self, this._then);

  final _SnChatMember _self;
  final $Res Function(_SnChatMember) _then;

/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? chatRoomId = null,Object? accountId = null,Object? nick = freezed,Object? role = null,Object? notify = null,Object? joinedAt = freezed,Object? isBot = null,}) {
  return _then(_SnChatMember(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as int,nick: freezed == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as int,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
