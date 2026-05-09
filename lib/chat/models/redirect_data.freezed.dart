// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'redirect_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SnRedirectData {

 int get version; String get sourceRoomId; Map<String, dynamic> get sourceRoom; Map<String, dynamic> get redirectedBy; Map<String, dynamic> get redirectedToRoom; Map<String, dynamic> get senderMap;
/// Create a copy of SnRedirectData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnRedirectDataCopyWith<SnRedirectData> get copyWith => _$SnRedirectDataCopyWithImpl<SnRedirectData>(this as SnRedirectData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnRedirectData&&(identical(other.version, version) || other.version == version)&&(identical(other.sourceRoomId, sourceRoomId) || other.sourceRoomId == sourceRoomId)&&const DeepCollectionEquality().equals(other.sourceRoom, sourceRoom)&&const DeepCollectionEquality().equals(other.redirectedBy, redirectedBy)&&const DeepCollectionEquality().equals(other.redirectedToRoom, redirectedToRoom)&&const DeepCollectionEquality().equals(other.senderMap, senderMap));
}


@override
int get hashCode => Object.hash(runtimeType,version,sourceRoomId,const DeepCollectionEquality().hash(sourceRoom),const DeepCollectionEquality().hash(redirectedBy),const DeepCollectionEquality().hash(redirectedToRoom),const DeepCollectionEquality().hash(senderMap));

@override
String toString() {
  return 'SnRedirectData(version: $version, sourceRoomId: $sourceRoomId, sourceRoom: $sourceRoom, redirectedBy: $redirectedBy, redirectedToRoom: $redirectedToRoom, senderMap: $senderMap)';
}


}

