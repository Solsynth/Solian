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

 String get id; String get username; String get instanceDomain; SnActivityPubInstance get instance; String get type; String? get displayName; String? get bio; String? get avatarUrl; String? get headerUrl; String? get webUrl; bool get isBot; bool get isLocked; bool get isDiscoverable; int get followersCount; int get followingCount; DateTime? get lastActivityAt; DateTime? get lastFetchedAt; Map<String, dynamic>? get metadata; bool? get isFollowing;
/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<SnActivityPubActor> get copyWith => _$SnActivityPubActorCopyWithImpl<SnActivityPubActor>(this as SnActivityPubActor, _$identity);

  /// Serializes this SnActivityPubActor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActivityPubActor&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.instanceDomain, instanceDomain) || other.instanceDomain == instanceDomain)&&(identical(other.instance, instance) || other.instance == instance)&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.headerUrl, headerUrl) || other.headerUrl == headerUrl)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isDiscoverable, isDiscoverable) || other.isDiscoverable == isDiscoverable)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,username,instanceDomain,instance,type,displayName,bio,avatarUrl,headerUrl,webUrl,isBot,isLocked,isDiscoverable,followersCount,followingCount,lastActivityAt,lastFetchedAt,const DeepCollectionEquality().hash(metadata),isFollowing]);

