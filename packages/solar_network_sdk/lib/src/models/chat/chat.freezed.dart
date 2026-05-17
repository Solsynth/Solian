// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnChatRoom {

 String get id; String? get name; String? get description; int get type;@JsonKey(name: 'encryption_mode') int get encryptionMode;@JsonKey(name: 'mls_group_id') String? get mlsGroupId; bool get isPublic; bool get isCommunity; SnCloudFileReference? get picture; SnCloudFileReference? get background; String? get realmId; String? get accountId; SnRealm? get realm; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; List<SnChatMember>? get members;// Frontend data
 bool get isPinned;
/// Create a copy of SnChatRoom
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatRoomCopyWith<SnChatRoom> get copyWith => _$SnChatRoomCopyWithImpl<SnChatRoom>(this as SnChatRoom, _$identity);

  /// Serializes this SnChatRoom to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChatRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.encryptionMode, encryptionMode) || other.encryptionMode == encryptionMode)&&(identical(other.mlsGroupId, mlsGroupId) || other.mlsGroupId == mlsGroupId)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,encryptionMode,mlsGroupId,isPublic,isCommunity,picture,background,realmId,accountId,realm,createdAt,updatedAt,deletedAt,const DeepCollectionEquality().hash(members),isPinned);

@override
String toString() {
  return 'SnChatRoom(id: $id, name: $name, description: $description, type: $type, encryptionMode: $encryptionMode, mlsGroupId: $mlsGroupId, isPublic: $isPublic, isCommunity: $isCommunity, picture: $picture, background: $background, realmId: $realmId, accountId: $accountId, realm: $realm, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, members: $members, isPinned: $isPinned)';
}


}

/// @nodoc
abstract mixin class $SnChatRoomCopyWith<$Res>  {
  factory $SnChatRoomCopyWith(SnChatRoom value, $Res Function(SnChatRoom) _then) = _$SnChatRoomCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? description, int type,@JsonKey(name: 'encryption_mode') int encryptionMode,@JsonKey(name: 'mls_group_id') String? mlsGroupId, bool isPublic, bool isCommunity, SnCloudFileReference? picture, SnCloudFileReference? background, String? realmId, String? accountId, SnRealm? realm, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnChatMember>? members, bool isPinned
});


$SnCloudFileReferenceCopyWith<$Res>? get picture;$SnCloudFileReferenceCopyWith<$Res>? get background;$SnRealmCopyWith<$Res>? get realm;

}
/// @nodoc
class _$SnChatRoomCopyWithImpl<$Res>
    implements $SnChatRoomCopyWith<$Res> {
  _$SnChatRoomCopyWithImpl(this._self, this._then);

  final SnChatRoom _self;
  final $Res Function(SnChatRoom) _then;

/// Create a copy of SnChatRoom
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? description = freezed,Object? type = null,Object? encryptionMode = null,Object? mlsGroupId = freezed,Object? isPublic = null,Object? isCommunity = null,Object? picture = freezed,Object? background = freezed,Object? realmId = freezed,Object? accountId = freezed,Object? realm = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? members = freezed,Object? isPinned = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,encryptionMode: null == encryptionMode ? _self.encryptionMode : encryptionMode // ignore: cast_nullable_to_non_nullable
as int,mlsGroupId: freezed == mlsGroupId ? _self.mlsGroupId : mlsGroupId // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,members: freezed == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<SnChatMember>?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of SnChatRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnChatRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnChatRoom
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


/// Adds pattern-matching-related methods to [SnChatRoom].
extension SnChatRoomPatterns on SnChatRoom {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnChatRoom value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnChatRoom() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnChatRoom value)  $default,){
final _that = this;
switch (_that) {
case _SnChatRoom():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnChatRoom value)?  $default,){
final _that = this;
switch (_that) {
case _SnChatRoom() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? description,  int type, @JsonKey(name: 'encryption_mode')  int encryptionMode, @JsonKey(name: 'mls_group_id')  String? mlsGroupId,  bool isPublic,  bool isCommunity,  SnCloudFileReference? picture,  SnCloudFileReference? background,  String? realmId,  String? accountId,  SnRealm? realm,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnChatMember>? members,  bool isPinned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnChatRoom() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.encryptionMode,_that.mlsGroupId,_that.isPublic,_that.isCommunity,_that.picture,_that.background,_that.realmId,_that.accountId,_that.realm,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.members,_that.isPinned);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? description,  int type, @JsonKey(name: 'encryption_mode')  int encryptionMode, @JsonKey(name: 'mls_group_id')  String? mlsGroupId,  bool isPublic,  bool isCommunity,  SnCloudFileReference? picture,  SnCloudFileReference? background,  String? realmId,  String? accountId,  SnRealm? realm,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnChatMember>? members,  bool isPinned)  $default,) {final _that = this;
switch (_that) {
case _SnChatRoom():
return $default(_that.id,_that.name,_that.description,_that.type,_that.encryptionMode,_that.mlsGroupId,_that.isPublic,_that.isCommunity,_that.picture,_that.background,_that.realmId,_that.accountId,_that.realm,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.members,_that.isPinned);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? description,  int type, @JsonKey(name: 'encryption_mode')  int encryptionMode, @JsonKey(name: 'mls_group_id')  String? mlsGroupId,  bool isPublic,  bool isCommunity,  SnCloudFileReference? picture,  SnCloudFileReference? background,  String? realmId,  String? accountId,  SnRealm? realm,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnChatMember>? members,  bool isPinned)?  $default,) {final _that = this;
switch (_that) {
case _SnChatRoom() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.encryptionMode,_that.mlsGroupId,_that.isPublic,_that.isCommunity,_that.picture,_that.background,_that.realmId,_that.accountId,_that.realm,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.members,_that.isPinned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnChatRoom implements SnChatRoom {
  const _SnChatRoom({required this.id, required this.name, required this.description, required this.type, @JsonKey(name: 'encryption_mode') this.encryptionMode = 0, @JsonKey(name: 'mls_group_id') this.mlsGroupId, this.isPublic = false, this.isCommunity = false, required this.picture, required this.background, required this.realmId, required this.accountId, required this.realm, required this.createdAt, required this.updatedAt, required this.deletedAt, required final  List<SnChatMember>? members, this.isPinned = false}): _members = members;
  factory _SnChatRoom.fromJson(Map<String, dynamic> json) => _$SnChatRoomFromJson(json);

@override final  String id;
@override final  String? name;
@override final  String? description;
@override final  int type;
@override@JsonKey(name: 'encryption_mode') final  int encryptionMode;
@override@JsonKey(name: 'mls_group_id') final  String? mlsGroupId;
@override@JsonKey() final  bool isPublic;
@override@JsonKey() final  bool isCommunity;
@override final  SnCloudFileReference? picture;
@override final  SnCloudFileReference? background;
@override final  String? realmId;
@override final  String? accountId;
@override final  SnRealm? realm;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
 final  List<SnChatMember>? _members;
@override List<SnChatMember>? get members {
  final value = _members;
  if (value == null) return null;
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Frontend data
@override@JsonKey() final  bool isPinned;

/// Create a copy of SnChatRoom
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnChatRoomCopyWith<_SnChatRoom> get copyWith => __$SnChatRoomCopyWithImpl<_SnChatRoom>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnChatRoomToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChatRoom&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.encryptionMode, encryptionMode) || other.encryptionMode == encryptionMode)&&(identical(other.mlsGroupId, mlsGroupId) || other.mlsGroupId == mlsGroupId)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isCommunity, isCommunity) || other.isCommunity == isCommunity)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.realmId, realmId) || other.realmId == realmId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.realm, realm) || other.realm == realm)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,encryptionMode,mlsGroupId,isPublic,isCommunity,picture,background,realmId,accountId,realm,createdAt,updatedAt,deletedAt,const DeepCollectionEquality().hash(_members),isPinned);

@override
String toString() {
  return 'SnChatRoom(id: $id, name: $name, description: $description, type: $type, encryptionMode: $encryptionMode, mlsGroupId: $mlsGroupId, isPublic: $isPublic, isCommunity: $isCommunity, picture: $picture, background: $background, realmId: $realmId, accountId: $accountId, realm: $realm, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, members: $members, isPinned: $isPinned)';
}


}

/// @nodoc
abstract mixin class _$SnChatRoomCopyWith<$Res> implements $SnChatRoomCopyWith<$Res> {
  factory _$SnChatRoomCopyWith(_SnChatRoom value, $Res Function(_SnChatRoom) _then) = __$SnChatRoomCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? description, int type,@JsonKey(name: 'encryption_mode') int encryptionMode,@JsonKey(name: 'mls_group_id') String? mlsGroupId, bool isPublic, bool isCommunity, SnCloudFileReference? picture, SnCloudFileReference? background, String? realmId, String? accountId, SnRealm? realm, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnChatMember>? members, bool isPinned
});


