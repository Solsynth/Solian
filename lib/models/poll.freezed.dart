// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPollWithStats {

 Map<String, dynamic>? get userAnswer; Map<String, dynamic> get stats; String get id; List<SnPollQuestion> get questions; String? get title; String? get description; DateTime? get endedAt; String get publisherId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPollWithStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPollWithStatsCopyWith<SnPollWithStats> get copyWith => _$SnPollWithStatsCopyWithImpl<SnPollWithStats>(this as SnPollWithStats, _$identity);

  /// Serializes this SnPollWithStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPollWithStats&&const DeepCollectionEquality().equals(other.userAnswer, userAnswer)&&const DeepCollectionEquality().equals(other.stats, stats)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.questions, questions)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(userAnswer),const DeepCollectionEquality().hash(stats),id,const DeepCollectionEquality().hash(questions),title,description,endedAt,publisherId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPollWithStats(userAnswer: $userAnswer, stats: $stats, id: $id, questions: $questions, title: $title, description: $description, endedAt: $endedAt, publisherId: $publisherId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPollWithStatsCopyWith<$Res>  {
  factory $SnPollWithStatsCopyWith(SnPollWithStats value, $Res Function(SnPollWithStats) _then) = _$SnPollWithStatsCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic>? userAnswer, Map<String, dynamic> stats, String id, List<SnPollQuestion> questions, String? title, String? description, DateTime? endedAt, String publisherId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnPollWithStatsCopyWithImpl<$Res>
    implements $SnPollWithStatsCopyWith<$Res> {
  _$SnPollWithStatsCopyWithImpl(this._self, this._then);

  final SnPollWithStats _self;
  final $Res Function(SnPollWithStats) _then;

/// Create a copy of SnPollWithStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userAnswer = freezed,Object? stats = null,Object? id = null,Object? questions = null,Object? title = freezed,Object? description = freezed,Object? endedAt = freezed,Object? publisherId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
userAnswer: freezed == userAnswer ? _self.userAnswer : userAnswer // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<SnPollQuestion>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPollWithStats].
extension SnPollWithStatsPatterns on SnPollWithStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPollWithStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPollWithStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPollWithStats value)  $default,){
final _that = this;
switch (_that) {
case _SnPollWithStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPollWithStats value)?  $default,){
final _that = this;
switch (_that) {
case _SnPollWithStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic>? userAnswer,  Map<String, dynamic> stats,  String id,  List<SnPollQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPollWithStats() when $default != null:
return $default(_that.userAnswer,_that.stats,_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic>? userAnswer,  Map<String, dynamic> stats,  String id,  List<SnPollQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPollWithStats():
return $default(_that.userAnswer,_that.stats,_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic>? userAnswer,  Map<String, dynamic> stats,  String id,  List<SnPollQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPollWithStats() when $default != null:
return $default(_that.userAnswer,_that.stats,_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPollWithStats implements SnPollWithStats {
  const _SnPollWithStats({required final  Map<String, dynamic>? userAnswer, required final  Map<String, dynamic> stats, required this.id, required final  List<SnPollQuestion> questions, this.title, this.description, this.endedAt, required this.publisherId, required this.createdAt, required this.updatedAt, this.deletedAt}): _userAnswer = userAnswer,_stats = stats,_questions = questions;
  factory _SnPollWithStats.fromJson(Map<String, dynamic> json) => _$SnPollWithStatsFromJson(json);

 final  Map<String, dynamic>? _userAnswer;
@override Map<String, dynamic>? get userAnswer {
  final value = _userAnswer;
  if (value == null) return null;
  if (_userAnswer is EqualUnmodifiableMapView) return _userAnswer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic> _stats;
@override Map<String, dynamic> get stats {
  if (_stats is EqualUnmodifiableMapView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stats);
}

@override final  String id;
 final  List<SnPollQuestion> _questions;
@override List<SnPollQuestion> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override final  String? title;
@override final  String? description;
@override final  DateTime? endedAt;
@override final  String publisherId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnPollWithStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPollWithStatsCopyWith<_SnPollWithStats> get copyWith => __$SnPollWithStatsCopyWithImpl<_SnPollWithStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPollWithStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPollWithStats&&const DeepCollectionEquality().equals(other._userAnswer, _userAnswer)&&const DeepCollectionEquality().equals(other._stats, _stats)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_userAnswer),const DeepCollectionEquality().hash(_stats),id,const DeepCollectionEquality().hash(_questions),title,description,endedAt,publisherId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPollWithStats(userAnswer: $userAnswer, stats: $stats, id: $id, questions: $questions, title: $title, description: $description, endedAt: $endedAt, publisherId: $publisherId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPollWithStatsCopyWith<$Res> implements $SnPollWithStatsCopyWith<$Res> {
  factory _$SnPollWithStatsCopyWith(_SnPollWithStats value, $Res Function(_SnPollWithStats) _then) = __$SnPollWithStatsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic>? userAnswer, Map<String, dynamic> stats, String id, List<SnPollQuestion> questions, String? title, String? description, DateTime? endedAt, String publisherId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnPollWithStatsCopyWithImpl<$Res>
    implements _$SnPollWithStatsCopyWith<$Res> {
  __$SnPollWithStatsCopyWithImpl(this._self, this._then);

  final _SnPollWithStats _self;
  final $Res Function(_SnPollWithStats) _then;

/// Create a copy of SnPollWithStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userAnswer = freezed,Object? stats = null,Object? id = null,Object? questions = null,Object? title = freezed,Object? description = freezed,Object? endedAt = freezed,Object? publisherId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPollWithStats(
userAnswer: freezed == userAnswer ? _self._userAnswer : userAnswer // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,stats: null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<SnPollQuestion>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SnPoll {

 String get id; List<SnPollQuestion> get questions; String? get title; String? get description; DateTime? get endedAt; String get publisherId; SnPublisher? get publisher;// ModelBase fields
 DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnPoll
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPollCopyWith<SnPoll> get copyWith => _$SnPollCopyWithImpl<SnPoll>(this as SnPoll, _$identity);

  /// Serializes this SnPoll to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPoll&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.questions, questions)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(questions),title,description,endedAt,publisherId,publisher,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPoll(id: $id, questions: $questions, title: $title, description: $description, endedAt: $endedAt, publisherId: $publisherId, publisher: $publisher, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnPollCopyWith<$Res>  {
  factory $SnPollCopyWith(SnPoll value, $Res Function(SnPoll) _then) = _$SnPollCopyWithImpl;
@useResult
$Res call({
 String id, List<SnPollQuestion> questions, String? title, String? description, DateTime? endedAt, String publisherId, SnPublisher? publisher, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class _$SnPollCopyWithImpl<$Res>
    implements $SnPollCopyWith<$Res> {
  _$SnPollCopyWithImpl(this._self, this._then);

  final SnPoll _self;
  final $Res Function(SnPoll) _then;

/// Create a copy of SnPoll
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? questions = null,Object? title = freezed,Object? description = freezed,Object? endedAt = freezed,Object? publisherId = null,Object? publisher = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<SnPollQuestion>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnPoll
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPoll].
extension SnPollPatterns on SnPoll {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPoll value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPoll() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPoll value)  $default,){
final _that = this;
switch (_that) {
case _SnPoll():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPoll value)?  $default,){
final _that = this;
switch (_that) {
case _SnPoll() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<SnPollQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  SnPublisher? publisher,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPoll() when $default != null:
return $default(_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.publisher,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<SnPollQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  SnPublisher? publisher,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnPoll():
return $default(_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.publisher,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<SnPollQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  SnPublisher? publisher,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnPoll() when $default != null:
return $default(_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.publisher,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPoll implements SnPoll {
  const _SnPoll({required this.id, required final  List<SnPollQuestion> questions, this.title, this.description, this.endedAt, required this.publisherId, this.publisher, required this.createdAt, required this.updatedAt, this.deletedAt}): _questions = questions;
  factory _SnPoll.fromJson(Map<String, dynamic> json) => _$SnPollFromJson(json);

@override final  String id;
 final  List<SnPollQuestion> _questions;
@override List<SnPollQuestion> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override final  String? title;
@override final  String? description;
@override final  DateTime? endedAt;
@override final  String publisherId;
@override final  SnPublisher? publisher;
// ModelBase fields
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnPoll
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPollCopyWith<_SnPoll> get copyWith => __$SnPollCopyWithImpl<_SnPoll>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPollToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPoll&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_questions),title,description,endedAt,publisherId,publisher,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnPoll(id: $id, questions: $questions, title: $title, description: $description, endedAt: $endedAt, publisherId: $publisherId, publisher: $publisher, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnPollCopyWith<$Res> implements $SnPollCopyWith<$Res> {
  factory _$SnPollCopyWith(_SnPoll value, $Res Function(_SnPoll) _then) = __$SnPollCopyWithImpl;
@override @useResult
$Res call({
 String id, List<SnPollQuestion> questions, String? title, String? description, DateTime? endedAt, String publisherId, SnPublisher? publisher, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class __$SnPollCopyWithImpl<$Res>
    implements _$SnPollCopyWith<$Res> {
  __$SnPollCopyWithImpl(this._self, this._then);

  final _SnPoll _self;
  final $Res Function(_SnPoll) _then;

/// Create a copy of SnPoll
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? questions = null,Object? title = freezed,Object? description = freezed,Object? endedAt = freezed,Object? publisherId = null,Object? publisher = freezed,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnPoll(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<SnPollQuestion>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnPoll
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get publisher {
    if (_self.publisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.publisher!, (value) {
    return _then(_self.copyWith(publisher: value));
  });
}
}


/// @nodoc
mixin _$SnPollQuestion {

 String get id; SnPollQuestionType get type; List<SnPollOption>? get options; String get title; String? get description; int get order; bool get isRequired;
/// Create a copy of SnPollQuestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPollQuestionCopyWith<SnPollQuestion> get copyWith => _$SnPollQuestionCopyWithImpl<SnPollQuestion>(this as SnPollQuestion, _$identity);

  /// Serializes this SnPollQuestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPollQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(options),title,description,order,isRequired);

@override
String toString() {
  return 'SnPollQuestion(id: $id, type: $type, options: $options, title: $title, description: $description, order: $order, isRequired: $isRequired)';
}


}

/// @nodoc
abstract mixin class $SnPollQuestionCopyWith<$Res>  {
  factory $SnPollQuestionCopyWith(SnPollQuestion value, $Res Function(SnPollQuestion) _then) = _$SnPollQuestionCopyWithImpl;
@useResult
$Res call({
 String id, SnPollQuestionType type, List<SnPollOption>? options, String title, String? description, int order, bool isRequired
});




}
/// @nodoc
class _$SnPollQuestionCopyWithImpl<$Res>
    implements $SnPollQuestionCopyWith<$Res> {
  _$SnPollQuestionCopyWithImpl(this._self, this._then);

  final SnPollQuestion _self;
  final $Res Function(SnPollQuestion) _then;

/// Create a copy of SnPollQuestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? options = freezed,Object? title = null,Object? description = freezed,Object? order = null,Object? isRequired = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SnPollQuestionType,options: freezed == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<SnPollOption>?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPollQuestion].
extension SnPollQuestionPatterns on SnPollQuestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPollQuestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPollQuestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPollQuestion value)  $default,){
final _that = this;
switch (_that) {
case _SnPollQuestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPollQuestion value)?  $default,){
final _that = this;
switch (_that) {
case _SnPollQuestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  SnPollQuestionType type,  List<SnPollOption>? options,  String title,  String? description,  int order,  bool isRequired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPollQuestion() when $default != null:
return $default(_that.id,_that.type,_that.options,_that.title,_that.description,_that.order,_that.isRequired);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  SnPollQuestionType type,  List<SnPollOption>? options,  String title,  String? description,  int order,  bool isRequired)  $default,) {final _that = this;
switch (_that) {
case _SnPollQuestion():
return $default(_that.id,_that.type,_that.options,_that.title,_that.description,_that.order,_that.isRequired);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  SnPollQuestionType type,  List<SnPollOption>? options,  String title,  String? description,  int order,  bool isRequired)?  $default,) {final _that = this;
switch (_that) {
case _SnPollQuestion() when $default != null:
return $default(_that.id,_that.type,_that.options,_that.title,_that.description,_that.order,_that.isRequired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPollQuestion implements SnPollQuestion {
  const _SnPollQuestion({required this.id, required this.type, final  List<SnPollOption>? options, required this.title, this.description, required this.order, required this.isRequired}): _options = options;
  factory _SnPollQuestion.fromJson(Map<String, dynamic> json) => _$SnPollQuestionFromJson(json);

@override final  String id;
@override final  SnPollQuestionType type;
 final  List<SnPollOption>? _options;
@override List<SnPollOption>? get options {
  final value = _options;
  if (value == null) return null;
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String title;
@override final  String? description;
@override final  int order;
@override final  bool isRequired;

/// Create a copy of SnPollQuestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPollQuestionCopyWith<_SnPollQuestion> get copyWith => __$SnPollQuestionCopyWithImpl<_SnPollQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPollQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPollQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(_options),title,description,order,isRequired);

@override
String toString() {
  return 'SnPollQuestion(id: $id, type: $type, options: $options, title: $title, description: $description, order: $order, isRequired: $isRequired)';
}


}

/// @nodoc
abstract mixin class _$SnPollQuestionCopyWith<$Res> implements $SnPollQuestionCopyWith<$Res> {
  factory _$SnPollQuestionCopyWith(_SnPollQuestion value, $Res Function(_SnPollQuestion) _then) = __$SnPollQuestionCopyWithImpl;
@override @useResult
$Res call({
 String id, SnPollQuestionType type, List<SnPollOption>? options, String title, String? description, int order, bool isRequired
});




}
/// @nodoc
class __$SnPollQuestionCopyWithImpl<$Res>
    implements _$SnPollQuestionCopyWith<$Res> {
  __$SnPollQuestionCopyWithImpl(this._self, this._then);

  final _SnPollQuestion _self;
  final $Res Function(_SnPollQuestion) _then;

/// Create a copy of SnPollQuestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? options = freezed,Object? title = null,Object? description = freezed,Object? order = null,Object? isRequired = null,}) {
  return _then(_SnPollQuestion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SnPollQuestionType,options: freezed == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<SnPollOption>?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SnPollOption {

 String get id; String get label; String? get description; int get order;
/// Create a copy of SnPollOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPollOptionCopyWith<SnPollOption> get copyWith => _$SnPollOptionCopyWithImpl<SnPollOption>(this as SnPollOption, _$identity);

  /// Serializes this SnPollOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPollOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,description,order);

@override
String toString() {
  return 'SnPollOption(id: $id, label: $label, description: $description, order: $order)';
}


}

/// @nodoc
abstract mixin class $SnPollOptionCopyWith<$Res>  {
  factory $SnPollOptionCopyWith(SnPollOption value, $Res Function(SnPollOption) _then) = _$SnPollOptionCopyWithImpl;
@useResult
$Res call({
 String id, String label, String? description, int order
});




}
/// @nodoc
class _$SnPollOptionCopyWithImpl<$Res>
    implements $SnPollOptionCopyWith<$Res> {
  _$SnPollOptionCopyWithImpl(this._self, this._then);

  final SnPollOption _self;
  final $Res Function(SnPollOption) _then;

/// Create a copy of SnPollOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? description = freezed,Object? order = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPollOption].
extension SnPollOptionPatterns on SnPollOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPollOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPollOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPollOption value)  $default,){
final _that = this;
switch (_that) {
case _SnPollOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPollOption value)?  $default,){
final _that = this;
switch (_that) {
case _SnPollOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  String? description,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPollOption() when $default != null:
return $default(_that.id,_that.label,_that.description,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  String? description,  int order)  $default,) {final _that = this;
switch (_that) {
case _SnPollOption():
return $default(_that.id,_that.label,_that.description,_that.order);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  String? description,  int order)?  $default,) {final _that = this;
switch (_that) {
case _SnPollOption() when $default != null:
return $default(_that.id,_that.label,_that.description,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPollOption implements SnPollOption {
  const _SnPollOption({required this.id, required this.label, this.description, required this.order});
  factory _SnPollOption.fromJson(Map<String, dynamic> json) => _$SnPollOptionFromJson(json);

@override final  String id;
@override final  String label;
@override final  String? description;
@override final  int order;

/// Create a copy of SnPollOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPollOptionCopyWith<_SnPollOption> get copyWith => __$SnPollOptionCopyWithImpl<_SnPollOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPollOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPollOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,description,order);

@override
String toString() {
  return 'SnPollOption(id: $id, label: $label, description: $description, order: $order)';
}


}

/// @nodoc
abstract mixin class _$SnPollOptionCopyWith<$Res> implements $SnPollOptionCopyWith<$Res> {
  factory _$SnPollOptionCopyWith(_SnPollOption value, $Res Function(_SnPollOption) _then) = __$SnPollOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String? description, int order
});




}
/// @nodoc
class __$SnPollOptionCopyWithImpl<$Res>
    implements _$SnPollOptionCopyWith<$Res> {
  __$SnPollOptionCopyWithImpl(this._self, this._then);

  final _SnPollOption _self;
  final $Res Function(_SnPollOption) _then;

/// Create a copy of SnPollOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? description = freezed,Object? order = null,}) {
  return _then(_SnPollOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
