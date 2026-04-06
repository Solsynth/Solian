// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnFitnessGoal {

 String get id; String get accountId; FitnessGoalType get goalType; String get title; String? get description; double? get targetValue; double? get currentValue; String? get unit; int? get boundWorkoutType; int? get boundMetricType; bool get autoUpdateProgress;@DateTimeConverter() DateTime get startDate;@NullableDateTimeConverter() DateTime? get endDate; FitnessGoalStatus get status; String? get notes;@DateTimeConverter() DateTime get createdAt;@DateTimeConverter() DateTime get updatedAt; RepeatType? get repeatType; int? get repeatInterval; int? get repeatCount; int? get currentRepetition; String? get parentGoalId; FitnessVisibility get visibility;
/// Create a copy of SnFitnessGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnFitnessGoalCopyWith<SnFitnessGoal> get copyWith => _$SnFitnessGoalCopyWithImpl<SnFitnessGoal>(this as SnFitnessGoal, _$identity);

  /// Serializes this SnFitnessGoal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnFitnessGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.boundWorkoutType, boundWorkoutType) || other.boundWorkoutType == boundWorkoutType)&&(identical(other.boundMetricType, boundMetricType) || other.boundMetricType == boundMetricType)&&(identical(other.autoUpdateProgress, autoUpdateProgress) || other.autoUpdateProgress == autoUpdateProgress)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.repeatType, repeatType) || other.repeatType == repeatType)&&(identical(other.repeatInterval, repeatInterval) || other.repeatInterval == repeatInterval)&&(identical(other.repeatCount, repeatCount) || other.repeatCount == repeatCount)&&(identical(other.currentRepetition, currentRepetition) || other.currentRepetition == currentRepetition)&&(identical(other.parentGoalId, parentGoalId) || other.parentGoalId == parentGoalId)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,accountId,goalType,title,description,targetValue,currentValue,unit,boundWorkoutType,boundMetricType,autoUpdateProgress,startDate,endDate,status,notes,createdAt,updatedAt,repeatType,repeatInterval,repeatCount,currentRepetition,parentGoalId,visibility]);

@override
String toString() {
  return 'SnFitnessGoal(id: $id, accountId: $accountId, goalType: $goalType, title: $title, description: $description, targetValue: $targetValue, currentValue: $currentValue, unit: $unit, boundWorkoutType: $boundWorkoutType, boundMetricType: $boundMetricType, autoUpdateProgress: $autoUpdateProgress, startDate: $startDate, endDate: $endDate, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, repeatType: $repeatType, repeatInterval: $repeatInterval, repeatCount: $repeatCount, currentRepetition: $currentRepetition, parentGoalId: $parentGoalId, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class $SnFitnessGoalCopyWith<$Res>  {
  factory $SnFitnessGoalCopyWith(SnFitnessGoal value, $Res Function(SnFitnessGoal) _then) = _$SnFitnessGoalCopyWithImpl;
@useResult
$Res call({
 String id, String accountId, FitnessGoalType goalType, String title, String? description, double? targetValue, double? currentValue, String? unit, int? boundWorkoutType, int? boundMetricType, bool autoUpdateProgress,@DateTimeConverter() DateTime startDate,@NullableDateTimeConverter() DateTime? endDate, FitnessGoalStatus status, String? notes,@DateTimeConverter() DateTime createdAt,@DateTimeConverter() DateTime updatedAt, RepeatType? repeatType, int? repeatInterval, int? repeatCount, int? currentRepetition, String? parentGoalId, FitnessVisibility visibility
});




}
/// @nodoc
class _$SnFitnessGoalCopyWithImpl<$Res>
    implements $SnFitnessGoalCopyWith<$Res> {
  _$SnFitnessGoalCopyWithImpl(this._self, this._then);

  final SnFitnessGoal _self;
  final $Res Function(SnFitnessGoal) _then;

/// Create a copy of SnFitnessGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? accountId = null,Object? goalType = null,Object? title = null,Object? description = freezed,Object? targetValue = freezed,Object? currentValue = freezed,Object? unit = freezed,Object? boundWorkoutType = freezed,Object? boundMetricType = freezed,Object? autoUpdateProgress = null,Object? startDate = null,Object? endDate = freezed,Object? status = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,Object? repeatType = freezed,Object? repeatInterval = freezed,Object? repeatCount = freezed,Object? currentRepetition = freezed,Object? parentGoalId = freezed,Object? visibility = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as FitnessGoalType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,currentValue: freezed == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,boundWorkoutType: freezed == boundWorkoutType ? _self.boundWorkoutType : boundWorkoutType // ignore: cast_nullable_to_non_nullable
as int?,boundMetricType: freezed == boundMetricType ? _self.boundMetricType : boundMetricType // ignore: cast_nullable_to_non_nullable
as int?,autoUpdateProgress: null == autoUpdateProgress ? _self.autoUpdateProgress : autoUpdateProgress // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FitnessGoalStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,repeatType: freezed == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as RepeatType?,repeatInterval: freezed == repeatInterval ? _self.repeatInterval : repeatInterval // ignore: cast_nullable_to_non_nullable
as int?,repeatCount: freezed == repeatCount ? _self.repeatCount : repeatCount // ignore: cast_nullable_to_non_nullable
as int?,currentRepetition: freezed == currentRepetition ? _self.currentRepetition : currentRepetition // ignore: cast_nullable_to_non_nullable
as int?,parentGoalId: freezed == parentGoalId ? _self.parentGoalId : parentGoalId // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as FitnessVisibility,
  ));
}

}


