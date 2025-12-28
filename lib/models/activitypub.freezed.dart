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

 String get id; String get type; String? get displayName; String? get username; String? get summary; String? get inboxUri; String? get outboxUri; String? get followersUri; String? get followingUri; String? get featuredUri; String? get icon; String? get image; String? get publicKeyId; String? get publicKey; bool get isBot; bool get isLocked; bool get discoverable; bool get manuallyApprovesFollowers; Map<String, dynamic>? get endpoints; Map<String, dynamic>? get publicKeyData; Map<String, dynamic>? get metadata; DateTime? get lastFetchedAt; DateTime? get lastActivityAt;
/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnActivityPubActorCopyWith<SnActivityPubActor> get copyWith => _$SnActivityPubActorCopyWithImpl<SnActivityPubActor>(this as SnActivityPubActor, _$identity);

  /// Serializes this SnActivityPubActor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnActivityPubActor&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.inboxUri, inboxUri) || other.inboxUri == inboxUri)&&(identical(other.outboxUri, outboxUri) || other.outboxUri == outboxUri)&&(identical(other.followersUri, followersUri) || other.followersUri == followersUri)&&(identical(other.followingUri, followingUri) || other.followingUri == followingUri)&&(identical(other.featuredUri, featuredUri) || other.featuredUri == featuredUri)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.image, image) || other.image == image)&&(identical(other.publicKeyId, publicKeyId) || other.publicKeyId == publicKeyId)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.discoverable, discoverable) || other.discoverable == discoverable)&&(identical(other.manuallyApprovesFollowers, manuallyApprovesFollowers) || other.manuallyApprovesFollowers == manuallyApprovesFollowers)&&const DeepCollectionEquality().equals(other.endpoints, endpoints)&&const DeepCollectionEquality().equals(other.publicKeyData, publicKeyData)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,displayName,username,summary,inboxUri,outboxUri,followersUri,followingUri,featuredUri,icon,image,publicKeyId,publicKey,isBot,isLocked,discoverable,manuallyApprovesFollowers,const DeepCollectionEquality().hash(endpoints),const DeepCollectionEquality().hash(publicKeyData),const DeepCollectionEquality().hash(metadata),lastFetchedAt,lastActivityAt]);

@override
String toString() {
  return 'SnActivityPubActor(id: $id, type: $type, displayName: $displayName, username: $username, summary: $summary, inboxUri: $inboxUri, outboxUri: $outboxUri, followersUri: $followersUri, followingUri: $followingUri, featuredUri: $featuredUri, icon: $icon, image: $image, publicKeyId: $publicKeyId, publicKey: $publicKey, isBot: $isBot, isLocked: $isLocked, discoverable: $discoverable, manuallyApprovesFollowers: $manuallyApprovesFollowers, endpoints: $endpoints, publicKeyData: $publicKeyData, metadata: $metadata, lastFetchedAt: $lastFetchedAt, lastActivityAt: $lastActivityAt)';
}


}