/// @nodoc
abstract mixin class $SnRedirectDataCopyWith<$Res>  {
  factory $SnRedirectDataCopyWith(SnRedirectData value, $Res Function(SnRedirectData) _then) = _$SnRedirectDataCopyWithImpl;
@useResult
$Res call({
 int version, String sourceRoomId, Map<String, dynamic> sourceRoom, Map<String, dynamic> redirectedBy, Map<String, dynamic> redirectedToRoom, Map<String, dynamic> senderMap
});




}
/// @nodoc
class _$SnRedirectDataCopyWithImpl<$Res>
    implements $SnRedirectDataCopyWith<$Res> {
  _$SnRedirectDataCopyWithImpl(this._self, this._then);

  final SnRedirectData _self;
  final $Res Function(SnRedirectData) _then;

/// Create a copy of SnRedirectData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? sourceRoomId = null,Object? sourceRoom = null,Object? redirectedBy = null,Object? redirectedToRoom = null,Object? senderMap = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,sourceRoomId: null == sourceRoomId ? _self.sourceRoomId : sourceRoomId // ignore: cast_nullable_to_non_nullable
as String,sourceRoom: null == sourceRoom ? _self.sourceRoom : sourceRoom // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,redirectedBy: null == redirectedBy ? _self.redirectedBy : redirectedBy // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,redirectedToRoom: null == redirectedToRoom ? _self.redirectedToRoom : redirectedToRoom // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,senderMap: null == senderMap ? _self.senderMap : senderMap // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnRedirectData].
extension SnRedirectDataPatterns on SnRedirectData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _SnSingleMessageRedirect value)?  singleMessage,TResult Function( _SnHistorySegmentRedirect value)?  historySegment,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSingleMessageRedirect() when singleMessage != null:
return singleMessage(_that);case _SnHistorySegmentRedirect() when historySegment != null:
return historySegment(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _SnSingleMessageRedirect value)  singleMessage,required TResult Function( _SnHistorySegmentRedirect value)  historySegment,}){
final _that = this;
switch (_that) {
case _SnSingleMessageRedirect():
return singleMessage(_that);case _SnHistorySegmentRedirect():
return historySegment(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _SnSingleMessageRedirect value)?  singleMessage,TResult? Function( _SnHistorySegmentRedirect value)?  historySegment,}){
final _that = this;
switch (_that) {
case _SnSingleMessageRedirect() when singleMessage != null:
return singleMessage(_that);case _SnHistorySegmentRedirect() when historySegment != null:
return historySegment(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int version,  String sourceType,  String sourceRoomId,  String sourceSenderId,  int sourceCreatedAt,  String sourceMessageId,  String? sourceContent,  String? sourceSenderName,  Map<String, dynamic> sourceMeta,  List<Map<String, dynamic>> sourceAttachments,  Map<String, dynamic> sourceRoom,  Map<String, dynamic> redirectedBy,  Map<String, dynamic> redirectedToRoom,  Map<String, dynamic> sourceMessage,  Map<String, dynamic> senderMap)?  singleMessage,TResult Function( int version,  String kind,  String sourceRoomId,  Map<String, dynamic> sourceRoom,  Map<String, dynamic> redirectedBy,  Map<String, dynamic> redirectedToRoom,  Map<String, dynamic> range,  List<Map<String, dynamic>> messages,  Map<String, dynamic> senderMap)?  historySegment,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSingleMessageRedirect() when singleMessage != null:
return singleMessage(_that.version,_that.sourceType,_that.sourceRoomId,_that.sourceSenderId,_that.sourceCreatedAt,_that.sourceMessageId,_that.sourceContent,_that.sourceSenderName,_that.sourceMeta,_that.sourceAttachments,_that.sourceRoom,_that.redirectedBy,_that.redirectedToRoom,_that.sourceMessage,_that.senderMap);case _SnHistorySegmentRedirect() when historySegment != null:
return historySegment(_that.version,_that.kind,_that.sourceRoomId,_that.sourceRoom,_that.redirectedBy,_that.redirectedToRoom,_that.range,_that.messages,_that.senderMap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int version,  String sourceType,  String sourceRoomId,  String sourceSenderId,  int sourceCreatedAt,  String sourceMessageId,  String? sourceContent,  String? sourceSenderName,  Map<String, dynamic> sourceMeta,  List<Map<String, dynamic>> sourceAttachments,  Map<String, dynamic> sourceRoom,  Map<String, dynamic> redirectedBy,  Map<String, dynamic> redirectedToRoom,  Map<String, dynamic> sourceMessage,  Map<String, dynamic> senderMap)  singleMessage,required TResult Function( int version,  String kind,  String sourceRoomId,  Map<String, dynamic> sourceRoom,  Map<String, dynamic> redirectedBy,  Map<String, dynamic> redirectedToRoom,  Map<String, dynamic> range,  List<Map<String, dynamic>> messages,  Map<String, dynamic> senderMap)  historySegment,}) {final _that = this;
switch (_that) {
case _SnSingleMessageRedirect():
return singleMessage(_that.version,_that.sourceType,_that.sourceRoomId,_that.sourceSenderId,_that.sourceCreatedAt,_that.sourceMessageId,_that.sourceContent,_that.sourceSenderName,_that.sourceMeta,_that.sourceAttachments,_that.sourceRoom,_that.redirectedBy,_that.redirectedToRoom,_that.sourceMessage,_that.senderMap);case _SnHistorySegmentRedirect():
return historySegment(_that.version,_that.kind,_that.sourceRoomId,_that.sourceRoom,_that.redirectedBy,_that.redirectedToRoom,_that.range,_that.messages,_that.senderMap);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int version,  String sourceType,  String sourceRoomId,  String sourceSenderId,  int sourceCreatedAt,  String sourceMessageId,  String? sourceContent,  String? sourceSenderName,  Map<String, dynamic> sourceMeta,  List<Map<String, dynamic>> sourceAttachments,  Map<String, dynamic> sourceRoom,  Map<String, dynamic> redirectedBy,  Map<String, dynamic> redirectedToRoom,  Map<String, dynamic> sourceMessage,  Map<String, dynamic> senderMap)?  singleMessage,TResult? Function( int version,  String kind,  String sourceRoomId,  Map<String, dynamic> sourceRoom,  Map<String, dynamic> redirectedBy,  Map<String, dynamic> redirectedToRoom,  Map<String, dynamic> range,  List<Map<String, dynamic>> messages,  Map<String, dynamic> senderMap)?  historySegment,}) {final _that = this;
switch (_that) {
case _SnSingleMessageRedirect() when singleMessage != null:
return singleMessage(_that.version,_that.sourceType,_that.sourceRoomId,_that.sourceSenderId,_that.sourceCreatedAt,_that.sourceMessageId,_that.sourceContent,_that.sourceSenderName,_that.sourceMeta,_that.sourceAttachments,_that.sourceRoom,_that.redirectedBy,_that.redirectedToRoom,_that.sourceMessage,_that.senderMap);case _SnHistorySegmentRedirect() when historySegment != null:
return historySegment(_that.version,_that.kind,_that.sourceRoomId,_that.sourceRoom,_that.redirectedBy,_that.redirectedToRoom,_that.range,_that.messages,_that.senderMap);case _:
  return null;

}
}

}