/// Adds pattern-matching-related methods to [SnFitnessGoal].
extension SnFitnessGoalPatterns on SnFitnessGoal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnFitnessGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnFitnessGoal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnFitnessGoal value)  $default,){
final _that = this;
switch (_that) {
case _SnFitnessGoal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnFitnessGoal value)?  $default,){
final _that = this;
switch (_that) {
case _SnFitnessGoal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String accountId,  FitnessGoalType goalType,  String title,  String? description,  double? targetValue,  double? currentValue,  String? unit,  int? boundWorkoutType,  int? boundMetricType,  bool autoUpdateProgress, @DateTimeConverter()  DateTime startDate, @NullableDateTimeConverter()  DateTime? endDate,  FitnessGoalStatus status,  String? notes, @DateTimeConverter()  DateTime createdAt, @DateTimeConverter()  DateTime updatedAt,  RepeatType? repeatType,  int? repeatInterval,  int? repeatCount,  int? currentRepetition,  String? parentGoalId,  FitnessVisibility visibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnFitnessGoal() when $default != null:
return $default(_that.id,_that.accountId,_that.goalType,_that.title,_that.description,_that.targetValue,_that.currentValue,_that.unit,_that.boundWorkoutType,_that.boundMetricType,_that.autoUpdateProgress,_that.startDate,_that.endDate,_that.status,_that.notes,_that.createdAt,_that.updatedAt,_that.repeatType,_that.repeatInterval,_that.repeatCount,_that.currentRepetition,_that.parentGoalId,_that.visibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String accountId,  FitnessGoalType goalType,  String title,  String? description,  double? targetValue,  double? currentValue,  String? unit,  int? boundWorkoutType,  int? boundMetricType,  bool autoUpdateProgress, @DateTimeConverter()  DateTime startDate, @NullableDateTimeConverter()  DateTime? endDate,  FitnessGoalStatus status,  String? notes, @DateTimeConverter()  DateTime createdAt, @DateTimeConverter()  DateTime updatedAt,  RepeatType? repeatType,  int? repeatInterval,  int? repeatCount,  int? currentRepetition,  String? parentGoalId,  FitnessVisibility visibility)  $default,) {final _that = this;
switch (_that) {
case _SnFitnessGoal():
return $default(_that.id,_that.accountId,_that.goalType,_that.title,_that.description,_that.targetValue,_that.currentValue,_that.unit,_that.boundWorkoutType,_that.boundMetricType,_that.autoUpdateProgress,_that.startDate,_that.endDate,_that.status,_that.notes,_that.createdAt,_that.updatedAt,_that.repeatType,_that.repeatInterval,_that.repeatCount,_that.currentRepetition,_that.parentGoalId,_that.visibility);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String accountId,  FitnessGoalType goalType,  String title,  String? description,  double? targetValue,  double? currentValue,  String? unit,  int? boundWorkoutType,  int? boundMetricType,  bool autoUpdateProgress, @DateTimeConverter()  DateTime startDate, @NullableDateTimeConverter()  DateTime? endDate,  FitnessGoalStatus status,  String? notes, @DateTimeConverter()  DateTime createdAt, @DateTimeConverter()  DateTime updatedAt,  RepeatType? repeatType,  int? repeatInterval,  int? repeatCount,  int? currentRepetition,  String? parentGoalId,  FitnessVisibility visibility)?  $default,) {final _that = this;
switch (_that) {
case _SnFitnessGoal() when $default != null:
return $default(_that.id,_that.accountId,_that.goalType,_that.title,_that.description,_that.targetValue,_that.currentValue,_that.unit,_that.boundWorkoutType,_that.boundMetricType,_that.autoUpdateProgress,_that.startDate,_that.endDate,_that.status,_that.notes,_that.createdAt,_that.updatedAt,_that.repeatType,_that.repeatInterval,_that.repeatCount,_that.currentRepetition,_that.parentGoalId,_that.visibility);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnFitnessGoal implements SnFitnessGoal {
  const _SnFitnessGoal({required this.id, required this.accountId, required this.goalType, required this.title, this.description, this.targetValue, this.currentValue, this.unit, this.boundWorkoutType, this.boundMetricType, this.autoUpdateProgress = true, @DateTimeConverter() required this.startDate, @NullableDateTimeConverter() this.endDate, required this.status, this.notes, @DateTimeConverter() required this.createdAt, @DateTimeConverter() required this.updatedAt, this.repeatType, this.repeatInterval, this.repeatCount, this.currentRepetition, this.parentGoalId, this.visibility = FitnessVisibility.private});
  factory _SnFitnessGoal.fromJson(Map<String, dynamic> json) => _$SnFitnessGoalFromJson(json);

@override final  String id;
@override final  String accountId;
@override final  FitnessGoalType goalType;
@override final  String title;
@override final  String? description;
@override final  double? targetValue;
@override final  double? currentValue;
@override final  String? unit;
@override final  int? boundWorkoutType;
@override final  int? boundMetricType;
@override@JsonKey() final  bool autoUpdateProgress;
@override@DateTimeConverter() final  DateTime startDate;
@override@NullableDateTimeConverter() final  DateTime? endDate;
@override final  FitnessGoalStatus status;
@override final  String? notes;
@override@DateTimeConverter() final  DateTime createdAt;
@override@DateTimeConverter() final  DateTime updatedAt;
@override final  RepeatType? repeatType;
@override final  int? repeatInterval;
@override final  int? repeatCount;
@override final  int? currentRepetition;
@override final  String? parentGoalId;
@override@JsonKey() final  FitnessVisibility visibility;

/// Create a copy of SnFitnessGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnFitnessGoalCopyWith<_SnFitnessGoal> get copyWith => __$SnFitnessGoalCopyWithImpl<_SnFitnessGoal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnFitnessGoalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnFitnessGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.boundWorkoutType, boundWorkoutType) || other.boundWorkoutType == boundWorkoutType)&&(identical(other.boundMetricType, boundMetricType) || other.boundMetricType == boundMetricType)&&(identical(other.autoUpdateProgress, autoUpdateProgress) || other.autoUpdateProgress == autoUpdateProgress)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.repeatType, repeatType) || other.repeatType == repeatType)&&(identical(other.repeatInterval, repeatInterval) || other.repeatInterval == repeatInterval)&&(identical(other.repeatCount, repeatCount) || other.repeatCount == repeatCount)&&(identical(other.currentRepetition, currentRepetition) || other.currentRepetition == currentRepetition)&&(identical(other.parentGoalId, parentGoalId) || other.parentGoalId == parentGoalId)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,accountId,goalType,title,description,targetValue,currentValue,unit,boundWorkoutType,boundMetricType,autoUpdateProgress,startDate,endDate,status,notes,createdAt,updatedAt,repeatType,repeatInterval,repeatCount,currentRepetition,parentGoalId,visibility]);

@override
String toString() {
  return 'SnFitnessGoal(id: $id, accountId: $accountId, goalType: $goalType, title: $title, description: $description, targetValue: $targetValue, currentValue: $currentValue, unit: $unit, boundWorkoutType: $boundWorkoutType, boundMetricType: $boundMetricType, autoUpdateProgress: $autoUpdateProgress, startDate: $startDate, endDate: $endDate, status: $status, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, repeatType: $repeatType, repeatInterval: $repeatInterval, repeatCount: $repeatCount, currentRepetition: $currentRepetition, parentGoalId: $parentGoalId, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class _$SnFitnessGoalCopyWith<$Res> implements $SnFitnessGoalCopyWith<$Res> {
  factory _$SnFitnessGoalCopyWith(_SnFitnessGoal value, $Res Function(_SnFitnessGoal) _then) = __$SnFitnessGoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String accountId, FitnessGoalType goalType, String title, String? description, double? targetValue, double? currentValue, String? unit, int? boundWorkoutType, int? boundMetricType, bool autoUpdateProgress,@DateTimeConverter() DateTime startDate,@NullableDateTimeConverter() DateTime? endDate, FitnessGoalStatus status, String? notes,@DateTimeConverter() DateTime createdAt,@DateTimeConverter() DateTime updatedAt, RepeatType? repeatType, int? repeatInterval, int? repeatCount, int? currentRepetition, String? parentGoalId, FitnessVisibility visibility
});




}
/// @nodoc
class __$SnFitnessGoalCopyWithImpl<$Res>
    implements _$SnFitnessGoalCopyWith<$Res> {
  __$SnFitnessGoalCopyWithImpl(this._self, this._then);

  final _SnFitnessGoal _self;
  final $Res Function(_SnFitnessGoal) _then;

/// Create a copy of SnFitnessGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? accountId = null,Object? goalType = null,Object? title = null,Object? description = freezed,Object? targetValue = freezed,Object? currentValue = freezed,Object? unit = freezed,Object? boundWorkoutType = freezed,Object? boundMetricType = freezed,Object? autoUpdateProgress = null,Object? startDate = null,Object? endDate = freezed,Object? status = null,Object? notes = freezed,Object? createdAt = null,Object? updatedAt = null,Object? repeatType = freezed,Object? repeatInterval = freezed,Object? repeatCount = freezed,Object? currentRepetition = freezed,Object? parentGoalId = freezed,Object? visibility = null,}) {
  return _then(_SnFitnessGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as FitnessGoalType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,currentValue: freezed == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,boundWorkoutType: freezed == boundWorkoutType ? _self.boundWorkoutType : boundWorkoutType // ignore: cast_nullable_to_non_nullable
as int?,boundMetricType: freezed == boundMetricType ? _self.boundMetricType : boundMetricType // ignore: cast_nullable_to_non_nullable
as int?,autoUpdateProgress: null == autoUpdateProgress ? _self.autoUpdateProgress : autoUpdateProgress // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FitnessGoalStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,repeatType: freezed == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as RepeatType?,repeatInterval: freezed == repeatInterval ? _self.repeatInterval : repeatInterval // ignore: cast_nullable_to_non_nullable
as int?,repeatCount: freezed == repeatCount ? _self.repeatCount : repeatCount // ignore: cast_nullable_to_non_nullable
as int?,currentRepetition: freezed == currentRepetition ? _self.currentRepetition : currentRepetition // ignore: cast_nullable_to_non_nullable
as int?,parentGoalId: freezed == parentGoalId ? _self.parentGoalId : parentGoalId // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as FitnessVisibility,
  ));
}


}


