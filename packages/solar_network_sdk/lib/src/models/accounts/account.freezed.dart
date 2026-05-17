// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAccount {

 String get id; String get name; String get nick; String get language; String get region; bool get isSuperuser; String? get automatedId; SnAccountProfile get profile; SnWalletSubscriptionRef? get perkSubscription; List<SnAccountBadge> get badges; List<SnContactMethod> get contacts; DateTime? get activatedAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountCopyWith<SnAccount> get copyWith => _$SnAccountCopyWithImpl<SnAccount>(this as SnAccount, _$identity);

  /// Serializes this SnAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.language, language) || other.language == language)&&(identical(other.region, region) || other.region == region)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.automatedId, automatedId) || other.automatedId == automatedId)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.perkSubscription, perkSubscription) || other.perkSubscription == perkSubscription)&&const DeepCollectionEquality().equals(other.badges, badges)&&const DeepCollectionEquality().equals(other.contacts, contacts)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick,language,region,isSuperuser,automatedId,profile,perkSubscription,const DeepCollectionEquality().hash(badges),const DeepCollectionEquality().hash(contacts),activatedAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccount(id: $id, name: $name, nick: $nick, language: $language, region: $region, isSuperuser: $isSuperuser, automatedId: $automatedId, profile: $profile, perkSubscription: $perkSubscription, badges: $badges, contacts: $contacts, activatedAt: $activatedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountCopyWith<$Res>  {
  factory $SnAccountCopyWith(SnAccount value, $Res Function(SnAccount) _then) = _$SnAccountCopyWithImpl;
