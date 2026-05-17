// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publisher_leaderboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPublisherLeaderboardEntry {

@JsonKey(name: 'publisher_id') String get publisherId; String get name; String get nick; SnCloudFileReference? get picture; double get rating; int get rank; double get percentile; String get grade;
/// Create a copy of SnPublisherLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherLeaderboardEntryCopyWith<SnPublisherLeaderboardEntry> get copyWith => _$SnPublisherLeaderboardEntryCopyWithImpl<SnPublisherLeaderboardEntry>(this as SnPublisherLeaderboardEntry, _$identity);

  /// Serializes this SnPublisherLeaderboardEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherLeaderboardEntry&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.percentile, percentile) || other.percentile == percentile)&&(identical(other.grade, grade) || other.grade == grade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publisherId,name,nick,picture,rating,rank,percentile,grade);

@override
String toString() {
  return 'SnPublisherLeaderboardEntry(publisherId: $publisherId, name: $name, nick: $nick, picture: $picture, rating: $rating, rank: $rank, percentile: $percentile, grade: $grade)';
}


}

/// @nodoc
abstract mixin class $SnPublisherLeaderboardEntryCopyWith<$Res>  {
  factory $SnPublisherLeaderboardEntryCopyWith(SnPublisherLeaderboardEntry value, $Res Function(SnPublisherLeaderboardEntry) _then) = _$SnPublisherLeaderboardEntryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'publisher_id') String publisherId, String name, String nick, SnCloudFileReference? picture, double rating, int rank, double percentile, String grade
});


$SnCloudFileReferenceCopyWith<$Res>? get picture;

}
/// @nodoc
class _$SnPublisherLeaderboardEntryCopyWithImpl<$Res>
    implements $SnPublisherLeaderboardEntryCopyWith<$Res> {
  _$SnPublisherLeaderboardEntryCopyWithImpl(this._self, this._then);

  final SnPublisherLeaderboardEntry _self;
  final $Res Function(SnPublisherLeaderboardEntry) _then;

/// Create a copy of SnPublisherLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publisherId = null,Object? name = null,Object? nick = null,Object? picture = freezed,Object? rating = null,Object? rank = null,Object? percentile = null,Object? grade = null,}) {
  return _then(_self.copyWith(
publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,percentile: null == percentile ? _self.percentile : percentile // ignore: cast_nullable_to_non_nullable
as double,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SnPublisherLeaderboardEntry
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
}
}


/// Adds pattern-matching-related methods to [SnPublisherLeaderboardEntry].
extension SnPublisherLeaderboardEntryPatterns on SnPublisherLeaderboardEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherLeaderboardEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherLeaderboardEntry value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherLeaderboardEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherLeaderboardEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherLeaderboardEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'publisher_id')  String publisherId,  String name,  String nick,  SnCloudFileReference? picture,  double rating,  int rank,  double percentile,  String grade)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherLeaderboardEntry() when $default != null:
return $default(_that.publisherId,_that.name,_that.nick,_that.picture,_that.rating,_that.rank,_that.percentile,_that.grade);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'publisher_id')  String publisherId,  String name,  String nick,  SnCloudFileReference? picture,  double rating,  int rank,  double percentile,  String grade)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherLeaderboardEntry():
return $default(_that.publisherId,_that.name,_that.nick,_that.picture,_that.rating,_that.rank,_that.percentile,_that.grade);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'publisher_id')  String publisherId,  String name,  String nick,  SnCloudFileReference? picture,  double rating,  int rank,  double percentile,  String grade)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherLeaderboardEntry() when $default != null:
return $default(_that.publisherId,_that.name,_that.nick,_that.picture,_that.rating,_that.rank,_that.percentile,_that.grade);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherLeaderboardEntry implements SnPublisherLeaderboardEntry {
  const _SnPublisherLeaderboardEntry({@JsonKey(name: 'publisher_id') required this.publisherId, required this.name, required this.nick, this.picture, required this.rating, required this.rank, required this.percentile, required this.grade});
  factory _SnPublisherLeaderboardEntry.fromJson(Map<String, dynamic> json) => _$SnPublisherLeaderboardEntryFromJson(json);

@override@JsonKey(name: 'publisher_id') final  String publisherId;
@override final  String name;
@override final  String nick;
@override final  SnCloudFileReference? picture;
@override final  double rating;
@override final  int rank;
@override final  double percentile;
@override final  String grade;

/// Create a copy of SnPublisherLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherLeaderboardEntryCopyWith<_SnPublisherLeaderboardEntry> get copyWith => __$SnPublisherLeaderboardEntryCopyWithImpl<_SnPublisherLeaderboardEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherLeaderboardEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherLeaderboardEntry&&(identical(other.publisherId, publisherId) || other.publisherId == publisherId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nick, nick) || other.nick == nick)&&(identical(other.picture, picture) || other.picture == picture)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.percentile, percentile) || other.percentile == percentile)&&(identical(other.grade, grade) || other.grade == grade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,publisherId,name,nick,picture,rating,rank,percentile,grade);

@override
String toString() {
  return 'SnPublisherLeaderboardEntry(publisherId: $publisherId, name: $name, nick: $nick, picture: $picture, rating: $rating, rank: $rank, percentile: $percentile, grade: $grade)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherLeaderboardEntryCopyWith<$Res> implements $SnPublisherLeaderboardEntryCopyWith<$Res> {
  factory _$SnPublisherLeaderboardEntryCopyWith(_SnPublisherLeaderboardEntry value, $Res Function(_SnPublisherLeaderboardEntry) _then) = __$SnPublisherLeaderboardEntryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'publisher_id') String publisherId, String name, String nick, SnCloudFileReference? picture, double rating, int rank, double percentile, String grade
});


