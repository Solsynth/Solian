// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dev_project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnDevProject {

 String get id; String get slug; String get name; String get description; SnDeveloper get developer; String get developerId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnDevProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnDevProjectCopyWith<SnDevProject> get copyWith => _$SnDevProjectCopyWithImpl<SnDevProject>(this as SnDevProject, _$identity);

  /// Serializes this SnDevProject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnDevProject&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.developer, developer) || other.developer == developer)&&(identical(other.developerId, developerId) || other.developerId == developerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,developer,developerId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnDevProject(id: $id, slug: $slug, name: $name, description: $description, developer: $developer, developerId: $developerId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnDevProjectCopyWith<$Res>  {
  factory $SnDevProjectCopyWith(SnDevProject value, $Res Function(SnDevProject) _then) = _$SnDevProjectCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String name, String description, SnDeveloper developer, String developerId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnDeveloperCopyWith<$Res> get developer;

}
/// @nodoc
class _$SnDevProjectCopyWithImpl<$Res>
    implements $SnDevProjectCopyWith<$Res> {
  _$SnDevProjectCopyWithImpl(this._self, this._then);

  final SnDevProject _self;
  final $Res Function(SnDevProject) _then;

/// Create a copy of SnDevProject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = null,Object? developer = null,Object? developerId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,developer: null == developer ? _self.developer : developer // ignore: cast_nullable_to_non_nullable
as SnDeveloper,developerId: null == developerId ? _self.developerId : developerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnDevProject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnDeveloperCopyWith<$Res> get developer {
  
  return $SnDeveloperCopyWith<$Res>(_self.developer, (value) {
    return _then(_self.copyWith(developer: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnDevProject].
extension SnDevProjectPatterns on SnDevProject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnDevProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnDevProject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnDevProject value)  $default,){
final _that = this;
switch (_that) {
case _SnDevProject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnDevProject value)?  $default,){
final _that = this;
switch (_that) {
case _SnDevProject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String description,  SnDeveloper developer,  String developerId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnDevProject() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.developer,_that.developerId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String name,  String description,  SnDeveloper developer,  String developerId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnDevProject():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.developer,_that.developerId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String name,  String description,  SnDeveloper developer,  String developerId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnDevProject() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.developer,_that.developerId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnDevProject implements SnDevProject {
  const _SnDevProject({required this.id, required this.slug, required this.name, required this.description, required this.developer, required this.developerId, required this.createdAt, required this.updatedAt, required this.deletedAt});
  factory _SnDevProject.fromJson(Map<String, dynamic> json) => _$SnDevProjectFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String name;
@override final  String description;
@override final  SnDeveloper developer;
@override final  String developerId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnDevProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnDevProjectCopyWith<_SnDevProject> get copyWith => __$SnDevProjectCopyWithImpl<_SnDevProject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnDevProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnDevProject&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.developer, developer) || other.developer == developer)&&(identical(other.developerId, developerId) || other.developerId == developerId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,developer,developerId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnDevProject(id: $id, slug: $slug, name: $name, description: $description, developer: $developer, developerId: $developerId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnDevProjectCopyWith<$Res> implements $SnDevProjectCopyWith<$Res> {
  factory _$SnDevProjectCopyWith(_SnDevProject value, $Res Function(_SnDevProject) _then) = __$SnDevProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String name, String description, SnDeveloper developer, String developerId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnDeveloperCopyWith<$Res> get developer;

}
/// @nodoc
class __$SnDevProjectCopyWithImpl<$Res>
    implements _$SnDevProjectCopyWith<$Res> {
  __$SnDevProjectCopyWithImpl(this._self, this._then);

  final _SnDevProject _self;
  final $Res Function(_SnDevProject) _then;

/// Create a copy of SnDevProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = null,Object? description = null,Object? developer = null,Object? developerId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnDevProject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,developer: null == developer ? _self.developer : developer // ignore: cast_nullable_to_non_nullable
as SnDeveloper,developerId: null == developerId ? _self.developerId : developerId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnDevProject
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnDeveloperCopyWith<$Res> get developer {
  
  return $SnDeveloperCopyWith<$Res>(_self.developer, (value) {
    return _then(_self.copyWith(developer: value));
  });
}
}

// dart format on
