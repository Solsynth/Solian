// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activitypub.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnActivityPubInstance {

 String get id; String get domain; String? get name; String? get description; String? get software; String? get version; String? get iconUrl; String? get thumbnailUrl; String? get contactEmail; String? get contactAccountUsername; int? get activeUsers; bool get isBlocked; bool get isSilenced; String? get blockReason; Map<String, dynamic>? get metadata; DateTime? get lastFetchedAt; DateTime? get lastActivityAt; DateTime? get metadataFetchedAt;
/// Create a copy of SnActivityPubInstance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActivityPubInstanceCopyWith<SnActivityPubInstance> get copyWith => _$SnActivityPubInstanceCopyWithImpl<SnActivityPubInstance>(this as SnActivityPubInstance, _$identity);

  /// Serializes this SnActivityPubInstance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActivityPubInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.software, software) || other.software == software)&&(identical(other.version, version) || other.version == version)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactAccountUsername, contactAccountUsername) || other.contactAccountUsername == contactAccountUsername)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isSilenced, isSilenced) || other.isSilenced == isSilenced)&&(identical(other.blockReason, blockReason) || other.blockReason == blockReason)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.metadataFetchedAt, metadataFetchedAt) || other.metadataFetchedAt == metadataFetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,domain,name,description,software,version,iconUrl,thumbnailUrl,contactEmail,contactAccountUsername,activeUsers,isBlocked,isSilenced,blockReason,const DeepCollectionEquality().hash(metadata),lastFetchedAt,lastActivityAt,metadataFetchedAt);

@override
String toString() {
  return 'SnActivityPubInstance(id: $id, domain: $domain, name: $name, description: $description, software: $software, version: $version, iconUrl: $iconUrl, thumbnailUrl: $thumbnailUrl, contactEmail: $contactEmail, contactAccountUsername: $contactAccountUsername, activeUsers: $activeUsers, isBlocked: $isBlocked, isSilenced: $isSilenced, blockReason: $blockReason, metadata: $metadata, lastFetchedAt: $lastFetchedAt, lastActivityAt: $lastActivityAt, metadataFetchedAt: $metadataFetchedAt)';
}


}

