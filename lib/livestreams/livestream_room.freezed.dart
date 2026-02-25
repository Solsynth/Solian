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
mixin _$LivestreamEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestreamEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LivestreamEvent()';
}


}

/// @nodoc
class $LivestreamEventCopyWith<$Res>  {
$LivestreamEventCopyWith(LivestreamEvent _, $Res Function(LivestreamEvent) __);
}


/// Adds pattern-matching-related methods to [LivestreamEvent].
extension LivestreamEventPatterns on LivestreamEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LivestreamEventChatMessage value)?  chatMessage,TResult Function( LivestreamTimeout value)?  timeout,TResult Function( LivestreamStreamAwarded value)?  streamAwarded,TResult Function( LivestreamUnknown value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LivestreamEventChatMessage() when chatMessage != null:
return chatMessage(_that);case LivestreamTimeout() when timeout != null:
return timeout(_that);case LivestreamStreamAwarded() when streamAwarded != null:
return streamAwarded(_that);case LivestreamUnknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LivestreamEventChatMessage value)  chatMessage,required TResult Function( LivestreamTimeout value)  timeout,required TResult Function( LivestreamStreamAwarded value)  streamAwarded,required TResult Function( LivestreamUnknown value)  unknown,}){
final _that = this;
switch (_that) {
case LivestreamEventChatMessage():
return chatMessage(_that);case LivestreamTimeout():
return timeout(_that);case LivestreamStreamAwarded():
return streamAwarded(_that);case LivestreamUnknown():
return unknown(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LivestreamEventChatMessage value)?  chatMessage,TResult? Function( LivestreamTimeout value)?  timeout,TResult? Function( LivestreamStreamAwarded value)?  streamAwarded,TResult? Function( LivestreamUnknown value)?  unknown,}){
final _that = this;
switch (_that) {
case LivestreamEventChatMessage() when chatMessage != null:
return chatMessage(_that);case LivestreamTimeout() when timeout != null:
return timeout(_that);case LivestreamStreamAwarded() when streamAwarded != null:
return streamAwarded(_that);case LivestreamUnknown() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id, @JsonKey(name: 'live_stream_id')  String livestreamId, @JsonKey(name: 'sender_id')  String senderId,  String senderName,  String content,  DateTime? createdAt,  SnAccount? sender)?  chatMessage,TResult Function( int durationMinutes)?  timeout,TResult Function(@JsonKey(name: 'sender_id')  String senderId,  String senderName,  double amount,  String? message, @JsonKey(name: 'highlight_seconds')  int? highlightSeconds)?  streamAwarded,TResult Function( Map<String, dynamic> raw)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LivestreamEventChatMessage() when chatMessage != null:
return chatMessage(_that.id,_that.livestreamId,_that.senderId,_that.senderName,_that.content,_that.createdAt,_that.sender);case LivestreamTimeout() when timeout != null:
return timeout(_that.durationMinutes);case LivestreamStreamAwarded() when streamAwarded != null:
return streamAwarded(_that.senderId,_that.senderName,_that.amount,_that.message,_that.highlightSeconds);case LivestreamUnknown() when unknown != null:
return unknown(_that.raw);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id, @JsonKey(name: 'live_stream_id')  String livestreamId, @JsonKey(name: 'sender_id')  String senderId,  String senderName,  String content,  DateTime? createdAt,  SnAccount? sender)  chatMessage,required TResult Function( int durationMinutes)  timeout,required TResult Function(@JsonKey(name: 'sender_id')  String senderId,  String senderName,  double amount,  String? message, @JsonKey(name: 'highlight_seconds')  int? highlightSeconds)  streamAwarded,required TResult Function( Map<String, dynamic> raw)  unknown,}) {final _that = this;
switch (_that) {
case LivestreamEventChatMessage():
return chatMessage(_that.id,_that.livestreamId,_that.senderId,_that.senderName,_that.content,_that.createdAt,_that.sender);case LivestreamTimeout():
return timeout(_that.durationMinutes);case LivestreamStreamAwarded():
return streamAwarded(_that.senderId,_that.senderName,_that.amount,_that.message,_that.highlightSeconds);case LivestreamUnknown():
return unknown(_that.raw);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id, @JsonKey(name: 'live_stream_id')  String livestreamId, @JsonKey(name: 'sender_id')  String senderId,  String senderName,  String content,  DateTime? createdAt,  SnAccount? sender)?  chatMessage,TResult? Function( int durationMinutes)?  timeout,TResult? Function(@JsonKey(name: 'sender_id')  String senderId,  String senderName,  double amount,  String? message, @JsonKey(name: 'highlight_seconds')  int? highlightSeconds)?  streamAwarded,TResult? Function( Map<String, dynamic> raw)?  unknown,}) {final _that = this;
switch (_that) {
case LivestreamEventChatMessage() when chatMessage != null:
return chatMessage(_that.id,_that.livestreamId,_that.senderId,_that.senderName,_that.content,_that.createdAt,_that.sender);case LivestreamTimeout() when timeout != null:
return timeout(_that.durationMinutes);case LivestreamStreamAwarded() when streamAwarded != null:
return streamAwarded(_that.senderId,_that.senderName,_that.amount,_that.message,_that.highlightSeconds);case LivestreamUnknown() when unknown != null:
return unknown(_that.raw);case _:
  return null;

}
}

}

