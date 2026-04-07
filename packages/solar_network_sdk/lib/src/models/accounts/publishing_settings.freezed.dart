// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publishing_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPublishingSettings {

 String get id; String get accountId; String? get defaultPostingPublisherId; String? get defaultReplyPublisherId; String? get defaultFediversePublisherId; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of SnPublishingSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublishingSettingsCopyWith<SnPublishingSettings> get copyWith => _$SnPublishingSettingsCopyWithImpl<SnPublishingSettings>(this as SnPublishingSettings, _$identity);

  /// Serializes this SnPublishingSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublishingSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.defaultPostingPublisherId, defaultPostingPublisherId) || other.defaultPostingPublisherId == defaultPostingPublisherId)&&(identical(other.defaultReplyPublisherId, defaultReplyPublisherId) || other.defaultReplyPublisherId == defaultReplyPublisherId)&&(identical(other.defaultFediversePublisherId, defaultFediversePublisherId) || other.defaultFediversePublisherId == defaultFediversePublisherId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,defaultPostingPublisherId,defaultReplyPublisherId,defaultFediversePublisherId,createdAt,updatedAt);

@override
String toString() {
  return 'SnPublishingSettings(id: $id, accountId: $accountId, defaultPostingPublisherId: $defaultPostingPublisherId, defaultReplyPublisherId: $defaultReplyPublisherId, defaultFediversePublisherId: $defaultFediversePublisherId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnPublishingSettingsCopyWith<$Res>  {
  factory $SnPublishingSettingsCopyWith(SnPublishingSettings value, $Res Function(SnPublishingSettings) _then) = _$SnPublishingSettingsCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String? defaultPostingPublisherId, String? defaultReplyPublisherId, String? defaultFediversePublisherId, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$SnPublishingSettingsCopyWithImpl<$Res>
    implements $SnPublishingSettingsCopyWith<$Res> {
  _$SnPublishingSettingsCopyWithImpl(this._self, this._then);

  final SnPublishingSettings _self;
  final $Res Function(SnPublishingSettings) _then;

/// Create a copy of SnPublishingSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? defaultPostingPublisherId = freezed,Object? defaultReplyPublisherId = freezed,Object? defaultFediversePublisherId = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,defaultPostingPublisherId: freezed == defaultPostingPublisherId ? _self.defaultPostingPublisherId : defaultPostingPublisherId // ignore: cast_nullable_to_non_nullable
as String?,defaultReplyPublisherId: freezed == defaultReplyPublisherId ? _self.defaultReplyPublisherId : defaultReplyPublisherId // ignore: cast_nullable_to_non_nullable
as String?,defaultFediversePublisherId: freezed == defaultFediversePublisherId ? _self.defaultFediversePublisherId : defaultFediversePublisherId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublishingSettings].
extension SnPublishingSettingsPatterns on SnPublishingSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublishingSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublishingSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublishingSettings value)  $default,){
final _that = this;
switch (_that) {
case _SnPublishingSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublishingSettings value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublishingSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String? defaultPostingPublisherId,  String? defaultReplyPublisherId,  String? defaultFediversePublisherId,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublishingSettings() when $default != null:
return $default(_that.id,_that.accountId,_that.defaultPostingPublisherId,_that.defaultReplyPublisherId,_that.defaultFediversePublisherId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String? defaultPostingPublisherId,  String? defaultReplyPublisherId,  String? defaultFediversePublisherId,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPublishingSettings():
return $default(_that.id,_that.accountId,_that.defaultPostingPublisherId,_that.defaultReplyPublisherId,_that.defaultFediversePublisherId,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String? defaultPostingPublisherId,  String? defaultReplyPublisherId,  String? defaultFediversePublisherId,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPublishingSettings() when $default != null:
return $default(_that.id,_that.accountId,_that.defaultPostingPublisherId,_that.defaultReplyPublisherId,_that.defaultFediversePublisherId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublishingSettings implements SnPublishingSettings {
  const _SnPublishingSettings({required this.id, required this.accountId, this.defaultPostingPublisherId, this.defaultReplyPublisherId, this.defaultFediversePublisherId, required this.createdAt, this.updatedAt});
  factory _SnPublishingSettings.fromJson(Map<String, dynamic> json) => _$SnPublishingSettingsFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String? defaultPostingPublisherId;
@override final  String? defaultReplyPublisherId;
@override final  String? defaultFediversePublisherId;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of SnPublishingSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublishingSettingsCopyWith<_SnPublishingSettings> get copyWith => __$SnPublishingSettingsCopyWithImpl<_SnPublishingSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublishingSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublishingSettings&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.defaultPostingPublisherId, defaultPostingPublisherId) || other.defaultPostingPublisherId == defaultPostingPublisherId)&&(identical(other.defaultReplyPublisherId, defaultReplyPublisherId) || other.defaultReplyPublisherId == defaultReplyPublisherId)&&(identical(other.defaultFediversePublisherId, defaultFediversePublisherId) || other.defaultFediversePublisherId == defaultFediversePublisherId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,defaultPostingPublisherId,defaultReplyPublisherId,defaultFediversePublisherId,createdAt,updatedAt);

@override
String toString() {
  return 'SnPublishingSettings(id: $id, accountId: $accountId, defaultPostingPublisherId: $defaultPostingPublisherId, defaultReplyPublisherId: $defaultReplyPublisherId, defaultFediversePublisherId: $defaultFediversePublisherId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPublishingSettingsCopyWith<$Res> implements $SnPublishingSettingsCopyWith<$Res> {
  factory _$SnPublishingSettingsCopyWith(_SnPublishingSettings value, $Res Function(_SnPublishingSettings) _then) = __$SnPublishingSettingsCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String? defaultPostingPublisherId, String? defaultReplyPublisherId, String? defaultFediversePublisherId, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$SnPublishingSettingsCopyWithImpl<$Res>
    implements _$SnPublishingSettingsCopyWith<$Res> {
  __$SnPublishingSettingsCopyWithImpl(this._self, this._then);

  final _SnPublishingSettings _self;
  final $Res Function(_SnPublishingSettings) _then;

/// Create a copy of SnPublishingSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? defaultPostingPublisherId = freezed,Object? defaultReplyPublisherId = freezed,Object? defaultFediversePublisherId = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_SnPublishingSettings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,defaultPostingPublisherId: freezed == defaultPostingPublisherId ? _self.defaultPostingPublisherId : defaultPostingPublisherId // ignore: cast_nullable_to_non_nullable
as String?,defaultReplyPublisherId: freezed == defaultReplyPublisherId ? _self.defaultReplyPublisherId : defaultReplyPublisherId // ignore: cast_nullable_to_non_nullable
as String?,defaultFediversePublisherId: freezed == defaultFediversePublisherId ? _self.defaultFediversePublisherId : defaultFediversePublisherId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnFediversePublisherAvailability {

 String get publisherId; String get publisherName; String get fediverseHandle; String get fediverseUri; String? get avatarUrl; bool get isEnabled; int get followersCount; int get followingCount; int get postsCount;
/// Create a copy of SnFediversePublisherAvailability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFediversePublisherAvailabilityCopyWith<SnFediversePublisherAvailability> get copyWith => _$SnFediversePublisherAvailabilityCopyWithImpl<SnFediversePublisherAvailability>(this as SnFediversePublisherAvailability, _$identity);

  /// Serializes this SnFediversePublisherAvailability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFediversePublisherAvailability&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName)&&(identical(other.fediverseHandle, fediverseHandle) || other.fediverseHandle == fediverseHandle)&&(identical(other.fediverseUri, fediverseUri) || other.fediverseUri == fediverseUri)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publisherId,publisherName,fediverseHandle,fediverseUri,avatarUrl,isEnabled,followersCount,followingCount,postsCount);

@override
String toString() {
  return 'SnFediversePublisherAvailability(publisherId: $publisherId, publisherName: $publisherName, fediverseHandle: $fediverseHandle, fediverseUri: $fediverseUri, avatarUrl: $avatarUrl, isEnabled: $isEnabled, followersCount: $followersCount, followingCount: $followingCount, postsCount: $postsCount)';
}


}

/// @nodoc
abstract mixin class $SnFediversePublisherAvailabilityCopyWith<$Res>  {
  factory $SnFediversePublisherAvailabilityCopyWith(SnFediversePublisherAvailability value, $Res Function(SnFediversePublisherAvailability) _then) = _$SnFediversePublisherAvailabilityCopyWithImpl;
@useResult
$Res call({
 String publisherId, String publisherName, String fediverseHandle, String fediverseUri, String? avatarUrl, bool isEnabled, int followersCount, int followingCount, int postsCount
});




}
/// @nodoc
class _$SnFediversePublisherAvailabilityCopyWithImpl<$Res>
    implements $SnFediversePublisherAvailabilityCopyWith<$Res> {
  _$SnFediversePublisherAvailabilityCopyWithImpl(this._self, this._then);

  final SnFediversePublisherAvailability _self;
  final $Res Function(SnFediversePublisherAvailability) _then;

/// Create a copy of SnFediversePublisherAvailability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publisherId = null,Object? publisherName = null,Object? fediverseHandle = null,Object? fediverseUri = null,Object? avatarUrl = freezed,Object? isEnabled = null,Object? followersCount = null,Object? followingCount = null,Object? postsCount = null,}) {
  return _then(_self.copyWith(
publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisherName: null == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String,fediverseHandle: null == fediverseHandle ? _self.fediverseHandle : fediverseHandle // ignore: cast_nullable_to_non_nullable
as String,fediverseUri: null == fediverseUri ? _self.fediverseUri : fediverseUri // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFediversePublisherAvailability].
extension SnFediversePublisherAvailabilityPatterns on SnFediversePublisherAvailability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFediversePublisherAvailability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFediversePublisherAvailability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFediversePublisherAvailability value)  $default,){
final _that = this;
switch (_that) {
case _SnFediversePublisherAvailability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFediversePublisherAvailability value)?  $default,){
final _that = this;
switch (_that) {
case _SnFediversePublisherAvailability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String publisherId,  String publisherName,  String fediverseHandle,  String fediverseUri,  String? avatarUrl,  bool isEnabled,  int followersCount,  int followingCount,  int postsCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFediversePublisherAvailability() when $default != null:
return $default(_that.publisherId,_that.publisherName,_that.fediverseHandle,_that.fediverseUri,_that.avatarUrl,_that.isEnabled,_that.followersCount,_that.followingCount,_that.postsCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String publisherId,  String publisherName,  String fediverseHandle,  String fediverseUri,  String? avatarUrl,  bool isEnabled,  int followersCount,  int followingCount,  int postsCount)  $default,) {final _that = this;
switch (_that) {
case _SnFediversePublisherAvailability():
return $default(_that.publisherId,_that.publisherName,_that.fediverseHandle,_that.fediverseUri,_that.avatarUrl,_that.isEnabled,_that.followersCount,_that.followingCount,_that.postsCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String publisherId,  String publisherName,  String fediverseHandle,  String fediverseUri,  String? avatarUrl,  bool isEnabled,  int followersCount,  int followingCount,  int postsCount)?  $default,) {final _that = this;
switch (_that) {
case _SnFediversePublisherAvailability() when $default != null:
return $default(_that.publisherId,_that.publisherName,_that.fediverseHandle,_that.fediverseUri,_that.avatarUrl,_that.isEnabled,_that.followersCount,_that.followingCount,_that.postsCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFediversePublisherAvailability implements SnFediversePublisherAvailability {
  const _SnFediversePublisherAvailability({required this.publisherId, required this.publisherName, required this.fediverseHandle, required this.fediverseUri, this.avatarUrl, required this.isEnabled, required this.followersCount, required this.followingCount, required this.postsCount});
  factory _SnFediversePublisherAvailability.fromJson(Map<String, dynamic> json) => _$SnFediversePublisherAvailabilityFromJson(json);

@override final  String publisherId;
@override final  String publisherName;
@override final  String fediverseHandle;
@override final  String fediverseUri;
@override final  String? avatarUrl;
@override final  bool isEnabled;
@override final  int followersCount;
@override final  int followingCount;
@override final  int postsCount;

/// Create a copy of SnFediversePublisherAvailability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFediversePublisherAvailabilityCopyWith<_SnFediversePublisherAvailability> get copyWith => __$SnFediversePublisherAvailabilityCopyWithImpl<_SnFediversePublisherAvailability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFediversePublisherAvailabilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFediversePublisherAvailability&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisherName, publisherName) || other.publisherName == publisherName)&&(identical(other.fediverseHandle, fediverseHandle) || other.fediverseHandle == fediverseHandle)&&(identical(other.fediverseUri, fediverseUri) || other.fediverseUri == fediverseUri)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.postsCount, postsCount) || other.postsCount == postsCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publisherId,publisherName,fediverseHandle,fediverseUri,avatarUrl,isEnabled,followersCount,followingCount,postsCount);

@override
String toString() {
  return 'SnFediversePublisherAvailability(publisherId: $publisherId, publisherName: $publisherName, fediverseHandle: $fediverseHandle, fediverseUri: $fediverseUri, avatarUrl: $avatarUrl, isEnabled: $isEnabled, followersCount: $followersCount, followingCount: $followingCount, postsCount: $postsCount)';
}


}

/// @nodoc
abstract mixin class _$SnFediversePublisherAvailabilityCopyWith<$Res> implements $SnFediversePublisherAvailabilityCopyWith<$Res> {
  factory _$SnFediversePublisherAvailabilityCopyWith(_SnFediversePublisherAvailability value, $Res Function(_SnFediversePublisherAvailability) _then) = __$SnFediversePublisherAvailabilityCopyWithImpl;
@override @useResult
$Res call({
 String publisherId, String publisherName, String fediverseHandle, String fediverseUri, String? avatarUrl, bool isEnabled, int followersCount, int followingCount, int postsCount
});




}
/// @nodoc
class __$SnFediversePublisherAvailabilityCopyWithImpl<$Res>
    implements _$SnFediversePublisherAvailabilityCopyWith<$Res> {
  __$SnFediversePublisherAvailabilityCopyWithImpl(this._self, this._then);

  final _SnFediversePublisherAvailability _self;
  final $Res Function(_SnFediversePublisherAvailability) _then;

/// Create a copy of SnFediversePublisherAvailability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publisherId = null,Object? publisherName = null,Object? fediverseHandle = null,Object? fediverseUri = null,Object? avatarUrl = freezed,Object? isEnabled = null,Object? followersCount = null,Object? followingCount = null,Object? postsCount = null,}) {
  return _then(_SnFediversePublisherAvailability(
publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisherName: null == publisherName ? _self.publisherName : publisherName // ignore: cast_nullable_to_non_nullable
as String,fediverseHandle: null == fediverseHandle ? _self.fediverseHandle : fediverseHandle // ignore: cast_nullable_to_non_nullable
as String,fediverseUri: null == fediverseUri ? _self.fediverseUri : fediverseUri // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,postsCount: null == postsCount ? _self.postsCount : postsCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SnFediverseAvailabilityResponse {

 bool get isEnabled; List<SnFediversePublisherAvailability> get publishers;
/// Create a copy of SnFediverseAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFediverseAvailabilityResponseCopyWith<SnFediverseAvailabilityResponse> get copyWith => _$SnFediverseAvailabilityResponseCopyWithImpl<SnFediverseAvailabilityResponse>(this as SnFediverseAvailabilityResponse, _$identity);

  /// Serializes this SnFediverseAvailabilityResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFediverseAvailabilityResponse&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&const DeepCollectionEquality().equals(other.publishers, publishers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isEnabled,const DeepCollectionEquality().hash(publishers));

@override
String toString() {
  return 'SnFediverseAvailabilityResponse(isEnabled: $isEnabled, publishers: $publishers)';
}


}

/// @nodoc
abstract mixin class $SnFediverseAvailabilityResponseCopyWith<$Res>  {
  factory $SnFediverseAvailabilityResponseCopyWith(SnFediverseAvailabilityResponse value, $Res Function(SnFediverseAvailabilityResponse) _then) = _$SnFediverseAvailabilityResponseCopyWithImpl;
@useResult
$Res call({
 bool isEnabled, List<SnFediversePublisherAvailability> publishers
});




}
/// @nodoc
class _$SnFediverseAvailabilityResponseCopyWithImpl<$Res>
    implements $SnFediverseAvailabilityResponseCopyWith<$Res> {
  _$SnFediverseAvailabilityResponseCopyWithImpl(this._self, this._then);

  final SnFediverseAvailabilityResponse _self;
  final $Res Function(SnFediverseAvailabilityResponse) _then;

/// Create a copy of SnFediverseAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isEnabled = null,Object? publishers = null,}) {
  return _then(_self.copyWith(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,publishers: null == publishers ? _self.publishers : publishers // ignore: cast_nullable_to_non_nullable
as List<SnFediversePublisherAvailability>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFediverseAvailabilityResponse].
extension SnFediverseAvailabilityResponsePatterns on SnFediverseAvailabilityResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFediverseAvailabilityResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFediverseAvailabilityResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFediverseAvailabilityResponse value)  $default,){
final _that = this;
switch (_that) {
case _SnFediverseAvailabilityResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFediverseAvailabilityResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SnFediverseAvailabilityResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isEnabled,  List<SnFediversePublisherAvailability> publishers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFediverseAvailabilityResponse() when $default != null:
return $default(_that.isEnabled,_that.publishers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isEnabled,  List<SnFediversePublisherAvailability> publishers)  $default,) {final _that = this;
switch (_that) {
case _SnFediverseAvailabilityResponse():
return $default(_that.isEnabled,_that.publishers);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isEnabled,  List<SnFediversePublisherAvailability> publishers)?  $default,) {final _that = this;
switch (_that) {
case _SnFediverseAvailabilityResponse() when $default != null:
return $default(_that.isEnabled,_that.publishers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFediverseAvailabilityResponse implements SnFediverseAvailabilityResponse {
  const _SnFediverseAvailabilityResponse({required this.isEnabled, required final  List<SnFediversePublisherAvailability> publishers}): _publishers = publishers;
  factory _SnFediverseAvailabilityResponse.fromJson(Map<String, dynamic> json) => _$SnFediverseAvailabilityResponseFromJson(json);

@override final  bool isEnabled;
 final  List<SnFediversePublisherAvailability> _publishers;
@override List<SnFediversePublisherAvailability> get publishers {
  if (_publishers is EqualUnmodifiableListView) return _publishers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publishers);
}


/// Create a copy of SnFediverseAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFediverseAvailabilityResponseCopyWith<_SnFediverseAvailabilityResponse> get copyWith => __$SnFediverseAvailabilityResponseCopyWithImpl<_SnFediverseAvailabilityResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFediverseAvailabilityResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFediverseAvailabilityResponse&&(identical(other.isEnabled, isEnabled) || other.isEnabled == isEnabled)&&const DeepCollectionEquality().equals(other._publishers, _publishers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isEnabled,const DeepCollectionEquality().hash(_publishers));

@override
String toString() {
  return 'SnFediverseAvailabilityResponse(isEnabled: $isEnabled, publishers: $publishers)';
}


}

/// @nodoc
abstract mixin class _$SnFediverseAvailabilityResponseCopyWith<$Res> implements $SnFediverseAvailabilityResponseCopyWith<$Res> {
  factory _$SnFediverseAvailabilityResponseCopyWith(_SnFediverseAvailabilityResponse value, $Res Function(_SnFediverseAvailabilityResponse) _then) = __$SnFediverseAvailabilityResponseCopyWithImpl;
@override @useResult
$Res call({
 bool isEnabled, List<SnFediversePublisherAvailability> publishers
});




}
/// @nodoc
class __$SnFediverseAvailabilityResponseCopyWithImpl<$Res>
    implements _$SnFediverseAvailabilityResponseCopyWith<$Res> {
  __$SnFediverseAvailabilityResponseCopyWithImpl(this._self, this._then);

  final _SnFediverseAvailabilityResponse _self;
  final $Res Function(_SnFediverseAvailabilityResponse) _then;

/// Create a copy of SnFediverseAvailabilityResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isEnabled = null,Object? publishers = null,}) {
  return _then(_SnFediverseAvailabilityResponse(
isEnabled: null == isEnabled ? _self.isEnabled : isEnabled // ignore: cast_nullable_to_non_nullable
as bool,publishers: null == publishers ? _self._publishers : publishers // ignore: cast_nullable_to_non_nullable
as List<SnFediversePublisherAvailability>,
  ));
}


}

// dart format on
