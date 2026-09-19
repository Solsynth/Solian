// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
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
  final _this = this as SnAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccount&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.nick, _this.nick) || other.nick == _this.nick)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.region, _this.region) || other.region == _this.region)&&(identical(other.isSuperuser, _this.isSuperuser) || other.isSuperuser == _this.isSuperuser)&&(identical(other.automatedId, _this.automatedId) || other.automatedId == _this.automatedId)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.perkSubscription, _this.perkSubscription) || other.perkSubscription == _this.perkSubscription)&&const DeepCollectionEquality().equals(other.badges, _this.badges)&&const DeepCollectionEquality().equals(other.contacts, _this.contacts)&&(identical(other.activatedAt, _this.activatedAt) || other.activatedAt == _this.activatedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnAccount;
  return Object.hash(runtimeType,_this.id,_this.name,_this.nick,_this.language,_this.region,_this.isSuperuser,_this.automatedId,_this.profile,_this.perkSubscription,const DeepCollectionEquality().hash(_this.badges),const DeepCollectionEquality().hash(_this.contacts),_this.activatedAt,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as SnAccount;
  return 'SnAccount(id: ${_this.id}, name: ${_this.name}, nick: ${_this.nick}, language: ${_this.language}, region: ${_this.region}, isSuperuser: ${_this.isSuperuser}, automatedId: ${_this.automatedId}, profile: ${_this.profile}, perkSubscription: ${_this.perkSubscription}, badges: ${_this.badges}, contacts: ${_this.contacts}, activatedAt: ${_this.activatedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
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
  return _then(SnAccount(
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
  const _SnAccount({required this.id, required this.name, required this.nick, required this.language, this.region = "", required this.isSuperuser, required this.automatedId, required this.profile, required this.perkSubscription,  List<SnAccountBadge> badges = const [],  List<SnContactMethod> contacts = const [], required this.activatedAt, required this.createdAt, required this.updatedAt, required this.deletedAt}): _badges = badges,_contacts = contacts,super._();
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.language, language) || other.language == language)&&(identical(other.region, region) || other.region == region)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.automatedId, automatedId) || other.automatedId == automatedId)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.perkSubscription, perkSubscription) || other.perkSubscription == perkSubscription)&&const DeepCollectionEquality().equals(other.badges, _badges)&&const DeepCollectionEquality().equals(other.contacts, _contacts)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,nick,language,region,isSuperuser,automatedId,profile,perkSubscription,const DeepCollectionEquality().hash(_badges),const DeepCollectionEquality().hash(_contacts),activatedAt,createdAt,updatedAt,deletedAt);
}

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
  final _this = this as ProfileLink;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileLink&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileLink;
  return Object.hash(runtimeType,_this.name,_this.url);
}

@override
String toString() {
  final _this = this as ProfileLink;
  return 'ProfileLink(name: ${_this.name}, url: ${_this.url})';
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
  return _then(ProfileLink(
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
int get hashCode {
    return Object.hash(runtimeType,name,url);
}

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
  final _this = this as UsernameColor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UsernameColor&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.direction, _this.direction) || other.direction == _this.direction)&&const DeepCollectionEquality().equals(other.colors, _this.colors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UsernameColor;
  return Object.hash(runtimeType,_this.type,_this.value,_this.direction,const DeepCollectionEquality().hash(_this.colors));
}

@override
String toString() {
  final _this = this as UsernameColor;
  return 'UsernameColor(type: ${_this.type}, value: ${_this.value}, direction: ${_this.direction}, colors: ${_this.colors})';
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
  return _then(UsernameColor(
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
  const _UsernameColor({this.type = 'plain', this.value, this.direction,  List<String>? colors}): _colors = colors;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UsernameColor&&(identical(other.type, type) || other.type == type)&&(identical(other.value, value) || other.value == value)&&(identical(other.direction, direction) || other.direction == direction)&&const DeepCollectionEquality().equals(other.colors, _colors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,value,direction,const DeepCollectionEquality().hash(_colors));
}

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
  final _this = this as SnAccountProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.middleName, _this.middleName) || other.middleName == _this.middleName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.pronouns, _this.pronouns) || other.pronouns == _this.pronouns)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.timeZone, _this.timeZone) || other.timeZone == _this.timeZone)&&(identical(other.birthday, _this.birthday) || other.birthday == _this.birthday)&&const DeepCollectionEquality().equals(other.links, _this.links)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.activeBadge, _this.activeBadge) || other.activeBadge == _this.activeBadge)&&(identical(other.experience, _this.experience) || other.experience == _this.experience)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.socialCredits, _this.socialCredits) || other.socialCredits == _this.socialCredits)&&(identical(other.socialCreditsLevel, _this.socialCreditsLevel) || other.socialCreditsLevel == _this.socialCreditsLevel)&&(identical(other.levelingProgress, _this.levelingProgress) || other.levelingProgress == _this.levelingProgress)&&(identical(other.picture, _this.picture) || other.picture == _this.picture)&&(identical(other.background, _this.background) || other.background == _this.background)&&(identical(other.verification, _this.verification) || other.verification == _this.verification)&&(identical(other.usernameColor, _this.usernameColor) || other.usernameColor == _this.usernameColor)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnAccountProfile;
  return Object.hashAll([runtimeType,_this.id,_this.firstName,_this.middleName,_this.lastName,_this.bio,_this.gender,_this.pronouns,_this.location,_this.timeZone,_this.birthday,const DeepCollectionEquality().hash(_this.links),_this.lastSeenAt,_this.activeBadge,_this.experience,_this.level,_this.socialCredits,_this.socialCreditsLevel,_this.levelingProgress,_this.picture,_this.background,_this.verification,_this.usernameColor,_this.createdAt,_this.updatedAt,_this.deletedAt]);
}

@override
String toString() {
  final _this = this as SnAccountProfile;
  return 'SnAccountProfile(id: ${_this.id}, firstName: ${_this.firstName}, middleName: ${_this.middleName}, lastName: ${_this.lastName}, bio: ${_this.bio}, gender: ${_this.gender}, pronouns: ${_this.pronouns}, location: ${_this.location}, timeZone: ${_this.timeZone}, birthday: ${_this.birthday}, links: ${_this.links}, lastSeenAt: ${_this.lastSeenAt}, activeBadge: ${_this.activeBadge}, experience: ${_this.experience}, level: ${_this.level}, socialCredits: ${_this.socialCredits}, socialCreditsLevel: ${_this.socialCreditsLevel}, levelingProgress: ${_this.levelingProgress}, picture: ${_this.picture}, background: ${_this.background}, verification: ${_this.verification}, usernameColor: ${_this.usernameColor}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
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
  return _then(SnAccountProfile(
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
  const _SnAccountProfile({required this.id, this.firstName = '', this.middleName = '', this.lastName = '', this.bio = '', this.gender = '', this.pronouns = '', this.location = '', this.timeZone = '', this.birthday, @ProfileLinkConverter()  List<ProfileLink> links = const [], this.lastSeenAt, this.activeBadge, required this.experience, required this.level, this.socialCredits = 100, this.socialCreditsLevel = 0, required this.levelingProgress, required this.picture, required this.background, required this.verification, this.usernameColor, required this.createdAt, required this.updatedAt, required this.deletedAt}): _links = links;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.pronouns, pronouns) || other.pronouns == pronouns)&&(identical(other.location, location) || other.location == location)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&const DeepCollectionEquality().equals(other.links, _links)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.activeBadge, activeBadge) || other.activeBadge == activeBadge)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.level, level) || other.level == level)&&(identical(other.socialCredits, socialCredits) || other.socialCredits == socialCredits)&&(identical(other.socialCreditsLevel, socialCreditsLevel) || other.socialCreditsLevel == socialCreditsLevel)&&(identical(other.levelingProgress, levelingProgress) || other.levelingProgress == levelingProgress)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.usernameColor, usernameColor) || other.usernameColor == usernameColor)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,firstName,middleName,lastName,bio,gender,pronouns,location,timeZone,birthday,const DeepCollectionEquality().hash(_links),lastSeenAt,activeBadge,experience,level,socialCredits,socialCreditsLevel,levelingProgress,picture,background,verification,usernameColor,createdAt,updatedAt,deletedAt]);
}

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

 String get id; int get attitude; bool get isOnline; bool get isIdle; DateTime? get idleSince; bool get isCustomized;@JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) int get type; String get label; String? get symbol; SnCloudFileReference? get icon; SnCloudFileReference? get background; Map<String, dynamic>? get meta; DateTime? get clearedAt; String? get appIdentifier; bool get isAutomated; String get accountId; SnAccount? get account; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; List<SnOnlineDevice> get onlineDevices;