/// @nodoc
abstract mixin class $SnActivityPubActorCopyWith<$Res>  {
  factory $SnActivityPubActorCopyWith(SnActivityPubActor value, $Res Function(SnActivityPubActor) _then) = _$SnActivityPubActorCopyWithImpl;
@useResult
$Res call({
 String id, String type, String? displayName, String? username, String? summary, String? inboxUri, String? outboxUri, String? followersUri, String? followingUri, String? featuredUri, String? icon, String? image, String? publicKeyId, String? publicKey, bool isBot, bool isLocked, bool discoverable, bool manuallyApprovesFollowers, Map<String, dynamic>? endpoints, Map<String, dynamic>? publicKeyData, Map<String, dynamic>? metadata, DateTime? lastFetchedAt, DateTime? lastActivityAt
});




}
/// @nodoc
class _$SnActivityPubActorCopyWithImpl<$Res>
    implements $SnActivityPubActorCopyWith<$Res> {
  _$SnActivityPubActorCopyWithImpl(this._self, this._then);

  final SnActivityPubActor _self;
  final $Res Function(SnActivityPubActor) _then;

/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? displayName = freezed,Object? username = freezed,Object? summary = freezed,Object? inboxUri = freezed,Object? outboxUri = freezed,Object? followersUri = freezed,Object? followingUri = freezed,Object? featuredUri = freezed,Object? icon = freezed,Object? image = freezed,Object? publicKeyId = freezed,Object? publicKey = freezed,Object? isBot = null,Object? isLocked = null,Object? discoverable = null,Object? manuallyApprovesFollowers = null,Object? endpoints = freezed,Object? publicKeyData = freezed,Object? metadata = freezed,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,inboxUri: freezed == inboxUri ? _self.inboxUri : inboxUri // ignore: cast_nullable_to_non_nullable
as String?,outboxUri: freezed == outboxUri ? _self.outboxUri : outboxUri // ignore: cast_nullable_to_non_nullable
as String?,followersUri: freezed == followersUri ? _self.followersUri : followersUri // ignore: cast_nullable_to_non_nullable
as String?,followingUri: freezed == followingUri ? _self.followingUri : followingUri // ignore: cast_nullable_to_non_nullable
as String?,featuredUri: freezed == featuredUri ? _self.featuredUri : featuredUri // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
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
as DateTime?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String? displayName,  String? username,  String? summary,  String? inboxUri,  String? outboxUri,  String? followersUri,  String? followingUri,  String? featuredUri,  String? icon,  String? image,  String? publicKeyId,  String? publicKey,  bool isBot,  bool isLocked,  bool discoverable,  bool manuallyApprovesFollowers,  Map<String, dynamic>? endpoints,  Map<String, dynamic>? publicKeyData,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnActivityPubActor() when $default != null:
return $default(_that.id,_that.type,_that.displayName,_that.username,_that.summary,_that.inboxUri,_that.outboxUri,_that.followersUri,_that.followingUri,_that.featuredUri,_that.icon,_that.image,_that.publicKeyId,_that.publicKey,_that.isBot,_that.isLocked,_that.discoverable,_that.manuallyApprovesFollowers,_that.endpoints,_that.publicKeyData,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String? displayName,  String? username,  String? summary,  String? inboxUri,  String? outboxUri,  String? followersUri,  String? followingUri,  String? featuredUri,  String? icon,  String? image,  String? publicKeyId,  String? publicKey,  bool isBot,  bool isLocked,  bool discoverable,  bool manuallyApprovesFollowers,  Map<String, dynamic>? endpoints,  Map<String, dynamic>? publicKeyData,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt)  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubActor():
return $default(_that.id,_that.type,_that.displayName,_that.username,_that.summary,_that.inboxUri,_that.outboxUri,_that.followersUri,_that.followingUri,_that.featuredUri,_that.icon,_that.image,_that.publicKeyId,_that.publicKey,_that.isBot,_that.isLocked,_that.discoverable,_that.manuallyApprovesFollowers,_that.endpoints,_that.publicKeyData,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String? displayName,  String? username,  String? summary,  String? inboxUri,  String? outboxUri,  String? followersUri,  String? followingUri,  String? featuredUri,  String? icon,  String? image,  String? publicKeyId,  String? publicKey,  bool isBot,  bool isLocked,  bool discoverable,  bool manuallyApprovesFollowers,  Map<String, dynamic>? endpoints,  Map<String, dynamic>? publicKeyData,  Map<String, dynamic>? metadata,  DateTime? lastFetchedAt,  DateTime? lastActivityAt)?  $default,) {final _that = this;
switch (_that) {
case _SnActivityPubActor() when $default != null:
return $default(_that.id,_that.type,_that.displayName,_that.username,_that.summary,_that.inboxUri,_that.outboxUri,_that.followersUri,_that.followingUri,_that.featuredUri,_that.icon,_that.image,_that.publicKeyId,_that.publicKey,_that.isBot,_that.isLocked,_that.discoverable,_that.manuallyApprovesFollowers,_that.endpoints,_that.publicKeyData,_that.metadata,_that.lastFetchedAt,_that.lastActivityAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnActivityPubActor implements SnActivityPubActor {
  const _SnActivityPubActor({required this.id, this.type = '', this.displayName, this.username, this.summary, this.inboxUri, this.outboxUri, this.followersUri, this.followingUri, this.featuredUri, this.icon, this.image, this.publicKeyId, this.publicKey, this.isBot = false, this.isLocked = false, this.discoverable = true, this.manuallyApprovesFollowers = false, final  Map<String, dynamic>? endpoints, final  Map<String, dynamic>? publicKeyData, final  Map<String, dynamic>? metadata, this.lastFetchedAt, this.lastActivityAt}): _endpoints = endpoints,_publicKeyData = publicKeyData,_metadata = metadata;
  factory _SnActivityPubActor.fromJson(Map<String, dynamic> json) => _$SnActivityPubActorFromJson(json);

@override final  String id;
@override@JsonKey() final  String type;
@override final  String? displayName;
@override final  String? username;
@override final  String? summary;
@override final  String? inboxUri;
@override final  String? outboxUri;
@override final  String? followersUri;
@override final  String? followingUri;
@override final  String? featuredUri;
@override final  String? icon;
@override final  String? image;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnActivityPubActor&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.username, username) || other.username == username)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.inboxUri, inboxUri) || other.inboxUri == inboxUri)&&(identical(other.outboxUri, outboxUri) || other.outboxUri == outboxUri)&&(identical(other.followersUri, followersUri) || other.followersUri == followersUri)&&(identical(other.followingUri, followingUri) || other.followingUri == followingUri)&&(identical(other.featuredUri, featuredUri) || other.featuredUri == featuredUri)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.image, image) || other.image == image)&&(identical(other.publicKeyId, publicKeyId) || other.publicKeyId == publicKeyId)&&(identical(other.publicKey, publicKey) || other.publicKey == publicKey)&&(identical(other.isBot, isBot) || other.isBot == isBot)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked)&&(identical(other.discoverable, discoverable) || other.discoverable == discoverable)&&(identical(other.manuallyApprovesFollowers, manuallyApprovesFollowers) || other.manuallyApprovesFollowers == manuallyApprovesFollowers)&&const DeepCollectionEquality().equals(other._endpoints, _endpoints)&&const DeepCollectionEquality().equals(other._publicKeyData, _publicKeyData)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.lastFetchedAt, lastFetchedAt) || other.lastFetchedAt == lastFetchedAt)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,type,displayName,username,summary,inboxUri,outboxUri,followersUri,followingUri,featuredUri,icon,image,publicKeyId,publicKey,isBot,isLocked,discoverable,manuallyApprovesFollowers,const DeepCollectionEquality().hash(_endpoints),const DeepCollectionEquality().hash(_publicKeyData),const DeepCollectionEquality().hash(_metadata),lastFetchedAt,lastActivityAt]);

