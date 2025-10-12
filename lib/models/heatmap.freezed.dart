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
mixin _$SnHeatmap {

 String get unit;@JsonKey(name: 'period_start') DateTime get periodStart;@JsonKey(name: 'period_end') DateTime get periodEnd; List<SnHeatmapItem> get items;
/// Create a copy of SnHeatmap
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnHeatmapCopyWith<SnHeatmap> get copyWith => _$SnHeatmapCopyWithImpl<SnHeatmap>(this as SnHeatmap, _$identity);

  /// Serializes this SnHeatmap to a JSON map.
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
  return 'SnHeatmap(unit: $unit, periodStart: $periodStart, periodEnd: $periodEnd, items: $items)';
}


}

/// @nodoc
abstract mixin class $SnHeatmapCopyWith<$Res>  {
  factory $SnHeatmapCopyWith(SnHeatmap value, $Res Function(SnHeatmap) _then) = _$SnHeatmapCopyWithImpl;
@useResult
$Res call({
 String unit,@JsonKey(name: 'period_start') DateTime periodStart,@JsonKey(name: 'period_end') DateTime periodEnd, List<SnHeatmapItem> items
});




}
/// @nodoc
class _$SnHeatmapCopyWithImpl<$Res>
    implements $SnHeatmapCopyWith<$Res> {
  _$SnHeatmapCopyWithImpl(this._self, this._then);

  final SnHeatmap _self;
  final $Res Function(SnHeatmap) _then;

/// Create a copy of SnHeatmap
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
extension SnHeatmapPatterns on SnHeatmap {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnHeatmap value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnHeatmap() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnHeatmap value)  $default,){
final _that = this;
switch (_that) {
case _SnHeatmap():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnHeatmap value)?  $default,){
final _that = this;
switch (_that) {
case _SnHeatmap() when $default != null:
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
case _SnHeatmap() when $default != null:
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
case _SnHeatmap():
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
case _SnHeatmap() when $default != null:
return $default(_that.unit,_that.periodStart,_that.periodEnd,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnHeatmap implements SnHeatmap {
  const _SnHeatmap({required this.unit, @JsonKey(name: 'period_start') required this.periodStart, @JsonKey(name: 'period_end') required this.periodEnd, required final  List<SnHeatmapItem> items}): _items = items;
  factory _SnHeatmap.fromJson(Map<String, dynamic> json) => _$SnHeatmapFromJson(json);

@override final  String unit;
@override@JsonKey(name: 'period_start') final  DateTime periodStart;
@override@JsonKey(name: 'period_end') final  DateTime periodEnd;
 final  List<SnHeatmapItem> _items;
@override List<SnHeatmapItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of SnHeatmap
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnHeatmapCopyWith<_SnHeatmap> get copyWith => __$SnHeatmapCopyWithImpl<_SnHeatmap>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnHeatmapToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnHeatmap&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&(identical(other.periodEnd, periodEnd) || other.periodEnd == periodEnd)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,unit,periodStart,periodEnd,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'SnHeatmap(unit: $unit, periodStart: $periodStart, periodEnd: $periodEnd, items: $items)';
}


}

/// @nodoc
abstract mixin class _$SnHeatmapCopyWith<$Res> implements $SnHeatmapCopyWith<$Res> {
  factory _$SnHeatmapCopyWith(_SnHeatmap value, $Res Function(_SnHeatmap) _then) = __$SnHeatmapCopyWithImpl;
@override @useResult
$Res call({
 String unit,@JsonKey(name: 'period_start') DateTime periodStart,@JsonKey(name: 'period_end') DateTime periodEnd, List<SnHeatmapItem> items
});




}
/// @nodoc
class __$SnHeatmapCopyWithImpl<$Res>
    implements _$SnHeatmapCopyWith<$Res> {
  __$SnHeatmapCopyWithImpl(this._self, this._then);

  final _SnHeatmap _self;
  final $Res Function(_SnHeatmap) _then;

/// Create a copy of SnHeatmap
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unit = null,Object? periodStart = null,Object? periodEnd = null,Object? items = null,}) {
  return _then(_SnHeatmap(
unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as DateTime,periodEnd: null == periodEnd ? _self.periodEnd : periodEnd // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SnHeatmapItem>,
  ));
}


}


/// @nodoc
mixin _$SnHeatmapItem {

 DateTime get date; int get count;
/// Create a copy of SnHeatmapItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnHeatmapItemCopyWith<SnHeatmapItem> get copyWith => _$SnHeatmapItemCopyWithImpl<SnHeatmapItem>(this as SnHeatmapItem, _$identity);

  /// Serializes this SnHeatmapItem to a JSON map.
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
  return 'SnHeatmapItem(date: $date, count: $count)';
}


}

/// @nodoc
abstract mixin class $SnHeatmapItemCopyWith<$Res>  {
  factory $SnHeatmapItemCopyWith(SnHeatmapItem value, $Res Function(SnHeatmapItem) _then) = _$SnHeatmapItemCopyWithImpl;
@useResult
$Res call({
 DateTime date, int count
});




}
/// @nodoc
class _$SnHeatmapItemCopyWithImpl<$Res>
    implements $SnHeatmapItemCopyWith<$Res> {
  _$SnHeatmapItemCopyWithImpl(this._self, this._then);

  final SnHeatmapItem _self;
  final $Res Function(SnHeatmapItem) _then;

/// Create a copy of SnHeatmapItem
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
extension SnHeatmapItemPatterns on SnHeatmapItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnHeatmapItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnHeatmapItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnHeatmapItem value)  $default,){
final _that = this;
switch (_that) {
case _SnHeatmapItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnHeatmapItem value)?  $default,){
final _that = this;
switch (_that) {
case _SnHeatmapItem() when $default != null:
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
case _SnHeatmapItem() when $default != null:
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
case _SnHeatmapItem():
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
case _SnHeatmapItem() when $default != null:
return $default(_that.date,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnHeatmapItem implements SnHeatmapItem {
  const _SnHeatmapItem({required this.date, required this.count});
  factory _SnHeatmapItem.fromJson(Map<String, dynamic> json) => _$SnHeatmapItemFromJson(json);

@override final  DateTime date;
@override final  int count;

/// Create a copy of SnHeatmapItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnHeatmapItemCopyWith<_SnHeatmapItem> get copyWith => __$SnHeatmapItemCopyWithImpl<_SnHeatmapItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnHeatmapItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnHeatmapItem&&(identical(other.date, date) || other.date == date)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,count);

@override
String toString() {
  return 'SnHeatmapItem(date: $date, count: $count)';
}


}

/// @nodoc
abstract mixin class _$SnHeatmapItemCopyWith<$Res> implements $SnHeatmapItemCopyWith<$Res> {
  factory _$SnHeatmapItemCopyWith(_SnHeatmapItem value, $Res Function(_SnHeatmapItem) _then) = __$SnHeatmapItemCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int count
});




}
/// @nodoc
class __$SnHeatmapItemCopyWithImpl<$Res>
    implements _$SnHeatmapItemCopyWith<$Res> {
  __$SnHeatmapItemCopyWithImpl(this._self, this._then);

  final _SnHeatmapItem _self;
  final $Res Function(_SnHeatmapItem) _then;

/// Create a copy of SnHeatmapItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? count = null,}) {
  return _then(_SnHeatmapItem(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
