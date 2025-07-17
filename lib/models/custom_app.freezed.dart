// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_app.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomApp {

 String get id; String get slug; String get name; String? get description; int get status; SnCloudFile? get picture; SnCloudFile? get background; SnVerificationMark? get verification; CustomAppOauthConfig? get oauthConfig; CustomAppLinks? get links; List<CustomAppSecret> get secrets; String get publisherId;
/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomAppCopyWith<CustomApp> get copyWith => _$CustomAppCopyWithImpl<CustomApp>(this as CustomApp, _$identity);

  /// Serializes this CustomApp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomApp&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.oauthConfig, oauthConfig) || other.oauthConfig == oauthConfig)&&(identical(other.links, links) || other.links == links)&&const DeepCollectionEquality().equals(other.secrets, secrets)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,status,picture,background,verification,oauthConfig,links,const DeepCollectionEquality().hash(secrets),publisherId);

@override
String toString() {
  return 'CustomApp(id: $id, slug: $slug, name: $name, description: $description, status: $status, picture: $picture, background: $background, verification: $verification, oauthConfig: $oauthConfig, links: $links, secrets: $secrets, publisherId: $publisherId)';
}


}

/// @nodoc
abstract mixin class $CustomAppCopyWith<$Res>  {
  factory $CustomAppCopyWith(CustomApp value, $Res Function(CustomApp) _then) = _$CustomAppCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String? description, int status, SnCloudFile? picture, SnCloudFile? background, SnVerificationMark? verification, CustomAppOauthConfig? oauthConfig, CustomAppLinks? links, List<CustomAppSecret> secrets, String publisherId
});