@override $SnCloudFileReferenceCopyWith<$Res>? get picture;@override $SnCloudFileReferenceCopyWith<$Res>? get background;@override $SnRealmCopyWith<$Res>? get realm;

}
/// @nodoc
class __$SnChatRoomCopyWithImpl<$Res>
    implements _$SnChatRoomCopyWith<$Res> {
  __$SnChatRoomCopyWithImpl(this._self, this._then);

  final _SnChatRoom _self;
  final $Res Function(_SnChatRoom) _then;

/// Create a copy of SnChatRoom
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? description = freezed,Object? type = null,Object? encryptionMode = null,Object? mlsGroupId = freezed,Object? isPublic = null,Object? isCommunity = null,Object? picture = freezed,Object? background = freezed,Object? realmId = freezed,Object? accountId = freezed,Object? realm = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? members = freezed,Object? isPinned = null,}) {
  return _then(_SnChatRoom(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,encryptionMode: null == encryptionMode ? _self.encryptionMode : encryptionMode // ignore: cast_nullable_to_non_nullable
as int,mlsGroupId: freezed == mlsGroupId ? _self.mlsGroupId : mlsGroupId // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,isCommunity: null == isCommunity ? _self.isCommunity : isCommunity // ignore: cast_nullable_to_non_nullable
as bool,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,realmId: freezed == realmId ? _self.realmId : realmId // ignore: cast_nullable_to_non_nullable
as String?,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,realm: freezed == realm ? _self.realm : realm // ignore: cast_nullable_to_non_nullable
as SnRealm?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,members: freezed == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<SnChatMember>?,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of SnChatRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnChatRoom
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnChatRoom
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

 DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String get id; String get type; String? get content;@JsonKey(name: 'client_message_id') String? get clientMessageId; String? get nonce; Map<String, dynamic> get meta; List<String> get membersMentioned; DateTime? get editedAt; List<SnCloudFileReference> get attachments; List<SnChatReaction> get reactions;@JsonKey(name: 'reactions_count') Map<String, int> get reactionsCount;@JsonKey(name: 'reactions_made') Map<String, bool> get reactionsMade; String? get repliedMessageId; String? get forwardedMessageId; String get senderId; SnChatMember get sender; String get chatRoomId;
/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatMessageCopyWith<SnChatMessage> get copyWith => _$SnChatMessageCopyWithImpl<SnChatMessage>(this as SnChatMessage, _$identity);

  /// Serializes this SnChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChatMessage&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&const DeepCollectionEquality().equals(other.meta, meta)&&const DeepCollectionEquality().equals(other.membersMentioned, membersMentioned)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&const DeepCollectionEquality().equals(other.reactionsCount, reactionsCount)&&const DeepCollectionEquality().equals(other.reactionsMade, reactionsMade)&&(identical(other.repliedMessageId, repliedMessageId) || other.repliedMessageId == repliedMessageId)&&(identical(other.forwardedMessageId, forwardedMessageId) || other.forwardedMessageId == forwardedMessageId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,createdAt,updatedAt,deletedAt,id,type,content,clientMessageId,nonce,const DeepCollectionEquality().hash(meta),const DeepCollectionEquality().hash(membersMentioned),editedAt,const DeepCollectionEquality().hash(attachments),const DeepCollectionEquality().hash(reactions),const DeepCollectionEquality().hash(reactionsCount),const DeepCollectionEquality().hash(reactionsMade),repliedMessageId,forwardedMessageId,senderId,sender,chatRoomId]);

@override
String toString() {
  return 'SnChatMessage(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, type: $type, content: $content, clientMessageId: $clientMessageId, nonce: $nonce, meta: $meta, membersMentioned: $membersMentioned, editedAt: $editedAt, attachments: $attachments, reactions: $reactions, reactionsCount: $reactionsCount, reactionsMade: $reactionsMade, repliedMessageId: $repliedMessageId, forwardedMessageId: $forwardedMessageId, senderId: $senderId, sender: $sender, chatRoomId: $chatRoomId)';
}


}

/// @nodoc
abstract mixin class $SnChatMessageCopyWith<$Res>  {
  factory $SnChatMessageCopyWith(SnChatMessage value, $Res Function(SnChatMessage) _then) = _$SnChatMessageCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String type, String? content,@JsonKey(name: 'client_message_id') String? clientMessageId, String? nonce, Map<String, dynamic> meta, List<String> membersMentioned, DateTime? editedAt, List<SnCloudFileReference> attachments, List<SnChatReaction> reactions,@JsonKey(name: 'reactions_count') Map<String, int> reactionsCount,@JsonKey(name: 'reactions_made') Map<String, bool> reactionsMade, String? repliedMessageId, String? forwardedMessageId, String senderId, SnChatMember sender, String chatRoomId
});


$SnChatMemberCopyWith<$Res> get sender;

}
/// @nodoc
class _$SnChatMessageCopyWithImpl<$Res>
    implements $SnChatMessageCopyWith<$Res> {
  _$SnChatMessageCopyWithImpl(this._self, this._then);

  final SnChatMessage _self;
  final $Res Function(SnChatMessage) _then;

/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? type = null,Object? content = freezed,Object? clientMessageId = freezed,Object? nonce = freezed,Object? meta = null,Object? membersMentioned = null,Object? editedAt = freezed,Object? attachments = null,Object? reactions = null,Object? reactionsCount = null,Object? reactionsMade = null,Object? repliedMessageId = freezed,Object? forwardedMessageId = freezed,Object? senderId = null,Object? sender = null,Object? chatRoomId = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,clientMessageId: freezed == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String?,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,membersMentioned: null == membersMentioned ? _self.membersMentioned : membersMentioned // ignore: cast_nullable_to_non_nullable
as List<String>,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<SnChatReaction>,reactionsCount: null == reactionsCount ? _self.reactionsCount : reactionsCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,reactionsMade: null == reactionsMade ? _self.reactionsMade : reactionsMade // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,repliedMessageId: freezed == repliedMessageId ? _self.repliedMessageId : repliedMessageId // ignore: cast_nullable_to_non_nullable
as String?,forwardedMessageId: freezed == forwardedMessageId ? _self.forwardedMessageId : forwardedMessageId // ignore: cast_nullable_to_non_nullable
as String?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnChatMember,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMemberCopyWith<$Res> get sender {
  
  return $SnChatMemberCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnChatMessage].
extension SnChatMessagePatterns on SnChatMessage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnChatMessage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _SnChatMessage():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _SnChatMessage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String type,  String? content, @JsonKey(name: 'client_message_id')  String? clientMessageId,  String? nonce,  Map<String, dynamic> meta,  List<String> membersMentioned,  DateTime? editedAt,  List<SnCloudFileReference> attachments,  List<SnChatReaction> reactions, @JsonKey(name: 'reactions_count')  Map<String, int> reactionsCount, @JsonKey(name: 'reactions_made')  Map<String, bool> reactionsMade,  String? repliedMessageId,  String? forwardedMessageId,  String senderId,  SnChatMember sender,  String chatRoomId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnChatMessage() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.type,_that.content,_that.clientMessageId,_that.nonce,_that.meta,_that.membersMentioned,_that.editedAt,_that.attachments,_that.reactions,_that.reactionsCount,_that.reactionsMade,_that.repliedMessageId,_that.forwardedMessageId,_that.senderId,_that.sender,_that.chatRoomId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String type,  String? content, @JsonKey(name: 'client_message_id')  String? clientMessageId,  String? nonce,  Map<String, dynamic> meta,  List<String> membersMentioned,  DateTime? editedAt,  List<SnCloudFileReference> attachments,  List<SnChatReaction> reactions, @JsonKey(name: 'reactions_count')  Map<String, int> reactionsCount, @JsonKey(name: 'reactions_made')  Map<String, bool> reactionsMade,  String? repliedMessageId,  String? forwardedMessageId,  String senderId,  SnChatMember sender,  String chatRoomId)  $default,) {final _that = this;
switch (_that) {
case _SnChatMessage():
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.type,_that.content,_that.clientMessageId,_that.nonce,_that.meta,_that.membersMentioned,_that.editedAt,_that.attachments,_that.reactions,_that.reactionsCount,_that.reactionsMade,_that.repliedMessageId,_that.forwardedMessageId,_that.senderId,_that.sender,_that.chatRoomId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String type,  String? content, @JsonKey(name: 'client_message_id')  String? clientMessageId,  String? nonce,  Map<String, dynamic> meta,  List<String> membersMentioned,  DateTime? editedAt,  List<SnCloudFileReference> attachments,  List<SnChatReaction> reactions, @JsonKey(name: 'reactions_count')  Map<String, int> reactionsCount, @JsonKey(name: 'reactions_made')  Map<String, bool> reactionsMade,  String? repliedMessageId,  String? forwardedMessageId,  String senderId,  SnChatMember sender,  String chatRoomId)?  $default,) {final _that = this;
switch (_that) {
case _SnChatMessage() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.type,_that.content,_that.clientMessageId,_that.nonce,_that.meta,_that.membersMentioned,_that.editedAt,_that.attachments,_that.reactions,_that.reactionsCount,_that.reactionsMade,_that.repliedMessageId,_that.forwardedMessageId,_that.senderId,_that.sender,_that.chatRoomId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnChatMessage implements SnChatMessage {
  const _SnChatMessage({required this.createdAt, required this.updatedAt, this.deletedAt, required this.id, this.type = 'text', this.content, @JsonKey(name: 'client_message_id') this.clientMessageId, this.nonce, final  Map<String, dynamic> meta = const {}, final  List<String> membersMentioned = const [], this.editedAt, final  List<SnCloudFileReference> attachments = const [], final  List<SnChatReaction> reactions = const [], @JsonKey(name: 'reactions_count') final  Map<String, int> reactionsCount = const {}, @JsonKey(name: 'reactions_made') final  Map<String, bool> reactionsMade = const {}, this.repliedMessageId, this.forwardedMessageId, required this.senderId, required this.sender, required this.chatRoomId}): _meta = meta,_membersMentioned = membersMentioned,_attachments = attachments,_reactions = reactions,_reactionsCount = reactionsCount,_reactionsMade = reactionsMade;
  factory _SnChatMessage.fromJson(Map<String, dynamic> json) => _$SnChatMessageFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  String id;
@override@JsonKey() final  String type;
@override final  String? content;
@override@JsonKey(name: 'client_message_id') final  String? clientMessageId;
@override final  String? nonce;
 final  Map<String, dynamic> _meta;
@override@JsonKey() Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

 final  List<String> _membersMentioned;
@override@JsonKey() List<String> get membersMentioned {
  if (_membersMentioned is EqualUnmodifiableListView) return _membersMentioned;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_membersMentioned);
}

@override final  DateTime? editedAt;
 final  List<SnCloudFileReference> _attachments;
@override@JsonKey() List<SnCloudFileReference> get attachments {
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

 final  Map<String, int> _reactionsCount;
@override@JsonKey(name: 'reactions_count') Map<String, int> get reactionsCount {
  if (_reactionsCount is EqualUnmodifiableMapView) return _reactionsCount;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactionsCount);
}

 final  Map<String, bool> _reactionsMade;
@override@JsonKey(name: 'reactions_made') Map<String, bool> get reactionsMade {
  if (_reactionsMade is EqualUnmodifiableMapView) return _reactionsMade;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_reactionsMade);
}

@override final  String? repliedMessageId;
@override final  String? forwardedMessageId;
@override final  String senderId;
@override final  SnChatMember sender;
@override final  String chatRoomId;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChatMessage&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&(identical(other.clientMessageId, clientMessageId) || other.clientMessageId == clientMessageId)&&(identical(other.nonce, nonce) || other.nonce == nonce)&&const DeepCollectionEquality().equals(other._meta, _meta)&&const DeepCollectionEquality().equals(other._membersMentioned, _membersMentioned)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&const DeepCollectionEquality().equals(other._reactionsCount, _reactionsCount)&&const DeepCollectionEquality().equals(other._reactionsMade, _reactionsMade)&&(identical(other.repliedMessageId, repliedMessageId) || other.repliedMessageId == repliedMessageId)&&(identical(other.forwardedMessageId, forwardedMessageId) || other.forwardedMessageId == forwardedMessageId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,createdAt,updatedAt,deletedAt,id,type,content,clientMessageId,nonce,const DeepCollectionEquality().hash(_meta),const DeepCollectionEquality().hash(_membersMentioned),editedAt,const DeepCollectionEquality().hash(_attachments),const DeepCollectionEquality().hash(_reactions),const DeepCollectionEquality().hash(_reactionsCount),const DeepCollectionEquality().hash(_reactionsMade),repliedMessageId,forwardedMessageId,senderId,sender,chatRoomId]);