/// @nodoc
abstract mixin class $SnActivityPubInstanceCopyWith<$Res>  {
  factory $SnActivityPubInstanceCopyWith(SnActivityPubInstance value, $Res Function(SnActivityPubInstance) _then) = _$SnActivityPubInstanceCopyWithImpl;
@useResult
$Res call({
 String id, String domain, String? name, String? description, String? software, String? version, String? iconUrl, String? thumbnailUrl, String? contactEmail, String? contactAccountUsername, int? activeUsers, bool isBlocked, bool isSilenced, String? blockReason, Map<String, dynamic>? metadata, DateTime? lastFetchedAt, DateTime? lastActivityAt, DateTime? metadataFetchedAt
});




}
/// @nodoc
class _$SnActivityPubInstanceCopyWithImpl<$Res>
    implements $SnActivityPubInstanceCopyWith<$Res> {
  _$SnActivityPubInstanceCopyWithImpl(this._self, this._then);

  final SnActivityPubInstance _self;
  final $Res Function(SnActivityPubInstance) _then;

/// Create a copy of SnActivityPubInstance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? domain = null,Object? name = freezed,Object? description = freezed,Object? software = freezed,Object? version = freezed,Object? iconUrl = freezed,Object? thumbnailUrl = freezed,Object? contactEmail = freezed,Object? contactAccountUsername = freezed,Object? activeUsers = freezed,Object? isBlocked = null,Object? isSilenced = null,Object? blockReason = freezed,Object? metadata = freezed,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,Object? metadataFetchedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,software: freezed == software ? _self.software : software // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,contactAccountUsername: freezed == contactAccountUsername ? _self.contactAccountUsername : contactAccountUsername // ignore: cast_nullable_to_non_nullable
as String?,activeUsers: freezed == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isSilenced: null == isSilenced ? _self.isSilenced : isSilenced // ignore: cast_nullable_to_non_nullable
as bool,blockReason: freezed == blockReason ? _self.blockReason : blockReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadataFetchedAt: freezed == metadataFetchedAt ? _self.metadataFetchedAt : metadataFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnActivityPubInstance].
extension SnActivityPubInstancePatterns on SnActivityPubInstance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnActivityPubInstance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnActivityPubInstance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnActivityPubInstance value)  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubInstance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnActivityPubInstance value)?  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubInstance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String domain,  String? name,  String? description,  String? software,  String? version,  String? iconUrl,  String? thumbnailUrl,  String? contactEmail,  String? contactAccountUsername,  int? activeUsers,  bool isBlocked,  bool isSilenced,  String? blockReason,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  DateTime? metadataFetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActivityPubInstance() when $default != null:
return $default(_that.id,_that.domain,_that.name,_that.description,_that.software,_that.version,_that.iconUrl,_that.thumbnailUrl,_that.contactEmail,_that.contactAccountUsername,_that.activeUsers,_that.isBlocked,_that.isSilenced,_that.blockReason,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt,_that.metadataFetchedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String domain,  String? name,  String? description,  String? software,  String? version,  String? iconUrl,  String? thumbnailUrl,  String? contactEmail,  String? contactAccountUsername,  int? activeUsers,  bool isBlocked,  bool isSilenced,  String? blockReason,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  DateTime? metadataFetchedAt)  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubInstance():
return $default(_that.id,_that.domain,_that.name,_that.description,_that.software,_that.version,_that.iconUrl,_that.thumbnailUrl,_that.contactEmail,_that.contactAccountUsername,_that.activeUsers,_that.isBlocked,_that.isSilenced,_that.blockReason,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt,_that.metadataFetchedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String domain,  String? name,  String? description,  String? software,  String? version,  String? iconUrl,  String? thumbnailUrl,  String? contactEmail,  String? contactAccountUsername,  int? activeUsers,  bool isBlocked,  bool isSilenced,  String? blockReason,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  DateTime? metadataFetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubInstance() when $default != null:
return $default(_that.id,_that.domain,_that.name,_that.description,_that.software,_that.version,_that.iconUrl,_that.thumbnailUrl,_that.contactEmail,_that.contactAccountUsername,_that.activeUsers,_that.isBlocked,_that.isSilenced,_that.blockReason,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt,_that.metadataFetchedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActivityPubInstance implements SnActivityPubInstance {
  const _SnActivityPubInstance({required this.id, required this.domain, this.name, this.description, this.software, this.version, this.iconUrl, this.thumbnailUrl, this.contactEmail, this.contactAccountUsername, this.activeUsers, this.isBlocked = false, this.isSilenced = false, this.blockReason, final  Map<String, dynamic>? metadata, this.lastFetchedAt, this.lastActivityAt, this.metadataFetchedAt}): _metadata = metadata;
  factory _SnActivityPubInstance.fromJson(Map<String, dynamic> json) => _$SnActivityPubInstanceFromJson(json);

@override final  String id;
@override final  String domain;
@override final  String? name;
@override final  String? description;
@override final  String? software;
@override final  String? version;
@override final  String? iconUrl;
@override final  String? thumbnailUrl;
@override final  String? contactEmail;
@override final  String? contactAccountUsername;
@override final  int? activeUsers;
@override@JsonKey() final  bool isBlocked;
@override@JsonKey() final  bool isSilenced;
@override final  String? blockReason;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? lastFetchedAt;
@override final  DateTime? lastActivityAt;
@override final  DateTime? metadataFetchedAt;

/// Create a copy of SnActivityPubInstance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnActivityPubInstanceCopyWith<_SnActivityPubInstance> get copyWith => __$SnActivityPubInstanceCopyWithImpl<_SnActivityPubInstance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnActivityPubInstanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActivityPubInstance&&(identical(other.id, id) || other.id == id)&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.software, software) || other.software == software)&&(identical(other.version, version) || other.version == version)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail)&&(identical(other.contactAccountUsername, contactAccountUsername) || other.contactAccountUsername == contactAccountUsername)&&(identical(other.activeUsers, activeUsers) || other.activeUsers == activeUsers)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.isSilenced, isSilenced) || other.isSilenced == isSilenced)&&(identical(other.blockReason, blockReason) || other.blockReason == blockReason)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.metadataFetchedAt, metadataFetchedAt) || other.metadataFetchedAt == metadataFetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,domain,name,description,software,version,iconUrl,thumbnailUrl,contactEmail,contactAccountUsername,activeUsers,isBlocked,isSilenced,blockReason,const DeepCollectionEquality().hash(_metadata),lastFetchedAt,lastActivityAt,metadataFetchedAt);

@override
String toString() {
  return 'SnActivityPubInstance(id: $id, domain: $domain, name: $name, description: $description, software: $software, version: $version, iconUrl: $iconUrl, thumbnailUrl: $thumbnailUrl, contactEmail: $contactEmail, contactAccountUsername: $contactAccountUsername, activeUsers: $activeUsers, isBlocked: $isBlocked, isSilenced: $isSilenced, blockReason: $blockReason, metadata: $metadata, lastFetchedAt: $lastFetchedAt, lastActivityAt: $lastActivityAt, metadataFetchedAt: $metadataFetchedAt)';
}


}

/// @nodoc
abstract mixin class _$SnActivityPubInstanceCopyWith<$Res> implements $SnActivityPubInstanceCopyWith<$Res> {
  factory _$SnActivityPubInstanceCopyWith(_SnActivityPubInstance value, $Res Function(_SnActivityPubInstance) _then) = __$SnActivityPubInstanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String domain, String? name, String? description, String? software, String? version, String? iconUrl, String? thumbnailUrl, String? contactEmail, String? contactAccountUsername, int? activeUsers, bool isBlocked, bool isSilenced, String? blockReason, Map<String, dynamic>? metadata, DateTime? lastFetchedAt, DateTime? lastActivityAt, DateTime? metadataFetchedAt
});




}
/// @nodoc
class __$SnActivityPubInstanceCopyWithImpl<$Res>
    implements _$SnActivityPubInstanceCopyWith<$Res> {
  __$SnActivityPubInstanceCopyWithImpl(this._self, this._then);

  final _SnActivityPubInstance _self;
  final $Res Function(_SnActivityPubInstance) _then;

/// Create a copy of SnActivityPubInstance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? domain = null,Object? name = freezed,Object? description = freezed,Object? software = freezed,Object? version = freezed,Object? iconUrl = freezed,Object? thumbnailUrl = freezed,Object? contactEmail = freezed,Object? contactAccountUsername = freezed,Object? activeUsers = freezed,Object? isBlocked = null,Object? isSilenced = null,Object? blockReason = freezed,Object? metadata = freezed,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,Object? metadataFetchedAt = freezed,}) {
  return _then(_SnActivityPubInstance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,software: freezed == software ? _self.software : software // ignore: cast_nullable_to_non_nullable
as String?,version: freezed == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,contactEmail: freezed == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String?,contactAccountUsername: freezed == contactAccountUsername ? _self.contactAccountUsername : contactAccountUsername // ignore: cast_nullable_to_non_nullable
as String?,activeUsers: freezed == activeUsers ? _self.activeUsers : activeUsers // ignore: cast_nullable_to_non_nullable
as int?,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,isSilenced: null == isSilenced ? _self.isSilenced : isSilenced // ignore: cast_nullable_to_non_nullable
as bool,blockReason: freezed == blockReason ? _self.blockReason : blockReason // ignore: cast_nullable_to_non_nullable
as String?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadataFetchedAt: freezed == metadataFetchedAt ? _self.metadataFetchedAt : metadataFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnActivityPubUser {

 String get actorUri; String get username; String get displayName; String get bio; String get avatarUrl; DateTime get followedAt; bool get isLocal; String get instanceDomain;
/// Create a copy of SnActivityPubUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActivityPubUserCopyWith<SnActivityPubUser> get copyWith => _$SnActivityPubUserCopyWithImpl<SnActivityPubUser>(this as SnActivityPubUser, _$identity);

  /// Serializes this SnActivityPubUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActivityPubUser&&(identical(other.actorUri, actorUri) || other.actorUri == actorUri)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt)&&(identical(other.isLocal, isLocal) || other.isLocal == isLocal)&&(identical(other.instanceDomain, instanceDomain) || other.instanceDomain == instanceDomain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actorUri,username,displayName,bio,avatarUrl,followedAt,isLocal,instanceDomain);

@override
String toString() {
  return 'SnActivityPubUser(actorUri: $actorUri, username: $username, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, followedAt: $followedAt, isLocal: $isLocal, instanceDomain: $instanceDomain)';
}


}

/// @nodoc
abstract mixin class $SnActivityPubUserCopyWith<$Res>  {
  factory $SnActivityPubUserCopyWith(SnActivityPubUser value, $Res Function(SnActivityPubUser) _then) = _$SnActivityPubUserCopyWithImpl;
@useResult
$Res call({
 String actorUri, String username, String displayName, String bio, String avatarUrl, DateTime followedAt, bool isLocal, String instanceDomain
});




}
/// @nodoc
class _$SnActivityPubUserCopyWithImpl<$Res>
    implements $SnActivityPubUserCopyWith<$Res> {
  _$SnActivityPubUserCopyWithImpl(this._self, this._then);

  final SnActivityPubUser _self;
  final $Res Function(SnActivityPubUser) _then;

/// Create a copy of SnActivityPubUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? actorUri = null,Object? username = null,Object? displayName = null,Object? bio = null,Object? avatarUrl = null,Object? followedAt = null,Object? isLocal = null,Object? instanceDomain = null,}) {
  return _then(_self.copyWith(
actorUri: null == actorUri ? _self.actorUri : actorUri // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,followedAt: null == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isLocal: null == isLocal ? _self.isLocal : isLocal // ignore: cast_nullable_to_non_nullable
as bool,instanceDomain: null == instanceDomain ? _self.instanceDomain : instanceDomain // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnActivityPubUser].
extension SnActivityPubUserPatterns on SnActivityPubUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnActivityPubUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnActivityPubUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnActivityPubUser value)  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnActivityPubUser value)?  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String actorUri,  String username,  String displayName,  String bio,  String avatarUrl,  DateTime followedAt,  bool isLocal,  String instanceDomain)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActivityPubUser() when $default != null:
return $default(_that.actorUri,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.followedAt,_that.isLocal,_that.instanceDomain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String actorUri,  String username,  String displayName,  String bio,  String avatarUrl,  DateTime followedAt,  bool isLocal,  String instanceDomain)  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubUser():
return $default(_that.actorUri,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.followedAt,_that.isLocal,_that.instanceDomain);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String actorUri,  String username,  String displayName,  String bio,  String avatarUrl,  DateTime followedAt,  bool isLocal,  String instanceDomain)?  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubUser() when $default != null:
return $default(_that.actorUri,_that.username,_that.displayName,_that.bio,_that.avatarUrl,_that.followedAt,_that.isLocal,_that.instanceDomain);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActivityPubUser implements SnActivityPubUser {
  const _SnActivityPubUser({required this.actorUri, required this.username, required this.displayName, required this.bio, required this.avatarUrl, required this.followedAt, required this.isLocal, required this.instanceDomain});
  factory _SnActivityPubUser.fromJson(Map<String, dynamic> json) => _$SnActivityPubUserFromJson(json);

@override final  String actorUri;
@override final  String username;
@override final  String displayName;
@override final  String bio;
@override final  String avatarUrl;
@override final  DateTime followedAt;
@override final  bool isLocal;
@override final  String instanceDomain;

/// Create a copy of SnActivityPubUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnActivityPubUserCopyWith<_SnActivityPubUser> get copyWith => __$SnActivityPubUserCopyWithImpl<_SnActivityPubUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnActivityPubUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActivityPubUser&&(identical(other.actorUri, actorUri) || other.actorUri == actorUri)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.followedAt, followedAt) || other.followedAt == followedAt)&&(identical(other.isLocal, isLocal) || other.isLocal == isLocal)&&(identical(other.instanceDomain, instanceDomain) || other.instanceDomain == instanceDomain));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,actorUri,username,displayName,bio,avatarUrl,followedAt,isLocal,instanceDomain);

@override
String toString() {
  return 'SnActivityPubUser(actorUri: $actorUri, username: $username, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, followedAt: $followedAt, isLocal: $isLocal, instanceDomain: $instanceDomain)';
}


}

/// @nodoc
abstract mixin class _$SnActivityPubUserCopyWith<$Res> implements $SnActivityPubUserCopyWith<$Res> {
  factory _$SnActivityPubUserCopyWith(_SnActivityPubUser value, $Res Function(_SnActivityPubUser) _then) = __$SnActivityPubUserCopyWithImpl;
@override @useResult
$Res call({
 String actorUri, String username, String displayName, String bio, String avatarUrl, DateTime followedAt, bool isLocal, String instanceDomain
});




}
/// @nodoc
class __$SnActivityPubUserCopyWithImpl<$Res>
    implements _$SnActivityPubUserCopyWith<$Res> {
  __$SnActivityPubUserCopyWithImpl(this._self, this._then);

  final _SnActivityPubUser _self;
  final $Res Function(_SnActivityPubUser) _then;

/// Create a copy of SnActivityPubUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? actorUri = null,Object? username = null,Object? displayName = null,Object? bio = null,Object? avatarUrl = null,Object? followedAt = null,Object? isLocal = null,Object? instanceDomain = null,}) {
  return _then(_SnActivityPubUser(
actorUri: null == actorUri ? _self.actorUri : actorUri // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,followedAt: null == followedAt ? _self.followedAt : followedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isLocal: null == isLocal ? _self.isLocal : isLocal // ignore: cast_nullable_to_non_nullable
as bool,instanceDomain: null == instanceDomain ? _self.instanceDomain : instanceDomain // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnActivityPubActor {

 String get id; String get uri; String get type; String? get displayName; String? get username; String? get summary; String? get inboxUri; String? get outboxUri; String? get followersUri; String? get followingUri; String? get featuredUri; String? get avatarUrl; String? get headerUrl; String? get publicKeyId; String? get publicKey; bool get isBot; bool get isLocked; bool get discoverable; bool get manuallyApprovesFollowers; Map<String, dynamic>? get endpoints; Map<String, dynamic>? get publicKeyData; Map<String, dynamic>? get metadata; DateTime? get lastFetchedAt; DateTime? get lastActivityAt; SnActivityPubInstance get instance; String get instanceId;
/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<SnActivityPubActor> get copyWith => _$SnActivityPubActorCopyWithImpl<SnActivityPubActor>(this as SnActivityPubActor, _$identity);

  /// Serializes this SnActivityPubActor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActivityPubActor&&(identical(other.id, id) || other.id == id)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.inboxUri, inboxUri) || other.inboxUri == inboxUri)&&(identical(other.outboxUri, outboxUri) || other.outboxUri == outboxUri)&&(identical(other.followersUri, followersUri) || other.followersUri == followersUri)&&(identical(other.followingUri, followingUri) || other.followingUri == followingUri)&&(identical(other.featuredUri, featuredUri) || other.featuredUri == featuredUri)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.headerUrl, headerUrl) || other.headerUrl == headerUrl)&&(identical(other.publicKeyId, publicKeyId) || other.publicKeyId == publicKeyId)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.discoverable, discoverable) || other.discoverable == discoverable)&&(identical(other.manuallyApprovesFollowers, manuallyApprovesFollowers) || other.manuallyApprovesFollowers == manuallyApprovesFollowers)&&const DeepCollectionEquality().equals(other.endpoints, endpoints)&&const DeepCollectionEquality().equals(other.publicKeyData, publicKeyData)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.instance, instance) || other.instance == instance)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,uri,type,displayName,username,summary,inboxUri,outboxUri,followersUri,followingUri,featuredUri,avatarUrl,headerUrl,publicKeyId,publicKey,isBot,isLocked,discoverable,manuallyApprovesFollowers,const DeepCollectionEquality().hash(endpoints),const DeepCollectionEquality().hash(publicKeyData),const DeepCollectionEquality().hash(metadata),lastFetchedAt,lastActivityAt,instance,instanceId]);

@override
String toString() {
  return 'SnActivityPubActor(id: $id, uri: $uri, type: $type, displayName: $displayName, username: $username, summary: $summary, inboxUri: $inboxUri, outboxUri: $outboxUri, followersUri: $followersUri, followingUri: $followingUri, featuredUri: $featuredUri, avatarUrl: $avatarUrl, headerUrl: $headerUrl, publicKeyId: $publicKeyId, publicKey: $publicKey, isBot: $isBot, isLocked: $isLocked, discoverable: $discoverable, manuallyApprovesFollowers: $manuallyApprovesFollowers, endpoints: $endpoints, publicKeyData: $publicKeyData, metadata: $metadata, lastFetchedAt: $lastFetchedAt, lastActivityAt: $lastActivityAt, instance: $instance, instanceId: $instanceId)';
}


}

/// @nodoc
abstract mixin class $SnActivityPubActorCopyWith<$Res>  {
  factory $SnActivityPubActorCopyWith(SnActivityPubActor value, $Res Function(SnActivityPubActor) _then) = _$SnActivityPubActorCopyWithImpl;
@useResult
$Res call({
 String id, String uri, String type, String? displayName, String? username, String? summary, String? inboxUri, String? outboxUri, String? followersUri, String? followingUri, String? featuredUri, String? avatarUrl, String? headerUrl, String? publicKeyId, String? publicKey, bool isBot, bool isLocked, bool discoverable, bool manuallyApprovesFollowers, Map<String, dynamic>? endpoints, Map<String, dynamic>? publicKeyData, Map<String, dynamic>? metadata, DateTime? lastFetchedAt, DateTime? lastActivityAt, SnActivityPubInstance instance, String instanceId
});


$SnActivityPubInstanceCopyWith<$Res> get instance;

}
/// @nodoc
class _$SnActivityPubActorCopyWithImpl<$Res>
    implements $SnActivityPubActorCopyWith<$Res> {
  _$SnActivityPubActorCopyWithImpl(this._self, this._then);

  final SnActivityPubActor _self;
  final $Res Function(SnActivityPubActor) _then;

/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uri = null,Object? type = null,Object? displayName = freezed,Object? username = freezed,Object? summary = freezed,Object? inboxUri = freezed,Object? outboxUri = freezed,Object? followersUri = freezed,Object? followingUri = freezed,Object? featuredUri = freezed,Object? avatarUrl = freezed,Object? headerUrl = freezed,Object? publicKeyId = freezed,Object? publicKey = freezed,Object? isBot = null,Object? isLocked = null,Object? discoverable = null,Object? manuallyApprovesFollowers = null,Object? endpoints = freezed,Object? publicKeyData = freezed,Object? metadata = freezed,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,Object? instance = null,Object? instanceId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,inboxUri: freezed == inboxUri ? _self.inboxUri : inboxUri // ignore: cast_nullable_to_non_nullable
as String?,outboxUri: freezed == outboxUri ? _self.outboxUri : outboxUri // ignore: cast_nullable_to_non_nullable
as String?,followersUri: freezed == followersUri ? _self.followersUri : followersUri // ignore: cast_nullable_to_non_nullable
as String?,followingUri: freezed == followingUri ? _self.followingUri : followingUri // ignore: cast_nullable_to_non_nullable
as String?,featuredUri: freezed == featuredUri ? _self.featuredUri : featuredUri // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,headerUrl: freezed == headerUrl ? _self.headerUrl : headerUrl // ignore: cast_nullable_to_non_nullable
as String?,publicKeyId: freezed == publicKeyId ? _self.publicKeyId : publicKeyId // ignore: cast_nullable_to_non_nullable
as String?,publicKey: freezed == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,discoverable: null == discoverable ? _self.discoverable : discoverable // ignore: cast_nullable_to_non_nullable
as bool,manuallyApprovesFollowers: null == manuallyApprovesFollowers ? _self.manuallyApprovesFollowers : manuallyApprovesFollowers // ignore: cast_nullable_to_non_nullable
as bool,endpoints: freezed == endpoints ? _self.endpoints : endpoints // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,publicKeyData: freezed == publicKeyData ? _self.publicKeyData : publicKeyData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,instance: null == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as SnActivityPubInstance,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubInstanceCopyWith<$Res> get instance {
  
  return $SnActivityPubInstanceCopyWith<$Res>(_self.instance, (value) {
    return _then(_self.copyWith(instance: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnActivityPubActor].
extension SnActivityPubActorPatterns on SnActivityPubActor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnActivityPubActor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnActivityPubActor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnActivityPubActor value)  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubActor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnActivityPubActor value)?  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubActor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String uri,  String type,  String? displayName,  String? username,  String? summary,  String? inboxUri,  String? outboxUri,  String? followersUri,  String? followingUri,  String? featuredUri,  String? avatarUrl,  String? headerUrl,  String? publicKeyId,  String? publicKey,  bool isBot,  bool isLocked,  bool discoverable,  bool manuallyApprovesFollowers,  Map<String, dynamic>? endpoints,  Map<String, dynamic>? publicKeyData,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  SnActivityPubInstance instance,  String instanceId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActivityPubActor() when $default != null:
return $default(_that.id,_that.uri,_that.type,_that.displayName,_that.username,_that.summary,_that.inboxUri,_that.outboxUri,_that.followersUri,_that.followingUri,_that.featuredUri,_that.avatarUrl,_that.headerUrl,_that.publicKeyId,_that.publicKey,_that.isBot,_that.isLocked,_that.discoverable,_that.manuallyApprovesFollowers,_that.endpoints,_that.publicKeyData,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt,_that.instance,_that.instanceId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String uri,  String type,  String? displayName,  String? username,  String? summary,  String? inboxUri,  String? outboxUri,  String? followersUri,  String? followingUri,  String? featuredUri,  String? avatarUrl,  String? headerUrl,  String? publicKeyId,  String? publicKey,  bool isBot,  bool isLocked,  bool discoverable,  bool manuallyApprovesFollowers,  Map<String, dynamic>? endpoints,  Map<String, dynamic>? publicKeyData,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  SnActivityPubInstance instance,  String instanceId)  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubActor():
return $default(_that.id,_that.uri,_that.type,_that.displayName,_that.username,_that.summary,_that.inboxUri,_that.outboxUri,_that.followersUri,_that.followingUri,_that.featuredUri,_that.avatarUrl,_that.headerUrl,_that.publicKeyId,_that.publicKey,_that.isBot,_that.isLocked,_that.discoverable,_that.manuallyApprovesFollowers,_that.endpoints,_that.publicKeyData,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt,_that.instance,_that.instanceId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String uri,  String type,  String? displayName,  String? username,  String? summary,  String? inboxUri,  String? outboxUri,  String? followersUri,  String? followingUri,  String? featuredUri,  String? avatarUrl,  String? headerUrl,  String? publicKeyId,  String? publicKey,  bool isBot,  bool isLocked,  bool discoverable,  bool manuallyApprovesFollowers,  Map<String, dynamic>? endpoints,  Map<String, dynamic>? publicKeyData,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt,  SnActivityPubInstance instance,  String instanceId)?  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubActor() when $default != null:
return $default(_that.id,_that.uri,_that.type,_that.displayName,_that.username,_that.summary,_that.inboxUri,_that.outboxUri,_that.followersUri,_that.followingUri,_that.featuredUri,_that.avatarUrl,_that.headerUrl,_that.publicKeyId,_that.publicKey,_that.isBot,_that.isLocked,_that.discoverable,_that.manuallyApprovesFollowers,_that.endpoints,_that.publicKeyData,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt,_that.instance,_that.instanceId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActivityPubActor implements SnActivityPubActor {
  const _SnActivityPubActor({required this.id, required this.uri, this.type = '', this.displayName, this.username, this.summary, this.inboxUri, this.outboxUri, this.followersUri, this.followingUri, this.featuredUri, this.avatarUrl, this.headerUrl, this.publicKeyId, this.publicKey, this.isBot = false, this.isLocked = false, this.discoverable = true, this.manuallyApprovesFollowers = false, final  Map<String, dynamic>? endpoints, final  Map<String, dynamic>? publicKeyData, final  Map<String, dynamic>? metadata, this.lastFetchedAt, this.lastActivityAt, required this.instance, required this.instanceId}): _endpoints = endpoints,_publicKeyData = publicKeyData,_metadata = metadata;
  factory _SnActivityPubActor.fromJson(Map<String, dynamic> json) => _$SnActivityPubActorFromJson(json);

@override final  String id;
@override final  String uri;
@override@JsonKey() final  String type;
@override final  String? displayName;
@override final  String? username;
@override final  String? summary;
@override final  String? inboxUri;
@override final  String? outboxUri;
@override final  String? followersUri;
@override final  String? followingUri;
@override final  String? featuredUri;
@override final  String? avatarUrl;
@override final  String? headerUrl;
@override final  String? publicKeyId;
@override final  String? publicKey;
@override@JsonKey() final  bool isBot;
@override@JsonKey() final  bool isLocked;
@override@JsonKey() final  bool discoverable;
@override@JsonKey() final  bool manuallyApprovesFollowers;
 final  Map<String, dynamic>? _endpoints;
@override Map<String, dynamic>? get endpoints {
  final value = _endpoints;
  if (value == null) return null;
  if (_endpoints is EqualUnmodifiableMapView) return _endpoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _publicKeyData;
@override Map<String, dynamic>? get publicKeyData {
  final value = _publicKeyData;
  if (value == null) return null;
  if (_publicKeyData is EqualUnmodifiableMapView) return _publicKeyData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? lastFetchedAt;
@override final  DateTime? lastActivityAt;
@override final  SnActivityPubInstance instance;
@override final  String instanceId;

/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnActivityPubActorCopyWith<_SnActivityPubActor> get copyWith => __$SnActivityPubActorCopyWithImpl<_SnActivityPubActor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnActivityPubActorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActivityPubActor&&(identical(other.id, id) || other.id == id)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.inboxUri, inboxUri) || other.inboxUri == inboxUri)&&(identical(other.outboxUri, outboxUri) || other.outboxUri == outboxUri)&&(identical(other.followersUri, followersUri) || other.followersUri == followersUri)&&(identical(other.followingUri, followingUri) || other.followingUri == followingUri)&&(identical(other.featuredUri, featuredUri) || other.featuredUri == featuredUri)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.headerUrl, headerUrl) || other.headerUrl == headerUrl)&&(identical(other.publicKeyId, publicKeyId) || other.publicKeyId == publicKeyId)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.discoverable, discoverable) || other.discoverable == discoverable)&&(identical(other.manuallyApprovesFollowers, manuallyApprovesFollowers) || other.manuallyApprovesFollowers == manuallyApprovesFollowers)&&const DeepCollectionEquality().equals(other._endpoints, _endpoints)&&const DeepCollectionEquality().equals(other._publicKeyData, _publicKeyData)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.instance, instance) || other.instance == instance)&&(identical(other.instanceId, instanceId) || other.instanceId == instanceId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,uri,type,displayName,username,summary,inboxUri,outboxUri,followersUri,followingUri,featuredUri,avatarUrl,headerUrl,publicKeyId,publicKey,isBot,isLocked,discoverable,manuallyApprovesFollowers,const DeepCollectionEquality().hash(_endpoints),const DeepCollectionEquality().hash(_publicKeyData),const DeepCollectionEquality().hash(_metadata),lastFetchedAt,lastActivityAt,instance,instanceId]);