/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAccountStatusCopyWith<SnAccountStatus> get copyWith => _$SnAccountStatusCopyWithImpl<SnAccountStatus>(this as SnAccountStatus, _$identity);

  /// Serializes this SnAccountStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnAccountStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountStatus&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.attitude, _this.attitude) || other.attitude == _this.attitude)&&(identical(other.isOnline, _this.isOnline) || other.isOnline == _this.isOnline)&&(identical(other.isIdle, _this.isIdle) || other.isIdle == _this.isIdle)&&(identical(other.idleSince, _this.idleSince) || other.idleSince == _this.idleSince)&&(identical(other.isCustomized, _this.isCustomized) || other.isCustomized == _this.isCustomized)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.symbol, _this.symbol) || other.symbol == _this.symbol)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.background, _this.background) || other.background == _this.background)&&const DeepCollectionEquality().equals(other.meta, _this.meta)&&(identical(other.clearedAt, _this.clearedAt) || other.clearedAt == _this.clearedAt)&&(identical(other.appIdentifier, _this.appIdentifier) || other.appIdentifier == _this.appIdentifier)&&(identical(other.isAutomated, _this.isAutomated) || other.isAutomated == _this.isAutomated)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&const DeepCollectionEquality().equals(other.onlineDevices, _this.onlineDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnAccountStatus;
  return Object.hashAll([runtimeType,_this.id,_this.attitude,_this.isOnline,_this.isIdle,_this.idleSince,_this.isCustomized,_this.type,_this.label,_this.symbol,_this.icon,_this.background,const DeepCollectionEquality().hash(_this.meta),_this.clearedAt,_this.appIdentifier,_this.isAutomated,_this.accountId,_this.account,_this.createdAt,_this.updatedAt,_this.deletedAt,const DeepCollectionEquality().hash(_this.onlineDevices)]);
}

@override
String toString() {
  final _this = this as SnAccountStatus;
  return 'SnAccountStatus(id: ${_this.id}, attitude: ${_this.attitude}, isOnline: ${_this.isOnline}, isIdle: ${_this.isIdle}, idleSince: ${_this.idleSince}, isCustomized: ${_this.isCustomized}, type: ${_this.type}, label: ${_this.label}, symbol: ${_this.symbol}, icon: ${_this.icon}, background: ${_this.background}, meta: ${_this.meta}, clearedAt: ${_this.clearedAt}, appIdentifier: ${_this.appIdentifier}, isAutomated: ${_this.isAutomated}, accountId: ${_this.accountId}, account: ${_this.account}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt}, onlineDevices: ${_this.onlineDevices})';
}


}

/// @nodoc
abstract mixin class $SnAccountStatusCopyWith<$Res>  {
  factory $SnAccountStatusCopyWith(SnAccountStatus value, $Res Function(SnAccountStatus) _then) = _$SnAccountStatusCopyWithImpl;
@useResult
$Res call({
 String id, int attitude, bool isOnline, bool isIdle, DateTime? idleSince, bool isCustomized,@JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) int type, String label, String? symbol, SnCloudFileReference? icon, SnCloudFileReference? background, Map<String, dynamic>? meta, DateTime? clearedAt, String? appIdentifier, bool isAutomated, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnOnlineDevice> onlineDevices
});


$SnCloudFileReferenceCopyWith<$Res>? get icon;$SnCloudFileReferenceCopyWith<$Res>? get background;$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnAccountStatusCopyWithImpl<$Res>
    implements $SnAccountStatusCopyWith<$Res> {
  _$SnAccountStatusCopyWithImpl(this._self, this._then);

  final SnAccountStatus _self;
  final $Res Function(SnAccountStatus) _then;

/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? attitude = null,Object? isOnline = null,Object? isIdle = null,Object? idleSince = freezed,Object? isCustomized = null,Object? type = null,Object? label = null,Object? symbol = freezed,Object? icon = freezed,Object? background = freezed,Object? meta = freezed,Object? clearedAt = freezed,Object? appIdentifier = freezed,Object? isAutomated = null,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? onlineDevices = null,}) {
  return _then(SnAccountStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isIdle: null == isIdle ? _self.isIdle : isIdle // ignore: cast_nullable_to_non_nullable
as bool,idleSince: freezed == idleSince ? _self.idleSince : idleSince // ignore: cast_nullable_to_non_nullable
as DateTime?,isCustomized: null == isCustomized ? _self.isCustomized : isCustomized // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clearedAt: freezed == clearedAt ? _self.clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,appIdentifier: freezed == appIdentifier ? _self.appIdentifier : appIdentifier // ignore: cast_nullable_to_non_nullable
as String?,isAutomated: null == isAutomated ? _self.isAutomated : isAutomated // ignore: cast_nullable_to_non_nullable
as bool,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,onlineDevices: null == onlineDevices ? _self.onlineDevices : onlineDevices // ignore: cast_nullable_to_non_nullable
as List<SnOnlineDevice>,
  ));
}
/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}/// Create a copy of SnAccountStatus
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
}/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int attitude,  bool isOnline,  bool isIdle,  DateTime? idleSince,  bool isCustomized, @JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson)  int type,  String label,  String? symbol,  SnCloudFileReference? icon,  SnCloudFileReference? background,  Map<String, dynamic>? meta,  DateTime? clearedAt,  String? appIdentifier,  bool isAutomated,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnOnlineDevice> onlineDevices)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAccountStatus() when $default != null:
return $default(_that.id,_that.attitude,_that.isOnline,_that.isIdle,_that.idleSince,_that.isCustomized,_that.type,_that.label,_that.symbol,_that.icon,_that.background,_that.meta,_that.clearedAt,_that.appIdentifier,_that.isAutomated,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.onlineDevices);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int attitude,  bool isOnline,  bool isIdle,  DateTime? idleSince,  bool isCustomized, @JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson)  int type,  String label,  String? symbol,  SnCloudFileReference? icon,  SnCloudFileReference? background,  Map<String, dynamic>? meta,  DateTime? clearedAt,  String? appIdentifier,  bool isAutomated,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnOnlineDevice> onlineDevices)  $default,) {final _that = this;
switch (_that) {
case _SnAccountStatus():
return $default(_that.id,_that.attitude,_that.isOnline,_that.isIdle,_that.idleSince,_that.isCustomized,_that.type,_that.label,_that.symbol,_that.icon,_that.background,_that.meta,_that.clearedAt,_that.appIdentifier,_that.isAutomated,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.onlineDevices);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int attitude,  bool isOnline,  bool isIdle,  DateTime? idleSince,  bool isCustomized, @JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson)  int type,  String label,  String? symbol,  SnCloudFileReference? icon,  SnCloudFileReference? background,  Map<String, dynamic>? meta,  DateTime? clearedAt,  String? appIdentifier,  bool isAutomated,  String accountId,  SnAccount? account,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  List<SnOnlineDevice> onlineDevices)?  $default,) {final _that = this;
switch (_that) {
case _SnAccountStatus() when $default != null:
return $default(_that.id,_that.attitude,_that.isOnline,_that.isIdle,_that.idleSince,_that.isCustomized,_that.type,_that.label,_that.symbol,_that.icon,_that.background,_that.meta,_that.clearedAt,_that.appIdentifier,_that.isAutomated,_that.accountId,_that.account,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.onlineDevices);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAccountStatus implements SnAccountStatus {
  const _SnAccountStatus({required this.id, required this.attitude, required this.isOnline, this.isIdle = false, this.idleSince, required this.isCustomized, @JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) this.type = SnAccountStatusType.defaultType, this.label = "", this.symbol, this.icon, this.background, required  Map<String, dynamic>? meta, required this.clearedAt, this.appIdentifier, this.isAutomated = false, required this.accountId, this.account, required this.createdAt, required this.updatedAt, required this.deletedAt,  List<SnOnlineDevice> onlineDevices = const []}): _meta = meta,_onlineDevices = onlineDevices;
  factory _SnAccountStatus.fromJson(Map<String, dynamic> json) => _$SnAccountStatusFromJson(json);

@override final  String id;
@override final  int attitude;
@override final  bool isOnline;
@override@JsonKey() final  bool isIdle;
@override final  DateTime? idleSince;
@override final  bool isCustomized;
@override@JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) final  int type;
@override@JsonKey() final  String label;
@override final  String? symbol;
@override final  SnCloudFileReference? icon;
@override final  SnCloudFileReference? background;
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
@override final  SnAccount? account;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
 final  List<SnOnlineDevice> _onlineDevices;
@override@JsonKey() List<SnOnlineDevice> get onlineDevices {
  if (_onlineDevices is EqualUnmodifiableListView) return _onlineDevices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_onlineDevices);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.attitude, attitude) || other.attitude == attitude)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.isIdle, isIdle) || other.isIdle == isIdle)&&(identical(other.idleSince, idleSince) || other.idleSince == idleSince)&&(identical(other.isCustomized, isCustomized) || other.isCustomized == isCustomized)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.background, background) || other.background == background)&&const DeepCollectionEquality().equals(other.meta, _meta)&&(identical(other.clearedAt, clearedAt) || other.clearedAt == clearedAt)&&(identical(other.appIdentifier, appIdentifier) || other.appIdentifier == appIdentifier)&&(identical(other.isAutomated, isAutomated) || other.isAutomated == isAutomated)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.account, account) || other.account == account)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other.onlineDevices, _onlineDevices));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,attitude,isOnline,isIdle,idleSince,isCustomized,type,label,symbol,icon,background,const DeepCollectionEquality().hash(_meta),clearedAt,appIdentifier,isAutomated,accountId,account,createdAt,updatedAt,deletedAt,const DeepCollectionEquality().hash(_onlineDevices)]);
}

