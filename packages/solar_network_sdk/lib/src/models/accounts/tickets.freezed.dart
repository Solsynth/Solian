// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tickets.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnTicket {

 String get id; String get title; String? get content; int get type; int get status; int get priority; String get creatorId; SnAccount get creator; String? get assigneeId; SnAccount? get assignee; DateTime? get resolvedAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; List<SnTicketMessage> get messages; List<String> get fileIds;
/// Create a copy of SnTicket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnTicketCopyWith<SnTicket> get copyWith => _$SnTicketCopyWithImpl<SnTicket>(this as SnTicket, _$identity);

  /// Serializes this SnTicket to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.assigneeId, assigneeId) || other.assigneeId == assigneeId)&&(identical(other.assignee, assignee) || other.assignee == assignee)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other.messages, messages)&&const DeepCollectionEquality().equals(other.fileIds, fileIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,type,status,priority,creatorId,creator,assigneeId,assignee,resolvedAt,createdAt,updatedAt,deletedAt,const DeepCollectionEquality().hash(messages),const DeepCollectionEquality().hash(fileIds));

@override
String toString() {
  return 'SnTicket(id: $id, title: $title, content: $content, type: $type, status: $status, priority: $priority, creatorId: $creatorId, creator: $creator, assigneeId: $assigneeId, assignee: $assignee, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, messages: $messages, fileIds: $fileIds)';
}


}

/// @nodoc
abstract mixin class $SnTicketCopyWith<$Res>  {
  factory $SnTicketCopyWith(SnTicket value, $Res Function(SnTicket) _then) = _$SnTicketCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? content, int type, int status, int priority, String creatorId, SnAccount creator, String? assigneeId, SnAccount? assignee, DateTime? resolvedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnTicketMessage> messages, List<String> fileIds
});


