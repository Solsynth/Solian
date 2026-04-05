// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnWorkout {

 String get id; String get accountId; String get name; String? get description; WorkoutType get type; DateTime get startTime; DateTime? get endTime; String? get duration; int? get caloriesBurned; String? get notes; DateTime get createdAt; DateTime get updatedAt; List<SnWorkoutExercise> get exercises;
/// Create a copy of SnWorkout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWorkoutCopyWith<SnWorkout> get copyWith => _$SnWorkoutCopyWithImpl<SnWorkout>(this as SnWorkout, _$identity);

  /// Serializes this SnWorkout to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.exercises, exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,name,description,type,startTime,endTime,duration,caloriesBurned,notes,createdAt,updatedAt,const DeepCollectionEquality().hash(exercises));

@override
String toString() {
  return 'SnWorkout(id: $id, accountId: $accountId, name: $name, description: $description, type: $type, startTime: $startTime, endTime: $endTime, duration: $duration, caloriesBurned: $caloriesBurned, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class $SnWorkoutCopyWith<$Res>  {
  factory $SnWorkoutCopyWith(SnWorkout value, $Res Function(SnWorkout) _then) = _$SnWorkoutCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, String name, String? description, WorkoutType type, DateTime startTime, DateTime? endTime, String? duration, int? caloriesBurned, String? notes, DateTime createdAt, DateTime updatedAt, List<SnWorkoutExercise> exercises
});




}
/// @nodoc
class _$SnWorkoutCopyWithImpl<$Res>
    implements $SnWorkoutCopyWith<$Res> {
  _$SnWorkoutCopyWithImpl(this._self, this._then);

  final SnWorkout _self;
  final $Res Function(SnWorkout) _then;

/// Create a copy of SnWorkout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? name = null,Object? description = freezed,Object? type = null,Object? startTime = null,Object? endTime = freezed,Object? duration = freezed,Object? caloriesBurned = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,Object? exercises = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkoutType,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SnWorkoutExercise>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnWorkout].
extension SnWorkoutPatterns on SnWorkout {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWorkout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWorkout() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWorkout value)  $default,){
final _that = this;
switch (_that) {
case _SnWorkout():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWorkout value)?  $default,){
final _that = this;
switch (_that) {
case _SnWorkout() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  String name,  String? description,  WorkoutType type,  DateTime startTime,  DateTime? endTime,  String? duration,  int? caloriesBurned,  String? notes,  DateTime createdAt,  DateTime updatedAt,  List<SnWorkoutExercise> exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWorkout() when $default != null:
return $default(_that.id,_that.accountId,_that.name,_that.description,_that.type,_that.startTime,_that.endTime,_that.duration,_that.caloriesBurned,_that.notes,_that.createdAt,_that.updatedAt,_that.exercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  String name,  String? description,  WorkoutType type,  DateTime startTime,  DateTime? endTime,  String? duration,  int? caloriesBurned,  String? notes,  DateTime createdAt,  DateTime updatedAt,  List<SnWorkoutExercise> exercises)  $default,) {final _that = this;
switch (_that) {
case _SnWorkout():
return $default(_that.id,_that.accountId,_that.name,_that.description,_that.type,_that.startTime,_that.endTime,_that.duration,_that.caloriesBurned,_that.notes,_that.createdAt,_that.updatedAt,_that.exercises);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  String name,  String? description,  WorkoutType type,  DateTime startTime,  DateTime? endTime,  String? duration,  int? caloriesBurned,  String? notes,  DateTime createdAt,  DateTime updatedAt,  List<SnWorkoutExercise> exercises)?  $default,) {final _that = this;
switch (_that) {
case _SnWorkout() when $default != null:
return $default(_that.id,_that.accountId,_that.name,_that.description,_that.type,_that.startTime,_that.endTime,_that.duration,_that.caloriesBurned,_that.notes,_that.createdAt,_that.updatedAt,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWorkout implements SnWorkout {
  const _SnWorkout({required this.id, required this.accountId, required this.name, this.description, required this.type, required this.startTime, this.endTime, this.duration, this.caloriesBurned, this.notes, required this.createdAt, required this.updatedAt, final  List<SnWorkoutExercise> exercises = const []}): _exercises = exercises;
  factory _SnWorkout.fromJson(Map<String, dynamic> json) => _$SnWorkoutFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  String name;
@override final  String? description;
@override final  WorkoutType type;
@override final  DateTime startTime;
@override final  DateTime? endTime;
@override final  String? duration;
@override final  int? caloriesBurned;
@override final  String? notes;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
 final  List<SnWorkoutExercise> _exercises;
@override@JsonKey() List<SnWorkoutExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}


/// Create a copy of SnWorkout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWorkoutCopyWith<_SnWorkout> get copyWith => __$SnWorkoutCopyWithImpl<_SnWorkout>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWorkoutToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWorkout&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._exercises, _exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,accountId,name,description,type,startTime,endTime,duration,caloriesBurned,notes,createdAt,updatedAt,const DeepCollectionEquality().hash(_exercises));

@override
String toString() {
  return 'SnWorkout(id: $id, accountId: $accountId, name: $name, description: $description, type: $type, startTime: $startTime, endTime: $endTime, duration: $duration, caloriesBurned: $caloriesBurned, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$SnWorkoutCopyWith<$Res> implements $SnWorkoutCopyWith<$Res> {
  factory _$SnWorkoutCopyWith(_SnWorkout value, $Res Function(_SnWorkout) _then) = __$SnWorkoutCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, String name, String? description, WorkoutType type, DateTime startTime, DateTime? endTime, String? duration, int? caloriesBurned, String? notes, DateTime createdAt, DateTime updatedAt, List<SnWorkoutExercise> exercises
});




}
/// @nodoc
class __$SnWorkoutCopyWithImpl<$Res>
    implements _$SnWorkoutCopyWith<$Res> {
  __$SnWorkoutCopyWithImpl(this._self, this._then);

  final _SnWorkout _self;
  final $Res Function(_SnWorkout) _then;

/// Create a copy of SnWorkout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? name = null,Object? description = freezed,Object? type = null,Object? startTime = null,Object? endTime = freezed,Object? duration = freezed,Object? caloriesBurned = freezed,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,Object? exercises = null,}) {
  return _then(_SnWorkout(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkoutType,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<SnWorkoutExercise>,
  ));
}


}


/// @nodoc
mixin _$SnWorkoutExercise {

 String get id; String get workoutId; String get exerciseName; int? get sets; int? get reps; double? get weight; String? get duration; String? get notes; int get orderIndex; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SnWorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnWorkoutExerciseCopyWith<SnWorkoutExercise> get copyWith => _$SnWorkoutExerciseCopyWithImpl<SnWorkoutExercise>(this as SnWorkoutExercise, _$identity);

  /// Serializes this SnWorkoutExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnWorkoutExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,exerciseName,sets,reps,weight,duration,notes,orderIndex,createdAt,updatedAt);

@override
String toString() {
  return 'SnWorkoutExercise(id: $id, workoutId: $workoutId, exerciseName: $exerciseName, sets: $sets, reps: $reps, weight: $weight, duration: $duration, notes: $notes, orderIndex: $orderIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SnWorkoutExerciseCopyWith<$Res>  {
  factory $SnWorkoutExerciseCopyWith(SnWorkoutExercise value, $Res Function(SnWorkoutExercise) _then) = _$SnWorkoutExerciseCopyWithImpl;
@useResult
$Res call({
 String id, String workoutId, String exerciseName, int? sets, int? reps, double? weight, String? duration, String? notes, int orderIndex, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SnWorkoutExerciseCopyWithImpl<$Res>
    implements $SnWorkoutExerciseCopyWith<$Res> {
  _$SnWorkoutExerciseCopyWithImpl(this._self, this._then);

  final SnWorkoutExercise _self;
  final $Res Function(SnWorkoutExercise) _then;

/// Create a copy of SnWorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? workoutId = null,Object? exerciseName = null,Object? sets = freezed,Object? reps = freezed,Object? weight = freezed,Object? duration = freezed,Object? notes = freezed,Object? orderIndex = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SnWorkoutExercise].
extension SnWorkoutExercisePatterns on SnWorkoutExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnWorkoutExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnWorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnWorkoutExercise value)  $default,){
final _that = this;
switch (_that) {
case _SnWorkoutExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnWorkoutExercise value)?  $default,){
final _that = this;
switch (_that) {
case _SnWorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String workoutId,  String exerciseName,  int? sets,  int? reps,  double? weight,  String? duration,  String? notes,  int orderIndex,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnWorkoutExercise() when $default != null:
return $default(_that.id,_that.workoutId,_that.exerciseName,_that.sets,_that.reps,_that.weight,_that.duration,_that.notes,_that.orderIndex,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String workoutId,  String exerciseName,  int? sets,  int? reps,  double? weight,  String? duration,  String? notes,  int orderIndex,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SnWorkoutExercise():
return $default(_that.id,_that.workoutId,_that.exerciseName,_that.sets,_that.reps,_that.weight,_that.duration,_that.notes,_that.orderIndex,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String workoutId,  String exerciseName,  int? sets,  int? reps,  double? weight,  String? duration,  String? notes,  int orderIndex,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnWorkoutExercise() when $default != null:
return $default(_that.id,_that.workoutId,_that.exerciseName,_that.sets,_that.reps,_that.weight,_that.duration,_that.notes,_that.orderIndex,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnWorkoutExercise implements SnWorkoutExercise {
  const _SnWorkoutExercise({required this.id, required this.workoutId, required this.exerciseName, this.sets, this.reps, this.weight, this.duration, this.notes, required this.orderIndex, required this.createdAt, required this.updatedAt});
  factory _SnWorkoutExercise.fromJson(Map<String, dynamic> json) => _$SnWorkoutExerciseFromJson(json);

@override final  String id;
@override final  String workoutId;
@override final  String exerciseName;
@override final  int? sets;
@override final  int? reps;
@override final  double? weight;
@override final  String? duration;
@override final  String? notes;
@override final  int orderIndex;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SnWorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnWorkoutExerciseCopyWith<_SnWorkoutExercise> get copyWith => __$SnWorkoutExerciseCopyWithImpl<_SnWorkoutExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnWorkoutExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnWorkoutExercise&&(identical(other.id, id) || other.id == id)&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,workoutId,exerciseName,sets,reps,weight,duration,notes,orderIndex,createdAt,updatedAt);

@override
String toString() {
  return 'SnWorkoutExercise(id: $id, workoutId: $workoutId, exerciseName: $exerciseName, sets: $sets, reps: $reps, weight: $weight, duration: $duration, notes: $notes, orderIndex: $orderIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SnWorkoutExerciseCopyWith<$Res> implements $SnWorkoutExerciseCopyWith<$Res> {
  factory _$SnWorkoutExerciseCopyWith(_SnWorkoutExercise value, $Res Function(_SnWorkoutExercise) _then) = __$SnWorkoutExerciseCopyWithImpl;
@override @useResult
$Res call({
 String id, String workoutId, String exerciseName, int? sets, int? reps, double? weight, String? duration, String? notes, int orderIndex, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SnWorkoutExerciseCopyWithImpl<$Res>
    implements _$SnWorkoutExerciseCopyWith<$Res> {
  __$SnWorkoutExerciseCopyWithImpl(this._self, this._then);

  final _SnWorkoutExercise _self;
  final $Res Function(_SnWorkoutExercise) _then;

/// Create a copy of SnWorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? workoutId = null,Object? exerciseName = null,Object? sets = freezed,Object? reps = freezed,Object? weight = freezed,Object? duration = freezed,Object? notes = freezed,Object? orderIndex = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SnWorkoutExercise(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,workoutId: null == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String,exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$CreateWorkoutRequest {

 String get name; WorkoutType get type;@DateTimeConverter() DateTime get startTime;@NullableDateTimeConverter() DateTime? get endTime; String? get description; String? get externalId; int? get caloriesBurned; String? get notes;
/// Create a copy of CreateWorkoutRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWorkoutRequestCopyWith<CreateWorkoutRequest> get copyWith => _$CreateWorkoutRequestCopyWithImpl<CreateWorkoutRequest>(this as CreateWorkoutRequest, _$identity);

  /// Serializes this CreateWorkoutRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWorkoutRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,startTime,endTime,description,externalId,caloriesBurned,notes);

@override
String toString() {
  return 'CreateWorkoutRequest(name: $name, type: $type, startTime: $startTime, endTime: $endTime, description: $description, externalId: $externalId, caloriesBurned: $caloriesBurned, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $CreateWorkoutRequestCopyWith<$Res>  {
  factory $CreateWorkoutRequestCopyWith(CreateWorkoutRequest value, $Res Function(CreateWorkoutRequest) _then) = _$CreateWorkoutRequestCopyWithImpl;
@useResult
$Res call({
 String name, WorkoutType type,@DateTimeConverter() DateTime startTime,@NullableDateTimeConverter() DateTime? endTime, String? description, String? externalId, int? caloriesBurned, String? notes
});




}
/// @nodoc
class _$CreateWorkoutRequestCopyWithImpl<$Res>
    implements $CreateWorkoutRequestCopyWith<$Res> {
  _$CreateWorkoutRequestCopyWithImpl(this._self, this._then);

  final CreateWorkoutRequest _self;
  final $Res Function(CreateWorkoutRequest) _then;

/// Create a copy of CreateWorkoutRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? startTime = null,Object? endTime = freezed,Object? description = freezed,Object? externalId = freezed,Object? caloriesBurned = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkoutType,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWorkoutRequest].
extension CreateWorkoutRequestPatterns on CreateWorkoutRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWorkoutRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWorkoutRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWorkoutRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateWorkoutRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWorkoutRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWorkoutRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  WorkoutType type, @DateTimeConverter()  DateTime startTime, @NullableDateTimeConverter()  DateTime? endTime,  String? description,  String? externalId,  int? caloriesBurned,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWorkoutRequest() when $default != null:
return $default(_that.name,_that.type,_that.startTime,_that.endTime,_that.description,_that.externalId,_that.caloriesBurned,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  WorkoutType type, @DateTimeConverter()  DateTime startTime, @NullableDateTimeConverter()  DateTime? endTime,  String? description,  String? externalId,  int? caloriesBurned,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _CreateWorkoutRequest():
return $default(_that.name,_that.type,_that.startTime,_that.endTime,_that.description,_that.externalId,_that.caloriesBurned,_that.notes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  WorkoutType type, @DateTimeConverter()  DateTime startTime, @NullableDateTimeConverter()  DateTime? endTime,  String? description,  String? externalId,  int? caloriesBurned,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _CreateWorkoutRequest() when $default != null:
return $default(_that.name,_that.type,_that.startTime,_that.endTime,_that.description,_that.externalId,_that.caloriesBurned,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWorkoutRequest implements CreateWorkoutRequest {
  const _CreateWorkoutRequest({required this.name, required this.type, @DateTimeConverter() required this.startTime, @NullableDateTimeConverter() this.endTime, this.description, this.externalId, this.caloriesBurned, this.notes});
  factory _CreateWorkoutRequest.fromJson(Map<String, dynamic> json) => _$CreateWorkoutRequestFromJson(json);

@override final  String name;
@override final  WorkoutType type;
@override@DateTimeConverter() final  DateTime startTime;
@override@NullableDateTimeConverter() final  DateTime? endTime;
@override final  String? description;
@override final  String? externalId;
@override final  int? caloriesBurned;
@override final  String? notes;

/// Create a copy of CreateWorkoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWorkoutRequestCopyWith<_CreateWorkoutRequest> get copyWith => __$CreateWorkoutRequestCopyWithImpl<_CreateWorkoutRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWorkoutRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWorkoutRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.externalId, externalId) || other.externalId == externalId)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,startTime,endTime,description,externalId,caloriesBurned,notes);

@override
String toString() {
  return 'CreateWorkoutRequest(name: $name, type: $type, startTime: $startTime, endTime: $endTime, description: $description, externalId: $externalId, caloriesBurned: $caloriesBurned, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$CreateWorkoutRequestCopyWith<$Res> implements $CreateWorkoutRequestCopyWith<$Res> {
  factory _$CreateWorkoutRequestCopyWith(_CreateWorkoutRequest value, $Res Function(_CreateWorkoutRequest) _then) = __$CreateWorkoutRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, WorkoutType type,@DateTimeConverter() DateTime startTime,@NullableDateTimeConverter() DateTime? endTime, String? description, String? externalId, int? caloriesBurned, String? notes
});




}
/// @nodoc
class __$CreateWorkoutRequestCopyWithImpl<$Res>
    implements _$CreateWorkoutRequestCopyWith<$Res> {
  __$CreateWorkoutRequestCopyWithImpl(this._self, this._then);

  final _CreateWorkoutRequest _self;
  final $Res Function(_CreateWorkoutRequest) _then;

/// Create a copy of CreateWorkoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? startTime = null,Object? endTime = freezed,Object? description = freezed,Object? externalId = freezed,Object? caloriesBurned = freezed,Object? notes = freezed,}) {
  return _then(_CreateWorkoutRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkoutType,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,externalId: freezed == externalId ? _self.externalId : externalId // ignore: cast_nullable_to_non_nullable
as String?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateWorkoutRequest {

 String get name; WorkoutType get type;@DateTimeConverter() DateTime get startTime; String? get description; String? get duration; int? get caloriesBurned; String? get notes;
/// Create a copy of UpdateWorkoutRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateWorkoutRequestCopyWith<UpdateWorkoutRequest> get copyWith => _$UpdateWorkoutRequestCopyWithImpl<UpdateWorkoutRequest>(this as UpdateWorkoutRequest, _$identity);

  /// Serializes this UpdateWorkoutRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateWorkoutRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,startTime,description,duration,caloriesBurned,notes);

@override
String toString() {
  return 'UpdateWorkoutRequest(name: $name, type: $type, startTime: $startTime, description: $description, duration: $duration, caloriesBurned: $caloriesBurned, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $UpdateWorkoutRequestCopyWith<$Res>  {
  factory $UpdateWorkoutRequestCopyWith(UpdateWorkoutRequest value, $Res Function(UpdateWorkoutRequest) _then) = _$UpdateWorkoutRequestCopyWithImpl;
@useResult
$Res call({
 String name, WorkoutType type,@DateTimeConverter() DateTime startTime, String? description, String? duration, int? caloriesBurned, String? notes
});




}
/// @nodoc
class _$UpdateWorkoutRequestCopyWithImpl<$Res>
    implements $UpdateWorkoutRequestCopyWith<$Res> {
  _$UpdateWorkoutRequestCopyWithImpl(this._self, this._then);

  final UpdateWorkoutRequest _self;
  final $Res Function(UpdateWorkoutRequest) _then;

/// Create a copy of UpdateWorkoutRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? type = null,Object? startTime = null,Object? description = freezed,Object? duration = freezed,Object? caloriesBurned = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkoutType,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateWorkoutRequest].
extension UpdateWorkoutRequestPatterns on UpdateWorkoutRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateWorkoutRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateWorkoutRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateWorkoutRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateWorkoutRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateWorkoutRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateWorkoutRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  WorkoutType type, @DateTimeConverter()  DateTime startTime,  String? description,  String? duration,  int? caloriesBurned,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateWorkoutRequest() when $default != null:
return $default(_that.name,_that.type,_that.startTime,_that.description,_that.duration,_that.caloriesBurned,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  WorkoutType type, @DateTimeConverter()  DateTime startTime,  String? description,  String? duration,  int? caloriesBurned,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _UpdateWorkoutRequest():
return $default(_that.name,_that.type,_that.startTime,_that.description,_that.duration,_that.caloriesBurned,_that.notes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  WorkoutType type, @DateTimeConverter()  DateTime startTime,  String? description,  String? duration,  int? caloriesBurned,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _UpdateWorkoutRequest() when $default != null:
return $default(_that.name,_that.type,_that.startTime,_that.description,_that.duration,_that.caloriesBurned,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateWorkoutRequest implements UpdateWorkoutRequest {
  const _UpdateWorkoutRequest({required this.name, required this.type, @DateTimeConverter() required this.startTime, this.description, this.duration, this.caloriesBurned, this.notes});
  factory _UpdateWorkoutRequest.fromJson(Map<String, dynamic> json) => _$UpdateWorkoutRequestFromJson(json);

@override final  String name;
@override final  WorkoutType type;
@override@DateTimeConverter() final  DateTime startTime;
@override final  String? description;
@override final  String? duration;
@override final  int? caloriesBurned;
@override final  String? notes;

/// Create a copy of UpdateWorkoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateWorkoutRequestCopyWith<_UpdateWorkoutRequest> get copyWith => __$UpdateWorkoutRequestCopyWithImpl<_UpdateWorkoutRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateWorkoutRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateWorkoutRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.description, description) || other.description == description)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.caloriesBurned, caloriesBurned) || other.caloriesBurned == caloriesBurned)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,type,startTime,description,duration,caloriesBurned,notes);

@override
String toString() {
  return 'UpdateWorkoutRequest(name: $name, type: $type, startTime: $startTime, description: $description, duration: $duration, caloriesBurned: $caloriesBurned, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$UpdateWorkoutRequestCopyWith<$Res> implements $UpdateWorkoutRequestCopyWith<$Res> {
  factory _$UpdateWorkoutRequestCopyWith(_UpdateWorkoutRequest value, $Res Function(_UpdateWorkoutRequest) _then) = __$UpdateWorkoutRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, WorkoutType type,@DateTimeConverter() DateTime startTime, String? description, String? duration, int? caloriesBurned, String? notes
});




}
/// @nodoc
class __$UpdateWorkoutRequestCopyWithImpl<$Res>
    implements _$UpdateWorkoutRequestCopyWith<$Res> {
  __$UpdateWorkoutRequestCopyWithImpl(this._self, this._then);

  final _UpdateWorkoutRequest _self;
  final $Res Function(_UpdateWorkoutRequest) _then;

/// Create a copy of UpdateWorkoutRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? type = null,Object? startTime = null,Object? description = freezed,Object? duration = freezed,Object? caloriesBurned = freezed,Object? notes = freezed,}) {
  return _then(_UpdateWorkoutRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WorkoutType,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as String?,caloriesBurned: freezed == caloriesBurned ? _self.caloriesBurned : caloriesBurned // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AddExerciseRequest {

 String get exerciseName; int? get sets; int? get reps; double? get weight; String? get notes; int get orderIndex;
/// Create a copy of AddExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddExerciseRequestCopyWith<AddExerciseRequest> get copyWith => _$AddExerciseRequestCopyWithImpl<AddExerciseRequest>(this as AddExerciseRequest, _$identity);

  /// Serializes this AddExerciseRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddExerciseRequest&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,sets,reps,weight,notes,orderIndex);

@override
String toString() {
  return 'AddExerciseRequest(exerciseName: $exerciseName, sets: $sets, reps: $reps, weight: $weight, notes: $notes, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class $AddExerciseRequestCopyWith<$Res>  {
  factory $AddExerciseRequestCopyWith(AddExerciseRequest value, $Res Function(AddExerciseRequest) _then) = _$AddExerciseRequestCopyWithImpl;
@useResult
$Res call({
 String exerciseName, int? sets, int? reps, double? weight, String? notes, int orderIndex
});




}
/// @nodoc
class _$AddExerciseRequestCopyWithImpl<$Res>
    implements $AddExerciseRequestCopyWith<$Res> {
  _$AddExerciseRequestCopyWithImpl(this._self, this._then);

  final AddExerciseRequest _self;
  final $Res Function(AddExerciseRequest) _then;

/// Create a copy of AddExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? sets = freezed,Object? reps = freezed,Object? weight = freezed,Object? notes = freezed,Object? orderIndex = null,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AddExerciseRequest].
extension AddExerciseRequestPatterns on AddExerciseRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddExerciseRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddExerciseRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddExerciseRequest value)  $default,){
final _that = this;
switch (_that) {
case _AddExerciseRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddExerciseRequest value)?  $default,){
final _that = this;
switch (_that) {
case _AddExerciseRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  int? sets,  int? reps,  double? weight,  String? notes,  int orderIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddExerciseRequest() when $default != null:
return $default(_that.exerciseName,_that.sets,_that.reps,_that.weight,_that.notes,_that.orderIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  int? sets,  int? reps,  double? weight,  String? notes,  int orderIndex)  $default,) {final _that = this;
switch (_that) {
case _AddExerciseRequest():
return $default(_that.exerciseName,_that.sets,_that.reps,_that.weight,_that.notes,_that.orderIndex);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  int? sets,  int? reps,  double? weight,  String? notes,  int orderIndex)?  $default,) {final _that = this;
switch (_that) {
case _AddExerciseRequest() when $default != null:
return $default(_that.exerciseName,_that.sets,_that.reps,_that.weight,_that.notes,_that.orderIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AddExerciseRequest implements AddExerciseRequest {
  const _AddExerciseRequest({required this.exerciseName, this.sets, this.reps, this.weight, this.notes, required this.orderIndex});
  factory _AddExerciseRequest.fromJson(Map<String, dynamic> json) => _$AddExerciseRequestFromJson(json);

@override final  String exerciseName;
@override final  int? sets;
@override final  int? reps;
@override final  double? weight;
@override final  String? notes;
@override final  int orderIndex;

/// Create a copy of AddExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddExerciseRequestCopyWith<_AddExerciseRequest> get copyWith => __$AddExerciseRequestCopyWithImpl<_AddExerciseRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AddExerciseRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddExerciseRequest&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,sets,reps,weight,notes,orderIndex);

@override
String toString() {
  return 'AddExerciseRequest(exerciseName: $exerciseName, sets: $sets, reps: $reps, weight: $weight, notes: $notes, orderIndex: $orderIndex)';
}


}

/// @nodoc
abstract mixin class _$AddExerciseRequestCopyWith<$Res> implements $AddExerciseRequestCopyWith<$Res> {
  factory _$AddExerciseRequestCopyWith(_AddExerciseRequest value, $Res Function(_AddExerciseRequest) _then) = __$AddExerciseRequestCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, int? sets, int? reps, double? weight, String? notes, int orderIndex
});




}
/// @nodoc
class __$AddExerciseRequestCopyWithImpl<$Res>
    implements _$AddExerciseRequestCopyWith<$Res> {
  __$AddExerciseRequestCopyWithImpl(this._self, this._then);

  final _AddExerciseRequest _self;
  final $Res Function(_AddExerciseRequest) _then;

/// Create a copy of AddExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? sets = freezed,Object? reps = freezed,Object? weight = freezed,Object? notes = freezed,Object? orderIndex = null,}) {
  return _then(_AddExerciseRequest(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$UpdateWorkoutExerciseRequest {

 String get exerciseName; int? get sets; int? get reps; double? get weight; int? get orderIndex; String? get notes;
/// Create a copy of UpdateWorkoutExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateWorkoutExerciseRequestCopyWith<UpdateWorkoutExerciseRequest> get copyWith => _$UpdateWorkoutExerciseRequestCopyWithImpl<UpdateWorkoutExerciseRequest>(this as UpdateWorkoutExerciseRequest, _$identity);

  /// Serializes this UpdateWorkoutExerciseRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateWorkoutExerciseRequest&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,sets,reps,weight,orderIndex,notes);

@override
String toString() {
  return 'UpdateWorkoutExerciseRequest(exerciseName: $exerciseName, sets: $sets, reps: $reps, weight: $weight, orderIndex: $orderIndex, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $UpdateWorkoutExerciseRequestCopyWith<$Res>  {
  factory $UpdateWorkoutExerciseRequestCopyWith(UpdateWorkoutExerciseRequest value, $Res Function(UpdateWorkoutExerciseRequest) _then) = _$UpdateWorkoutExerciseRequestCopyWithImpl;
@useResult
$Res call({
 String exerciseName, int? sets, int? reps, double? weight, int? orderIndex, String? notes
});




}
/// @nodoc
class _$UpdateWorkoutExerciseRequestCopyWithImpl<$Res>
    implements $UpdateWorkoutExerciseRequestCopyWith<$Res> {
  _$UpdateWorkoutExerciseRequestCopyWithImpl(this._self, this._then);

  final UpdateWorkoutExerciseRequest _self;
  final $Res Function(UpdateWorkoutExerciseRequest) _then;

/// Create a copy of UpdateWorkoutExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? exerciseName = null,Object? sets = freezed,Object? reps = freezed,Object? weight = freezed,Object? orderIndex = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,orderIndex: freezed == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateWorkoutExerciseRequest].
extension UpdateWorkoutExerciseRequestPatterns on UpdateWorkoutExerciseRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateWorkoutExerciseRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateWorkoutExerciseRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateWorkoutExerciseRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateWorkoutExerciseRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateWorkoutExerciseRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateWorkoutExerciseRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String exerciseName,  int? sets,  int? reps,  double? weight,  int? orderIndex,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateWorkoutExerciseRequest() when $default != null:
return $default(_that.exerciseName,_that.sets,_that.reps,_that.weight,_that.orderIndex,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String exerciseName,  int? sets,  int? reps,  double? weight,  int? orderIndex,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _UpdateWorkoutExerciseRequest():
return $default(_that.exerciseName,_that.sets,_that.reps,_that.weight,_that.orderIndex,_that.notes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String exerciseName,  int? sets,  int? reps,  double? weight,  int? orderIndex,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _UpdateWorkoutExerciseRequest() when $default != null:
return $default(_that.exerciseName,_that.sets,_that.reps,_that.weight,_that.orderIndex,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateWorkoutExerciseRequest implements UpdateWorkoutExerciseRequest {
  const _UpdateWorkoutExerciseRequest({required this.exerciseName, this.sets, this.reps, this.weight, this.orderIndex, this.notes});
  factory _UpdateWorkoutExerciseRequest.fromJson(Map<String, dynamic> json) => _$UpdateWorkoutExerciseRequestFromJson(json);

@override final  String exerciseName;
@override final  int? sets;
@override final  int? reps;
@override final  double? weight;
@override final  int? orderIndex;
@override final  String? notes;

/// Create a copy of UpdateWorkoutExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateWorkoutExerciseRequestCopyWith<_UpdateWorkoutExerciseRequest> get copyWith => __$UpdateWorkoutExerciseRequestCopyWithImpl<_UpdateWorkoutExerciseRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateWorkoutExerciseRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateWorkoutExerciseRequest&&(identical(other.exerciseName, exerciseName) || other.exerciseName == exerciseName)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,exerciseName,sets,reps,weight,orderIndex,notes);

@override
String toString() {
  return 'UpdateWorkoutExerciseRequest(exerciseName: $exerciseName, sets: $sets, reps: $reps, weight: $weight, orderIndex: $orderIndex, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$UpdateWorkoutExerciseRequestCopyWith<$Res> implements $UpdateWorkoutExerciseRequestCopyWith<$Res> {
  factory _$UpdateWorkoutExerciseRequestCopyWith(_UpdateWorkoutExerciseRequest value, $Res Function(_UpdateWorkoutExerciseRequest) _then) = __$UpdateWorkoutExerciseRequestCopyWithImpl;
@override @useResult
$Res call({
 String exerciseName, int? sets, int? reps, double? weight, int? orderIndex, String? notes
});




}
/// @nodoc
class __$UpdateWorkoutExerciseRequestCopyWithImpl<$Res>
    implements _$UpdateWorkoutExerciseRequestCopyWith<$Res> {
  __$UpdateWorkoutExerciseRequestCopyWithImpl(this._self, this._then);

  final _UpdateWorkoutExerciseRequest _self;
  final $Res Function(_UpdateWorkoutExerciseRequest) _then;

/// Create a copy of UpdateWorkoutExerciseRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? exerciseName = null,Object? sets = freezed,Object? reps = freezed,Object? weight = freezed,Object? orderIndex = freezed,Object? notes = freezed,}) {
  return _then(_UpdateWorkoutExerciseRequest(
exerciseName: null == exerciseName ? _self.exerciseName : exerciseName // ignore: cast_nullable_to_non_nullable
as String,sets: freezed == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int?,reps: freezed == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int?,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,orderIndex: freezed == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateWorkoutsBatchRequest {

 List<CreateWorkoutRequest> get workouts;
/// Create a copy of CreateWorkoutsBatchRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateWorkoutsBatchRequestCopyWith<CreateWorkoutsBatchRequest> get copyWith => _$CreateWorkoutsBatchRequestCopyWithImpl<CreateWorkoutsBatchRequest>(this as CreateWorkoutsBatchRequest, _$identity);

  /// Serializes this CreateWorkoutsBatchRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateWorkoutsBatchRequest&&const DeepCollectionEquality().equals(other.workouts, workouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(workouts));

@override
String toString() {
  return 'CreateWorkoutsBatchRequest(workouts: $workouts)';
}


}

/// @nodoc
abstract mixin class $CreateWorkoutsBatchRequestCopyWith<$Res>  {
  factory $CreateWorkoutsBatchRequestCopyWith(CreateWorkoutsBatchRequest value, $Res Function(CreateWorkoutsBatchRequest) _then) = _$CreateWorkoutsBatchRequestCopyWithImpl;
@useResult
$Res call({
 List<CreateWorkoutRequest> workouts
});




}
/// @nodoc
class _$CreateWorkoutsBatchRequestCopyWithImpl<$Res>
    implements $CreateWorkoutsBatchRequestCopyWith<$Res> {
  _$CreateWorkoutsBatchRequestCopyWithImpl(this._self, this._then);

  final CreateWorkoutsBatchRequest _self;
  final $Res Function(CreateWorkoutsBatchRequest) _then;

/// Create a copy of CreateWorkoutsBatchRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workouts = null,}) {
  return _then(_self.copyWith(
workouts: null == workouts ? _self.workouts : workouts // ignore: cast_nullable_to_non_nullable
as List<CreateWorkoutRequest>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateWorkoutsBatchRequest].
extension CreateWorkoutsBatchRequestPatterns on CreateWorkoutsBatchRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateWorkoutsBatchRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateWorkoutsBatchRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateWorkoutsBatchRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateWorkoutsBatchRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateWorkoutsBatchRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateWorkoutsBatchRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CreateWorkoutRequest> workouts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateWorkoutsBatchRequest() when $default != null:
return $default(_that.workouts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CreateWorkoutRequest> workouts)  $default,) {final _that = this;
switch (_that) {
case _CreateWorkoutsBatchRequest():
return $default(_that.workouts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CreateWorkoutRequest> workouts)?  $default,) {final _that = this;
switch (_that) {
case _CreateWorkoutsBatchRequest() when $default != null:
return $default(_that.workouts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateWorkoutsBatchRequest implements CreateWorkoutsBatchRequest {
  const _CreateWorkoutsBatchRequest({required final  List<CreateWorkoutRequest> workouts}): _workouts = workouts;
  factory _CreateWorkoutsBatchRequest.fromJson(Map<String, dynamic> json) => _$CreateWorkoutsBatchRequestFromJson(json);

 final  List<CreateWorkoutRequest> _workouts;
@override List<CreateWorkoutRequest> get workouts {
  if (_workouts is EqualUnmodifiableListView) return _workouts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workouts);
}


/// Create a copy of CreateWorkoutsBatchRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateWorkoutsBatchRequestCopyWith<_CreateWorkoutsBatchRequest> get copyWith => __$CreateWorkoutsBatchRequestCopyWithImpl<_CreateWorkoutsBatchRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateWorkoutsBatchRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateWorkoutsBatchRequest&&const DeepCollectionEquality().equals(other._workouts, _workouts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_workouts));

@override
String toString() {
  return 'CreateWorkoutsBatchRequest(workouts: $workouts)';
}


}

/// @nodoc
abstract mixin class _$CreateWorkoutsBatchRequestCopyWith<$Res> implements $CreateWorkoutsBatchRequestCopyWith<$Res> {
  factory _$CreateWorkoutsBatchRequestCopyWith(_CreateWorkoutsBatchRequest value, $Res Function(_CreateWorkoutsBatchRequest) _then) = __$CreateWorkoutsBatchRequestCopyWithImpl;
@override @useResult
$Res call({
 List<CreateWorkoutRequest> workouts
});




}
/// @nodoc
class __$CreateWorkoutsBatchRequestCopyWithImpl<$Res>
    implements _$CreateWorkoutsBatchRequestCopyWith<$Res> {
  __$CreateWorkoutsBatchRequestCopyWithImpl(this._self, this._then);

  final _CreateWorkoutsBatchRequest _self;
  final $Res Function(_CreateWorkoutsBatchRequest) _then;

/// Create a copy of CreateWorkoutsBatchRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workouts = null,}) {
  return _then(_CreateWorkoutsBatchRequest(
workouts: null == workouts ? _self._workouts : workouts // ignore: cast_nullable_to_non_nullable
as List<CreateWorkoutRequest>,
  ));
}


}

// dart format on