$SnCloudFileCopyWith<$Res>? get picture;$SnCloudFileCopyWith<$Res>? get background;$SnVerificationMarkCopyWith<$Res>? get verification;$CustomAppOauthConfigCopyWith<$Res>? get oauthConfig;$CustomAppLinksCopyWith<$Res>? get links;

}
/// @nodoc
class _$CustomAppCopyWithImpl<$Res>
    implements $CustomAppCopyWith<$Res> {
  _$CustomAppCopyWithImpl(this._self, this._then);

  final CustomApp _self;
  final $Res Function(CustomApp) _then;

/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? status = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? oauthConfig = freezed,Object? links = freezed,Object? secrets = null,Object? publisherId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,oauthConfig: freezed == oauthConfig ? _self.oauthConfig : oauthConfig // ignore: cast_nullable_to_non_nullable
as CustomAppOauthConfig?,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as CustomAppLinks?,secrets: null == secrets ? _self.secrets : secrets // ignore: cast_nullable_to_non_nullable
as List<CustomAppSecret>,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of CustomApp
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
}/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomAppOauthConfigCopyWith<$Res>? get oauthConfig {
    if (_self.oauthConfig == null) {
    return null;
  }

  return $CustomAppOauthConfigCopyWith<$Res>(_self.oauthConfig!, (value) {
    return _then(_self.copyWith(oauthConfig: value));
  });
}/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomAppLinksCopyWith<$Res>? get links {
    if (_self.links == null) {
    return null;
  }

  return $CustomAppLinksCopyWith<$Res>(_self.links!, (value) {
    return _then(_self.copyWith(links: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomApp].
extension CustomAppPatterns on CustomApp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomApp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomApp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomApp value)  $default,){
final _that = this;
switch (_that) {
case _CustomApp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomApp value)?  $default,){
final _that = this;
switch (_that) {
case _CustomApp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? description,  int status,  SnCloudFile? picture,  SnCloudFile? background,  SnVerificationMark? verification,  CustomAppOauthConfig? oauthConfig,  CustomAppLinks? links,  List<CustomAppSecret> secrets,  String publisherId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomApp() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.status,_that.picture,_that.background,_that.verification,_that.oauthConfig,_that.links,_that.secrets,_that.publisherId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String? description,  int status,  SnCloudFile? picture,  SnCloudFile? background,  SnVerificationMark? verification,  CustomAppOauthConfig? oauthConfig,  CustomAppLinks? links,  List<CustomAppSecret> secrets,  String publisherId)  $default,) {final _that = this;
switch (_that) {
case _CustomApp():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.status,_that.picture,_that.background,_that.verification,_that.oauthConfig,_that.links,_that.secrets,_that.publisherId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String? description,  int status,  SnCloudFile? picture,  SnCloudFile? background,  SnVerificationMark? verification,  CustomAppOauthConfig? oauthConfig,  CustomAppLinks? links,  List<CustomAppSecret> secrets,  String publisherId)?  $default,) {final _that = this;
switch (_that) {
case _CustomApp() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.status,_that.picture,_that.background,_that.verification,_that.oauthConfig,_that.links,_that.secrets,_that.publisherId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomApp implements CustomApp {
  const _CustomApp({this.id = '', this.slug = '', this.name = '', this.description, this.status = 0, this.picture, this.background, this.verification, this.oauthConfig, this.links, final  List<CustomAppSecret> secrets = const [], this.publisherId = ''}): _secrets = secrets;
  factory _CustomApp.fromJson(Map<String, dynamic> json) => _$CustomAppFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String slug;
@override@JsonKey() final  String name;
@override final  String? description;
@override@JsonKey() final  int status;
@override final  SnCloudFile? picture;
@override final  SnCloudFile? background;
@override final  SnVerificationMark? verification;
@override final  CustomAppOauthConfig? oauthConfig;
@override final  CustomAppLinks? links;
 final  List<CustomAppSecret> _secrets;
@override@JsonKey() List<CustomAppSecret> get secrets {
  if (_secrets is EqualUnmodifiableListView) return _secrets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secrets);
}

@override@JsonKey() final  String publisherId;

/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomAppCopyWith<_CustomApp> get copyWith => __$CustomAppCopyWithImpl<_CustomApp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomAppToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomApp&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.background, background) || other.background == background)&&(identical(other.verification, verification) || other.verification == verification)&&(identical(other.oauthConfig, oauthConfig) || other.oauthConfig == oauthConfig)&&(identical(other.links, links) || other.links == links)&&const DeepCollectionEquality().equals(other._secrets, _secrets)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,status,picture,background,verification,oauthConfig,links,const DeepCollectionEquality().hash(_secrets),publisherId);

@override
String toString() {
  return 'CustomApp(id: $id, slug: $slug, name: $name, description: $description, status: $status, picture: $picture, background: $background, verification: $verification, oauthConfig: $oauthConfig, links: $links, secrets: $secrets, publisherId: $publisherId)';
}


}

/// @nodoc
abstract mixin class _$CustomAppCopyWith<$Res> implements $CustomAppCopyWith<$Res> {
  factory _$CustomAppCopyWith(_CustomApp value, $Res Function(_CustomApp) _then) = __$CustomAppCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String? description, int status, SnCloudFile? picture, SnCloudFile? background, SnVerificationMark? verification, CustomAppOauthConfig? oauthConfig, CustomAppLinks? links, List<CustomAppSecret> secrets, String publisherId
});