@override
String toString() {
  return 'SnActivityPubActor(id: $id, uri: $uri, type: $type, displayName: $displayName, username: $username, summary: $summary, inboxUri: $inboxUri, outboxUri: $outboxUri, followersUri: $followersUri, followingUri: $followingUri, featuredUri: $featuredUri, avatarUrl: $avatarUrl, headerUrl: $headerUrl, publicKeyId: $publicKeyId, publicKey: $publicKey, isBot: $isBot, isLocked: $isLocked, discoverable: $discoverable, manuallyApprovesFollowers: $manuallyApprovesFollowers, endpoints: $endpoints, publicKeyData: $publicKeyData, metadata: $metadata, lastFetchedAt: $lastFetchedAt, lastActivityAt: $lastActivityAt, instance: $instance, instanceId: $instanceId)';
}


}

/// @nodoc
abstract mixin class _$SnActivityPubActorCopyWith<$Res> implements $SnActivityPubActorCopyWith<$Res> {
  factory _$SnActivityPubActorCopyWith(_SnActivityPubActor value, $Res Function(_SnActivityPubActor) _then) = __$SnActivityPubActorCopyWithImpl;
@override @useResult
$Res call({
 String id, String uri, String type, String? displayName, String? username, String? summary, String? inboxUri, String? outboxUri, String? followersUri, String? followingUri, String? featuredUri, String? avatarUrl, String? headerUrl, String? publicKeyId, String? publicKey, bool isBot, bool isLocked, bool discoverable, bool manuallyApprovesFollowers, Map<String, dynamic>? endpoints, Map<String, dynamic>? publicKeyData, Map<String, dynamic>? metadata, DateTime? lastFetchedAt, DateTime? lastActivityAt, SnActivityPubInstance instance, String instanceId
});


@override $SnActivityPubInstanceCopyWith<$Res> get instance;

}
/// @nodoc
class __$SnActivityPubActorCopyWithImpl<$Res>
    implements _$SnActivityPubActorCopyWith<$Res> {
  __$SnActivityPubActorCopyWithImpl(this._self, this._then);

  final _SnActivityPubActor _self;
  final $Res Function(_SnActivityPubActor) _then;

/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uri = null,Object? type = null,Object? displayName = freezed,Object? username = freezed,Object? summary = freezed,Object? inboxUri = freezed,Object? outboxUri = freezed,Object? followersUri = freezed,Object? followingUri = freezed,Object? featuredUri = freezed,Object? avatarUrl = freezed,Object? headerUrl = freezed,Object? publicKeyId = freezed,Object? publicKey = freezed,Object? isBot = null,Object? isLocked = null,Object? discoverable = null,Object? manuallyApprovesFollowers = null,Object? endpoints = freezed,Object? publicKeyData = freezed,Object? metadata = freezed,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,Object? instance = null,Object? instanceId = null,}) {
  return _then(_SnActivityPubActor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,inboxUri: freezed == inboxUri ? _self.inboxUri : inboxUri // ignore: cast_nullable_to_non_nullable
as String?,outboxUri: freezed == outboxUri ? _self.outboxUri : outboxUri // ignore: cast_nullable_to_non_nullable
as String?,followersUri: freezed == followersUri ? _self.followersUri : followersUri // ignore: cast_nullable_to_non_nullable
as String?,followingUri: freezed == followingUri ? _self.followingUri : followingUri // ignore: cast_nullable_to_non_nullable
as String?,featuredUri: freezed == featuredUri ? _self.featuredUri : featuredUri // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,headerUrl: freezed == headerUrl ? _self.headerUrl : headerUrl // ignore: cast_nullable_to_non_nullable
as String?,publicKeyId: freezed == publicKeyId ? _self.publicKeyId : publicKeyId // ignore: cast_nullable_to_non_nullable
as String?,publicKey: freezed == publicKey ? _self.publicKey : publicKey // ignore: cast_nullable_to_non_nullable
as String?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,discoverable: null == discoverable ? _self.discoverable : discoverable // ignore: cast_nullable_to_non_nullable
as bool,manuallyApprovesFollowers: null == manuallyApprovesFollowers ? _self.manuallyApprovesFollowers : manuallyApprovesFollowers // ignore: cast_nullable_to_non_nullable
as bool,endpoints: freezed == endpoints ? _self._endpoints : endpoints // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,publicKeyData: freezed == publicKeyData ? _self._publicKeyData : publicKeyData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,instance: null == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as SnActivityPubInstance,instanceId: null == instanceId ? _self.instanceId : instanceId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubInstanceCopyWith<$Res> get instance {
  
  return $SnActivityPubInstanceCopyWith<$Res>(_self.instance, (value) {
    return _then(_self.copyWith(instance: value));
  });
}
}