@override
String toString() {
  return 'SnActivityPubActor(id: $id, username: $username, instanceDomain: $instanceDomain, instance: $instance, type: $type, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, headerUrl: $headerUrl, webUrl: $webUrl, isBot: $isBot, isLocked: $isLocked, isDiscoverable: $isDiscoverable, followersCount: $followersCount, followingCount: $followingCount, lastActivityAt: $lastActivityAt, lastFetchedAt: $lastFetchedAt, metadata: $metadata, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class $SnActivityPubActorCopyWith<$Res>  {
  factory $SnActivityPubActorCopyWith(SnActivityPubActor value, $Res Function(SnActivityPubActor) _then) = _$SnActivityPubActorCopyWithImpl;
@useResult
$Res call({
 String id, String username, String instanceDomain, SnActivityPubInstance instance, String type, String? displayName, String? bio, String? avatarUrl, String? headerUrl, String? webUrl, bool isBot, bool isLocked, bool isDiscoverable, int followersCount, int followingCount, DateTime? lastActivityAt, DateTime? lastFetchedAt, Map<String, dynamic>? metadata, bool? isFollowing
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? instanceDomain = null,Object? instance = null,Object? type = null,Object? displayName = freezed,Object? bio = freezed,Object? avatarUrl = freezed,Object? headerUrl = freezed,Object? webUrl = freezed,Object? isBot = null,Object? isLocked = null,Object? isDiscoverable = null,Object? followersCount = null,Object? followingCount = null,Object? lastActivityAt = freezed,Object? lastFetchedAt = freezed,Object? metadata = freezed,Object? isFollowing = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,instanceDomain: null == instanceDomain ? _self.instanceDomain : instanceDomain // ignore: cast_nullable_to_non_nullable
as String,instance: null == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as SnActivityPubInstance,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,headerUrl: freezed == headerUrl ? _self.headerUrl : headerUrl // ignore: cast_nullable_to_non_nullable
as String?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isDiscoverable: null == isDiscoverable ? _self.isDiscoverable : isDiscoverable // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isFollowing: freezed == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String instanceDomain,  SnActivityPubInstance instance,  String type,  String? displayName,  String? bio,  String? avatarUrl,  String? headerUrl,  String? webUrl,  bool isBot,  bool isLocked,  bool isDiscoverable,  int followersCount,  int followingCount,  DateTime? lastActivityAt,  DateTime? lastFetchedAt,  Map<String, dynamic>? metadata,  bool? isFollowing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActivityPubActor() when $default != null:
return $default(_that.id,_that.username,_that.instanceDomain,_that.instance,_that.type,_that.displayName,_that.bio,_that.avatarUrl,_that.headerUrl,_that.webUrl,_that.isBot,_that.isLocked,_that.isDiscoverable,_that.followersCount,_that.followingCount,_that.lastActivityAt,_that.lastFetchedAt,_that.metadata,_that.isFollowing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String instanceDomain,  SnActivityPubInstance instance,  String type,  String? displayName,  String? bio,  String? avatarUrl,  String? headerUrl,  String? webUrl,  bool isBot,  bool isLocked,  bool isDiscoverable,  int followersCount,  int followingCount,  DateTime? lastActivityAt,  DateTime? lastFetchedAt,  Map<String, dynamic>? metadata,  bool? isFollowing)  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubActor():
return $default(_that.id,_that.username,_that.instanceDomain,_that.instance,_that.type,_that.displayName,_that.bio,_that.avatarUrl,_that.headerUrl,_that.webUrl,_that.isBot,_that.isLocked,_that.isDiscoverable,_that.followersCount,_that.followingCount,_that.lastActivityAt,_that.lastFetchedAt,_that.metadata,_that.isFollowing);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String instanceDomain,  SnActivityPubInstance instance,  String type,  String? displayName,  String? bio,  String? avatarUrl,  String? headerUrl,  String? webUrl,  bool isBot,  bool isLocked,  bool isDiscoverable,  int followersCount,  int followingCount,  DateTime? lastActivityAt,  DateTime? lastFetchedAt,  Map<String, dynamic>? metadata,  bool? isFollowing)?  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubActor() when $default != null:
return $default(_that.id,_that.username,_that.instanceDomain,_that.instance,_that.type,_that.displayName,_that.bio,_that.avatarUrl,_that.headerUrl,_that.webUrl,_that.isBot,_that.isLocked,_that.isDiscoverable,_that.followersCount,_that.followingCount,_that.lastActivityAt,_that.lastFetchedAt,_that.metadata,_that.isFollowing);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActivityPubActor implements SnActivityPubActor {
  const _SnActivityPubActor({required this.id, required this.username, required this.instanceDomain, required this.instance, this.type = 'Person', this.displayName, this.bio, this.avatarUrl, this.headerUrl, this.webUrl, this.isBot = false, this.isLocked = false, this.isDiscoverable = true, this.followersCount = 0, this.followingCount = 0, this.lastActivityAt, this.lastFetchedAt, final  Map<String, dynamic>? metadata, this.isFollowing}): _metadata = metadata;
  factory _SnActivityPubActor.fromJson(Map<String, dynamic> json) => _$SnActivityPubActorFromJson(json);

@override final  String id;
@override final  String username;
@override final  String instanceDomain;
@override final  SnActivityPubInstance instance;
@override@JsonKey() final  String type;
@override final  String? displayName;
@override final  String? bio;
@override final  String? avatarUrl;
@override final  String? headerUrl;
@override final  String? webUrl;
@override@JsonKey() final  bool isBot;
@override@JsonKey() final  bool isLocked;
@override@JsonKey() final  bool isDiscoverable;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followingCount;
@override final  DateTime? lastActivityAt;
@override final  DateTime? lastFetchedAt;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  bool? isFollowing;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActivityPubActor&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.instanceDomain, instanceDomain) || other.instanceDomain == instanceDomain)&&(identical(other.instance, instance) || other.instance == instance)&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.headerUrl, headerUrl) || other.headerUrl == headerUrl)&&(identical(other.webUrl, webUrl) || other.webUrl == webUrl)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.isDiscoverable, isDiscoverable) || other.isDiscoverable == isDiscoverable)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,username,instanceDomain,instance,type,displayName,bio,avatarUrl,headerUrl,webUrl,isBot,isLocked,isDiscoverable,followersCount,followingCount,lastActivityAt,lastFetchedAt,const DeepCollectionEquality().hash(_metadata),isFollowing]);

@override
String toString() {
  return 'SnActivityPubActor(id: $id, username: $username, instanceDomain: $instanceDomain, instance: $instance, type: $type, displayName: $displayName, bio: $bio, avatarUrl: $avatarUrl, headerUrl: $headerUrl, webUrl: $webUrl, isBot: $isBot, isLocked: $isLocked, isDiscoverable: $isDiscoverable, followersCount: $followersCount, followingCount: $followingCount, lastActivityAt: $lastActivityAt, lastFetchedAt: $lastFetchedAt, metadata: $metadata, isFollowing: $isFollowing)';
}


}