/// @nodoc
mixin _$GoalStats {

 int get activeCount; int get completedCount;
/// Create a copy of GoalStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalStatsCopyWith<GoalStats> get copyWith => _$GoalStatsCopyWithImpl<GoalStats>(this as GoalStats, _$identity);

  /// Serializes this GoalStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalStats&&(identical(other.activeCount, activeCount) || other.activeCount == activeCount)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeCount,completedCount);

@override
String toString() {
  return 'GoalStats(activeCount: $activeCount, completedCount: $completedCount)';
}


}

/// @nodoc
abstract mixin class $GoalStatsCopyWith<$Res>  {
  factory $GoalStatsCopyWith(GoalStats value, $Res Function(GoalStats) _then) = _$GoalStatsCopyWithImpl;
@useResult
$Res call({
 int activeCount, int completedCount
});




}
/// @nodoc
class _$GoalStatsCopyWithImpl<$Res>
    implements $GoalStatsCopyWith<$Res> {
  _$GoalStatsCopyWithImpl(this._self, this._then);

  final GoalStats _self;
  final $Res Function(GoalStats) _then;

/// Create a copy of GoalStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeCount = null,Object? completedCount = null,}) {
  return _then(_self.copyWith(
activeCount: null == activeCount ? _self.activeCount : activeCount // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalStats].
extension GoalStatsPatterns on GoalStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalStats value)  $default,){
final _that = this;
switch (_that) {
case _GoalStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalStats value)?  $default,){
final _that = this;
switch (_that) {
case _GoalStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int activeCount,  int completedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalStats() when $default != null:
return $default(_that.activeCount,_that.completedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int activeCount,  int completedCount)  $default,) {final _that = this;
switch (_that) {
case _GoalStats():
return $default(_that.activeCount,_that.completedCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int activeCount,  int completedCount)?  $default,) {final _that = this;
switch (_that) {
case _GoalStats() when $default != null:
return $default(_that.activeCount,_that.completedCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoalStats implements GoalStats {
  const _GoalStats({required this.activeCount, required this.completedCount});
  factory _GoalStats.fromJson(Map<String, dynamic> json) => _$GoalStatsFromJson(json);

@override final  int activeCount;
@override final  int completedCount;

/// Create a copy of GoalStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalStatsCopyWith<_GoalStats> get copyWith => __$GoalStatsCopyWithImpl<_GoalStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalStats&&(identical(other.activeCount, activeCount) || other.activeCount == activeCount)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeCount,completedCount);

@override
String toString() {
  return 'GoalStats(activeCount: $activeCount, completedCount: $completedCount)';
}


}

/// @nodoc
abstract mixin class _$GoalStatsCopyWith<$Res> implements $GoalStatsCopyWith<$Res> {
  factory _$GoalStatsCopyWith(_GoalStats value, $Res Function(_GoalStats) _then) = __$GoalStatsCopyWithImpl;
@override @useResult
$Res call({
 int activeCount, int completedCount
});




}
/// @nodoc
class __$GoalStatsCopyWithImpl<$Res>
    implements _$GoalStatsCopyWith<$Res> {
  __$GoalStatsCopyWithImpl(this._self, this._then);

  final _GoalStats _self;
  final $Res Function(_GoalStats) _then;

/// Create a copy of GoalStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeCount = null,Object? completedCount = null,}) {
  return _then(_GoalStats(
activeCount: null == activeCount ? _self.activeCount : activeCount // ignore: cast_nullable_to_non_nullable
as int,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CreateGoalRequest {

 String get title; FitnessGoalType get goalType;@DateTimeConverter() DateTime get startDate; String? get description; double? get targetValue; String? get unit; int? get boundWorkoutType; int? get boundMetricType; bool get autoUpdateProgress;@NullableDateTimeConverter() DateTime? get endDate; String? get notes; RepeatType? get repeatType; int? get repeatInterval; int? get repeatCount; FitnessVisibility get visibility;
/// Create a copy of CreateGoalRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGoalRequestCopyWith<CreateGoalRequest> get copyWith => _$CreateGoalRequestCopyWithImpl<CreateGoalRequest>(this as CreateGoalRequest, _$identity);

  /// Serializes this CreateGoalRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGoalRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.boundWorkoutType, boundWorkoutType) || other.boundWorkoutType == boundWorkoutType)&&(identical(other.boundMetricType, boundMetricType) || other.boundMetricType == boundMetricType)&&(identical(other.autoUpdateProgress, autoUpdateProgress) || other.autoUpdateProgress == autoUpdateProgress)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.repeatType, repeatType) || other.repeatType == repeatType)&&(identical(other.repeatInterval, repeatInterval) || other.repeatInterval == repeatInterval)&&(identical(other.repeatCount, repeatCount) || other.repeatCount == repeatCount)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,goalType,startDate,description,targetValue,unit,boundWorkoutType,boundMetricType,autoUpdateProgress,endDate,notes,repeatType,repeatInterval,repeatCount,visibility);

@override
String toString() {
  return 'CreateGoalRequest(title: $title, goalType: $goalType, startDate: $startDate, description: $description, targetValue: $targetValue, unit: $unit, boundWorkoutType: $boundWorkoutType, boundMetricType: $boundMetricType, autoUpdateProgress: $autoUpdateProgress, endDate: $endDate, notes: $notes, repeatType: $repeatType, repeatInterval: $repeatInterval, repeatCount: $repeatCount, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class $CreateGoalRequestCopyWith<$Res>  {
  factory $CreateGoalRequestCopyWith(CreateGoalRequest value, $Res Function(CreateGoalRequest) _then) = _$CreateGoalRequestCopyWithImpl;
@useResult
$Res call({
 String title, FitnessGoalType goalType,@DateTimeConverter() DateTime startDate, String? description, double? targetValue, String? unit, int? boundWorkoutType, int? boundMetricType, bool autoUpdateProgress,@NullableDateTimeConverter() DateTime? endDate, String? notes, RepeatType? repeatType, int? repeatInterval, int? repeatCount, FitnessVisibility visibility
});




}
/// @nodoc
class _$CreateGoalRequestCopyWithImpl<$Res>
    implements $CreateGoalRequestCopyWith<$Res> {
  _$CreateGoalRequestCopyWithImpl(this._self, this._then);

  final CreateGoalRequest _self;
  final $Res Function(CreateGoalRequest) _then;

/// Create a copy of CreateGoalRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? goalType = null,Object? startDate = null,Object? description = freezed,Object? targetValue = freezed,Object? unit = freezed,Object? boundWorkoutType = freezed,Object? boundMetricType = freezed,Object? autoUpdateProgress = null,Object? endDate = freezed,Object? notes = freezed,Object? repeatType = freezed,Object? repeatInterval = freezed,Object? repeatCount = freezed,Object? visibility = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as FitnessGoalType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,boundWorkoutType: freezed == boundWorkoutType ? _self.boundWorkoutType : boundWorkoutType // ignore: cast_nullable_to_non_nullable
as int?,boundMetricType: freezed == boundMetricType ? _self.boundMetricType : boundMetricType // ignore: cast_nullable_to_non_nullable
as int?,autoUpdateProgress: null == autoUpdateProgress ? _self.autoUpdateProgress : autoUpdateProgress // ignore: cast_nullable_to_non_nullable
as bool,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,repeatType: freezed == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as RepeatType?,repeatInterval: freezed == repeatInterval ? _self.repeatInterval : repeatInterval // ignore: cast_nullable_to_non_nullable
as int?,repeatCount: freezed == repeatCount ? _self.repeatCount : repeatCount // ignore: cast_nullable_to_non_nullable
as int?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as FitnessVisibility,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGoalRequest].
extension CreateGoalRequestPatterns on CreateGoalRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGoalRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGoalRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGoalRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateGoalRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGoalRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGoalRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  FitnessGoalType goalType, @DateTimeConverter()  DateTime startDate,  String? description,  double? targetValue,  String? unit,  int? boundWorkoutType,  int? boundMetricType,  bool autoUpdateProgress, @NullableDateTimeConverter()  DateTime? endDate,  String? notes,  RepeatType? repeatType,  int? repeatInterval,  int? repeatCount,  FitnessVisibility visibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGoalRequest() when $default != null:
return $default(_that.title,_that.goalType,_that.startDate,_that.description,_that.targetValue,_that.unit,_that.boundWorkoutType,_that.boundMetricType,_that.autoUpdateProgress,_that.endDate,_that.notes,_that.repeatType,_that.repeatInterval,_that.repeatCount,_that.visibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  FitnessGoalType goalType, @DateTimeConverter()  DateTime startDate,  String? description,  double? targetValue,  String? unit,  int? boundWorkoutType,  int? boundMetricType,  bool autoUpdateProgress, @NullableDateTimeConverter()  DateTime? endDate,  String? notes,  RepeatType? repeatType,  int? repeatInterval,  int? repeatCount,  FitnessVisibility visibility)  $default,) {final _that = this;
switch (_that) {
case _CreateGoalRequest():
return $default(_that.title,_that.goalType,_that.startDate,_that.description,_that.targetValue,_that.unit,_that.boundWorkoutType,_that.boundMetricType,_that.autoUpdateProgress,_that.endDate,_that.notes,_that.repeatType,_that.repeatInterval,_that.repeatCount,_that.visibility);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  FitnessGoalType goalType, @DateTimeConverter()  DateTime startDate,  String? description,  double? targetValue,  String? unit,  int? boundWorkoutType,  int? boundMetricType,  bool autoUpdateProgress, @NullableDateTimeConverter()  DateTime? endDate,  String? notes,  RepeatType? repeatType,  int? repeatInterval,  int? repeatCount,  FitnessVisibility visibility)?  $default,) {final _that = this;
switch (_that) {
case _CreateGoalRequest() when $default != null:
return $default(_that.title,_that.goalType,_that.startDate,_that.description,_that.targetValue,_that.unit,_that.boundWorkoutType,_that.boundMetricType,_that.autoUpdateProgress,_that.endDate,_that.notes,_that.repeatType,_that.repeatInterval,_that.repeatCount,_that.visibility);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateGoalRequest implements CreateGoalRequest {
  const _CreateGoalRequest({required this.title, required this.goalType, @DateTimeConverter() required this.startDate, this.description, this.targetValue, this.unit, this.boundWorkoutType, this.boundMetricType, this.autoUpdateProgress = true, @NullableDateTimeConverter() this.endDate, this.notes, this.repeatType, this.repeatInterval, this.repeatCount, this.visibility = FitnessVisibility.private});
  factory _CreateGoalRequest.fromJson(Map<String, dynamic> json) => _$CreateGoalRequestFromJson(json);

@override final  String title;
@override final  FitnessGoalType goalType;
@override@DateTimeConverter() final  DateTime startDate;
@override final  String? description;
@override final  double? targetValue;
@override final  String? unit;
@override final  int? boundWorkoutType;
@override final  int? boundMetricType;
@override@JsonKey() final  bool autoUpdateProgress;
@override@NullableDateTimeConverter() final  DateTime? endDate;
@override final  String? notes;
@override final  RepeatType? repeatType;
@override final  int? repeatInterval;
@override final  int? repeatCount;
@override@JsonKey() final  FitnessVisibility visibility;

/// Create a copy of CreateGoalRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGoalRequestCopyWith<_CreateGoalRequest> get copyWith => __$CreateGoalRequestCopyWithImpl<_CreateGoalRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateGoalRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGoalRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.boundWorkoutType, boundWorkoutType) || other.boundWorkoutType == boundWorkoutType)&&(identical(other.boundMetricType, boundMetricType) || other.boundMetricType == boundMetricType)&&(identical(other.autoUpdateProgress, autoUpdateProgress) || other.autoUpdateProgress == autoUpdateProgress)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.repeatType, repeatType) || other.repeatType == repeatType)&&(identical(other.repeatInterval, repeatInterval) || other.repeatInterval == repeatInterval)&&(identical(other.repeatCount, repeatCount) || other.repeatCount == repeatCount)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,goalType,startDate,description,targetValue,unit,boundWorkoutType,boundMetricType,autoUpdateProgress,endDate,notes,repeatType,repeatInterval,repeatCount,visibility);

@override
String toString() {
  return 'CreateGoalRequest(title: $title, goalType: $goalType, startDate: $startDate, description: $description, targetValue: $targetValue, unit: $unit, boundWorkoutType: $boundWorkoutType, boundMetricType: $boundMetricType, autoUpdateProgress: $autoUpdateProgress, endDate: $endDate, notes: $notes, repeatType: $repeatType, repeatInterval: $repeatInterval, repeatCount: $repeatCount, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class _$CreateGoalRequestCopyWith<$Res> implements $CreateGoalRequestCopyWith<$Res> {
  factory _$CreateGoalRequestCopyWith(_CreateGoalRequest value, $Res Function(_CreateGoalRequest) _then) = __$CreateGoalRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, FitnessGoalType goalType,@DateTimeConverter() DateTime startDate, String? description, double? targetValue, String? unit, int? boundWorkoutType, int? boundMetricType, bool autoUpdateProgress,@NullableDateTimeConverter() DateTime? endDate, String? notes, RepeatType? repeatType, int? repeatInterval, int? repeatCount, FitnessVisibility visibility
});




}
/// @nodoc
class __$CreateGoalRequestCopyWithImpl<$Res>
    implements _$CreateGoalRequestCopyWith<$Res> {
  __$CreateGoalRequestCopyWithImpl(this._self, this._then);

  final _CreateGoalRequest _self;
  final $Res Function(_CreateGoalRequest) _then;

/// Create a copy of CreateGoalRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? goalType = null,Object? startDate = null,Object? description = freezed,Object? targetValue = freezed,Object? unit = freezed,Object? boundWorkoutType = freezed,Object? boundMetricType = freezed,Object? autoUpdateProgress = null,Object? endDate = freezed,Object? notes = freezed,Object? repeatType = freezed,Object? repeatInterval = freezed,Object? repeatCount = freezed,Object? visibility = null,}) {
  return _then(_CreateGoalRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as FitnessGoalType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,boundWorkoutType: freezed == boundWorkoutType ? _self.boundWorkoutType : boundWorkoutType // ignore: cast_nullable_to_non_nullable
as int?,boundMetricType: freezed == boundMetricType ? _self.boundMetricType : boundMetricType // ignore: cast_nullable_to_non_nullable
as int?,autoUpdateProgress: null == autoUpdateProgress ? _self.autoUpdateProgress : autoUpdateProgress // ignore: cast_nullable_to_non_nullable
as bool,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,repeatType: freezed == repeatType ? _self.repeatType : repeatType // ignore: cast_nullable_to_non_nullable
as RepeatType?,repeatInterval: freezed == repeatInterval ? _self.repeatInterval : repeatInterval // ignore: cast_nullable_to_non_nullable
as int?,repeatCount: freezed == repeatCount ? _self.repeatCount : repeatCount // ignore: cast_nullable_to_non_nullable
as int?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as FitnessVisibility,
  ));
}


}


/// @nodoc
mixin _$UpdateGoalRequest {

 String get title; FitnessGoalType get goalType;@DateTimeConverter() DateTime get startDate; FitnessGoalStatus get status; String? get description; double? get targetValue; double? get currentValue; String? get unit; int? get boundWorkoutType; int? get boundMetricType; bool? get autoUpdateProgress;@NullableDateTimeConverter() DateTime? get endDate; String? get notes; FitnessVisibility? get visibility;
/// Create a copy of UpdateGoalRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateGoalRequestCopyWith<UpdateGoalRequest> get copyWith => _$UpdateGoalRequestCopyWithImpl<UpdateGoalRequest>(this as UpdateGoalRequest, _$identity);

  /// Serializes this UpdateGoalRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateGoalRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.boundWorkoutType, boundWorkoutType) || other.boundWorkoutType == boundWorkoutType)&&(identical(other.boundMetricType, boundMetricType) || other.boundMetricType == boundMetricType)&&(identical(other.autoUpdateProgress, autoUpdateProgress) || other.autoUpdateProgress == autoUpdateProgress)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,goalType,startDate,status,description,targetValue,currentValue,unit,boundWorkoutType,boundMetricType,autoUpdateProgress,endDate,notes,visibility);

@override
String toString() {
  return 'UpdateGoalRequest(title: $title, goalType: $goalType, startDate: $startDate, status: $status, description: $description, targetValue: $targetValue, currentValue: $currentValue, unit: $unit, boundWorkoutType: $boundWorkoutType, boundMetricType: $boundMetricType, autoUpdateProgress: $autoUpdateProgress, endDate: $endDate, notes: $notes, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class $UpdateGoalRequestCopyWith<$Res>  {
  factory $UpdateGoalRequestCopyWith(UpdateGoalRequest value, $Res Function(UpdateGoalRequest) _then) = _$UpdateGoalRequestCopyWithImpl;
@useResult
$Res call({
 String title, FitnessGoalType goalType,@DateTimeConverter() DateTime startDate, FitnessGoalStatus status, String? description, double? targetValue, double? currentValue, String? unit, int? boundWorkoutType, int? boundMetricType, bool? autoUpdateProgress,@NullableDateTimeConverter() DateTime? endDate, String? notes, FitnessVisibility? visibility
});




}
/// @nodoc
class _$UpdateGoalRequestCopyWithImpl<$Res>
    implements $UpdateGoalRequestCopyWith<$Res> {
  _$UpdateGoalRequestCopyWithImpl(this._self, this._then);

  final UpdateGoalRequest _self;
  final $Res Function(UpdateGoalRequest) _then;

/// Create a copy of UpdateGoalRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? goalType = null,Object? startDate = null,Object? status = null,Object? description = freezed,Object? targetValue = freezed,Object? currentValue = freezed,Object? unit = freezed,Object? boundWorkoutType = freezed,Object? boundMetricType = freezed,Object? autoUpdateProgress = freezed,Object? endDate = freezed,Object? notes = freezed,Object? visibility = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as FitnessGoalType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FitnessGoalStatus,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,currentValue: freezed == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,boundWorkoutType: freezed == boundWorkoutType ? _self.boundWorkoutType : boundWorkoutType // ignore: cast_nullable_to_non_nullable
as int?,boundMetricType: freezed == boundMetricType ? _self.boundMetricType : boundMetricType // ignore: cast_nullable_to_non_nullable
as int?,autoUpdateProgress: freezed == autoUpdateProgress ? _self.autoUpdateProgress : autoUpdateProgress // ignore: cast_nullable_to_non_nullable
as bool?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as FitnessVisibility?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateGoalRequest].
extension UpdateGoalRequestPatterns on UpdateGoalRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateGoalRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateGoalRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateGoalRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateGoalRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateGoalRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateGoalRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  FitnessGoalType goalType, @DateTimeConverter()  DateTime startDate,  FitnessGoalStatus status,  String? description,  double? targetValue,  double? currentValue,  String? unit,  int? boundWorkoutType,  int? boundMetricType,  bool? autoUpdateProgress, @NullableDateTimeConverter()  DateTime? endDate,  String? notes,  FitnessVisibility? visibility)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateGoalRequest() when $default != null:
return $default(_that.title,_that.goalType,_that.startDate,_that.status,_that.description,_that.targetValue,_that.currentValue,_that.unit,_that.boundWorkoutType,_that.boundMetricType,_that.autoUpdateProgress,_that.endDate,_that.notes,_that.visibility);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  FitnessGoalType goalType, @DateTimeConverter()  DateTime startDate,  FitnessGoalStatus status,  String? description,  double? targetValue,  double? currentValue,  String? unit,  int? boundWorkoutType,  int? boundMetricType,  bool? autoUpdateProgress, @NullableDateTimeConverter()  DateTime? endDate,  String? notes,  FitnessVisibility? visibility)  $default,) {final _that = this;
switch (_that) {
case _UpdateGoalRequest():
return $default(_that.title,_that.goalType,_that.startDate,_that.status,_that.description,_that.targetValue,_that.currentValue,_that.unit,_that.boundWorkoutType,_that.boundMetricType,_that.autoUpdateProgress,_that.endDate,_that.notes,_that.visibility);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  FitnessGoalType goalType, @DateTimeConverter()  DateTime startDate,  FitnessGoalStatus status,  String? description,  double? targetValue,  double? currentValue,  String? unit,  int? boundWorkoutType,  int? boundMetricType,  bool? autoUpdateProgress, @NullableDateTimeConverter()  DateTime? endDate,  String? notes,  FitnessVisibility? visibility)?  $default,) {final _that = this;
switch (_that) {
case _UpdateGoalRequest() when $default != null:
return $default(_that.title,_that.goalType,_that.startDate,_that.status,_that.description,_that.targetValue,_that.currentValue,_that.unit,_that.boundWorkoutType,_that.boundMetricType,_that.autoUpdateProgress,_that.endDate,_that.notes,_that.visibility);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateGoalRequest implements UpdateGoalRequest {
  const _UpdateGoalRequest({required this.title, required this.goalType, @DateTimeConverter() required this.startDate, required this.status, this.description, this.targetValue, this.currentValue, this.unit, this.boundWorkoutType, this.boundMetricType, this.autoUpdateProgress, @NullableDateTimeConverter() this.endDate, this.notes, this.visibility});
  factory _UpdateGoalRequest.fromJson(Map<String, dynamic> json) => _$UpdateGoalRequestFromJson(json);

@override final  String title;
@override final  FitnessGoalType goalType;
@override@DateTimeConverter() final  DateTime startDate;
@override final  FitnessGoalStatus status;
@override final  String? description;
@override final  double? targetValue;
@override final  double? currentValue;
@override final  String? unit;
@override final  int? boundWorkoutType;
@override final  int? boundMetricType;
@override final  bool? autoUpdateProgress;
@override@NullableDateTimeConverter() final  DateTime? endDate;
@override final  String? notes;
@override final  FitnessVisibility? visibility;

/// Create a copy of UpdateGoalRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateGoalRequestCopyWith<_UpdateGoalRequest> get copyWith => __$UpdateGoalRequestCopyWithImpl<_UpdateGoalRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateGoalRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateGoalRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.goalType, goalType) || other.goalType == goalType)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.boundWorkoutType, boundWorkoutType) || other.boundWorkoutType == boundWorkoutType)&&(identical(other.boundMetricType, boundMetricType) || other.boundMetricType == boundMetricType)&&(identical(other.autoUpdateProgress, autoUpdateProgress) || other.autoUpdateProgress == autoUpdateProgress)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,goalType,startDate,status,description,targetValue,currentValue,unit,boundWorkoutType,boundMetricType,autoUpdateProgress,endDate,notes,visibility);

@override
String toString() {
  return 'UpdateGoalRequest(title: $title, goalType: $goalType, startDate: $startDate, status: $status, description: $description, targetValue: $targetValue, currentValue: $currentValue, unit: $unit, boundWorkoutType: $boundWorkoutType, boundMetricType: $boundMetricType, autoUpdateProgress: $autoUpdateProgress, endDate: $endDate, notes: $notes, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class _$UpdateGoalRequestCopyWith<$Res> implements $UpdateGoalRequestCopyWith<$Res> {
  factory _$UpdateGoalRequestCopyWith(_UpdateGoalRequest value, $Res Function(_UpdateGoalRequest) _then) = __$UpdateGoalRequestCopyWithImpl;
@override @useResult
$Res call({
 String title, FitnessGoalType goalType,@DateTimeConverter() DateTime startDate, FitnessGoalStatus status, String? description, double? targetValue, double? currentValue, String? unit, int? boundWorkoutType, int? boundMetricType, bool? autoUpdateProgress,@NullableDateTimeConverter() DateTime? endDate, String? notes, FitnessVisibility? visibility
});




}
/// @nodoc
class __$UpdateGoalRequestCopyWithImpl<$Res>
    implements _$UpdateGoalRequestCopyWith<$Res> {
  __$UpdateGoalRequestCopyWithImpl(this._self, this._then);

  final _UpdateGoalRequest _self;
  final $Res Function(_UpdateGoalRequest) _then;

/// Create a copy of UpdateGoalRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? goalType = null,Object? startDate = null,Object? status = null,Object? description = freezed,Object? targetValue = freezed,Object? currentValue = freezed,Object? unit = freezed,Object? boundWorkoutType = freezed,Object? boundMetricType = freezed,Object? autoUpdateProgress = freezed,Object? endDate = freezed,Object? notes = freezed,Object? visibility = freezed,}) {
  return _then(_UpdateGoalRequest(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,goalType: null == goalType ? _self.goalType : goalType // ignore: cast_nullable_to_non_nullable
as FitnessGoalType,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FitnessGoalStatus,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,currentValue: freezed == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double?,unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String?,boundWorkoutType: freezed == boundWorkoutType ? _self.boundWorkoutType : boundWorkoutType // ignore: cast_nullable_to_non_nullable
as int?,boundMetricType: freezed == boundMetricType ? _self.boundMetricType : boundMetricType // ignore: cast_nullable_to_non_nullable
as int?,autoUpdateProgress: freezed == autoUpdateProgress ? _self.autoUpdateProgress : autoUpdateProgress // ignore: cast_nullable_to_non_nullable
as bool?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as FitnessVisibility?,
  ));
}


}


/// @nodoc
mixin _$UpdateProgressRequest {

 double get currentValue;
/// Create a copy of UpdateProgressRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateProgressRequestCopyWith<UpdateProgressRequest> get copyWith => _$UpdateProgressRequestCopyWithImpl<UpdateProgressRequest>(this as UpdateProgressRequest, _$identity);

  /// Serializes this UpdateProgressRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateProgressRequest&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentValue);

@override
String toString() {
  return 'UpdateProgressRequest(currentValue: $currentValue)';
}


}

/// @nodoc
abstract mixin class $UpdateProgressRequestCopyWith<$Res>  {
  factory $UpdateProgressRequestCopyWith(UpdateProgressRequest value, $Res Function(UpdateProgressRequest) _then) = _$UpdateProgressRequestCopyWithImpl;
@useResult
$Res call({
 double currentValue
});




}
/// @nodoc
class _$UpdateProgressRequestCopyWithImpl<$Res>
    implements $UpdateProgressRequestCopyWith<$Res> {
  _$UpdateProgressRequestCopyWithImpl(this._self, this._then);

  final UpdateProgressRequest _self;
  final $Res Function(UpdateProgressRequest) _then;

/// Create a copy of UpdateProgressRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentValue = null,}) {
  return _then(_self.copyWith(
currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateProgressRequest].
extension UpdateProgressRequestPatterns on UpdateProgressRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateProgressRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateProgressRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateProgressRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateProgressRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateProgressRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateProgressRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double currentValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateProgressRequest() when $default != null:
return $default(_that.currentValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double currentValue)  $default,) {final _that = this;
switch (_that) {
case _UpdateProgressRequest():
return $default(_that.currentValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double currentValue)?  $default,) {final _that = this;
switch (_that) {
case _UpdateProgressRequest() when $default != null:
return $default(_that.currentValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateProgressRequest implements UpdateProgressRequest {
  const _UpdateProgressRequest({required this.currentValue});
  factory _UpdateProgressRequest.fromJson(Map<String, dynamic> json) => _$UpdateProgressRequestFromJson(json);

@override final  double currentValue;

/// Create a copy of UpdateProgressRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateProgressRequestCopyWith<_UpdateProgressRequest> get copyWith => __$UpdateProgressRequestCopyWithImpl<_UpdateProgressRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateProgressRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateProgressRequest&&(identical(other.currentValue, currentValue) || other.currentValue == currentValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentValue);

@override
String toString() {
  return 'UpdateProgressRequest(currentValue: $currentValue)';
}


}

/// @nodoc
abstract mixin class _$UpdateProgressRequestCopyWith<$Res> implements $UpdateProgressRequestCopyWith<$Res> {
  factory _$UpdateProgressRequestCopyWith(_UpdateProgressRequest value, $Res Function(_UpdateProgressRequest) _then) = __$UpdateProgressRequestCopyWithImpl;
@override @useResult
$Res call({
 double currentValue
});




}
/// @nodoc
class __$UpdateProgressRequestCopyWithImpl<$Res>
    implements _$UpdateProgressRequestCopyWith<$Res> {
  __$UpdateProgressRequestCopyWithImpl(this._self, this._then);

  final _UpdateProgressRequest _self;
  final $Res Function(_UpdateProgressRequest) _then;

/// Create a copy of UpdateProgressRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentValue = null,}) {
  return _then(_UpdateProgressRequest(
currentValue: null == currentValue ? _self.currentValue : currentValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$UpdateGoalStatusRequest {

 FitnessGoalStatus get status;
/// Create a copy of UpdateGoalStatusRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateGoalStatusRequestCopyWith<UpdateGoalStatusRequest> get copyWith => _$UpdateGoalStatusRequestCopyWithImpl<UpdateGoalStatusRequest>(this as UpdateGoalStatusRequest, _$identity);

  /// Serializes this UpdateGoalStatusRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateGoalStatusRequest&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'UpdateGoalStatusRequest(status: $status)';
}


}

/// @nodoc
abstract mixin class $UpdateGoalStatusRequestCopyWith<$Res>  {
  factory $UpdateGoalStatusRequestCopyWith(UpdateGoalStatusRequest value, $Res Function(UpdateGoalStatusRequest) _then) = _$UpdateGoalStatusRequestCopyWithImpl;
@useResult
$Res call({
 FitnessGoalStatus status
});




}
/// @nodoc
class _$UpdateGoalStatusRequestCopyWithImpl<$Res>
    implements $UpdateGoalStatusRequestCopyWith<$Res> {
  _$UpdateGoalStatusRequestCopyWithImpl(this._self, this._then);

  final UpdateGoalStatusRequest _self;
  final $Res Function(UpdateGoalStatusRequest) _then;

/// Create a copy of UpdateGoalStatusRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FitnessGoalStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateGoalStatusRequest].
extension UpdateGoalStatusRequestPatterns on UpdateGoalStatusRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateGoalStatusRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateGoalStatusRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateGoalStatusRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateGoalStatusRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateGoalStatusRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateGoalStatusRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FitnessGoalStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateGoalStatusRequest() when $default != null:
return $default(_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FitnessGoalStatus status)  $default,) {final _that = this;
switch (_that) {
case _UpdateGoalStatusRequest():
return $default(_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FitnessGoalStatus status)?  $default,) {final _that = this;
switch (_that) {
case _UpdateGoalStatusRequest() when $default != null:
return $default(_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateGoalStatusRequest implements UpdateGoalStatusRequest {
  const _UpdateGoalStatusRequest({required this.status});
  factory _UpdateGoalStatusRequest.fromJson(Map<String, dynamic> json) => _$UpdateGoalStatusRequestFromJson(json);

@override final  FitnessGoalStatus status;

/// Create a copy of UpdateGoalStatusRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateGoalStatusRequestCopyWith<_UpdateGoalStatusRequest> get copyWith => __$UpdateGoalStatusRequestCopyWithImpl<_UpdateGoalStatusRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateGoalStatusRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateGoalStatusRequest&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'UpdateGoalStatusRequest(status: $status)';
}


}

/// @nodoc
abstract mixin class _$UpdateGoalStatusRequestCopyWith<$Res> implements $UpdateGoalStatusRequestCopyWith<$Res> {
  factory _$UpdateGoalStatusRequestCopyWith(_UpdateGoalStatusRequest value, $Res Function(_UpdateGoalStatusRequest) _then) = __$UpdateGoalStatusRequestCopyWithImpl;
@override @useResult
$Res call({
 FitnessGoalStatus status
});




}
/// @nodoc
class __$UpdateGoalStatusRequestCopyWithImpl<$Res>
    implements _$UpdateGoalStatusRequestCopyWith<$Res> {
  __$UpdateGoalStatusRequestCopyWithImpl(this._self, this._then);

  final _UpdateGoalStatusRequest _self;
  final $Res Function(_UpdateGoalStatusRequest) _then;

/// Create a copy of UpdateGoalStatusRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(_UpdateGoalStatusRequest(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FitnessGoalStatus,
  ));
}


}

// dart format on