@override
String toString() {
    return 'SnAccountStatus(id: $id, attitude: $attitude, isOnline: $isOnline, isIdle: $isIdle, idleSince: $idleSince, isCustomized: $isCustomized, type: $type, label: $label, symbol: $symbol, icon: $icon, background: $background, meta: $meta, clearedAt: $clearedAt, appIdentifier: $appIdentifier, isAutomated: $isAutomated, accountId: $accountId, account: $account, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, onlineDevices: $onlineDevices)';
}


}

/// @nodoc
abstract mixin class _$SnAccountStatusCopyWith<$Res> implements $SnAccountStatusCopyWith<$Res> {
  factory _$SnAccountStatusCopyWith(_SnAccountStatus value, $Res Function(_SnAccountStatus) _then) = __$SnAccountStatusCopyWithImpl;
@override @useResult
$Res call({
 String id, int attitude, bool isOnline, bool isIdle, DateTime? idleSince, bool isCustomized,@JsonKey(readValue: _readStatusType, fromJson: _statusTypeFromJson) int type, String label, String? symbol, SnCloudFileReference? icon, SnCloudFileReference? background, Map<String, dynamic>? meta, DateTime? clearedAt, String? appIdentifier, bool isAutomated, String accountId, SnAccount? account, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, List<SnOnlineDevice> onlineDevices
});


@override $SnCloudFileReferenceCopyWith<$Res>? get icon;@override $SnCloudFileReferenceCopyWith<$Res>? get background;@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnAccountStatusCopyWithImpl<$Res>
    implements _$SnAccountStatusCopyWith<$Res> {
  __$SnAccountStatusCopyWithImpl(this._self, this._then);

  final _SnAccountStatus _self;
  final $Res Function(_SnAccountStatus) _then;

/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? attitude = null,Object? isOnline = null,Object? isIdle = null,Object? idleSince = freezed,Object? isCustomized = null,Object? type = null,Object? label = null,Object? symbol = freezed,Object? icon = freezed,Object? background = freezed,Object? meta = freezed,Object? clearedAt = freezed,Object? appIdentifier = freezed,Object? isAutomated = null,Object? accountId = null,Object? account = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? onlineDevices = null,}) {
  return _then(_SnAccountStatus(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,attitude: null == attitude ? _self.attitude : attitude // ignore: cast_nullable_to_non_nullable
as int,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,isIdle: null == isIdle ? _self.isIdle : isIdle // ignore: cast_nullable_to_non_nullable
as bool,idleSince: freezed == idleSince ? _self.idleSince : idleSince // ignore: cast_nullable_to_non_nullable
as DateTime?,isCustomized: null == isCustomized ? _self.isCustomized : isCustomized // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,meta: freezed == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,clearedAt: freezed == clearedAt ? _self.clearedAt : clearedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,appIdentifier: freezed == appIdentifier ? _self.appIdentifier : appIdentifier // ignore: cast_nullable_to_non_nullable
as String?,isAutomated: null == isAutomated ? _self.isAutomated : isAutomated // ignore: cast_nullable_to_non_nullable
as bool,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,onlineDevices: null == onlineDevices ? _self._onlineDevices : onlineDevices // ignore: cast_nullable_to_non_nullable
as List<SnOnlineDevice>,
  ));
}

/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileReferenceCopyWith<$Res>? get icon {
    if (_self.icon == null) {
    return null;
  }

  return $SnCloudFileReferenceCopyWith<$Res>(_self.icon!, (value) {
    return _then(_self.copyWith(icon: value));
  });
}/// Create a copy of SnAccountStatus
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
}/// Create a copy of SnAccountStatus
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $SnAccountCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// @nodoc
mixin _$SnOnlineDevice {

 String get id; String get deviceId; String get deviceName; String? get deviceLabel; int get platform; DateTime? get lastGrantedAt;
/// Create a copy of SnOnlineDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnOnlineDeviceCopyWith<SnOnlineDevice> get copyWith => _$SnOnlineDeviceCopyWithImpl<SnOnlineDevice>(this as SnOnlineDevice, _$identity);

  /// Serializes this SnOnlineDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnOnlineDevice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnOnlineDevice&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.deviceLabel, _this.deviceLabel) || other.deviceLabel == _this.deviceLabel)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.lastGrantedAt, _this.lastGrantedAt) || other.lastGrantedAt == _this.lastGrantedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnOnlineDevice;
  return Object.hash(runtimeType,_this.id,_this.deviceId,_this.deviceName,_this.deviceLabel,_this.platform,_this.lastGrantedAt);
}

@override
String toString() {
  final _this = this as SnOnlineDevice;
  return 'SnOnlineDevice(id: ${_this.id}, deviceId: ${_this.deviceId}, deviceName: ${_this.deviceName}, deviceLabel: ${_this.deviceLabel}, platform: ${_this.platform}, lastGrantedAt: ${_this.lastGrantedAt})';
}


}

/// @nodoc
abstract mixin class $SnOnlineDeviceCopyWith<$Res>  {
  factory $SnOnlineDeviceCopyWith(SnOnlineDevice value, $Res Function(SnOnlineDevice) _then) = _$SnOnlineDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, int platform, DateTime? lastGrantedAt
});




}
/// @nodoc
class _$SnOnlineDeviceCopyWithImpl<$Res>
    implements $SnOnlineDeviceCopyWith<$Res> {
  _$SnOnlineDeviceCopyWithImpl(this._self, this._then);

  final SnOnlineDevice _self;
  final $Res Function(SnOnlineDevice) _then;

/// Create a copy of SnOnlineDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? platform = null,Object? lastGrantedAt = freezed,}) {
  return _then(SnOnlineDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,lastGrantedAt: freezed == lastGrantedAt ? _self.lastGrantedAt : lastGrantedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnOnlineDevice].
extension SnOnlineDevicePatterns on SnOnlineDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnOnlineDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnOnlineDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnOnlineDevice value)  $default,){
final _that = this;
switch (_that) {
case _SnOnlineDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnOnlineDevice value)?  $default,){
final _that = this;
switch (_that) {
case _SnOnlineDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  int platform,  DateTime? lastGrantedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnOnlineDevice() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.platform,_that.lastGrantedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  int platform,  DateTime? lastGrantedAt)  $default,) {final _that = this;
switch (_that) {
case _SnOnlineDevice():
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.platform,_that.lastGrantedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  int platform,  DateTime? lastGrantedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnOnlineDevice() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.platform,_that.lastGrantedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnOnlineDevice implements SnOnlineDevice {
  const _SnOnlineDevice({required this.id, required this.deviceId, required this.deviceName, this.deviceLabel, this.platform = 0, this.lastGrantedAt});
  factory _SnOnlineDevice.fromJson(Map<String, dynamic> json) => _$SnOnlineDeviceFromJson(json);

@override final  String id;
@override final  String deviceId;
@override final  String deviceName;
@override final  String? deviceLabel;
@override@JsonKey() final  int platform;
@override final  DateTime? lastGrantedAt;

/// Create a copy of SnOnlineDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnOnlineDeviceCopyWith<_SnOnlineDevice> get copyWith => __$SnOnlineDeviceCopyWithImpl<_SnOnlineDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnOnlineDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnOnlineDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceLabel, deviceLabel) || other.deviceLabel == deviceLabel)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.lastGrantedAt, lastGrantedAt) || other.lastGrantedAt == lastGrantedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,deviceId,deviceName,deviceLabel,platform,lastGrantedAt);
}

@override
String toString() {
    return 'SnOnlineDevice(id: $id, deviceId: $deviceId, deviceName: $deviceName, deviceLabel: $deviceLabel, platform: $platform, lastGrantedAt: $lastGrantedAt)';
}


}

/// @nodoc
abstract mixin class _$SnOnlineDeviceCopyWith<$Res> implements $SnOnlineDeviceCopyWith<$Res> {
  factory _$SnOnlineDeviceCopyWith(_SnOnlineDevice value, $Res Function(_SnOnlineDevice) _then) = __$SnOnlineDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, int platform, DateTime? lastGrantedAt
});




}
/// @nodoc
class __$SnOnlineDeviceCopyWithImpl<$Res>
    implements _$SnOnlineDeviceCopyWith<$Res> {
  __$SnOnlineDeviceCopyWithImpl(this._self, this._then);

  final _SnOnlineDevice _self;
  final $Res Function(_SnOnlineDevice) _then;

/// Create a copy of SnOnlineDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? platform = null,Object? lastGrantedAt = freezed,}) {
  return _then(_SnOnlineDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,lastGrantedAt: freezed == lastGrantedAt ? _self.lastGrantedAt : lastGrantedAt // ignore: cast_nullable_to_non_nullable
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
  final _this = this as SnAccountBadge;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountBadge&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.caption, _this.caption) || other.caption == _this.caption)&&const DeepCollectionEquality().equals(other.meta, _this.meta)&&(identical(other.expiredAt, _this.expiredAt) || other.expiredAt == _this.expiredAt)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.activatedAt, _this.activatedAt) || other.activatedAt == _this.activatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnAccountBadge;
  return Object.hash(runtimeType,_this.id,_this.type,_this.label,_this.caption,const DeepCollectionEquality().hash(_this.meta),_this.expiredAt,_this.accountId,_this.createdAt,_this.updatedAt,_this.activatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as SnAccountBadge;
  return 'SnAccountBadge(id: ${_this.id}, type: ${_this.type}, label: ${_this.label}, caption: ${_this.caption}, meta: ${_this.meta}, expiredAt: ${_this.expiredAt}, accountId: ${_this.accountId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, activatedAt: ${_this.activatedAt}, deletedAt: ${_this.deletedAt})';
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
  return _then(SnAccountBadge(
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
  const _SnAccountBadge({required this.id, required this.type, required this.label, required this.caption, required  Map<String, dynamic> meta, required this.expiredAt, required this.accountId, required this.createdAt, required this.updatedAt, required this.activatedAt, required this.deletedAt}): _meta = meta;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.label, label) || other.label == label)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other.meta, _meta)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.activatedAt, activatedAt) || other.activatedAt == activatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,label,caption,const DeepCollectionEquality().hash(_meta),expiredAt,accountId,createdAt,updatedAt,activatedAt,deletedAt);
}

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
mixin _$BadgeManifestSeries {

 String get identifier; String? get title; int get order;
/// Create a copy of BadgeManifestSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BadgeManifestSeriesCopyWith<BadgeManifestSeries> get copyWith => _$BadgeManifestSeriesCopyWithImpl<BadgeManifestSeries>(this as BadgeManifestSeries, _$identity);

  /// Serializes this BadgeManifestSeries to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BadgeManifestSeries;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BadgeManifestSeries&&(identical(other.identifier, _this.identifier) || other.identifier == _this.identifier)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.order, _this.order) || other.order == _this.order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BadgeManifestSeries;
  return Object.hash(runtimeType,_this.identifier,_this.title,_this.order);
}