/// @nodoc


class _SnSingleMessageRedirect extends SnRedirectData {
  const _SnSingleMessageRedirect({required this.version, required this.sourceType, required this.sourceRoomId, required this.sourceSenderId, required this.sourceCreatedAt, required this.sourceMessageId, this.sourceContent, this.sourceSenderName, final  Map<String, dynamic> sourceMeta = const {}, final  List<Map<String, dynamic>> sourceAttachments = const [], required final  Map<String, dynamic> sourceRoom, required final  Map<String, dynamic> redirectedBy, required final  Map<String, dynamic> redirectedToRoom, required final  Map<String, dynamic> sourceMessage, final  Map<String, dynamic> senderMap = const {}}): _sourceMeta = sourceMeta,_sourceAttachments = sourceAttachments,_sourceRoom = sourceRoom,_redirectedBy = redirectedBy,_redirectedToRoom = redirectedToRoom,_sourceMessage = sourceMessage,_senderMap = senderMap,super._();
  

@override final  int version;
 final  String sourceType;
@override final  String sourceRoomId;
 final  String sourceSenderId;
 final  int sourceCreatedAt;
 final  String sourceMessageId;
 final  String? sourceContent;
 final  String? sourceSenderName;
 final  Map<String, dynamic> _sourceMeta;
@JsonKey() Map<String, dynamic> get sourceMeta {
  if (_sourceMeta is EqualUnmodifiableMapView) return _sourceMeta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sourceMeta);
}

 final  List<Map<String, dynamic>> _sourceAttachments;
@JsonKey() List<Map<String, dynamic>> get sourceAttachments {
  if (_sourceAttachments is EqualUnmodifiableListView) return _sourceAttachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sourceAttachments);
}

 final  Map<String, dynamic> _sourceRoom;
@override Map<String, dynamic> get sourceRoom {
  if (_sourceRoom is EqualUnmodifiableMapView) return _sourceRoom;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sourceRoom);
}

 final  Map<String, dynamic> _redirectedBy;
@override Map<String, dynamic> get redirectedBy {
  if (_redirectedBy is EqualUnmodifiableMapView) return _redirectedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_redirectedBy);
}

 final  Map<String, dynamic> _redirectedToRoom;
@override Map<String, dynamic> get redirectedToRoom {
  if (_redirectedToRoom is EqualUnmodifiableMapView) return _redirectedToRoom;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_redirectedToRoom);
}

 final  Map<String, dynamic> _sourceMessage;
 Map<String, dynamic> get sourceMessage {
  if (_sourceMessage is EqualUnmodifiableMapView) return _sourceMessage;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sourceMessage);
}

 final  Map<String, dynamic> _senderMap;
@override@JsonKey() Map<String, dynamic> get senderMap {
  if (_senderMap is EqualUnmodifiableMapView) return _senderMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_senderMap);
}


