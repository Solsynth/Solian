// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heatmap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPublisherHeatmap {

 String get unit;@JsonKey(name: 'period_start') DateTime get periodStart;@JsonKey(name: 'period_end') DateTime get periodEnd; List<SnHeatmapItem> get items;
/// Create a copy of SnPublisherHeatmap
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherHeatmapCopyWith<SnHeatmap> get copyWith => _$SnPublisherHeatmapCopyWithImpl<SnHeatmap>(this as SnHeatmap, _$identity);

  /// Serializes this SnPublisherHeatmap to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnHeatmap&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unit,periodStart,periodEnd,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'SnPublisherHeatmap(unit: $unit, periodStart: $periodStart, periodEnd: $periodEnd, items: $items)';
}


}

/// @nodoc
abstract mixin class $SnPublisherHeatmapCopyWith<$Res>  {
  factory $SnPublisherHeatmapCopyWith(SnHeatmap value, $Res Function(SnHeatmap) _then) = _$SnPublisherHeatmapCopyWithImpl;
@useResult
$Res call({
 String unit,@JsonKey(name: 'period_start') DateTime periodStart,@JsonKey(name: 'period_end') DateTime periodEnd, List<SnHeatmapItem> items
});




}
/// @nodoc
class _$SnPublisherHeatmapCopyWithImpl<$Res>
    implements $SnPublisherHeatmapCopyWith<$Res> {
  _$SnPublisherHeatmapCopyWithImpl(this._self, this._then);

  final SnHeatmap _self;
  final $Res Function(SnHeatmap) _then;

/// Create a copy of SnPublisherHeatmap
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unit = null,Object? periodStart = null,Object? periodEnd = null,Object? items = null,}) {
  return _then(_self.copyWith(
unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SnHeatmapItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [SnHeatmap].
extension SnPublisherHeatmapPatterns on SnHeatmap {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherHeatmap value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherHeatmap() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherHeatmap value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherHeatmap():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherHeatmap value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherHeatmap() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String unit, @JsonKey(name: 'period_start')  DateTime periodStart, @JsonKey(name: 'period_end')  DateTime periodEnd,  List<SnHeatmapItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherHeatmap() when $default != null:
return $default(_that.unit,_that.periodStart,_that.periodEnd,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String unit, @JsonKey(name: 'period_start')  DateTime periodStart, @JsonKey(name: 'period_end')  DateTime periodEnd,  List<SnHeatmapItem> items)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherHeatmap():
return $default(_that.unit,_that.periodStart,_that.periodEnd,_that.items);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String unit, @JsonKey(name: 'period_start')  DateTime periodStart, @JsonKey(name: 'period_end')  DateTime periodEnd,  List<SnHeatmapItem> items)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherHeatmap() when $default != null:
return $default(_that.unit,_that.periodStart,_that.periodEnd,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherHeatmap implements SnHeatmap {
  const _SnPublisherHeatmap({required this.unit, @JsonKey(name: 'period_start') required this.periodStart, @JsonKey(name: 'period_end') required this.periodEnd, required final  List<SnHeatmapItem> items}): _items = items;
  factory _SnPublisherHeatmap.fromJson(Map<String, dynamic> json) => _$SnPublisherHeatmapFromJson(json);

@override final  String unit;
@override@JsonKey(name: 'period_start') final  DateTime periodStart;
@override@JsonKey(name: 'period_end') final  DateTime periodEnd;
 final  List<SnHeatmapItem> _items;
@override List<SnHeatmapItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of SnPublisherHeatmap
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherHeatmapCopyWith<_SnPublisherHeatmap> get copyWith => __$SnPublisherHeatmapCopyWithImpl<_SnPublisherHeatmap>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherHeatmapToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherHeatmap&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unit,periodStart,periodEnd,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'SnPublisherHeatmap(unit: $unit, periodStart: $periodStart, periodEnd: $periodEnd, items: $items)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherHeatmapCopyWith<$Res> implements $SnPublisherHeatmapCopyWith<$Res> {
  factory _$SnPublisherHeatmapCopyWith(_SnPublisherHeatmap value, $Res Function(_SnPublisherHeatmap) _then) = __$SnPublisherHeatmapCopyWithImpl;
@override @useResult
$Res call({
 String unit,@JsonKey(name: 'period_start') DateTime periodStart,@JsonKey(name: 'period_end') DateTime periodEnd, List<SnHeatmapItem> items
});




}
/// @nodoc
class __$SnPublisherHeatmapCopyWithImpl<$Res>
    implements _$SnPublisherHeatmapCopyWith<$Res> {
  __$SnPublisherHeatmapCopyWithImpl(this._self, this._then);

  final _SnPublisherHeatmap _self;
  final $Res Function(_SnPublisherHeatmap) _then;

/// Create a copy of SnPublisherHeatmap
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unit = null,Object? periodStart = null,Object? periodEnd = null,Object? items = null,}) {
  return _then(_SnPublisherHeatmap(
unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SnHeatmapItem>,
  ));
}


}


/// @nodoc
mixin _$SnPublisherHeatmapItem {

 DateTime get date; int get count;
/// Create a copy of SnPublisherHeatmapItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPublisherHeatmapItemCopyWith<SnHeatmapItem> get copyWith => _$SnPublisherHeatmapItemCopyWithImpl<SnHeatmapItem>(this as SnHeatmapItem, _$identity);

  /// Serializes this SnPublisherHeatmapItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnHeatmapItem&&(identical(other.date, date) || other.date == date)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,count);

@override
String toString() {
  return 'SnPublisherHeatmapItem(date: $date, count: $count)';
}


}

/// @nodoc
abstract mixin class $SnPublisherHeatmapItemCopyWith<$Res>  {
  factory $SnPublisherHeatmapItemCopyWith(SnHeatmapItem value, $Res Function(SnHeatmapItem) _then) = _$SnPublisherHeatmapItemCopyWithImpl;
@useResult
$Res call({
 DateTime date, int count
});




}
/// @nodoc
class _$SnPublisherHeatmapItemCopyWithImpl<$Res>
    implements $SnPublisherHeatmapItemCopyWith<$Res> {
  _$SnPublisherHeatmapItemCopyWithImpl(this._self, this._then);

  final SnHeatmapItem _self;
  final $Res Function(SnHeatmapItem) _then;

/// Create a copy of SnPublisherHeatmapItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? count = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SnHeatmapItem].
extension SnPublisherHeatmapItemPatterns on SnHeatmapItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPublisherHeatmapItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPublisherHeatmapItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPublisherHeatmapItem value)  $default,){
final _that = this;
switch (_that) {
case _SnPublisherHeatmapItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPublisherHeatmapItem value)?  $default,){
final _that = this;
switch (_that) {
case _SnPublisherHeatmapItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPublisherHeatmapItem() when $default != null:
return $default(_that.date,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int count)  $default,) {final _that = this;
switch (_that) {
case _SnPublisherHeatmapItem():
return $default(_that.date,_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int count)?  $default,) {final _that = this;
switch (_that) {
case _SnPublisherHeatmapItem() when $default != null:
return $default(_that.date,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPublisherHeatmapItem implements SnHeatmapItem {
  const _SnPublisherHeatmapItem({required this.date, required this.count});
  factory _SnPublisherHeatmapItem.fromJson(Map<String, dynamic> json) => _$SnPublisherHeatmapItemFromJson(json);

@override final  DateTime date;
@override final  int count;

/// Create a copy of SnPublisherHeatmapItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPublisherHeatmapItemCopyWith<_SnPublisherHeatmapItem> get copyWith => __$SnPublisherHeatmapItemCopyWithImpl<_SnPublisherHeatmapItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPublisherHeatmapItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPublisherHeatmapItem&&(identical(other.date, date) || other.date == date)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,count);

@override
String toString() {
  return 'SnPublisherHeatmapItem(date: $date, count: $count)';
}


}

/// @nodoc
abstract mixin class _$SnPublisherHeatmapItemCopyWith<$Res> implements $SnPublisherHeatmapItemCopyWith<$Res> {
  factory _$SnPublisherHeatmapItemCopyWith(_SnPublisherHeatmapItem value, $Res Function(_SnPublisherHeatmapItem) _then) = __$SnPublisherHeatmapItemCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int count
});




}
/// @nodoc
class __$SnPublisherHeatmapItemCopyWithImpl<$Res>
    implements _$SnPublisherHeatmapItemCopyWith<$Res> {
  __$SnPublisherHeatmapItemCopyWithImpl(this._self, this._then);

  final _SnPublisherHeatmapItem _self;
  final $Res Function(_SnPublisherHeatmapItem) _then;

/// Create a copy of SnPublisherHeatmapItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? count = null,}) {
  return _then(_SnPublisherHeatmapItem(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
