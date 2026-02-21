// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'livestream_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {

 String get id;@JsonKey(name: 'sender_id') String get senderId;@JsonKey(name: 'sender_name') String get sender;@JsonKey(name: 'sender_identity') String? get senderIdentity;@JsonKey(name: 'content') String get message;@JsonKey(name: 'is_mine') bool get isMine;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'message_type') ChatMessageType get messageType; Map<String, dynamic>? get metadata;@JsonKey(name: 'sender') SnAccount? get senderAccount;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.senderIdentity, senderIdentity) || other.senderIdentity == senderIdentity)&&(identical(other.message, message) || other.message == message)&&(identical(other.isMine, isMine) || other.isMine == isMine)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.senderAccount, senderAccount) || other.senderAccount == senderAccount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,sender,senderIdentity,message,isMine,createdAt,messageType,const DeepCollectionEquality().hash(metadata),senderAccount);

@override
String toString() {
  return 'ChatMessage(id: $id, senderId: $senderId, sender: $sender, senderIdentity: $senderIdentity, message: $message, isMine: $isMine, createdAt: $createdAt, messageType: $messageType, metadata: $metadata, senderAccount: $senderAccount)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'sender_id') String senderId,@JsonKey(name: 'sender_name') String sender,@JsonKey(name: 'sender_identity') String? senderIdentity,@JsonKey(name: 'content') String message,@JsonKey(name: 'is_mine') bool isMine,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'message_type') ChatMessageType messageType, Map<String, dynamic>? metadata,@JsonKey(name: 'sender') SnAccount? senderAccount
});


$SnAccountCopyWith<$Res>? get senderAccount;

}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? sender = null,Object? senderIdentity = freezed,Object? message = null,Object? isMine = null,Object? createdAt = freezed,Object? messageType = null,Object? metadata = freezed,Object? senderAccount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,senderIdentity: freezed == senderIdentity ? _self.senderIdentity : senderIdentity // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as ChatMessageType,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,senderAccount: freezed == senderAccount ? _self.senderAccount : senderAccount // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get senderAccount {
    if (_self.senderAccount == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.senderAccount!, (value) {
    return _then(_self.copyWith(senderAccount: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'sender_name')  String sender, @JsonKey(name: 'sender_identity')  String? senderIdentity, @JsonKey(name: 'content')  String message, @JsonKey(name: 'is_mine')  bool isMine, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'message_type')  ChatMessageType messageType,  Map<String, dynamic>? metadata, @JsonKey(name: 'sender')  SnAccount? senderAccount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.sender,_that.senderIdentity,_that.message,_that.isMine,_that.createdAt,_that.messageType,_that.metadata,_that.senderAccount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'sender_name')  String sender, @JsonKey(name: 'sender_identity')  String? senderIdentity, @JsonKey(name: 'content')  String message, @JsonKey(name: 'is_mine')  bool isMine, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'message_type')  ChatMessageType messageType,  Map<String, dynamic>? metadata, @JsonKey(name: 'sender')  SnAccount? senderAccount)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.senderId,_that.sender,_that.senderIdentity,_that.message,_that.isMine,_that.createdAt,_that.messageType,_that.metadata,_that.senderAccount);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'sender_id')  String senderId, @JsonKey(name: 'sender_name')  String sender, @JsonKey(name: 'sender_identity')  String? senderIdentity, @JsonKey(name: 'content')  String message, @JsonKey(name: 'is_mine')  bool isMine, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'message_type')  ChatMessageType messageType,  Map<String, dynamic>? metadata, @JsonKey(name: 'sender')  SnAccount? senderAccount)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.sender,_that.senderIdentity,_that.message,_that.isMine,_that.createdAt,_that.messageType,_that.metadata,_that.senderAccount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage extends ChatMessage {
  const _ChatMessage({this.id = '', @JsonKey(name: 'sender_id') this.senderId = '', @JsonKey(name: 'sender_name') this.sender = 'Unknown', @JsonKey(name: 'sender_identity') this.senderIdentity, @JsonKey(name: 'content') this.message = '', @JsonKey(name: 'is_mine') this.isMine = false, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'message_type') this.messageType = ChatMessageType.chat, final  Map<String, dynamic>? metadata, @JsonKey(name: 'sender') this.senderAccount}): _metadata = metadata,super._();
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'sender_id') final  String senderId;
@override@JsonKey(name: 'sender_name') final  String sender;
@override@JsonKey(name: 'sender_identity') final  String? senderIdentity;
@override@JsonKey(name: 'content') final  String message;
@override@JsonKey(name: 'is_mine') final  bool isMine;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'message_type') final  ChatMessageType messageType;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'sender') final  SnAccount? senderAccount;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.senderIdentity, senderIdentity) || other.senderIdentity == senderIdentity)&&(identical(other.message, message) || other.message == message)&&(identical(other.isMine, isMine) || other.isMine == isMine)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.senderAccount, senderAccount) || other.senderAccount == senderAccount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,sender,senderIdentity,message,isMine,createdAt,messageType,const DeepCollectionEquality().hash(_metadata),senderAccount);

@override
String toString() {
  return 'ChatMessage(id: $id, senderId: $senderId, sender: $sender, senderIdentity: $senderIdentity, message: $message, isMine: $isMine, createdAt: $createdAt, messageType: $messageType, metadata: $metadata, senderAccount: $senderAccount)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'sender_id') String senderId,@JsonKey(name: 'sender_name') String sender,@JsonKey(name: 'sender_identity') String? senderIdentity,@JsonKey(name: 'content') String message,@JsonKey(name: 'is_mine') bool isMine,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'message_type') ChatMessageType messageType, Map<String, dynamic>? metadata,@JsonKey(name: 'sender') SnAccount? senderAccount
});


@override $SnAccountCopyWith<$Res>? get senderAccount;

}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? sender = null,Object? senderIdentity = freezed,Object? message = null,Object? isMine = null,Object? createdAt = freezed,Object? messageType = null,Object? metadata = freezed,Object? senderAccount = freezed,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,senderIdentity: freezed == senderIdentity ? _self.senderIdentity : senderIdentity // ignore: cast_nullable_to_non_nullable
as String?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isMine: null == isMine ? _self.isMine : isMine // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as ChatMessageType,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,senderAccount: freezed == senderAccount ? _self.senderAccount : senderAccount // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get senderAccount {
    if (_self.senderAccount == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.senderAccount!, (value) {
    return _then(_self.copyWith(senderAccount: value));
  });
}
}

// dart format on
