// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bot {

 String get id; String get slug; bool get isActive; String get projectId; DateTime get createdAt; DateTime get updatedAt; SnAccount get account; SnDeveloper? get developer;
/// Create a copy of Bot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotCopyWith<Bot> get copyWith => _$BotCopyWithImpl<Bot>(this as Bot, _$identity);

  /// Serializes this Bot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bot&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.account, account) || other.account == account)&&(identical(other.developer, developer) || other.developer == developer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,isActive,projectId,createdAt,updatedAt,account,developer);

@override
String toString() {
  return 'Bot(id: $id, slug: $slug, isActive: $isActive, projectId: $projectId, createdAt: $createdAt, updatedAt: $updatedAt, account: $account, developer: $developer)';
}


}

/// @nodoc
abstract mixin class $BotCopyWith<$Res>  {
  factory $BotCopyWith(Bot value, $Res Function(Bot) _then) = _$BotCopyWithImpl;
@useResult
$Res call({
 String id, String slug, bool isActive, String projectId, DateTime createdAt, DateTime updatedAt, SnAccount account, SnDeveloper? developer
});


$SnAccountCopyWith<$Res> get account;$SnDeveloperCopyWith<$Res>? get developer;

}
/// @nodoc
class _$BotCopyWithImpl<$Res>
    implements $BotCopyWith<$Res> {
  _$BotCopyWithImpl(this._self, this._then);

  final Bot _self;
  final $Res Function(Bot) _then;

/// Create a copy of Bot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? isActive = null,Object? projectId = null,Object? createdAt = null,Object? updatedAt = null,Object? account = null,Object? developer = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount,developer: freezed == developer ? _self.developer : developer // ignore: cast_nullable_to_non_nullable
as SnDeveloper?,
  ));
}
/// Create a copy of Bot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get account {
  
  return $SnAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of Bot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnDeveloperCopyWith<$Res>? get developer {
    if (_self.developer == null) {
    return null;
  }

  return $SnDeveloperCopyWith<$Res>(_self.developer!, (value) {
    return _then(_self.copyWith(developer: value));
  });
}
}


/// Adds pattern-matching-related methods to [Bot].
extension BotPatterns on Bot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bot value)  $default,){
final _that = this;
switch (_that) {
case _Bot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bot value)?  $default,){
final _that = this;
switch (_that) {
case _Bot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  bool isActive,  String projectId,  DateTime createdAt,  DateTime updatedAt,  SnAccount account,  SnDeveloper? developer)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bot() when $default != null:
return $default(_that.id,_that.slug,_that.isActive,_that.projectId,_that.createdAt,_that.updatedAt,_that.account,_that.developer);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  bool isActive,  String projectId,  DateTime createdAt,  DateTime updatedAt,  SnAccount account,  SnDeveloper? developer)  $default,) {final _that = this;
switch (_that) {
case _Bot():
return $default(_that.id,_that.slug,_that.isActive,_that.projectId,_that.createdAt,_that.updatedAt,_that.account,_that.developer);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  bool isActive,  String projectId,  DateTime createdAt,  DateTime updatedAt,  SnAccount account,  SnDeveloper? developer)?  $default,) {final _that = this;
switch (_that) {
case _Bot() when $default != null:
return $default(_that.id,_that.slug,_that.isActive,_that.projectId,_that.createdAt,_that.updatedAt,_that.account,_that.developer);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bot implements Bot {
  const _Bot({required this.id, required this.slug, required this.isActive, required this.projectId, required this.createdAt, required this.updatedAt, required this.account, this.developer});
  factory _Bot.fromJson(Map<String, dynamic> json) => _$BotFromJson(json);

@override final  String id;
@override final  String slug;
@override final  bool isActive;
@override final  String projectId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  SnAccount account;
@override final  SnDeveloper? developer;

/// Create a copy of Bot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotCopyWith<_Bot> get copyWith => __$BotCopyWithImpl<_Bot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bot&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.account, account) || other.account == account)&&(identical(other.developer, developer) || other.developer == developer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,isActive,projectId,createdAt,updatedAt,account,developer);

@override
String toString() {
  return 'Bot(id: $id, slug: $slug, isActive: $isActive, projectId: $projectId, createdAt: $createdAt, updatedAt: $updatedAt, account: $account, developer: $developer)';
}


}

/// @nodoc
abstract mixin class _$BotCopyWith<$Res> implements $BotCopyWith<$Res> {
  factory _$BotCopyWith(_Bot value, $Res Function(_Bot) _then) = __$BotCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, bool isActive, String projectId, DateTime createdAt, DateTime updatedAt, SnAccount account, SnDeveloper? developer
});


@override $SnAccountCopyWith<$Res> get account;@override $SnDeveloperCopyWith<$Res>? get developer;

}
/// @nodoc
class __$BotCopyWithImpl<$Res>
    implements _$BotCopyWith<$Res> {
  __$BotCopyWithImpl(this._self, this._then);

  final _Bot _self;
  final $Res Function(_Bot) _then;

/// Create a copy of Bot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? isActive = null,Object? projectId = null,Object? createdAt = null,Object? updatedAt = null,Object? account = null,Object? developer = freezed,}) {
  return _then(_Bot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount,developer: freezed == developer ? _self.developer : developer // ignore: cast_nullable_to_non_nullable
as SnDeveloper?,
  ));
}