/// Create a copy of SnRedirectData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSingleMessageRedirectCopyWith<_SnSingleMessageRedirect> get copyWith => __$SnSingleMessageRedirectCopyWithImpl<_SnSingleMessageRedirect>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSingleMessageRedirect&&(identical(other.version, version) || other.version == version)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.sourceRoomId, sourceRoomId) || other.sourceRoomId == sourceRoomId)&&(identical(other.sourceSenderId, sourceSenderId) || other.sourceSenderId == sourceSenderId)&&(identical(other.sourceCreatedAt, sourceCreatedAt) || other.sourceCreatedAt == sourceCreatedAt)&&(identical(other.sourceMessageId, sourceMessageId) || other.sourceMessageId == sourceMessageId)&&(identical(other.sourceContent, sourceContent) || other.sourceContent == sourceContent)&&(identical(other.sourceSenderName, sourceSenderName) || other.sourceSenderName == sourceSenderName)&&const DeepCollectionEquality().equals(other._sourceMeta, _sourceMeta)&&const DeepCollectionEquality().equals(other._sourceAttachments, _sourceAttachments)&&const DeepCollectionEquality().equals(other._sourceRoom, _sourceRoom)&&const DeepCollectionEquality().equals(other._redirectedBy, _redirectedBy)&&const DeepCollectionEquality().equals(other._redirectedToRoom, _redirectedToRoom)&&const DeepCollectionEquality().equals(other._sourceMessage, _sourceMessage)&&const DeepCollectionEquality().equals(other._senderMap, _senderMap));
}


@override
int get hashCode => Object.hash(runtimeType,version,sourceType,sourceRoomId,sourceSenderId,sourceCreatedAt,sourceMessageId,sourceContent,sourceSenderName,const DeepCollectionEquality().hash(_sourceMeta),const DeepCollectionEquality().hash(_sourceAttachments),const DeepCollectionEquality().hash(_sourceRoom),const DeepCollectionEquality().hash(_redirectedBy),const DeepCollectionEquality().hash(_redirectedToRoom),const DeepCollectionEquality().hash(_sourceMessage),const DeepCollectionEquality().hash(_senderMap));

@override
String toString() {
  return 'SnRedirectData.singleMessage(version: $version, sourceType: $sourceType, sourceRoomId: $sourceRoomId, sourceSenderId: $sourceSenderId, sourceCreatedAt: $sourceCreatedAt, sourceMessageId: $sourceMessageId, sourceContent: $sourceContent, sourceSenderName: $sourceSenderName, sourceMeta: $sourceMeta, sourceAttachments: $sourceAttachments, sourceRoom: $sourceRoom, redirectedBy: $redirectedBy, redirectedToRoom: $redirectedToRoom, sourceMessage: $sourceMessage, senderMap: $senderMap)';
}


}