@override
String toString() {
  return 'SnActivityPubActor(id: $id, type: $type, displayName: $displayName, username: $username, summary: $summary, inboxUri: $inboxUri, outboxUri: $outboxUri, followersUri: $followersUri, followingUri: $followingUri, featuredUri: $featuredUri, icon: $icon, image: $image, publicKeyId: $publicKeyId, publicKey: $publicKey, isBot: $isBot, isLocked: $isLocked, discoverable: $discoverable, manuallyApprovesFollowers: $manuallyApprovesFollowers, endpoints: $endpoints, publicKeyData: $publicKeyData, metadata: $metadata, lastFetchedAt: $lastFetchedAt, lastActivityAt: $lastActivityAt)';
}


}

/// @nodoc
abstract mixin class _$SnActivityPubActorCopyWith<$Res> implements $SnActivityPubActorCopyWith<$Res> {
  factory _$SnActivityPubActorCopyWith(_SnActivityPubActor value, $Res Function(_SnActivityPubActor) _then) = __$SnActivityPubActorCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String? displayName, String? username, String? summary, String? inboxUri, String? outboxUri, String? followersUri, String? followingUri, String? featuredUri, String? icon, String? image, String? publicKeyId, String? publicKey, bool isBot, bool isLocked, bool discoverable, bool manuallyApprovesFollowers, Map<String, dynamic>? endpoints, Map<String, dynamic>? publicKeyData, Map<String, dynamic>? metadata, DateTime? lastFetchedAt, DateTime? lastActivityAt
});




}
/// @nodoc
class __$SnActivityPubActorCopyWithImpl<$Res>
    implements _$SnActivityPubActorCopyWith<$Res> {
  __$SnActivityPubActorCopyWithImpl(this._self, this._then);

  final _SnActivityPubActor _self;
  final $Res Function(_SnActivityPubActor) _then;

/// Create a copy of SnActivityPubActor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? displayName = freezed,Object? username = freezed,Object? summary = freezed,Object? inboxUri = freezed,Object? outboxUri = freezed,Object? followersUri = freezed,Object? followingUri = freezed,Object? featuredUri = freezed,Object? icon = freezed,Object? image = freezed,Object? publicKeyId = freezed,Object? publicKey = freezed,Object? isBot = null,Object? isLocked = null,Object? discoverable = null,Object? manuallyApprovesFollowers = null,Object? endpoints = freezed,Object? publicKeyData = freezed,Object? metadata = freezed,Object? lastFetchedAt = freezed,Object? lastActivityAt = freezed,}) {
  return _then(_SnActivityPubActor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,inboxUri: freezed == inboxUri ? _self.inboxUri : inboxUri // ignore: cast_nullable_to_non_nullable
as String?,outboxUri: freezed == outboxUri ? _self.outboxUri : outboxUri // ignore: cast_nullable_to_non_nullable
as String?,followersUri: freezed == followersUri ? _self.followersUri : followersUri // ignore: cast_nullable_to_non_nullable
as String?,followingUri: freezed == followingUri ? _self.followingUri : followingUri // ignore: cast_nullable_to_non_nullable
as String?,featuredUri: freezed == featuredUri ? _self.featuredUri : featuredUri // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
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
as DateTime?,
  ));
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
