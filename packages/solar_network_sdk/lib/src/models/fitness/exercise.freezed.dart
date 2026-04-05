// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnExerciseLibrary {

 String get id; String get name; String? get description; ExerciseCategory get category; List<String>? get muscleGroups; ExerciseDifficulty get difficulty; List<String>? get equipment; bool get isPublic; String? get accountId; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SnExerciseLibrary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnExerciseLibraryCopyWith<SnExerciseLibrary> get copyWith => _$SnExerciseLibraryCopyWithImpl<SnExerciseLibrary>(this as SnExerciseLibrary, _$identity);

  /// Serializes this SnExerciseLibrary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnExerciseLibrary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.muscleGroups, muscleGroups)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other.equipment, equipment)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,const DeepCollectionEquality().hash(muscleGroups),difficulty,const DeepCollectionEquality().hash(equipment),isPublic,accountId,createdAt,updatedAt);

@override
String toString() {
  return 'SnExerciseLibrary(id: $id, name: $name, description: $description, category: $category, muscleGroups: $muscleGroups, difficulty: $difficulty, equipment: $equipment, isPublic: $isPublic, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnExerciseLibraryCopyWith<$Res>  {
  factory $SnExerciseLibraryCopyWith(SnExerciseLibrary value, $Res Function(SnExerciseLibrary) _then) = _$SnExerciseLibraryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, ExerciseCategory category, List<String>? muscleGroups, ExerciseDifficulty difficulty, List<String>? equipment, bool isPublic, String? accountId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SnExerciseLibraryCopyWithImpl<$Res>
    implements $SnExerciseLibraryCopyWith<$Res> {
  _$SnExerciseLibraryCopyWithImpl(this._self, this._then);

  final SnExerciseLibrary _self;
  final $Res Function(SnExerciseLibrary) _then;

/// Create a copy of SnExerciseLibrary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? category = null,Object? muscleGroups = freezed,Object? difficulty = null,Object? equipment = freezed,Object? isPublic = null,Object? accountId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,muscleGroups: freezed == muscleGroups ? _self.muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ExerciseDifficulty,equipment: freezed == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SnExerciseLibrary].
extension SnExerciseLibraryPatterns on SnExerciseLibrary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnExerciseLibrary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnExerciseLibrary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnExerciseLibrary value)  $default,){
final _that = this;
switch (_that) {
case _SnExerciseLibrary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnExerciseLibrary value)?  $default,){
final _that = this;
switch (_that) {
case _SnExerciseLibrary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  ExerciseCategory category,  List<String>? muscleGroups,  ExerciseDifficulty difficulty,  List<String>? equipment,  bool isPublic,  String? accountId,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnExerciseLibrary() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.muscleGroups,_that.difficulty,_that.equipment,_that.isPublic,_that.accountId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  ExerciseCategory category,  List<String>? muscleGroups,  ExerciseDifficulty difficulty,  List<String>? equipment,  bool isPublic,  String? accountId,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnExerciseLibrary():
return $default(_that.id,_that.name,_that.description,_that.category,_that.muscleGroups,_that.difficulty,_that.equipment,_that.isPublic,_that.accountId,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  ExerciseCategory category,  List<String>? muscleGroups,  ExerciseDifficulty difficulty,  List<String>? equipment,  bool isPublic,  String? accountId,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnExerciseLibrary() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.muscleGroups,_that.difficulty,_that.equipment,_that.isPublic,_that.accountId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnExerciseLibrary implements SnExerciseLibrary {
  const _SnExerciseLibrary({required this.id, required this.name, this.description, required this.category, final  List<String>? muscleGroups, required this.difficulty, final  List<String>? equipment, required this.isPublic, this.accountId, required this.createdAt, required this.updatedAt}): _muscleGroups = muscleGroups,_equipment = equipment;
  factory _SnExerciseLibrary.fromJson(Map<String, dynamic> json) => _$SnExerciseLibraryFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  ExerciseCategory category;
 final  List<String>? _muscleGroups;
@override List<String>? get muscleGroups {
  final value = _muscleGroups;
  if (value == null) return null;
  if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  ExerciseDifficulty difficulty;
 final  List<String>? _equipment;
@override List<String>? get equipment {
  final value = _equipment;
  if (value == null) return null;
  if (_equipment is EqualUnmodifiableListView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool isPublic;
@override final  String? accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SnExerciseLibrary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnExerciseLibraryCopyWith<_SnExerciseLibrary> get copyWith => __$SnExerciseLibraryCopyWithImpl<_SnExerciseLibrary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnExerciseLibraryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnExerciseLibrary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._muscleGroups, _muscleGroups)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&const DeepCollectionEquality().equals(other._equipment, _equipment)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,const DeepCollectionEquality().hash(_muscleGroups),difficulty,const DeepCollectionEquality().hash(_equipment),isPublic,accountId,createdAt,updatedAt);

@override
String toString() {
  return 'SnExerciseLibrary(id: $id, name: $name, description: $description, category: $category, muscleGroups: $muscleGroups, difficulty: $difficulty, equipment: $equipment, isPublic: $isPublic, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnExerciseLibraryCopyWith<$Res> implements $SnExerciseLibraryCopyWith<$Res> {
  factory _$SnExerciseLibraryCopyWith(_SnExerciseLibrary value, $Res Function(_SnExerciseLibrary) _then) = __$SnExerciseLibraryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, ExerciseCategory category, List<String>? muscleGroups, ExerciseDifficulty difficulty, List<String>? equipment, bool isPublic, String? accountId, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SnExerciseLibraryCopyWithImpl<$Res>
    implements _$SnExerciseLibraryCopyWith<$Res> {
  __$SnExerciseLibraryCopyWithImpl(this._self, this._then);

  final _SnExerciseLibrary _self;
  final $Res Function(_SnExerciseLibrary) _then;

/// Create a copy of SnExerciseLibrary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? category = null,Object? muscleGroups = freezed,Object? difficulty = null,Object? equipment = freezed,Object? isPublic = null,Object? accountId = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SnExerciseLibrary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,muscleGroups: freezed == muscleGroups ? _self._muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>?,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ExerciseDifficulty,equipment: freezed == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,accountId: freezed == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$CreateExerciseRequest {

 String get name; ExerciseCategory get category; ExerciseDifficulty get difficulty; String? get description; List<String>? get muscleGroups; List<String>? get equipment; bool get isPublic;
/// Create a copy of CreateExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateExerciseRequestCopyWith<CreateExerciseRequest> get copyWith => _$CreateExerciseRequestCopyWithImpl<CreateExerciseRequest>(this as CreateExerciseRequest, _$identity);

  /// Serializes this CreateExerciseRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateExerciseRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.muscleGroups, muscleGroups)&&const DeepCollectionEquality().equals(other.equipment, equipment)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,category,difficulty,description,const DeepCollectionEquality().hash(muscleGroups),const DeepCollectionEquality().hash(equipment),isPublic);

@override
String toString() {
  return 'CreateExerciseRequest(name: $name, category: $category, difficulty: $difficulty, description: $description, muscleGroups: $muscleGroups, equipment: $equipment, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class $CreateExerciseRequestCopyWith<$Res>  {
  factory $CreateExerciseRequestCopyWith(CreateExerciseRequest value, $Res Function(CreateExerciseRequest) _then) = _$CreateExerciseRequestCopyWithImpl;
@useResult
$Res call({
 String name, ExerciseCategory category, ExerciseDifficulty difficulty, String? description, List<String>? muscleGroups, List<String>? equipment, bool isPublic
});




}
/// @nodoc
class _$CreateExerciseRequestCopyWithImpl<$Res>
    implements $CreateExerciseRequestCopyWith<$Res> {
  _$CreateExerciseRequestCopyWithImpl(this._self, this._then);

  final CreateExerciseRequest _self;
  final $Res Function(CreateExerciseRequest) _then;

/// Create a copy of CreateExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? category = null,Object? difficulty = null,Object? description = freezed,Object? muscleGroups = freezed,Object? equipment = freezed,Object? isPublic = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ExerciseDifficulty,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,muscleGroups: freezed == muscleGroups ? _self.muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>?,equipment: freezed == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateExerciseRequest].
extension CreateExerciseRequestPatterns on CreateExerciseRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateExerciseRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateExerciseRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateExerciseRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateExerciseRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateExerciseRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateExerciseRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  ExerciseCategory category,  ExerciseDifficulty difficulty,  String? description,  List<String>? muscleGroups,  List<String>? equipment,  bool isPublic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateExerciseRequest() when $default != null:
return $default(_that.name,_that.category,_that.difficulty,_that.description,_that.muscleGroups,_that.equipment,_that.isPublic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  ExerciseCategory category,  ExerciseDifficulty difficulty,  String? description,  List<String>? muscleGroups,  List<String>? equipment,  bool isPublic)  $default,) {final _that = this;
switch (_that) {
case _CreateExerciseRequest():
return $default(_that.name,_that.category,_that.difficulty,_that.description,_that.muscleGroups,_that.equipment,_that.isPublic);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  ExerciseCategory category,  ExerciseDifficulty difficulty,  String? description,  List<String>? muscleGroups,  List<String>? equipment,  bool isPublic)?  $default,) {final _that = this;
switch (_that) {
case _CreateExerciseRequest() when $default != null:
return $default(_that.name,_that.category,_that.difficulty,_that.description,_that.muscleGroups,_that.equipment,_that.isPublic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateExerciseRequest implements CreateExerciseRequest {
  const _CreateExerciseRequest({required this.name, required this.category, required this.difficulty, this.description, final  List<String>? muscleGroups, final  List<String>? equipment, this.isPublic = true}): _muscleGroups = muscleGroups,_equipment = equipment;
  factory _CreateExerciseRequest.fromJson(Map<String, dynamic> json) => _$CreateExerciseRequestFromJson(json);

@override final  String name;
@override final  ExerciseCategory category;
@override final  ExerciseDifficulty difficulty;
@override final  String? description;
 final  List<String>? _muscleGroups;
@override List<String>? get muscleGroups {
  final value = _muscleGroups;
  if (value == null) return null;
  if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _equipment;
@override List<String>? get equipment {
  final value = _equipment;
  if (value == null) return null;
  if (_equipment is EqualUnmodifiableListView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool isPublic;

/// Create a copy of CreateExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateExerciseRequestCopyWith<_CreateExerciseRequest> get copyWith => __$CreateExerciseRequestCopyWithImpl<_CreateExerciseRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateExerciseRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateExerciseRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._muscleGroups, _muscleGroups)&&const DeepCollectionEquality().equals(other._equipment, _equipment)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,category,difficulty,description,const DeepCollectionEquality().hash(_muscleGroups),const DeepCollectionEquality().hash(_equipment),isPublic);

@override
String toString() {
  return 'CreateExerciseRequest(name: $name, category: $category, difficulty: $difficulty, description: $description, muscleGroups: $muscleGroups, equipment: $equipment, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class _$CreateExerciseRequestCopyWith<$Res> implements $CreateExerciseRequestCopyWith<$Res> {
  factory _$CreateExerciseRequestCopyWith(_CreateExerciseRequest value, $Res Function(_CreateExerciseRequest) _then) = __$CreateExerciseRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, ExerciseCategory category, ExerciseDifficulty difficulty, String? description, List<String>? muscleGroups, List<String>? equipment, bool isPublic
});




}
/// @nodoc
class __$CreateExerciseRequestCopyWithImpl<$Res>
    implements _$CreateExerciseRequestCopyWith<$Res> {
  __$CreateExerciseRequestCopyWithImpl(this._self, this._then);

  final _CreateExerciseRequest _self;
  final $Res Function(_CreateExerciseRequest) _then;

/// Create a copy of CreateExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? category = null,Object? difficulty = null,Object? description = freezed,Object? muscleGroups = freezed,Object? equipment = freezed,Object? isPublic = null,}) {
  return _then(_CreateExerciseRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ExerciseDifficulty,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,muscleGroups: freezed == muscleGroups ? _self._muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>?,equipment: freezed == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UpdateExerciseLibraryRequest {

 String get name; ExerciseCategory get category; ExerciseDifficulty get difficulty; String? get description; List<String>? get muscleGroups; List<String>? get equipment; bool get isPublic;
/// Create a copy of UpdateExerciseLibraryRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateExerciseLibraryRequestCopyWith<UpdateExerciseLibraryRequest> get copyWith => _$UpdateExerciseLibraryRequestCopyWithImpl<UpdateExerciseLibraryRequest>(this as UpdateExerciseLibraryRequest, _$identity);

  /// Serializes this UpdateExerciseLibraryRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateExerciseLibraryRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.muscleGroups, muscleGroups)&&const DeepCollectionEquality().equals(other.equipment, equipment)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,category,difficulty,description,const DeepCollectionEquality().hash(muscleGroups),const DeepCollectionEquality().hash(equipment),isPublic);

@override
String toString() {
  return 'UpdateExerciseLibraryRequest(name: $name, category: $category, difficulty: $difficulty, description: $description, muscleGroups: $muscleGroups, equipment: $equipment, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class $UpdateExerciseLibraryRequestCopyWith<$Res>  {
  factory $UpdateExerciseLibraryRequestCopyWith(UpdateExerciseLibraryRequest value, $Res Function(UpdateExerciseLibraryRequest) _then) = _$UpdateExerciseLibraryRequestCopyWithImpl;
@useResult
$Res call({
 String name, ExerciseCategory category, ExerciseDifficulty difficulty, String? description, List<String>? muscleGroups, List<String>? equipment, bool isPublic
});




}
/// @nodoc
class _$UpdateExerciseLibraryRequestCopyWithImpl<$Res>
    implements $UpdateExerciseLibraryRequestCopyWith<$Res> {
  _$UpdateExerciseLibraryRequestCopyWithImpl(this._self, this._then);

  final UpdateExerciseLibraryRequest _self;
  final $Res Function(UpdateExerciseLibraryRequest) _then;

/// Create a copy of UpdateExerciseLibraryRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? category = null,Object? difficulty = null,Object? description = freezed,Object? muscleGroups = freezed,Object? equipment = freezed,Object? isPublic = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ExerciseDifficulty,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,muscleGroups: freezed == muscleGroups ? _self.muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>?,equipment: freezed == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateExerciseLibraryRequest].
extension UpdateExerciseLibraryRequestPatterns on UpdateExerciseLibraryRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateExerciseLibraryRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateExerciseLibraryRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateExerciseLibraryRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateExerciseLibraryRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateExerciseLibraryRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateExerciseLibraryRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  ExerciseCategory category,  ExerciseDifficulty difficulty,  String? description,  List<String>? muscleGroups,  List<String>? equipment,  bool isPublic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateExerciseLibraryRequest() when $default != null:
return $default(_that.name,_that.category,_that.difficulty,_that.description,_that.muscleGroups,_that.equipment,_that.isPublic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  ExerciseCategory category,  ExerciseDifficulty difficulty,  String? description,  List<String>? muscleGroups,  List<String>? equipment,  bool isPublic)  $default,) {final _that = this;
switch (_that) {
case _UpdateExerciseLibraryRequest():
return $default(_that.name,_that.category,_that.difficulty,_that.description,_that.muscleGroups,_that.equipment,_that.isPublic);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  ExerciseCategory category,  ExerciseDifficulty difficulty,  String? description,  List<String>? muscleGroups,  List<String>? equipment,  bool isPublic)?  $default,) {final _that = this;
switch (_that) {
case _UpdateExerciseLibraryRequest() when $default != null:
return $default(_that.name,_that.category,_that.difficulty,_that.description,_that.muscleGroups,_that.equipment,_that.isPublic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateExerciseLibraryRequest implements UpdateExerciseLibraryRequest {
  const _UpdateExerciseLibraryRequest({required this.name, required this.category, required this.difficulty, this.description, final  List<String>? muscleGroups, final  List<String>? equipment, required this.isPublic}): _muscleGroups = muscleGroups,_equipment = equipment;
  factory _UpdateExerciseLibraryRequest.fromJson(Map<String, dynamic> json) => _$UpdateExerciseLibraryRequestFromJson(json);

@override final  String name;
@override final  ExerciseCategory category;
@override final  ExerciseDifficulty difficulty;
@override final  String? description;
 final  List<String>? _muscleGroups;
@override List<String>? get muscleGroups {
  final value = _muscleGroups;
  if (value == null) return null;
  if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _equipment;
@override List<String>? get equipment {
  final value = _equipment;
  if (value == null) return null;
  if (_equipment is EqualUnmodifiableListView) return _equipment;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool isPublic;

/// Create a copy of UpdateExerciseLibraryRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateExerciseLibraryRequestCopyWith<_UpdateExerciseLibraryRequest> get copyWith => __$UpdateExerciseLibraryRequestCopyWithImpl<_UpdateExerciseLibraryRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateExerciseLibraryRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateExerciseLibraryRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._muscleGroups, _muscleGroups)&&const DeepCollectionEquality().equals(other._equipment, _equipment)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,category,difficulty,description,const DeepCollectionEquality().hash(_muscleGroups),const DeepCollectionEquality().hash(_equipment),isPublic);

@override
String toString() {
  return 'UpdateExerciseLibraryRequest(name: $name, category: $category, difficulty: $difficulty, description: $description, muscleGroups: $muscleGroups, equipment: $equipment, isPublic: $isPublic)';
}


}

/// @nodoc
abstract mixin class _$UpdateExerciseLibraryRequestCopyWith<$Res> implements $UpdateExerciseLibraryRequestCopyWith<$Res> {
  factory _$UpdateExerciseLibraryRequestCopyWith(_UpdateExerciseLibraryRequest value, $Res Function(_UpdateExerciseLibraryRequest) _then) = __$UpdateExerciseLibraryRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, ExerciseCategory category, ExerciseDifficulty difficulty, String? description, List<String>? muscleGroups, List<String>? equipment, bool isPublic
});




}
/// @nodoc
class __$UpdateExerciseLibraryRequestCopyWithImpl<$Res>
    implements _$UpdateExerciseLibraryRequestCopyWith<$Res> {
  __$UpdateExerciseLibraryRequestCopyWithImpl(this._self, this._then);

  final _UpdateExerciseLibraryRequest _self;
  final $Res Function(_UpdateExerciseLibraryRequest) _then;

/// Create a copy of UpdateExerciseLibraryRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? category = null,Object? difficulty = null,Object? description = freezed,Object? muscleGroups = freezed,Object? equipment = freezed,Object? isPublic = null,}) {
  return _then(_UpdateExerciseLibraryRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExerciseCategory,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as ExerciseDifficulty,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,muscleGroups: freezed == muscleGroups ? _self._muscleGroups : muscleGroups // ignore: cast_nullable_to_non_nullable
as List<String>?,equipment: freezed == equipment ? _self._equipment : equipment // ignore: cast_nullable_to_non_nullable
as List<String>?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