/// @nodoc
abstract mixin class _$SnSingleMessageRedirectCopyWith<$Res> implements $SnRedirectDataCopyWith<$Res> {
  factory _$SnSingleMessageRedirectCopyWith(_SnSingleMessageRedirect value, $Res Function(_SnSingleMessageRedirect) _then) = __$SnSingleMessageRedirectCopyWithImpl;
@override @useResult
$Res call({
 int version, String sourceType, String sourceRoomId, String sourceSenderId, int sourceCreatedAt, String sourceMessageId, String? sourceContent, String? sourceSenderName, Map<String, dynamic> sourceMeta, List<Map<String, dynamic>> sourceAttachments, Map<String, dynamic> sourceRoom, Map<String, dynamic> redirectedBy, Map<String, dynamic> redirectedToRoom, Map<String, dynamic> sourceMessage, Map<String, dynamic> senderMap
});




}
/// @nodoc
class __$SnSingleMessageRedirectCopyWithImpl<$Res>
    implements _$SnSingleMessageRedirectCopyWith<$Res> {
  __$SnSingleMessageRedirectCopyWithImpl(this._self, this._then);

  final _SnSingleMessageRedirect _self;
  final $Res Function(_SnSingleMessageRedirect) _then;

/// Create a copy of SnRedirectData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? sourceType = null,Object? sourceRoomId = null,Object? sourceSenderId = null,Object? sourceCreatedAt = null,Object? sourceMessageId = null,Object? sourceContent = freezed,Object? sourceSenderName = freezed,Object? sourceMeta = null,Object? sourceAttachments = null,Object? sourceRoom = null,Object? redirectedBy = null,Object? redirectedToRoom = null,Object? sourceMessage = null,Object? senderMap = null,}) {
  return _then(_SnSingleMessageRedirect(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,sourceType: null == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String,sourceRoomId: null == sourceRoomId ? _self.sourceRoomId : sourceRoomId // ignore: cast_nullable_to_non_nullable
as String,sourceSenderId: null == sourceSenderId ? _self.sourceSenderId : sourceSenderId // ignore: cast_nullable_to_non_nullable
as String,sourceCreatedAt: null == sourceCreatedAt ? _self.sourceCreatedAt : sourceCreatedAt // ignore: cast_nullable_to_non_nullable
as int,sourceMessageId: null == sourceMessageId ? _self.sourceMessageId : sourceMessageId // ignore: cast_nullable_to_non_nullable
as String,sourceContent: freezed == sourceContent ? _self.sourceContent : sourceContent // ignore: cast_nullable_to_non_nullable
as String?,sourceSenderName: freezed == sourceSenderName ? _self.sourceSenderName : sourceSenderName // ignore: cast_nullable_to_non_nullable
as String?,sourceMeta: null == sourceMeta ? _self._sourceMeta : sourceMeta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,sourceAttachments: null == sourceAttachments ? _self._sourceAttachments : sourceAttachments // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,sourceRoom: null == sourceRoom ? _self._sourceRoom : sourceRoom // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,redirectedBy: null == redirectedBy ? _self._redirectedBy : redirectedBy // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,redirectedToRoom: null == redirectedToRoom ? _self._redirectedToRoom : redirectedToRoom // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,sourceMessage: null == sourceMessage ? _self._sourceMessage : sourceMessage // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,senderMap: null == senderMap ? _self._senderMap : senderMap // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class _SnHistorySegmentRedirect extends SnRedirectData {
  const _SnHistorySegmentRedirect({required this.version, required this.kind, required this.sourceRoomId, required final  Map<String, dynamic> sourceRoom, required final  Map<String, dynamic> redirectedBy, required final  Map<String, dynamic> redirectedToRoom, required final  Map<String, dynamic> range, final  List<Map<String, dynamic>> messages = const [], final  Map<String, dynamic> senderMap = const {}}): _sourceRoom = sourceRoom,_redirectedBy = redirectedBy,_redirectedToRoom = redirectedToRoom,_range = range,_messages = messages,_senderMap = senderMap,super._();
  

@override final  int version;
 final  String kind;
@override final  String sourceRoomId;
 final  Map<String, dynamic> _sourceRoom;
@override Map<String, dynamic> get sourceRoom {
  if (_sourceRoom is EqualUnmodifiableMapView) return _sourceRoom;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sourceRoom);
}

 final  Map<String, dynamic> _redirectedBy;
@override Map<String, dynamic> get redirectedBy {
  if (_redirectedBy is EqualUnmodifiableMapView) return _redirectedBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_redirectedBy);
}

 final  Map<String, dynamic> _redirectedToRoom;
@override Map<String, dynamic> get redirectedToRoom {
  if (_redirectedToRoom is EqualUnmodifiableMapView) return _redirectedToRoom;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_redirectedToRoom);
}

 final  Map<String, dynamic> _range;
 Map<String, dynamic> get range {
  if (_range is EqualUnmodifiableMapView) return _range;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_range);
}

 final  List<Map<String, dynamic>> _messages;
