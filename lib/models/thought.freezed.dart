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

 String get userMessage; String? get sequenceId; List<String> get accpetProposals; List<String>? get attachedPosts; List<Map<String, dynamic>>? get attachedMessages;@JsonKey(name: 'service_id') String? get serviceId;
/// Create a copy of StreamThinkingRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamThinkingRequestCopyWith<StreamThinkingRequest> get copyWith => _$StreamThinkingRequestCopyWithImpl<StreamThinkingRequest>(this as StreamThinkingRequest, _$identity);

  /// Serializes this StreamThinkingRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamThinkingRequest&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.sequenceId, sequenceId) || other.sequenceId == sequenceId)&&const DeepCollectionEquality().equals(other.accpetProposals, accpetProposals)&&const DeepCollectionEquality().equals(other.attachedPosts, attachedPosts)&&const DeepCollectionEquality().equals(other.attachedMessages, attachedMessages)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userMessage,sequenceId,const DeepCollectionEquality().hash(accpetProposals),const DeepCollectionEquality().hash(attachedPosts),const DeepCollectionEquality().hash(attachedMessages),serviceId);

@override
String toString() {
  return 'StreamThinkingRequest(userMessage: $userMessage, sequenceId: $sequenceId, accpetProposals: $accpetProposals, attachedPosts: $attachedPosts, attachedMessages: $attachedMessages, serviceId: $serviceId)';
}


}