/// Create a copy of Bot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnAccountCopyWith<$Res> get account {
  
  return $SnAccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of Bot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnDeveloperCopyWith<$Res>? get developer {
    if (_self.developer == null) {
    return null;
  }

  return $SnDeveloperCopyWith<$Res>(_self.developer!, (value) {
    return _then(_self.copyWith(developer: value));
  });
}
}


/// @nodoc
mixin _$BotConfig {

 bool get isPublic; bool get isInteractive; List<String> get allowedRealms; List<String> get allowedChatTypes; Map<String, dynamic> get metadata;
/// Create a copy of BotConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotConfigCopyWith<BotConfig> get copyWith => _$BotConfigCopyWithImpl<BotConfig>(this as BotConfig, _$identity);

  /// Serializes this BotConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotConfig&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isInteractive, isInteractive) || other.isInteractive == isInteractive)&&const DeepCollectionEquality().equals(other.allowedRealms, allowedRealms)&&const DeepCollectionEquality().equals(other.allowedChatTypes, allowedChatTypes)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPublic,isInteractive,const DeepCollectionEquality().hash(allowedRealms),const DeepCollectionEquality().hash(allowedChatTypes),const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'BotConfig(isPublic: $isPublic, isInteractive: $isInteractive, allowedRealms: $allowedRealms, allowedChatTypes: $allowedChatTypes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $BotConfigCopyWith<$Res>  {
  factory $BotConfigCopyWith(BotConfig value, $Res Function(BotConfig) _then) = _$BotConfigCopyWithImpl;
@useResult
$Res call({
 bool isPublic, bool isInteractive, List<String> allowedRealms, List<String> allowedChatTypes, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$BotConfigCopyWithImpl<$Res>
    implements $BotConfigCopyWith<$Res> {
  _$BotConfigCopyWithImpl(this._self, this._then);

  final BotConfig _self;
  final $Res Function(BotConfig) _then;

/// Create a copy of BotConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPublic = null,Object? isInteractive = null,Object? allowedRealms = null,Object? allowedChatTypes = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,isInteractive: null == isInteractive ? _self.isInteractive : isInteractive // ignore: cast_nullable_to_non_nullable
as bool,allowedRealms: null == allowedRealms ? _self.allowedRealms : allowedRealms // ignore: cast_nullable_to_non_nullable
as List<String>,allowedChatTypes: null == allowedChatTypes ? _self.allowedChatTypes : allowedChatTypes // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [BotConfig].
extension BotConfigPatterns on BotConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotConfig value)  $default,){
final _that = this;
switch (_that) {
case _BotConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotConfig value)?  $default,){
final _that = this;
switch (_that) {
case _BotConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPublic,  bool isInteractive,  List<String> allowedRealms,  List<String> allowedChatTypes,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotConfig() when $default != null:
return $default(_that.isPublic,_that.isInteractive,_that.allowedRealms,_that.allowedChatTypes,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPublic,  bool isInteractive,  List<String> allowedRealms,  List<String> allowedChatTypes,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _BotConfig():
return $default(_that.isPublic,_that.isInteractive,_that.allowedRealms,_that.allowedChatTypes,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPublic,  bool isInteractive,  List<String> allowedRealms,  List<String> allowedChatTypes,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _BotConfig() when $default != null:
return $default(_that.isPublic,_that.isInteractive,_that.allowedRealms,_that.allowedChatTypes,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotConfig implements BotConfig {
  const _BotConfig({this.isPublic = false, this.isInteractive = false, final  List<String> allowedRealms = const [], final  List<String> allowedChatTypes = const [], final  Map<String, dynamic> metadata = const {}}): _allowedRealms = allowedRealms,_allowedChatTypes = allowedChatTypes,_metadata = metadata;
  factory _BotConfig.fromJson(Map<String, dynamic> json) => _$BotConfigFromJson(json);

@override@JsonKey() final  bool isPublic;
@override@JsonKey() final  bool isInteractive;
 final  List<String> _allowedRealms;
@override@JsonKey() List<String> get allowedRealms {
  if (_allowedRealms is EqualUnmodifiableListView) return _allowedRealms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedRealms);
}

 final  List<String> _allowedChatTypes;
@override@JsonKey() List<String> get allowedChatTypes {
  if (_allowedChatTypes is EqualUnmodifiableListView) return _allowedChatTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedChatTypes);
}

 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of BotConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotConfigCopyWith<_BotConfig> get copyWith => __$BotConfigCopyWithImpl<_BotConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotConfig&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.isInteractive, isInteractive) || other.isInteractive == isInteractive)&&const DeepCollectionEquality().equals(other._allowedRealms, _allowedRealms)&&const DeepCollectionEquality().equals(other._allowedChatTypes, _allowedChatTypes)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPublic,isInteractive,const DeepCollectionEquality().hash(_allowedRealms),const DeepCollectionEquality().hash(_allowedChatTypes),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'BotConfig(isPublic: $isPublic, isInteractive: $isInteractive, allowedRealms: $allowedRealms, allowedChatTypes: $allowedChatTypes, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$BotConfigCopyWith<$Res> implements $BotConfigCopyWith<$Res> {
  factory _$BotConfigCopyWith(_BotConfig value, $Res Function(_BotConfig) _then) = __$BotConfigCopyWithImpl;
@override @useResult
$Res call({
 bool isPublic, bool isInteractive, List<String> allowedRealms, List<String> allowedChatTypes, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$BotConfigCopyWithImpl<$Res>
    implements _$BotConfigCopyWith<$Res> {
  __$BotConfigCopyWithImpl(this._self, this._then);

  final _BotConfig _self;
  final $Res Function(_BotConfig) _then;

/// Create a copy of BotConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPublic = null,Object? isInteractive = null,Object? allowedRealms = null,Object? allowedChatTypes = null,Object? metadata = null,}) {
  return _then(_BotConfig(
isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,isInteractive: null == isInteractive ? _self.isInteractive : isInteractive // ignore: cast_nullable_to_non_nullable
as bool,allowedRealms: null == allowedRealms ? _self._allowedRealms : allowedRealms // ignore: cast_nullable_to_non_nullable
as List<String>,allowedChatTypes: null == allowedChatTypes ? _self._allowedChatTypes : allowedChatTypes // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}


/// @nodoc
mixin _$BotLinks {

 String? get website; String? get documentation; String? get privacyPolicy; String? get termsOfService;
/// Create a copy of BotLinks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotLinksCopyWith<BotLinks> get copyWith => _$BotLinksCopyWithImpl<BotLinks>(this as BotLinks, _$identity);

  /// Serializes this BotLinks to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotLinks&&(identical(other.website, website) || other.website == website)&&(identical(other.documentation, documentation) || other.documentation == documentation)&&(identical(other.privacyPolicy, privacyPolicy) || other.privacyPolicy == privacyPolicy)&&(identical(other.termsOfService, termsOfService) || other.termsOfService == termsOfService));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,website,documentation,privacyPolicy,termsOfService);

@override
String toString() {
  return 'BotLinks(website: $website, documentation: $documentation, privacyPolicy: $privacyPolicy, termsOfService: $termsOfService)';
}


}

/// @nodoc
abstract mixin class $BotLinksCopyWith<$Res>  {
  factory $BotLinksCopyWith(BotLinks value, $Res Function(BotLinks) _then) = _$BotLinksCopyWithImpl;
@useResult
$Res call({
 String? website, String? documentation, String? privacyPolicy, String? termsOfService
});




}
/// @nodoc
class _$BotLinksCopyWithImpl<$Res>
    implements $BotLinksCopyWith<$Res> {
  _$BotLinksCopyWithImpl(this._self, this._then);

  final BotLinks _self;
  final $Res Function(BotLinks) _then;

/// Create a copy of BotLinks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? website = freezed,Object? documentation = freezed,Object? privacyPolicy = freezed,Object? termsOfService = freezed,}) {
  return _then(_self.copyWith(
website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,documentation: freezed == documentation ? _self.documentation : documentation // ignore: cast_nullable_to_non_nullable
as String?,privacyPolicy: freezed == privacyPolicy ? _self.privacyPolicy : privacyPolicy // ignore: cast_nullable_to_non_nullable
as String?,termsOfService: freezed == termsOfService ? _self.termsOfService : termsOfService // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BotLinks].
extension BotLinksPatterns on BotLinks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotLinks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotLinks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotLinks value)  $default,){
final _that = this;
switch (_that) {
case _BotLinks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotLinks value)?  $default,){
final _that = this;
switch (_that) {
case _BotLinks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? website,  String? documentation,  String? privacyPolicy,  String? termsOfService)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotLinks() when $default != null:
return $default(_that.website,_that.documentation,_that.privacyPolicy,_that.termsOfService);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? website,  String? documentation,  String? privacyPolicy,  String? termsOfService)  $default,) {final _that = this;
switch (_that) {
case _BotLinks():
return $default(_that.website,_that.documentation,_that.privacyPolicy,_that.termsOfService);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? website,  String? documentation,  String? privacyPolicy,  String? termsOfService)?  $default,) {final _that = this;
switch (_that) {
case _BotLinks() when $default != null:
return $default(_that.website,_that.documentation,_that.privacyPolicy,_that.termsOfService);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotLinks implements BotLinks {
  const _BotLinks({this.website, this.documentation, this.privacyPolicy, this.termsOfService});
  factory _BotLinks.fromJson(Map<String, dynamic> json) => _$BotLinksFromJson(json);

@override final  String? website;
@override final  String? documentation;
@override final  String? privacyPolicy;
@override final  String? termsOfService;

/// Create a copy of BotLinks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotLinksCopyWith<_BotLinks> get copyWith => __$BotLinksCopyWithImpl<_BotLinks>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotLinksToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotLinks&&(identical(other.website, website) || other.website == website)&&(identical(other.documentation, documentation) || other.documentation == documentation)&&(identical(other.privacyPolicy, privacyPolicy) || other.privacyPolicy == privacyPolicy)&&(identical(other.termsOfService, termsOfService) || other.termsOfService == termsOfService));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,website,documentation,privacyPolicy,termsOfService);

@override
String toString() {
  return 'BotLinks(website: $website, documentation: $documentation, privacyPolicy: $privacyPolicy, termsOfService: $termsOfService)';
}


}

/// @nodoc
abstract mixin class _$BotLinksCopyWith<$Res> implements $BotLinksCopyWith<$Res> {
  factory _$BotLinksCopyWith(_BotLinks value, $Res Function(_BotLinks) _then) = __$BotLinksCopyWithImpl;
@override @useResult
$Res call({
 String? website, String? documentation, String? privacyPolicy, String? termsOfService
});




}
/// @nodoc
class __$BotLinksCopyWithImpl<$Res>
    implements _$BotLinksCopyWith<$Res> {
  __$BotLinksCopyWithImpl(this._self, this._then);

  final _BotLinks _self;
  final $Res Function(_BotLinks) _then;

/// Create a copy of BotLinks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? website = freezed,Object? documentation = freezed,Object? privacyPolicy = freezed,Object? termsOfService = freezed,}) {
  return _then(_BotLinks(
website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,documentation: freezed == documentation ? _self.documentation : documentation // ignore: cast_nullable_to_non_nullable
as String?,privacyPolicy: freezed == privacyPolicy ? _self.privacyPolicy : privacyPolicy // ignore: cast_nullable_to_non_nullable
as String?,termsOfService: freezed == termsOfService ? _self.termsOfService : termsOfService // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BotSecret {

 String get id; String get secret; String? get description; DateTime? get expiredAt; String get botId;
/// Create a copy of BotSecret
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BotSecretCopyWith<BotSecret> get copyWith => _$BotSecretCopyWithImpl<BotSecret>(this as BotSecret, _$identity);

  /// Serializes this BotSecret to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BotSecret&&(identical(other.id, id) || other.id == id)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.description, description) || other.description == description)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.botId, botId) || other.botId == botId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,secret,description,expiredAt,botId);

@override
String toString() {
  return 'BotSecret(id: $id, secret: $secret, description: $description, expiredAt: $expiredAt, botId: $botId)';
}


}

/// @nodoc
abstract mixin class $BotSecretCopyWith<$Res>  {
  factory $BotSecretCopyWith(BotSecret value, $Res Function(BotSecret) _then) = _$BotSecretCopyWithImpl;
@useResult
$Res call({
 String id, String secret, String? description, DateTime? expiredAt, String botId
});




}
/// @nodoc
class _$BotSecretCopyWithImpl<$Res>
    implements $BotSecretCopyWith<$Res> {
  _$BotSecretCopyWithImpl(this._self, this._then);

  final BotSecret _self;
  final $Res Function(BotSecret) _then;

/// Create a copy of BotSecret
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? secret = null,Object? description = freezed,Object? expiredAt = freezed,Object? botId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,botId: null == botId ? _self.botId : botId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BotSecret].
extension BotSecretPatterns on BotSecret {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BotSecret value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BotSecret() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BotSecret value)  $default,){
final _that = this;
switch (_that) {
case _BotSecret():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BotSecret value)?  $default,){
final _that = this;
switch (_that) {
case _BotSecret() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String secret,  String? description,  DateTime? expiredAt,  String botId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BotSecret() when $default != null:
return $default(_that.id,_that.secret,_that.description,_that.expiredAt,_that.botId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String secret,  String? description,  DateTime? expiredAt,  String botId)  $default,) {final _that = this;
switch (_that) {
case _BotSecret():
return $default(_that.id,_that.secret,_that.description,_that.expiredAt,_that.botId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String secret,  String? description,  DateTime? expiredAt,  String botId)?  $default,) {final _that = this;
switch (_that) {
case _BotSecret() when $default != null:
return $default(_that.id,_that.secret,_that.description,_that.expiredAt,_that.botId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BotSecret implements BotSecret {
  const _BotSecret({this.id = '', this.secret = '', this.description, this.expiredAt, this.botId = ''});
  factory _BotSecret.fromJson(Map<String, dynamic> json) => _$BotSecretFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String secret;
@override final  String? description;
@override final  DateTime? expiredAt;
@override@JsonKey() final  String botId;

/// Create a copy of BotSecret
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BotSecretCopyWith<_BotSecret> get copyWith => __$BotSecretCopyWithImpl<_BotSecret>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BotSecretToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BotSecret&&(identical(other.id, id) || other.id == id)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.description, description) || other.description == description)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.botId, botId) || other.botId == botId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,secret,description,expiredAt,botId);

@override
String toString() {
  return 'BotSecret(id: $id, secret: $secret, description: $description, expiredAt: $expiredAt, botId: $botId)';
}


}

/// @nodoc
abstract mixin class _$BotSecretCopyWith<$Res> implements $BotSecretCopyWith<$Res> {
  factory _$BotSecretCopyWith(_BotSecret value, $Res Function(_BotSecret) _then) = __$BotSecretCopyWithImpl;
@override @useResult
$Res call({
 String id, String secret, String? description, DateTime? expiredAt, String botId
});




}
/// @nodoc
class __$BotSecretCopyWithImpl<$Res>
    implements _$BotSecretCopyWith<$Res> {
  __$BotSecretCopyWithImpl(this._self, this._then);

  final _BotSecret _self;
  final $Res Function(_BotSecret) _then;

/// Create a copy of BotSecret
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? secret = null,Object? description = freezed,Object? expiredAt = freezed,Object? botId = null,}) {
  return _then(_BotSecret(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,botId: null == botId ? _self.botId : botId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
