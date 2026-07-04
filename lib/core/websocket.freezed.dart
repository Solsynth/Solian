// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'websocket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WebSocketState implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketState'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebSocketState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketState()';
}


}

/// @nodoc
class $WebSocketStateCopyWith<$Res>  {
$WebSocketStateCopyWith(WebSocketState _, $Res Function(WebSocketState) __);
}


/// Adds pattern-matching-related methods to [WebSocketState].
extension WebSocketStatePatterns on WebSocketState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Connected value)?  connected,TResult Function( _Connecting value)?  connecting,TResult Function( _Disconnected value)?  disconnected,TResult Function( _InternetChanged value)?  internetChanged,TResult Function( _ServerDown value)?  serverDown,TResult Function( _DuplicateDevice value)?  duplicateDevice,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Connected() when connected != null:
return connected(_that);case _Connecting() when connecting != null:
return connecting(_that);case _Disconnected() when disconnected != null:
return disconnected(_that);case _InternetChanged() when internetChanged != null:
return internetChanged(_that);case _ServerDown() when serverDown != null:
return serverDown(_that);case _DuplicateDevice() when duplicateDevice != null:
return duplicateDevice(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Connected value)  connected,required TResult Function( _Connecting value)  connecting,required TResult Function( _Disconnected value)  disconnected,required TResult Function( _InternetChanged value)  internetChanged,required TResult Function( _ServerDown value)  serverDown,required TResult Function( _DuplicateDevice value)  duplicateDevice,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Connected():
return connected(_that);case _Connecting():
return connecting(_that);case _Disconnected():
return disconnected(_that);case _InternetChanged():
return internetChanged(_that);case _ServerDown():
return serverDown(_that);case _DuplicateDevice():
return duplicateDevice(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Connected value)?  connected,TResult? Function( _Connecting value)?  connecting,TResult? Function( _Disconnected value)?  disconnected,TResult? Function( _InternetChanged value)?  internetChanged,TResult? Function( _ServerDown value)?  serverDown,TResult? Function( _DuplicateDevice value)?  duplicateDevice,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Connected() when connected != null:
return connected(_that);case _Connecting() when connecting != null:
return connecting(_that);case _Disconnected() when disconnected != null:
return disconnected(_that);case _InternetChanged() when internetChanged != null:
return internetChanged(_that);case _ServerDown() when serverDown != null:
return serverDown(_that);case _DuplicateDevice() when duplicateDevice != null:
return duplicateDevice(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  connected,TResult Function()?  connecting,TResult Function()?  disconnected,TResult Function()?  internetChanged,TResult Function()?  serverDown,TResult Function()?  duplicateDevice,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Connected() when connected != null:
return connected();case _Connecting() when connecting != null:
return connecting();case _Disconnected() when disconnected != null:
return disconnected();case _InternetChanged() when internetChanged != null:
return internetChanged();case _ServerDown() when serverDown != null:
return serverDown();case _DuplicateDevice() when duplicateDevice != null:
return duplicateDevice();case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  connected,required TResult Function()  connecting,required TResult Function()  disconnected,required TResult Function()  internetChanged,required TResult Function()  serverDown,required TResult Function()  duplicateDevice,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Connected():
return connected();case _Connecting():
return connecting();case _Disconnected():
return disconnected();case _InternetChanged():
return internetChanged();case _ServerDown():
return serverDown();case _DuplicateDevice():
return duplicateDevice();case _Error():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  connected,TResult? Function()?  connecting,TResult? Function()?  disconnected,TResult? Function()?  internetChanged,TResult? Function()?  serverDown,TResult? Function()?  duplicateDevice,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Connected() when connected != null:
return connected();case _Connecting() when connecting != null:
return connecting();case _Disconnected() when disconnected != null:
return disconnected();case _InternetChanged() when internetChanged != null:
return internetChanged();case _ServerDown() when serverDown != null:
return serverDown();case _DuplicateDevice() when duplicateDevice != null:
return duplicateDevice();case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Connected with DiagnosticableTreeMixin implements WebSocketState {
  const _Connected();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketState.connected'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketState.connected()';
}


}




/// @nodoc


class _Connecting with DiagnosticableTreeMixin implements WebSocketState {
  const _Connecting();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketState.connecting'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketState.connecting()';
}


}




/// @nodoc


class _Disconnected with DiagnosticableTreeMixin implements WebSocketState {
  const _Disconnected();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketState.disconnected'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Disconnected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketState.disconnected()';
}


}




/// @nodoc


class _InternetChanged with DiagnosticableTreeMixin implements WebSocketState {
  const _InternetChanged();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketState.internetChanged'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InternetChanged);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketState.internetChanged()';
}


}




/// @nodoc


class _ServerDown with DiagnosticableTreeMixin implements WebSocketState {
  const _ServerDown();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketState.serverDown'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerDown);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketState.serverDown()';
}


}




