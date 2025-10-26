// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thought.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreamThinkingRequest {

 String get userMessage; String? get sequenceId;
/// Create a copy of StreamThinkingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamThinkingRequestCopyWith<StreamThinkingRequest> get copyWith => _$StreamThinkingRequestCopyWithImpl<StreamThinkingRequest>(this as StreamThinkingRequest, _$identity);

  /// Serializes this StreamThinkingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamThinkingRequest&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.sequenceId, sequenceId) || other.sequenceId == sequenceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userMessage,sequenceId);

@override
String toString() {
  return 'StreamThinkingRequest(userMessage: $userMessage, sequenceId: $sequenceId)';
}


}

/// @nodoc
abstract mixin class $StreamThinkingRequestCopyWith<$Res>  {
  factory $StreamThinkingRequestCopyWith(StreamThinkingRequest value, $Res Function(StreamThinkingRequest) _then) = _$StreamThinkingRequestCopyWithImpl;
@useResult
$Res call({
 String userMessage, String? sequenceId
});




}
/// @nodoc
class _$StreamThinkingRequestCopyWithImpl<$Res>
    implements $StreamThinkingRequestCopyWith<$Res> {
  _$StreamThinkingRequestCopyWithImpl(this._self, this._then);

  final StreamThinkingRequest _self;
  final $Res Function(StreamThinkingRequest) _then;

/// Create a copy of StreamThinkingRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userMessage = null,Object? sequenceId = freezed,}) {
  return _then(_self.copyWith(
userMessage: null == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as String,sequenceId: freezed == sequenceId ? _self.sequenceId : sequenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreamThinkingRequest].
extension StreamThinkingRequestPatterns on StreamThinkingRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreamThinkingRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreamThinkingRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreamThinkingRequest value)  $default,){
final _that = this;
switch (_that) {
case _StreamThinkingRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreamThinkingRequest value)?  $default,){
final _that = this;
switch (_that) {
case _StreamThinkingRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userMessage,  String? sequenceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamThinkingRequest() when $default != null:
return $default(_that.userMessage,_that.sequenceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userMessage,  String? sequenceId)  $default,) {final _that = this;
switch (_that) {
case _StreamThinkingRequest():
return $default(_that.userMessage,_that.sequenceId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userMessage,  String? sequenceId)?  $default,) {final _that = this;
switch (_that) {
case _StreamThinkingRequest() when $default != null:
return $default(_that.userMessage,_that.sequenceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamThinkingRequest implements StreamThinkingRequest {
  const _StreamThinkingRequest({required this.userMessage, this.sequenceId});
  factory _StreamThinkingRequest.fromJson(Map<String, dynamic> json) => _$StreamThinkingRequestFromJson(json);

@override final  String userMessage;
@override final  String? sequenceId;

/// Create a copy of StreamThinkingRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreamThinkingRequestCopyWith<_StreamThinkingRequest> get copyWith => __$StreamThinkingRequestCopyWithImpl<_StreamThinkingRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreamThinkingRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamThinkingRequest&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.sequenceId, sequenceId) || other.sequenceId == sequenceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userMessage,sequenceId);

@override
String toString() {
  return 'StreamThinkingRequest(userMessage: $userMessage, sequenceId: $sequenceId)';
}


}

/// @nodoc
abstract mixin class _$StreamThinkingRequestCopyWith<$Res> implements $StreamThinkingRequestCopyWith<$Res> {
  factory _$StreamThinkingRequestCopyWith(_StreamThinkingRequest value, $Res Function(_StreamThinkingRequest) _then) = __$StreamThinkingRequestCopyWithImpl;
@override @useResult
$Res call({
 String userMessage, String? sequenceId
});




}
/// @nodoc
class __$StreamThinkingRequestCopyWithImpl<$Res>
    implements _$StreamThinkingRequestCopyWith<$Res> {
  __$StreamThinkingRequestCopyWithImpl(this._self, this._then);

  final _StreamThinkingRequest _self;
  final $Res Function(_StreamThinkingRequest) _then;

/// Create a copy of StreamThinkingRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userMessage = null,Object? sequenceId = freezed,}) {
  return _then(_StreamThinkingRequest(
userMessage: null == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as String,sequenceId: freezed == sequenceId ? _self.sequenceId : sequenceId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnThinkingChunk {

@ThinkingChunkTypeConverter() ThinkingChunkType get type; Map<String, dynamic>? get data;
/// Create a copy of SnThinkingChunk
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnThinkingChunkCopyWith<SnThinkingChunk> get copyWith => _$SnThinkingChunkCopyWithImpl<SnThinkingChunk>(this as SnThinkingChunk, _$identity);

  /// Serializes this SnThinkingChunk to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnThinkingChunk&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'SnThinkingChunk(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class $SnThinkingChunkCopyWith<$Res>  {
  factory $SnThinkingChunkCopyWith(SnThinkingChunk value, $Res Function(SnThinkingChunk) _then) = _$SnThinkingChunkCopyWithImpl;
@useResult
$Res call({
@ThinkingChunkTypeConverter() ThinkingChunkType type, Map<String, dynamic>? data
});




}
/// @nodoc
class _$SnThinkingChunkCopyWithImpl<$Res>
    implements $SnThinkingChunkCopyWith<$Res> {
  _$SnThinkingChunkCopyWithImpl(this._self, this._then);

  final SnThinkingChunk _self;
  final $Res Function(SnThinkingChunk) _then;

/// Create a copy of SnThinkingChunk
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ThinkingChunkType,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnThinkingChunk].
extension SnThinkingChunkPatterns on SnThinkingChunk {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnThinkingChunk value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnThinkingChunk() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnThinkingChunk value)  $default,){
final _that = this;
switch (_that) {
case _SnThinkingChunk():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnThinkingChunk value)?  $default,){
final _that = this;
switch (_that) {
case _SnThinkingChunk() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@ThinkingChunkTypeConverter()  ThinkingChunkType type,  Map<String, dynamic>? data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnThinkingChunk() when $default != null:
return $default(_that.type,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@ThinkingChunkTypeConverter()  ThinkingChunkType type,  Map<String, dynamic>? data)  $default,) {final _that = this;
switch (_that) {
case _SnThinkingChunk():
return $default(_that.type,_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@ThinkingChunkTypeConverter()  ThinkingChunkType type,  Map<String, dynamic>? data)?  $default,) {final _that = this;
switch (_that) {
case _SnThinkingChunk() when $default != null:
return $default(_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnThinkingChunk implements SnThinkingChunk {
  const _SnThinkingChunk({@ThinkingChunkTypeConverter() required this.type, final  Map<String, dynamic>? data}): _data = data;
  factory _SnThinkingChunk.fromJson(Map<String, dynamic> json) => _$SnThinkingChunkFromJson(json);

@override@ThinkingChunkTypeConverter() final  ThinkingChunkType type;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of SnThinkingChunk
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnThinkingChunkCopyWith<_SnThinkingChunk> get copyWith => __$SnThinkingChunkCopyWithImpl<_SnThinkingChunk>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnThinkingChunkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnThinkingChunk&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._data, _data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'SnThinkingChunk(type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$SnThinkingChunkCopyWith<$Res> implements $SnThinkingChunkCopyWith<$Res> {
  factory _$SnThinkingChunkCopyWith(_SnThinkingChunk value, $Res Function(_SnThinkingChunk) _then) = __$SnThinkingChunkCopyWithImpl;
@override @useResult
$Res call({
@ThinkingChunkTypeConverter() ThinkingChunkType type, Map<String, dynamic>? data
});




}
/// @nodoc
class __$SnThinkingChunkCopyWithImpl<$Res>
    implements _$SnThinkingChunkCopyWith<$Res> {
  __$SnThinkingChunkCopyWithImpl(this._self, this._then);

  final _SnThinkingChunk _self;
  final $Res Function(_SnThinkingChunk) _then;

/// Create a copy of SnThinkingChunk
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = freezed,}) {
  return _then(_SnThinkingChunk(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ThinkingChunkType,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$SnThinkingSequence {

 String get id; String? get topic; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnThinkingSequence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnThinkingSequenceCopyWith<SnThinkingSequence> get copyWith => _$SnThinkingSequenceCopyWithImpl<SnThinkingSequence>(this as SnThinkingSequence, _$identity);

  /// Serializes this SnThinkingSequence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnThinkingSequence&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,topic,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnThinkingSequence(id: $id, topic: $topic, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnThinkingSequenceCopyWith<$Res>  {
  factory $SnThinkingSequenceCopyWith(SnThinkingSequence value, $Res Function(SnThinkingSequence) _then) = _$SnThinkingSequenceCopyWithImpl;
@useResult
$Res call({
 String id, String? topic, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnThinkingSequenceCopyWithImpl<$Res>
    implements $SnThinkingSequenceCopyWith<$Res> {
  _$SnThinkingSequenceCopyWithImpl(this._self, this._then);

  final SnThinkingSequence _self;
  final $Res Function(SnThinkingSequence) _then;

/// Create a copy of SnThinkingSequence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? topic = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnThinkingSequence].
extension SnThinkingSequencePatterns on SnThinkingSequence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnThinkingSequence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnThinkingSequence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnThinkingSequence value)  $default,){
final _that = this;
switch (_that) {
case _SnThinkingSequence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnThinkingSequence value)?  $default,){
final _that = this;
switch (_that) {
case _SnThinkingSequence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? topic,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnThinkingSequence() when $default != null:
return $default(_that.id,_that.topic,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? topic,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnThinkingSequence():
return $default(_that.id,_that.topic,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? topic,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnThinkingSequence() when $default != null:
return $default(_that.id,_that.topic,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnThinkingSequence implements SnThinkingSequence {
  const _SnThinkingSequence({required this.id, this.topic, required this.accountId, required this.createdAt, required this.updatedAt, this.deletedAt});
  factory _SnThinkingSequence.fromJson(Map<String, dynamic> json) => _$SnThinkingSequenceFromJson(json);

@override final  String id;
@override final  String? topic;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnThinkingSequence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnThinkingSequenceCopyWith<_SnThinkingSequence> get copyWith => __$SnThinkingSequenceCopyWithImpl<_SnThinkingSequence>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnThinkingSequenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnThinkingSequence&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,topic,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnThinkingSequence(id: $id, topic: $topic, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnThinkingSequenceCopyWith<$Res> implements $SnThinkingSequenceCopyWith<$Res> {
  factory _$SnThinkingSequenceCopyWith(_SnThinkingSequence value, $Res Function(_SnThinkingSequence) _then) = __$SnThinkingSequenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String? topic, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnThinkingSequenceCopyWithImpl<$Res>
    implements _$SnThinkingSequenceCopyWith<$Res> {
  __$SnThinkingSequenceCopyWithImpl(this._self, this._then);

  final _SnThinkingSequence _self;
  final $Res Function(_SnThinkingSequence) _then;

/// Create a copy of SnThinkingSequence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? topic = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnThinkingSequence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnThinkingThought {

 String get id; String? get content; List<SnCloudFile> get files; List<SnThinkingChunk> get chunks;@ThinkingThoughtRoleConverter() ThinkingThoughtRole get role; String get sequenceId; SnThinkingSequence? get sequence; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnThinkingThought
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnThinkingThoughtCopyWith<SnThinkingThought> get copyWith => _$SnThinkingThoughtCopyWithImpl<SnThinkingThought>(this as SnThinkingThought, _$identity);

  /// Serializes this SnThinkingThought to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnThinkingThought&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.files, files)&&const DeepCollectionEquality().equals(other.chunks, chunks)&&(identical(other.role, role) || other.role == role)&&(identical(other.sequenceId, sequenceId) || other.sequenceId == sequenceId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,const DeepCollectionEquality().hash(files),const DeepCollectionEquality().hash(chunks),role,sequenceId,sequence,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnThinkingThought(id: $id, content: $content, files: $files, chunks: $chunks, role: $role, sequenceId: $sequenceId, sequence: $sequence, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnThinkingThoughtCopyWith<$Res>  {
  factory $SnThinkingThoughtCopyWith(SnThinkingThought value, $Res Function(SnThinkingThought) _then) = _$SnThinkingThoughtCopyWithImpl;
@useResult
$Res call({
 String id, String? content, List<SnCloudFile> files, List<SnThinkingChunk> chunks,@ThinkingThoughtRoleConverter() ThinkingThoughtRole role, String sequenceId, SnThinkingSequence? sequence, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnThinkingSequenceCopyWith<$Res>? get sequence;

}
/// @nodoc
class _$SnThinkingThoughtCopyWithImpl<$Res>
    implements $SnThinkingThoughtCopyWith<$Res> {
  _$SnThinkingThoughtCopyWithImpl(this._self, this._then);

  final SnThinkingThought _self;
  final $Res Function(SnThinkingThought) _then;

/// Create a copy of SnThinkingThought
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = freezed,Object? files = null,Object? chunks = null,Object? role = null,Object? sequenceId = null,Object? sequence = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,chunks: null == chunks ? _self.chunks : chunks // ignore: cast_nullable_to_non_nullable
as List<SnThinkingChunk>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ThinkingThoughtRole,sequenceId: null == sequenceId ? _self.sequenceId : sequenceId // ignore: cast_nullable_to_non_nullable
as String,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as SnThinkingSequence?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnThinkingThought
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnThinkingSequenceCopyWith<$Res>? get sequence {
    if (_self.sequence == null) {
    return null;
  }

  return $SnThinkingSequenceCopyWith<$Res>(_self.sequence!, (value) {
    return _then(_self.copyWith(sequence: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnThinkingThought].
extension SnThinkingThoughtPatterns on SnThinkingThought {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnThinkingThought value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnThinkingThought() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnThinkingThought value)  $default,){
final _that = this;
switch (_that) {
case _SnThinkingThought():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnThinkingThought value)?  $default,){
final _that = this;
switch (_that) {
case _SnThinkingThought() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? content,  List<SnCloudFile> files,  List<SnThinkingChunk> chunks, @ThinkingThoughtRoleConverter()  ThinkingThoughtRole role,  String sequenceId,  SnThinkingSequence? sequence,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnThinkingThought() when $default != null:
return $default(_that.id,_that.content,_that.files,_that.chunks,_that.role,_that.sequenceId,_that.sequence,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? content,  List<SnCloudFile> files,  List<SnThinkingChunk> chunks, @ThinkingThoughtRoleConverter()  ThinkingThoughtRole role,  String sequenceId,  SnThinkingSequence? sequence,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnThinkingThought():
return $default(_that.id,_that.content,_that.files,_that.chunks,_that.role,_that.sequenceId,_that.sequence,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? content,  List<SnCloudFile> files,  List<SnThinkingChunk> chunks, @ThinkingThoughtRoleConverter()  ThinkingThoughtRole role,  String sequenceId,  SnThinkingSequence? sequence,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnThinkingThought() when $default != null:
return $default(_that.id,_that.content,_that.files,_that.chunks,_that.role,_that.sequenceId,_that.sequence,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnThinkingThought implements SnThinkingThought {
  const _SnThinkingThought({required this.id, this.content, final  List<SnCloudFile> files = const [], final  List<SnThinkingChunk> chunks = const [], @ThinkingThoughtRoleConverter() required this.role, required this.sequenceId, this.sequence, required this.createdAt, required this.updatedAt, this.deletedAt}): _files = files,_chunks = chunks;
  factory _SnThinkingThought.fromJson(Map<String, dynamic> json) => _$SnThinkingThoughtFromJson(json);

@override final  String id;
@override final  String? content;
 final  List<SnCloudFile> _files;
@override@JsonKey() List<SnCloudFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

 final  List<SnThinkingChunk> _chunks;
@override@JsonKey() List<SnThinkingChunk> get chunks {
  if (_chunks is EqualUnmodifiableListView) return _chunks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chunks);
}

@override@ThinkingThoughtRoleConverter() final  ThinkingThoughtRole role;
@override final  String sequenceId;
@override final  SnThinkingSequence? sequence;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnThinkingThought
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnThinkingThoughtCopyWith<_SnThinkingThought> get copyWith => __$SnThinkingThoughtCopyWithImpl<_SnThinkingThought>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnThinkingThoughtToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnThinkingThought&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._files, _files)&&const DeepCollectionEquality().equals(other._chunks, _chunks)&&(identical(other.role, role) || other.role == role)&&(identical(other.sequenceId, sequenceId) || other.sequenceId == sequenceId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,const DeepCollectionEquality().hash(_files),const DeepCollectionEquality().hash(_chunks),role,sequenceId,sequence,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnThinkingThought(id: $id, content: $content, files: $files, chunks: $chunks, role: $role, sequenceId: $sequenceId, sequence: $sequence, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnThinkingThoughtCopyWith<$Res> implements $SnThinkingThoughtCopyWith<$Res> {
  factory _$SnThinkingThoughtCopyWith(_SnThinkingThought value, $Res Function(_SnThinkingThought) _then) = __$SnThinkingThoughtCopyWithImpl;
@override @useResult
$Res call({
 String id, String? content, List<SnCloudFile> files, List<SnThinkingChunk> chunks,@ThinkingThoughtRoleConverter() ThinkingThoughtRole role, String sequenceId, SnThinkingSequence? sequence, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnThinkingSequenceCopyWith<$Res>? get sequence;

}
/// @nodoc
class __$SnThinkingThoughtCopyWithImpl<$Res>
    implements _$SnThinkingThoughtCopyWith<$Res> {
  __$SnThinkingThoughtCopyWithImpl(this._self, this._then);

  final _SnThinkingThought _self;
  final $Res Function(_SnThinkingThought) _then;

/// Create a copy of SnThinkingThought
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = freezed,Object? files = null,Object? chunks = null,Object? role = null,Object? sequenceId = null,Object? sequence = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnThinkingThought(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,chunks: null == chunks ? _self._chunks : chunks // ignore: cast_nullable_to_non_nullable
as List<SnThinkingChunk>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ThinkingThoughtRole,sequenceId: null == sequenceId ? _self.sequenceId : sequenceId // ignore: cast_nullable_to_non_nullable
as String,sequence: freezed == sequence ? _self.sequence : sequence // ignore: cast_nullable_to_non_nullable
as SnThinkingSequence?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnThinkingThought
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnThinkingSequenceCopyWith<$Res>? get sequence {
    if (_self.sequence == null) {
    return null;
  }

  return $SnThinkingSequenceCopyWith<$Res>(_self.sequence!, (value) {
    return _then(_self.copyWith(sequence: value));
  });
}
}

// dart format on