@override
String toString() {
  return 'SnChatMessage(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, type: $type, content: $content, clientMessageId: $clientMessageId, nonce: $nonce, meta: $meta, membersMentioned: $membersMentioned, editedAt: $editedAt, attachments: $attachments, reactions: $reactions, reactionsCount: $reactionsCount, reactionsMade: $reactionsMade, repliedMessageId: $repliedMessageId, forwardedMessageId: $forwardedMessageId, senderId: $senderId, sender: $sender, chatRoomId: $chatRoomId)';
}


}

/// @nodoc
abstract mixin class _$SnChatMessageCopyWith<$Res> implements $SnChatMessageCopyWith<$Res> {
  factory _$SnChatMessageCopyWith(_SnChatMessage value, $Res Function(_SnChatMessage) _then) = __$SnChatMessageCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String type, String? content,@JsonKey(name: 'client_message_id') String? clientMessageId, String? nonce, Map<String, dynamic> meta, List<String> membersMentioned, DateTime? editedAt, List<SnCloudFileReference> attachments, List<SnChatReaction> reactions,@JsonKey(name: 'reactions_count') Map<String, int> reactionsCount,@JsonKey(name: 'reactions_made') Map<String, bool> reactionsMade, String? repliedMessageId, String? forwardedMessageId, String senderId, SnChatMember sender, String chatRoomId
});


@override $SnChatMemberCopyWith<$Res> get sender;

}
/// @nodoc
class __$SnChatMessageCopyWithImpl<$Res>
    implements _$SnChatMessageCopyWith<$Res> {
  __$SnChatMessageCopyWithImpl(this._self, this._then);

  final _SnChatMessage _self;
  final $Res Function(_SnChatMessage) _then;

/// Create a copy of SnChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? type = null,Object? content = freezed,Object? clientMessageId = freezed,Object? nonce = freezed,Object? meta = null,Object? membersMentioned = null,Object? editedAt = freezed,Object? attachments = null,Object? reactions = null,Object? reactionsCount = null,Object? reactionsMade = null,Object? repliedMessageId = freezed,Object? forwardedMessageId = freezed,Object? senderId = null,Object? sender = null,Object? chatRoomId = null,}) {
  return _then(_SnChatMessage(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,clientMessageId: freezed == clientMessageId ? _self.clientMessageId : clientMessageId // ignore: cast_nullable_to_non_nullable
as String?,nonce: freezed == nonce ? _self.nonce : nonce // ignore: cast_nullable_to_non_nullable
as String?,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,membersMentioned: null == membersMentioned ? _self._membersMentioned : membersMentioned // ignore: cast_nullable_to_non_nullable
as List<String>,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<SnChatReaction>,reactionsCount: null == reactionsCount ? _self._reactionsCount : reactionsCount // ignore: cast_nullable_to_non_nullable
as Map<String, int>,reactionsMade: null == reactionsMade ? _self._reactionsMade : reactionsMade // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,repliedMessageId: freezed == repliedMessageId ? _self.repliedMessageId : repliedMessageId // ignore: cast_nullable_to_non_nullable
as String?,forwardedMessageId: freezed == forwardedMessageId ? _self.forwardedMessageId : forwardedMessageId // ignore: cast_nullable_to_non_nullable
as String?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnChatMember,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SnChatMessage
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


/// Adds pattern-matching-related methods to [SnChatReaction].
extension SnChatReactionPatterns on SnChatReaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnChatReaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnChatReaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnChatReaction value)  $default,){
final _that = this;
switch (_that) {
case _SnChatReaction():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnChatReaction value)?  $default,){
final _that = this;
switch (_that) {
case _SnChatReaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String messageId,  String senderId,  SnChatMember sender,  String symbol,  int attitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnChatReaction() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.messageId,_that.senderId,_that.sender,_that.symbol,_that.attitude);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String messageId,  String senderId,  SnChatMember sender,  String symbol,  int attitude)  $default,) {final _that = this;
switch (_that) {
case _SnChatReaction():
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.messageId,_that.senderId,_that.sender,_that.symbol,_that.attitude);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String messageId,  String senderId,  SnChatMember sender,  String symbol,  int attitude)?  $default,) {final _that = this;
switch (_that) {
case _SnChatReaction() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.messageId,_that.senderId,_that.sender,_that.symbol,_that.attitude);case _:
  return null;

}
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

 DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String get id; String get chatRoomId; SnChatRoom? get chatRoom; String get accountId; SnAccount get account; String? get nick; int get notify; DateTime? get joinedAt; DateTime? get breakUntil; DateTime? get timeoutUntil; DateTime? get lastReadAt; SnAccountStatus? get status;// Realm related-content
 String? get realmNick; String? get realmBio; int? get realmExperience; int? get realmLevel; double? get realmLevelingProgress; SnRealmLabel? get realmLabel;// Frontend data
 DateTime? get lastTyped;
/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatMemberCopyWith<SnChatMember> get copyWith => _$SnChatMemberCopyWithImpl<SnChatMember>(this as SnChatMember, _$identity);

  /// Serializes this SnChatMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChatMember&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId)&&(identical(other.chatRoom, chatRoom) || other.chatRoom == chatRoom)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.notify, notify) || other.notify == notify)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.breakUntil, breakUntil) || other.breakUntil == breakUntil)&&(identical(other.timeoutUntil, timeoutUntil) || other.timeoutUntil == timeoutUntil)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.realmNick, realmNick) || other.realmNick == realmNick)&&(identical(other.realmBio, realmBio) || other.realmBio == realmBio)&&(identical(other.realmExperience, realmExperience) || other.realmExperience == realmExperience)&&(identical(other.realmLevel, realmLevel) || other.realmLevel == realmLevel)&&(identical(other.realmLevelingProgress, realmLevelingProgress) || other.realmLevelingProgress == realmLevelingProgress)&&(identical(other.realmLabel, realmLabel) || other.realmLabel == realmLabel)&&(identical(other.lastTyped, lastTyped) || other.lastTyped == lastTyped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,createdAt,updatedAt,deletedAt,id,chatRoomId,chatRoom,accountId,account,nick,notify,joinedAt,breakUntil,timeoutUntil,lastReadAt,status,realmNick,realmBio,realmExperience,realmLevel,realmLevelingProgress,realmLabel,lastTyped]);

@override
String toString() {
  return 'SnChatMember(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, chatRoomId: $chatRoomId, chatRoom: $chatRoom, accountId: $accountId, account: $account, nick: $nick, notify: $notify, joinedAt: $joinedAt, breakUntil: $breakUntil, timeoutUntil: $timeoutUntil, lastReadAt: $lastReadAt, status: $status, realmNick: $realmNick, realmBio: $realmBio, realmExperience: $realmExperience, realmLevel: $realmLevel, realmLevelingProgress: $realmLevelingProgress, realmLabel: $realmLabel, lastTyped: $lastTyped)';
}


}

/// @nodoc
abstract mixin class $SnChatMemberCopyWith<$Res>  {
  factory $SnChatMemberCopyWith(SnChatMember value, $Res Function(SnChatMember) _then) = _$SnChatMemberCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String chatRoomId, SnChatRoom? chatRoom, String accountId, SnAccount account, String? nick, int notify, DateTime? joinedAt, DateTime? breakUntil, DateTime? timeoutUntil, DateTime? lastReadAt, SnAccountStatus? status, String? realmNick, String? realmBio, int? realmExperience, int? realmLevel, double? realmLevelingProgress, SnRealmLabel? realmLabel, DateTime? lastTyped
});