/// @nodoc


class _DuplicateDevice with DiagnosticableTreeMixin implements WebSocketState {
  const _DuplicateDevice();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketState.duplicateDevice'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DuplicateDevice);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketState.duplicateDevice()';
}


}




/// @nodoc


class _Error with DiagnosticableTreeMixin implements WebSocketState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of WebSocketState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketState.error'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $WebSocketStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of WebSocketState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WebSocketPacket implements DiagnosticableTreeMixin {

 String get type; Map<String, dynamic>? get data; String? get endpoint; String? get errorMessage;
/// Create a copy of WebSocketPacket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WebSocketPacketCopyWith<WebSocketPacket> get copyWith => _$WebSocketPacketCopyWithImpl<WebSocketPacket>(this as WebSocketPacket, _$identity);

  /// Serializes this WebSocketPacket to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketPacket'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('data', data))..add(DiagnosticsProperty('endpoint', endpoint))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WebSocketPacket&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.endpoint, endpoint) || other.endpoint == endpoint)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(data),endpoint,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketPacket(type: $type, data: $data, endpoint: $endpoint, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $WebSocketPacketCopyWith<$Res>  {
  factory $WebSocketPacketCopyWith(WebSocketPacket value, $Res Function(WebSocketPacket) _then) = _$WebSocketPacketCopyWithImpl;
@useResult
$Res call({
 String type, Map<String, dynamic>? data, String? endpoint, String? errorMessage
});




}
/// @nodoc
class _$WebSocketPacketCopyWithImpl<$Res>
    implements $WebSocketPacketCopyWith<$Res> {
  _$WebSocketPacketCopyWithImpl(this._self, this._then);

  final WebSocketPacket _self;
  final $Res Function(WebSocketPacket) _then;

/// Create a copy of WebSocketPacket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? data = freezed,Object? endpoint = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,endpoint: freezed == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WebSocketPacket].
extension WebSocketPacketPatterns on WebSocketPacket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WebSocketPacket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WebSocketPacket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WebSocketPacket value)  $default,){
final _that = this;
switch (_that) {
case _WebSocketPacket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WebSocketPacket value)?  $default,){
final _that = this;
switch (_that) {
case _WebSocketPacket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  Map<String, dynamic>? data,  String? endpoint,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WebSocketPacket() when $default != null:
return $default(_that.type,_that.data,_that.endpoint,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  Map<String, dynamic>? data,  String? endpoint,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _WebSocketPacket():
return $default(_that.type,_that.data,_that.endpoint,_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  Map<String, dynamic>? data,  String? endpoint,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _WebSocketPacket() when $default != null:
return $default(_that.type,_that.data,_that.endpoint,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WebSocketPacket with DiagnosticableTreeMixin implements WebSocketPacket {
  const _WebSocketPacket({required this.type, required final  Map<String, dynamic>? data, this.endpoint, this.errorMessage}): _data = data;
  factory _WebSocketPacket.fromJson(Map<String, dynamic> json) => _$WebSocketPacketFromJson(json);

@override final  String type;
 final  Map<String, dynamic>? _data;
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? endpoint;
@override final  String? errorMessage;

/// Create a copy of WebSocketPacket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WebSocketPacketCopyWith<_WebSocketPacket> get copyWith => __$WebSocketPacketCopyWithImpl<_WebSocketPacket>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WebSocketPacketToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'WebSocketPacket'))
    ..add(DiagnosticsProperty('type', type))..add(DiagnosticsProperty('data', data))..add(DiagnosticsProperty('endpoint', endpoint))..add(DiagnosticsProperty('errorMessage', errorMessage));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WebSocketPacket&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.endpoint, endpoint) || other.endpoint == endpoint)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_data),endpoint,errorMessage);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'WebSocketPacket(type: $type, data: $data, endpoint: $endpoint, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$WebSocketPacketCopyWith<$Res> implements $WebSocketPacketCopyWith<$Res> {
  factory _$WebSocketPacketCopyWith(_WebSocketPacket value, $Res Function(_WebSocketPacket) _then) = __$WebSocketPacketCopyWithImpl;
@override @useResult
$Res call({
 String type, Map<String, dynamic>? data, String? endpoint, String? errorMessage
});




}
/// @nodoc
class __$WebSocketPacketCopyWithImpl<$Res>
    implements _$WebSocketPacketCopyWith<$Res> {
  __$WebSocketPacketCopyWithImpl(this._self, this._then);

  final _WebSocketPacket _self;
  final $Res Function(_WebSocketPacket) _then;

/// Create a copy of WebSocketPacket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? data = freezed,Object? endpoint = freezed,Object? errorMessage = freezed,}) {
  return _then(_WebSocketPacket(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,endpoint: freezed == endpoint ? _self.endpoint : endpoint // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