$SnAccountCopyWith<$Res> get creator;$SnAccountCopyWith<$Res>? get assignee;

}
/// @nodoc
class _$SnTicketCopyWithImpl<$Res>
    implements $SnTicketCopyWith<$Res> {
  _$SnTicketCopyWithImpl(this._self, this._then);

  final SnTicket _self;
  final $Res Function(SnTicket) _then;

/// Create a copy of SnTicket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? content = freezed,Object? type = null,Object? status = null,Object? priority = null,Object? creatorId = null,Object? creator = null,Object? assigneeId = freezed,Object? assignee = freezed,Object? resolvedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? messages = null,Object? fileIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as SnAccount,assigneeId: freezed == assigneeId ? _self.assigneeId : assigneeId // ignore: cast_nullable_to_non_nullable
as String?,assignee: freezed == assignee ? _self.assignee : assignee // ignore: cast_nullable_to_non_nullable
as SnAccount?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<SnTicketMessage>,fileIds: null == fileIds ? _self.fileIds : fileIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of SnTicket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get creator {
  
  return $SnAccountCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of SnTicket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get assignee {
    if (_self.assignee == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.assignee!, (value) {
    return _then(_self.copyWith(assignee: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnTicket].
extension SnTicketPatterns on SnTicket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnTicket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnTicket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnTicket value)  $default,){
final _that = this;
switch (_that) {
case _SnTicket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnTicket value)?  $default,){
final _that = this;
switch (_that) {
case _SnTicket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? content,  int type,  int status,  int priority,  String creatorId,  SnAccount creator,  String? assigneeId,  SnAccount? assignee,  DateTime? resolvedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnTicketMessage> messages,  List<String> fileIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnTicket() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.type,_that.status,_that.priority,_that.creatorId,_that.creator,_that.assigneeId,_that.assignee,_that.resolvedAt,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.messages,_that.fileIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? content,  int type,  int status,  int priority,  String creatorId,  SnAccount creator,  String? assigneeId,  SnAccount? assignee,  DateTime? resolvedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnTicketMessage> messages,  List<String> fileIds)  $default,) {final _that = this;
switch (_that) {
case _SnTicket():
return $default(_that.id,_that.title,_that.content,_that.type,_that.status,_that.priority,_that.creatorId,_that.creator,_that.assigneeId,_that.assignee,_that.resolvedAt,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.messages,_that.fileIds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? content,  int type,  int status,  int priority,  String creatorId,  SnAccount creator,  String? assigneeId,  SnAccount? assignee,  DateTime? resolvedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnTicketMessage> messages,  List<String> fileIds)?  $default,) {final _that = this;
switch (_that) {
case _SnTicket() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.type,_that.status,_that.priority,_that.creatorId,_that.creator,_that.assigneeId,_that.assignee,_that.resolvedAt,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.messages,_that.fileIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnTicket implements SnTicket {
  const _SnTicket({required this.id, required this.title, this.content, required this.type, required this.status, required this.priority, required this.creatorId, required this.creator, this.assigneeId, this.assignee, this.resolvedAt, required this.createdAt, required this.updatedAt, this.deletedAt, final  List<SnTicketMessage> messages = const [], final  List<String> fileIds = const []}): _messages = messages,_fileIds = fileIds;
  factory _SnTicket.fromJson(Map<String, dynamic> json) => _$SnTicketFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? content;
@override final  int type;
@override final  int status;
@override final  int priority;
@override final  String creatorId;
@override final  SnAccount creator;
@override final  String? assigneeId;
@override final  SnAccount? assignee;
@override final  DateTime? resolvedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
 final  List<SnTicketMessage> _messages;
@override@JsonKey() List<SnTicketMessage> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  List<String> _fileIds;
@override@JsonKey() List<String> get fileIds {
  if (_fileIds is EqualUnmodifiableListView) return _fileIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fileIds);
}


/// Create a copy of SnTicket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnTicketCopyWith<_SnTicket> get copyWith => __$SnTicketCopyWithImpl<_SnTicket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnTicketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnTicket&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.assigneeId, assigneeId) || other.assigneeId == assigneeId)&&(identical(other.assignee, assignee) || other.assignee == assignee)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._fileIds, _fileIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,type,status,priority,creatorId,creator,assigneeId,assignee,resolvedAt,createdAt,updatedAt,deletedAt,const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_fileIds));

@override
String toString() {
  return 'SnTicket(id: $id, title: $title, content: $content, type: $type, status: $status, priority: $priority, creatorId: $creatorId, creator: $creator, assigneeId: $assigneeId, assignee: $assignee, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, messages: $messages, fileIds: $fileIds)';
}


}

/// @nodoc
abstract mixin class _$SnTicketCopyWith<$Res> implements $SnTicketCopyWith<$Res> {
  factory _$SnTicketCopyWith(_SnTicket value, $Res Function(_SnTicket) _then) = __$SnTicketCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? content, int type, int status, int priority, String creatorId, SnAccount creator, String? assigneeId, SnAccount? assignee, DateTime? resolvedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnTicketMessage> messages, List<String> fileIds
});


@override $SnAccountCopyWith<$Res> get creator;@override $SnAccountCopyWith<$Res>? get assignee;

}
/// @nodoc
class __$SnTicketCopyWithImpl<$Res>
    implements _$SnTicketCopyWith<$Res> {
  __$SnTicketCopyWithImpl(this._self, this._then);

  final _SnTicket _self;
  final $Res Function(_SnTicket) _then;

/// Create a copy of SnTicket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? content = freezed,Object? type = null,Object? status = null,Object? priority = null,Object? creatorId = null,Object? creator = null,Object? assigneeId = freezed,Object? assignee = freezed,Object? resolvedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? messages = null,Object? fileIds = null,}) {
  return _then(_SnTicket(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as SnAccount,assigneeId: freezed == assigneeId ? _self.assigneeId : assigneeId // ignore: cast_nullable_to_non_nullable
as String?,assignee: freezed == assignee ? _self.assignee : assignee // ignore: cast_nullable_to_non_nullable
as SnAccount?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<SnTicketMessage>,fileIds: null == fileIds ? _self._fileIds : fileIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of SnTicket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get creator {
  
  return $SnAccountCopyWith<$Res>(_self.creator, (value) {
    return _then(_self.copyWith(creator: value));
  });
}/// Create a copy of SnTicket
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get assignee {
    if (_self.assignee == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.assignee!, (value) {
    return _then(_self.copyWith(assignee: value));
  });
}
}


/// @nodoc
mixin _$SnTicketMessage {

 String get id; String get ticketId; String get senderId; SnAccount get sender; String get content; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; List<SnCloudFileReference> get files;
/// Create a copy of SnTicketMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnTicketMessageCopyWith<SnTicketMessage> get copyWith => _$SnTicketMessageCopyWithImpl<SnTicketMessage>(this as SnTicketMessage, _$identity);

  /// Serializes this SnTicketMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnTicketMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other.files, files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ticketId,senderId,sender,content,createdAt,updatedAt,deletedAt,const DeepCollectionEquality().hash(files));

@override
String toString() {
  return 'SnTicketMessage(id: $id, ticketId: $ticketId, senderId: $senderId, sender: $sender, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, files: $files)';
}


}

/// @nodoc
abstract mixin class $SnTicketMessageCopyWith<$Res>  {
  factory $SnTicketMessageCopyWith(SnTicketMessage value, $Res Function(SnTicketMessage) _then) = _$SnTicketMessageCopyWithImpl;
@useResult
$Res call({
 String id, String ticketId, String senderId, SnAccount sender, String content, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnCloudFileReference> files
});


$SnAccountCopyWith<$Res> get sender;

}
/// @nodoc
class _$SnTicketMessageCopyWithImpl<$Res>
    implements $SnTicketMessageCopyWith<$Res> {
  _$SnTicketMessageCopyWithImpl(this._self, this._then);

  final SnTicketMessage _self;
  final $Res Function(SnTicketMessage) _then;

/// Create a copy of SnTicketMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ticketId = null,Object? senderId = null,Object? sender = null,Object? content = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? files = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnAccount,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,
  ));
}
/// Create a copy of SnTicketMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get sender {
  
  return $SnAccountCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnTicketMessage].
extension SnTicketMessagePatterns on SnTicketMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnTicketMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnTicketMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnTicketMessage value)  $default,){
final _that = this;
switch (_that) {
case _SnTicketMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnTicketMessage value)?  $default,){
final _that = this;
switch (_that) {
case _SnTicketMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ticketId,  String senderId,  SnAccount sender,  String content,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnCloudFileReference> files)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnTicketMessage() when $default != null:
return $default(_that.id,_that.ticketId,_that.senderId,_that.sender,_that.content,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.files);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ticketId,  String senderId,  SnAccount sender,  String content,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnCloudFileReference> files)  $default,) {final _that = this;
switch (_that) {
case _SnTicketMessage():
return $default(_that.id,_that.ticketId,_that.senderId,_that.sender,_that.content,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.files);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ticketId,  String senderId,  SnAccount sender,  String content,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnCloudFileReference> files)?  $default,) {final _that = this;
switch (_that) {
case _SnTicketMessage() when $default != null:
return $default(_that.id,_that.ticketId,_that.senderId,_that.sender,_that.content,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.files);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnTicketMessage implements SnTicketMessage {
  const _SnTicketMessage({required this.id, required this.ticketId, required this.senderId, required this.sender, required this.content, required this.createdAt, required this.updatedAt, this.deletedAt, required final  List<SnCloudFileReference> files}): _files = files;
  factory _SnTicketMessage.fromJson(Map<String, dynamic> json) => _$SnTicketMessageFromJson(json);

@override final  String id;
@override final  String ticketId;
@override final  String senderId;
@override final  SnAccount sender;
@override final  String content;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
 final  List<SnCloudFileReference> _files;
@override List<SnCloudFileReference> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}


/// Create a copy of SnTicketMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnTicketMessageCopyWith<_SnTicketMessage> get copyWith => __$SnTicketMessageCopyWithImpl<_SnTicketMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnTicketMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnTicketMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other._files, _files));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,ticketId,senderId,sender,content,createdAt,updatedAt,deletedAt,const DeepCollectionEquality().hash(_files));

@override
String toString() {
  return 'SnTicketMessage(id: $id, ticketId: $ticketId, senderId: $senderId, sender: $sender, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, files: $files)';
}


}

/// @nodoc
abstract mixin class _$SnTicketMessageCopyWith<$Res> implements $SnTicketMessageCopyWith<$Res> {
  factory _$SnTicketMessageCopyWith(_SnTicketMessage value, $Res Function(_SnTicketMessage) _then) = __$SnTicketMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String ticketId, String senderId, SnAccount sender, String content, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnCloudFileReference> files
});


