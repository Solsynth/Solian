// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CallState {

 bool get isConnected; bool get isReconnecting; bool get isMicrophoneEnabled; bool get isCameraEnabled; bool get isScreenSharing; bool get isSpeakerphone; Duration get duration; DateTime? get joinedAt; ViewMode get viewMode; int get participantSyncVersion; int get reconnectAttempt; bool get hasJoined; String? get error;
/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallStateCopyWith<CallState> get copyWith => _$CallStateCopyWithImpl<CallState>(this as CallState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallState&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isReconnecting, isReconnecting) || other.isReconnecting == isReconnecting)&&(identical(other.isMicrophoneEnabled, isMicrophoneEnabled) || other.isMicrophoneEnabled == isMicrophoneEnabled)&&(identical(other.isCameraEnabled, isCameraEnabled) || other.isCameraEnabled == isCameraEnabled)&&(identical(other.isScreenSharing, isScreenSharing) || other.isScreenSharing == isScreenSharing)&&(identical(other.isSpeakerphone, isSpeakerphone) || other.isSpeakerphone == isSpeakerphone)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.participantSyncVersion, participantSyncVersion) || other.participantSyncVersion == participantSyncVersion)&&(identical(other.reconnectAttempt, reconnectAttempt) || other.reconnectAttempt == reconnectAttempt)&&(identical(other.hasJoined, hasJoined) || other.hasJoined == hasJoined)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isConnected,isReconnecting,isMicrophoneEnabled,isCameraEnabled,isScreenSharing,isSpeakerphone,duration,joinedAt,viewMode,participantSyncVersion,reconnectAttempt,hasJoined,error);

@override
String toString() {
  return 'CallState(isConnected: $isConnected, isReconnecting: $isReconnecting, isMicrophoneEnabled: $isMicrophoneEnabled, isCameraEnabled: $isCameraEnabled, isScreenSharing: $isScreenSharing, isSpeakerphone: $isSpeakerphone, duration: $duration, joinedAt: $joinedAt, viewMode: $viewMode, participantSyncVersion: $participantSyncVersion, reconnectAttempt: $reconnectAttempt, hasJoined: $hasJoined, error: $error)';
}


}

