// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'survey.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnSurveyWithStats {

 SnSurveyAnswer? get userAnswer; Map<String, dynamic> get stats; String get id; List<SnSurveyQuestion> get questions; String? get title; String? get description; DateTime? get endedAt; String get publisherId; SnPublisher? get publisher; SnSurveyStatus get status; DateTime? get publishedAt; bool get notifySubscribers; bool get isAnonymous; List<SnCloudFileReference> get attachments; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnSurveyWithStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSurveyWithStatsCopyWith<SnSurveyWithStats> get copyWith => _$SnSurveyWithStatsCopyWithImpl<SnSurveyWithStats>(this as SnSurveyWithStats, _$identity);

  /// Serializes this SnSurveyWithStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSurveyWithStats&&(identical(other.userAnswer, userAnswer) || other.userAnswer == userAnswer)&&const DeepCollectionEquality().equals(other.stats, stats)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.questions, questions)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.notifySubscribers, notifySubscribers) || other.notifySubscribers == notifySubscribers)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userAnswer,const DeepCollectionEquality().hash(stats),id,const DeepCollectionEquality().hash(questions),title,description,endedAt,publisherId,publisher,status,publishedAt,notifySubscribers,isAnonymous,const DeepCollectionEquality().hash(attachments),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSurveyWithStats(userAnswer: $userAnswer, stats: $stats, id: $id, questions: $questions, title: $title, description: $description, endedAt: $endedAt, publisherId: $publisherId, publisher: $publisher, status: $status, publishedAt: $publishedAt, notifySubscribers: $notifySubscribers, isAnonymous: $isAnonymous, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnSurveyWithStatsCopyWith<$Res>  {
  factory $SnSurveyWithStatsCopyWith(SnSurveyWithStats value, $Res Function(SnSurveyWithStats) _then) = _$SnSurveyWithStatsCopyWithImpl;