/// @nodoc
abstract mixin class $StreamThinkingRequestCopyWith<$Res>  {
  factory $StreamThinkingRequestCopyWith(StreamThinkingRequest value, $Res Function(StreamThinkingRequest) _then) = _$StreamThinkingRequestCopyWithImpl;
@useResult
$Res call({
 String userMessage, String? sequenceId, List<String> accpetProposals, List<String>? attachedPosts, List<Map<String, dynamic>>? attachedMessages,@JsonKey(name: 'service_id') String? serviceId
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
@pragma('vm:prefer-inline') @override $Res call({Object? userMessage = null,Object? sequenceId = freezed,Object? accpetProposals = null,Object? attachedPosts = freezed,Object? attachedMessages = freezed,Object? serviceId = freezed,}) {
  return _then(_self.copyWith(
userMessage: null == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as String,sequenceId: freezed == sequenceId ? _self.sequenceId : sequenceId // ignore: cast_nullable_to_non_nullable
as String?,accpetProposals: null == accpetProposals ? _self.accpetProposals : accpetProposals // ignore: cast_nullable_to_non_nullable
as List<String>,attachedPosts: freezed == attachedPosts ? _self.attachedPosts : attachedPosts // ignore: cast_nullable_to_non_nullable
as List<String>?,attachedMessages: freezed == attachedMessages ? _self.attachedMessages : attachedMessages // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userMessage,  String? sequenceId,  List<String> accpetProposals,  List<String>? attachedPosts,  List<Map<String, dynamic>>? attachedMessages, @JsonKey(name: 'service_id')  String? serviceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamThinkingRequest() when $default != null:
return $default(_that.userMessage,_that.sequenceId,_that.accpetProposals,_that.attachedPosts,_that.attachedMessages,_that.serviceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userMessage,  String? sequenceId,  List<String> accpetProposals,  List<String>? attachedPosts,  List<Map<String, dynamic>>? attachedMessages, @JsonKey(name: 'service_id')  String? serviceId)  $default,) {final _that = this;
switch (_that) {
case _StreamThinkingRequest():
return $default(_that.userMessage,_that.sequenceId,_that.accpetProposals,_that.attachedPosts,_that.attachedMessages,_that.serviceId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userMessage,  String? sequenceId,  List<String> accpetProposals,  List<String>? attachedPosts,  List<Map<String, dynamic>>? attachedMessages, @JsonKey(name: 'service_id')  String? serviceId)?  $default,) {final _that = this;
switch (_that) {
case _StreamThinkingRequest() when $default != null:
return $default(_that.userMessage,_that.sequenceId,_that.accpetProposals,_that.attachedPosts,_that.attachedMessages,_that.serviceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamThinkingRequest implements StreamThinkingRequest {
  const _StreamThinkingRequest({required this.userMessage, this.sequenceId, final  List<String> accpetProposals = const [], final  List<String>? attachedPosts, final  List<Map<String, dynamic>>? attachedMessages, @JsonKey(name: 'service_id') this.serviceId}): _accpetProposals = accpetProposals,_attachedPosts = attachedPosts,_attachedMessages = attachedMessages;
  factory _StreamThinkingRequest.fromJson(Map<String, dynamic> json) => _$StreamThinkingRequestFromJson(json);

@override final  String userMessage;
@override final  String? sequenceId;
 final  List<String> _accpetProposals;
@override@JsonKey() List<String> get accpetProposals {
  if (_accpetProposals is EqualUnmodifiableListView) return _accpetProposals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accpetProposals);
}

 final  List<String>? _attachedPosts;
@override List<String>? get attachedPosts {
  final value = _attachedPosts;
  if (value == null) return null;
  if (_attachedPosts is EqualUnmodifiableListView) return _attachedPosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Map<String, dynamic>>? _attachedMessages;
@override List<Map<String, dynamic>>? get attachedMessages {
  final value = _attachedMessages;
  if (value == null) return null;
  if (_attachedMessages is EqualUnmodifiableListView) return _attachedMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'service_id') final  String? serviceId;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamThinkingRequest&&(identical(other.userMessage, userMessage) || other.userMessage == userMessage)&&(identical(other.sequenceId, sequenceId) || other.sequenceId == sequenceId)&&const DeepCollectionEquality().equals(other._accpetProposals, _accpetProposals)&&const DeepCollectionEquality().equals(other._attachedPosts, _attachedPosts)&&const DeepCollectionEquality().equals(other._attachedMessages, _attachedMessages)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userMessage,sequenceId,const DeepCollectionEquality().hash(_accpetProposals),const DeepCollectionEquality().hash(_attachedPosts),const DeepCollectionEquality().hash(_attachedMessages),serviceId);

@override
String toString() {
  return 'StreamThinkingRequest(userMessage: $userMessage, sequenceId: $sequenceId, accpetProposals: $accpetProposals, attachedPosts: $attachedPosts, attachedMessages: $attachedMessages, serviceId: $serviceId)';
}


}

/// @nodoc
abstract mixin class _$StreamThinkingRequestCopyWith<$Res> implements $StreamThinkingRequestCopyWith<$Res> {
  factory _$StreamThinkingRequestCopyWith(_StreamThinkingRequest value, $Res Function(_StreamThinkingRequest) _then) = __$StreamThinkingRequestCopyWithImpl;
@override @useResult
$Res call({
 String userMessage, String? sequenceId, List<String> accpetProposals, List<String>? attachedPosts, List<Map<String, dynamic>>? attachedMessages,@JsonKey(name: 'service_id') String? serviceId
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
@override @pragma('vm:prefer-inline') $Res call({Object? userMessage = null,Object? sequenceId = freezed,Object? accpetProposals = null,Object? attachedPosts = freezed,Object? attachedMessages = freezed,Object? serviceId = freezed,}) {
  return _then(_StreamThinkingRequest(
userMessage: null == userMessage ? _self.userMessage : userMessage // ignore: cast_nullable_to_non_nullable
as String,sequenceId: freezed == sequenceId ? _self.sequenceId : sequenceId // ignore: cast_nullable_to_non_nullable
as String?,accpetProposals: null == accpetProposals ? _self._accpetProposals : accpetProposals // ignore: cast_nullable_to_non_nullable
as List<String>,attachedPosts: freezed == attachedPosts ? _self._attachedPosts : attachedPosts // ignore: cast_nullable_to_non_nullable
as List<String>?,attachedMessages: freezed == attachedMessages ? _self._attachedMessages : attachedMessages // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
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
mixin _$SnFunctionCall {

 String get id; String get name; String get arguments;
/// Create a copy of SnFunctionCall
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFunctionCallCopyWith<SnFunctionCall> get copyWith => _$SnFunctionCallCopyWithImpl<SnFunctionCall>(this as SnFunctionCall, _$identity);

  /// Serializes this SnFunctionCall to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFunctionCall&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.arguments, arguments) || other.arguments == arguments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,arguments);

@override
String toString() {
  return 'SnFunctionCall(id: $id, name: $name, arguments: $arguments)';
}


}

/// @nodoc
abstract mixin class $SnFunctionCallCopyWith<$Res>  {
  factory $SnFunctionCallCopyWith(SnFunctionCall value, $Res Function(SnFunctionCall) _then) = _$SnFunctionCallCopyWithImpl;
@useResult
$Res call({
 String id, String name, String arguments
});




}
/// @nodoc
class _$SnFunctionCallCopyWithImpl<$Res>
    implements $SnFunctionCallCopyWith<$Res> {
  _$SnFunctionCallCopyWithImpl(this._self, this._then);

  final SnFunctionCall _self;
  final $Res Function(SnFunctionCall) _then;

/// Create a copy of SnFunctionCall
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? arguments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFunctionCall].
extension SnFunctionCallPatterns on SnFunctionCall {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFunctionCall value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFunctionCall() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFunctionCall value)  $default,){
final _that = this;
switch (_that) {
case _SnFunctionCall():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFunctionCall value)?  $default,){
final _that = this;
switch (_that) {
case _SnFunctionCall() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String arguments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFunctionCall() when $default != null:
return $default(_that.id,_that.name,_that.arguments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String arguments)  $default,) {final _that = this;
switch (_that) {
case _SnFunctionCall():
return $default(_that.id,_that.name,_that.arguments);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String arguments)?  $default,) {final _that = this;
switch (_that) {
case _SnFunctionCall() when $default != null:
return $default(_that.id,_that.name,_that.arguments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFunctionCall implements SnFunctionCall {
  const _SnFunctionCall({required this.id, required this.name, required this.arguments});
  factory _SnFunctionCall.fromJson(Map<String, dynamic> json) => _$SnFunctionCallFromJson(json);

@override final  String id;
@override final  String name;
@override final  String arguments;

/// Create a copy of SnFunctionCall
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFunctionCallCopyWith<_SnFunctionCall> get copyWith => __$SnFunctionCallCopyWithImpl<_SnFunctionCall>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFunctionCallToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFunctionCall&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.arguments, arguments) || other.arguments == arguments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,arguments);

@override
String toString() {
  return 'SnFunctionCall(id: $id, name: $name, arguments: $arguments)';
}


}

/// @nodoc
abstract mixin class _$SnFunctionCallCopyWith<$Res> implements $SnFunctionCallCopyWith<$Res> {
  factory _$SnFunctionCallCopyWith(_SnFunctionCall value, $Res Function(_SnFunctionCall) _then) = __$SnFunctionCallCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String arguments
});




}
/// @nodoc
class __$SnFunctionCallCopyWithImpl<$Res>
    implements _$SnFunctionCallCopyWith<$Res> {
  __$SnFunctionCallCopyWithImpl(this._self, this._then);

  final _SnFunctionCall _self;
  final $Res Function(_SnFunctionCall) _then;

/// Create a copy of SnFunctionCall
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? arguments = null,}) {
  return _then(_SnFunctionCall(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,arguments: null == arguments ? _self.arguments : arguments // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnFunctionResult {

 String get callId; dynamic get result; bool get isError;
/// Create a copy of SnFunctionResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFunctionResultCopyWith<SnFunctionResult> get copyWith => _$SnFunctionResultCopyWithImpl<SnFunctionResult>(this as SnFunctionResult, _$identity);

  /// Serializes this SnFunctionResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFunctionResult&&(identical(other.callId, callId) || other.callId == callId)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.isError, isError) || other.isError == isError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,const DeepCollectionEquality().hash(result),isError);

@override
String toString() {
  return 'SnFunctionResult(callId: $callId, result: $result, isError: $isError)';
}


}

/// @nodoc
abstract mixin class $SnFunctionResultCopyWith<$Res>  {
  factory $SnFunctionResultCopyWith(SnFunctionResult value, $Res Function(SnFunctionResult) _then) = _$SnFunctionResultCopyWithImpl;
@useResult
$Res call({
 String callId, dynamic result, bool isError
});




}
/// @nodoc
class _$SnFunctionResultCopyWithImpl<$Res>
    implements $SnFunctionResultCopyWith<$Res> {
  _$SnFunctionResultCopyWithImpl(this._self, this._then);

  final SnFunctionResult _self;
  final $Res Function(SnFunctionResult) _then;

/// Create a copy of SnFunctionResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? callId = null,Object? result = freezed,Object? isError = null,}) {
  return _then(_self.copyWith(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as dynamic,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFunctionResult].
extension SnFunctionResultPatterns on SnFunctionResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFunctionResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFunctionResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFunctionResult value)  $default,){
final _that = this;
switch (_that) {
case _SnFunctionResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFunctionResult value)?  $default,){
final _that = this;
switch (_that) {
case _SnFunctionResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String callId,  dynamic result,  bool isError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFunctionResult() when $default != null:
return $default(_that.callId,_that.result,_that.isError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String callId,  dynamic result,  bool isError)  $default,) {final _that = this;
switch (_that) {
case _SnFunctionResult():
return $default(_that.callId,_that.result,_that.isError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String callId,  dynamic result,  bool isError)?  $default,) {final _that = this;
switch (_that) {
case _SnFunctionResult() when $default != null:
return $default(_that.callId,_that.result,_that.isError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFunctionResult implements SnFunctionResult {
  const _SnFunctionResult({required this.callId, required this.result, required this.isError});
  factory _SnFunctionResult.fromJson(Map<String, dynamic> json) => _$SnFunctionResultFromJson(json);

@override final  String callId;
@override final  dynamic result;
@override final  bool isError;

/// Create a copy of SnFunctionResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFunctionResultCopyWith<_SnFunctionResult> get copyWith => __$SnFunctionResultCopyWithImpl<_SnFunctionResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFunctionResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFunctionResult&&(identical(other.callId, callId) || other.callId == callId)&&const DeepCollectionEquality().equals(other.result, result)&&(identical(other.isError, isError) || other.isError == isError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,callId,const DeepCollectionEquality().hash(result),isError);

@override
String toString() {
  return 'SnFunctionResult(callId: $callId, result: $result, isError: $isError)';
}


}

/// @nodoc
abstract mixin class _$SnFunctionResultCopyWith<$Res> implements $SnFunctionResultCopyWith<$Res> {
  factory _$SnFunctionResultCopyWith(_SnFunctionResult value, $Res Function(_SnFunctionResult) _then) = __$SnFunctionResultCopyWithImpl;
@override @useResult
$Res call({
 String callId, dynamic result, bool isError
});




}
/// @nodoc
class __$SnFunctionResultCopyWithImpl<$Res>
    implements _$SnFunctionResultCopyWith<$Res> {
  __$SnFunctionResultCopyWithImpl(this._self, this._then);

  final _SnFunctionResult _self;
  final $Res Function(_SnFunctionResult) _then;

/// Create a copy of SnFunctionResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? callId = null,Object? result = freezed,Object? isError = null,}) {
  return _then(_SnFunctionResult(
callId: null == callId ? _self.callId : callId // ignore: cast_nullable_to_non_nullable
as String,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as dynamic,isError: null == isError ? _self.isError : isError // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SnThinkingMessagePart {

@ThinkingMessagePartTypeConverter() ThinkingMessagePartType get type; String? get text; SnFunctionCall? get functionCall; SnFunctionResult? get functionResult;
/// Create a copy of SnThinkingMessagePart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnThinkingMessagePartCopyWith<SnThinkingMessagePart> get copyWith => _$SnThinkingMessagePartCopyWithImpl<SnThinkingMessagePart>(this as SnThinkingMessagePart, _$identity);

  /// Serializes this SnThinkingMessagePart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnThinkingMessagePart&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.functionCall, functionCall) || other.functionCall == functionCall)&&(identical(other.functionResult, functionResult) || other.functionResult == functionResult));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,text,functionCall,functionResult);

@override
String toString() {
  return 'SnThinkingMessagePart(type: $type, text: $text, functionCall: $functionCall, functionResult: $functionResult)';
}


}

/// @nodoc
abstract mixin class $SnThinkingMessagePartCopyWith<$Res>  {
  factory $SnThinkingMessagePartCopyWith(SnThinkingMessagePart value, $Res Function(SnThinkingMessagePart) _then) = _$SnThinkingMessagePartCopyWithImpl;
@useResult
$Res call({
@ThinkingMessagePartTypeConverter() ThinkingMessagePartType type, String? text, SnFunctionCall? functionCall, SnFunctionResult? functionResult
});


$SnFunctionCallCopyWith<$Res>? get functionCall;$SnFunctionResultCopyWith<$Res>? get functionResult;

}
/// @nodoc
class _$SnThinkingMessagePartCopyWithImpl<$Res>
    implements $SnThinkingMessagePartCopyWith<$Res> {
  _$SnThinkingMessagePartCopyWithImpl(this._self, this._then);

  final SnThinkingMessagePart _self;
  final $Res Function(SnThinkingMessagePart) _then;

/// Create a copy of SnThinkingMessagePart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? text = freezed,Object? functionCall = freezed,Object? functionResult = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ThinkingMessagePartType,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,functionCall: freezed == functionCall ? _self.functionCall : functionCall // ignore: cast_nullable_to_non_nullable
as SnFunctionCall?,functionResult: freezed == functionResult ? _self.functionResult : functionResult // ignore: cast_nullable_to_non_nullable
as SnFunctionResult?,
  ));
}
/// Create a copy of SnThinkingMessagePart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnFunctionCallCopyWith<$Res>? get functionCall {
    if (_self.functionCall == null) {
    return null;
  }

  return $SnFunctionCallCopyWith<$Res>(_self.functionCall!, (value) {
    return _then(_self.copyWith(functionCall: value));
  });
}/// Create a copy of SnThinkingMessagePart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnFunctionResultCopyWith<$Res>? get functionResult {
    if (_self.functionResult == null) {
    return null;
  }

  return $SnFunctionResultCopyWith<$Res>(_self.functionResult!, (value) {
    return _then(_self.copyWith(functionResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnThinkingMessagePart].
extension SnThinkingMessagePartPatterns on SnThinkingMessagePart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnThinkingMessagePart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnThinkingMessagePart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnThinkingMessagePart value)  $default,){
final _that = this;
switch (_that) {
case _SnThinkingMessagePart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnThinkingMessagePart value)?  $default,){
final _that = this;
switch (_that) {
case _SnThinkingMessagePart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@ThinkingMessagePartTypeConverter()  ThinkingMessagePartType type,  String? text,  SnFunctionCall? functionCall,  SnFunctionResult? functionResult)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnThinkingMessagePart() when $default != null:
return $default(_that.type,_that.text,_that.functionCall,_that.functionResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@ThinkingMessagePartTypeConverter()  ThinkingMessagePartType type,  String? text,  SnFunctionCall? functionCall,  SnFunctionResult? functionResult)  $default,) {final _that = this;
switch (_that) {
case _SnThinkingMessagePart():
return $default(_that.type,_that.text,_that.functionCall,_that.functionResult);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@ThinkingMessagePartTypeConverter()  ThinkingMessagePartType type,  String? text,  SnFunctionCall? functionCall,  SnFunctionResult? functionResult)?  $default,) {final _that = this;
switch (_that) {
case _SnThinkingMessagePart() when $default != null:
return $default(_that.type,_that.text,_that.functionCall,_that.functionResult);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnThinkingMessagePart implements SnThinkingMessagePart {
  const _SnThinkingMessagePart({@ThinkingMessagePartTypeConverter() required this.type, this.text, this.functionCall, this.functionResult});
  factory _SnThinkingMessagePart.fromJson(Map<String, dynamic> json) => _$SnThinkingMessagePartFromJson(json);

@override@ThinkingMessagePartTypeConverter() final  ThinkingMessagePartType type;
@override final  String? text;
@override final  SnFunctionCall? functionCall;
@override final  SnFunctionResult? functionResult;

/// Create a copy of SnThinkingMessagePart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnThinkingMessagePartCopyWith<_SnThinkingMessagePart> get copyWith => __$SnThinkingMessagePartCopyWithImpl<_SnThinkingMessagePart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnThinkingMessagePartToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnThinkingMessagePart&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&(identical(other.functionCall, functionCall) || other.functionCall == functionCall)&&(identical(other.functionResult, functionResult) || other.functionResult == functionResult));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,text,functionCall,functionResult);

@override
String toString() {
  return 'SnThinkingMessagePart(type: $type, text: $text, functionCall: $functionCall, functionResult: $functionResult)';
}


}

/// @nodoc
abstract mixin class _$SnThinkingMessagePartCopyWith<$Res> implements $SnThinkingMessagePartCopyWith<$Res> {
  factory _$SnThinkingMessagePartCopyWith(_SnThinkingMessagePart value, $Res Function(_SnThinkingMessagePart) _then) = __$SnThinkingMessagePartCopyWithImpl;
@override @useResult
$Res call({
@ThinkingMessagePartTypeConverter() ThinkingMessagePartType type, String? text, SnFunctionCall? functionCall, SnFunctionResult? functionResult
});


@override $SnFunctionCallCopyWith<$Res>? get functionCall;@override $SnFunctionResultCopyWith<$Res>? get functionResult;

}
/// @nodoc
class __$SnThinkingMessagePartCopyWithImpl<$Res>
    implements _$SnThinkingMessagePartCopyWith<$Res> {
  __$SnThinkingMessagePartCopyWithImpl(this._self, this._then);

  final _SnThinkingMessagePart _self;
  final $Res Function(_SnThinkingMessagePart) _then;

/// Create a copy of SnThinkingMessagePart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? text = freezed,Object? functionCall = freezed,Object? functionResult = freezed,}) {
  return _then(_SnThinkingMessagePart(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ThinkingMessagePartType,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,functionCall: freezed == functionCall ? _self.functionCall : functionCall // ignore: cast_nullable_to_non_nullable
as SnFunctionCall?,functionResult: freezed == functionResult ? _self.functionResult : functionResult // ignore: cast_nullable_to_non_nullable
as SnFunctionResult?,
  ));
}

/// Create a copy of SnThinkingMessagePart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnFunctionCallCopyWith<$Res>? get functionCall {
    if (_self.functionCall == null) {
    return null;
  }

  return $SnFunctionCallCopyWith<$Res>(_self.functionCall!, (value) {
    return _then(_self.copyWith(functionCall: value));
  });
}/// Create a copy of SnThinkingMessagePart
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnFunctionResultCopyWith<$Res>? get functionResult {
    if (_self.functionResult == null) {
    return null;
  }

  return $SnFunctionResultCopyWith<$Res>(_self.functionResult!, (value) {
    return _then(_self.copyWith(functionResult: value));
  });
}
}


/// @nodoc
mixin _$SnThinkingSequence {

 String get id; String? get topic; int get totalToken; int get paidToken; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnThinkingSequence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnThinkingSequenceCopyWith<SnThinkingSequence> get copyWith => _$SnThinkingSequenceCopyWithImpl<SnThinkingSequence>(this as SnThinkingSequence, _$identity);

  /// Serializes this SnThinkingSequence to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnThinkingSequence&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.totalToken, totalToken) || other.totalToken == totalToken)&&(identical(other.paidToken, paidToken) || other.paidToken == paidToken)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,topic,totalToken,paidToken,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnThinkingSequence(id: $id, topic: $topic, totalToken: $totalToken, paidToken: $paidToken, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnThinkingSequenceCopyWith<$Res>  {
  factory $SnThinkingSequenceCopyWith(SnThinkingSequence value, $Res Function(SnThinkingSequence) _then) = _$SnThinkingSequenceCopyWithImpl;
@useResult
$Res call({
 String id, String? topic, int totalToken, int paidToken, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? topic = freezed,Object? totalToken = null,Object? paidToken = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,totalToken: null == totalToken ? _self.totalToken : totalToken // ignore: cast_nullable_to_non_nullable
as int,paidToken: null == paidToken ? _self.paidToken : paidToken // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? topic,  int totalToken,  int paidToken,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnThinkingSequence() when $default != null:
return $default(_that.id,_that.topic,_that.totalToken,_that.paidToken,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? topic,  int totalToken,  int paidToken,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnThinkingSequence():
return $default(_that.id,_that.topic,_that.totalToken,_that.paidToken,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? topic,  int totalToken,  int paidToken,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnThinkingSequence() when $default != null:
return $default(_that.id,_that.topic,_that.totalToken,_that.paidToken,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnThinkingSequence implements SnThinkingSequence {
  const _SnThinkingSequence({required this.id, this.topic, this.totalToken = 0, this.paidToken = 0, required this.accountId, required this.createdAt, required this.updatedAt, this.deletedAt});
  factory _SnThinkingSequence.fromJson(Map<String, dynamic> json) => _$SnThinkingSequenceFromJson(json);

@override final  String id;
@override final  String? topic;
@override@JsonKey() final  int totalToken;
@override@JsonKey() final  int paidToken;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnThinkingSequence&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.totalToken, totalToken) || other.totalToken == totalToken)&&(identical(other.paidToken, paidToken) || other.paidToken == paidToken)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,topic,totalToken,paidToken,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnThinkingSequence(id: $id, topic: $topic, totalToken: $totalToken, paidToken: $paidToken, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnThinkingSequenceCopyWith<$Res> implements $SnThinkingSequenceCopyWith<$Res> {
  factory _$SnThinkingSequenceCopyWith(_SnThinkingSequence value, $Res Function(_SnThinkingSequence) _then) = __$SnThinkingSequenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String? topic, int totalToken, int paidToken, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? topic = freezed,Object? totalToken = null,Object? paidToken = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnThinkingSequence(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: freezed == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String?,totalToken: null == totalToken ? _self.totalToken : totalToken // ignore: cast_nullable_to_non_nullable
as int,paidToken: null == paidToken ? _self.paidToken : paidToken // ignore: cast_nullable_to_non_nullable
as int,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnThinkingThought {

 String get id; List<SnThinkingMessagePart> get parts; List<SnCloudFile> get files;@ThinkingThoughtRoleConverter() ThinkingThoughtRole get role; int? get tokenCount; String? get modelName; String get sequenceId; SnThinkingSequence? get sequence; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnThinkingThought
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnThinkingThoughtCopyWith<SnThinkingThought> get copyWith => _$SnThinkingThoughtCopyWithImpl<SnThinkingThought>(this as SnThinkingThought, _$identity);

  /// Serializes this SnThinkingThought to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnThinkingThought&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.parts, parts)&&const DeepCollectionEquality().equals(other.files, files)&&(identical(other.role, role) || other.role == role)&&(identical(other.tokenCount, tokenCount) || other.tokenCount == tokenCount)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.sequenceId, sequenceId) || other.sequenceId == sequenceId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(parts),const DeepCollectionEquality().hash(files),role,tokenCount,modelName,sequenceId,sequence,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnThinkingThought(id: $id, parts: $parts, files: $files, role: $role, tokenCount: $tokenCount, modelName: $modelName, sequenceId: $sequenceId, sequence: $sequence, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnThinkingThoughtCopyWith<$Res>  {
  factory $SnThinkingThoughtCopyWith(SnThinkingThought value, $Res Function(SnThinkingThought) _then) = _$SnThinkingThoughtCopyWithImpl;
@useResult
$Res call({
 String id, List<SnThinkingMessagePart> parts, List<SnCloudFile> files,@ThinkingThoughtRoleConverter() ThinkingThoughtRole role, int? tokenCount, String? modelName, String sequenceId, SnThinkingSequence? sequence, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parts = null,Object? files = null,Object? role = null,Object? tokenCount = freezed,Object? modelName = freezed,Object? sequenceId = null,Object? sequence = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parts: null == parts ? _self.parts : parts // ignore: cast_nullable_to_non_nullable
as List<SnThinkingMessagePart>,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ThinkingThoughtRole,tokenCount: freezed == tokenCount ? _self.tokenCount : tokenCount // ignore: cast_nullable_to_non_nullable
as int?,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,sequenceId: null == sequenceId ? _self.sequenceId : sequenceId // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<SnThinkingMessagePart> parts,  List<SnCloudFile> files, @ThinkingThoughtRoleConverter()  ThinkingThoughtRole role,  int? tokenCount,  String? modelName,  String sequenceId,  SnThinkingSequence? sequence,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnThinkingThought() when $default != null:
return $default(_that.id,_that.parts,_that.files,_that.role,_that.tokenCount,_that.modelName,_that.sequenceId,_that.sequence,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<SnThinkingMessagePart> parts,  List<SnCloudFile> files, @ThinkingThoughtRoleConverter()  ThinkingThoughtRole role,  int? tokenCount,  String? modelName,  String sequenceId,  SnThinkingSequence? sequence,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnThinkingThought():
return $default(_that.id,_that.parts,_that.files,_that.role,_that.tokenCount,_that.modelName,_that.sequenceId,_that.sequence,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<SnThinkingMessagePart> parts,  List<SnCloudFile> files, @ThinkingThoughtRoleConverter()  ThinkingThoughtRole role,  int? tokenCount,  String? modelName,  String sequenceId,  SnThinkingSequence? sequence,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnThinkingThought() when $default != null:
return $default(_that.id,_that.parts,_that.files,_that.role,_that.tokenCount,_that.modelName,_that.sequenceId,_that.sequence,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnThinkingThought implements SnThinkingThought {
  const _SnThinkingThought({required this.id, final  List<SnThinkingMessagePart> parts = const [], final  List<SnCloudFile> files = const [], @ThinkingThoughtRoleConverter() required this.role, this.tokenCount, this.modelName, required this.sequenceId, this.sequence, required this.createdAt, required this.updatedAt, this.deletedAt}): _parts = parts,_files = files;
  factory _SnThinkingThought.fromJson(Map<String, dynamic> json) => _$SnThinkingThoughtFromJson(json);

@override final  String id;
 final  List<SnThinkingMessagePart> _parts;
@override@JsonKey() List<SnThinkingMessagePart> get parts {
  if (_parts is EqualUnmodifiableListView) return _parts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parts);
}

 final  List<SnCloudFile> _files;
@override@JsonKey() List<SnCloudFile> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

@override@ThinkingThoughtRoleConverter() final  ThinkingThoughtRole role;
@override final  int? tokenCount;
@override final  String? modelName;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnThinkingThought&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._parts, _parts)&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.role, role) || other.role == role)&&(identical(other.tokenCount, tokenCount) || other.tokenCount == tokenCount)&&(identical(other.modelName, modelName) || other.modelName == modelName)&&(identical(other.sequenceId, sequenceId) || other.sequenceId == sequenceId)&&(identical(other.sequence, sequence) || other.sequence == sequence)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_parts),const DeepCollectionEquality().hash(_files),role,tokenCount,modelName,sequenceId,sequence,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnThinkingThought(id: $id, parts: $parts, files: $files, role: $role, tokenCount: $tokenCount, modelName: $modelName, sequenceId: $sequenceId, sequence: $sequence, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnThinkingThoughtCopyWith<$Res> implements $SnThinkingThoughtCopyWith<$Res> {
  factory _$SnThinkingThoughtCopyWith(_SnThinkingThought value, $Res Function(_SnThinkingThought) _then) = __$SnThinkingThoughtCopyWithImpl;
@override @useResult
$Res call({
 String id, List<SnThinkingMessagePart> parts, List<SnCloudFile> files,@ThinkingThoughtRoleConverter() ThinkingThoughtRole role, int? tokenCount, String? modelName, String sequenceId, SnThinkingSequence? sequence, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parts = null,Object? files = null,Object? role = null,Object? tokenCount = freezed,Object? modelName = freezed,Object? sequenceId = null,Object? sequence = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnThinkingThought(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parts: null == parts ? _self._parts : parts // ignore: cast_nullable_to_non_nullable
as List<SnThinkingMessagePart>,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<SnCloudFile>,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as ThinkingThoughtRole,tokenCount: freezed == tokenCount ? _self.tokenCount : tokenCount // ignore: cast_nullable_to_non_nullable
as int?,modelName: freezed == modelName ? _self.modelName : modelName // ignore: cast_nullable_to_non_nullable
as String?,sequenceId: null == sequenceId ? _self.sequenceId : sequenceId // ignore: cast_nullable_to_non_nullable
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


/// @nodoc
mixin _$ThoughtService {

@JsonKey(name: 'service_id') String get serviceId; double get billingMultiplier; int get perkLevel;
/// Create a copy of ThoughtService
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThoughtServiceCopyWith<ThoughtService> get copyWith => _$ThoughtServiceCopyWithImpl<ThoughtService>(this as ThoughtService, _$identity);

  /// Serializes this ThoughtService to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThoughtService&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.billingMultiplier, billingMultiplier) || other.billingMultiplier == billingMultiplier)&&(identical(other.perkLevel, perkLevel) || other.perkLevel == perkLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serviceId,billingMultiplier,perkLevel);

@override
String toString() {
  return 'ThoughtService(serviceId: $serviceId, billingMultiplier: $billingMultiplier, perkLevel: $perkLevel)';
}


}

/// @nodoc
abstract mixin class $ThoughtServiceCopyWith<$Res>  {
  factory $ThoughtServiceCopyWith(ThoughtService value, $Res Function(ThoughtService) _then) = _$ThoughtServiceCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'service_id') String serviceId, double billingMultiplier, int perkLevel
});




}
/// @nodoc
class _$ThoughtServiceCopyWithImpl<$Res>
    implements $ThoughtServiceCopyWith<$Res> {
  _$ThoughtServiceCopyWithImpl(this._self, this._then);

  final ThoughtService _self;
  final $Res Function(ThoughtService) _then;

/// Create a copy of ThoughtService
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serviceId = null,Object? billingMultiplier = null,Object? perkLevel = null,}) {
  return _then(_self.copyWith(
serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,billingMultiplier: null == billingMultiplier ? _self.billingMultiplier : billingMultiplier // ignore: cast_nullable_to_non_nullable
as double,perkLevel: null == perkLevel ? _self.perkLevel : perkLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ThoughtService].
extension ThoughtServicePatterns on ThoughtService {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThoughtService value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThoughtService() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThoughtService value)  $default,){
final _that = this;
switch (_that) {
case _ThoughtService():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThoughtService value)?  $default,){
final _that = this;
switch (_that) {
case _ThoughtService() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'service_id')  String serviceId,  double billingMultiplier,  int perkLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThoughtService() when $default != null:
return $default(_that.serviceId,_that.billingMultiplier,_that.perkLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'service_id')  String serviceId,  double billingMultiplier,  int perkLevel)  $default,) {final _that = this;
switch (_that) {
case _ThoughtService():
return $default(_that.serviceId,_that.billingMultiplier,_that.perkLevel);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'service_id')  String serviceId,  double billingMultiplier,  int perkLevel)?  $default,) {final _that = this;
switch (_that) {
case _ThoughtService() when $default != null:
return $default(_that.serviceId,_that.billingMultiplier,_that.perkLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThoughtService implements ThoughtService {
  const _ThoughtService({@JsonKey(name: 'service_id') required this.serviceId, required this.billingMultiplier, required this.perkLevel});
  factory _ThoughtService.fromJson(Map<String, dynamic> json) => _$ThoughtServiceFromJson(json);

@override@JsonKey(name: 'service_id') final  String serviceId;
@override final  double billingMultiplier;
@override final  int perkLevel;

/// Create a copy of ThoughtService
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThoughtServiceCopyWith<_ThoughtService> get copyWith => __$ThoughtServiceCopyWithImpl<_ThoughtService>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThoughtServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThoughtService&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.billingMultiplier, billingMultiplier) || other.billingMultiplier == billingMultiplier)&&(identical(other.perkLevel, perkLevel) || other.perkLevel == perkLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serviceId,billingMultiplier,perkLevel);

@override
String toString() {
  return 'ThoughtService(serviceId: $serviceId, billingMultiplier: $billingMultiplier, perkLevel: $perkLevel)';
}


}

/// @nodoc
abstract mixin class _$ThoughtServiceCopyWith<$Res> implements $ThoughtServiceCopyWith<$Res> {
  factory _$ThoughtServiceCopyWith(_ThoughtService value, $Res Function(_ThoughtService) _then) = __$ThoughtServiceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'service_id') String serviceId, double billingMultiplier, int perkLevel
});




}
/// @nodoc
class __$ThoughtServiceCopyWithImpl<$Res>
    implements _$ThoughtServiceCopyWith<$Res> {
  __$ThoughtServiceCopyWithImpl(this._self, this._then);

  final _ThoughtService _self;
  final $Res Function(_ThoughtService) _then;

/// Create a copy of ThoughtService
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serviceId = null,Object? billingMultiplier = null,Object? perkLevel = null,}) {
  return _then(_ThoughtService(
serviceId: null == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String,billingMultiplier: null == billingMultiplier ? _self.billingMultiplier : billingMultiplier // ignore: cast_nullable_to_non_nullable
as double,perkLevel: null == perkLevel ? _self.perkLevel : perkLevel // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ThoughtServicesResponse {

@JsonKey(name: 'default_service') String get defaultService; List<ThoughtService> get services;
/// Create a copy of ThoughtServicesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThoughtServicesResponseCopyWith<ThoughtServicesResponse> get copyWith => _$ThoughtServicesResponseCopyWithImpl<ThoughtServicesResponse>(this as ThoughtServicesResponse, _$identity);

  /// Serializes this ThoughtServicesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThoughtServicesResponse&&(identical(other.defaultService, defaultService) || other.defaultService == defaultService)&&const DeepCollectionEquality().equals(other.services, services));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultService,const DeepCollectionEquality().hash(services));

@override
String toString() {
  return 'ThoughtServicesResponse(defaultService: $defaultService, services: $services)';
}


}

/// @nodoc
abstract mixin class $ThoughtServicesResponseCopyWith<$Res>  {
  factory $ThoughtServicesResponseCopyWith(ThoughtServicesResponse value, $Res Function(ThoughtServicesResponse) _then) = _$ThoughtServicesResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'default_service') String defaultService, List<ThoughtService> services
});




}
/// @nodoc
class _$ThoughtServicesResponseCopyWithImpl<$Res>
    implements $ThoughtServicesResponseCopyWith<$Res> {
  _$ThoughtServicesResponseCopyWithImpl(this._self, this._then);

  final ThoughtServicesResponse _self;
  final $Res Function(ThoughtServicesResponse) _then;

/// Create a copy of ThoughtServicesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultService = null,Object? services = null,}) {
  return _then(_self.copyWith(
defaultService: null == defaultService ? _self.defaultService : defaultService // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<ThoughtService>,
  ));
}

}


/// Adds pattern-matching-related methods to [ThoughtServicesResponse].
extension ThoughtServicesResponsePatterns on ThoughtServicesResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThoughtServicesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThoughtServicesResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThoughtServicesResponse value)  $default,){
final _that = this;
switch (_that) {
case _ThoughtServicesResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThoughtServicesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ThoughtServicesResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'default_service')  String defaultService,  List<ThoughtService> services)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThoughtServicesResponse() when $default != null:
return $default(_that.defaultService,_that.services);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'default_service')  String defaultService,  List<ThoughtService> services)  $default,) {final _that = this;
switch (_that) {
case _ThoughtServicesResponse():
return $default(_that.defaultService,_that.services);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'default_service')  String defaultService,  List<ThoughtService> services)?  $default,) {final _that = this;
switch (_that) {
case _ThoughtServicesResponse() when $default != null:
return $default(_that.defaultService,_that.services);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThoughtServicesResponse implements ThoughtServicesResponse {
  const _ThoughtServicesResponse({@JsonKey(name: 'default_service') required this.defaultService, required final  List<ThoughtService> services}): _services = services;
  factory _ThoughtServicesResponse.fromJson(Map<String, dynamic> json) => _$ThoughtServicesResponseFromJson(json);

@override@JsonKey(name: 'default_service') final  String defaultService;
 final  List<ThoughtService> _services;
@override List<ThoughtService> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}


/// Create a copy of ThoughtServicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThoughtServicesResponseCopyWith<_ThoughtServicesResponse> get copyWith => __$ThoughtServicesResponseCopyWithImpl<_ThoughtServicesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThoughtServicesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThoughtServicesResponse&&(identical(other.defaultService, defaultService) || other.defaultService == defaultService)&&const DeepCollectionEquality().equals(other._services, _services));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultService,const DeepCollectionEquality().hash(_services));

@override
String toString() {
  return 'ThoughtServicesResponse(defaultService: $defaultService, services: $services)';
}


}

/// @nodoc
abstract mixin class _$ThoughtServicesResponseCopyWith<$Res> implements $ThoughtServicesResponseCopyWith<$Res> {
  factory _$ThoughtServicesResponseCopyWith(_ThoughtServicesResponse value, $Res Function(_ThoughtServicesResponse) _then) = __$ThoughtServicesResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'default_service') String defaultService, List<ThoughtService> services
});




}
/// @nodoc
class __$ThoughtServicesResponseCopyWithImpl<$Res>
    implements _$ThoughtServicesResponseCopyWith<$Res> {
  __$ThoughtServicesResponseCopyWithImpl(this._self, this._then);

  final _ThoughtServicesResponse _self;
  final $Res Function(_ThoughtServicesResponse) _then;

/// Create a copy of ThoughtServicesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultService = null,Object? services = null,}) {
  return _then(_ThoughtServicesResponse(
defaultService: null == defaultService ? _self.defaultService : defaultService // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<ThoughtService>,
  ));
}


}

// dart format on