/// @nodoc
abstract mixin class $CallStateCopyWith<$Res>  {
  factory $CallStateCopyWith(CallState value, $Res Function(CallState) _then) = _$CallStateCopyWithImpl;
@useResult
$Res call({
 bool isConnected, bool isReconnecting, bool isMicrophoneEnabled, bool isCameraEnabled, bool isScreenSharing, bool isSpeakerphone, Duration duration, DateTime? joinedAt, ViewMode viewMode, int participantSyncVersion, int reconnectAttempt, bool hasJoined, String? error
});




}
/// @nodoc
class _$CallStateCopyWithImpl<$Res>
    implements $CallStateCopyWith<$Res> {
  _$CallStateCopyWithImpl(this._self, this._then);

  final CallState _self;
  final $Res Function(CallState) _then;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isConnected = null,Object? isReconnecting = null,Object? isMicrophoneEnabled = null,Object? isCameraEnabled = null,Object? isScreenSharing = null,Object? isSpeakerphone = null,Object? duration = null,Object? joinedAt = freezed,Object? viewMode = null,Object? participantSyncVersion = null,Object? reconnectAttempt = null,Object? hasJoined = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isReconnecting: null == isReconnecting ? _self.isReconnecting : isReconnecting // ignore: cast_nullable_to_non_nullable
as bool,isMicrophoneEnabled: null == isMicrophoneEnabled ? _self.isMicrophoneEnabled : isMicrophoneEnabled // ignore: cast_nullable_to_non_nullable
as bool,isCameraEnabled: null == isCameraEnabled ? _self.isCameraEnabled : isCameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,isScreenSharing: null == isScreenSharing ? _self.isScreenSharing : isScreenSharing // ignore: cast_nullable_to_non_nullable
as bool,isSpeakerphone: null == isSpeakerphone ? _self.isSpeakerphone : isSpeakerphone // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as ViewMode,participantSyncVersion: null == participantSyncVersion ? _self.participantSyncVersion : participantSyncVersion // ignore: cast_nullable_to_non_nullable
as int,reconnectAttempt: null == reconnectAttempt ? _self.reconnectAttempt : reconnectAttempt // ignore: cast_nullable_to_non_nullable
as int,hasJoined: null == hasJoined ? _self.hasJoined : hasJoined // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CallState].
extension CallStatePatterns on CallState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallState value)  $default,){
final _that = this;
switch (_that) {
case _CallState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallState value)?  $default,){
final _that = this;
switch (_that) {
case _CallState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isConnected,  bool isReconnecting,  bool isMicrophoneEnabled,  bool isCameraEnabled,  bool isScreenSharing,  bool isSpeakerphone,  Duration duration,  DateTime? joinedAt,  ViewMode viewMode,  int participantSyncVersion,  int reconnectAttempt,  bool hasJoined,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallState() when $default != null:
return $default(_that.isConnected,_that.isReconnecting,_that.isMicrophoneEnabled,_that.isCameraEnabled,_that.isScreenSharing,_that.isSpeakerphone,_that.duration,_that.joinedAt,_that.viewMode,_that.participantSyncVersion,_that.reconnectAttempt,_that.hasJoined,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isConnected,  bool isReconnecting,  bool isMicrophoneEnabled,  bool isCameraEnabled,  bool isScreenSharing,  bool isSpeakerphone,  Duration duration,  DateTime? joinedAt,  ViewMode viewMode,  int participantSyncVersion,  int reconnectAttempt,  bool hasJoined,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CallState():
return $default(_that.isConnected,_that.isReconnecting,_that.isMicrophoneEnabled,_that.isCameraEnabled,_that.isScreenSharing,_that.isSpeakerphone,_that.duration,_that.joinedAt,_that.viewMode,_that.participantSyncVersion,_that.reconnectAttempt,_that.hasJoined,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isConnected,  bool isReconnecting,  bool isMicrophoneEnabled,  bool isCameraEnabled,  bool isScreenSharing,  bool isSpeakerphone,  Duration duration,  DateTime? joinedAt,  ViewMode viewMode,  int participantSyncVersion,  int reconnectAttempt,  bool hasJoined,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CallState() when $default != null:
return $default(_that.isConnected,_that.isReconnecting,_that.isMicrophoneEnabled,_that.isCameraEnabled,_that.isScreenSharing,_that.isSpeakerphone,_that.duration,_that.joinedAt,_that.viewMode,_that.participantSyncVersion,_that.reconnectAttempt,_that.hasJoined,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CallState implements CallState {
  const _CallState({required this.isConnected, this.isReconnecting = false, required this.isMicrophoneEnabled, required this.isCameraEnabled, required this.isScreenSharing, required this.isSpeakerphone, this.duration = const Duration(seconds: 0), this.joinedAt, this.viewMode = ViewMode.grid, this.participantSyncVersion = 0, this.reconnectAttempt = 0, this.hasJoined = false, this.error});
  

@override final  bool isConnected;
@override@JsonKey() final  bool isReconnecting;
@override final  bool isMicrophoneEnabled;
@override final  bool isCameraEnabled;
@override final  bool isScreenSharing;
@override final  bool isSpeakerphone;
@override@JsonKey() final  Duration duration;
@override final  DateTime? joinedAt;
@override@JsonKey() final  ViewMode viewMode;
@override@JsonKey() final  int participantSyncVersion;
@override@JsonKey() final  int reconnectAttempt;
@override@JsonKey() final  bool hasJoined;
@override final  String? error;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallStateCopyWith<_CallState> get copyWith => __$CallStateCopyWithImpl<_CallState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallState&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&(identical(other.isReconnecting, isReconnecting) || other.isReconnecting == isReconnecting)&&(identical(other.isMicrophoneEnabled, isMicrophoneEnabled) || other.isMicrophoneEnabled == isMicrophoneEnabled)&&(identical(other.isCameraEnabled, isCameraEnabled) || other.isCameraEnabled == isCameraEnabled)&&(identical(other.isScreenSharing, isScreenSharing) || other.isScreenSharing == isScreenSharing)&&(identical(other.isSpeakerphone, isSpeakerphone) || other.isSpeakerphone == isSpeakerphone)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&(identical(other.viewMode, viewMode) || other.viewMode == viewMode)&&(identical(other.participantSyncVersion, participantSyncVersion) || other.participantSyncVersion == participantSyncVersion)&&(identical(other.reconnectAttempt, reconnectAttempt) || other.reconnectAttempt == reconnectAttempt)&&(identical(other.hasJoined, hasJoined) || other.hasJoined == hasJoined)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,isConnected,isReconnecting,isMicrophoneEnabled,isCameraEnabled,isScreenSharing,isSpeakerphone,duration,joinedAt,viewMode,participantSyncVersion,reconnectAttempt,hasJoined,error);

@override
String toString() {
  return 'CallState(isConnected: $isConnected, isReconnecting: $isReconnecting, isMicrophoneEnabled: $isMicrophoneEnabled, isCameraEnabled: $isCameraEnabled, isScreenSharing: $isScreenSharing, isSpeakerphone: $isSpeakerphone, duration: $duration, joinedAt: $joinedAt, viewMode: $viewMode, participantSyncVersion: $participantSyncVersion, reconnectAttempt: $reconnectAttempt, hasJoined: $hasJoined, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CallStateCopyWith<$Res> implements $CallStateCopyWith<$Res> {
  factory _$CallStateCopyWith(_CallState value, $Res Function(_CallState) _then) = __$CallStateCopyWithImpl;
@override @useResult
$Res call({
 bool isConnected, bool isReconnecting, bool isMicrophoneEnabled, bool isCameraEnabled, bool isScreenSharing, bool isSpeakerphone, Duration duration, DateTime? joinedAt, ViewMode viewMode, int participantSyncVersion, int reconnectAttempt, bool hasJoined, String? error
});




}
/// @nodoc
class __$CallStateCopyWithImpl<$Res>
    implements _$CallStateCopyWith<$Res> {
  __$CallStateCopyWithImpl(this._self, this._then);

  final _CallState _self;
  final $Res Function(_CallState) _then;

/// Create a copy of CallState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isConnected = null,Object? isReconnecting = null,Object? isMicrophoneEnabled = null,Object? isCameraEnabled = null,Object? isScreenSharing = null,Object? isSpeakerphone = null,Object? duration = null,Object? joinedAt = freezed,Object? viewMode = null,Object? participantSyncVersion = null,Object? reconnectAttempt = null,Object? hasJoined = null,Object? error = freezed,}) {
  return _then(_CallState(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,isReconnecting: null == isReconnecting ? _self.isReconnecting : isReconnecting // ignore: cast_nullable_to_non_nullable
as bool,isMicrophoneEnabled: null == isMicrophoneEnabled ? _self.isMicrophoneEnabled : isMicrophoneEnabled // ignore: cast_nullable_to_non_nullable
as bool,isCameraEnabled: null == isCameraEnabled ? _self.isCameraEnabled : isCameraEnabled // ignore: cast_nullable_to_non_nullable
as bool,isScreenSharing: null == isScreenSharing ? _self.isScreenSharing : isScreenSharing // ignore: cast_nullable_to_non_nullable
as bool,isSpeakerphone: null == isSpeakerphone ? _self.isSpeakerphone : isSpeakerphone // ignore: cast_nullable_to_non_nullable
as bool,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,viewMode: null == viewMode ? _self.viewMode : viewMode // ignore: cast_nullable_to_non_nullable
as ViewMode,participantSyncVersion: null == participantSyncVersion ? _self.participantSyncVersion : participantSyncVersion // ignore: cast_nullable_to_non_nullable
as int,reconnectAttempt: null == reconnectAttempt ? _self.reconnectAttempt : reconnectAttempt // ignore: cast_nullable_to_non_nullable
as int,hasJoined: null == hasJoined ? _self.hasJoined : hasJoined // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CallParticipantLive {

 CallParticipant get participant; lk.Participant get remoteParticipant;
/// Create a copy of CallParticipantLive
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallParticipantLiveCopyWith<CallParticipantLive> get copyWith => _$CallParticipantLiveCopyWithImpl<CallParticipantLive>(this as CallParticipantLive, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallParticipantLive&&(identical(other.participant, participant) || other.participant == participant)&&(identical(other.remoteParticipant, remoteParticipant) || other.remoteParticipant == remoteParticipant));
}


@override
int get hashCode => Object.hash(runtimeType,participant,remoteParticipant);

@override
String toString() {
  return 'CallParticipantLive(participant: $participant, remoteParticipant: $remoteParticipant)';
}


}

/// @nodoc
abstract mixin class $CallParticipantLiveCopyWith<$Res>  {
  factory $CallParticipantLiveCopyWith(CallParticipantLive value, $Res Function(CallParticipantLive) _then) = _$CallParticipantLiveCopyWithImpl;
@useResult
$Res call({
 CallParticipant participant, lk.Participant remoteParticipant
});


$CallParticipantCopyWith<$Res> get participant;

}
/// @nodoc
class _$CallParticipantLiveCopyWithImpl<$Res>
    implements $CallParticipantLiveCopyWith<$Res> {
  _$CallParticipantLiveCopyWithImpl(this._self, this._then);

  final CallParticipantLive _self;
  final $Res Function(CallParticipantLive) _then;

/// Create a copy of CallParticipantLive
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? participant = null,Object? remoteParticipant = null,}) {
  return _then(_self.copyWith(
participant: null == participant ? _self.participant : participant // ignore: cast_nullable_to_non_nullable
as CallParticipant,remoteParticipant: null == remoteParticipant ? _self.remoteParticipant : remoteParticipant // ignore: cast_nullable_to_non_nullable
as lk.Participant,
  ));
}
/// Create a copy of CallParticipantLive
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CallParticipantCopyWith<$Res> get participant {
  
  return $CallParticipantCopyWith<$Res>(_self.participant, (value) {
    return _then(_self.copyWith(participant: value));
  });
}
}


/// Adds pattern-matching-related methods to [CallParticipantLive].
extension CallParticipantLivePatterns on CallParticipantLive {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CallParticipantLive value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CallParticipantLive() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CallParticipantLive value)  $default,){
final _that = this;
switch (_that) {
case _CallParticipantLive():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CallParticipantLive value)?  $default,){
final _that = this;
switch (_that) {
case _CallParticipantLive() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CallParticipant participant,  lk.Participant remoteParticipant)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CallParticipantLive() when $default != null:
return $default(_that.participant,_that.remoteParticipant);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CallParticipant participant,  lk.Participant remoteParticipant)  $default,) {final _that = this;
switch (_that) {
case _CallParticipantLive():
return $default(_that.participant,_that.remoteParticipant);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CallParticipant participant,  lk.Participant remoteParticipant)?  $default,) {final _that = this;
switch (_that) {
case _CallParticipantLive() when $default != null:
return $default(_that.participant,_that.remoteParticipant);case _:
  return null;

}
}

}

/// @nodoc


class _CallParticipantLive extends CallParticipantLive {
  const _CallParticipantLive({required this.participant, required this.remoteParticipant}): super._();
  

@override final  CallParticipant participant;
@override final  lk.Participant remoteParticipant;

/// Create a copy of CallParticipantLive
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CallParticipantLiveCopyWith<_CallParticipantLive> get copyWith => __$CallParticipantLiveCopyWithImpl<_CallParticipantLive>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CallParticipantLive&&(identical(other.participant, participant) || other.participant == participant)&&(identical(other.remoteParticipant, remoteParticipant) || other.remoteParticipant == remoteParticipant));
}