/// @nodoc
abstract mixin class _$SnActivityPubActorCopyWith<$Res> implements $SnActivityPubActorCopyWith<$Res> {
  factory _$SnActivityPubActorCopyWith(_SnActivityPubActor value, $Res Function(_SnActivityPubActor) _then) = __$SnActivityPubActorCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String instanceDomain, SnActivityPubInstance instance, String type, String? displayName, String? bio, String? avatarUrl, String? headerUrl, String? webUrl, bool isBot, bool isLocked, bool isDiscoverable, int followersCount, int followingCount, DateTime? lastActivityAt, DateTime? lastFetchedAt, Map<String, dynamic>? metadata, bool? isFollowing
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? instanceDomain = null,Object? instance = null,Object? type = null,Object? displayName = freezed,Object? bio = freezed,Object? avatarUrl = freezed,Object? headerUrl = freezed,Object? webUrl = freezed,Object? isBot = null,Object? isLocked = null,Object? isDiscoverable = null,Object? followersCount = null,Object? followingCount = null,Object? lastActivityAt = freezed,Object? lastFetchedAt = freezed,Object? metadata = freezed,Object? isFollowing = freezed,}) {
  return _then(_SnActivityPubActor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,instanceDomain: null == instanceDomain ? _self.instanceDomain : instanceDomain // ignore: cast_nullable_to_non_nullable
as String,instance: null == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as SnActivityPubInstance,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,headerUrl: freezed == headerUrl ? _self.headerUrl : headerUrl // ignore: cast_nullable_to_non_nullable
as String?,webUrl: freezed == webUrl ? _self.webUrl : webUrl // ignore: cast_nullable_to_non_nullable
as String?,isBot: null == isBot ? _self.isBot : isBot // ignore: cast_nullable_to_non_nullable
as bool,isLocked: null == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool,isDiscoverable: null == isDiscoverable ? _self.isDiscoverable : isDiscoverable // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastFetchedAt: freezed == lastFetchedAt ? _self.lastFetchedAt : lastFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isFollowing: freezed == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool?,
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

 bool get success; String get message;
/// Create a copy of SnActivityPubFollowResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActivityPubFollowResponseCopyWith<SnActivityPubFollowResponse> get copyWith => _$SnActivityPubFollowResponseCopyWithImpl<SnActivityPubFollowResponse>(this as SnActivityPubFollowResponse, _$identity);

  /// Serializes this SnActivityPubFollowResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActivityPubFollowResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message);

@override
String toString() {
  return 'SnActivityPubFollowResponse(success: $success, message: $message)';
}


}

/// @nodoc
abstract mixin class $SnActivityPubFollowResponseCopyWith<$Res>  {
  factory $SnActivityPubFollowResponseCopyWith(SnActivityPubFollowResponse value, $Res Function(SnActivityPubFollowResponse) _then) = _$SnActivityPubFollowResponseCopyWithImpl;
@useResult
$Res call({
 bool success, String message
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
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? message = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActivityPubFollowResponse() when $default != null:
return $default(_that.success,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  String message)  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubFollowResponse():
return $default(_that.success,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  String message)?  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubFollowResponse() when $default != null:
return $default(_that.success,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActivityPubFollowResponse implements SnActivityPubFollowResponse {
  const _SnActivityPubFollowResponse({required this.success, required this.message});
  factory _SnActivityPubFollowResponse.fromJson(Map<String, dynamic> json) => _$SnActivityPubFollowResponseFromJson(json);

@override final  bool success;
@override final  String message;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActivityPubFollowResponse&&(identical(other.success, success) || other.success == success)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,message);

@override
String toString() {
  return 'SnActivityPubFollowResponse(success: $success, message: $message)';
}


}

/// @nodoc
abstract mixin class _$SnActivityPubFollowResponseCopyWith<$Res> implements $SnActivityPubFollowResponseCopyWith<$Res> {
  factory _$SnActivityPubFollowResponseCopyWith(_SnActivityPubFollowResponse value, $Res Function(_SnActivityPubFollowResponse) _then) = __$SnActivityPubFollowResponseCopyWithImpl;
@override @useResult
$Res call({
 bool success, String message
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
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? message = null,}) {
  return _then(_SnActivityPubFollowResponse(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnActorStatusResponse {

 bool get enabled; int get followerCount; SnActivityPubActor? get actor; String? get actorUri;
/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActorStatusResponseCopyWith<SnActorStatusResponse> get copyWith => _$SnActorStatusResponseCopyWithImpl<SnActorStatusResponse>(this as SnActorStatusResponse, _$identity);

  /// Serializes this SnActorStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActorStatusResponse&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.actorUri, actorUri) || other.actorUri == actorUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,followerCount,actor,actorUri);

@override
String toString() {
  return 'SnActorStatusResponse(enabled: $enabled, followerCount: $followerCount, actor: $actor, actorUri: $actorUri)';
}


}

/// @nodoc
abstract mixin class $SnActorStatusResponseCopyWith<$Res>  {
  factory $SnActorStatusResponseCopyWith(SnActorStatusResponse value, $Res Function(SnActorStatusResponse) _then) = _$SnActorStatusResponseCopyWithImpl;
@useResult
$Res call({
 bool enabled, int followerCount, SnActivityPubActor? actor, String? actorUri
});


$SnActivityPubActorCopyWith<$Res>? get actor;

}
/// @nodoc
class _$SnActorStatusResponseCopyWithImpl<$Res>
    implements $SnActorStatusResponseCopyWith<$Res> {
  _$SnActorStatusResponseCopyWithImpl(this._self, this._then);

  final SnActorStatusResponse _self;
  final $Res Function(SnActorStatusResponse) _then;

/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? followerCount = null,Object? actor = freezed,Object? actorUri = freezed,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as SnActivityPubActor?,actorUri: freezed == actorUri ? _self.actorUri : actorUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $SnActivityPubActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnActorStatusResponse].
extension SnActorStatusResponsePatterns on SnActorStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnActorStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnActorStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnActorStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _SnActorStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnActorStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _SnActorStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int followerCount,  SnActivityPubActor? actor,  String? actorUri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActorStatusResponse() when $default != null:
return $default(_that.enabled,_that.followerCount,_that.actor,_that.actorUri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int followerCount,  SnActivityPubActor? actor,  String? actorUri)  $default,) {final _that = this;
switch (_that) {
case _SnActorStatusResponse():
return $default(_that.enabled,_that.followerCount,_that.actor,_that.actorUri);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int followerCount,  SnActivityPubActor? actor,  String? actorUri)?  $default,) {final _that = this;
switch (_that) {
case _SnActorStatusResponse() when $default != null:
return $default(_that.enabled,_that.followerCount,_that.actor,_that.actorUri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActorStatusResponse implements SnActorStatusResponse {
  const _SnActorStatusResponse({required this.enabled, this.followerCount = 0, this.actor, this.actorUri});
  factory _SnActorStatusResponse.fromJson(Map<String, dynamic> json) => _$SnActorStatusResponseFromJson(json);

@override final  bool enabled;
@override@JsonKey() final  int followerCount;
@override final  SnActivityPubActor? actor;
@override final  String? actorUri;

/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnActorStatusResponseCopyWith<_SnActorStatusResponse> get copyWith => __$SnActorStatusResponseCopyWithImpl<_SnActorStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnActorStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActorStatusResponse&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.followerCount, followerCount) || other.followerCount == followerCount)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.actorUri, actorUri) || other.actorUri == actorUri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,followerCount,actor,actorUri);

@override
String toString() {
  return 'SnActorStatusResponse(enabled: $enabled, followerCount: $followerCount, actor: $actor, actorUri: $actorUri)';
}


}

/// @nodoc
abstract mixin class _$SnActorStatusResponseCopyWith<$Res> implements $SnActorStatusResponseCopyWith<$Res> {
  factory _$SnActorStatusResponseCopyWith(_SnActorStatusResponse value, $Res Function(_SnActorStatusResponse) _then) = __$SnActorStatusResponseCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int followerCount, SnActivityPubActor? actor, String? actorUri
});


@override $SnActivityPubActorCopyWith<$Res>? get actor;

}
/// @nodoc
class __$SnActorStatusResponseCopyWithImpl<$Res>
    implements _$SnActorStatusResponseCopyWith<$Res> {
  __$SnActorStatusResponseCopyWithImpl(this._self, this._then);

  final _SnActorStatusResponse _self;
  final $Res Function(_SnActorStatusResponse) _then;

/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? followerCount = null,Object? actor = freezed,Object? actorUri = freezed,}) {
  return _then(_SnActorStatusResponse(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,followerCount: null == followerCount ? _self.followerCount : followerCount // ignore: cast_nullable_to_non_nullable
as int,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as SnActivityPubActor?,actorUri: freezed == actorUri ? _self.actorUri : actorUri // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SnActorStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $SnActivityPubActorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}
}

// dart format on