/// @nodoc


class LivestreamEventChatMessage implements LivestreamEvent {
  const LivestreamEventChatMessage({required this.id, @JsonKey(name: 'live_stream_id') required this.livestreamId, @JsonKey(name: 'sender_id') required this.senderId, required this.senderName, required this.content, this.createdAt, this.sender});
  

 final  String id;
@JsonKey(name: 'live_stream_id') final  String livestreamId;
@JsonKey(name: 'sender_id') final  String senderId;
 final  String senderName;
 final  String content;
 final  DateTime? createdAt;
 final  SnAccount? sender;

/// Create a copy of LivestreamEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestreamEventChatMessageCopyWith<LivestreamEventChatMessage> get copyWith => _$LivestreamEventChatMessageCopyWithImpl<LivestreamEventChatMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestreamEventChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.livestreamId, livestreamId) || other.livestreamId == livestreamId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sender, sender) || other.sender == sender));
}


@override
int get hashCode => Object.hash(runtimeType,id,livestreamId,senderId,senderName,content,createdAt,sender);

@override
String toString() {
  return 'LivestreamEvent.chatMessage(id: $id, livestreamId: $livestreamId, senderId: $senderId, senderName: $senderName, content: $content, createdAt: $createdAt, sender: $sender)';
}


}

/// @nodoc
abstract mixin class $LivestreamEventChatMessageCopyWith<$Res> implements $LivestreamEventCopyWith<$Res> {
  factory $LivestreamEventChatMessageCopyWith(LivestreamEventChatMessage value, $Res Function(LivestreamEventChatMessage) _then) = _$LivestreamEventChatMessageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'live_stream_id') String livestreamId,@JsonKey(name: 'sender_id') String senderId, String senderName, String content, DateTime? createdAt, SnAccount? sender
});