/// @nodoc
mixin _$SnActivityPubFollowResponse {

 bool get success; String get message; String get targetActorUri;
/// Create a copy of SnActivityPubFollowResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActivityPubFollowResponseCopyWith<SnActivityPubFollowResponse> get copyWith => _$SnActivityPubFollowResponseCopyWithImpl<SnActivityPubFollowResponse>(this as SnActivityPubFollowResponse, _$identity);

  /// Serializes this SnActivityPubFollowResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActivityPubFollowResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.targetActorUri, targetActorUri) || other.targetActorUri == targetActorUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,targetActorUri);

@override
String toString() {
  return 'SnActivityPubFollowResponse(success: $success, message: $message, targetActorUri: $targetActorUri)';
}


}

/// @nodoc
abstract mixin class $SnActivityPubFollowResponseCopyWith<$Res>  {
  factory $SnActivityPubFollowResponseCopyWith(SnActivityPubFollowResponse value, $Res Function(SnActivityPubFollowResponse) _then) = _$SnActivityPubFollowResponseCopyWithImpl;
@useResult
$Res call({
 bool success, String message, String targetActorUri
});




}
/// @nodoc
class _$SnActivityPubFollowResponseCopyWithImpl<$Res>
    implements $SnActivityPubFollowResponseCopyWith<$Res> {
  _$SnActivityPubFollowResponseCopyWithImpl(this._self, this._then);

  final SnActivityPubFollowResponse _self;
  final $Res Function(SnActivityPubFollowResponse) _then;

/// Create a copy of SnActivityPubFollowResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = null,Object? targetActorUri = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,targetActorUri: null == targetActorUri ? _self.targetActorUri : targetActorUri // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnActivityPubFollowResponse].
extension SnActivityPubFollowResponsePatterns on SnActivityPubFollowResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnActivityPubFollowResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnActivityPubFollowResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnActivityPubFollowResponse value)  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubFollowResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnActivityPubFollowResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SnActivityPubFollowResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String message,  String targetActorUri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActivityPubFollowResponse() when $default != null:
return $default(_that.success,_that.message,_that.targetActorUri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String message,  String targetActorUri)  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubFollowResponse():
return $default(_that.success,_that.message,_that.targetActorUri);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String message,  String targetActorUri)?  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubFollowResponse() when $default != null:
return $default(_that.success,_that.message,_that.targetActorUri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActivityPubFollowResponse implements SnActivityPubFollowResponse {
  const _SnActivityPubFollowResponse({required this.success, required this.message, required this.targetActorUri});
  factory _SnActivityPubFollowResponse.fromJson(Map<String, dynamic> json) => _$SnActivityPubFollowResponseFromJson(json);

@override final  bool success;
@override final  String message;
@override final  String targetActorUri;

/// Create a copy of SnActivityPubFollowResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnActivityPubFollowResponseCopyWith<_SnActivityPubFollowResponse> get copyWith => __$SnActivityPubFollowResponseCopyWithImpl<_SnActivityPubFollowResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnActivityPubFollowResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActivityPubFollowResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message)&&(identical(other.targetActorUri, targetActorUri) || other.targetActorUri == targetActorUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message,targetActorUri);

@override
String toString() {
  return 'SnActivityPubFollowResponse(success: $success, message: $message, targetActorUri: $targetActorUri)';
}


}

/// @nodoc
abstract mixin class _$SnActivityPubFollowResponseCopyWith<$Res> implements $SnActivityPubFollowResponseCopyWith<$Res> {
  factory _$SnActivityPubFollowResponseCopyWith(_SnActivityPubFollowResponse value, $Res Function(_SnActivityPubFollowResponse) _then) = __$SnActivityPubFollowResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, String message, String targetActorUri
});




}
/// @nodoc
class __$SnActivityPubFollowResponseCopyWithImpl<$Res>
    implements _$SnActivityPubFollowResponseCopyWith<$Res> {
  __$SnActivityPubFollowResponseCopyWithImpl(this._self, this._then);

  final _SnActivityPubFollowResponse _self;
  final $Res Function(_SnActivityPubFollowResponse) _then;

/// Create a copy of SnActivityPubFollowResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = null,Object? targetActorUri = null,}) {
  return _then(_SnActivityPubFollowResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,targetActorUri: null == targetActorUri ? _self.targetActorUri : targetActorUri // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