@useResult
$Res call({
 SnSurveyAnswer? userAnswer, Map<String, dynamic> stats, String id, List<SnSurveyQuestion> questions, String? title, String? description, DateTime? endedAt, String publisherId, SnPublisher? publisher, SnSurveyStatus status, DateTime? publishedAt, bool notifySubscribers, bool isAnonymous, List<SnCloudFileReference> attachments, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnSurveyAnswerCopyWith<$Res>? get userAnswer;$SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class _$SnSurveyWithStatsCopyWithImpl<$Res>
    implements $SnSurveyWithStatsCopyWith<$Res> {
  _$SnSurveyWithStatsCopyWithImpl(this._self, this._then);

  final SnSurveyWithStats _self;
  final $Res Function(SnSurveyWithStats) _then;

/// Create a copy of SnSurveyWithStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userAnswer = freezed,Object? stats = null,Object? id = null,Object? questions = null,Object? title = freezed,Object? description = freezed,Object? endedAt = freezed,Object? publisherId = null,Object? publisher = freezed,Object? status = null,Object? publishedAt = freezed,Object? notifySubscribers = null,Object? isAnonymous = null,Object? attachments = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
userAnswer: freezed == userAnswer ? _self.userAnswer : userAnswer // ignore: cast_nullable_to_non_nullable
as SnSurveyAnswer?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<SnSurveyQuestion>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnSurveyStatus,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notifySubscribers: null == notifySubscribers ? _self.notifySubscribers : notifySubscribers // ignore: cast_nullable_to_non_nullable
as bool,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnSurveyWithStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnSurveyAnswerCopyWith<$Res>? get userAnswer {
    if (_self.userAnswer == null) {
    return null;
  }

  return $SnSurveyAnswerCopyWith<$Res>(_self.userAnswer!, (value) {
    return _then(_self.copyWith(userAnswer: value));
  });
}/// Create a copy of SnSurveyWithStats
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


/// Adds pattern-matching-related methods to [SnSurveyWithStats].
extension SnSurveyWithStatsPatterns on SnSurveyWithStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSurveyWithStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSurveyWithStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSurveyWithStats value)  $default,){
final _that = this;
switch (_that) {
case _SnSurveyWithStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSurveyWithStats value)?  $default,){
final _that = this;
switch (_that) {
case _SnSurveyWithStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SnSurveyAnswer? userAnswer,  Map<String, dynamic> stats,  String id,  List<SnSurveyQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  SnPublisher? publisher,  SnSurveyStatus status,  DateTime? publishedAt,  bool notifySubscribers,  bool isAnonymous,  List<SnCloudFileReference> attachments,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSurveyWithStats() when $default != null:
return $default(_that.userAnswer,_that.stats,_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.publisher,_that.status,_that.publishedAt,_that.notifySubscribers,_that.isAnonymous,_that.attachments,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SnSurveyAnswer? userAnswer,  Map<String, dynamic> stats,  String id,  List<SnSurveyQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  SnPublisher? publisher,  SnSurveyStatus status,  DateTime? publishedAt,  bool notifySubscribers,  bool isAnonymous,  List<SnCloudFileReference> attachments,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnSurveyWithStats():
return $default(_that.userAnswer,_that.stats,_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.publisher,_that.status,_that.publishedAt,_that.notifySubscribers,_that.isAnonymous,_that.attachments,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SnSurveyAnswer? userAnswer,  Map<String, dynamic> stats,  String id,  List<SnSurveyQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  SnPublisher? publisher,  SnSurveyStatus status,  DateTime? publishedAt,  bool notifySubscribers,  bool isAnonymous,  List<SnCloudFileReference> attachments,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnSurveyWithStats() when $default != null:
return $default(_that.userAnswer,_that.stats,_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.publisher,_that.status,_that.publishedAt,_that.notifySubscribers,_that.isAnonymous,_that.attachments,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSurveyWithStats implements SnSurveyWithStats {
  const _SnSurveyWithStats({required this.userAnswer, final  Map<String, dynamic> stats = const {}, required this.id, required final  List<SnSurveyQuestion> questions, this.title, this.description, this.endedAt, required this.publisherId, this.publisher, required this.status, this.publishedAt, this.notifySubscribers = false, this.isAnonymous = false, final  List<SnCloudFileReference> attachments = const [], required this.createdAt, required this.updatedAt, this.deletedAt}): _stats = stats,_questions = questions,_attachments = attachments;
  factory _SnSurveyWithStats.fromJson(Map<String, dynamic> json) => _$SnSurveyWithStatsFromJson(json);

@override final  SnSurveyAnswer? userAnswer;
 final  Map<String, dynamic> _stats;
@override@JsonKey() Map<String, dynamic> get stats {
  if (_stats is EqualUnmodifiableMapView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stats);
}

@override final  String id;
 final  List<SnSurveyQuestion> _questions;
@override List<SnSurveyQuestion> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override final  String? title;
@override final  String? description;
@override final  DateTime? endedAt;
@override final  String publisherId;
@override final  SnPublisher? publisher;
@override final  SnSurveyStatus status;
@override final  DateTime? publishedAt;
@override@JsonKey() final  bool notifySubscribers;
@override@JsonKey() final  bool isAnonymous;
 final  List<SnCloudFileReference> _attachments;
@override@JsonKey() List<SnCloudFileReference> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnSurveyWithStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSurveyWithStatsCopyWith<_SnSurveyWithStats> get copyWith => __$SnSurveyWithStatsCopyWithImpl<_SnSurveyWithStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSurveyWithStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSurveyWithStats&&(identical(other.userAnswer, userAnswer) || other.userAnswer == userAnswer)&&const DeepCollectionEquality().equals(other._stats, _stats)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.notifySubscribers, notifySubscribers) || other.notifySubscribers == notifySubscribers)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userAnswer,const DeepCollectionEquality().hash(_stats),id,const DeepCollectionEquality().hash(_questions),title,description,endedAt,publisherId,publisher,status,publishedAt,notifySubscribers,isAnonymous,const DeepCollectionEquality().hash(_attachments),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSurveyWithStats(userAnswer: $userAnswer, stats: $stats, id: $id, questions: $questions, title: $title, description: $description, endedAt: $endedAt, publisherId: $publisherId, publisher: $publisher, status: $status, publishedAt: $publishedAt, notifySubscribers: $notifySubscribers, isAnonymous: $isAnonymous, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnSurveyWithStatsCopyWith<$Res> implements $SnSurveyWithStatsCopyWith<$Res> {
  factory _$SnSurveyWithStatsCopyWith(_SnSurveyWithStats value, $Res Function(_SnSurveyWithStats) _then) = __$SnSurveyWithStatsCopyWithImpl;
@override @useResult
$Res call({
 SnSurveyAnswer? userAnswer, Map<String, dynamic> stats, String id, List<SnSurveyQuestion> questions, String? title, String? description, DateTime? endedAt, String publisherId, SnPublisher? publisher, SnSurveyStatus status, DateTime? publishedAt, bool notifySubscribers, bool isAnonymous, List<SnCloudFileReference> attachments, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnSurveyAnswerCopyWith<$Res>? get userAnswer;@override $SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class __$SnSurveyWithStatsCopyWithImpl<$Res>
    implements _$SnSurveyWithStatsCopyWith<$Res> {
  __$SnSurveyWithStatsCopyWithImpl(this._self, this._then);

  final _SnSurveyWithStats _self;
  final $Res Function(_SnSurveyWithStats) _then;

/// Create a copy of SnSurveyWithStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userAnswer = freezed,Object? stats = null,Object? id = null,Object? questions = null,Object? title = freezed,Object? description = freezed,Object? endedAt = freezed,Object? publisherId = null,Object? publisher = freezed,Object? status = null,Object? publishedAt = freezed,Object? notifySubscribers = null,Object? isAnonymous = null,Object? attachments = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnSurveyWithStats(
userAnswer: freezed == userAnswer ? _self.userAnswer : userAnswer // ignore: cast_nullable_to_non_nullable
as SnSurveyAnswer?,stats: null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<SnSurveyQuestion>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnSurveyStatus,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notifySubscribers: null == notifySubscribers ? _self.notifySubscribers : notifySubscribers // ignore: cast_nullable_to_non_nullable
as bool,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnSurveyWithStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnSurveyAnswerCopyWith<$Res>? get userAnswer {
    if (_self.userAnswer == null) {
    return null;
  }

  return $SnSurveyAnswerCopyWith<$Res>(_self.userAnswer!, (value) {
    return _then(_self.copyWith(userAnswer: value));
  });
}/// Create a copy of SnSurveyWithStats
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
mixin _$SnSurvey {

 String get id; List<SnSurveyQuestion> get questions; String? get title; String? get description; DateTime? get endedAt; String get publisherId; SnPublisher? get publisher; SnSurveyStatus get status; DateTime? get publishedAt; bool get notifySubscribers; bool get isAnonymous; List<SnCloudFileReference> get attachments;// ModelBase fields
 DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnSurvey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSurveyCopyWith<SnSurvey> get copyWith => _$SnSurveyCopyWithImpl<SnSurvey>(this as SnSurvey, _$identity);

  /// Serializes this SnSurvey to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSurvey&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.questions, questions)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.notifySubscribers, notifySubscribers) || other.notifySubscribers == notifySubscribers)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(questions),title,description,endedAt,publisherId,publisher,status,publishedAt,notifySubscribers,isAnonymous,const DeepCollectionEquality().hash(attachments),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSurvey(id: $id, questions: $questions, title: $title, description: $description, endedAt: $endedAt, publisherId: $publisherId, publisher: $publisher, status: $status, publishedAt: $publishedAt, notifySubscribers: $notifySubscribers, isAnonymous: $isAnonymous, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnSurveyCopyWith<$Res>  {
  factory $SnSurveyCopyWith(SnSurvey value, $Res Function(SnSurvey) _then) = _$SnSurveyCopyWithImpl;
@useResult
$Res call({
 String id, List<SnSurveyQuestion> questions, String? title, String? description, DateTime? endedAt, String publisherId, SnPublisher? publisher, SnSurveyStatus status, DateTime? publishedAt, bool notifySubscribers, bool isAnonymous, List<SnCloudFileReference> attachments, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


$SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class _$SnSurveyCopyWithImpl<$Res>
    implements $SnSurveyCopyWith<$Res> {
  _$SnSurveyCopyWithImpl(this._self, this._then);

  final SnSurvey _self;
  final $Res Function(SnSurvey) _then;

/// Create a copy of SnSurvey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? questions = null,Object? title = freezed,Object? description = freezed,Object? endedAt = freezed,Object? publisherId = null,Object? publisher = freezed,Object? status = null,Object? publishedAt = freezed,Object? notifySubscribers = null,Object? isAnonymous = null,Object? attachments = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<SnSurveyQuestion>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnSurveyStatus,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notifySubscribers: null == notifySubscribers ? _self.notifySubscribers : notifySubscribers // ignore: cast_nullable_to_non_nullable
as bool,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of SnSurvey
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


/// Adds pattern-matching-related methods to [SnSurvey].
extension SnSurveyPatterns on SnSurvey {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSurvey value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSurvey() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSurvey value)  $default,){
final _that = this;
switch (_that) {
case _SnSurvey():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSurvey value)?  $default,){
final _that = this;
switch (_that) {
case _SnSurvey() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<SnSurveyQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  SnPublisher? publisher,  SnSurveyStatus status,  DateTime? publishedAt,  bool notifySubscribers,  bool isAnonymous,  List<SnCloudFileReference> attachments,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSurvey() when $default != null:
return $default(_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.publisher,_that.status,_that.publishedAt,_that.notifySubscribers,_that.isAnonymous,_that.attachments,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<SnSurveyQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  SnPublisher? publisher,  SnSurveyStatus status,  DateTime? publishedAt,  bool notifySubscribers,  bool isAnonymous,  List<SnCloudFileReference> attachments,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnSurvey():
return $default(_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.publisher,_that.status,_that.publishedAt,_that.notifySubscribers,_that.isAnonymous,_that.attachments,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<SnSurveyQuestion> questions,  String? title,  String? description,  DateTime? endedAt,  String publisherId,  SnPublisher? publisher,  SnSurveyStatus status,  DateTime? publishedAt,  bool notifySubscribers,  bool isAnonymous,  List<SnCloudFileReference> attachments,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnSurvey() when $default != null:
return $default(_that.id,_that.questions,_that.title,_that.description,_that.endedAt,_that.publisherId,_that.publisher,_that.status,_that.publishedAt,_that.notifySubscribers,_that.isAnonymous,_that.attachments,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSurvey implements SnSurvey {
  const _SnSurvey({required this.id, required final  List<SnSurveyQuestion> questions, this.title, this.description, this.endedAt, required this.publisherId, this.publisher, required this.status, this.publishedAt, this.notifySubscribers = false, this.isAnonymous = false, final  List<SnCloudFileReference> attachments = const [], required this.createdAt, required this.updatedAt, this.deletedAt}): _questions = questions,_attachments = attachments;
  factory _SnSurvey.fromJson(Map<String, dynamic> json) => _$SnSurveyFromJson(json);

@override final  String id;
 final  List<SnSurveyQuestion> _questions;
@override List<SnSurveyQuestion> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override final  String? title;
@override final  String? description;
@override final  DateTime? endedAt;
@override final  String publisherId;
@override final  SnPublisher? publisher;
@override final  SnSurveyStatus status;
@override final  DateTime? publishedAt;
@override@JsonKey() final  bool notifySubscribers;
@override@JsonKey() final  bool isAnonymous;
 final  List<SnCloudFileReference> _attachments;
@override@JsonKey() List<SnCloudFileReference> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

// ModelBase fields
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnSurvey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSurveyCopyWith<_SnSurvey> get copyWith => __$SnSurveyCopyWithImpl<_SnSurvey>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSurveyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSurvey&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._questions, _questions)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.status, status) || other.status == status)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.notifySubscribers, notifySubscribers) || other.notifySubscribers == notifySubscribers)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_questions),title,description,endedAt,publisherId,publisher,status,publishedAt,notifySubscribers,isAnonymous,const DeepCollectionEquality().hash(_attachments),createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSurvey(id: $id, questions: $questions, title: $title, description: $description, endedAt: $endedAt, publisherId: $publisherId, publisher: $publisher, status: $status, publishedAt: $publishedAt, notifySubscribers: $notifySubscribers, isAnonymous: $isAnonymous, attachments: $attachments, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnSurveyCopyWith<$Res> implements $SnSurveyCopyWith<$Res> {
  factory _$SnSurveyCopyWith(_SnSurvey value, $Res Function(_SnSurvey) _then) = __$SnSurveyCopyWithImpl;
@override @useResult
$Res call({
 String id, List<SnSurveyQuestion> questions, String? title, String? description, DateTime? endedAt, String publisherId, SnPublisher? publisher, SnSurveyStatus status, DateTime? publishedAt, bool notifySubscribers, bool isAnonymous, List<SnCloudFileReference> attachments, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});


@override $SnPublisherCopyWith<$Res>? get publisher;

}
/// @nodoc
class __$SnSurveyCopyWithImpl<$Res>
    implements _$SnSurveyCopyWith<$Res> {
  __$SnSurveyCopyWithImpl(this._self, this._then);

  final _SnSurvey _self;
  final $Res Function(_SnSurvey) _then;

/// Create a copy of SnSurvey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? questions = null,Object? title = freezed,Object? description = freezed,Object? endedAt = freezed,Object? publisherId = null,Object? publisher = freezed,Object? status = null,Object? publishedAt = freezed,Object? notifySubscribers = null,Object? isAnonymous = null,Object? attachments = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnSurvey(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<SnSurveyQuestion>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SnSurveyStatus,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,notifySubscribers: null == notifySubscribers ? _self.notifySubscribers : notifySubscribers // ignore: cast_nullable_to_non_nullable
as bool,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of SnSurvey
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
mixin _$SnSurveyQuestion {

 String get id; SnSurveyQuestionType get type; List<SnSurveyOption>? get options; String get title; String? get description; int get order; bool get isRequired; int? get maxSelections; int? get maxLength; double? get minValue; double? get maxValue; List<SnCloudFileReference> get attachments;
/// Create a copy of SnSurveyQuestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSurveyQuestionCopyWith<SnSurveyQuestion> get copyWith => _$SnSurveyQuestionCopyWithImpl<SnSurveyQuestion>(this as SnSurveyQuestion, _$identity);

  /// Serializes this SnSurveyQuestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSurveyQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.options, options)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.maxSelections, maxSelections) || other.maxSelections == maxSelections)&&(identical(other.maxLength, maxLength) || other.maxLength == maxLength)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(options),title,description,order,isRequired,maxSelections,maxLength,minValue,maxValue,const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'SnSurveyQuestion(id: $id, type: $type, options: $options, title: $title, description: $description, order: $order, isRequired: $isRequired, maxSelections: $maxSelections, maxLength: $maxLength, minValue: $minValue, maxValue: $maxValue, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $SnSurveyQuestionCopyWith<$Res>  {
  factory $SnSurveyQuestionCopyWith(SnSurveyQuestion value, $Res Function(SnSurveyQuestion) _then) = _$SnSurveyQuestionCopyWithImpl;
@useResult
$Res call({
 String id, SnSurveyQuestionType type, List<SnSurveyOption>? options, String title, String? description, int order, bool isRequired, int? maxSelections, int? maxLength, double? minValue, double? maxValue, List<SnCloudFileReference> attachments
});




}
/// @nodoc
class _$SnSurveyQuestionCopyWithImpl<$Res>
    implements $SnSurveyQuestionCopyWith<$Res> {
  _$SnSurveyQuestionCopyWithImpl(this._self, this._then);

  final SnSurveyQuestion _self;
  final $Res Function(SnSurveyQuestion) _then;

/// Create a copy of SnSurveyQuestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? options = freezed,Object? title = null,Object? description = freezed,Object? order = null,Object? isRequired = null,Object? maxSelections = freezed,Object? maxLength = freezed,Object? minValue = freezed,Object? maxValue = freezed,Object? attachments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SnSurveyQuestionType,options: freezed == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<SnSurveyOption>?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,maxSelections: freezed == maxSelections ? _self.maxSelections : maxSelections // ignore: cast_nullable_to_non_nullable
as int?,maxLength: freezed == maxLength ? _self.maxLength : maxLength // ignore: cast_nullable_to_non_nullable
as int?,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as double?,maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as double?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnSurveyQuestion].
extension SnSurveyQuestionPatterns on SnSurveyQuestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSurveyQuestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSurveyQuestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSurveyQuestion value)  $default,){
final _that = this;
switch (_that) {
case _SnSurveyQuestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSurveyQuestion value)?  $default,){
final _that = this;
switch (_that) {
case _SnSurveyQuestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  SnSurveyQuestionType type,  List<SnSurveyOption>? options,  String title,  String? description,  int order,  bool isRequired,  int? maxSelections,  int? maxLength,  double? minValue,  double? maxValue,  List<SnCloudFileReference> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSurveyQuestion() when $default != null:
return $default(_that.id,_that.type,_that.options,_that.title,_that.description,_that.order,_that.isRequired,_that.maxSelections,_that.maxLength,_that.minValue,_that.maxValue,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  SnSurveyQuestionType type,  List<SnSurveyOption>? options,  String title,  String? description,  int order,  bool isRequired,  int? maxSelections,  int? maxLength,  double? minValue,  double? maxValue,  List<SnCloudFileReference> attachments)  $default,) {final _that = this;
switch (_that) {
case _SnSurveyQuestion():
return $default(_that.id,_that.type,_that.options,_that.title,_that.description,_that.order,_that.isRequired,_that.maxSelections,_that.maxLength,_that.minValue,_that.maxValue,_that.attachments);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  SnSurveyQuestionType type,  List<SnSurveyOption>? options,  String title,  String? description,  int order,  bool isRequired,  int? maxSelections,  int? maxLength,  double? minValue,  double? maxValue,  List<SnCloudFileReference> attachments)?  $default,) {final _that = this;
switch (_that) {
case _SnSurveyQuestion() when $default != null:
return $default(_that.id,_that.type,_that.options,_that.title,_that.description,_that.order,_that.isRequired,_that.maxSelections,_that.maxLength,_that.minValue,_that.maxValue,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSurveyQuestion implements SnSurveyQuestion {
  const _SnSurveyQuestion({required this.id, required this.type, final  List<SnSurveyOption>? options, required this.title, this.description, required this.order, required this.isRequired, this.maxSelections, this.maxLength, this.minValue, this.maxValue, final  List<SnCloudFileReference> attachments = const []}): _options = options,_attachments = attachments;
  factory _SnSurveyQuestion.fromJson(Map<String, dynamic> json) => _$SnSurveyQuestionFromJson(json);

@override final  String id;
@override final  SnSurveyQuestionType type;
 final  List<SnSurveyOption>? _options;
@override List<SnSurveyOption>? get options {
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
@override final  int? maxSelections;
@override final  int? maxLength;
@override final  double? minValue;
@override final  double? maxValue;
 final  List<SnCloudFileReference> _attachments;
@override@JsonKey() List<SnCloudFileReference> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of SnSurveyQuestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSurveyQuestionCopyWith<_SnSurveyQuestion> get copyWith => __$SnSurveyQuestionCopyWithImpl<_SnSurveyQuestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSurveyQuestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSurveyQuestion&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._options, _options)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.maxSelections, maxSelections) || other.maxSelections == maxSelections)&&(identical(other.maxLength, maxLength) || other.maxLength == maxLength)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,const DeepCollectionEquality().hash(_options),title,description,order,isRequired,maxSelections,maxLength,minValue,maxValue,const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'SnSurveyQuestion(id: $id, type: $type, options: $options, title: $title, description: $description, order: $order, isRequired: $isRequired, maxSelections: $maxSelections, maxLength: $maxLength, minValue: $minValue, maxValue: $maxValue, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$SnSurveyQuestionCopyWith<$Res> implements $SnSurveyQuestionCopyWith<$Res> {
  factory _$SnSurveyQuestionCopyWith(_SnSurveyQuestion value, $Res Function(_SnSurveyQuestion) _then) = __$SnSurveyQuestionCopyWithImpl;
@override @useResult
$Res call({
 String id, SnSurveyQuestionType type, List<SnSurveyOption>? options, String title, String? description, int order, bool isRequired, int? maxSelections, int? maxLength, double? minValue, double? maxValue, List<SnCloudFileReference> attachments
});




}
/// @nodoc
class __$SnSurveyQuestionCopyWithImpl<$Res>
    implements _$SnSurveyQuestionCopyWith<$Res> {
  __$SnSurveyQuestionCopyWithImpl(this._self, this._then);

  final _SnSurveyQuestion _self;
  final $Res Function(_SnSurveyQuestion) _then;

/// Create a copy of SnSurveyQuestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? options = freezed,Object? title = null,Object? description = freezed,Object? order = null,Object? isRequired = null,Object? maxSelections = freezed,Object? maxLength = freezed,Object? minValue = freezed,Object? maxValue = freezed,Object? attachments = null,}) {
  return _then(_SnSurveyQuestion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SnSurveyQuestionType,options: freezed == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<SnSurveyOption>?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,maxSelections: freezed == maxSelections ? _self.maxSelections : maxSelections // ignore: cast_nullable_to_non_nullable
as int?,maxLength: freezed == maxLength ? _self.maxLength : maxLength // ignore: cast_nullable_to_non_nullable
as int?,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as double?,maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as double?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<SnCloudFileReference>,
  ));
}


}


/// @nodoc
mixin _$SnSurveyOption {

 String get id; String get label; String? get description; int get order;
/// Create a copy of SnSurveyOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSurveyOptionCopyWith<SnSurveyOption> get copyWith => _$SnSurveyOptionCopyWithImpl<SnSurveyOption>(this as SnSurveyOption, _$identity);

  /// Serializes this SnSurveyOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSurveyOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,description,order);

@override
String toString() {
  return 'SnSurveyOption(id: $id, label: $label, description: $description, order: $order)';
}


}

/// @nodoc
abstract mixin class $SnSurveyOptionCopyWith<$Res>  {
  factory $SnSurveyOptionCopyWith(SnSurveyOption value, $Res Function(SnSurveyOption) _then) = _$SnSurveyOptionCopyWithImpl;
@useResult
$Res call({
 String id, String label, String? description, int order
});




}
/// @nodoc
class _$SnSurveyOptionCopyWithImpl<$Res>
    implements $SnSurveyOptionCopyWith<$Res> {
  _$SnSurveyOptionCopyWithImpl(this._self, this._then);

  final SnSurveyOption _self;
  final $Res Function(SnSurveyOption) _then;

/// Create a copy of SnSurveyOption
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


/// Adds pattern-matching-related methods to [SnSurveyOption].
extension SnSurveyOptionPatterns on SnSurveyOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSurveyOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSurveyOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSurveyOption value)  $default,){
final _that = this;
switch (_that) {
case _SnSurveyOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSurveyOption value)?  $default,){
final _that = this;
switch (_that) {
case _SnSurveyOption() when $default != null:
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
case _SnSurveyOption() when $default != null:
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
case _SnSurveyOption():
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
case _SnSurveyOption() when $default != null:
return $default(_that.id,_that.label,_that.description,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSurveyOption implements SnSurveyOption {
  const _SnSurveyOption({required this.id, required this.label, this.description, required this.order});
  factory _SnSurveyOption.fromJson(Map<String, dynamic> json) => _$SnSurveyOptionFromJson(json);

@override final  String id;
@override final  String label;
@override final  String? description;
@override final  int order;

/// Create a copy of SnSurveyOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSurveyOptionCopyWith<_SnSurveyOption> get copyWith => __$SnSurveyOptionCopyWithImpl<_SnSurveyOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSurveyOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSurveyOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.description, description) || other.description == description)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,description,order);

@override
String toString() {
  return 'SnSurveyOption(id: $id, label: $label, description: $description, order: $order)';
}


}

/// @nodoc
abstract mixin class _$SnSurveyOptionCopyWith<$Res> implements $SnSurveyOptionCopyWith<$Res> {
  factory _$SnSurveyOptionCopyWith(_SnSurveyOption value, $Res Function(_SnSurveyOption) _then) = __$SnSurveyOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, String? description, int order
});




}
/// @nodoc
class __$SnSurveyOptionCopyWithImpl<$Res>
    implements _$SnSurveyOptionCopyWith<$Res> {
  __$SnSurveyOptionCopyWithImpl(this._self, this._then);

  final _SnSurveyOption _self;
  final $Res Function(_SnSurveyOption) _then;

/// Create a copy of SnSurveyOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? description = freezed,Object? order = null,}) {
  return _then(_SnSurveyOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SnSurveyAnswer {

 String get id; Map<String, dynamic> get answer; String get accountId; String get surveyId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt; SnAccount? get account;
/// Create a copy of SnSurveyAnswer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSurveyAnswerCopyWith<SnSurveyAnswer> get copyWith => _$SnSurveyAnswerCopyWithImpl<SnSurveyAnswer>(this as SnSurveyAnswer, _$identity);

  /// Serializes this SnSurveyAnswer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSurveyAnswer&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.answer, answer)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.surveyId, surveyId) || other.surveyId == surveyId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.account, account) || other.account == account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(answer),accountId,surveyId,createdAt,updatedAt,deletedAt,account);

@override
String toString() {
  return 'SnSurveyAnswer(id: $id, answer: $answer, accountId: $accountId, surveyId: $surveyId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, account: $account)';
}


}

/// @nodoc
abstract mixin class $SnSurveyAnswerCopyWith<$Res>  {
  factory $SnSurveyAnswerCopyWith(SnSurveyAnswer value, $Res Function(SnSurveyAnswer) _then) = _$SnSurveyAnswerCopyWithImpl;
@useResult
$Res call({
 String id, Map<String, dynamic> answer, String accountId, String surveyId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, SnAccount? account
});


$SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class _$SnSurveyAnswerCopyWithImpl<$Res>
    implements $SnSurveyAnswerCopyWith<$Res> {
  _$SnSurveyAnswerCopyWithImpl(this._self, this._then);

  final SnSurveyAnswer _self;
  final $Res Function(SnSurveyAnswer) _then;

/// Create a copy of SnSurveyAnswer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? answer = null,Object? accountId = null,Object? surveyId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? account = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self.answer : answer // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,surveyId: null == surveyId ? _self.surveyId : surveyId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}
/// Create a copy of SnSurveyAnswer
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


/// Adds pattern-matching-related methods to [SnSurveyAnswer].
extension SnSurveyAnswerPatterns on SnSurveyAnswer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSurveyAnswer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSurveyAnswer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSurveyAnswer value)  $default,){
final _that = this;
switch (_that) {
case _SnSurveyAnswer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSurveyAnswer value)?  $default,){
final _that = this;
switch (_that) {
case _SnSurveyAnswer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  Map<String, dynamic> answer,  String accountId,  String surveyId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  SnAccount? account)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSurveyAnswer() when $default != null:
return $default(_that.id,_that.answer,_that.accountId,_that.surveyId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.account);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  Map<String, dynamic> answer,  String accountId,  String surveyId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  SnAccount? account)  $default,) {final _that = this;
switch (_that) {
case _SnSurveyAnswer():
return $default(_that.id,_that.answer,_that.accountId,_that.surveyId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.account);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  Map<String, dynamic> answer,  String accountId,  String surveyId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt,  SnAccount? account)?  $default,) {final _that = this;
switch (_that) {
case _SnSurveyAnswer() when $default != null:
return $default(_that.id,_that.answer,_that.accountId,_that.surveyId,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.account);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSurveyAnswer implements SnSurveyAnswer {
  const _SnSurveyAnswer({required this.id, required final  Map<String, dynamic> answer, required this.accountId, required this.surveyId, required this.createdAt, required this.updatedAt, required this.deletedAt, this.account}): _answer = answer;
  factory _SnSurveyAnswer.fromJson(Map<String, dynamic> json) => _$SnSurveyAnswerFromJson(json);

@override final  String id;
 final  Map<String, dynamic> _answer;
@override Map<String, dynamic> get answer {
  if (_answer is EqualUnmodifiableMapView) return _answer;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_answer);
}

@override final  String accountId;
@override final  String surveyId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;
@override final  SnAccount? account;

/// Create a copy of SnSurveyAnswer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSurveyAnswerCopyWith<_SnSurveyAnswer> get copyWith => __$SnSurveyAnswerCopyWithImpl<_SnSurveyAnswer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSurveyAnswerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSurveyAnswer&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._answer, _answer)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.surveyId, surveyId) || other.surveyId == surveyId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.account, account) || other.account == account));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_answer),accountId,surveyId,createdAt,updatedAt,deletedAt,account);

@override
String toString() {
  return 'SnSurveyAnswer(id: $id, answer: $answer, accountId: $accountId, surveyId: $surveyId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, account: $account)';
}


}

/// @nodoc
abstract mixin class _$SnSurveyAnswerCopyWith<$Res> implements $SnSurveyAnswerCopyWith<$Res> {
  factory _$SnSurveyAnswerCopyWith(_SnSurveyAnswer value, $Res Function(_SnSurveyAnswer) _then) = __$SnSurveyAnswerCopyWithImpl;
@override @useResult
$Res call({
 String id, Map<String, dynamic> answer, String accountId, String surveyId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt, SnAccount? account
});


@override $SnAccountCopyWith<$Res>? get account;

}
/// @nodoc
class __$SnSurveyAnswerCopyWithImpl<$Res>
    implements _$SnSurveyAnswerCopyWith<$Res> {
  __$SnSurveyAnswerCopyWithImpl(this._self, this._then);

  final _SnSurveyAnswer _self;
  final $Res Function(_SnSurveyAnswer) _then;

/// Create a copy of SnSurveyAnswer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? answer = null,Object? accountId = null,Object? surveyId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,Object? account = freezed,}) {
  return _then(_SnSurveyAnswer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,answer: null == answer ? _self._answer : answer // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,surveyId: null == surveyId ? _self.surveyId : surveyId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as SnAccount?,
  ));
}

/// Create a copy of SnSurveyAnswer
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
mixin _$SnSurveySubscription {

 String get id; String get surveyId; String get accountId; DateTime get createdAt; DateTime get updatedAt; DateTime? get deletedAt;
/// Create a copy of SnSurveySubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnSurveySubscriptionCopyWith<SnSurveySubscription> get copyWith => _$SnSurveySubscriptionCopyWithImpl<SnSurveySubscription>(this as SnSurveySubscription, _$identity);

  /// Serializes this SnSurveySubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnSurveySubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.surveyId, surveyId) || other.surveyId == surveyId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surveyId,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSurveySubscription(id: $id, surveyId: $surveyId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $SnSurveySubscriptionCopyWith<$Res>  {
  factory $SnSurveySubscriptionCopyWith(SnSurveySubscription value, $Res Function(SnSurveySubscription) _then) = _$SnSurveySubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String surveyId, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$SnSurveySubscriptionCopyWithImpl<$Res>
    implements $SnSurveySubscriptionCopyWith<$Res> {
  _$SnSurveySubscriptionCopyWithImpl(this._self, this._then);

  final SnSurveySubscription _self;
  final $Res Function(SnSurveySubscription) _then;

/// Create a copy of SnSurveySubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? surveyId = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,surveyId: null == surveyId ? _self.surveyId : surveyId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SnSurveySubscription].
extension SnSurveySubscriptionPatterns on SnSurveySubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnSurveySubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnSurveySubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnSurveySubscription value)  $default,){
final _that = this;
switch (_that) {
case _SnSurveySubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnSurveySubscription value)?  $default,){
final _that = this;
switch (_that) {
case _SnSurveySubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String surveyId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnSurveySubscription() when $default != null:
return $default(_that.id,_that.surveyId,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String surveyId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _SnSurveySubscription():
return $default(_that.id,_that.surveyId,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String surveyId,  String accountId,  DateTime createdAt,  DateTime updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _SnSurveySubscription() when $default != null:
return $default(_that.id,_that.surveyId,_that.accountId,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnSurveySubscription implements SnSurveySubscription {
  const _SnSurveySubscription({required this.id, required this.surveyId, required this.accountId, required this.createdAt, required this.updatedAt, this.deletedAt});
  factory _SnSurveySubscription.fromJson(Map<String, dynamic> json) => _$SnSurveySubscriptionFromJson(json);

@override final  String id;
@override final  String surveyId;
@override final  String accountId;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of SnSurveySubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnSurveySubscriptionCopyWith<_SnSurveySubscription> get copyWith => __$SnSurveySubscriptionCopyWithImpl<_SnSurveySubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnSurveySubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnSurveySubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.surveyId, surveyId) || other.surveyId == surveyId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,surveyId,accountId,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'SnSurveySubscription(id: $id, surveyId: $surveyId, accountId: $accountId, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$SnSurveySubscriptionCopyWith<$Res> implements $SnSurveySubscriptionCopyWith<$Res> {
  factory _$SnSurveySubscriptionCopyWith(_SnSurveySubscription value, $Res Function(_SnSurveySubscription) _then) = __$SnSurveySubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String surveyId, String accountId, DateTime createdAt, DateTime updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$SnSurveySubscriptionCopyWithImpl<$Res>
    implements _$SnSurveySubscriptionCopyWith<$Res> {
  __$SnSurveySubscriptionCopyWithImpl(this._self, this._then);

  final _SnSurveySubscription _self;
  final $Res Function(_SnSurveySubscription) _then;

/// Create a copy of SnSurveySubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? surveyId = null,Object? accountId = null,Object? createdAt = null,Object? updatedAt = null,Object? deletedAt = freezed,}) {
  return _then(_SnSurveySubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,surveyId: null == surveyId ? _self.surveyId : surveyId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