@useResult
$Res call({
 String id, String name, String nick, String language, String region, bool isSuperuser, String? automatedId, SnAccountProfile profile, SnWalletSubscriptionRef? perkSubscription, List<SnAccountBadge> badges, List<SnContactMethod> contacts, DateTime? activatedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAccountProfileCopyWith<$Res> get profile;$SnWalletSubscriptionRefCopyWith<$Res>? get perkSubscription;

}
/// @nodoc
class _$SnAccountCopyWithImpl<$Res>
    implements $SnAccountCopyWith<$Res> {
  _$SnAccountCopyWithImpl(this._self, this._then);

  final SnAccount _self;
  final $Res Function(SnAccount) _then;

/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nick = null,Object? language = null,Object? region = null,Object? isSuperuser = null,Object? automatedId = freezed,Object? profile = null,Object? perkSubscription = freezed,Object? badges = null,Object? contacts = null,Object? activatedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,automatedId: freezed == automatedId ? _self.automatedId : automatedId // ignore: cast_nullable_to_non_nullable
as String?,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SnAccountProfile,perkSubscription: freezed == perkSubscription ? _self.perkSubscription : perkSubscription // ignore: cast_nullable_to_non_nullable
as SnWalletSubscriptionRef?,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<SnAccountBadge>,contacts: null == contacts ? _self.contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<SnContactMethod>,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountProfileCopyWith<$Res> get profile {
  
  return $SnAccountProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWalletSubscriptionRefCopyWith<$Res>? get perkSubscription {
    if (_self.perkSubscription == null) {
    return null;
  }

  return $SnWalletSubscriptionRefCopyWith<$Res>(_self.perkSubscription!, (value) {
    return _then(_self.copyWith(perkSubscription: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnAccount].
extension SnAccountPatterns on SnAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccount value)  $default,){
final _that = this;
switch (_that) {
case _SnAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccount value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String nick,  String language,  String region,  bool isSuperuser,  String? automatedId,  SnAccountProfile profile,  SnWalletSubscriptionRef? perkSubscription,  List<SnAccountBadge> badges,  List<SnContactMethod> contacts,  DateTime? activatedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccount() when $default != null:
return $default(_that.id,_that.name,_that.nick,_that.language,_that.region,_that.isSuperuser,_that.automatedId,_that.profile,_that.perkSubscription,_that.badges,_that.contacts,_that.activatedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String nick,  String language,  String region,  bool isSuperuser,  String? automatedId,  SnAccountProfile profile,  SnWalletSubscriptionRef? perkSubscription,  List<SnAccountBadge> badges,  List<SnContactMethod> contacts,  DateTime? activatedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAccount():
return $default(_that.id,_that.name,_that.nick,_that.language,_that.region,_that.isSuperuser,_that.automatedId,_that.profile,_that.perkSubscription,_that.badges,_that.contacts,_that.activatedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String nick,  String language,  String region,  bool isSuperuser,  String? automatedId,  SnAccountProfile profile,  SnWalletSubscriptionRef? perkSubscription,  List<SnAccountBadge> badges,  List<SnContactMethod> contacts,  DateTime? activatedAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAccount() when $default != null:
return $default(_that.id,_that.name,_that.nick,_that.language,_that.region,_that.isSuperuser,_that.automatedId,_that.profile,_that.perkSubscription,_that.badges,_that.contacts,_that.activatedAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccount extends SnAccount {
  const _SnAccount({required this.id, required this.name, required this.nick, required this.language, this.region = "", required this.isSuperuser, required this.automatedId, required this.profile, required this.perkSubscription, final  List<SnAccountBadge> badges = const [], final  List<SnContactMethod> contacts = const [], required this.activatedAt, required this.createdAt, required this.updatedAt, required this.deletedAt}): _badges = badges,_contacts = contacts,super._();
  factory _SnAccount.fromJson(Map<String, dynamic> json) => _$SnAccountFromJson(json);

@override final  String id;
@override final  String name;
@override final  String nick;
@override final  String language;
@override@JsonKey() final  String region;
@override final  bool isSuperuser;
@override final  String? automatedId;
@override final  SnAccountProfile profile;
@override final  SnWalletSubscriptionRef? perkSubscription;
 final  List<SnAccountBadge> _badges;
@override@JsonKey() List<SnAccountBadge> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

 final  List<SnContactMethod> _contacts;
@override@JsonKey() List<SnContactMethod> get contacts {
  if (_contacts is EqualUnmodifiableListView) return _contacts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_contacts);
}

@override final  DateTime? activatedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountCopyWith<_SnAccount> get copyWith => __$SnAccountCopyWithImpl<_SnAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.language, language) || other.language == language)&&(identical(other.region, region) || other.region == region)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.automatedId, automatedId) || other.automatedId == automatedId)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.perkSubscription, perkSubscription) || other.perkSubscription == perkSubscription)&&const DeepCollectionEquality().equals(other._badges, _badges)&&const DeepCollectionEquality().equals(other._contacts, _contacts)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick,language,region,isSuperuser,automatedId,profile,perkSubscription,const DeepCollectionEquality().hash(_badges),const DeepCollectionEquality().hash(_contacts),activatedAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccount(id: $id, name: $name, nick: $nick, language: $language, region: $region, isSuperuser: $isSuperuser, automatedId: $automatedId, profile: $profile, perkSubscription: $perkSubscription, badges: $badges, contacts: $contacts, activatedAt: $activatedAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountCopyWith<$Res> implements $SnAccountCopyWith<$Res> {
  factory _$SnAccountCopyWith(_SnAccount value, $Res Function(_SnAccount) _then) = __$SnAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String nick, String language, String region, bool isSuperuser, String? automatedId, SnAccountProfile profile, SnWalletSubscriptionRef? perkSubscription, List<SnAccountBadge> badges, List<SnContactMethod> contacts, DateTime? activatedAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAccountProfileCopyWith<$Res> get profile;@override $SnWalletSubscriptionRefCopyWith<$Res>? get perkSubscription;

}
/// @nodoc
class __$SnAccountCopyWithImpl<$Res>
    implements _$SnAccountCopyWith<$Res> {
  __$SnAccountCopyWithImpl(this._self, this._then);

  final _SnAccount _self;
  final $Res Function(_SnAccount) _then;

/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nick = null,Object? language = null,Object? region = null,Object? isSuperuser = null,Object? automatedId = freezed,Object? profile = null,Object? perkSubscription = freezed,Object? badges = null,Object? contacts = null,Object? activatedAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,automatedId: freezed == automatedId ? _self.automatedId : automatedId // ignore: cast_nullable_to_non_nullable
as String?,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SnAccountProfile,perkSubscription: freezed == perkSubscription ? _self.perkSubscription : perkSubscription // ignore: cast_nullable_to_non_nullable
as SnWalletSubscriptionRef?,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<SnAccountBadge>,contacts: null == contacts ? _self._contacts : contacts // ignore: cast_nullable_to_non_nullable
as List<SnContactMethod>,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountProfileCopyWith<$Res> get profile {
  
  return $SnAccountProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of SnAccount
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnWalletSubscriptionRefCopyWith<$Res>? get perkSubscription {
    if (_self.perkSubscription == null) {
    return null;
  }

  return $SnWalletSubscriptionRefCopyWith<$Res>(_self.perkSubscription!, (value) {
    return _then(_self.copyWith(perkSubscription: value));
  });
}
}


/// @nodoc
mixin _$ProfileLink {

 String get name; String get url;
/// Create a copy of ProfileLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileLinkCopyWith<ProfileLink> get copyWith => _$ProfileLinkCopyWithImpl<ProfileLink>(this as ProfileLink, _$identity);

  /// Serializes this ProfileLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLink&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'ProfileLink(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class $ProfileLinkCopyWith<$Res>  {
  factory $ProfileLinkCopyWith(ProfileLink value, $Res Function(ProfileLink) _then) = _$ProfileLinkCopyWithImpl;
@useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class _$ProfileLinkCopyWithImpl<$Res>
    implements $ProfileLinkCopyWith<$Res> {
  _$ProfileLinkCopyWithImpl(this._self, this._then);

  final ProfileLink _self;
  final $Res Function(ProfileLink) _then;

/// Create a copy of ProfileLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? url = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileLink].
extension ProfileLinkPatterns on ProfileLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileLink value)  $default,){
final _that = this;
switch (_that) {
case _ProfileLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileLink value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileLink() when $default != null:
return $default(_that.name,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String url)  $default,) {final _that = this;
switch (_that) {
case _ProfileLink():
return $default(_that.name,_that.url);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String url)?  $default,) {final _that = this;
switch (_that) {
case _ProfileLink() when $default != null:
return $default(_that.name,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileLink implements ProfileLink {
  const _ProfileLink({required this.name, required this.url});
  factory _ProfileLink.fromJson(Map<String, dynamic> json) => _$ProfileLinkFromJson(json);

@override final  String name;
@override final  String url;

/// Create a copy of ProfileLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileLinkCopyWith<_ProfileLink> get copyWith => __$ProfileLinkCopyWithImpl<_ProfileLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileLink&&(identical(other.name, name) || other.name == name)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,url);

@override
String toString() {
  return 'ProfileLink(name: $name, url: $url)';
}


}

/// @nodoc
abstract mixin class _$ProfileLinkCopyWith<$Res> implements $ProfileLinkCopyWith<$Res> {
  factory _$ProfileLinkCopyWith(_ProfileLink value, $Res Function(_ProfileLink) _then) = __$ProfileLinkCopyWithImpl;
@override @useResult
$Res call({
 String name, String url
});




}
/// @nodoc
class __$ProfileLinkCopyWithImpl<$Res>
    implements _$ProfileLinkCopyWith<$Res> {
  __$ProfileLinkCopyWithImpl(this._self, this._then);

  final _ProfileLink _self;
  final $Res Function(_ProfileLink) _then;

/// Create a copy of ProfileLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? url = null,}) {
  return _then(_ProfileLink(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UsernameColor {

 String get type; String? get value; String? get direction; List<String>? get colors;
/// Create a copy of UsernameColor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsernameColorCopyWith<UsernameColor> get copyWith => _$UsernameColorCopyWithImpl<UsernameColor>(this as UsernameColor, _$identity);

  /// Serializes this UsernameColor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsernameColor&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.direction, direction) || other.direction == direction)&&const DeepCollectionEquality().equals(other.colors, colors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value,direction,const DeepCollectionEquality().hash(colors));

@override
String toString() {
  return 'UsernameColor(type: $type, value: $value, direction: $direction, colors: $colors)';
}


}

/// @nodoc
abstract mixin class $UsernameColorCopyWith<$Res>  {
  factory $UsernameColorCopyWith(UsernameColor value, $Res Function(UsernameColor) _then) = _$UsernameColorCopyWithImpl;
@useResult
$Res call({
 String type, String? value, String? direction, List<String>? colors
});




}
/// @nodoc
class _$UsernameColorCopyWithImpl<$Res>
    implements $UsernameColorCopyWith<$Res> {
  _$UsernameColorCopyWithImpl(this._self, this._then);

  final UsernameColor _self;
  final $Res Function(UsernameColor) _then;

/// Create a copy of UsernameColor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? value = freezed,Object? direction = freezed,Object? colors = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,colors: freezed == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [UsernameColor].
extension UsernameColorPatterns on UsernameColor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UsernameColor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UsernameColor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UsernameColor value)  $default,){
final _that = this;
switch (_that) {
case _UsernameColor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UsernameColor value)?  $default,){
final _that = this;
switch (_that) {
case _UsernameColor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String? value,  String? direction,  List<String>? colors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UsernameColor() when $default != null:
return $default(_that.type,_that.value,_that.direction,_that.colors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String? value,  String? direction,  List<String>? colors)  $default,) {final _that = this;
switch (_that) {
case _UsernameColor():
return $default(_that.type,_that.value,_that.direction,_that.colors);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String? value,  String? direction,  List<String>? colors)?  $default,) {final _that = this;
switch (_that) {
case _UsernameColor() when $default != null:
return $default(_that.type,_that.value,_that.direction,_that.colors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UsernameColor implements UsernameColor {
  const _UsernameColor({this.type = 'plain', this.value, this.direction, final  List<String>? colors}): _colors = colors;
  factory _UsernameColor.fromJson(Map<String, dynamic> json) => _$UsernameColorFromJson(json);

@override@JsonKey() final  String type;
@override final  String? value;
@override final  String? direction;
 final  List<String>? _colors;
@override List<String>? get colors {
  final value = _colors;
  if (value == null) return null;
  if (_colors is EqualUnmodifiableListView) return _colors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of UsernameColor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsernameColorCopyWith<_UsernameColor> get copyWith => __$UsernameColorCopyWithImpl<_UsernameColor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsernameColorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsernameColor&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.direction, direction) || other.direction == direction)&&const DeepCollectionEquality().equals(other._colors, _colors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,value,direction,const DeepCollectionEquality().hash(_colors));

@override
String toString() {
  return 'UsernameColor(type: $type, value: $value, direction: $direction, colors: $colors)';
}


}

/// @nodoc
abstract mixin class _$UsernameColorCopyWith<$Res> implements $UsernameColorCopyWith<$Res> {
  factory _$UsernameColorCopyWith(_UsernameColor value, $Res Function(_UsernameColor) _then) = __$UsernameColorCopyWithImpl;
@override @useResult
$Res call({
 String type, String? value, String? direction, List<String>? colors
});




}
/// @nodoc
class __$UsernameColorCopyWithImpl<$Res>
    implements _$UsernameColorCopyWith<$Res> {
  __$UsernameColorCopyWithImpl(this._self, this._then);

  final _UsernameColor _self;
  final $Res Function(_UsernameColor) _then;

/// Create a copy of UsernameColor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? value = freezed,Object? direction = freezed,Object? colors = freezed,}) {
  return _then(_UsernameColor(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,direction: freezed == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String?,colors: freezed == colors ? _self._colors : colors // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}


/// @nodoc
mixin _$SnAccountProfile {

 String get id; String get firstName; String get middleName; String get lastName; String get bio; String get gender; String get pronouns; String get location; String get timeZone; DateTime? get birthday;@ProfileLinkConverter() List<ProfileLink> get links; DateTime? get lastSeenAt; SnAccountBadge? get activeBadge; int get experience; int get level; double get socialCredits; int get socialCreditsLevel; double get levelingProgress; SnCloudFileReference? get picture; SnCloudFileReference? get background; SnVerificationMark? get verification; UsernameColor? get usernameColor; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountProfileCopyWith<SnAccountProfile> get copyWith => _$SnAccountProfileCopyWithImpl<SnAccountProfile>(this as SnAccountProfile, _$identity);

  /// Serializes this SnAccountProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.location, location) || other.location == location)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&const DeepCollectionEquality().equals(other.links, links)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.activeBadge, activeBadge) || other.activeBadge == activeBadge)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.level, level) || other.level == level)&&(identical(other.socialCredits, socialCredits) || other.socialCredits == socialCredits)&&(identical(other.socialCreditsLevel, socialCreditsLevel) || other.socialCreditsLevel == socialCreditsLevel)&&(identical(other.levelingProgress, levelingProgress) || other.levelingProgress == levelingProgress)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.usernameColor, usernameColor) || other.usernameColor == usernameColor)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,middleName,lastName,bio,gender,pronouns,location,timeZone,birthday,const DeepCollectionEquality().hash(links),lastSeenAt,activeBadge,experience,level,socialCredits,socialCreditsLevel,levelingProgress,picture,background,verification,usernameColor,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnAccountProfile(id: $id, firstName: $firstName, middleName: $middleName, lastName: $lastName, bio: $bio, gender: $gender, pronouns: $pronouns, location: $location, timeZone: $timeZone, birthday: $birthday, links: $links, lastSeenAt: $lastSeenAt, activeBadge: $activeBadge, experience: $experience, level: $level, socialCredits: $socialCredits, socialCreditsLevel: $socialCreditsLevel, levelingProgress: $levelingProgress, picture: $picture, background: $background, verification: $verification, usernameColor: $usernameColor, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountProfileCopyWith<$Res>  {
  factory $SnAccountProfileCopyWith(SnAccountProfile value, $Res Function(SnAccountProfile) _then) = _$SnAccountProfileCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String middleName, String lastName, String bio, String gender, String pronouns, String location, String timeZone, DateTime? birthday,@ProfileLinkConverter() List<ProfileLink> links, DateTime? lastSeenAt, SnAccountBadge? activeBadge, int experience, int level, double socialCredits, int socialCreditsLevel, double levelingProgress, SnCloudFileReference? picture, SnCloudFileReference? background, SnVerificationMark? verification, UsernameColor? usernameColor, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnAccountBadgeCopyWith<$Res>? get activeBadge;$SnCloudFileReferenceCopyWith<$Res>? get picture;$SnCloudFileReferenceCopyWith<$Res>? get background;$SnVerificationMarkCopyWith<$Res>? get verification;$UsernameColorCopyWith<$Res>? get usernameColor;

}
/// @nodoc
class _$SnAccountProfileCopyWithImpl<$Res>
    implements $SnAccountProfileCopyWith<$Res> {
  _$SnAccountProfileCopyWithImpl(this._self, this._then);

  final SnAccountProfile _self;
  final $Res Function(SnAccountProfile) _then;

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? bio = null,Object? gender = null,Object? pronouns = null,Object? location = null,Object? timeZone = null,Object? birthday = freezed,Object? links = null,Object? lastSeenAt = freezed,Object? activeBadge = freezed,Object? experience = null,Object? level = null,Object? socialCredits = null,Object? socialCreditsLevel = null,Object? levelingProgress = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? usernameColor = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,pronouns: null == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<ProfileLink>,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,activeBadge: freezed == activeBadge ? _self.activeBadge : activeBadge // ignore: cast_nullable_to_non_nullable
as SnAccountBadge?,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,socialCredits: null == socialCredits ? _self.socialCredits : socialCredits // ignore: cast_nullable_to_non_nullable
as double,socialCreditsLevel: null == socialCreditsLevel ? _self.socialCreditsLevel : socialCreditsLevel // ignore: cast_nullable_to_non_nullable
as int,levelingProgress: null == levelingProgress ? _self.levelingProgress : levelingProgress // ignore: cast_nullable_to_non_nullable
as double,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,usernameColor: freezed == usernameColor ? _self.usernameColor : usernameColor // ignore: cast_nullable_to_non_nullable
as UsernameColor?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountBadgeCopyWith<$Res>? get activeBadge {
    if (_self.activeBadge == null) {
    return null;
  }

  return $SnAccountBadgeCopyWith<$Res>(_self.activeBadge!, (value) {
    return _then(_self.copyWith(activeBadge: value));
  });
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsernameColorCopyWith<$Res>? get usernameColor {
    if (_self.usernameColor == null) {
    return null;
  }

  return $UsernameColorCopyWith<$Res>(_self.usernameColor!, (value) {
    return _then(_self.copyWith(usernameColor: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnAccountProfile].
extension SnAccountProfilePatterns on SnAccountProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccountProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccountProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccountProfile value)  $default,){
final _that = this;
switch (_that) {
case _SnAccountProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccountProfile value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccountProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String middleName,  String lastName,  String bio,  String gender,  String pronouns,  String location,  String timeZone,  DateTime? birthday, @ProfileLinkConverter()  List<ProfileLink> links,  DateTime? lastSeenAt,  SnAccountBadge? activeBadge,  int experience,  int level,  double socialCredits,  int socialCreditsLevel,  double levelingProgress,  SnCloudFileReference? picture,  SnCloudFileReference? background,  SnVerificationMark? verification,  UsernameColor? usernameColor,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountProfile() when $default != null:
return $default(_that.id,_that.firstName,_that.middleName,_that.lastName,_that.bio,_that.gender,_that.pronouns,_that.location,_that.timeZone,_that.birthday,_that.links,_that.lastSeenAt,_that.activeBadge,_that.experience,_that.level,_that.socialCredits,_that.socialCreditsLevel,_that.levelingProgress,_that.picture,_that.background,_that.verification,_that.usernameColor,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String middleName,  String lastName,  String bio,  String gender,  String pronouns,  String location,  String timeZone,  DateTime? birthday, @ProfileLinkConverter()  List<ProfileLink> links,  DateTime? lastSeenAt,  SnAccountBadge? activeBadge,  int experience,  int level,  double socialCredits,  int socialCreditsLevel,  double levelingProgress,  SnCloudFileReference? picture,  SnCloudFileReference? background,  SnVerificationMark? verification,  UsernameColor? usernameColor,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAccountProfile():
return $default(_that.id,_that.firstName,_that.middleName,_that.lastName,_that.bio,_that.gender,_that.pronouns,_that.location,_that.timeZone,_that.birthday,_that.links,_that.lastSeenAt,_that.activeBadge,_that.experience,_that.level,_that.socialCredits,_that.socialCreditsLevel,_that.levelingProgress,_that.picture,_that.background,_that.verification,_that.usernameColor,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String middleName,  String lastName,  String bio,  String gender,  String pronouns,  String location,  String timeZone,  DateTime? birthday, @ProfileLinkConverter()  List<ProfileLink> links,  DateTime? lastSeenAt,  SnAccountBadge? activeBadge,  int experience,  int level,  double socialCredits,  int socialCreditsLevel,  double levelingProgress,  SnCloudFileReference? picture,  SnCloudFileReference? background,  SnVerificationMark? verification,  UsernameColor? usernameColor,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountProfile() when $default != null:
return $default(_that.id,_that.firstName,_that.middleName,_that.lastName,_that.bio,_that.gender,_that.pronouns,_that.location,_that.timeZone,_that.birthday,_that.links,_that.lastSeenAt,_that.activeBadge,_that.experience,_that.level,_that.socialCredits,_that.socialCreditsLevel,_that.levelingProgress,_that.picture,_that.background,_that.verification,_that.usernameColor,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountProfile implements SnAccountProfile {
  const _SnAccountProfile({required this.id, this.firstName = '', this.middleName = '', this.lastName = '', this.bio = '', this.gender = '', this.pronouns = '', this.location = '', this.timeZone = '', this.birthday, @ProfileLinkConverter() final  List<ProfileLink> links = const [], this.lastSeenAt, this.activeBadge, required this.experience, required this.level, this.socialCredits = 100, this.socialCreditsLevel = 0, required this.levelingProgress, required this.picture, required this.background, required this.verification, this.usernameColor, required this.createdAt, required this.updatedAt, required this.deletedAt}): _links = links;
  factory _SnAccountProfile.fromJson(Map<String, dynamic> json) => _$SnAccountProfileFromJson(json);

@override final  String id;
@override@JsonKey() final  String firstName;
@override@JsonKey() final  String middleName;
@override@JsonKey() final  String lastName;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String gender;
@override@JsonKey() final  String pronouns;
@override@JsonKey() final  String location;
@override@JsonKey() final  String timeZone;
@override final  DateTime? birthday;
 final  List<ProfileLink> _links;
@override@JsonKey()@ProfileLinkConverter() List<ProfileLink> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}

@override final  DateTime? lastSeenAt;
@override final  SnAccountBadge? activeBadge;
@override final  int experience;
@override final  int level;
@override@JsonKey() final  double socialCredits;
@override@JsonKey() final  int socialCreditsLevel;
@override final  double levelingProgress;
@override final  SnCloudFileReference? picture;
@override final  SnCloudFileReference? background;
@override final  SnVerificationMark? verification;
@override final  UsernameColor? usernameColor;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountProfileCopyWith<_SnAccountProfile> get copyWith => __$SnAccountProfileCopyWithImpl<_SnAccountProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.location, location) || other.location == location)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&const DeepCollectionEquality().equals(other._links, _links)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.activeBadge, activeBadge) || other.activeBadge == activeBadge)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.level, level) || other.level == level)&&(identical(other.socialCredits, socialCredits) || other.socialCredits == socialCredits)&&(identical(other.socialCreditsLevel, socialCreditsLevel) || other.socialCreditsLevel == socialCreditsLevel)&&(identical(other.levelingProgress, levelingProgress) || other.levelingProgress == levelingProgress)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.usernameColor, usernameColor) || other.usernameColor == usernameColor)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,firstName,middleName,lastName,bio,gender,pronouns,location,timeZone,birthday,const DeepCollectionEquality().hash(_links),lastSeenAt,activeBadge,experience,level,socialCredits,socialCreditsLevel,levelingProgress,picture,background,verification,usernameColor,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'SnAccountProfile(id: $id, firstName: $firstName, middleName: $middleName, lastName: $lastName, bio: $bio, gender: $gender, pronouns: $pronouns, location: $location, timeZone: $timeZone, birthday: $birthday, links: $links, lastSeenAt: $lastSeenAt, activeBadge: $activeBadge, experience: $experience, level: $level, socialCredits: $socialCredits, socialCreditsLevel: $socialCreditsLevel, levelingProgress: $levelingProgress, picture: $picture, background: $background, verification: $verification, usernameColor: $usernameColor, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountProfileCopyWith<$Res> implements $SnAccountProfileCopyWith<$Res> {
  factory _$SnAccountProfileCopyWith(_SnAccountProfile value, $Res Function(_SnAccountProfile) _then) = __$SnAccountProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String middleName, String lastName, String bio, String gender, String pronouns, String location, String timeZone, DateTime? birthday,@ProfileLinkConverter() List<ProfileLink> links, DateTime? lastSeenAt, SnAccountBadge? activeBadge, int experience, int level, double socialCredits, int socialCreditsLevel, double levelingProgress, SnCloudFileReference? picture, SnCloudFileReference? background, SnVerificationMark? verification, UsernameColor? usernameColor, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnAccountBadgeCopyWith<$Res>? get activeBadge;@override $SnCloudFileReferenceCopyWith<$Res>? get picture;@override $SnCloudFileReferenceCopyWith<$Res>? get background;@override $SnVerificationMarkCopyWith<$Res>? get verification;@override $UsernameColorCopyWith<$Res>? get usernameColor;

}
/// @nodoc
class __$SnAccountProfileCopyWithImpl<$Res>
    implements _$SnAccountProfileCopyWith<$Res> {
  __$SnAccountProfileCopyWithImpl(this._self, this._then);

  final _SnAccountProfile _self;
  final $Res Function(_SnAccountProfile) _then;

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? bio = null,Object? gender = null,Object? pronouns = null,Object? location = null,Object? timeZone = null,Object? birthday = freezed,Object? links = null,Object? lastSeenAt = freezed,Object? activeBadge = freezed,Object? experience = null,Object? level = null,Object? socialCredits = null,Object? socialCreditsLevel = null,Object? levelingProgress = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? usernameColor = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccountProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,pronouns: null == pronouns ? _self.pronouns : pronouns // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<ProfileLink>,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,activeBadge: freezed == activeBadge ? _self.activeBadge : activeBadge // ignore: cast_nullable_to_non_nullable
as SnAccountBadge?,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as int,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as int,socialCredits: null == socialCredits ? _self.socialCredits : socialCredits // ignore: cast_nullable_to_non_nullable
as double,socialCreditsLevel: null == socialCreditsLevel ? _self.socialCreditsLevel : socialCreditsLevel // ignore: cast_nullable_to_non_nullable
as int,levelingProgress: null == levelingProgress ? _self.levelingProgress : levelingProgress // ignore: cast_nullable_to_non_nullable
as double,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,usernameColor: freezed == usernameColor ? _self.usernameColor : usernameColor // ignore: cast_nullable_to_non_nullable
as UsernameColor?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountBadgeCopyWith<$Res>? get activeBadge {
    if (_self.activeBadge == null) {
    return null;
  }

  return $SnAccountBadgeCopyWith<$Res>(_self.activeBadge!, (value) {
    return _then(_self.copyWith(activeBadge: value));
  });
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}/// Create a copy of SnAccountProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsernameColorCopyWith<$Res>? get usernameColor {
    if (_self.usernameColor == null) {
    return null;
  }

  return $UsernameColorCopyWith<$Res>(_self.usernameColor!, (value) {
    return _then(_self.copyWith(usernameColor: value));
  });
}
}


/// @nodoc
mixin _$SnAccountStatus {

 String get id; int get attitude; bool get isOnline; bool get isCustomized;@JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) int get type; String get label; String? get symbol; Map<String, dynamic>? get meta; DateTime? get clearedAt; String? get appIdentifier; bool get isAutomated; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<SnAccountStatus> get copyWith => _$SnAccountStatusCopyWithImpl<SnAccountStatus>(this as SnAccountStatus, _$identity);

  /// Serializes this SnAccountStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isCustomized, isCustomized) || other.isCustomized == isCustomized)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.clearedAt, clearedAt) || other.clearedAt == clearedAt)&&(identical(other.appIdentifier, appIdentifier) || other.appIdentifier == appIdentifier)&&(identical(other.isAutomated, isAutomated) || other.isAutomated == isAutomated)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attitude,isOnline,isCustomized,type,label,symbol,const DeepCollectionEquality().hash(meta),clearedAt,appIdentifier,isAutomated,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountStatus(id: $id, attitude: $attitude, isOnline: $isOnline, isCustomized: $isCustomized, type: $type, label: $label, symbol: $symbol, meta: $meta, clearedAt: $clearedAt, appIdentifier: $appIdentifier, isAutomated: $isAutomated, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountStatusCopyWith<$Res>  {
  factory $SnAccountStatusCopyWith(SnAccountStatus value, $Res Function(SnAccountStatus) _then) = _$SnAccountStatusCopyWithImpl;
@useResult
$Res call({
 String id, int attitude, bool isOnline, bool isCustomized,@JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) int type, String label, String? symbol, Map<String, dynamic>? meta, DateTime? clearedAt, String? appIdentifier, bool isAutomated, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnAccountStatusCopyWithImpl<$Res>
    implements $SnAccountStatusCopyWith<$Res> {
  _$SnAccountStatusCopyWithImpl(this._self, this._then);

  final SnAccountStatus _self;
  final $Res Function(SnAccountStatus) _then;

/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? attitude = null,Object? isOnline = null,Object? isCustomized = null,Object? type = null,Object? label = null,Object? symbol = freezed,Object? meta = freezed,Object? clearedAt = freezed,Object? appIdentifier = freezed,Object? isAutomated = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isCustomized: null == isCustomized ? _self.isCustomized : isCustomized // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clearedAt: freezed == clearedAt ? _self.clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,appIdentifier: freezed == appIdentifier ? _self.appIdentifier : appIdentifier // ignore: cast_nullable_to_non_nullable
as String?,isAutomated: null == isAutomated ? _self.isAutomated : isAutomated // ignore: cast_nullable_to_non_nullable
as bool,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAccountStatus].
extension SnAccountStatusPatterns on SnAccountStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccountStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccountStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccountStatus value)  $default,){
final _that = this;
switch (_that) {
case _SnAccountStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccountStatus value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccountStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int attitude,  bool isOnline,  bool isCustomized, @JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson)  int type,  String label,  String? symbol,  Map<String, dynamic>? meta,  DateTime? clearedAt,  String? appIdentifier,  bool isAutomated,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountStatus() when $default != null:
return $default(_that.id,_that.attitude,_that.isOnline,_that.isCustomized,_that.type,_that.label,_that.symbol,_that.meta,_that.clearedAt,_that.appIdentifier,_that.isAutomated,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int attitude,  bool isOnline,  bool isCustomized, @JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson)  int type,  String label,  String? symbol,  Map<String, dynamic>? meta,  DateTime? clearedAt,  String? appIdentifier,  bool isAutomated,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAccountStatus():
return $default(_that.id,_that.attitude,_that.isOnline,_that.isCustomized,_that.type,_that.label,_that.symbol,_that.meta,_that.clearedAt,_that.appIdentifier,_that.isAutomated,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int attitude,  bool isOnline,  bool isCustomized, @JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson)  int type,  String label,  String? symbol,  Map<String, dynamic>? meta,  DateTime? clearedAt,  String? appIdentifier,  bool isAutomated,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountStatus() when $default != null:
return $default(_that.id,_that.attitude,_that.isOnline,_that.isCustomized,_that.type,_that.label,_that.symbol,_that.meta,_that.clearedAt,_that.appIdentifier,_that.isAutomated,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountStatus implements SnAccountStatus {
  const _SnAccountStatus({required this.id, required this.attitude, required this.isOnline, required this.isCustomized, @JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) this.type = SnAccountStatusType.defaultType, this.label = "", this.symbol, required final  Map<String, dynamic>? meta, required this.clearedAt, this.appIdentifier, this.isAutomated = false, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt}): _meta = meta;
  factory _SnAccountStatus.fromJson(Map<String, dynamic> json) => _$SnAccountStatusFromJson(json);

@override final  String id;
@override final  int attitude;
@override final  bool isOnline;
@override final  bool isCustomized;
@override@JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) final  int type;
@override@JsonKey() final  String label;
@override final  String? symbol;
 final  Map<String, dynamic>? _meta;
@override Map<String, dynamic>? get meta {
  final value = _meta;
  if (value == null) return null;
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime? clearedAt;
@override final  String? appIdentifier;
@override@JsonKey() final  bool isAutomated;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountStatusCopyWith<_SnAccountStatus> get copyWith => __$SnAccountStatusCopyWithImpl<_SnAccountStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isCustomized, isCustomized) || other.isCustomized == isCustomized)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.clearedAt, clearedAt) || other.clearedAt == clearedAt)&&(identical(other.appIdentifier, appIdentifier) || other.appIdentifier == appIdentifier)&&(identical(other.isAutomated, isAutomated) || other.isAutomated == isAutomated)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,attitude,isOnline,isCustomized,type,label,symbol,const DeepCollectionEquality().hash(_meta),clearedAt,appIdentifier,isAutomated,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountStatus(id: $id, attitude: $attitude, isOnline: $isOnline, isCustomized: $isCustomized, type: $type, label: $label, symbol: $symbol, meta: $meta, clearedAt: $clearedAt, appIdentifier: $appIdentifier, isAutomated: $isAutomated, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountStatusCopyWith<$Res> implements $SnAccountStatusCopyWith<$Res> {
  factory _$SnAccountStatusCopyWith(_SnAccountStatus value, $Res Function(_SnAccountStatus) _then) = __$SnAccountStatusCopyWithImpl;
@override @useResult
$Res call({
 String id, int attitude, bool isOnline, bool isCustomized,@JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) int type, String label, String? symbol, Map<String, dynamic>? meta, DateTime? clearedAt, String? appIdentifier, bool isAutomated, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnAccountStatusCopyWithImpl<$Res>
    implements _$SnAccountStatusCopyWith<$Res> {
  __$SnAccountStatusCopyWithImpl(this._self, this._then);

  final _SnAccountStatus _self;
  final $Res Function(_SnAccountStatus) _then;

/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? attitude = null,Object? isOnline = null,Object? isCustomized = null,Object? type = null,Object? label = null,Object? symbol = freezed,Object? meta = freezed,Object? clearedAt = freezed,Object? appIdentifier = freezed,Object? isAutomated = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnAccountStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isCustomized: null == isCustomized ? _self.isCustomized : isCustomized // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clearedAt: freezed == clearedAt ? _self.clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,appIdentifier: freezed == appIdentifier ? _self.appIdentifier : appIdentifier // ignore: cast_nullable_to_non_nullable
as String?,isAutomated: null == isAutomated ? _self.isAutomated : isAutomated // ignore: cast_nullable_to_non_nullable
as bool,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnAccountBadge {

 String get id; String get type; String? get label; String? get caption; Map<String, dynamic> get meta; DateTime? get expiredAt; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get activatedAt; DateTime? get deletedAt;
/// Create a copy of SnAccountBadge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountBadgeCopyWith<SnAccountBadge> get copyWith => _$SnAccountBadgeCopyWithImpl<SnAccountBadge>(this as SnAccountBadge, _$identity);

  /// Serializes this SnAccountBadge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,label,caption,const DeepCollectionEquality().hash(meta),expiredAt,accountId,createdAt,updatedAt,activatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountBadge(id: $id, type: $type, label: $label, caption: $caption, meta: $meta, expiredAt: $expiredAt, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, activatedAt: $activatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnAccountBadgeCopyWith<$Res>  {
  factory $SnAccountBadgeCopyWith(SnAccountBadge value, $Res Function(SnAccountBadge) _then) = _$SnAccountBadgeCopyWithImpl;
@useResult
$Res call({
 String id, String type, String? label, String? caption, Map<String, dynamic> meta, DateTime? expiredAt, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? activatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnAccountBadgeCopyWithImpl<$Res>
    implements $SnAccountBadgeCopyWith<$Res> {
  _$SnAccountBadgeCopyWithImpl(this._self, this._then);

  final SnAccountBadge _self;
  final $Res Function(SnAccountBadge) _then;

/// Create a copy of SnAccountBadge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? label = freezed,Object? caption = freezed,Object? meta = null,Object? expiredAt = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? activatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAccountBadge].
extension SnAccountBadgePatterns on SnAccountBadge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccountBadge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccountBadge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccountBadge value)  $default,){
final _that = this;
switch (_that) {
case _SnAccountBadge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccountBadge value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccountBadge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String? label,  String? caption,  Map<String, dynamic> meta,  DateTime? expiredAt,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? activatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountBadge() when $default != null:
return $default(_that.id,_that.type,_that.label,_that.caption,_that.meta,_that.expiredAt,_that.accountId,_that.createdAt,_that.updatedAt,_that.activatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String? label,  String? caption,  Map<String, dynamic> meta,  DateTime? expiredAt,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? activatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnAccountBadge():
return $default(_that.id,_that.type,_that.label,_that.caption,_that.meta,_that.expiredAt,_that.accountId,_that.createdAt,_that.updatedAt,_that.activatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String? label,  String? caption,  Map<String, dynamic> meta,  DateTime? expiredAt,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? activatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountBadge() when $default != null:
return $default(_that.id,_that.type,_that.label,_that.caption,_that.meta,_that.expiredAt,_that.accountId,_that.createdAt,_that.updatedAt,_that.activatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountBadge implements SnAccountBadge {
  const _SnAccountBadge({required this.id, required this.type, required this.label, required this.caption, required final  Map<String, dynamic> meta, required this.expiredAt, required this.accountId, required this.createdAt, required this.updatedAt, required this.activatedAt, required this.deletedAt}): _meta = meta;
  factory _SnAccountBadge.fromJson(Map<String, dynamic> json) => _$SnAccountBadgeFromJson(json);

@override final  String id;
@override final  String type;
@override final  String? label;
@override final  String? caption;
 final  Map<String, dynamic> _meta;
@override Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

@override final  DateTime? expiredAt;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? activatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnAccountBadge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountBadgeCopyWith<_SnAccountBadge> get copyWith => __$SnAccountBadgeCopyWithImpl<_SnAccountBadge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountBadgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,label,caption,const DeepCollectionEquality().hash(_meta),expiredAt,accountId,createdAt,updatedAt,activatedAt,deletedAt);

@override
String toString() {
  return 'SnAccountBadge(id: $id, type: $type, label: $label, caption: $caption, meta: $meta, expiredAt: $expiredAt, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, activatedAt: $activatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnAccountBadgeCopyWith<$Res> implements $SnAccountBadgeCopyWith<$Res> {
  factory _$SnAccountBadgeCopyWith(_SnAccountBadge value, $Res Function(_SnAccountBadge) _then) = __$SnAccountBadgeCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String? label, String? caption, Map<String, dynamic> meta, DateTime? expiredAt, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? activatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnAccountBadgeCopyWithImpl<$Res>
    implements _$SnAccountBadgeCopyWith<$Res> {
  __$SnAccountBadgeCopyWithImpl(this._self, this._then);

  final _SnAccountBadge _self;
  final $Res Function(_SnAccountBadge) _then;

/// Create a copy of SnAccountBadge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? label = freezed,Object? caption = freezed,Object? meta = null,Object? expiredAt = freezed,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? activatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_SnAccountBadge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,activatedAt: freezed == activatedAt ? _self.activatedAt : activatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnContactMethod {

 String get id; int get type; DateTime? get verifiedAt; bool get isPrimary; bool get isPublic; String get content; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnContactMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnContactMethodCopyWith<SnContactMethod> get copyWith => _$SnContactMethodCopyWithImpl<SnContactMethod>(this as SnContactMethod, _$identity);

  /// Serializes this SnContactMethod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnContactMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.content, content) || other.content == content)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,verifiedAt,isPrimary,isPublic,content,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnContactMethod(id: $id, type: $type, verifiedAt: $verifiedAt, isPrimary: $isPrimary, isPublic: $isPublic, content: $content, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnContactMethodCopyWith<$Res>  {
  factory $SnContactMethodCopyWith(SnContactMethod value, $Res Function(SnContactMethod) _then) = _$SnContactMethodCopyWithImpl;
@useResult
$Res call({
 String id, int type, DateTime? verifiedAt, bool isPrimary, bool isPublic, String content, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnContactMethodCopyWithImpl<$Res>
    implements $SnContactMethodCopyWith<$Res> {
  _$SnContactMethodCopyWithImpl(this._self, this._then);

  final SnContactMethod _self;
  final $Res Function(SnContactMethod) _then;

/// Create a copy of SnContactMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? verifiedAt = freezed,Object? isPrimary = null,Object? isPublic = null,Object? content = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnContactMethod].
extension SnContactMethodPatterns on SnContactMethod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnContactMethod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnContactMethod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnContactMethod value)  $default,){
final _that = this;
switch (_that) {
case _SnContactMethod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnContactMethod value)?  $default,){
final _that = this;
switch (_that) {
case _SnContactMethod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int type,  DateTime? verifiedAt,  bool isPrimary,  bool isPublic,  String content,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnContactMethod() when $default != null:
return $default(_that.id,_that.type,_that.verifiedAt,_that.isPrimary,_that.isPublic,_that.content,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int type,  DateTime? verifiedAt,  bool isPrimary,  bool isPublic,  String content,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnContactMethod():
return $default(_that.id,_that.type,_that.verifiedAt,_that.isPrimary,_that.isPublic,_that.content,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int type,  DateTime? verifiedAt,  bool isPrimary,  bool isPublic,  String content,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnContactMethod() when $default != null:
return $default(_that.id,_that.type,_that.verifiedAt,_that.isPrimary,_that.isPublic,_that.content,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnContactMethod implements SnContactMethod {
  const _SnContactMethod({required this.id, required this.type, required this.verifiedAt, required this.isPrimary, required this.isPublic, required this.content, required this.accountId, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnContactMethod.fromJson(Map<String, dynamic> json) => _$SnContactMethodFromJson(json);

@override final  String id;
@override final  int type;
@override final  DateTime? verifiedAt;
@override final  bool isPrimary;
@override final  bool isPublic;
@override final  String content;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnContactMethod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnContactMethodCopyWith<_SnContactMethod> get copyWith => __$SnContactMethodCopyWithImpl<_SnContactMethod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnContactMethodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnContactMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.content, content) || other.content == content)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,verifiedAt,isPrimary,isPublic,content,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnContactMethod(id: $id, type: $type, verifiedAt: $verifiedAt, isPrimary: $isPrimary, isPublic: $isPublic, content: $content, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnContactMethodCopyWith<$Res> implements $SnContactMethodCopyWith<$Res> {
  factory _$SnContactMethodCopyWith(_SnContactMethod value, $Res Function(_SnContactMethod) _then) = __$SnContactMethodCopyWithImpl;
@override @useResult
$Res call({
 String id, int type, DateTime? verifiedAt, bool isPrimary, bool isPublic, String content, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnContactMethodCopyWithImpl<$Res>
    implements _$SnContactMethodCopyWith<$Res> {
  __$SnContactMethodCopyWithImpl(this._self, this._then);

  final _SnContactMethod _self;
  final $Res Function(_SnContactMethod) _then;

/// Create a copy of SnContactMethod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? verifiedAt = freezed,Object? isPrimary = null,Object? isPublic = null,Object? content = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnContactMethod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnNotification {

 DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; String get id; String get topic; String get title; String get subtitle; String get content; Map<String, dynamic> get meta; int get priority; DateTime? get viewedAt; String get accountId;
/// Create a copy of SnNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNotificationCopyWith<SnNotification> get copyWith => _$SnNotificationCopyWithImpl<SnNotification>(this as SnNotification, _$identity);

  /// Serializes this SnNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotification&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.meta, meta)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,topic,title,subtitle,content,const DeepCollectionEquality().hash(meta),priority,viewedAt,accountId);

@override
String toString() {
  return 'SnNotification(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, topic: $topic, title: $title, subtitle: $subtitle, content: $content, meta: $meta, priority: $priority, viewedAt: $viewedAt, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class $SnNotificationCopyWith<$Res>  {
  factory $SnNotificationCopyWith(SnNotification value, $Res Function(SnNotification) _then) = _$SnNotificationCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String topic, String title, String subtitle, String content, Map<String, dynamic> meta, int priority, DateTime? viewedAt, String accountId
});




}
/// @nodoc
class _$SnNotificationCopyWithImpl<$Res>
    implements $SnNotificationCopyWith<$Res> {
  _$SnNotificationCopyWithImpl(this._self, this._then);

  final SnNotification _self;
  final $Res Function(SnNotification) _then;

/// Create a copy of SnNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? topic = null,Object? title = null,Object? subtitle = null,Object? content = null,Object? meta = null,Object? priority = null,Object? viewedAt = freezed,Object? accountId = null,}) {
  return _then(_self.copyWith(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnNotification].
extension SnNotificationPatterns on SnNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnNotification value)  $default,){
final _that = this;
switch (_that) {
case _SnNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnNotification value)?  $default,){
final _that = this;
switch (_that) {
case _SnNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String topic,  String title,  String subtitle,  String content,  Map<String, dynamic> meta,  int priority,  DateTime? viewedAt,  String accountId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNotification() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.topic,_that.title,_that.subtitle,_that.content,_that.meta,_that.priority,_that.viewedAt,_that.accountId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String topic,  String title,  String subtitle,  String content,  Map<String, dynamic> meta,  int priority,  DateTime? viewedAt,  String accountId)  $default,) {final _that = this;
switch (_that) {
case _SnNotification():
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.topic,_that.title,_that.subtitle,_that.content,_that.meta,_that.priority,_that.viewedAt,_that.accountId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  String id,  String topic,  String title,  String subtitle,  String content,  Map<String, dynamic> meta,  int priority,  DateTime? viewedAt,  String accountId)?  $default,) {final _that = this;
switch (_that) {
case _SnNotification() when $default != null:
return $default(_that.createdAt,_that.updatedAt,_that.deletedAt,_that.id,_that.topic,_that.title,_that.subtitle,_that.content,_that.meta,_that.priority,_that.viewedAt,_that.accountId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNotification implements SnNotification {
  const _SnNotification({required this.createdAt, required this.updatedAt, required this.deletedAt, required this.id, required this.topic, required this.title, this.subtitle = '', required this.content, final  Map<String, dynamic> meta = const {}, required this.priority, required this.viewedAt, required this.accountId}): _meta = meta;
  factory _SnNotification.fromJson(Map<String, dynamic> json) => _$SnNotificationFromJson(json);

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  String id;
@override final  String topic;
@override final  String title;
@override@JsonKey() final  String subtitle;
@override final  String content;
 final  Map<String, dynamic> _meta;
@override@JsonKey() Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

@override final  int priority;
@override final  DateTime? viewedAt;
@override final  String accountId;

/// Create a copy of SnNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnNotificationCopyWith<_SnNotification> get copyWith => __$SnNotificationCopyWithImpl<_SnNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNotification&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._meta, _meta)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,createdAt,updatedAt,deletedAt,id,topic,title,subtitle,content,const DeepCollectionEquality().hash(_meta),priority,viewedAt,accountId);

@override
String toString() {
  return 'SnNotification(createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, id: $id, topic: $topic, title: $title, subtitle: $subtitle, content: $content, meta: $meta, priority: $priority, viewedAt: $viewedAt, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class _$SnNotificationCopyWith<$Res> implements $SnNotificationCopyWith<$Res> {
  factory _$SnNotificationCopyWith(_SnNotification value, $Res Function(_SnNotification) _then) = __$SnNotificationCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, String id, String topic, String title, String subtitle, String content, Map<String, dynamic> meta, int priority, DateTime? viewedAt, String accountId
});




}
/// @nodoc
class __$SnNotificationCopyWithImpl<$Res>
    implements _$SnNotificationCopyWith<$Res> {
  __$SnNotificationCopyWithImpl(this._self, this._then);

  final _SnNotification _self;
  final $Res Function(_SnNotification) _then;

/// Create a copy of SnNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? id = null,Object? topic = null,Object? title = null,Object? subtitle = null,Object? content = null,Object? meta = null,Object? priority = null,Object? viewedAt = freezed,Object? accountId = null,}) {
  return _then(_SnNotification(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SnVerificationMark {

 int get type; String? get title; String? get description; String? get verifiedBy;
/// Create a copy of SnVerificationMark
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<SnVerificationMark> get copyWith => _$SnVerificationMarkCopyWithImpl<SnVerificationMark>(this as SnVerificationMark, _$identity);

  /// Serializes this SnVerificationMark to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnVerificationMark&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,description,verifiedBy);

@override
String toString() {
  return 'SnVerificationMark(type: $type, title: $title, description: $description, verifiedBy: $verifiedBy)';
}


}

/// @nodoc
abstract mixin class $SnVerificationMarkCopyWith<$Res>  {
  factory $SnVerificationMarkCopyWith(SnVerificationMark value, $Res Function(SnVerificationMark) _then) = _$SnVerificationMarkCopyWithImpl;
@useResult
$Res call({
 int type, String? title, String? description, String? verifiedBy
});




}
/// @nodoc
class _$SnVerificationMarkCopyWithImpl<$Res>
    implements $SnVerificationMarkCopyWith<$Res> {
  _$SnVerificationMarkCopyWithImpl(this._self, this._then);

  final SnVerificationMark _self;
  final $Res Function(SnVerificationMark) _then;

/// Create a copy of SnVerificationMark
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? title = freezed,Object? description = freezed,Object? verifiedBy = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnVerificationMark].
extension SnVerificationMarkPatterns on SnVerificationMark {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnVerificationMark value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnVerificationMark() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnVerificationMark value)  $default,){
final _that = this;
switch (_that) {
case _SnVerificationMark():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnVerificationMark value)?  $default,){
final _that = this;
switch (_that) {
case _SnVerificationMark() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int type,  String? title,  String? description,  String? verifiedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnVerificationMark() when $default != null:
return $default(_that.type,_that.title,_that.description,_that.verifiedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int type,  String? title,  String? description,  String? verifiedBy)  $default,) {final _that = this;
switch (_that) {
case _SnVerificationMark():
return $default(_that.type,_that.title,_that.description,_that.verifiedBy);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int type,  String? title,  String? description,  String? verifiedBy)?  $default,) {final _that = this;
switch (_that) {
case _SnVerificationMark() when $default != null:
return $default(_that.type,_that.title,_that.description,_that.verifiedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnVerificationMark implements SnVerificationMark {
  const _SnVerificationMark({required this.type, required this.title, required this.description, required this.verifiedBy});
  factory _SnVerificationMark.fromJson(Map<String, dynamic> json) => _$SnVerificationMarkFromJson(json);

@override final  int type;
@override final  String? title;
@override final  String? description;
@override final  String? verifiedBy;

/// Create a copy of SnVerificationMark
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnVerificationMarkCopyWith<_SnVerificationMark> get copyWith => __$SnVerificationMarkCopyWithImpl<_SnVerificationMark>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnVerificationMarkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnVerificationMark&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,description,verifiedBy);

@override
String toString() {
  return 'SnVerificationMark(type: $type, title: $title, description: $description, verifiedBy: $verifiedBy)';
}


}

/// @nodoc
abstract mixin class _$SnVerificationMarkCopyWith<$Res> implements $SnVerificationMarkCopyWith<$Res> {
  factory _$SnVerificationMarkCopyWith(_SnVerificationMark value, $Res Function(_SnVerificationMark) _then) = __$SnVerificationMarkCopyWithImpl;
@override @useResult
$Res call({
 int type, String? title, String? description, String? verifiedBy
});




}
/// @nodoc
class __$SnVerificationMarkCopyWithImpl<$Res>
    implements _$SnVerificationMarkCopyWith<$Res> {
  __$SnVerificationMarkCopyWithImpl(this._self, this._then);

  final _SnVerificationMark _self;
  final $Res Function(_SnVerificationMark) _then;

/// Create a copy of SnVerificationMark
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? title = freezed,Object? description = freezed,Object? verifiedBy = freezed,}) {
  return _then(_SnVerificationMark(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SnAccountProfileRef {

 String get id; String get firstName; String get middleName; String get lastName; String get bio; SnCloudFileReference? get picture; SnCloudFileReference? get background; SnVerificationMark? get verification; UsernameColor? get usernameColor;
/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountProfileRefCopyWith<SnAccountProfileRef> get copyWith => _$SnAccountProfileRefCopyWithImpl<SnAccountProfileRef>(this as SnAccountProfileRef, _$identity);

  /// Serializes this SnAccountProfileRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountProfileRef&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.usernameColor, usernameColor) || other.usernameColor == usernameColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,middleName,lastName,bio,picture,background,verification,usernameColor);

@override
String toString() {
  return 'SnAccountProfileRef(id: $id, firstName: $firstName, middleName: $middleName, lastName: $lastName, bio: $bio, picture: $picture, background: $background, verification: $verification, usernameColor: $usernameColor)';
}


}

/// @nodoc
abstract mixin class $SnAccountProfileRefCopyWith<$Res>  {
  factory $SnAccountProfileRefCopyWith(SnAccountProfileRef value, $Res Function(SnAccountProfileRef) _then) = _$SnAccountProfileRefCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String middleName, String lastName, String bio, SnCloudFileReference? picture, SnCloudFileReference? background, SnVerificationMark? verification, UsernameColor? usernameColor
});


$SnCloudFileReferenceCopyWith<$Res>? get picture;$SnCloudFileReferenceCopyWith<$Res>? get background;$SnVerificationMarkCopyWith<$Res>? get verification;$UsernameColorCopyWith<$Res>? get usernameColor;

}
/// @nodoc
class _$SnAccountProfileRefCopyWithImpl<$Res>
    implements $SnAccountProfileRefCopyWith<$Res> {
  _$SnAccountProfileRefCopyWithImpl(this._self, this._then);

  final SnAccountProfileRef _self;
  final $Res Function(SnAccountProfileRef) _then;

/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? bio = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? usernameColor = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,usernameColor: freezed == usernameColor ? _self.usernameColor : usernameColor // ignore: cast_nullable_to_non_nullable
as UsernameColor?,
  ));
}
/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsernameColorCopyWith<$Res>? get usernameColor {
    if (_self.usernameColor == null) {
    return null;
  }

  return $UsernameColorCopyWith<$Res>(_self.usernameColor!, (value) {
    return _then(_self.copyWith(usernameColor: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnAccountProfileRef].
extension SnAccountProfileRefPatterns on SnAccountProfileRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccountProfileRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccountProfileRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccountProfileRef value)  $default,){
final _that = this;
switch (_that) {
case _SnAccountProfileRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccountProfileRef value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccountProfileRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String middleName,  String lastName,  String bio,  SnCloudFileReference? picture,  SnCloudFileReference? background,  SnVerificationMark? verification,  UsernameColor? usernameColor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountProfileRef() when $default != null:
return $default(_that.id,_that.firstName,_that.middleName,_that.lastName,_that.bio,_that.picture,_that.background,_that.verification,_that.usernameColor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String middleName,  String lastName,  String bio,  SnCloudFileReference? picture,  SnCloudFileReference? background,  SnVerificationMark? verification,  UsernameColor? usernameColor)  $default,) {final _that = this;
switch (_that) {
case _SnAccountProfileRef():
return $default(_that.id,_that.firstName,_that.middleName,_that.lastName,_that.bio,_that.picture,_that.background,_that.verification,_that.usernameColor);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String middleName,  String lastName,  String bio,  SnCloudFileReference? picture,  SnCloudFileReference? background,  SnVerificationMark? verification,  UsernameColor? usernameColor)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountProfileRef() when $default != null:
return $default(_that.id,_that.firstName,_that.middleName,_that.lastName,_that.bio,_that.picture,_that.background,_that.verification,_that.usernameColor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountProfileRef implements SnAccountProfileRef {
  const _SnAccountProfileRef({required this.id, this.firstName = '', this.middleName = '', this.lastName = '', this.bio = '', this.picture, this.background, this.verification, this.usernameColor});
  factory _SnAccountProfileRef.fromJson(Map<String, dynamic> json) => _$SnAccountProfileRefFromJson(json);

@override final  String id;
@override@JsonKey() final  String firstName;
@override@JsonKey() final  String middleName;
@override@JsonKey() final  String lastName;
@override@JsonKey() final  String bio;
@override final  SnCloudFileReference? picture;
@override final  SnCloudFileReference? background;
@override final  SnVerificationMark? verification;
@override final  UsernameColor? usernameColor;

/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountProfileRefCopyWith<_SnAccountProfileRef> get copyWith => __$SnAccountProfileRefCopyWithImpl<_SnAccountProfileRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountProfileRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountProfileRef&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.usernameColor, usernameColor) || other.usernameColor == usernameColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,middleName,lastName,bio,picture,background,verification,usernameColor);

@override
String toString() {
  return 'SnAccountProfileRef(id: $id, firstName: $firstName, middleName: $middleName, lastName: $lastName, bio: $bio, picture: $picture, background: $background, verification: $verification, usernameColor: $usernameColor)';
}


}

/// @nodoc
abstract mixin class _$SnAccountProfileRefCopyWith<$Res> implements $SnAccountProfileRefCopyWith<$Res> {
  factory _$SnAccountProfileRefCopyWith(_SnAccountProfileRef value, $Res Function(_SnAccountProfileRef) _then) = __$SnAccountProfileRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String middleName, String lastName, String bio, SnCloudFileReference? picture, SnCloudFileReference? background, SnVerificationMark? verification, UsernameColor? usernameColor
});


@override $SnCloudFileReferenceCopyWith<$Res>? get picture;@override $SnCloudFileReferenceCopyWith<$Res>? get background;@override $SnVerificationMarkCopyWith<$Res>? get verification;@override $UsernameColorCopyWith<$Res>? get usernameColor;

}
/// @nodoc
class __$SnAccountProfileRefCopyWithImpl<$Res>
    implements _$SnAccountProfileRefCopyWith<$Res> {
  __$SnAccountProfileRefCopyWithImpl(this._self, this._then);

  final _SnAccountProfileRef _self;
  final $Res Function(_SnAccountProfileRef) _then;

/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? middleName = null,Object? lastName = null,Object? bio = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? usernameColor = freezed,}) {
  return _then(_SnAccountProfileRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,middleName: null == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,usernameColor: freezed == usernameColor ? _self.usernameColor : usernameColor // ignore: cast_nullable_to_non_nullable
as UsernameColor?,
  ));
}

/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnVerificationMarkCopyWith<$Res>? get verification {
    if (_self.verification == null) {
    return null;
  }

  return $SnVerificationMarkCopyWith<$Res>(_self.verification!, (value) {
    return _then(_self.copyWith(verification: value));
  });
}/// Create a copy of SnAccountProfileRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UsernameColorCopyWith<$Res>? get usernameColor {
    if (_self.usernameColor == null) {
    return null;
  }

  return $UsernameColorCopyWith<$Res>(_self.usernameColor!, (value) {
    return _then(_self.copyWith(usernameColor: value));
  });
}
}


/// @nodoc
mixin _$SnAccountReference {

 String get id; String get name; String get nick; SnAccountProfileRef? get profile; List<SnAccountBadge> get badges; String? get automatedId;
/// Create a copy of SnAccountReference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountReferenceCopyWith<SnAccountReference> get copyWith => _$SnAccountReferenceCopyWithImpl<SnAccountReference>(this as SnAccountReference, _$identity);

  /// Serializes this SnAccountReference to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountReference&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.automatedId, automatedId) || other.automatedId == automatedId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick,profile,const DeepCollectionEquality().hash(badges),automatedId);

@override
String toString() {
  return 'SnAccountReference(id: $id, name: $name, nick: $nick, profile: $profile, badges: $badges, automatedId: $automatedId)';
}


}

/// @nodoc
abstract mixin class $SnAccountReferenceCopyWith<$Res>  {
  factory $SnAccountReferenceCopyWith(SnAccountReference value, $Res Function(SnAccountReference) _then) = _$SnAccountReferenceCopyWithImpl;
@useResult
$Res call({
 String id, String name, String nick, SnAccountProfileRef? profile, List<SnAccountBadge> badges, String? automatedId
});


$SnAccountProfileRefCopyWith<$Res>? get profile;

}
/// @nodoc
class _$SnAccountReferenceCopyWithImpl<$Res>
    implements $SnAccountReferenceCopyWith<$Res> {
  _$SnAccountReferenceCopyWithImpl(this._self, this._then);

  final SnAccountReference _self;
  final $Res Function(SnAccountReference) _then;

/// Create a copy of SnAccountReference
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? nick = null,Object? profile = freezed,Object? badges = null,Object? automatedId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SnAccountProfileRef?,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<SnAccountBadge>,automatedId: freezed == automatedId ? _self.automatedId : automatedId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SnAccountReference
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountProfileRefCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $SnAccountProfileRefCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnAccountReference].
extension SnAccountReferencePatterns on SnAccountReference {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAccountReference value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAccountReference() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAccountReference value)  $default,){
final _that = this;
switch (_that) {
case _SnAccountReference():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAccountReference value)?  $default,){
final _that = this;
switch (_that) {
case _SnAccountReference() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String nick,  SnAccountProfileRef? profile,  List<SnAccountBadge> badges,  String? automatedId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountReference() when $default != null:
return $default(_that.id,_that.name,_that.nick,_that.profile,_that.badges,_that.automatedId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String nick,  SnAccountProfileRef? profile,  List<SnAccountBadge> badges,  String? automatedId)  $default,) {final _that = this;
switch (_that) {
case _SnAccountReference():
return $default(_that.id,_that.name,_that.nick,_that.profile,_that.badges,_that.automatedId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String nick,  SnAccountProfileRef? profile,  List<SnAccountBadge> badges,  String? automatedId)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountReference() when $default != null:
return $default(_that.id,_that.name,_that.nick,_that.profile,_that.badges,_that.automatedId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountReference extends SnAccountReference {
  const _SnAccountReference({required this.id, required this.name, required this.nick, this.profile, final  List<SnAccountBadge> badges = const [], this.automatedId}): _badges = badges,super._();
  factory _SnAccountReference.fromJson(Map<String, dynamic> json) => _$SnAccountReferenceFromJson(json);

@override final  String id;
@override final  String name;
@override final  String nick;
@override final  SnAccountProfileRef? profile;
 final  List<SnAccountBadge> _badges;
@override@JsonKey() List<SnAccountBadge> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

@override final  String? automatedId;

/// Create a copy of SnAccountReference
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAccountReferenceCopyWith<_SnAccountReference> get copyWith => __$SnAccountReferenceCopyWithImpl<_SnAccountReference>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAccountReferenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountReference&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.automatedId, automatedId) || other.automatedId == automatedId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nick,profile,const DeepCollectionEquality().hash(_badges),automatedId);

@override
String toString() {
  return 'SnAccountReference(id: $id, name: $name, nick: $nick, profile: $profile, badges: $badges, automatedId: $automatedId)';
}


}

/// @nodoc
abstract mixin class _$SnAccountReferenceCopyWith<$Res> implements $SnAccountReferenceCopyWith<$Res> {
  factory _$SnAccountReferenceCopyWith(_SnAccountReference value, $Res Function(_SnAccountReference) _then) = __$SnAccountReferenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String nick, SnAccountProfileRef? profile, List<SnAccountBadge> badges, String? automatedId
});


@override $SnAccountProfileRefCopyWith<$Res>? get profile;

}
/// @nodoc
class __$SnAccountReferenceCopyWithImpl<$Res>
    implements _$SnAccountReferenceCopyWith<$Res> {
  __$SnAccountReferenceCopyWithImpl(this._self, this._then);

  final _SnAccountReference _self;
  final $Res Function(_SnAccountReference) _then;

/// Create a copy of SnAccountReference
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? nick = null,Object? profile = freezed,Object? badges = null,Object? automatedId = freezed,}) {
  return _then(_SnAccountReference(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SnAccountProfileRef?,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<SnAccountBadge>,automatedId: freezed == automatedId ? _self.automatedId : automatedId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SnAccountReference
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountProfileRefCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $SnAccountProfileRefCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$SnAuthDevice {

 String get id; String get deviceId; String get deviceName; String? get deviceLabel; String get accountId; int get platform; bool get isCurrent;
/// Create a copy of SnAuthDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthDeviceCopyWith<SnAuthDevice> get copyWith => _$SnAuthDeviceCopyWithImpl<SnAuthDevice>(this as SnAuthDevice, _$identity);

  /// Serializes this SnAuthDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceLabel, deviceLabel) || other.deviceLabel == deviceLabel)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceId,deviceName,deviceLabel,accountId,platform,isCurrent);

@override
String toString() {
  return 'SnAuthDevice(id: $id, deviceId: $deviceId, deviceName: $deviceName, deviceLabel: $deviceLabel, accountId: $accountId, platform: $platform, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class $SnAuthDeviceCopyWith<$Res>  {
  factory $SnAuthDeviceCopyWith(SnAuthDevice value, $Res Function(SnAuthDevice) _then) = _$SnAuthDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, String accountId, int platform, bool isCurrent
});




}
/// @nodoc
class _$SnAuthDeviceCopyWithImpl<$Res>
    implements $SnAuthDeviceCopyWith<$Res> {
  _$SnAuthDeviceCopyWithImpl(this._self, this._then);

  final SnAuthDevice _self;
  final $Res Function(SnAuthDevice) _then;

/// Create a copy of SnAuthDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? accountId = null,Object? platform = null,Object? isCurrent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAuthDevice].
extension SnAuthDevicePatterns on SnAuthDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAuthDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAuthDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAuthDevice value)  $default,){
final _that = this;
switch (_that) {
case _SnAuthDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAuthDevice value)?  $default,){
final _that = this;
switch (_that) {
case _SnAuthDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  bool isCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAuthDevice() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.isCurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  bool isCurrent)  $default,) {final _that = this;
switch (_that) {
case _SnAuthDevice():
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.isCurrent);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  bool isCurrent)?  $default,) {final _that = this;
switch (_that) {
case _SnAuthDevice() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.isCurrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAuthDevice implements SnAuthDevice {
  const _SnAuthDevice({required this.id, required this.deviceId, required this.deviceName, required this.deviceLabel, required this.accountId, required this.platform, this.isCurrent = false});
  factory _SnAuthDevice.fromJson(Map<String, dynamic> json) => _$SnAuthDeviceFromJson(json);

@override final  String id;
@override final  String deviceId;
@override final  String deviceName;
@override final  String? deviceLabel;
@override final  String accountId;
@override final  int platform;
@override@JsonKey() final  bool isCurrent;

/// Create a copy of SnAuthDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAuthDeviceCopyWith<_SnAuthDevice> get copyWith => __$SnAuthDeviceCopyWithImpl<_SnAuthDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAuthDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceLabel, deviceLabel) || other.deviceLabel == deviceLabel)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceId,deviceName,deviceLabel,accountId,platform,isCurrent);

@override
String toString() {
  return 'SnAuthDevice(id: $id, deviceId: $deviceId, deviceName: $deviceName, deviceLabel: $deviceLabel, accountId: $accountId, platform: $platform, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$SnAuthDeviceCopyWith<$Res> implements $SnAuthDeviceCopyWith<$Res> {
  factory _$SnAuthDeviceCopyWith(_SnAuthDevice value, $Res Function(_SnAuthDevice) _then) = __$SnAuthDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, String accountId, int platform, bool isCurrent
});




}
/// @nodoc
class __$SnAuthDeviceCopyWithImpl<$Res>
    implements _$SnAuthDeviceCopyWith<$Res> {
  __$SnAuthDeviceCopyWithImpl(this._self, this._then);

  final _SnAuthDevice _self;
  final $Res Function(_SnAuthDevice) _then;

/// Create a copy of SnAuthDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? accountId = null,Object? platform = null,Object? isCurrent = null,}) {
  return _then(_SnAuthDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

SnAuthDeviceWithSession _$SnAuthDeviceWithSessionFromJson(
  Map<String, dynamic> json
) {
    return _SnAuthDeviceWithSessione.fromJson(
      json
    );
}

/// @nodoc
mixin _$SnAuthDeviceWithSession {

 String get id; String get deviceId; String get deviceName; String? get deviceLabel; String get accountId; int get platform; List<SnAuthSession> get sessions; bool get isCurrent;
/// Create a copy of SnAuthDeviceWithSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthDeviceWithSessionCopyWith<SnAuthDeviceWithSession> get copyWith => _$SnAuthDeviceWithSessionCopyWithImpl<SnAuthDeviceWithSession>(this as SnAuthDeviceWithSession, _$identity);

  /// Serializes this SnAuthDeviceWithSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthDeviceWithSession&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceLabel, deviceLabel) || other.deviceLabel == deviceLabel)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceId,deviceName,deviceLabel,accountId,platform,const DeepCollectionEquality().hash(sessions),isCurrent);

@override
String toString() {
  return 'SnAuthDeviceWithSession(id: $id, deviceId: $deviceId, deviceName: $deviceName, deviceLabel: $deviceLabel, accountId: $accountId, platform: $platform, sessions: $sessions, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class $SnAuthDeviceWithSessionCopyWith<$Res>  {
  factory $SnAuthDeviceWithSessionCopyWith(SnAuthDeviceWithSession value, $Res Function(SnAuthDeviceWithSession) _then) = _$SnAuthDeviceWithSessionCopyWithImpl;
@useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, String accountId, int platform, List<SnAuthSession> sessions, bool isCurrent
});




}
/// @nodoc
class _$SnAuthDeviceWithSessionCopyWithImpl<$Res>
    implements $SnAuthDeviceWithSessionCopyWith<$Res> {
  _$SnAuthDeviceWithSessionCopyWithImpl(this._self, this._then);

  final SnAuthDeviceWithSession _self;
  final $Res Function(SnAuthDeviceWithSession) _then;

/// Create a copy of SnAuthDeviceWithSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? accountId = null,Object? platform = null,Object? sessions = null,Object? isCurrent = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SnAuthSession>,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SnAuthDeviceWithSession].
extension SnAuthDeviceWithSessionPatterns on SnAuthDeviceWithSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnAuthDeviceWithSessione value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnAuthDeviceWithSessione() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnAuthDeviceWithSessione value)  $default,){
final _that = this;
switch (_that) {
case _SnAuthDeviceWithSessione():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnAuthDeviceWithSessione value)?  $default,){
final _that = this;
switch (_that) {
case _SnAuthDeviceWithSessione() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  List<SnAuthSession> sessions,  bool isCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAuthDeviceWithSessione() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.sessions,_that.isCurrent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  List<SnAuthSession> sessions,  bool isCurrent)  $default,) {final _that = this;
switch (_that) {
case _SnAuthDeviceWithSessione():
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.sessions,_that.isCurrent);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  List<SnAuthSession> sessions,  bool isCurrent)?  $default,) {final _that = this;
switch (_that) {
case _SnAuthDeviceWithSessione() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.sessions,_that.isCurrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAuthDeviceWithSessione implements SnAuthDeviceWithSession {
  const _SnAuthDeviceWithSessione({required this.id, required this.deviceId, required this.deviceName, required this.deviceLabel, required this.accountId, required this.platform, required final  List<SnAuthSession> sessions, this.isCurrent = false}): _sessions = sessions;
  factory _SnAuthDeviceWithSessione.fromJson(Map<String, dynamic> json) => _$SnAuthDeviceWithSessioneFromJson(json);

@override final  String id;
@override final  String deviceId;
@override final  String deviceName;
@override final  String? deviceLabel;
@override final  String accountId;
@override final  int platform;
 final  List<SnAuthSession> _sessions;
@override List<SnAuthSession> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

@override@JsonKey() final  bool isCurrent;

/// Create a copy of SnAuthDeviceWithSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnAuthDeviceWithSessioneCopyWith<_SnAuthDeviceWithSessione> get copyWith => __$SnAuthDeviceWithSessioneCopyWithImpl<_SnAuthDeviceWithSessione>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnAuthDeviceWithSessioneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthDeviceWithSessione&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceLabel, deviceLabel) || other.deviceLabel == deviceLabel)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,deviceId,deviceName,deviceLabel,accountId,platform,const DeepCollectionEquality().hash(_sessions),isCurrent);

@override
String toString() {
  return 'SnAuthDeviceWithSession(id: $id, deviceId: $deviceId, deviceName: $deviceName, deviceLabel: $deviceLabel, accountId: $accountId, platform: $platform, sessions: $sessions, isCurrent: $isCurrent)';
}


}

/// @nodoc
abstract mixin class _$SnAuthDeviceWithSessioneCopyWith<$Res> implements $SnAuthDeviceWithSessionCopyWith<$Res> {
  factory _$SnAuthDeviceWithSessioneCopyWith(_SnAuthDeviceWithSessione value, $Res Function(_SnAuthDeviceWithSessione) _then) = __$SnAuthDeviceWithSessioneCopyWithImpl;
@override @useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, String accountId, int platform, List<SnAuthSession> sessions, bool isCurrent
});




}
/// @nodoc
class __$SnAuthDeviceWithSessioneCopyWithImpl<$Res>
    implements _$SnAuthDeviceWithSessioneCopyWith<$Res> {
  __$SnAuthDeviceWithSessioneCopyWithImpl(this._self, this._then);

  final _SnAuthDeviceWithSessione _self;
  final $Res Function(_SnAuthDeviceWithSessione) _then;

/// Create a copy of SnAuthDeviceWithSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? accountId = null,Object? platform = null,Object? sessions = null,Object? isCurrent = null,}) {
  return _then(_SnAuthDeviceWithSessione(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SnAuthSession>,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SnExperienceRecord {

 String get id; int get delta; String get reasonType; String get reason; double? get bonusMultiplier; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnExperienceRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnExperienceRecordCopyWith<SnExperienceRecord> get copyWith => _$SnExperienceRecordCopyWithImpl<SnExperienceRecord>(this as SnExperienceRecord, _$identity);

  /// Serializes this SnExperienceRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnExperienceRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.reasonType, reasonType) || other.reasonType == reasonType)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.bonusMultiplier, bonusMultiplier) || other.bonusMultiplier == bonusMultiplier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,delta,reasonType,reason,bonusMultiplier,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnExperienceRecord(id: $id, delta: $delta, reasonType: $reasonType, reason: $reason, bonusMultiplier: $bonusMultiplier, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnExperienceRecordCopyWith<$Res>  {
  factory $SnExperienceRecordCopyWith(SnExperienceRecord value, $Res Function(SnExperienceRecord) _then) = _$SnExperienceRecordCopyWithImpl;
@useResult
$Res call({
 String id, int delta, String reasonType, String reason, double? bonusMultiplier, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnExperienceRecordCopyWithImpl<$Res>
    implements $SnExperienceRecordCopyWith<$Res> {
  _$SnExperienceRecordCopyWithImpl(this._self, this._then);

  final SnExperienceRecord _self;
  final $Res Function(SnExperienceRecord) _then;

/// Create a copy of SnExperienceRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? delta = null,Object? reasonType = null,Object? reason = null,Object? bonusMultiplier = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as int,reasonType: null == reasonType ? _self.reasonType : reasonType // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,bonusMultiplier: freezed == bonusMultiplier ? _self.bonusMultiplier : bonusMultiplier // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnExperienceRecord].
extension SnExperienceRecordPatterns on SnExperienceRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnExperienceRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnExperienceRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnExperienceRecord value)  $default,){
final _that = this;
switch (_that) {
case _SnExperienceRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnExperienceRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SnExperienceRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int delta,  String reasonType,  String reason,  double? bonusMultiplier,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnExperienceRecord() when $default != null:
return $default(_that.id,_that.delta,_that.reasonType,_that.reason,_that.bonusMultiplier,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int delta,  String reasonType,  String reason,  double? bonusMultiplier,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnExperienceRecord():
return $default(_that.id,_that.delta,_that.reasonType,_that.reason,_that.bonusMultiplier,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int delta,  String reasonType,  String reason,  double? bonusMultiplier,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnExperienceRecord() when $default != null:
return $default(_that.id,_that.delta,_that.reasonType,_that.reason,_that.bonusMultiplier,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnExperienceRecord implements SnExperienceRecord {
  const _SnExperienceRecord({required this.id, required this.delta, required this.reasonType, required this.reason, this.bonusMultiplier = 1.0, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnExperienceRecord.fromJson(Map<String, dynamic> json) => _$SnExperienceRecordFromJson(json);

@override final  String id;
@override final  int delta;
@override final  String reasonType;
@override final  String reason;
@override@JsonKey() final  double? bonusMultiplier;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnExperienceRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnExperienceRecordCopyWith<_SnExperienceRecord> get copyWith => __$SnExperienceRecordCopyWithImpl<_SnExperienceRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnExperienceRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnExperienceRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.reasonType, reasonType) || other.reasonType == reasonType)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.bonusMultiplier, bonusMultiplier) || other.bonusMultiplier == bonusMultiplier)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,delta,reasonType,reason,bonusMultiplier,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnExperienceRecord(id: $id, delta: $delta, reasonType: $reasonType, reason: $reason, bonusMultiplier: $bonusMultiplier, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnExperienceRecordCopyWith<$Res> implements $SnExperienceRecordCopyWith<$Res> {
  factory _$SnExperienceRecordCopyWith(_SnExperienceRecord value, $Res Function(_SnExperienceRecord) _then) = __$SnExperienceRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, int delta, String reasonType, String reason, double? bonusMultiplier, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnExperienceRecordCopyWithImpl<$Res>
    implements _$SnExperienceRecordCopyWith<$Res> {
  __$SnExperienceRecordCopyWithImpl(this._self, this._then);

  final _SnExperienceRecord _self;
  final $Res Function(_SnExperienceRecord) _then;

/// Create a copy of SnExperienceRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? delta = null,Object? reasonType = null,Object? reason = null,Object? bonusMultiplier = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnExperienceRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as int,reasonType: null == reasonType ? _self.reasonType : reasonType // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,bonusMultiplier: freezed == bonusMultiplier ? _self.bonusMultiplier : bonusMultiplier // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnSocialCreditRecord {

 String get id; double get delta; String get reasonType; String get reason; DateTime? get expiredAt; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnSocialCreditRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSocialCreditRecordCopyWith<SnSocialCreditRecord> get copyWith => _$SnSocialCreditRecordCopyWithImpl<SnSocialCreditRecord>(this as SnSocialCreditRecord, _$identity);

  /// Serializes this SnSocialCreditRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSocialCreditRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.reasonType, reasonType) || other.reasonType == reasonType)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,delta,reasonType,reason,expiredAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSocialCreditRecord(id: $id, delta: $delta, reasonType: $reasonType, reason: $reason, expiredAt: $expiredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnSocialCreditRecordCopyWith<$Res>  {
  factory $SnSocialCreditRecordCopyWith(SnSocialCreditRecord value, $Res Function(SnSocialCreditRecord) _then) = _$SnSocialCreditRecordCopyWithImpl;
@useResult
$Res call({
 String id, double delta, String reasonType, String reason, DateTime? expiredAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnSocialCreditRecordCopyWithImpl<$Res>
    implements $SnSocialCreditRecordCopyWith<$Res> {
  _$SnSocialCreditRecordCopyWithImpl(this._self, this._then);

  final SnSocialCreditRecord _self;
  final $Res Function(SnSocialCreditRecord) _then;

/// Create a copy of SnSocialCreditRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? delta = null,Object? reasonType = null,Object? reason = null,Object? expiredAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as double,reasonType: null == reasonType ? _self.reasonType : reasonType // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnSocialCreditRecord].
extension SnSocialCreditRecordPatterns on SnSocialCreditRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSocialCreditRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSocialCreditRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSocialCreditRecord value)  $default,){
final _that = this;
switch (_that) {
case _SnSocialCreditRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSocialCreditRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SnSocialCreditRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double delta,  String reasonType,  String reason,  DateTime? expiredAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSocialCreditRecord() when $default != null:
return $default(_that.id,_that.delta,_that.reasonType,_that.reason,_that.expiredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double delta,  String reasonType,  String reason,  DateTime? expiredAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnSocialCreditRecord():
return $default(_that.id,_that.delta,_that.reasonType,_that.reason,_that.expiredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double delta,  String reasonType,  String reason,  DateTime? expiredAt,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnSocialCreditRecord() when $default != null:
return $default(_that.id,_that.delta,_that.reasonType,_that.reason,_that.expiredAt,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSocialCreditRecord implements SnSocialCreditRecord {
  const _SnSocialCreditRecord({required this.id, required this.delta, required this.reasonType, required this.reason, required this.expiredAt, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnSocialCreditRecord.fromJson(Map<String, dynamic> json) => _$SnSocialCreditRecordFromJson(json);

@override final  String id;
@override final  double delta;
@override final  String reasonType;
@override final  String reason;
@override final  DateTime? expiredAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnSocialCreditRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSocialCreditRecordCopyWith<_SnSocialCreditRecord> get copyWith => __$SnSocialCreditRecordCopyWithImpl<_SnSocialCreditRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSocialCreditRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSocialCreditRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.delta, delta) || other.delta == delta)&&(identical(other.reasonType, reasonType) || other.reasonType == reasonType)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,delta,reasonType,reason,expiredAt,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSocialCreditRecord(id: $id, delta: $delta, reasonType: $reasonType, reason: $reason, expiredAt: $expiredAt, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnSocialCreditRecordCopyWith<$Res> implements $SnSocialCreditRecordCopyWith<$Res> {
  factory _$SnSocialCreditRecordCopyWith(_SnSocialCreditRecord value, $Res Function(_SnSocialCreditRecord) _then) = __$SnSocialCreditRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, double delta, String reasonType, String reason, DateTime? expiredAt, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnSocialCreditRecordCopyWithImpl<$Res>
    implements _$SnSocialCreditRecordCopyWith<$Res> {
  __$SnSocialCreditRecordCopyWithImpl(this._self, this._then);

  final _SnSocialCreditRecord _self;
  final $Res Function(_SnSocialCreditRecord) _then;

/// Create a copy of SnSocialCreditRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? delta = null,Object? reasonType = null,Object? reason = null,Object? expiredAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnSocialCreditRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,delta: null == delta ? _self.delta : delta // ignore: cast_nullable_to_non_nullable
as double,reasonType: null == reasonType ? _self.reasonType : reasonType // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnFriendOverviewItem {

 SnAccount get account; SnAccountStatus get status; List<SnPresenceActivity> get activities;
/// Create a copy of SnFriendOverviewItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFriendOverviewItemCopyWith<SnFriendOverviewItem> get copyWith => _$SnFriendOverviewItemCopyWithImpl<SnFriendOverviewItem>(this as SnFriendOverviewItem, _$identity);

  /// Serializes this SnFriendOverviewItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFriendOverviewItem&&(identical(other.account, account) || other.account == account)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.activities, activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,account,status,const DeepCollectionEquality().hash(activities));

@override
String toString() {
  return 'SnFriendOverviewItem(account: $account, status: $status, activities: $activities)';
}


}

/// @nodoc
abstract mixin class $SnFriendOverviewItemCopyWith<$Res>  {
  factory $SnFriendOverviewItemCopyWith(SnFriendOverviewItem value, $Res Function(SnFriendOverviewItem) _then) = _$SnFriendOverviewItemCopyWithImpl;
@useResult
$Res call({
 SnAccount account, SnAccountStatus status, List<SnPresenceActivity> activities
});


$SnAccountCopyWith<$Res> get account;$SnAccountStatusCopyWith<$Res> get status;

}
/// @nodoc
class _$SnFriendOverviewItemCopyWithImpl<$Res>
    implements $SnFriendOverviewItemCopyWith<$Res> {
  _$SnFriendOverviewItemCopyWithImpl(this._self, this._then);

  final SnFriendOverviewItem _self;
  final $Res Function(SnFriendOverviewItem) _then;

/// Create a copy of SnFriendOverviewItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? account = null,Object? status = null,Object? activities = null,}) {
  return _then(_self.copyWith(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnAccountStatus,activities: null == activities ? _self.activities : activities // ignore: cast_nullable_to_non_nullable
as List<SnPresenceActivity>,
  ));
}
/// Create a copy of SnFriendOverviewItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get account {
  
  return $SnAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of SnFriendOverviewItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res> get status {
  
  return $SnAccountStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnFriendOverviewItem].
extension SnFriendOverviewItemPatterns on SnFriendOverviewItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFriendOverviewItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFriendOverviewItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFriendOverviewItem value)  $default,){
final _that = this;
switch (_that) {
case _SnFriendOverviewItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFriendOverviewItem value)?  $default,){
final _that = this;
switch (_that) {
case _SnFriendOverviewItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnAccount account,  SnAccountStatus status,  List<SnPresenceActivity> activities)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFriendOverviewItem() when $default != null:
return $default(_that.account,_that.status,_that.activities);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnAccount account,  SnAccountStatus status,  List<SnPresenceActivity> activities)  $default,) {final _that = this;
switch (_that) {
case _SnFriendOverviewItem():
return $default(_that.account,_that.status,_that.activities);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnAccount account,  SnAccountStatus status,  List<SnPresenceActivity> activities)?  $default,) {final _that = this;
switch (_that) {
case _SnFriendOverviewItem() when $default != null:
return $default(_that.account,_that.status,_that.activities);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFriendOverviewItem implements SnFriendOverviewItem {
  const _SnFriendOverviewItem({required this.account, required this.status, required final  List<SnPresenceActivity> activities}): _activities = activities;
  factory _SnFriendOverviewItem.fromJson(Map<String, dynamic> json) => _$SnFriendOverviewItemFromJson(json);

@override final  SnAccount account;
@override final  SnAccountStatus status;
 final  List<SnPresenceActivity> _activities;
@override List<SnPresenceActivity> get activities {
  if (_activities is EqualUnmodifiableListView) return _activities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activities);
}


/// Create a copy of SnFriendOverviewItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFriendOverviewItemCopyWith<_SnFriendOverviewItem> get copyWith => __$SnFriendOverviewItemCopyWithImpl<_SnFriendOverviewItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFriendOverviewItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFriendOverviewItem&&(identical(other.account, account) || other.account == account)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._activities, _activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,account,status,const DeepCollectionEquality().hash(_activities));

@override
String toString() {
  return 'SnFriendOverviewItem(account: $account, status: $status, activities: $activities)';
}


}

/// @nodoc
abstract mixin class _$SnFriendOverviewItemCopyWith<$Res> implements $SnFriendOverviewItemCopyWith<$Res> {
  factory _$SnFriendOverviewItemCopyWith(_SnFriendOverviewItem value, $Res Function(_SnFriendOverviewItem) _then) = __$SnFriendOverviewItemCopyWithImpl;
@override @useResult
$Res call({
 SnAccount account, SnAccountStatus status, List<SnPresenceActivity> activities
});


@override $SnAccountCopyWith<$Res> get account;@override $SnAccountStatusCopyWith<$Res> get status;

}
/// @nodoc
class __$SnFriendOverviewItemCopyWithImpl<$Res>
    implements _$SnFriendOverviewItemCopyWith<$Res> {
  __$SnFriendOverviewItemCopyWithImpl(this._self, this._then);

  final _SnFriendOverviewItem _self;
  final $Res Function(_SnFriendOverviewItem) _then;

/// Create a copy of SnFriendOverviewItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? account = null,Object? status = null,Object? activities = null,}) {
  return _then(_SnFriendOverviewItem(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnAccountStatus,activities: null == activities ? _self._activities : activities // ignore: cast_nullable_to_non_nullable
as List<SnPresenceActivity>,
  ));
}

/// Create a copy of SnFriendOverviewItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get account {
  
  return $SnAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of SnFriendOverviewItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<$Res> get status {
  
  return $SnAccountStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// @nodoc
mixin _$SnNotificationPreference {

 String get id; String get accountId; String get topic; SnNotificationPreferenceLevel get preference; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnNotificationPreference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNotificationPreferenceCopyWith<SnNotificationPreference> get copyWith => _$SnNotificationPreferenceCopyWithImpl<SnNotificationPreference>(this as SnNotificationPreference, _$identity);

  /// Serializes this SnNotificationPreference to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotificationPreference&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.preference, preference) || other.preference == preference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,topic,preference,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnNotificationPreference(id: $id, accountId: $accountId, topic: $topic, preference: $preference, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnNotificationPreferenceCopyWith<$Res>  {
  factory $SnNotificationPreferenceCopyWith(SnNotificationPreference value, $Res Function(SnNotificationPreference) _then) = _$SnNotificationPreferenceCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String topic, SnNotificationPreferenceLevel preference, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnNotificationPreferenceCopyWithImpl<$Res>
    implements $SnNotificationPreferenceCopyWith<$Res> {
  _$SnNotificationPreferenceCopyWithImpl(this._self, this._then);

  final SnNotificationPreference _self;
  final $Res Function(SnNotificationPreference) _then;

/// Create a copy of SnNotificationPreference
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? topic = null,Object? preference = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,preference: null == preference ? _self.preference : preference // ignore: cast_nullable_to_non_nullable
as SnNotificationPreferenceLevel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnNotificationPreference].
extension SnNotificationPreferencePatterns on SnNotificationPreference {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnNotificationPreference value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnNotificationPreference() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnNotificationPreference value)  $default,){
final _that = this;
switch (_that) {
case _SnNotificationPreference():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnNotificationPreference value)?  $default,){
final _that = this;
switch (_that) {
case _SnNotificationPreference() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String topic,  SnNotificationPreferenceLevel preference,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNotificationPreference() when $default != null:
return $default(_that.id,_that.accountId,_that.topic,_that.preference,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String topic,  SnNotificationPreferenceLevel preference,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnNotificationPreference():
return $default(_that.id,_that.accountId,_that.topic,_that.preference,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String topic,  SnNotificationPreferenceLevel preference,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnNotificationPreference() when $default != null:
return $default(_that.id,_that.accountId,_that.topic,_that.preference,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNotificationPreference implements SnNotificationPreference {
  const _SnNotificationPreference({required this.id, required this.accountId, required this.topic, required this.preference, required this.createdAt, required this.updatedAt, this.deletedAt});
  factory _SnNotificationPreference.fromJson(Map<String, dynamic> json) => _$SnNotificationPreferenceFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String topic;
@override final  SnNotificationPreferenceLevel preference;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnNotificationPreference
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnNotificationPreferenceCopyWith<_SnNotificationPreference> get copyWith => __$SnNotificationPreferenceCopyWithImpl<_SnNotificationPreference>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnNotificationPreferenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNotificationPreference&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.preference, preference) || other.preference == preference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,topic,preference,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnNotificationPreference(id: $id, accountId: $accountId, topic: $topic, preference: $preference, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnNotificationPreferenceCopyWith<$Res> implements $SnNotificationPreferenceCopyWith<$Res> {
  factory _$SnNotificationPreferenceCopyWith(_SnNotificationPreference value, $Res Function(_SnNotificationPreference) _then) = __$SnNotificationPreferenceCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String topic, SnNotificationPreferenceLevel preference, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnNotificationPreferenceCopyWithImpl<$Res>
    implements _$SnNotificationPreferenceCopyWith<$Res> {
  __$SnNotificationPreferenceCopyWithImpl(this._self, this._then);

  final _SnNotificationPreference _self;
  final $Res Function(_SnNotificationPreference) _then;

/// Create a copy of SnNotificationPreference
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? topic = null,Object? preference = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnNotificationPreference(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,preference: null == preference ? _self.preference : preference // ignore: cast_nullable_to_non_nullable
as SnNotificationPreferenceLevel,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnNotificationTopic {

 String get topic; String get description; bool get isCustom;
/// Create a copy of SnNotificationTopic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNotificationTopicCopyWith<SnNotificationTopic> get copyWith => _$SnNotificationTopicCopyWithImpl<SnNotificationTopic>(this as SnNotificationTopic, _$identity);

  /// Serializes this SnNotificationTopic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotificationTopic&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.description, description) || other.description == description)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,topic,description,isCustom);

@override
String toString() {
  return 'SnNotificationTopic(topic: $topic, description: $description, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class $SnNotificationTopicCopyWith<$Res>  {
  factory $SnNotificationTopicCopyWith(SnNotificationTopic value, $Res Function(SnNotificationTopic) _then) = _$SnNotificationTopicCopyWithImpl;
@useResult
$Res call({
 String topic, String description, bool isCustom
});




}
/// @nodoc
class _$SnNotificationTopicCopyWithImpl<$Res>
    implements $SnNotificationTopicCopyWith<$Res> {
  _$SnNotificationTopicCopyWithImpl(this._self, this._then);

  final SnNotificationTopic _self;
  final $Res Function(SnNotificationTopic) _then;

/// Create a copy of SnNotificationTopic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topic = null,Object? description = null,Object? isCustom = null,}) {
  return _then(_self.copyWith(
topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SnNotificationTopic].
extension SnNotificationTopicPatterns on SnNotificationTopic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnNotificationTopic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnNotificationTopic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnNotificationTopic value)  $default,){
final _that = this;
switch (_that) {
case _SnNotificationTopic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnNotificationTopic value)?  $default,){
final _that = this;
switch (_that) {
case _SnNotificationTopic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String topic,  String description,  bool isCustom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNotificationTopic() when $default != null:
return $default(_that.topic,_that.description,_that.isCustom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String topic,  String description,  bool isCustom)  $default,) {final _that = this;
switch (_that) {
case _SnNotificationTopic():
return $default(_that.topic,_that.description,_that.isCustom);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String topic,  String description,  bool isCustom)?  $default,) {final _that = this;
switch (_that) {
case _SnNotificationTopic() when $default != null:
return $default(_that.topic,_that.description,_that.isCustom);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNotificationTopic implements SnNotificationTopic {
  const _SnNotificationTopic({required this.topic, required this.description, this.isCustom = false});
  factory _SnNotificationTopic.fromJson(Map<String, dynamic> json) => _$SnNotificationTopicFromJson(json);

@override final  String topic;
@override final  String description;
@override@JsonKey() final  bool isCustom;

/// Create a copy of SnNotificationTopic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnNotificationTopicCopyWith<_SnNotificationTopic> get copyWith => __$SnNotificationTopicCopyWithImpl<_SnNotificationTopic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnNotificationTopicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNotificationTopic&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.description, description) || other.description == description)&&(identical(other.isCustom, isCustom) || other.isCustom == isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,topic,description,isCustom);

@override
String toString() {
  return 'SnNotificationTopic(topic: $topic, description: $description, isCustom: $isCustom)';
}


}

/// @nodoc
abstract mixin class _$SnNotificationTopicCopyWith<$Res> implements $SnNotificationTopicCopyWith<$Res> {
  factory _$SnNotificationTopicCopyWith(_SnNotificationTopic value, $Res Function(_SnNotificationTopic) _then) = __$SnNotificationTopicCopyWithImpl;
@override @useResult
$Res call({
 String topic, String description, bool isCustom
});




}
/// @nodoc
class __$SnNotificationTopicCopyWithImpl<$Res>
    implements _$SnNotificationTopicCopyWith<$Res> {
  __$SnNotificationTopicCopyWithImpl(this._self, this._then);

  final _SnNotificationTopic _self;
  final $Res Function(_SnNotificationTopic) _then;

/// Create a copy of SnNotificationTopic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topic = null,Object? description = null,Object? isCustom = null,}) {
  return _then(_SnNotificationTopic(
topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isCustom: null == isCustom ? _self.isCustom : isCustom // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SnNotificationPushSubscription {

 String get id; String get accountId; String get deviceId; String get deviceToken; SnNotificationPushSubscriptionProvider get provider; bool get isActivated; DateTime? get lastUsedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SnNotificationPushSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNotificationPushSubscriptionCopyWith<SnNotificationPushSubscription> get copyWith => _$SnNotificationPushSubscriptionCopyWithImpl<SnNotificationPushSubscription>(this as SnNotificationPushSubscription, _$identity);

  /// Serializes this SnNotificationPushSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotificationPushSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceToken, deviceToken) || other.deviceToken == deviceToken)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.isActivated, isActivated) || other.isActivated == isActivated)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,deviceId,deviceToken,provider,isActivated,lastUsedAt,createdAt,updatedAt);

@override
String toString() {
  return 'SnNotificationPushSubscription(id: $id, accountId: $accountId, deviceId: $deviceId, deviceToken: $deviceToken, provider: $provider, isActivated: $isActivated, lastUsedAt: $lastUsedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnNotificationPushSubscriptionCopyWith<$Res>  {
  factory $SnNotificationPushSubscriptionCopyWith(SnNotificationPushSubscription value, $Res Function(SnNotificationPushSubscription) _then) = _$SnNotificationPushSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String deviceId, String deviceToken, SnNotificationPushSubscriptionProvider provider, bool isActivated, DateTime? lastUsedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SnNotificationPushSubscriptionCopyWithImpl<$Res>
    implements $SnNotificationPushSubscriptionCopyWith<$Res> {
  _$SnNotificationPushSubscriptionCopyWithImpl(this._self, this._then);

  final SnNotificationPushSubscription _self;
  final $Res Function(SnNotificationPushSubscription) _then;

/// Create a copy of SnNotificationPushSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? deviceId = null,Object? deviceToken = null,Object? provider = null,Object? isActivated = null,Object? lastUsedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceToken: null == deviceToken ? _self.deviceToken : deviceToken // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SnNotificationPushSubscriptionProvider,isActivated: null == isActivated ? _self.isActivated : isActivated // ignore: cast_nullable_to_non_nullable
as bool,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SnNotificationPushSubscription].
extension SnNotificationPushSubscriptionPatterns on SnNotificationPushSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnNotificationPushSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnNotificationPushSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnNotificationPushSubscription value)  $default,){
final _that = this;
switch (_that) {
case _SnNotificationPushSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnNotificationPushSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _SnNotificationPushSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String deviceId,  String deviceToken,  SnNotificationPushSubscriptionProvider provider,  bool isActivated,  DateTime? lastUsedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNotificationPushSubscription() when $default != null:
return $default(_that.id,_that.accountId,_that.deviceId,_that.deviceToken,_that.provider,_that.isActivated,_that.lastUsedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String deviceId,  String deviceToken,  SnNotificationPushSubscriptionProvider provider,  bool isActivated,  DateTime? lastUsedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnNotificationPushSubscription():
return $default(_that.id,_that.accountId,_that.deviceId,_that.deviceToken,_that.provider,_that.isActivated,_that.lastUsedAt,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String deviceId,  String deviceToken,  SnNotificationPushSubscriptionProvider provider,  bool isActivated,  DateTime? lastUsedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnNotificationPushSubscription() when $default != null:
return $default(_that.id,_that.accountId,_that.deviceId,_that.deviceToken,_that.provider,_that.isActivated,_that.lastUsedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNotificationPushSubscription implements SnNotificationPushSubscription {
  const _SnNotificationPushSubscription({required this.id, required this.accountId, required this.deviceId, required this.deviceToken, required this.provider, required this.isActivated, this.lastUsedAt, required this.createdAt, required this.updatedAt});
  factory _SnNotificationPushSubscription.fromJson(Map<String, dynamic> json) => _$SnNotificationPushSubscriptionFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String deviceId;
@override final  String deviceToken;
@override final  SnNotificationPushSubscriptionProvider provider;
@override final  bool isActivated;
@override final  DateTime? lastUsedAt;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SnNotificationPushSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnNotificationPushSubscriptionCopyWith<_SnNotificationPushSubscription> get copyWith => __$SnNotificationPushSubscriptionCopyWithImpl<_SnNotificationPushSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnNotificationPushSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNotificationPushSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceToken, deviceToken) || other.deviceToken == deviceToken)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.isActivated, isActivated) || other.isActivated == isActivated)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,deviceId,deviceToken,provider,isActivated,lastUsedAt,createdAt,updatedAt);

@override
String toString() {
  return 'SnNotificationPushSubscription(id: $id, accountId: $accountId, deviceId: $deviceId, deviceToken: $deviceToken, provider: $provider, isActivated: $isActivated, lastUsedAt: $lastUsedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnNotificationPushSubscriptionCopyWith<$Res> implements $SnNotificationPushSubscriptionCopyWith<$Res> {
  factory _$SnNotificationPushSubscriptionCopyWith(_SnNotificationPushSubscription value, $Res Function(_SnNotificationPushSubscription) _then) = __$SnNotificationPushSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String deviceId, String deviceToken, SnNotificationPushSubscriptionProvider provider, bool isActivated, DateTime? lastUsedAt, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SnNotificationPushSubscriptionCopyWithImpl<$Res>
    implements _$SnNotificationPushSubscriptionCopyWith<$Res> {
  __$SnNotificationPushSubscriptionCopyWithImpl(this._self, this._then);

  final _SnNotificationPushSubscription _self;
  final $Res Function(_SnNotificationPushSubscription) _then;

/// Create a copy of SnNotificationPushSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? deviceId = null,Object? deviceToken = null,Object? provider = null,Object? isActivated = null,Object? lastUsedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SnNotificationPushSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceToken: null == deviceToken ? _self.deviceToken : deviceToken // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SnNotificationPushSubscriptionProvider,isActivated: null == isActivated ? _self.isActivated : isActivated // ignore: cast_nullable_to_non_nullable
as bool,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