@override $SnAccountCopyWith<$Res> get sender;

}
/// @nodoc
class __$SnTicketMessageCopyWithImpl<$Res>
    implements _$SnTicketMessageCopyWith<$Res> {
  __$SnTicketMessageCopyWithImpl(this._self, this._then);

  final _SnTicketMessage _self;
  final $Res Function(_SnTicketMessage) _then;

/// Create a copy of SnTicketMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ticketId = null,Object? senderId = null,Object? sender = null,Object? content = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? files = null,}) {
  return _then(_SnTicketMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ticketId: null == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as SnAccount,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,
  ));
}

/// Create a copy of SnTicketMessage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get sender {
  
  return $SnAccountCopyWith<$Res>(_self.sender, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}

/// @nodoc
mixin _$TicketType {

 int get value; String get displayName;
/// Create a copy of TicketType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketTypeCopyWith<TicketType> get copyWith => _$TicketTypeCopyWithImpl<TicketType>(this as TicketType, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketType&&(identical(other.value, value) || other.value == value)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,value,displayName);

@override
String toString() {
  return 'TicketType(value: $value, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $TicketTypeCopyWith<$Res>  {
  factory $TicketTypeCopyWith(TicketType value, $Res Function(TicketType) _then) = _$TicketTypeCopyWithImpl;
@useResult
$Res call({
 int value, String displayName
});




}
/// @nodoc
class _$TicketTypeCopyWithImpl<$Res>
    implements $TicketTypeCopyWith<$Res> {
  _$TicketTypeCopyWithImpl(this._self, this._then);

  final TicketType _self;
  final $Res Function(TicketType) _then;

/// Create a copy of TicketType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? displayName = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketType].
extension TicketTypePatterns on TicketType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketType value)  $default,){
final _that = this;
switch (_that) {
case _TicketType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketType value)?  $default,){
final _that = this;
switch (_that) {
case _TicketType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int value,  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketType() when $default != null:
return $default(_that.value,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int value,  String displayName)  $default,) {final _that = this;
switch (_that) {
case _TicketType():
return $default(_that.value,_that.displayName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int value,  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _TicketType() when $default != null:
return $default(_that.value,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc


class _TicketType extends TicketType {
  const _TicketType(this.value, this.displayName): super._();
  

@override final  int value;
@override final  String displayName;

/// Create a copy of TicketType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketTypeCopyWith<_TicketType> get copyWith => __$TicketTypeCopyWithImpl<_TicketType>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketType&&(identical(other.value, value) || other.value == value)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,value,displayName);

@override
String toString() {
  return 'TicketType(value: $value, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$TicketTypeCopyWith<$Res> implements $TicketTypeCopyWith<$Res> {
  factory _$TicketTypeCopyWith(_TicketType value, $Res Function(_TicketType) _then) = __$TicketTypeCopyWithImpl;
@override @useResult
$Res call({
 int value, String displayName
});




}
/// @nodoc
class __$TicketTypeCopyWithImpl<$Res>
    implements _$TicketTypeCopyWith<$Res> {
  __$TicketTypeCopyWithImpl(this._self, this._then);

  final _TicketType _self;
  final $Res Function(_TicketType) _then;

/// Create a copy of TicketType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? displayName = null,}) {
  return _then(_TicketType(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TicketStatus {

 int get value; String get displayName;
/// Create a copy of TicketStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketStatusCopyWith<TicketStatus> get copyWith => _$TicketStatusCopyWithImpl<TicketStatus>(this as TicketStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketStatus&&(identical(other.value, value) || other.value == value)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,value,displayName);

@override
String toString() {
  return 'TicketStatus(value: $value, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $TicketStatusCopyWith<$Res>  {
  factory $TicketStatusCopyWith(TicketStatus value, $Res Function(TicketStatus) _then) = _$TicketStatusCopyWithImpl;
@useResult
$Res call({
 int value, String displayName
});




}
/// @nodoc
class _$TicketStatusCopyWithImpl<$Res>
    implements $TicketStatusCopyWith<$Res> {
  _$TicketStatusCopyWithImpl(this._self, this._then);

  final TicketStatus _self;
  final $Res Function(TicketStatus) _then;

/// Create a copy of TicketStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? displayName = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketStatus].
extension TicketStatusPatterns on TicketStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketStatus value)  $default,){
final _that = this;
switch (_that) {
case _TicketStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketStatus value)?  $default,){
final _that = this;
switch (_that) {
case _TicketStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int value,  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketStatus() when $default != null:
return $default(_that.value,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int value,  String displayName)  $default,) {final _that = this;
switch (_that) {
case _TicketStatus():
return $default(_that.value,_that.displayName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int value,  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _TicketStatus() when $default != null:
return $default(_that.value,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc


class _TicketStatus extends TicketStatus {
  const _TicketStatus(this.value, this.displayName): super._();
  

@override final  int value;
@override final  String displayName;

/// Create a copy of TicketStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketStatusCopyWith<_TicketStatus> get copyWith => __$TicketStatusCopyWithImpl<_TicketStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketStatus&&(identical(other.value, value) || other.value == value)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,value,displayName);

@override
String toString() {
  return 'TicketStatus(value: $value, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$TicketStatusCopyWith<$Res> implements $TicketStatusCopyWith<$Res> {
  factory _$TicketStatusCopyWith(_TicketStatus value, $Res Function(_TicketStatus) _then) = __$TicketStatusCopyWithImpl;
@override @useResult
$Res call({
 int value, String displayName
});




}
/// @nodoc
class __$TicketStatusCopyWithImpl<$Res>
    implements _$TicketStatusCopyWith<$Res> {
  __$TicketStatusCopyWithImpl(this._self, this._then);

  final _TicketStatus _self;
  final $Res Function(_TicketStatus) _then;

/// Create a copy of TicketStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? displayName = null,}) {
  return _then(_TicketStatus(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TicketPriority {

 int get value; String get displayName;
/// Create a copy of TicketPriority
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketPriorityCopyWith<TicketPriority> get copyWith => _$TicketPriorityCopyWithImpl<TicketPriority>(this as TicketPriority, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketPriority&&(identical(other.value, value) || other.value == value)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,value,displayName);

@override
String toString() {
  return 'TicketPriority(value: $value, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $TicketPriorityCopyWith<$Res>  {
  factory $TicketPriorityCopyWith(TicketPriority value, $Res Function(TicketPriority) _then) = _$TicketPriorityCopyWithImpl;
@useResult
$Res call({
 int value, String displayName
});




}
/// @nodoc
class _$TicketPriorityCopyWithImpl<$Res>
    implements $TicketPriorityCopyWith<$Res> {
  _$TicketPriorityCopyWithImpl(this._self, this._then);

  final TicketPriority _self;
  final $Res Function(TicketPriority) _then;

/// Create a copy of TicketPriority
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? displayName = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketPriority].
extension TicketPriorityPatterns on TicketPriority {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketPriority value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketPriority() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketPriority value)  $default,){
final _that = this;
switch (_that) {
case _TicketPriority():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketPriority value)?  $default,){
final _that = this;
switch (_that) {
case _TicketPriority() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int value,  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketPriority() when $default != null:
return $default(_that.value,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int value,  String displayName)  $default,) {final _that = this;
switch (_that) {
case _TicketPriority():
return $default(_that.value,_that.displayName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int value,  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _TicketPriority() when $default != null:
return $default(_that.value,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc


class _TicketPriority extends TicketPriority {
  const _TicketPriority(this.value, this.displayName): super._();
  

@override final  int value;
@override final  String displayName;

/// Create a copy of TicketPriority
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketPriorityCopyWith<_TicketPriority> get copyWith => __$TicketPriorityCopyWithImpl<_TicketPriority>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketPriority&&(identical(other.value, value) || other.value == value)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,value,displayName);

@override
String toString() {
  return 'TicketPriority(value: $value, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$TicketPriorityCopyWith<$Res> implements $TicketPriorityCopyWith<$Res> {
  factory _$TicketPriorityCopyWith(_TicketPriority value, $Res Function(_TicketPriority) _then) = __$TicketPriorityCopyWithImpl;
@override @useResult
$Res call({
 int value, String displayName
});




}
/// @nodoc
class __$TicketPriorityCopyWithImpl<$Res>
    implements _$TicketPriorityCopyWith<$Res> {
  __$TicketPriorityCopyWithImpl(this._self, this._then);

  final _TicketPriority _self;
  final $Res Function(_TicketPriority) _then;

/// Create a copy of TicketPriority
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? displayName = null,}) {
  return _then(_TicketPriority(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