@override $SnCloudFileCopyWith<$Res>? get picture;@override $SnCloudFileCopyWith<$Res>? get background;@override $SnVerificationMarkCopyWith<$Res>? get verification;@override $CustomAppOauthConfigCopyWith<$Res>? get oauthConfig;@override $CustomAppLinksCopyWith<$Res>? get links;

}
/// @nodoc
class __$CustomAppCopyWithImpl<$Res>
    implements _$CustomAppCopyWith<$Res> {
  __$CustomAppCopyWithImpl(this._self, this._then);

  final _CustomApp _self;
  final $Res Function(_CustomApp) _then;

/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = freezed,Object? status = null,Object? picture = freezed,Object? background = freezed,Object? verification = freezed,Object? oauthConfig = freezed,Object? links = freezed,Object? secrets = null,Object? publisherId = null,}) {
  return _then(_CustomApp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,background: freezed == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,verification: freezed == verification ? _self.verification : verification // ignore: cast_nullable_to_non_nullable
as SnVerificationMark?,oauthConfig: freezed == oauthConfig ? _self.oauthConfig : oauthConfig // ignore: cast_nullable_to_non_nullable
as CustomAppOauthConfig?,links: freezed == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as CustomAppLinks?,secrets: null == secrets ? _self._secrets : secrets // ignore: cast_nullable_to_non_nullable
as List<CustomAppSecret>,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get picture {
    if (_self.picture == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.picture!, (value) {
    return _then(_self.copyWith(picture: value));
  });
}/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get background {
    if (_self.background == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.background!, (value) {
    return _then(_self.copyWith(background: value));
  });
}/// Create a copy of CustomApp
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
}/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomAppOauthConfigCopyWith<$Res>? get oauthConfig {
    if (_self.oauthConfig == null) {
    return null;
  }

  return $CustomAppOauthConfigCopyWith<$Res>(_self.oauthConfig!, (value) {
    return _then(_self.copyWith(oauthConfig: value));
  });
}/// Create a copy of CustomApp
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomAppLinksCopyWith<$Res>? get links {
    if (_self.links == null) {
    return null;
  }

  return $CustomAppLinksCopyWith<$Res>(_self.links!, (value) {
    return _then(_self.copyWith(links: value));
  });
}
}


/// @nodoc
mixin _$CustomAppLinks {

 String? get homePage; String? get privacyPolicy; String? get termsOfService;
/// Create a copy of CustomAppLinks
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomAppLinksCopyWith<CustomAppLinks> get copyWith => _$CustomAppLinksCopyWithImpl<CustomAppLinks>(this as CustomAppLinks, _$identity);

  /// Serializes this CustomAppLinks to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomAppLinks&&(identical(other.homePage, homePage) || other.homePage == homePage)&&(identical(other.privacyPolicy, privacyPolicy) || other.privacyPolicy == privacyPolicy)&&(identical(other.termsOfService, termsOfService) || other.termsOfService == termsOfService));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homePage,privacyPolicy,termsOfService);

@override
String toString() {
  return 'CustomAppLinks(homePage: $homePage, privacyPolicy: $privacyPolicy, termsOfService: $termsOfService)';
}


}