$SnChatRoomCopyWith<$Res>? get chatRoom;$SnAccountCopyWith<$Res> get account;$SnAccountStatusCopyWith<$Res>? get status;$SnRealmLabelCopyWith<$Res>? get realmLabel;

}
/// @nodoc
class _$SnChatMemberCopyWithImpl<$Res>
    implements $SnChatMemberCopyWith<$Res> {
  _$SnChatMemberCopyWithImpl(this._self, this._then);

  final SnChatMember _self;
  final $Res Function(SnChatMember) _then;

/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? chatRoomId = null,Object? chatRoom = freezed,Object? accountId = null,Object? account = null,Object? nick = freezed,Object? notify = null,Object? joinedAt = freezed,Object? breakUntil = freezed,Object? timeoutUntil = freezed,Object? lastReadAt = freezed,Object? status = freezed,Object? realmNick = freezed,Object? realmBio = freezed,Object? realmExperience = freezed,Object? realmLevel = freezed,Object? realmLevelingProgress = freezed,Object? realmLabel = freezed,Object? lastTyped = freezed,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as String,chatRoom: freezed == chatRoom ? _self.chatRoom : chatRoom // ignore: cast_nullable_to_non_nullable
as SnChatRoom?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount,nick: freezed == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String?,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,breakUntil: freezed == breakUntil ? _self.breakUntil : breakUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,timeoutUntil: freezed == timeoutUntil ? _self.timeoutUntil : timeoutUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnAccountStatus?,realmNick: freezed == realmNick ? _self.realmNick : realmNick // ignore: cast_nullable_to_non_nullable
as String?,realmBio: freezed == realmBio ? _self.realmBio : realmBio // ignore: cast_nullable_to_non_nullable
as String?,realmExperience: freezed == realmExperience ? _self.realmExperience : realmExperience // ignore: cast_nullable_to_non_nullable
as int?,realmLevel: freezed == realmLevel ? _self.realmLevel : realmLevel // ignore: cast_nullable_to_non_nullable
as int?,realmLevelingProgress: freezed == realmLevelingProgress ? _self.realmLevelingProgress : realmLevelingProgress // ignore: cast_nullable_to_non_nullable
as double?,realmLabel: freezed == realmLabel ? _self.realmLabel : realmLabel // ignore: cast_nullable_to_non_nullable
as SnRealmLabel?,lastTyped: freezed == lastTyped ? _self.lastTyped : lastTyped // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatRoomCopyWith<$Res>? get chatRoom {
    if (_self.chatRoom == null) {
    return null;
  }

  return $SnChatRoomCopyWith<$Res>(_self.chatRoom!, (value) {
    return _then(_self.copyWith(chatRoom: value));
  });
}/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get account {
  
  return $SnAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $SnAccountStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmLabelCopyWith<$Res>? get realmLabel {
    if (_self.realmLabel == null) {
    return null;
  }

  return $SnRealmLabelCopyWith<$Res>(_self.realmLabel!, (value) {
    return _then(_self.copyWith(realmLabel: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnChatMember].
extension SnChatMemberPatterns on SnChatMember {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnChatMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnChatMember() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnChatMember value)  $default,){
final _that = this;
switch (_that) {
case _SnChatMember():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnChatMember value)?  $default,){
final _that = this;
switch (_that) {
case _SnChatMember() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String chatRoomId,  SnChatRoom? chatRoom,  String accountId,  SnAccount account,  String? nick,  int notify,  DateTime? joinedAt,  DateTime? breakUntil,  DateTime? timeoutUntil,  DateTime? lastReadAt,  SnAccountStatus? status,  String? realmNick,  String? realmBio,  int? realmExperience,  int? realmLevel,  double? realmLevelingProgress,  SnRealmLabel? realmLabel,  DateTime? lastTyped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnChatMember() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.chatRoomId,_that.chatRoom,_that.accountId,_that.account,_that.nick,_that.notify,_that.joinedAt,_that.breakUntil,_that.timeoutUntil,_that.lastReadAt,_that.status,_that.realmNick,_that.realmBio,_that.realmExperience,_that.realmLevel,_that.realmLevelingProgress,_that.realmLabel,_that.lastTyped);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String chatRoomId,  SnChatRoom? chatRoom,  String accountId,  SnAccount account,  String? nick,  int notify,  DateTime? joinedAt,  DateTime? breakUntil,  DateTime? timeoutUntil,  DateTime? lastReadAt,  SnAccountStatus? status,  String? realmNick,  String? realmBio,  int? realmExperience,  int? realmLevel,  double? realmLevelingProgress,  SnRealmLabel? realmLabel,  DateTime? lastTyped)  $default,) {final _that = this;
switch (_that) {
case _SnChatMember():
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.chatRoomId,_that.chatRoom,_that.accountId,_that.account,_that.nick,_that.notify,_that.joinedAt,_that.breakUntil,_that.timeoutUntil,_that.lastReadAt,_that.status,_that.realmNick,_that.realmBio,_that.realmExperience,_that.realmLevel,_that.realmLevelingProgress,_that.realmLabel,_that.lastTyped);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String chatRoomId,  SnChatRoom? chatRoom,  String accountId,  SnAccount account,  String? nick,  int notify,  DateTime? joinedAt,  DateTime? breakUntil,  DateTime? timeoutUntil,  DateTime? lastReadAt,  SnAccountStatus? status,  String? realmNick,  String? realmBio,  int? realmExperience,  int? realmLevel,  double? realmLevelingProgress,  SnRealmLabel? realmLabel,  DateTime? lastTyped)?  $default,) {final _that = this;
switch (_that) {
case _SnChatMember() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.chatRoomId,_that.chatRoom,_that.accountId,_that.account,_that.nick,_that.notify,_that.joinedAt,_that.breakUntil,_that.timeoutUntil,_that.lastReadAt,_that.status,_that.realmNick,_that.realmBio,_that.realmExperience,_that.realmLevel,_that.realmLevelingProgress,_that.realmLabel,_that.lastTyped);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnChatMember implements SnChatMember {
  const _SnChatMember({required this.createdAt, required this.updatedAt, required this.deletedAt, required this.id, required this.chatRoomId, required this.chatRoom, required this.accountId, required this.account, required this.nick, required this.notify, required this.joinedAt, required this.breakUntil, required this.timeoutUntil, required this.lastReadAt, required this.status, required this.realmNick, required this.realmBio, required this.realmExperience, required this.realmLevel, required this.realmLevelingProgress, required this.realmLabel, this.lastTyped});
  factory _SnChatMember.fromJson(Map<String, dynamic> json) => _$SnChatMemberFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  String id;
@override final  String chatRoomId;
@override final  SnChatRoom? chatRoom;
@override final  String accountId;
@override final  SnAccount account;
@override final  String? nick;
@override final  int notify;
@override final  DateTime? joinedAt;
@override final  DateTime? breakUntil;
@override final  DateTime? timeoutUntil;
@override final  DateTime? lastReadAt;
@override final  SnAccountStatus? status;
// Realm related-content
@override final  String? realmNick;
@override final  String? realmBio;
@override final  int? realmExperience;
@override final  int? realmLevel;
@override final  double? realmLevelingProgress;
@override final  SnRealmLabel? realmLabel;
// Frontend data
@override final  DateTime? lastTyped;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChatMember&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.chatRoomId, chatRoomId) || other.chatRoomId == chatRoomId)&&(identical(other.chatRoom, chatRoom) || other.chatRoom == chatRoom)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.notify, notify) || other.notify == notify)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.breakUntil, breakUntil) || other.breakUntil == breakUntil)&&(identical(other.timeoutUntil, timeoutUntil) || other.timeoutUntil == timeoutUntil)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.realmNick, realmNick) || other.realmNick == realmNick)&&(identical(other.realmBio, realmBio) || other.realmBio == realmBio)&&(identical(other.realmExperience, realmExperience) || other.realmExperience == realmExperience)&&(identical(other.realmLevel, realmLevel) || other.realmLevel == realmLevel)&&(identical(other.realmLevelingProgress, realmLevelingProgress) || other.realmLevelingProgress == realmLevelingProgress)&&(identical(other.realmLabel, realmLabel) || other.realmLabel == realmLabel)&&(identical(other.lastTyped, lastTyped) || other.lastTyped == lastTyped));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,createdAt,updatedAt,deletedAt,id,chatRoomId,chatRoom,accountId,account,nick,notify,joinedAt,breakUntil,timeoutUntil,lastReadAt,status,realmNick,realmBio,realmExperience,realmLevel,realmLevelingProgress,realmLabel,lastTyped]);

@override
String toString() {
  return 'SnChatMember(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, chatRoomId: $chatRoomId, chatRoom: $chatRoom, accountId: $accountId, account: $account, nick: $nick, notify: $notify, joinedAt: $joinedAt, breakUntil: $breakUntil, timeoutUntil: $timeoutUntil, lastReadAt: $lastReadAt, status: $status, realmNick: $realmNick, realmBio: $realmBio, realmExperience: $realmExperience, realmLevel: $realmLevel, realmLevelingProgress: $realmLevelingProgress, realmLabel: $realmLabel, lastTyped: $lastTyped)';
}


}

/// @nodoc
abstract mixin class _$SnChatMemberCopyWith<$Res> implements $SnChatMemberCopyWith<$Res> {
  factory _$SnChatMemberCopyWith(_SnChatMember value, $Res Function(_SnChatMember) _then) = __$SnChatMemberCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String chatRoomId, SnChatRoom? chatRoom, String accountId, SnAccount account, String? nick, int notify, DateTime? joinedAt, DateTime? breakUntil, DateTime? timeoutUntil, DateTime? lastReadAt, SnAccountStatus? status, String? realmNick, String? realmBio, int? realmExperience, int? realmLevel, double? realmLevelingProgress, SnRealmLabel? realmLabel, DateTime? lastTyped
});