@override
int get hashCode => Object.hash(runtimeType,participant,remoteParticipant);

@override
String toString() {
  return 'CallParticipantLive(participant: $participant, remoteParticipant: $remoteParticipant)';
}


}

/// @nodoc
abstract mixin class _$CallParticipantLiveCopyWith<$Res> implements $CallParticipantLiveCopyWith<$Res> {
  factory _$CallParticipantLiveCopyWith(_CallParticipantLive value, $Res Function(_CallParticipantLive) _then) = __$CallParticipantLiveCopyWithImpl;
@override @useResult
$Res call({
 CallParticipant participant, lk.Participant remoteParticipant
});


@override $CallParticipantCopyWith<$Res> get participant;

}
/// @nodoc
class __$CallParticipantLiveCopyWithImpl<$Res>
    implements _$CallParticipantLiveCopyWith<$Res> {
  __$CallParticipantLiveCopyWithImpl(this._self, this._then);

  final _CallParticipantLive _self;
  final $Res Function(_CallParticipantLive) _then;

/// Create a copy of CallParticipantLive
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? participant = null,Object? remoteParticipant = null,}) {
  return _then(_CallParticipantLive(
participant: null == participant ? _self.participant : participant // ignore: cast_nullable_to_non_nullable
as CallParticipant,remoteParticipant: null == remoteParticipant ? _self.remoteParticipant : remoteParticipant // ignore: cast_nullable_to_non_nullable
as lk.Participant,
  ));
}

/// Create a copy of CallParticipantLive
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CallParticipantCopyWith<$Res> get participant {
  
  return $CallParticipantCopyWith<$Res>(_self.participant, (value) {
    return _then(_self.copyWith(participant: value));
  });
}
}

// dart format on