@override
String toString() {
  final _this = this as BadgeManifestSeries;
  return 'BadgeManifestSeries(identifier: ${_this.identifier}, title: ${_this.title}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $BadgeManifestSeriesCopyWith<$Res>  {
  factory $BadgeManifestSeriesCopyWith(BadgeManifestSeries value, $Res Function(BadgeManifestSeries) _then) = _$BadgeManifestSeriesCopyWithImpl;
@useResult
$Res call({
 String identifier, String? title, int order
});




}
/// @nodoc
class _$BadgeManifestSeriesCopyWithImpl<$Res>
    implements $BadgeManifestSeriesCopyWith<$Res> {
  _$BadgeManifestSeriesCopyWithImpl(this._self, this._then);

  final BadgeManifestSeries _self;
  final $Res Function(BadgeManifestSeries) _then;

/// Create a copy of BadgeManifestSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identifier = null,Object? title = freezed,Object? order = null,}) {
  return _then(BadgeManifestSeries(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BadgeManifestSeries].
extension BadgeManifestSeriesPatterns on BadgeManifestSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BadgeManifestSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BadgeManifestSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BadgeManifestSeries value)  $default,){
final _that = this;
switch (_that) {
case _BadgeManifestSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BadgeManifestSeries value)?  $default,){
final _that = this;
switch (_that) {
case _BadgeManifestSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identifier,  String? title,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BadgeManifestSeries() when $default != null:
return $default(_that.identifier,_that.title,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identifier,  String? title,  int order)  $default,) {final _that = this;
switch (_that) {
case _BadgeManifestSeries():
return $default(_that.identifier,_that.title,_that.order);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identifier,  String? title,  int order)?  $default,) {final _that = this;
switch (_that) {
case _BadgeManifestSeries() when $default != null:
return $default(_that.identifier,_that.title,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BadgeManifestSeries implements BadgeManifestSeries {
  const _BadgeManifestSeries({required this.identifier, required this.title, this.order = 0});
  factory _BadgeManifestSeries.fromJson(Map<String, dynamic> json) => _$BadgeManifestSeriesFromJson(json);

@override final  String identifier;
@override final  String? title;
@override@JsonKey() final  int order;

/// Create a copy of BadgeManifestSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BadgeManifestSeriesCopyWith<_BadgeManifestSeries> get copyWith => __$BadgeManifestSeriesCopyWithImpl<_BadgeManifestSeries>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BadgeManifestSeriesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BadgeManifestSeries&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.title, title) || other.title == title)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,identifier,title,order);
}

@override
String toString() {
    return 'BadgeManifestSeries(identifier: $identifier, title: $title, order: $order)';
}


}

/// @nodoc
abstract mixin class _$BadgeManifestSeriesCopyWith<$Res> implements $BadgeManifestSeriesCopyWith<$Res> {
  factory _$BadgeManifestSeriesCopyWith(_BadgeManifestSeries value, $Res Function(_BadgeManifestSeries) _then) = __$BadgeManifestSeriesCopyWithImpl;
@override @useResult
$Res call({
 String identifier, String? title, int order
});




}
/// @nodoc
class __$BadgeManifestSeriesCopyWithImpl<$Res>
    implements _$BadgeManifestSeriesCopyWith<$Res> {
  __$BadgeManifestSeriesCopyWithImpl(this._self, this._then);

  final _BadgeManifestSeries _self;
  final $Res Function(_BadgeManifestSeries) _then;

/// Create a copy of BadgeManifestSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identifier = null,Object? title = freezed,Object? order = null,}) {
  return _then(_BadgeManifestSeries(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BadgeManifestEntry {

 String get identifier; String? get achievementIdentifier; String? get label; String? get caption; String? get icon; String? get color; String? get iconUrl; String? get localizationKey; String? get category; BadgeManifestSeries? get series; bool get hidden;
/// Create a copy of BadgeManifestEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BadgeManifestEntryCopyWith<BadgeManifestEntry> get copyWith => _$BadgeManifestEntryCopyWithImpl<BadgeManifestEntry>(this as BadgeManifestEntry, _$identity);

  /// Serializes this BadgeManifestEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BadgeManifestEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BadgeManifestEntry&&(identical(other.identifier, _this.identifier) || other.identifier == _this.identifier)&&(identical(other.achievementIdentifier, _this.achievementIdentifier) || other.achievementIdentifier == _this.achievementIdentifier)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.caption, _this.caption) || other.caption == _this.caption)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.iconUrl, _this.iconUrl) || other.iconUrl == _this.iconUrl)&&(identical(other.localizationKey, _this.localizationKey) || other.localizationKey == _this.localizationKey)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.hidden, _this.hidden) || other.hidden == _this.hidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BadgeManifestEntry;
  return Object.hash(runtimeType,_this.identifier,_this.achievementIdentifier,_this.label,_this.caption,_this.icon,_this.color,_this.iconUrl,_this.localizationKey,_this.category,_this.series,_this.hidden);
}

@override
String toString() {
  final _this = this as BadgeManifestEntry;
  return 'BadgeManifestEntry(identifier: ${_this.identifier}, achievementIdentifier: ${_this.achievementIdentifier}, label: ${_this.label}, caption: ${_this.caption}, icon: ${_this.icon}, color: ${_this.color}, iconUrl: ${_this.iconUrl}, localizationKey: ${_this.localizationKey}, category: ${_this.category}, series: ${_this.series}, hidden: ${_this.hidden})';
}


}

/// @nodoc
abstract mixin class $BadgeManifestEntryCopyWith<$Res>  {
  factory $BadgeManifestEntryCopyWith(BadgeManifestEntry value, $Res Function(BadgeManifestEntry) _then) = _$BadgeManifestEntryCopyWithImpl;
@useResult
$Res call({
 String identifier, String? achievementIdentifier, String? label, String? caption, String? icon, String? color, String? iconUrl, String? localizationKey, String? category, BadgeManifestSeries? series, bool hidden
});


$BadgeManifestSeriesCopyWith<$Res>? get series;

}
/// @nodoc
class _$BadgeManifestEntryCopyWithImpl<$Res>
    implements $BadgeManifestEntryCopyWith<$Res> {
  _$BadgeManifestEntryCopyWithImpl(this._self, this._then);

  final BadgeManifestEntry _self;
  final $Res Function(BadgeManifestEntry) _then;

/// Create a copy of BadgeManifestEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identifier = null,Object? achievementIdentifier = freezed,Object? label = freezed,Object? caption = freezed,Object? icon = freezed,Object? color = freezed,Object? iconUrl = freezed,Object? localizationKey = freezed,Object? category = freezed,Object? series = freezed,Object? hidden = null,}) {
  return _then(BadgeManifestEntry(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,achievementIdentifier: freezed == achievementIdentifier ? _self.achievementIdentifier : achievementIdentifier // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,localizationKey: freezed == localizationKey ? _self.localizationKey : localizationKey // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as BadgeManifestSeries?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of BadgeManifestEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BadgeManifestSeriesCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $BadgeManifestSeriesCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}
}


/// Adds pattern-matching-related methods to [BadgeManifestEntry].
extension BadgeManifestEntryPatterns on BadgeManifestEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BadgeManifestEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BadgeManifestEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BadgeManifestEntry value)  $default,){
final _that = this;
switch (_that) {
case _BadgeManifestEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BadgeManifestEntry value)?  $default,){
final _that = this;
switch (_that) {
case _BadgeManifestEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String identifier,  String? achievementIdentifier,  String? label,  String? caption,  String? icon,  String? color,  String? iconUrl,  String? localizationKey,  String? category,  BadgeManifestSeries? series,  bool hidden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BadgeManifestEntry() when $default != null:
return $default(_that.identifier,_that.achievementIdentifier,_that.label,_that.caption,_that.icon,_that.color,_that.iconUrl,_that.localizationKey,_that.category,_that.series,_that.hidden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String identifier,  String? achievementIdentifier,  String? label,  String? caption,  String? icon,  String? color,  String? iconUrl,  String? localizationKey,  String? category,  BadgeManifestSeries? series,  bool hidden)  $default,) {final _that = this;
switch (_that) {
case _BadgeManifestEntry():
return $default(_that.identifier,_that.achievementIdentifier,_that.label,_that.caption,_that.icon,_that.color,_that.iconUrl,_that.localizationKey,_that.category,_that.series,_that.hidden);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String identifier,  String? achievementIdentifier,  String? label,  String? caption,  String? icon,  String? color,  String? iconUrl,  String? localizationKey,  String? category,  BadgeManifestSeries? series,  bool hidden)?  $default,) {final _that = this;
switch (_that) {
case _BadgeManifestEntry() when $default != null:
return $default(_that.identifier,_that.achievementIdentifier,_that.label,_that.caption,_that.icon,_that.color,_that.iconUrl,_that.localizationKey,_that.category,_that.series,_that.hidden);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BadgeManifestEntry implements BadgeManifestEntry {
  const _BadgeManifestEntry({required this.identifier, this.achievementIdentifier, required this.label, this.caption, this.icon, this.color, this.iconUrl, this.localizationKey, this.category, this.series, this.hidden = false});
  factory _BadgeManifestEntry.fromJson(Map<String, dynamic> json) => _$BadgeManifestEntryFromJson(json);

@override final  String identifier;
@override final  String? achievementIdentifier;
@override final  String? label;
@override final  String? caption;
@override final  String? icon;
@override final  String? color;
@override final  String? iconUrl;
@override final  String? localizationKey;
@override final  String? category;
@override final  BadgeManifestSeries? series;
@override@JsonKey() final  bool hidden;

/// Create a copy of BadgeManifestEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BadgeManifestEntryCopyWith<_BadgeManifestEntry> get copyWith => __$BadgeManifestEntryCopyWithImpl<_BadgeManifestEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BadgeManifestEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BadgeManifestEntry&&(identical(other.identifier, identifier) || other.identifier == identifier)&&(identical(other.achievementIdentifier, achievementIdentifier) || other.achievementIdentifier == achievementIdentifier)&&(identical(other.label, label) || other.label == label)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.localizationKey, localizationKey) || other.localizationKey == localizationKey)&&(identical(other.category, category) || other.category == category)&&(identical(other.series, series) || other.series == series)&&(identical(other.hidden, hidden) || other.hidden == hidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,identifier,achievementIdentifier,label,caption,icon,color,iconUrl,localizationKey,category,series,hidden);
}

@override
String toString() {
    return 'BadgeManifestEntry(identifier: $identifier, achievementIdentifier: $achievementIdentifier, label: $label, caption: $caption, icon: $icon, color: $color, iconUrl: $iconUrl, localizationKey: $localizationKey, category: $category, series: $series, hidden: $hidden)';
}


}

/// @nodoc
abstract mixin class _$BadgeManifestEntryCopyWith<$Res> implements $BadgeManifestEntryCopyWith<$Res> {
  factory _$BadgeManifestEntryCopyWith(_BadgeManifestEntry value, $Res Function(_BadgeManifestEntry) _then) = __$BadgeManifestEntryCopyWithImpl;
@override @useResult
$Res call({
 String identifier, String? achievementIdentifier, String? label, String? caption, String? icon, String? color, String? iconUrl, String? localizationKey, String? category, BadgeManifestSeries? series, bool hidden
});


@override $BadgeManifestSeriesCopyWith<$Res>? get series;

}
/// @nodoc
class __$BadgeManifestEntryCopyWithImpl<$Res>
    implements _$BadgeManifestEntryCopyWith<$Res> {
  __$BadgeManifestEntryCopyWithImpl(this._self, this._then);

  final _BadgeManifestEntry _self;
  final $Res Function(_BadgeManifestEntry) _then;

/// Create a copy of BadgeManifestEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identifier = null,Object? achievementIdentifier = freezed,Object? label = freezed,Object? caption = freezed,Object? icon = freezed,Object? color = freezed,Object? iconUrl = freezed,Object? localizationKey = freezed,Object? category = freezed,Object? series = freezed,Object? hidden = null,}) {
  return _then(_BadgeManifestEntry(
identifier: null == identifier ? _self.identifier : identifier // ignore: cast_nullable_to_non_nullable
as String,achievementIdentifier: freezed == achievementIdentifier ? _self.achievementIdentifier : achievementIdentifier // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,localizationKey: freezed == localizationKey ? _self.localizationKey : localizationKey // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as BadgeManifestSeries?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of BadgeManifestEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BadgeManifestSeriesCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $BadgeManifestSeriesCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
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
  final _this = this as SnContactMethod;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnContactMethod&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.verifiedAt, _this.verifiedAt) || other.verifiedAt == _this.verifiedAt)&&(identical(other.isPrimary, _this.isPrimary) || other.isPrimary == _this.isPrimary)&&(identical(other.isPublic, _this.isPublic) || other.isPublic == _this.isPublic)&&(identical(other.content, _this.content) || other.content == _this.content)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnContactMethod;
  return Object.hash(runtimeType,_this.id,_this.type,_this.verifiedAt,_this.isPrimary,_this.isPublic,_this.content,_this.accountId,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as SnContactMethod;
  return 'SnContactMethod(id: ${_this.id}, type: ${_this.type}, verifiedAt: ${_this.verifiedAt}, isPrimary: ${_this.isPrimary}, isPublic: ${_this.isPublic}, content: ${_this.content}, accountId: ${_this.accountId}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
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
  return _then(SnContactMethod(
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
int get hashCode {
    return Object.hash(runtimeType,id,type,verifiedAt,isPrimary,isPublic,content,accountId,createdAt,updatedAt,deletedAt);
}

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

 DateTime get createdAt; String get id; String? get appId; String get topic; String get title; String get subtitle;@JsonKey(name: 'content') String get body; Map<String, dynamic> get meta; DateTime? get viewedAt; String get accountId;
/// Create a copy of SnNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNotificationCopyWith<SnNotification> get copyWith => _$SnNotificationCopyWithImpl<SnNotification>(this as SnNotification, _$identity);

  /// Serializes this SnNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnNotification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotification&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.appId, _this.appId) || other.appId == _this.appId)&&(identical(other.topic, _this.topic) || other.topic == _this.topic)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.subtitle, _this.subtitle) || other.subtitle == _this.subtitle)&&(identical(other.body, _this.body) || other.body == _this.body)&&const DeepCollectionEquality().equals(other.meta, _this.meta)&&(identical(other.viewedAt, _this.viewedAt) || other.viewedAt == _this.viewedAt)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnNotification;
  return Object.hash(runtimeType,_this.createdAt,_this.id,_this.appId,_this.topic,_this.title,_this.subtitle,_this.body,const DeepCollectionEquality().hash(_this.meta),_this.viewedAt,_this.accountId);
}

@override
String toString() {
  final _this = this as SnNotification;
  return 'SnNotification(createdAt: ${_this.createdAt}, id: ${_this.id}, appId: ${_this.appId}, topic: ${_this.topic}, title: ${_this.title}, subtitle: ${_this.subtitle}, body: ${_this.body}, meta: ${_this.meta}, viewedAt: ${_this.viewedAt}, accountId: ${_this.accountId})';
}


}

/// @nodoc
abstract mixin class $SnNotificationCopyWith<$Res>  {
  factory $SnNotificationCopyWith(SnNotification value, $Res Function(SnNotification) _then) = _$SnNotificationCopyWithImpl;
@useResult
$Res call({
 DateTime createdAt, String id, String? appId, String topic, String title, String subtitle,@JsonKey(name: 'content') String body, Map<String, dynamic> meta, DateTime? viewedAt, String accountId
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
@pragma('vm:prefer-inline') @override $Res call({Object? createdAt = null,Object? id = null,Object? appId = freezed,Object? topic = null,Object? title = null,Object? subtitle = null,Object? body = null,Object? meta = null,Object? viewedAt = freezed,Object? accountId = null,}) {
  return _then(SnNotification(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,appId: freezed == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String?,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime createdAt,  String id,  String? appId,  String topic,  String title,  String subtitle, @JsonKey(name: 'content')  String body,  Map<String, dynamic> meta,  DateTime? viewedAt,  String accountId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNotification() when $default != null:
return $default(_that.createdAt,_that.id,_that.appId,_that.topic,_that.title,_that.subtitle,_that.body,_that.meta,_that.viewedAt,_that.accountId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime createdAt,  String id,  String? appId,  String topic,  String title,  String subtitle, @JsonKey(name: 'content')  String body,  Map<String, dynamic> meta,  DateTime? viewedAt,  String accountId)  $default,) {final _that = this;
switch (_that) {
case _SnNotification():
return $default(_that.createdAt,_that.id,_that.appId,_that.topic,_that.title,_that.subtitle,_that.body,_that.meta,_that.viewedAt,_that.accountId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime createdAt,  String id,  String? appId,  String topic,  String title,  String subtitle, @JsonKey(name: 'content')  String body,  Map<String, dynamic> meta,  DateTime? viewedAt,  String accountId)?  $default,) {final _that = this;
switch (_that) {
case _SnNotification() when $default != null:
return $default(_that.createdAt,_that.id,_that.appId,_that.topic,_that.title,_that.subtitle,_that.body,_that.meta,_that.viewedAt,_that.accountId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNotification implements SnNotification {
  const _SnNotification({required this.createdAt, required this.id, this.appId, required this.topic, required this.title, this.subtitle = '', @JsonKey(name: 'content') required this.body,  Map<String, dynamic> meta = const {}, required this.viewedAt, required this.accountId}): _meta = meta;
  factory _SnNotification.fromJson(Map<String, dynamic> json) => _$SnNotificationFromJson(json);

@override final  DateTime createdAt;
@override final  String id;
@override final  String? appId;
@override final  String topic;
@override final  String title;
@override@JsonKey() final  String subtitle;
@override@JsonKey(name: 'content') final  String body;
 final  Map<String, dynamic> _meta;
@override@JsonKey() Map<String, dynamic> get meta {
  if (_meta is EqualUnmodifiableMapView) return _meta;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_meta);
}

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNotification&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.id, id) || other.id == id)&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.meta, _meta)&&(identical(other.viewedAt, viewedAt) || other.viewedAt == viewedAt)&&(identical(other.accountId, accountId) || other.accountId == accountId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,createdAt,id,appId,topic,title,subtitle,body,const DeepCollectionEquality().hash(_meta),viewedAt,accountId);
}

@override
String toString() {
    return 'SnNotification(createdAt: $createdAt, id: $id, appId: $appId, topic: $topic, title: $title, subtitle: $subtitle, body: $body, meta: $meta, viewedAt: $viewedAt, accountId: $accountId)';
}


}

/// @nodoc
abstract mixin class _$SnNotificationCopyWith<$Res> implements $SnNotificationCopyWith<$Res> {
  factory _$SnNotificationCopyWith(_SnNotification value, $Res Function(_SnNotification) _then) = __$SnNotificationCopyWithImpl;
@override @useResult
$Res call({
 DateTime createdAt, String id, String? appId, String topic, String title, String subtitle,@JsonKey(name: 'content') String body, Map<String, dynamic> meta, DateTime? viewedAt, String accountId
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
@override @pragma('vm:prefer-inline') $Res call({Object? createdAt = null,Object? id = null,Object? appId = freezed,Object? topic = null,Object? title = null,Object? subtitle = null,Object? body = null,Object? meta = null,Object? viewedAt = freezed,Object? accountId = null,}) {
  return _then(_SnNotification(
createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,appId: freezed == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String?,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,meta: null == meta ? _self._meta : meta // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,viewedAt: freezed == viewedAt ? _self.viewedAt : viewedAt // ignore: cast_nullable_to_non_nullable
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
  final _this = this as SnVerificationMark;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnVerificationMark&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.verifiedBy, _this.verifiedBy) || other.verifiedBy == _this.verifiedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnVerificationMark;
  return Object.hash(runtimeType,_this.type,_this.title,_this.description,_this.verifiedBy);
}

@override
String toString() {
  final _this = this as SnVerificationMark;
  return 'SnVerificationMark(type: ${_this.type}, title: ${_this.title}, description: ${_this.description}, verifiedBy: ${_this.verifiedBy})';
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
  return _then(SnVerificationMark(
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
int get hashCode {
    return Object.hash(runtimeType,type,title,description,verifiedBy);
}

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
  final _this = this as SnAccountProfileRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountProfileRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.middleName, _this.middleName) || other.middleName == _this.middleName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.picture, _this.picture) || other.picture == _this.picture)&&(identical(other.background, _this.background) || other.background == _this.background)&&(identical(other.verification, _this.verification) || other.verification == _this.verification)&&(identical(other.usernameColor, _this.usernameColor) || other.usernameColor == _this.usernameColor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnAccountProfileRef;
  return Object.hash(runtimeType,_this.id,_this.firstName,_this.middleName,_this.lastName,_this.bio,_this.picture,_this.background,_this.verification,_this.usernameColor);
}

@override
String toString() {
  final _this = this as SnAccountProfileRef;
  return 'SnAccountProfileRef(id: ${_this.id}, firstName: ${_this.firstName}, middleName: ${_this.middleName}, lastName: ${_this.lastName}, bio: ${_this.bio}, picture: ${_this.picture}, background: ${_this.background}, verification: ${_this.verification}, usernameColor: ${_this.usernameColor})';
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
  return _then(SnAccountProfileRef(
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
int get hashCode {
    return Object.hash(runtimeType,id,firstName,middleName,lastName,bio,picture,background,verification,usernameColor);
}

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
  final _this = this as SnAccountReference;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAccountReference&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.nick, _this.nick) || other.nick == _this.nick)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&const DeepCollectionEquality().equals(other.badges, _this.badges)&&(identical(other.automatedId, _this.automatedId) || other.automatedId == _this.automatedId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnAccountReference;
  return Object.hash(runtimeType,_this.id,_this.name,_this.nick,_this.profile,const DeepCollectionEquality().hash(_this.badges),_this.automatedId);
}

@override
String toString() {
  final _this = this as SnAccountReference;
  return 'SnAccountReference(id: ${_this.id}, name: ${_this.name}, nick: ${_this.nick}, profile: ${_this.profile}, badges: ${_this.badges}, automatedId: ${_this.automatedId})';
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
  return _then(SnAccountReference(
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
  const _SnAccountReference({required this.id, required this.name, required this.nick, this.profile,  List<SnAccountBadge> badges = const [], this.automatedId}): _badges = badges,super._();
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAccountReference&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.badges, _badges)&&(identical(other.automatedId, automatedId) || other.automatedId == automatedId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,nick,profile,const DeepCollectionEquality().hash(_badges),automatedId);
}

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

 String get id; String get deviceId; String get deviceName; String? get deviceLabel; String get accountId; int get platform; bool get isCurrent; String get category; bool get trusted; bool get isOnline;
/// Create a copy of SnAuthDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthDeviceCopyWith<SnAuthDevice> get copyWith => _$SnAuthDeviceCopyWithImpl<SnAuthDevice>(this as SnAuthDevice, _$identity);

  /// Serializes this SnAuthDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnAuthDevice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthDevice&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.deviceLabel, _this.deviceLabel) || other.deviceLabel == _this.deviceLabel)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&(identical(other.isCurrent, _this.isCurrent) || other.isCurrent == _this.isCurrent)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.trusted, _this.trusted) || other.trusted == _this.trusted)&&(identical(other.isOnline, _this.isOnline) || other.isOnline == _this.isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnAuthDevice;
  return Object.hash(runtimeType,_this.id,_this.deviceId,_this.deviceName,_this.deviceLabel,_this.accountId,_this.platform,_this.isCurrent,_this.category,_this.trusted,_this.isOnline);
}

@override
String toString() {
  final _this = this as SnAuthDevice;
  return 'SnAuthDevice(id: ${_this.id}, deviceId: ${_this.deviceId}, deviceName: ${_this.deviceName}, deviceLabel: ${_this.deviceLabel}, accountId: ${_this.accountId}, platform: ${_this.platform}, isCurrent: ${_this.isCurrent}, category: ${_this.category}, trusted: ${_this.trusted}, isOnline: ${_this.isOnline})';
}


}

/// @nodoc
abstract mixin class $SnAuthDeviceCopyWith<$Res>  {
  factory $SnAuthDeviceCopyWith(SnAuthDevice value, $Res Function(SnAuthDevice) _then) = _$SnAuthDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, String accountId, int platform, bool isCurrent, String category, bool trusted, bool isOnline
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? accountId = null,Object? platform = null,Object? isCurrent = null,Object? category = null,Object? trusted = null,Object? isOnline = null,}) {
  return _then(SnAuthDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,trusted: null == trusted ? _self.trusted : trusted // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  bool isCurrent,  String category,  bool trusted,  bool isOnline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAuthDevice() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.isCurrent,_that.category,_that.trusted,_that.isOnline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  bool isCurrent,  String category,  bool trusted,  bool isOnline)  $default,) {final _that = this;
switch (_that) {
case _SnAuthDevice():
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.isCurrent,_that.category,_that.trusted,_that.isOnline);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  bool isCurrent,  String category,  bool trusted,  bool isOnline)?  $default,) {final _that = this;
switch (_that) {
case _SnAuthDevice() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.isCurrent,_that.category,_that.trusted,_that.isOnline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAuthDevice implements SnAuthDevice {
  const _SnAuthDevice({required this.id, required this.deviceId, required this.deviceName, required this.deviceLabel, required this.accountId, required this.platform, this.isCurrent = false, this.category = 'device', this.trusted = false, this.isOnline = false});
  factory _SnAuthDevice.fromJson(Map<String, dynamic> json) => _$SnAuthDeviceFromJson(json);

@override final  String id;
@override final  String deviceId;
@override final  String deviceName;
@override final  String? deviceLabel;
@override final  String accountId;
@override final  int platform;
@override@JsonKey() final  bool isCurrent;
@override@JsonKey() final  String category;
@override@JsonKey() final  bool trusted;
@override@JsonKey() final  bool isOnline;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceLabel, deviceLabel) || other.deviceLabel == deviceLabel)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.category, category) || other.category == category)&&(identical(other.trusted, trusted) || other.trusted == trusted)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,deviceId,deviceName,deviceLabel,accountId,platform,isCurrent,category,trusted,isOnline);
}

@override
String toString() {
    return 'SnAuthDevice(id: $id, deviceId: $deviceId, deviceName: $deviceName, deviceLabel: $deviceLabel, accountId: $accountId, platform: $platform, isCurrent: $isCurrent, category: $category, trusted: $trusted, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class _$SnAuthDeviceCopyWith<$Res> implements $SnAuthDeviceCopyWith<$Res> {
  factory _$SnAuthDeviceCopyWith(_SnAuthDevice value, $Res Function(_SnAuthDevice) _then) = __$SnAuthDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, String accountId, int platform, bool isCurrent, String category, bool trusted, bool isOnline
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? accountId = null,Object? platform = null,Object? isCurrent = null,Object? category = null,Object? trusted = null,Object? isOnline = null,}) {
  return _then(_SnAuthDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,trusted: null == trusted ? _self.trusted : trusted // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
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

 String get id; String get deviceId; String get deviceName; String? get deviceLabel; String get accountId; int get platform; List<SnAuthSession> get sessions; bool get isCurrent; String get category; bool get trusted; bool get isOnline;
/// Create a copy of SnAuthDeviceWithSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnAuthDeviceWithSessionCopyWith<SnAuthDeviceWithSession> get copyWith => _$SnAuthDeviceWithSessionCopyWithImpl<SnAuthDeviceWithSession>(this as SnAuthDeviceWithSession, _$identity);

  /// Serializes this SnAuthDeviceWithSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnAuthDeviceWithSession;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnAuthDeviceWithSession&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.deviceLabel, _this.deviceLabel) || other.deviceLabel == _this.deviceLabel)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.platform, _this.platform) || other.platform == _this.platform)&&const DeepCollectionEquality().equals(other.sessions, _this.sessions)&&(identical(other.isCurrent, _this.isCurrent) || other.isCurrent == _this.isCurrent)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.trusted, _this.trusted) || other.trusted == _this.trusted)&&(identical(other.isOnline, _this.isOnline) || other.isOnline == _this.isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnAuthDeviceWithSession;
  return Object.hash(runtimeType,_this.id,_this.deviceId,_this.deviceName,_this.deviceLabel,_this.accountId,_this.platform,const DeepCollectionEquality().hash(_this.sessions),_this.isCurrent,_this.category,_this.trusted,_this.isOnline);
}

@override
String toString() {
  final _this = this as SnAuthDeviceWithSession;
  return 'SnAuthDeviceWithSession(id: ${_this.id}, deviceId: ${_this.deviceId}, deviceName: ${_this.deviceName}, deviceLabel: ${_this.deviceLabel}, accountId: ${_this.accountId}, platform: ${_this.platform}, sessions: ${_this.sessions}, isCurrent: ${_this.isCurrent}, category: ${_this.category}, trusted: ${_this.trusted}, isOnline: ${_this.isOnline})';
}


}

/// @nodoc
abstract mixin class $SnAuthDeviceWithSessionCopyWith<$Res>  {
  factory $SnAuthDeviceWithSessionCopyWith(SnAuthDeviceWithSession value, $Res Function(SnAuthDeviceWithSession) _then) = _$SnAuthDeviceWithSessionCopyWithImpl;
@useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, String accountId, int platform, List<SnAuthSession> sessions, bool isCurrent, String category, bool trusted, bool isOnline
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? accountId = null,Object? platform = null,Object? sessions = null,Object? isCurrent = null,Object? category = null,Object? trusted = null,Object? isOnline = null,}) {
  return _then(SnAuthDeviceWithSession(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SnAuthSession>,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,trusted: null == trusted ? _self.trusted : trusted // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  List<SnAuthSession> sessions,  bool isCurrent,  String category,  bool trusted,  bool isOnline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnAuthDeviceWithSessione() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.sessions,_that.isCurrent,_that.category,_that.trusted,_that.isOnline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  List<SnAuthSession> sessions,  bool isCurrent,  String category,  bool trusted,  bool isOnline)  $default,) {final _that = this;
switch (_that) {
case _SnAuthDeviceWithSessione():
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.sessions,_that.isCurrent,_that.category,_that.trusted,_that.isOnline);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deviceId,  String deviceName,  String? deviceLabel,  String accountId,  int platform,  List<SnAuthSession> sessions,  bool isCurrent,  String category,  bool trusted,  bool isOnline)?  $default,) {final _that = this;
switch (_that) {
case _SnAuthDeviceWithSessione() when $default != null:
return $default(_that.id,_that.deviceId,_that.deviceName,_that.deviceLabel,_that.accountId,_that.platform,_that.sessions,_that.isCurrent,_that.category,_that.trusted,_that.isOnline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnAuthDeviceWithSessione implements SnAuthDeviceWithSession {
  const _SnAuthDeviceWithSessione({required this.id, required this.deviceId, required this.deviceName, required this.deviceLabel, required this.accountId, required this.platform, required  List<SnAuthSession> sessions, this.isCurrent = false, this.category = 'device', this.trusted = false, this.isOnline = false}): _sessions = sessions;
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
@override@JsonKey() final  String category;
@override@JsonKey() final  bool trusted;
@override@JsonKey() final  bool isOnline;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnAuthDeviceWithSessione&&(identical(other.id, id) || other.id == id)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.deviceLabel, deviceLabel) || other.deviceLabel == deviceLabel)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.platform, platform) || other.platform == platform)&&const DeepCollectionEquality().equals(other.sessions, _sessions)&&(identical(other.isCurrent, isCurrent) || other.isCurrent == isCurrent)&&(identical(other.category, category) || other.category == category)&&(identical(other.trusted, trusted) || other.trusted == trusted)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,deviceId,deviceName,deviceLabel,accountId,platform,const DeepCollectionEquality().hash(_sessions),isCurrent,category,trusted,isOnline);
}

@override
String toString() {
    return 'SnAuthDeviceWithSession(id: $id, deviceId: $deviceId, deviceName: $deviceName, deviceLabel: $deviceLabel, accountId: $accountId, platform: $platform, sessions: $sessions, isCurrent: $isCurrent, category: $category, trusted: $trusted, isOnline: $isOnline)';
}


}

/// @nodoc
abstract mixin class _$SnAuthDeviceWithSessioneCopyWith<$Res> implements $SnAuthDeviceWithSessionCopyWith<$Res> {
  factory _$SnAuthDeviceWithSessioneCopyWith(_SnAuthDeviceWithSessione value, $Res Function(_SnAuthDeviceWithSessione) _then) = __$SnAuthDeviceWithSessioneCopyWithImpl;
@override @useResult
$Res call({
 String id, String deviceId, String deviceName, String? deviceLabel, String accountId, int platform, List<SnAuthSession> sessions, bool isCurrent, String category, bool trusted, bool isOnline
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deviceId = null,Object? deviceName = null,Object? deviceLabel = freezed,Object? accountId = null,Object? platform = null,Object? sessions = null,Object? isCurrent = null,Object? category = null,Object? trusted = null,Object? isOnline = null,}) {
  return _then(_SnAuthDeviceWithSessione(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceName: null == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String,deviceLabel: freezed == deviceLabel ? _self.deviceLabel : deviceLabel // ignore: cast_nullable_to_non_nullable
as String?,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as int,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<SnAuthSession>,isCurrent: null == isCurrent ? _self.isCurrent : isCurrent // ignore: cast_nullable_to_non_nullable
as bool,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,trusted: null == trusted ? _self.trusted : trusted // ignore: cast_nullable_to_non_nullable
as bool,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
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
  final _this = this as SnExperienceRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnExperienceRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.delta, _this.delta) || other.delta == _this.delta)&&(identical(other.reasonType, _this.reasonType) || other.reasonType == _this.reasonType)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.bonusMultiplier, _this.bonusMultiplier) || other.bonusMultiplier == _this.bonusMultiplier)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnExperienceRecord;
  return Object.hash(runtimeType,_this.id,_this.delta,_this.reasonType,_this.reason,_this.bonusMultiplier,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as SnExperienceRecord;
  return 'SnExperienceRecord(id: ${_this.id}, delta: ${_this.delta}, reasonType: ${_this.reasonType}, reason: ${_this.reason}, bonusMultiplier: ${_this.bonusMultiplier}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
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
  return _then(SnExperienceRecord(
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
int get hashCode {
    return Object.hash(runtimeType,id,delta,reasonType,reason,bonusMultiplier,createdAt,updatedAt,deletedAt);
}

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
  final _this = this as SnSocialCreditRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSocialCreditRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.delta, _this.delta) || other.delta == _this.delta)&&(identical(other.reasonType, _this.reasonType) || other.reasonType == _this.reasonType)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.expiredAt, _this.expiredAt) || other.expiredAt == _this.expiredAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnSocialCreditRecord;
  return Object.hash(runtimeType,_this.id,_this.delta,_this.reasonType,_this.reason,_this.expiredAt,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as SnSocialCreditRecord;
  return 'SnSocialCreditRecord(id: ${_this.id}, delta: ${_this.delta}, reasonType: ${_this.reasonType}, reason: ${_this.reason}, expiredAt: ${_this.expiredAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
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
  return _then(SnSocialCreditRecord(
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
int get hashCode {
    return Object.hash(runtimeType,id,delta,reasonType,reason,expiredAt,createdAt,updatedAt,deletedAt);
}

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
  final _this = this as SnFriendOverviewItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFriendOverviewItem&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.activities, _this.activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnFriendOverviewItem;
  return Object.hash(runtimeType,_this.account,_this.status,const DeepCollectionEquality().hash(_this.activities));
}

@override
String toString() {
  final _this = this as SnFriendOverviewItem;
  return 'SnFriendOverviewItem(account: ${_this.account}, status: ${_this.status}, activities: ${_this.activities})';
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
  return _then(SnFriendOverviewItem(
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
  const _SnFriendOverviewItem({required this.account, required this.status, required  List<SnPresenceActivity> activities}): _activities = activities;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFriendOverviewItem&&(identical(other.account, account) || other.account == account)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.activities, _activities));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,account,status,const DeepCollectionEquality().hash(_activities));
}

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
  final _this = this as SnNotificationPreference;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotificationPreference&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.topic, _this.topic) || other.topic == _this.topic)&&(identical(other.preference, _this.preference) || other.preference == _this.preference)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnNotificationPreference;
  return Object.hash(runtimeType,_this.id,_this.accountId,_this.topic,_this.preference,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as SnNotificationPreference;
  return 'SnNotificationPreference(id: ${_this.id}, accountId: ${_this.accountId}, topic: ${_this.topic}, preference: ${_this.preference}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
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
  return _then(SnNotificationPreference(
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
int get hashCode {
    return Object.hash(runtimeType,id,accountId,topic,preference,createdAt,updatedAt,deletedAt);
}

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
  final _this = this as SnNotificationTopic;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotificationTopic&&(identical(other.topic, _this.topic) || other.topic == _this.topic)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.isCustom, _this.isCustom) || other.isCustom == _this.isCustom));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnNotificationTopic;
  return Object.hash(runtimeType,_this.topic,_this.description,_this.isCustom);
}

@override
String toString() {
  final _this = this as SnNotificationTopic;
  return 'SnNotificationTopic(topic: ${_this.topic}, description: ${_this.description}, isCustom: ${_this.isCustom})';
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
  return _then(SnNotificationTopic(
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
int get hashCode {
    return Object.hash(runtimeType,topic,description,isCustom);
}

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

 String get id; String get accountId; String? get appId; String get deviceId; String get deviceToken; String? get deviceName; SnNotificationPushSubscriptionProvider get provider; bool get isActivated; DateTime? get lastUsedAt; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SnNotificationPushSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnNotificationPushSubscriptionCopyWith<SnNotificationPushSubscription> get copyWith => _$SnNotificationPushSubscriptionCopyWithImpl<SnNotificationPushSubscription>(this as SnNotificationPushSubscription, _$identity);

  /// Serializes this SnNotificationPushSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SnNotificationPushSubscription;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnNotificationPushSubscription&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.appId, _this.appId) || other.appId == _this.appId)&&(identical(other.deviceId, _this.deviceId) || other.deviceId == _this.deviceId)&&(identical(other.deviceToken, _this.deviceToken) || other.deviceToken == _this.deviceToken)&&(identical(other.deviceName, _this.deviceName) || other.deviceName == _this.deviceName)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.isActivated, _this.isActivated) || other.isActivated == _this.isActivated)&&(identical(other.lastUsedAt, _this.lastUsedAt) || other.lastUsedAt == _this.lastUsedAt)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SnNotificationPushSubscription;
  return Object.hash(runtimeType,_this.id,_this.accountId,_this.appId,_this.deviceId,_this.deviceToken,_this.deviceName,_this.provider,_this.isActivated,_this.lastUsedAt,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as SnNotificationPushSubscription;
  return 'SnNotificationPushSubscription(id: ${_this.id}, accountId: ${_this.accountId}, appId: ${_this.appId}, deviceId: ${_this.deviceId}, deviceToken: ${_this.deviceToken}, deviceName: ${_this.deviceName}, provider: ${_this.provider}, isActivated: ${_this.isActivated}, lastUsedAt: ${_this.lastUsedAt}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SnNotificationPushSubscriptionCopyWith<$Res>  {
  factory $SnNotificationPushSubscriptionCopyWith(SnNotificationPushSubscription value, $Res Function(SnNotificationPushSubscription) _then) = _$SnNotificationPushSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String? appId, String deviceId, String deviceToken, String? deviceName, SnNotificationPushSubscriptionProvider provider, bool isActivated, DateTime? lastUsedAt, DateTime createdAt, DateTime updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? appId = freezed,Object? deviceId = null,Object? deviceToken = null,Object? deviceName = freezed,Object? provider = null,Object? isActivated = null,Object? lastUsedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(SnNotificationPushSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,appId: freezed == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String?,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceToken: null == deviceToken ? _self.deviceToken : deviceToken // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String? appId,  String deviceId,  String deviceToken,  String? deviceName,  SnNotificationPushSubscriptionProvider provider,  bool isActivated,  DateTime? lastUsedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnNotificationPushSubscription() when $default != null:
return $default(_that.id,_that.accountId,_that.appId,_that.deviceId,_that.deviceToken,_that.deviceName,_that.provider,_that.isActivated,_that.lastUsedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String? appId,  String deviceId,  String deviceToken,  String? deviceName,  SnNotificationPushSubscriptionProvider provider,  bool isActivated,  DateTime? lastUsedAt,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnNotificationPushSubscription():
return $default(_that.id,_that.accountId,_that.appId,_that.deviceId,_that.deviceToken,_that.deviceName,_that.provider,_that.isActivated,_that.lastUsedAt,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String? appId,  String deviceId,  String deviceToken,  String? deviceName,  SnNotificationPushSubscriptionProvider provider,  bool isActivated,  DateTime? lastUsedAt,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnNotificationPushSubscription() when $default != null:
return $default(_that.id,_that.accountId,_that.appId,_that.deviceId,_that.deviceToken,_that.deviceName,_that.provider,_that.isActivated,_that.lastUsedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnNotificationPushSubscription implements SnNotificationPushSubscription {
  const _SnNotificationPushSubscription({required this.id, required this.accountId, this.appId, required this.deviceId, required this.deviceToken, this.deviceName, required this.provider, required this.isActivated, this.lastUsedAt, required this.createdAt, required this.updatedAt});
  factory _SnNotificationPushSubscription.fromJson(Map<String, dynamic> json) => _$SnNotificationPushSubscriptionFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String? appId;
@override final  String deviceId;
@override final  String deviceToken;
@override final  String? deviceName;
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnNotificationPushSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.appId, appId) || other.appId == appId)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.deviceToken, deviceToken) || other.deviceToken == deviceToken)&&(identical(other.deviceName, deviceName) || other.deviceName == deviceName)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.isActivated, isActivated) || other.isActivated == isActivated)&&(identical(other.lastUsedAt, lastUsedAt) || other.lastUsedAt == lastUsedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,accountId,appId,deviceId,deviceToken,deviceName,provider,isActivated,lastUsedAt,createdAt,updatedAt);
}

@override
String toString() {
    return 'SnNotificationPushSubscription(id: $id, accountId: $accountId, appId: $appId, deviceId: $deviceId, deviceToken: $deviceToken, deviceName: $deviceName, provider: $provider, isActivated: $isActivated, lastUsedAt: $lastUsedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnNotificationPushSubscriptionCopyWith<$Res> implements $SnNotificationPushSubscriptionCopyWith<$Res> {
  factory _$SnNotificationPushSubscriptionCopyWith(_SnNotificationPushSubscription value, $Res Function(_SnNotificationPushSubscription) _then) = __$SnNotificationPushSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String? appId, String deviceId, String deviceToken, String? deviceName, SnNotificationPushSubscriptionProvider provider, bool isActivated, DateTime? lastUsedAt, DateTime createdAt, DateTime updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? appId = freezed,Object? deviceId = null,Object? deviceToken = null,Object? deviceName = freezed,Object? provider = null,Object? isActivated = null,Object? lastUsedAt = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SnNotificationPushSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,appId: freezed == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String?,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,deviceToken: null == deviceToken ? _self.deviceToken : deviceToken // ignore: cast_nullable_to_non_nullable
as String,deviceName: freezed == deviceName ? _self.deviceName : deviceName // ignore: cast_nullable_to_non_nullable
as String?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SnNotificationPushSubscriptionProvider,isActivated: null == isActivated ? _self.isActivated : isActivated // ignore: cast_nullable_to_non_nullable
as bool,lastUsedAt: freezed == lastUsedAt ? _self.lastUsedAt : lastUsedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