@override $SnCloudFileReferenceCopyWith<$Res>? get picture;

}
/// @nodoc
class __$SnPublisherLeaderboardEntryCopyWithImpl<$Res>
    implements _$SnPublisherLeaderboardEntryCopyWith<$Res> {
  __$SnPublisherLeaderboardEntryCopyWithImpl(this._self, this._then);

  final _SnPublisherLeaderboardEntry _self;
  final $Res Function(_SnPublisherLeaderboardEntry) _then;

/// Create a copy of SnPublisherLeaderboardEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publisherId = null,Object? name = null,Object? nick = null,Object? picture = freezed,Object? rating = null,Object? rank = null,Object? percentile = null,Object? grade = null,}) {
  return _then(_SnPublisherLeaderboardEntry(
publisherId: null == publisherId ? _self.publisherId : publisherId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,nick: null == nick ? _self.nick : nick // ignore: cast_nullable_to_non_nullable
as String,picture: freezed == picture ? _self.picture : picture // ignore: cast_nullable_to_non_nullable
as SnCloudFileReference?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,percentile: null == percentile ? _self.percentile : percentile // ignore: cast_nullable_to_non_nullable
as double,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SnPublisherLeaderboardEntry
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
}
}


/// @nodoc
mixin _$SnPublisherRatingOverview {

 double get rating; int get rank;@JsonKey(name: 'total_publishers') int get totalPublishers; double get percentile; String get grade;
/// Create a copy of SnPublisherRatingOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherRatingOverviewCopyWith<SnPublisherRatingOverview> get copyWith => _$SnPublisherRatingOverviewCopyWithImpl<SnPublisherRatingOverview>(this as SnPublisherRatingOverview, _$identity);

  /// Serializes this SnPublisherRatingOverview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPublisherRatingOverview&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.totalPublishers, totalPublishers) || other.totalPublishers == totalPublishers)&&(identical(other.percentile, percentile) || other.percentile == percentile)&&(identical(other.grade, grade) || other.grade == grade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rating,rank,totalPublishers,percentile,grade);

@override
String toString() {
  return 'SnPublisherRatingOverview(rating: $rating, rank: $rank, totalPublishers: $totalPublishers, percentile: $percentile, grade: $grade)';
}


}

/// @nodoc
abstract mixin class $SnPublisherRatingOverviewCopyWith<$Res>  {
  factory $SnPublisherRatingOverviewCopyWith(SnPublisherRatingOverview value, $Res Function(SnPublisherRatingOverview) _then) = _$SnPublisherRatingOverviewCopyWithImpl;
@useResult
$Res call({
 double rating, int rank,@JsonKey(name: 'total_publishers') int totalPublishers, double percentile, String grade
});




}
/// @nodoc
class _$SnPublisherRatingOverviewCopyWithImpl<$Res>
    implements $SnPublisherRatingOverviewCopyWith<$Res> {
  _$SnPublisherRatingOverviewCopyWithImpl(this._self, this._then);

  final SnPublisherRatingOverview _self;
  final $Res Function(SnPublisherRatingOverview) _then;

/// Create a copy of SnPublisherRatingOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rating = null,Object? rank = null,Object? totalPublishers = null,Object? percentile = null,Object? grade = null,}) {
  return _then(_self.copyWith(
rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,totalPublishers: null == totalPublishers ? _self.totalPublishers : totalPublishers // ignore: cast_nullable_to_non_nullable
as int,percentile: null == percentile ? _self.percentile : percentile // ignore: cast_nullable_to_non_nullable
as double,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SnPublisherRatingOverview].
extension SnPublisherRatingOverviewPatterns on SnPublisherRatingOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherRatingOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherRatingOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherRatingOverview value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherRatingOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherRatingOverview value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherRatingOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double rating,  int rank, @JsonKey(name: 'total_publishers')  int totalPublishers,  double percentile,  String grade)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherRatingOverview() when $default != null:
return $default(_that.rating,_that.rank,_that.totalPublishers,_that.percentile,_that.grade);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double rating,  int rank, @JsonKey(name: 'total_publishers')  int totalPublishers,  double percentile,  String grade)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherRatingOverview():
return $default(_that.rating,_that.rank,_that.totalPublishers,_that.percentile,_that.grade);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double rating,  int rank, @JsonKey(name: 'total_publishers')  int totalPublishers,  double percentile,  String grade)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherRatingOverview() when $default != null:
return $default(_that.rating,_that.rank,_that.totalPublishers,_that.percentile,_that.grade);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherRatingOverview implements SnPublisherRatingOverview {
  const _SnPublisherRatingOverview({required this.rating, required this.rank, @JsonKey(name: 'total_publishers') required this.totalPublishers, required this.percentile, required this.grade});
  factory _SnPublisherRatingOverview.fromJson(Map<String, dynamic> json) => _$SnPublisherRatingOverviewFromJson(json);

@override final  double rating;
@override final  int rank;
@override@JsonKey(name: 'total_publishers') final  int totalPublishers;
@override final  double percentile;
@override final  String grade;

/// Create a copy of SnPublisherRatingOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherRatingOverviewCopyWith<_SnPublisherRatingOverview> get copyWith => __$SnPublisherRatingOverviewCopyWithImpl<_SnPublisherRatingOverview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherRatingOverviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherRatingOverview&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.totalPublishers, totalPublishers) || other.totalPublishers == totalPublishers)&&(identical(other.percentile, percentile) || other.percentile == percentile)&&(identical(other.grade, grade) || other.grade == grade));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rating,rank,totalPublishers,percentile,grade);

@override
String toString() {
  return 'SnPublisherRatingOverview(rating: $rating, rank: $rank, totalPublishers: $totalPublishers, percentile: $percentile, grade: $grade)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherRatingOverviewCopyWith<$Res> implements $SnPublisherRatingOverviewCopyWith<$Res> {
  factory _$SnPublisherRatingOverviewCopyWith(_SnPublisherRatingOverview value, $Res Function(_SnPublisherRatingOverview) _then) = __$SnPublisherRatingOverviewCopyWithImpl;
@override @useResult
$Res call({
 double rating, int rank,@JsonKey(name: 'total_publishers') int totalPublishers, double percentile, String grade
});




}
/// @nodoc
class __$SnPublisherRatingOverviewCopyWithImpl<$Res>
    implements _$SnPublisherRatingOverviewCopyWith<$Res> {
  __$SnPublisherRatingOverviewCopyWithImpl(this._self, this._then);

  final _SnPublisherRatingOverview _self;
  final $Res Function(_SnPublisherRatingOverview) _then;

/// Create a copy of SnPublisherRatingOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rating = null,Object? rank = null,Object? totalPublishers = null,Object? percentile = null,Object? grade = null,}) {
  return _then(_SnPublisherRatingOverview(
rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,totalPublishers: null == totalPublishers ? _self.totalPublishers : totalPublishers // ignore: cast_nullable_to_non_nullable
as int,percentile: null == percentile ? _self.percentile : percentile // ignore: cast_nullable_to_non_nullable
as double,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