$SnAccountCopyWith<$Res>? get sender;

}
/// @nodoc
class _$LivestreamEventChatMessageCopyWithImpl<$Res>
    implements $LivestreamEventChatMessageCopyWith<$Res> {
  _$LivestreamEventChatMessageCopyWithImpl(this._self, this._then);

  final LivestreamEventChatMessage _self;
  final $Res Function(LivestreamEventChatMessage) _then;

/// Create a copy of LivestreamEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? livestreamId = null,Object? senderId = null,Object? senderName = null,Object? content = null,Object? createdAt = freezed,Object? sender = freezed,}) {
  return _then(LivestreamEventChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,livestreamId: null == livestreamId ? _self.livestreamId : livestreamId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}

/// Create a copy of LivestreamEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}

/// @nodoc


class LivestreamTimeout implements LivestreamEvent {
  const LivestreamTimeout({required this.durationMinutes});
  

 final  int durationMinutes;

/// Create a copy of LivestreamEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestreamTimeoutCopyWith<LivestreamTimeout> get copyWith => _$LivestreamTimeoutCopyWithImpl<LivestreamTimeout>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestreamTimeout&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,durationMinutes);

@override
String toString() {
  return 'LivestreamEvent.timeout(durationMinutes: $durationMinutes)';
}


}

/// @nodoc
abstract mixin class $LivestreamTimeoutCopyWith<$Res> implements $LivestreamEventCopyWith<$Res> {
  factory $LivestreamTimeoutCopyWith(LivestreamTimeout value, $Res Function(LivestreamTimeout) _then) = _$LivestreamTimeoutCopyWithImpl;
@useResult
$Res call({
 int durationMinutes
});




}
/// @nodoc
class _$LivestreamTimeoutCopyWithImpl<$Res>
    implements $LivestreamTimeoutCopyWith<$Res> {
  _$LivestreamTimeoutCopyWithImpl(this._self, this._then);

  final LivestreamTimeout _self;
  final $Res Function(LivestreamTimeout) _then;

/// Create a copy of LivestreamEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? durationMinutes = null,}) {
  return _then(LivestreamTimeout(
durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class LivestreamStreamAwarded implements LivestreamEvent {
  const LivestreamStreamAwarded({@JsonKey(name: 'sender_id') required this.senderId, required this.senderName, required this.amount, this.message, @JsonKey(name: 'highlight_seconds') this.highlightSeconds});
  

@JsonKey(name: 'sender_id') final  String senderId;
 final  String senderName;
 final  double amount;
 final  String? message;
@JsonKey(name: 'highlight_seconds') final  int? highlightSeconds;

/// Create a copy of LivestreamEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestreamStreamAwardedCopyWith<LivestreamStreamAwarded> get copyWith => _$LivestreamStreamAwardedCopyWithImpl<LivestreamStreamAwarded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestreamStreamAwarded&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.message, message) || other.message == message)&&(identical(other.highlightSeconds, highlightSeconds) || other.highlightSeconds == highlightSeconds));
}


@override
int get hashCode => Object.hash(runtimeType,senderId,senderName,amount,message,highlightSeconds);

@override
String toString() {
  return 'LivestreamEvent.streamAwarded(senderId: $senderId, senderName: $senderName, amount: $amount, message: $message, highlightSeconds: $highlightSeconds)';
}


}

/// @nodoc
abstract mixin class $LivestreamStreamAwardedCopyWith<$Res> implements $LivestreamEventCopyWith<$Res> {
  factory $LivestreamStreamAwardedCopyWith(LivestreamStreamAwarded value, $Res Function(LivestreamStreamAwarded) _then) = _$LivestreamStreamAwardedCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'sender_id') String senderId, String senderName, double amount, String? message,@JsonKey(name: 'highlight_seconds') int? highlightSeconds
});




}
/// @nodoc
class _$LivestreamStreamAwardedCopyWithImpl<$Res>
    implements $LivestreamStreamAwardedCopyWith<$Res> {
  _$LivestreamStreamAwardedCopyWithImpl(this._self, this._then);

  final LivestreamStreamAwarded _self;
  final $Res Function(LivestreamStreamAwarded) _then;

/// Create a copy of LivestreamEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? senderId = null,Object? senderName = null,Object? amount = null,Object? message = freezed,Object? highlightSeconds = freezed,}) {
  return _then(LivestreamStreamAwarded(
senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,highlightSeconds: freezed == highlightSeconds ? _self.highlightSeconds : highlightSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class LivestreamUnknown implements LivestreamEvent {
  const LivestreamUnknown(final  Map<String, dynamic> raw): _raw = raw;
  

 final  Map<String, dynamic> _raw;
 Map<String, dynamic> get raw {
  if (_raw is EqualUnmodifiableMapView) return _raw;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_raw);
}


/// Create a copy of LivestreamEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LivestreamUnknownCopyWith<LivestreamUnknown> get copyWith => _$LivestreamUnknownCopyWithImpl<LivestreamUnknown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LivestreamUnknown&&const DeepCollectionEquality().equals(other._raw, _raw));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_raw));

@override
String toString() {
  return 'LivestreamEvent.unknown(raw: $raw)';
}


}

/// @nodoc
abstract mixin class $LivestreamUnknownCopyWith<$Res> implements $LivestreamEventCopyWith<$Res> {
  factory $LivestreamUnknownCopyWith(LivestreamUnknown value, $Res Function(LivestreamUnknown) _then) = _$LivestreamUnknownCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> raw
});




}
/// @nodoc
class _$LivestreamUnknownCopyWithImpl<$Res>
    implements $LivestreamUnknownCopyWith<$Res> {
  _$LivestreamUnknownCopyWithImpl(this._self, this._then);

  final LivestreamUnknown _self;
  final $Res Function(LivestreamUnknown) _then;

/// Create a copy of LivestreamEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? raw = null,}) {
  return _then(LivestreamUnknown(
null == raw ? _self._raw : raw // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


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