@JsonKey() List<Map<String, dynamic>> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  Map<String, dynamic> _senderMap;
@override@JsonKey() Map<String, dynamic> get senderMap {
  if (_senderMap is EqualUnmodifiableMapView) return _senderMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_senderMap);
}


/// Create a copy of SnRedirectData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnHistorySegmentRedirectCopyWith<_SnHistorySegmentRedirect> get copyWith => __$SnHistorySegmentRedirectCopyWithImpl<_SnHistorySegmentRedirect>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnHistorySegmentRedirect&&(identical(other.version, version) || other.version == version)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.sourceRoomId, sourceRoomId) || other.sourceRoomId == sourceRoomId)&&const DeepCollectionEquality().equals(other._sourceRoom, _sourceRoom)&&const DeepCollectionEquality().equals(other._redirectedBy, _redirectedBy)&&const DeepCollectionEquality().equals(other._redirectedToRoom, _redirectedToRoom)&&const DeepCollectionEquality().equals(other._range, _range)&&const DeepCollectionEquality().equals(other._messages, _messages)&&const DeepCollectionEquality().equals(other._senderMap, _senderMap));
}


@override
int get hashCode => Object.hash(runtimeType,version,kind,sourceRoomId,const DeepCollectionEquality().hash(_sourceRoom),const DeepCollectionEquality().hash(_redirectedBy),const DeepCollectionEquality().hash(_redirectedToRoom),const DeepCollectionEquality().hash(_range),const DeepCollectionEquality().hash(_messages),const DeepCollectionEquality().hash(_senderMap));

@override
String toString() {
  return 'SnRedirectData.historySegment(version: $version, kind: $kind, sourceRoomId: $sourceRoomId, sourceRoom: $sourceRoom, redirectedBy: $redirectedBy, redirectedToRoom: $redirectedToRoom, range: $range, messages: $messages, senderMap: $senderMap)';
}


}

/// @nodoc
abstract mixin class _$SnHistorySegmentRedirectCopyWith<$Res> implements $SnRedirectDataCopyWith<$Res> {
  factory _$SnHistorySegmentRedirectCopyWith(_SnHistorySegmentRedirect value, $Res Function(_SnHistorySegmentRedirect) _then) = __$SnHistorySegmentRedirectCopyWithImpl;
@override @useResult
$Res call({
 int version, String kind, String sourceRoomId, Map<String, dynamic> sourceRoom, Map<String, dynamic> redirectedBy, Map<String, dynamic> redirectedToRoom, Map<String, dynamic> range, List<Map<String, dynamic>> messages, Map<String, dynamic> senderMap
});




}
/// @nodoc
class __$SnHistorySegmentRedirectCopyWithImpl<$Res>
    implements _$SnHistorySegmentRedirectCopyWith<$Res> {
  __$SnHistorySegmentRedirectCopyWithImpl(this._self, this._then);

  final _SnHistorySegmentRedirect _self;
  final $Res Function(_SnHistorySegmentRedirect) _then;

/// Create a copy of SnRedirectData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? kind = null,Object? sourceRoomId = null,Object? sourceRoom = null,Object? redirectedBy = null,Object? redirectedToRoom = null,Object? range = null,Object? messages = null,Object? senderMap = null,}) {
  return _then(_SnHistorySegmentRedirect(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,sourceRoomId: null == sourceRoomId ? _self.sourceRoomId : sourceRoomId // ignore: cast_nullable_to_non_nullable
as String,sourceRoom: null == sourceRoom ? _self._sourceRoom : sourceRoom // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,redirectedBy: null == redirectedBy ? _self._redirectedBy : redirectedBy // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,redirectedToRoom: null == redirectedToRoom ? _self._redirectedToRoom : redirectedToRoom // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,range: null == range ? _self._range : range // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,senderMap: null == senderMap ? _self._senderMap : senderMap // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