@override $SnChatRoomCopyWith<$Res>? get chatRoom;@override $SnAccountCopyWith<$Res> get account;@override $SnAccountStatusCopyWith<$Res>? get status;@override $SnRealmLabelCopyWith<$Res>? get realmLabel;

}
/// @nodoc
class __$SnChatMemberCopyWithImpl<$Res>
    implements _$SnChatMemberCopyWith<$Res> {
  __$SnChatMemberCopyWithImpl(this._self, this._then);

  final _SnChatMember _self;
  final $Res Function(_SnChatMember) _then;

/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? chatRoomId = null,Object? chatRoom = freezed,Object? accountId = null,Object? account = null,Object? nick = freezed,Object? notify = null,Object? joinedAt = freezed,Object? breakUntil = freezed,Object? timeoutUntil = freezed,Object? lastReadAt = freezed,Object? status = freezed,Object? realmNick = freezed,Object? realmBio = freezed,Object? realmExperience = freezed,Object? realmLevel = freezed,Object? realmLevelingProgress = freezed,Object? realmLabel = freezed,Object? lastTyped = freezed,}) {
  return _then(_SnChatMember(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatRoomId: null == chatRoomId ? _self.chatRoomId : chatRoomId // ignore: cast_nullable_to_non_nullable
as String,chatRoom: freezed == chatRoom ? _self.chatRoom : chatRoom // ignore: cast_nullable_to_non_nullable
as SnChatRoom?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount,nick: freezed == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String?,notify: null == notify ? _self.notify : notify // ignore: cast_nullable_to_non_nullable
as int,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,breakUntil: freezed == breakUntil ? _self.breakUntil : breakUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,timeoutUntil: freezed == timeoutUntil ? _self.timeoutUntil : timeoutUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnAccountStatus?,realmNick: freezed == realmNick ? _self.realmNick : realmNick // ignore: cast_nullable_to_non_nullable
as String?,realmBio: freezed == realmBio ? _self.realmBio : realmBio // ignore: cast_nullable_to_non_nullable
as String?,realmExperience: freezed == realmExperience ? _self.realmExperience : realmExperience // ignore: cast_nullable_to_non_nullable
as int?,realmLevel: freezed == realmLevel ? _self.realmLevel : realmLevel // ignore: cast_nullable_to_non_nullable
as int?,realmLevelingProgress: freezed == realmLevelingProgress ? _self.realmLevelingProgress : realmLevelingProgress // ignore: cast_nullable_to_non_nullable
as double?,realmLabel: freezed == realmLabel ? _self.realmLabel : realmLabel // ignore: cast_nullable_to_non_nullable
as SnRealmLabel?,lastTyped: freezed == lastTyped ? _self.lastTyped : lastTyped // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatRoomCopyWith<$Res>? get chatRoom {
    if (_self.chatRoom == null) {
    return null;
  }

  return $SnChatRoomCopyWith<$Res>(_self.chatRoom!, (value) {
    return _then(_self.copyWith(chatRoom: value));
  });
}/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get account {
  
  return $SnAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res>? get status {
    if (_self.status == null) {
    return null;
  }

  return $SnAccountStatusCopyWith<$Res>(_self.status!, (value) {
    return _then(_self.copyWith(status: value));
  });
}/// Create a copy of SnChatMember
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnRealmLabelCopyWith<$Res>? get realmLabel {
    if (_self.realmLabel == null) {
    return null;
  }

  return $SnRealmLabelCopyWith<$Res>(_self.realmLabel!, (value) {
    return _then(_self.copyWith(realmLabel: value));
  });
}
}


/// @nodoc
mixin _$SnChatSummary {

 int get unreadCount; SnChatMessage? get lastMessage;
/// Create a copy of SnChatSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatSummaryCopyWith<SnChatSummary> get copyWith => _$SnChatSummaryCopyWithImpl<SnChatSummary>(this as SnChatSummary, _$identity);

  /// Serializes this SnChatSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChatSummary&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unreadCount,lastMessage);

@override
String toString() {
  return 'SnChatSummary(unreadCount: $unreadCount, lastMessage: $lastMessage)';
}


}

/// @nodoc
abstract mixin class $SnChatSummaryCopyWith<$Res>  {
  factory $SnChatSummaryCopyWith(SnChatSummary value, $Res Function(SnChatSummary) _then) = _$SnChatSummaryCopyWithImpl;
@useResult
$Res call({
 int unreadCount, SnChatMessage? lastMessage
});


$SnChatMessageCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class _$SnChatSummaryCopyWithImpl<$Res>
    implements $SnChatSummaryCopyWith<$Res> {
  _$SnChatSummaryCopyWithImpl(this._self, this._then);

  final SnChatSummary _self;
  final $Res Function(SnChatSummary) _then;

/// Create a copy of SnChatSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unreadCount = null,Object? lastMessage = freezed,}) {
  return _then(_self.copyWith(
unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as SnChatMessage?,
  ));
}
/// Create a copy of SnChatSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMessageCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $SnChatMessageCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnChatSummary].
extension SnChatSummaryPatterns on SnChatSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnChatSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnChatSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnChatSummary value)  $default,){
final _that = this;
switch (_that) {
case _SnChatSummary():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnChatSummary value)?  $default,){
final _that = this;
switch (_that) {
case _SnChatSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int unreadCount,  SnChatMessage? lastMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnChatSummary() when $default != null:
return $default(_that.unreadCount,_that.lastMessage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int unreadCount,  SnChatMessage? lastMessage)  $default,) {final _that = this;
switch (_that) {
case _SnChatSummary():
return $default(_that.unreadCount,_that.lastMessage);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int unreadCount,  SnChatMessage? lastMessage)?  $default,) {final _that = this;
switch (_that) {
case _SnChatSummary() when $default != null:
return $default(_that.unreadCount,_that.lastMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnChatSummary implements SnChatSummary {
  const _SnChatSummary({required this.unreadCount, required this.lastMessage});
  factory _SnChatSummary.fromJson(Map<String, dynamic> json) => _$SnChatSummaryFromJson(json);

@override final  int unreadCount;
@override final  SnChatMessage? lastMessage;

/// Create a copy of SnChatSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnChatSummaryCopyWith<_SnChatSummary> get copyWith => __$SnChatSummaryCopyWithImpl<_SnChatSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnChatSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChatSummary&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unreadCount,lastMessage);

@override
String toString() {
  return 'SnChatSummary(unreadCount: $unreadCount, lastMessage: $lastMessage)';
}


}

/// @nodoc
abstract mixin class _$SnChatSummaryCopyWith<$Res> implements $SnChatSummaryCopyWith<$Res> {
  factory _$SnChatSummaryCopyWith(_SnChatSummary value, $Res Function(_SnChatSummary) _then) = __$SnChatSummaryCopyWithImpl;
@override @useResult
$Res call({
 int unreadCount, SnChatMessage? lastMessage
});


@override $SnChatMessageCopyWith<$Res>? get lastMessage;

}
/// @nodoc
class __$SnChatSummaryCopyWithImpl<$Res>
    implements _$SnChatSummaryCopyWith<$Res> {
  __$SnChatSummaryCopyWithImpl(this._self, this._then);

  final _SnChatSummary _self;
  final $Res Function(_SnChatSummary) _then;

/// Create a copy of SnChatSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unreadCount = null,Object? lastMessage = freezed,}) {
  return _then(_SnChatSummary(
unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as SnChatMessage?,
  ));
}

/// Create a copy of SnChatSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMessageCopyWith<$Res>? get lastMessage {
    if (_self.lastMessage == null) {
    return null;
  }

  return $SnChatMessageCopyWith<$Res>(_self.lastMessage!, (value) {
    return _then(_self.copyWith(lastMessage: value));
  });
}
}


/// @nodoc
mixin _$SnChatOnlineAccount {

 String get id; String get name; String get nick;
/// Create a copy of SnChatOnlineAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatOnlineAccountCopyWith<SnChatOnlineAccount> get copyWith => _$SnChatOnlineAccountCopyWithImpl<SnChatOnlineAccount>(this as SnChatOnlineAccount, _$identity);

  /// Serializes this SnChatOnlineAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChatOnlineAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick);

@override
String toString() {
  return 'SnChatOnlineAccount(id: $id, name: $name, nick: $nick)';
}


}

/// @nodoc
abstract mixin class $SnChatOnlineAccountCopyWith<$Res>  {
  factory $SnChatOnlineAccountCopyWith(SnChatOnlineAccount value, $Res Function(SnChatOnlineAccount) _then) = _$SnChatOnlineAccountCopyWithImpl;
@useResult
$Res call({
 String id, String name, String nick
});




}
/// @nodoc
class _$SnChatOnlineAccountCopyWithImpl<$Res>
    implements $SnChatOnlineAccountCopyWith<$Res> {
  _$SnChatOnlineAccountCopyWithImpl(this._self, this._then);

  final SnChatOnlineAccount _self;
  final $Res Function(SnChatOnlineAccount) _then;

/// Create a copy of SnChatOnlineAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nick = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnChatOnlineAccount].
extension SnChatOnlineAccountPatterns on SnChatOnlineAccount {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnChatOnlineAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnChatOnlineAccount() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnChatOnlineAccount value)  $default,){
final _that = this;
switch (_that) {
case _SnChatOnlineAccount():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnChatOnlineAccount value)?  $default,){
final _that = this;
switch (_that) {
case _SnChatOnlineAccount() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String nick)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnChatOnlineAccount() when $default != null:
return $default(_that.id,_that.name,_that.nick);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String nick)  $default,) {final _that = this;
switch (_that) {
case _SnChatOnlineAccount():
return $default(_that.id,_that.name,_that.nick);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String nick)?  $default,) {final _that = this;
switch (_that) {
case _SnChatOnlineAccount() when $default != null:
return $default(_that.id,_that.name,_that.nick);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnChatOnlineAccount implements SnChatOnlineAccount {
  const _SnChatOnlineAccount({required this.id, required this.name, required this.nick});
  factory _SnChatOnlineAccount.fromJson(Map<String, dynamic> json) => _$SnChatOnlineAccountFromJson(json);

@override final  String id;
@override final  String name;
@override final  String nick;

/// Create a copy of SnChatOnlineAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnChatOnlineAccountCopyWith<_SnChatOnlineAccount> get copyWith => __$SnChatOnlineAccountCopyWithImpl<_SnChatOnlineAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnChatOnlineAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChatOnlineAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick);

@override
String toString() {
  return 'SnChatOnlineAccount(id: $id, name: $name, nick: $nick)';
}


}

/// @nodoc
abstract mixin class _$SnChatOnlineAccountCopyWith<$Res> implements $SnChatOnlineAccountCopyWith<$Res> {
  factory _$SnChatOnlineAccountCopyWith(_SnChatOnlineAccount value, $Res Function(_SnChatOnlineAccount) _then) = __$SnChatOnlineAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String nick
});




}
/// @nodoc
class __$SnChatOnlineAccountCopyWithImpl<$Res>
    implements _$SnChatOnlineAccountCopyWith<$Res> {
  __$SnChatOnlineAccountCopyWithImpl(this._self, this._then);

  final _SnChatOnlineAccount _self;
  final $Res Function(_SnChatOnlineAccount) _then;

/// Create a copy of SnChatOnlineAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nick = null,}) {
  return _then(_SnChatOnlineAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnChatOnlineStatus {

 int get onlineCount; SnAccountStatus? get directMessageStatus; List<String> get onlineUserNames; List<SnChatOnlineAccount> get onlineAccounts;
/// Create a copy of SnChatOnlineStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnChatOnlineStatusCopyWith<SnChatOnlineStatus> get copyWith => _$SnChatOnlineStatusCopyWithImpl<SnChatOnlineStatus>(this as SnChatOnlineStatus, _$identity);

  /// Serializes this SnChatOnlineStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnChatOnlineStatus&&(identical(other.onlineCount, onlineCount) || other.onlineCount == onlineCount)&&(identical(other.directMessageStatus, directMessageStatus) || other.directMessageStatus == directMessageStatus)&&const DeepCollectionEquality().equals(other.onlineUserNames, onlineUserNames)&&const DeepCollectionEquality().equals(other.onlineAccounts, onlineAccounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,onlineCount,directMessageStatus,const DeepCollectionEquality().hash(onlineUserNames),const DeepCollectionEquality().hash(onlineAccounts));

@override
String toString() {
  return 'SnChatOnlineStatus(onlineCount: $onlineCount, directMessageStatus: $directMessageStatus, onlineUserNames: $onlineUserNames, onlineAccounts: $onlineAccounts)';
}


}

/// @nodoc
abstract mixin class $SnChatOnlineStatusCopyWith<$Res>  {
  factory $SnChatOnlineStatusCopyWith(SnChatOnlineStatus value, $Res Function(SnChatOnlineStatus) _then) = _$SnChatOnlineStatusCopyWithImpl;
@useResult
$Res call({
 int onlineCount, SnAccountStatus? directMessageStatus, List<String> onlineUserNames, List<SnChatOnlineAccount> onlineAccounts
});


$SnAccountStatusCopyWith<$Res>? get directMessageStatus;

}
/// @nodoc
class _$SnChatOnlineStatusCopyWithImpl<$Res>
    implements $SnChatOnlineStatusCopyWith<$Res> {
  _$SnChatOnlineStatusCopyWithImpl(this._self, this._then);

  final SnChatOnlineStatus _self;
  final $Res Function(SnChatOnlineStatus) _then;

/// Create a copy of SnChatOnlineStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? onlineCount = null,Object? directMessageStatus = freezed,Object? onlineUserNames = null,Object? onlineAccounts = null,}) {
  return _then(_self.copyWith(
onlineCount: null == onlineCount ? _self.onlineCount : onlineCount // ignore: cast_nullable_to_non_nullable
as int,directMessageStatus: freezed == directMessageStatus ? _self.directMessageStatus : directMessageStatus // ignore: cast_nullable_to_non_nullable
as SnAccountStatus?,onlineUserNames: null == onlineUserNames ? _self.onlineUserNames : onlineUserNames // ignore: cast_nullable_to_non_nullable
as List<String>,onlineAccounts: null == onlineAccounts ? _self.onlineAccounts : onlineAccounts // ignore: cast_nullable_to_non_nullable
as List<SnChatOnlineAccount>,
  ));
}
/// Create a copy of SnChatOnlineStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res>? get directMessageStatus {
    if (_self.directMessageStatus == null) {
    return null;
  }

  return $SnAccountStatusCopyWith<$Res>(_self.directMessageStatus!, (value) {
    return _then(_self.copyWith(directMessageStatus: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnChatOnlineStatus].
extension SnChatOnlineStatusPatterns on SnChatOnlineStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnChatOnlineStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnChatOnlineStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnChatOnlineStatus value)  $default,){
final _that = this;
switch (_that) {
case _SnChatOnlineStatus():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnChatOnlineStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SnChatOnlineStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int onlineCount,  SnAccountStatus? directMessageStatus,  List<String> onlineUserNames,  List<SnChatOnlineAccount> onlineAccounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnChatOnlineStatus() when $default != null:
return $default(_that.onlineCount,_that.directMessageStatus,_that.onlineUserNames,_that.onlineAccounts);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int onlineCount,  SnAccountStatus? directMessageStatus,  List<String> onlineUserNames,  List<SnChatOnlineAccount> onlineAccounts)  $default,) {final _that = this;
switch (_that) {
case _SnChatOnlineStatus():
return $default(_that.onlineCount,_that.directMessageStatus,_that.onlineUserNames,_that.onlineAccounts);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int onlineCount,  SnAccountStatus? directMessageStatus,  List<String> onlineUserNames,  List<SnChatOnlineAccount> onlineAccounts)?  $default,) {final _that = this;
switch (_that) {
case _SnChatOnlineStatus() when $default != null:
return $default(_that.onlineCount,_that.directMessageStatus,_that.onlineUserNames,_that.onlineAccounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnChatOnlineStatus implements SnChatOnlineStatus {
  const _SnChatOnlineStatus({required this.onlineCount, this.directMessageStatus, final  List<String> onlineUserNames = const [], final  List<SnChatOnlineAccount> onlineAccounts = const []}): _onlineUserNames = onlineUserNames,_onlineAccounts = onlineAccounts;
  factory _SnChatOnlineStatus.fromJson(Map<String, dynamic> json) => _$SnChatOnlineStatusFromJson(json);

@override final  int onlineCount;
@override final  SnAccountStatus? directMessageStatus;
 final  List<String> _onlineUserNames;
@override@JsonKey() List<String> get onlineUserNames {
  if (_onlineUserNames is EqualUnmodifiableListView) return _onlineUserNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_onlineUserNames);
}

 final  List<SnChatOnlineAccount> _onlineAccounts;
@override@JsonKey() List<SnChatOnlineAccount> get onlineAccounts {
  if (_onlineAccounts is EqualUnmodifiableListView) return _onlineAccounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_onlineAccounts);
}


/// Create a copy of SnChatOnlineStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnChatOnlineStatusCopyWith<_SnChatOnlineStatus> get copyWith => __$SnChatOnlineStatusCopyWithImpl<_SnChatOnlineStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnChatOnlineStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnChatOnlineStatus&&(identical(other.onlineCount, onlineCount) || other.onlineCount == onlineCount)&&(identical(other.directMessageStatus, directMessageStatus) || other.directMessageStatus == directMessageStatus)&&const DeepCollectionEquality().equals(other._onlineUserNames, _onlineUserNames)&&const DeepCollectionEquality().equals(other._onlineAccounts, _onlineAccounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,onlineCount,directMessageStatus,const DeepCollectionEquality().hash(_onlineUserNames),const DeepCollectionEquality().hash(_onlineAccounts));

@override
String toString() {
  return 'SnChatOnlineStatus(onlineCount: $onlineCount, directMessageStatus: $directMessageStatus, onlineUserNames: $onlineUserNames, onlineAccounts: $onlineAccounts)';
}


}

/// @nodoc
abstract mixin class _$SnChatOnlineStatusCopyWith<$Res> implements $SnChatOnlineStatusCopyWith<$Res> {
  factory _$SnChatOnlineStatusCopyWith(_SnChatOnlineStatus value, $Res Function(_SnChatOnlineStatus) _then) = __$SnChatOnlineStatusCopyWithImpl;
@override @useResult
$Res call({
 int onlineCount, SnAccountStatus? directMessageStatus, List<String> onlineUserNames, List<SnChatOnlineAccount> onlineAccounts
});


@override $SnAccountStatusCopyWith<$Res>? get directMessageStatus;

}
/// @nodoc
class __$SnChatOnlineStatusCopyWithImpl<$Res>
    implements _$SnChatOnlineStatusCopyWith<$Res> {
  __$SnChatOnlineStatusCopyWithImpl(this._self, this._then);

  final _SnChatOnlineStatus _self;
  final $Res Function(_SnChatOnlineStatus) _then;

/// Create a copy of SnChatOnlineStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? onlineCount = null,Object? directMessageStatus = freezed,Object? onlineUserNames = null,Object? onlineAccounts = null,}) {
  return _then(_SnChatOnlineStatus(
onlineCount: null == onlineCount ? _self.onlineCount : onlineCount // ignore: cast_nullable_to_non_nullable
as int,directMessageStatus: freezed == directMessageStatus ? _self.directMessageStatus : directMessageStatus // ignore: cast_nullable_to_non_nullable
as SnAccountStatus?,onlineUserNames: null == onlineUserNames ? _self._onlineUserNames : onlineUserNames // ignore: cast_nullable_to_non_nullable
as List<String>,onlineAccounts: null == onlineAccounts ? _self._onlineAccounts : onlineAccounts // ignore: cast_nullable_to_non_nullable
as List<SnChatOnlineAccount>,
  ));
}

/// Create a copy of SnChatOnlineStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res>? get directMessageStatus {
    if (_self.directMessageStatus == null) {
    return null;
  }

  return $SnAccountStatusCopyWith<$Res>(_self.directMessageStatus!, (value) {
    return _then(_self.copyWith(directMessageStatus: value));
  });
}
}


/// @nodoc
mixin _$MessageSyncResponse {

 List<SnChatMessage> get messages; int get totalCount; DateTime get currentTimestamp;
/// Create a copy of MessageSyncResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSyncResponseCopyWith<MessageSyncResponse> get copyWith => _$MessageSyncResponseCopyWithImpl<MessageSyncResponse>(this as MessageSyncResponse, _$identity);

  /// Serializes this MessageSyncResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSyncResponse&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.currentTimestamp, currentTimestamp) || other.currentTimestamp == currentTimestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),totalCount,currentTimestamp);

@override
String toString() {
  return 'MessageSyncResponse(messages: $messages, totalCount: $totalCount, currentTimestamp: $currentTimestamp)';
}


}

/// @nodoc
abstract mixin class $MessageSyncResponseCopyWith<$Res>  {
  factory $MessageSyncResponseCopyWith(MessageSyncResponse value, $Res Function(MessageSyncResponse) _then) = _$MessageSyncResponseCopyWithImpl;
@useResult
$Res call({
 List<SnChatMessage> messages, int totalCount, DateTime currentTimestamp
});




}
/// @nodoc
class _$MessageSyncResponseCopyWithImpl<$Res>
    implements $MessageSyncResponseCopyWith<$Res> {
  _$MessageSyncResponseCopyWithImpl(this._self, this._then);

  final MessageSyncResponse _self;
  final $Res Function(MessageSyncResponse) _then;

/// Create a copy of MessageSyncResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? totalCount = null,Object? currentTimestamp = null,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<SnChatMessage>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,currentTimestamp: null == currentTimestamp ? _self.currentTimestamp : currentTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageSyncResponse].
extension MessageSyncResponsePatterns on MessageSyncResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageSyncResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageSyncResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageSyncResponse value)  $default,){
final _that = this;
switch (_that) {
case _MessageSyncResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageSyncResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MessageSyncResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SnChatMessage> messages,  int totalCount,  DateTime currentTimestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageSyncResponse() when $default != null:
return $default(_that.messages,_that.totalCount,_that.currentTimestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SnChatMessage> messages,  int totalCount,  DateTime currentTimestamp)  $default,) {final _that = this;
switch (_that) {
case _MessageSyncResponse():
return $default(_that.messages,_that.totalCount,_that.currentTimestamp);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SnChatMessage> messages,  int totalCount,  DateTime currentTimestamp)?  $default,) {final _that = this;
switch (_that) {
case _MessageSyncResponse() when $default != null:
return $default(_that.messages,_that.totalCount,_that.currentTimestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageSyncResponse implements MessageSyncResponse {
  const _MessageSyncResponse({final  List<SnChatMessage> messages = const [], this.totalCount = 0, required this.currentTimestamp}): _messages = messages;
  factory _MessageSyncResponse.fromJson(Map<String, dynamic> json) => _$MessageSyncResponseFromJson(json);

 final  List<SnChatMessage> _messages;
@override@JsonKey() List<SnChatMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

@override@JsonKey() final  int totalCount;
@override final  DateTime currentTimestamp;

/// Create a copy of MessageSyncResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSyncResponseCopyWith<_MessageSyncResponse> get copyWith => __$MessageSyncResponseCopyWithImpl<_MessageSyncResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageSyncResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSyncResponse&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.currentTimestamp, currentTimestamp) || other.currentTimestamp == currentTimestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),totalCount,currentTimestamp);

@override
String toString() {
  return 'MessageSyncResponse(messages: $messages, totalCount: $totalCount, currentTimestamp: $currentTimestamp)';
}


}

/// @nodoc
abstract mixin class _$MessageSyncResponseCopyWith<$Res> implements $MessageSyncResponseCopyWith<$Res> {
  factory _$MessageSyncResponseCopyWith(_MessageSyncResponse value, $Res Function(_MessageSyncResponse) _then) = __$MessageSyncResponseCopyWithImpl;
@override @useResult
$Res call({
 List<SnChatMessage> messages, int totalCount, DateTime currentTimestamp
});




}
/// @nodoc
class __$MessageSyncResponseCopyWithImpl<$Res>
    implements _$MessageSyncResponseCopyWith<$Res> {
  __$MessageSyncResponseCopyWithImpl(this._self, this._then);

  final _MessageSyncResponse _self;
  final $Res Function(_MessageSyncResponse) _then;

/// Create a copy of MessageSyncResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? totalCount = null,Object? currentTimestamp = null,}) {
  return _then(_MessageSyncResponse(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<SnChatMessage>,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,currentTimestamp: null == currentTimestamp ? _self.currentTimestamp : currentTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ChatRealtimeJoinResponse {

 String get provider; String get endpoint; String get token; String get callId; String get roomName; bool get isAdmin; List<CallParticipant> get participants;
/// Create a copy of ChatRealtimeJoinResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatRealtimeJoinResponseCopyWith<ChatRealtimeJoinResponse> get copyWith => _$ChatRealtimeJoinResponseCopyWithImpl<ChatRealtimeJoinResponse>(this as ChatRealtimeJoinResponse, _$identity);

  /// Serializes this ChatRealtimeJoinResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatRealtimeJoinResponse&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.endpoint, endpoint) || other.endpoint == endpoint)&&(identical(other.token, token) || other.token == token)&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&const DeepCollectionEquality().equals(other.participants, participants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,endpoint,token,callId,roomName,isAdmin,const DeepCollectionEquality().hash(participants));

@override
String toString() {
  return 'ChatRealtimeJoinResponse(provider: $provider, endpoint: $endpoint, token: $token, callId: $callId, roomName: $roomName, isAdmin: $isAdmin, participants: $participants)';
}


}

/// @nodoc
abstract mixin class $ChatRealtimeJoinResponseCopyWith<$Res>  {
  factory $ChatRealtimeJoinResponseCopyWith(ChatRealtimeJoinResponse value, $Res Function(ChatRealtimeJoinResponse) _then) = _$ChatRealtimeJoinResponseCopyWithImpl;
@useResult
$Res call({
 String provider, String endpoint, String token, String callId, String roomName, bool isAdmin, List<CallParticipant> participants
});




}
/// @nodoc
class _$ChatRealtimeJoinResponseCopyWithImpl<$Res>
    implements $ChatRealtimeJoinResponseCopyWith<$Res> {
  _$ChatRealtimeJoinResponseCopyWithImpl(this._self, this._then);

  final ChatRealtimeJoinResponse _self;
  final $Res Function(ChatRealtimeJoinResponse) _then;

/// Create a copy of ChatRealtimeJoinResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? endpoint = null,Object? token = null,Object? callId = null,Object? roomName = null,Object? isAdmin = null,Object? participants = null,}) {
  return _then(_self.copyWith(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,endpoint: null == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<CallParticipant>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatRealtimeJoinResponse].
extension ChatRealtimeJoinResponsePatterns on ChatRealtimeJoinResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatRealtimeJoinResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatRealtimeJoinResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatRealtimeJoinResponse value)  $default,){
final _that = this;
switch (_that) {
case _ChatRealtimeJoinResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatRealtimeJoinResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ChatRealtimeJoinResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String provider,  String endpoint,  String token,  String callId,  String roomName,  bool isAdmin,  List<CallParticipant> participants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatRealtimeJoinResponse() when $default != null:
return $default(_that.provider,_that.endpoint,_that.token,_that.callId,_that.roomName,_that.isAdmin,_that.participants);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String provider,  String endpoint,  String token,  String callId,  String roomName,  bool isAdmin,  List<CallParticipant> participants)  $default,) {final _that = this;
switch (_that) {
case _ChatRealtimeJoinResponse():
return $default(_that.provider,_that.endpoint,_that.token,_that.callId,_that.roomName,_that.isAdmin,_that.participants);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String provider,  String endpoint,  String token,  String callId,  String roomName,  bool isAdmin,  List<CallParticipant> participants)?  $default,) {final _that = this;
switch (_that) {
case _ChatRealtimeJoinResponse() when $default != null:
return $default(_that.provider,_that.endpoint,_that.token,_that.callId,_that.roomName,_that.isAdmin,_that.participants);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatRealtimeJoinResponse implements ChatRealtimeJoinResponse {
  const _ChatRealtimeJoinResponse({required this.provider, required this.endpoint, required this.token, required this.callId, required this.roomName, required this.isAdmin, required final  List<CallParticipant> participants}): _participants = participants;
  factory _ChatRealtimeJoinResponse.fromJson(Map<String, dynamic> json) => _$ChatRealtimeJoinResponseFromJson(json);

@override final  String provider;
@override final  String endpoint;
@override final  String token;
@override final  String callId;
@override final  String roomName;
@override final  bool isAdmin;
 final  List<CallParticipant> _participants;
@override List<CallParticipant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}


/// Create a copy of ChatRealtimeJoinResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatRealtimeJoinResponseCopyWith<_ChatRealtimeJoinResponse> get copyWith => __$ChatRealtimeJoinResponseCopyWithImpl<_ChatRealtimeJoinResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatRealtimeJoinResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatRealtimeJoinResponse&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.endpoint, endpoint) || other.endpoint == endpoint)&&(identical(other.token, token) || other.token == token)&&(identical(other.callId, callId) || other.callId == callId)&&(identical(other.roomName, roomName) || other.roomName == roomName)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&const DeepCollectionEquality().equals(other._participants, _participants));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,provider,endpoint,token,callId,roomName,isAdmin,const DeepCollectionEquality().hash(_participants));

@override
String toString() {
  return 'ChatRealtimeJoinResponse(provider: $provider, endpoint: $endpoint, token: $token, callId: $callId, roomName: $roomName, isAdmin: $isAdmin, participants: $participants)';
}


}

/// @nodoc
abstract mixin class _$ChatRealtimeJoinResponseCopyWith<$Res> implements $ChatRealtimeJoinResponseCopyWith<$Res> {
  factory _$ChatRealtimeJoinResponseCopyWith(_ChatRealtimeJoinResponse value, $Res Function(_ChatRealtimeJoinResponse) _then) = __$ChatRealtimeJoinResponseCopyWithImpl;
@override @useResult
$Res call({
 String provider, String endpoint, String token, String callId, String roomName, bool isAdmin, List<CallParticipant> participants
});




}
/// @nodoc
class __$ChatRealtimeJoinResponseCopyWithImpl<$Res>
    implements _$ChatRealtimeJoinResponseCopyWith<$Res> {
  __$ChatRealtimeJoinResponseCopyWithImpl(this._self, this._then);

  final _ChatRealtimeJoinResponse _self;
  final $Res Function(_ChatRealtimeJoinResponse) _then;

/// Create a copy of ChatRealtimeJoinResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? endpoint = null,Object? token = null,Object? callId = null,Object? roomName = null,Object? isAdmin = null,Object? participants = null,}) {
  return _then(_ChatRealtimeJoinResponse(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,endpoint: null == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,roomName: null == roomName ? _self.roomName : roomName // ignore: cast_nullable_to_non_nullable
as String,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<CallParticipant>,
  ));
}


}


/// @nodoc
mixin _$CallParticipant {

 String get identity; String get name; DateTime get joinedAt;
/// Create a copy of CallParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallParticipantCopyWith<CallParticipant> get copyWith => _$CallParticipantCopyWithImpl<CallParticipant>(this as CallParticipant, _$identity);

  /// Serializes this CallParticipant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallParticipant&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.name, name) || other.name == name)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identity,name,joinedAt);

@override
String toString() {
  return 'CallParticipant(identity: $identity, name: $name, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class $CallParticipantCopyWith<$Res>  {
  factory $CallParticipantCopyWith(CallParticipant value, $Res Function(CallParticipant) _then) = _$CallParticipantCopyWithImpl;
@useResult
$Res call({
 String identity, String name, DateTime joinedAt
});




}
/// @nodoc
class _$CallParticipantCopyWithImpl<$Res>
    implements $CallParticipantCopyWith<$Res> {
  _$CallParticipantCopyWithImpl(this._self, this._then);

  final CallParticipant _self;
  final $Res Function(CallParticipant) _then;

/// Create a copy of CallParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identity = null,Object? name = null,Object? joinedAt = null,}) {
  return _then(_self.copyWith(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CallParticipant].
extension CallParticipantPatterns on CallParticipant {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallParticipant() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallParticipant value)  $default,){
final _that = this;
switch (_that) {
case _CallParticipant():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _CallParticipant() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identity,  String name,  DateTime joinedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallParticipant() when $default != null:
return $default(_that.identity,_that.name,_that.joinedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identity,  String name,  DateTime joinedAt)  $default,) {final _that = this;
switch (_that) {
case _CallParticipant():
return $default(_that.identity,_that.name,_that.joinedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identity,  String name,  DateTime joinedAt)?  $default,) {final _that = this;
switch (_that) {
case _CallParticipant() when $default != null:
return $default(_that.identity,_that.name,_that.joinedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CallParticipant implements CallParticipant {
  const _CallParticipant({required this.identity, required this.name, required this.joinedAt});
  factory _CallParticipant.fromJson(Map<String, dynamic> json) => _$CallParticipantFromJson(json);

@override final  String identity;
@override final  String name;
@override final  DateTime joinedAt;

/// Create a copy of CallParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallParticipantCopyWith<_CallParticipant> get copyWith => __$CallParticipantCopyWithImpl<_CallParticipant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallParticipant&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.name, name) || other.name == name)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identity,name,joinedAt);

@override
String toString() {
  return 'CallParticipant(identity: $identity, name: $name, joinedAt: $joinedAt)';
}


}

/// @nodoc
abstract mixin class _$CallParticipantCopyWith<$Res> implements $CallParticipantCopyWith<$Res> {
  factory _$CallParticipantCopyWith(_CallParticipant value, $Res Function(_CallParticipant) _then) = __$CallParticipantCopyWithImpl;
@override @useResult
$Res call({
 String identity, String name, DateTime joinedAt
});




}
/// @nodoc
class __$CallParticipantCopyWithImpl<$Res>
    implements _$CallParticipantCopyWith<$Res> {
  __$CallParticipantCopyWithImpl(this._self, this._then);

  final _CallParticipant _self;
  final $Res Function(_CallParticipant) _then;

/// Create a copy of CallParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identity = null,Object? name = null,Object? joinedAt = null,}) {
  return _then(_CallParticipant(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,joinedAt: null == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SnRealtimeCall {

 String get id; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; DateTime? get endedAt; String get senderId; SnChatMember get sender; String get roomId; SnChatRoom get room; Map<String, dynamic> get upstreamConfig; String? get providerName; String? get sessionId;
/// Create a copy of SnRealtimeCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRealtimeCallCopyWith<SnRealtimeCall> get copyWith => _$SnRealtimeCallCopyWithImpl<SnRealtimeCall>(this as SnRealtimeCall, _$identity);

  /// Serializes this SnRealtimeCall to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRealtimeCall&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.room, room) || other.room == room)&&const DeepCollectionEquality().equals(other.upstreamConfig, upstreamConfig)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,deletedAt,endedAt,senderId,sender,roomId,room,const DeepCollectionEquality().hash(upstreamConfig),providerName,sessionId);

@override
String toString() {
  return 'SnRealtimeCall(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, endedAt: $endedAt, senderId: $senderId, sender: $sender, roomId: $roomId, room: $room, upstreamConfig: $upstreamConfig, providerName: $providerName, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class $SnRealtimeCallCopyWith<$Res>  {
  factory $SnRealtimeCallCopyWith(SnRealtimeCall value, $Res Function(SnRealtimeCall) _then) = _$SnRealtimeCallCopyWithImpl;
@useResult
$Res call({
 String id, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, DateTime? endedAt, String senderId, SnChatMember sender, String roomId, SnChatRoom room, Map<String, dynamic> upstreamConfig, String? providerName, String? sessionId
});


$SnChatMemberCopyWith<$Res> get sender;$SnChatRoomCopyWith<$Res> get room;

}
/// @nodoc
class _$SnRealtimeCallCopyWithImpl<$Res>
    implements $SnRealtimeCallCopyWith<$Res> {
  _$SnRealtimeCallCopyWithImpl(this._self, this._then);

  final SnRealtimeCall _self;
  final $Res Function(SnRealtimeCall) _then;

/// Create a copy of SnRealtimeCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? endedAt = freezed,Object? senderId = null,Object? sender = null,Object? roomId = null,Object? room = null,Object? upstreamConfig = null,Object? providerName = freezed,Object? sessionId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnChatMember,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as SnChatRoom,upstreamConfig: null == upstreamConfig ? _self.upstreamConfig : upstreamConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,providerName: freezed == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SnRealtimeCall
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMemberCopyWith<$Res> get sender {
  
  return $SnChatMemberCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}/// Create a copy of SnRealtimeCall
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatRoomCopyWith<$Res> get room {
  
  return $SnChatRoomCopyWith<$Res>(_self.room, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnRealtimeCall].
extension SnRealtimeCallPatterns on SnRealtimeCall {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnRealtimeCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnRealtimeCall() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnRealtimeCall value)  $default,){
final _that = this;
switch (_that) {
case _SnRealtimeCall():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnRealtimeCall value)?  $default,){
final _that = this;
switch (_that) {
case _SnRealtimeCall() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  DateTime? endedAt,  String senderId,  SnChatMember sender,  String roomId,  SnChatRoom room,  Map<String, dynamic> upstreamConfig,  String? providerName,  String? sessionId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnRealtimeCall() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.endedAt,_that.senderId,_that.sender,_that.roomId,_that.room,_that.upstreamConfig,_that.providerName,_that.sessionId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  DateTime? endedAt,  String senderId,  SnChatMember sender,  String roomId,  SnChatRoom room,  Map<String, dynamic> upstreamConfig,  String? providerName,  String? sessionId)  $default,) {final _that = this;
switch (_that) {
case _SnRealtimeCall():
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.endedAt,_that.senderId,_that.sender,_that.roomId,_that.room,_that.upstreamConfig,_that.providerName,_that.sessionId);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  DateTime? endedAt,  String senderId,  SnChatMember sender,  String roomId,  SnChatRoom room,  Map<String, dynamic> upstreamConfig,  String? providerName,  String? sessionId)?  $default,) {final _that = this;
switch (_that) {
case _SnRealtimeCall() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.endedAt,_that.senderId,_that.sender,_that.roomId,_that.room,_that.upstreamConfig,_that.providerName,_that.sessionId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnRealtimeCall implements SnRealtimeCall {
  const _SnRealtimeCall({required this.id, required this.createdAt, required this.updatedAt, required this.deletedAt, required this.endedAt, required this.senderId, required this.sender, required this.roomId, required this.room, required final  Map<String, dynamic> upstreamConfig, this.providerName, this.sessionId}): _upstreamConfig = upstreamConfig;
  factory _SnRealtimeCall.fromJson(Map<String, dynamic> json) => _$SnRealtimeCallFromJson(json);

@override final  String id;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  DateTime? endedAt;
@override final  String senderId;
@override final  SnChatMember sender;
@override final  String roomId;
@override final  SnChatRoom room;
 final  Map<String, dynamic> _upstreamConfig;
@override Map<String, dynamic> get upstreamConfig {
  if (_upstreamConfig is EqualUnmodifiableMapView) return _upstreamConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_upstreamConfig);
}

@override final  String? providerName;
@override final  String? sessionId;

/// Create a copy of SnRealtimeCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnRealtimeCallCopyWith<_SnRealtimeCall> get copyWith => __$SnRealtimeCallCopyWithImpl<_SnRealtimeCall>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnRealtimeCallToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnRealtimeCall&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.roomId, roomId) || other.roomId == roomId)&&(identical(other.room, room) || other.room == room)&&const DeepCollectionEquality().equals(other._upstreamConfig, _upstreamConfig)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,deletedAt,endedAt,senderId,sender,roomId,room,const DeepCollectionEquality().hash(_upstreamConfig),providerName,sessionId);

@override
String toString() {
  return 'SnRealtimeCall(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, endedAt: $endedAt, senderId: $senderId, sender: $sender, roomId: $roomId, room: $room, upstreamConfig: $upstreamConfig, providerName: $providerName, sessionId: $sessionId)';
}


}

/// @nodoc
abstract mixin class _$SnRealtimeCallCopyWith<$Res> implements $SnRealtimeCallCopyWith<$Res> {
  factory _$SnRealtimeCallCopyWith(_SnRealtimeCall value, $Res Function(_SnRealtimeCall) _then) = __$SnRealtimeCallCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, DateTime? endedAt, String senderId, SnChatMember sender, String roomId, SnChatRoom room, Map<String, dynamic> upstreamConfig, String? providerName, String? sessionId
});


@override $SnChatMemberCopyWith<$Res> get sender;@override $SnChatRoomCopyWith<$Res> get room;

}
/// @nodoc
class __$SnRealtimeCallCopyWithImpl<$Res>
    implements _$SnRealtimeCallCopyWith<$Res> {
  __$SnRealtimeCallCopyWithImpl(this._self, this._then);

  final _SnRealtimeCall _self;
  final $Res Function(_SnRealtimeCall) _then;

/// Create a copy of SnRealtimeCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? endedAt = freezed,Object? senderId = null,Object? sender = null,Object? roomId = null,Object? room = null,Object? upstreamConfig = null,Object? providerName = freezed,Object? sessionId = freezed,}) {
  return _then(_SnRealtimeCall(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnChatMember,roomId: null == roomId ? _self.roomId : roomId // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as SnChatRoom,upstreamConfig: null == upstreamConfig ? _self._upstreamConfig : upstreamConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,providerName: freezed == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SnRealtimeCall
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatMemberCopyWith<$Res> get sender {
  
  return $SnChatMemberCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}/// Create a copy of SnRealtimeCall
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnChatRoomCopyWith<$Res> get room {
  
  return $SnChatRoomCopyWith<$Res>(_self.room, (value) {
    return _then(_self.copyWith(room: value));
  });
}
}

// dart format on