/// @nodoc
abstract mixin class $CustomAppLinksCopyWith<$Res>  {
  factory $CustomAppLinksCopyWith(CustomAppLinks value, $Res Function(CustomAppLinks) _then) = _$CustomAppLinksCopyWithImpl;
@useResult
$Res call({
 String? homePage, String? privacyPolicy, String? termsOfService
});




}
/// @nodoc
class _$CustomAppLinksCopyWithImpl<$Res>
    implements $CustomAppLinksCopyWith<$Res> {
  _$CustomAppLinksCopyWithImpl(this._self, this._then);

  final CustomAppLinks _self;
  final $Res Function(CustomAppLinks) _then;

/// Create a copy of CustomAppLinks
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? homePage = freezed,Object? privacyPolicy = freezed,Object? termsOfService = freezed,}) {
  return _then(_self.copyWith(
homePage: freezed == homePage ? _self.homePage : homePage // ignore: cast_nullable_to_non_nullable
as String?,privacyPolicy: freezed == privacyPolicy ? _self.privacyPolicy : privacyPolicy // ignore: cast_nullable_to_non_nullable
as String?,termsOfService: freezed == termsOfService ? _self.termsOfService : termsOfService // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomAppLinks].
extension CustomAppLinksPatterns on CustomAppLinks {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomAppLinks value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomAppLinks() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomAppLinks value)  $default,){
final _that = this;
switch (_that) {
case _CustomAppLinks():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomAppLinks value)?  $default,){
final _that = this;
switch (_that) {
case _CustomAppLinks() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? homePage,  String? privacyPolicy,  String? termsOfService)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomAppLinks() when $default != null:
return $default(_that.homePage,_that.privacyPolicy,_that.termsOfService);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? homePage,  String? privacyPolicy,  String? termsOfService)  $default,) {final _that = this;
switch (_that) {
case _CustomAppLinks():
return $default(_that.homePage,_that.privacyPolicy,_that.termsOfService);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? homePage,  String? privacyPolicy,  String? termsOfService)?  $default,) {final _that = this;
switch (_that) {
case _CustomAppLinks() when $default != null:
return $default(_that.homePage,_that.privacyPolicy,_that.termsOfService);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomAppLinks implements CustomAppLinks {
  const _CustomAppLinks({this.homePage, this.privacyPolicy, this.termsOfService});
  factory _CustomAppLinks.fromJson(Map<String, dynamic> json) => _$CustomAppLinksFromJson(json);

@override final  String? homePage;
@override final  String? privacyPolicy;
@override final  String? termsOfService;

/// Create a copy of CustomAppLinks
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomAppLinksCopyWith<_CustomAppLinks> get copyWith => __$CustomAppLinksCopyWithImpl<_CustomAppLinks>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomAppLinksToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomAppLinks&&(identical(other.homePage, homePage) || other.homePage == homePage)&&(identical(other.privacyPolicy, privacyPolicy) || other.privacyPolicy == privacyPolicy)&&(identical(other.termsOfService, termsOfService) || other.termsOfService == termsOfService));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,homePage,privacyPolicy,termsOfService);

@override
String toString() {
  return 'CustomAppLinks(homePage: $homePage, privacyPolicy: $privacyPolicy, termsOfService: $termsOfService)';
}


}

/// @nodoc
abstract mixin class _$CustomAppLinksCopyWith<$Res> implements $CustomAppLinksCopyWith<$Res> {
  factory _$CustomAppLinksCopyWith(_CustomAppLinks value, $Res Function(_CustomAppLinks) _then) = __$CustomAppLinksCopyWithImpl;
@override @useResult
$Res call({
 String? homePage, String? privacyPolicy, String? termsOfService
});




}
/// @nodoc
class __$CustomAppLinksCopyWithImpl<$Res>
    implements _$CustomAppLinksCopyWith<$Res> {
  __$CustomAppLinksCopyWithImpl(this._self, this._then);

  final _CustomAppLinks _self;
  final $Res Function(_CustomAppLinks) _then;

/// Create a copy of CustomAppLinks
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? homePage = freezed,Object? privacyPolicy = freezed,Object? termsOfService = freezed,}) {
  return _then(_CustomAppLinks(
homePage: freezed == homePage ? _self.homePage : homePage // ignore: cast_nullable_to_non_nullable
as String?,privacyPolicy: freezed == privacyPolicy ? _self.privacyPolicy : privacyPolicy // ignore: cast_nullable_to_non_nullable
as String?,termsOfService: freezed == termsOfService ? _self.termsOfService : termsOfService // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CustomAppOauthConfig {

 String? get clientUri; List<String> get redirectUris; List<String>? get postLogoutRedirectUris; List<String> get allowedScopes; List<String> get allowedGrantTypes; bool get requirePkce; bool get allowOfflineAccess;
/// Create a copy of CustomAppOauthConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomAppOauthConfigCopyWith<CustomAppOauthConfig> get copyWith => _$CustomAppOauthConfigCopyWithImpl<CustomAppOauthConfig>(this as CustomAppOauthConfig, _$identity);

  /// Serializes this CustomAppOauthConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomAppOauthConfig&&(identical(other.clientUri, clientUri) || other.clientUri == clientUri)&&const DeepCollectionEquality().equals(other.redirectUris, redirectUris)&&const DeepCollectionEquality().equals(other.postLogoutRedirectUris, postLogoutRedirectUris)&&const DeepCollectionEquality().equals(other.allowedScopes, allowedScopes)&&const DeepCollectionEquality().equals(other.allowedGrantTypes, allowedGrantTypes)&&(identical(other.requirePkce, requirePkce) || other.requirePkce == requirePkce)&&(identical(other.allowOfflineAccess, allowOfflineAccess) || other.allowOfflineAccess == allowOfflineAccess));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientUri,const DeepCollectionEquality().hash(redirectUris),const DeepCollectionEquality().hash(postLogoutRedirectUris),const DeepCollectionEquality().hash(allowedScopes),const DeepCollectionEquality().hash(allowedGrantTypes),requirePkce,allowOfflineAccess);

@override
String toString() {
  return 'CustomAppOauthConfig(clientUri: $clientUri, redirectUris: $redirectUris, postLogoutRedirectUris: $postLogoutRedirectUris, allowedScopes: $allowedScopes, allowedGrantTypes: $allowedGrantTypes, requirePkce: $requirePkce, allowOfflineAccess: $allowOfflineAccess)';
}


}

/// @nodoc
abstract mixin class $CustomAppOauthConfigCopyWith<$Res>  {
  factory $CustomAppOauthConfigCopyWith(CustomAppOauthConfig value, $Res Function(CustomAppOauthConfig) _then) = _$CustomAppOauthConfigCopyWithImpl;
@useResult
$Res call({
 String? clientUri, List<String> redirectUris, List<String>? postLogoutRedirectUris, List<String> allowedScopes, List<String> allowedGrantTypes, bool requirePkce, bool allowOfflineAccess
});




}
/// @nodoc
class _$CustomAppOauthConfigCopyWithImpl<$Res>
    implements $CustomAppOauthConfigCopyWith<$Res> {
  _$CustomAppOauthConfigCopyWithImpl(this._self, this._then);

  final CustomAppOauthConfig _self;
  final $Res Function(CustomAppOauthConfig) _then;

/// Create a copy of CustomAppOauthConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clientUri = freezed,Object? redirectUris = null,Object? postLogoutRedirectUris = freezed,Object? allowedScopes = null,Object? allowedGrantTypes = null,Object? requirePkce = null,Object? allowOfflineAccess = null,}) {
  return _then(_self.copyWith(
clientUri: freezed == clientUri ? _self.clientUri : clientUri // ignore: cast_nullable_to_non_nullable
as String?,redirectUris: null == redirectUris ? _self.redirectUris : redirectUris // ignore: cast_nullable_to_non_nullable
as List<String>,postLogoutRedirectUris: freezed == postLogoutRedirectUris ? _self.postLogoutRedirectUris : postLogoutRedirectUris // ignore: cast_nullable_to_non_nullable
as List<String>?,allowedScopes: null == allowedScopes ? _self.allowedScopes : allowedScopes // ignore: cast_nullable_to_non_nullable
as List<String>,allowedGrantTypes: null == allowedGrantTypes ? _self.allowedGrantTypes : allowedGrantTypes // ignore: cast_nullable_to_non_nullable
as List<String>,requirePkce: null == requirePkce ? _self.requirePkce : requirePkce // ignore: cast_nullable_to_non_nullable
as bool,allowOfflineAccess: null == allowOfflineAccess ? _self.allowOfflineAccess : allowOfflineAccess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomAppOauthConfig].
extension CustomAppOauthConfigPatterns on CustomAppOauthConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomAppOauthConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomAppOauthConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomAppOauthConfig value)  $default,){
final _that = this;
switch (_that) {
case _CustomAppOauthConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomAppOauthConfig value)?  $default,){
final _that = this;
switch (_that) {
case _CustomAppOauthConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? clientUri,  List<String> redirectUris,  List<String>? postLogoutRedirectUris,  List<String> allowedScopes,  List<String> allowedGrantTypes,  bool requirePkce,  bool allowOfflineAccess)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomAppOauthConfig() when $default != null:
return $default(_that.clientUri,_that.redirectUris,_that.postLogoutRedirectUris,_that.allowedScopes,_that.allowedGrantTypes,_that.requirePkce,_that.allowOfflineAccess);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? clientUri,  List<String> redirectUris,  List<String>? postLogoutRedirectUris,  List<String> allowedScopes,  List<String> allowedGrantTypes,  bool requirePkce,  bool allowOfflineAccess)  $default,) {final _that = this;
switch (_that) {
case _CustomAppOauthConfig():
return $default(_that.clientUri,_that.redirectUris,_that.postLogoutRedirectUris,_that.allowedScopes,_that.allowedGrantTypes,_that.requirePkce,_that.allowOfflineAccess);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? clientUri,  List<String> redirectUris,  List<String>? postLogoutRedirectUris,  List<String> allowedScopes,  List<String> allowedGrantTypes,  bool requirePkce,  bool allowOfflineAccess)?  $default,) {final _that = this;
switch (_that) {
case _CustomAppOauthConfig() when $default != null:
return $default(_that.clientUri,_that.redirectUris,_that.postLogoutRedirectUris,_that.allowedScopes,_that.allowedGrantTypes,_that.requirePkce,_that.allowOfflineAccess);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomAppOauthConfig implements CustomAppOauthConfig {
  const _CustomAppOauthConfig({this.clientUri, final  List<String> redirectUris = const [], final  List<String>? postLogoutRedirectUris, final  List<String> allowedScopes = const ['openid', 'profile', 'email'], final  List<String> allowedGrantTypes = const ['authorization_code', 'refresh_token'], this.requirePkce = true, this.allowOfflineAccess = false}): _redirectUris = redirectUris,_postLogoutRedirectUris = postLogoutRedirectUris,_allowedScopes = allowedScopes,_allowedGrantTypes = allowedGrantTypes;
  factory _CustomAppOauthConfig.fromJson(Map<String, dynamic> json) => _$CustomAppOauthConfigFromJson(json);

@override final  String? clientUri;
 final  List<String> _redirectUris;
@override@JsonKey() List<String> get redirectUris {
  if (_redirectUris is EqualUnmodifiableListView) return _redirectUris;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_redirectUris);
}

 final  List<String>? _postLogoutRedirectUris;
@override List<String>? get postLogoutRedirectUris {
  final value = _postLogoutRedirectUris;
  if (value == null) return null;
  if (_postLogoutRedirectUris is EqualUnmodifiableListView) return _postLogoutRedirectUris;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String> _allowedScopes;
@override@JsonKey() List<String> get allowedScopes {
  if (_allowedScopes is EqualUnmodifiableListView) return _allowedScopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedScopes);
}

 final  List<String> _allowedGrantTypes;
@override@JsonKey() List<String> get allowedGrantTypes {
  if (_allowedGrantTypes is EqualUnmodifiableListView) return _allowedGrantTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedGrantTypes);
}

@override@JsonKey() final  bool requirePkce;
@override@JsonKey() final  bool allowOfflineAccess;

/// Create a copy of CustomAppOauthConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomAppOauthConfigCopyWith<_CustomAppOauthConfig> get copyWith => __$CustomAppOauthConfigCopyWithImpl<_CustomAppOauthConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomAppOauthConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomAppOauthConfig&&(identical(other.clientUri, clientUri) || other.clientUri == clientUri)&&const DeepCollectionEquality().equals(other._redirectUris, _redirectUris)&&const DeepCollectionEquality().equals(other._postLogoutRedirectUris, _postLogoutRedirectUris)&&const DeepCollectionEquality().equals(other._allowedScopes, _allowedScopes)&&const DeepCollectionEquality().equals(other._allowedGrantTypes, _allowedGrantTypes)&&(identical(other.requirePkce, requirePkce) || other.requirePkce == requirePkce)&&(identical(other.allowOfflineAccess, allowOfflineAccess) || other.allowOfflineAccess == allowOfflineAccess));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,clientUri,const DeepCollectionEquality().hash(_redirectUris),const DeepCollectionEquality().hash(_postLogoutRedirectUris),const DeepCollectionEquality().hash(_allowedScopes),const DeepCollectionEquality().hash(_allowedGrantTypes),requirePkce,allowOfflineAccess);

@override
String toString() {
  return 'CustomAppOauthConfig(clientUri: $clientUri, redirectUris: $redirectUris, postLogoutRedirectUris: $postLogoutRedirectUris, allowedScopes: $allowedScopes, allowedGrantTypes: $allowedGrantTypes, requirePkce: $requirePkce, allowOfflineAccess: $allowOfflineAccess)';
}


}

/// @nodoc
abstract mixin class _$CustomAppOauthConfigCopyWith<$Res> implements $CustomAppOauthConfigCopyWith<$Res> {
  factory _$CustomAppOauthConfigCopyWith(_CustomAppOauthConfig value, $Res Function(_CustomAppOauthConfig) _then) = __$CustomAppOauthConfigCopyWithImpl;
@override @useResult
$Res call({
 String? clientUri, List<String> redirectUris, List<String>? postLogoutRedirectUris, List<String> allowedScopes, List<String> allowedGrantTypes, bool requirePkce, bool allowOfflineAccess
});




}
/// @nodoc
class __$CustomAppOauthConfigCopyWithImpl<$Res>
    implements _$CustomAppOauthConfigCopyWith<$Res> {
  __$CustomAppOauthConfigCopyWithImpl(this._self, this._then);

  final _CustomAppOauthConfig _self;
  final $Res Function(_CustomAppOauthConfig) _then;

/// Create a copy of CustomAppOauthConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clientUri = freezed,Object? redirectUris = null,Object? postLogoutRedirectUris = freezed,Object? allowedScopes = null,Object? allowedGrantTypes = null,Object? requirePkce = null,Object? allowOfflineAccess = null,}) {
  return _then(_CustomAppOauthConfig(
clientUri: freezed == clientUri ? _self.clientUri : clientUri // ignore: cast_nullable_to_non_nullable
as String?,redirectUris: null == redirectUris ? _self._redirectUris : redirectUris // ignore: cast_nullable_to_non_nullable
as List<String>,postLogoutRedirectUris: freezed == postLogoutRedirectUris ? _self._postLogoutRedirectUris : postLogoutRedirectUris // ignore: cast_nullable_to_non_nullable
as List<String>?,allowedScopes: null == allowedScopes ? _self._allowedScopes : allowedScopes // ignore: cast_nullable_to_non_nullable
as List<String>,allowedGrantTypes: null == allowedGrantTypes ? _self._allowedGrantTypes : allowedGrantTypes // ignore: cast_nullable_to_non_nullable
as List<String>,requirePkce: null == requirePkce ? _self.requirePkce : requirePkce // ignore: cast_nullable_to_non_nullable
as bool,allowOfflineAccess: null == allowOfflineAccess ? _self.allowOfflineAccess : allowOfflineAccess // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CustomAppSecret {

 String get id; String get secret; String? get description; DateTime? get expiredAt; bool get isOidc; String get appId;
/// Create a copy of CustomAppSecret
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomAppSecretCopyWith<CustomAppSecret> get copyWith => _$CustomAppSecretCopyWithImpl<CustomAppSecret>(this as CustomAppSecret, _$identity);

  /// Serializes this CustomAppSecret to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomAppSecret&&(identical(other.id, id) || other.id == id)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.description, description) || other.description == description)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.isOidc, isOidc) || other.isOidc == isOidc)&&(identical(other.appId, appId) || other.appId == appId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,secret,description,expiredAt,isOidc,appId);

@override
String toString() {
  return 'CustomAppSecret(id: $id, secret: $secret, description: $description, expiredAt: $expiredAt, isOidc: $isOidc, appId: $appId)';
}


}

/// @nodoc
abstract mixin class $CustomAppSecretCopyWith<$Res>  {
  factory $CustomAppSecretCopyWith(CustomAppSecret value, $Res Function(CustomAppSecret) _then) = _$CustomAppSecretCopyWithImpl;
@useResult
$Res call({
 String id, String secret, String? description, DateTime? expiredAt, bool isOidc, String appId
});




}
/// @nodoc
class _$CustomAppSecretCopyWithImpl<$Res>
    implements $CustomAppSecretCopyWith<$Res> {
  _$CustomAppSecretCopyWithImpl(this._self, this._then);

  final CustomAppSecret _self;
  final $Res Function(CustomAppSecret) _then;

/// Create a copy of CustomAppSecret
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? secret = null,Object? description = freezed,Object? expiredAt = freezed,Object? isOidc = null,Object? appId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isOidc: null == isOidc ? _self.isOidc : isOidc // ignore: cast_nullable_to_non_nullable
as bool,appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomAppSecret].
extension CustomAppSecretPatterns on CustomAppSecret {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomAppSecret value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomAppSecret() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomAppSecret value)  $default,){
final _that = this;
switch (_that) {
case _CustomAppSecret():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomAppSecret value)?  $default,){
final _that = this;
switch (_that) {
case _CustomAppSecret() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String secret,  String? description,  DateTime? expiredAt,  bool isOidc,  String appId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomAppSecret() when $default != null:
return $default(_that.id,_that.secret,_that.description,_that.expiredAt,_that.isOidc,_that.appId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String secret,  String? description,  DateTime? expiredAt,  bool isOidc,  String appId)  $default,) {final _that = this;
switch (_that) {
case _CustomAppSecret():
return $default(_that.id,_that.secret,_that.description,_that.expiredAt,_that.isOidc,_that.appId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String secret,  String? description,  DateTime? expiredAt,  bool isOidc,  String appId)?  $default,) {final _that = this;
switch (_that) {
case _CustomAppSecret() when $default != null:
return $default(_that.id,_that.secret,_that.description,_that.expiredAt,_that.isOidc,_that.appId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomAppSecret implements CustomAppSecret {
  const _CustomAppSecret({this.id = '', this.secret = '', this.description, this.expiredAt, this.isOidc = false, this.appId = ''});
  factory _CustomAppSecret.fromJson(Map<String, dynamic> json) => _$CustomAppSecretFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String secret;
@override final  String? description;
@override final  DateTime? expiredAt;
@override@JsonKey() final  bool isOidc;
@override@JsonKey() final  String appId;

/// Create a copy of CustomAppSecret
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomAppSecretCopyWith<_CustomAppSecret> get copyWith => __$CustomAppSecretCopyWithImpl<_CustomAppSecret>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomAppSecretToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomAppSecret&&(identical(other.id, id) || other.id == id)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.description, description) || other.description == description)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.isOidc, isOidc) || other.isOidc == isOidc)&&(identical(other.appId, appId) || other.appId == appId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,secret,description,expiredAt,isOidc,appId);

@override
String toString() {
  return 'CustomAppSecret(id: $id, secret: $secret, description: $description, expiredAt: $expiredAt, isOidc: $isOidc, appId: $appId)';
}


}

/// @nodoc
abstract mixin class _$CustomAppSecretCopyWith<$Res> implements $CustomAppSecretCopyWith<$Res> {
  factory _$CustomAppSecretCopyWith(_CustomAppSecret value, $Res Function(_CustomAppSecret) _then) = __$CustomAppSecretCopyWithImpl;
@override @useResult
$Res call({
 String id, String secret, String? description, DateTime? expiredAt, bool isOidc, String appId
});




}
/// @nodoc
class __$CustomAppSecretCopyWithImpl<$Res>
    implements _$CustomAppSecretCopyWith<$Res> {
  __$CustomAppSecretCopyWithImpl(this._self, this._then);

  final _CustomAppSecret _self;
  final $Res Function(_CustomAppSecret) _then;

/// Create a copy of CustomAppSecret
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? secret = null,Object? description = freezed,Object? expiredAt = freezed,Object? isOidc = null,Object? appId = null,}) {
  return _then(_CustomAppSecret(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isOidc: null == isOidc ? _self.isOidc : isOidc // ignore: cast_nullable_to_non_nullable
as bool,appId: null == appId ? _self.appId : appId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
