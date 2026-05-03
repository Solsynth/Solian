// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_view_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageOperationResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageOperationResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageOperationResult()';
}


}

/// @nodoc
class $MessageOperationResultCopyWith<$Res>  {
$MessageOperationResultCopyWith(MessageOperationResult _, $Res Function(MessageOperationResult) __);
}


/// Adds pattern-matching-related methods to [MessageOperationResult].
extension MessageOperationResultPatterns on MessageOperationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Success value)?  success,TResult Function( _Failure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Success() when success != null:
return success(_that);case _Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Success value)  success,required TResult Function( _Failure value)  failure,}){
final _that = this;
switch (_that) {
case _Success():
return success(_that);case _Failure():
return failure(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Success value)?  success,TResult? Function( _Failure value)?  failure,}){
final _that = this;
switch (_that) {
case _Success() when success != null:
return success(_that);case _Failure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  success,TResult Function( String error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Success() when success != null:
return success();case _Failure() when failure != null:
return failure(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  success,required TResult Function( String error)  failure,}) {final _that = this;
switch (_that) {
case _Success():
return success();case _Failure():
return failure(_that.error);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  success,TResult? Function( String error)?  failure,}) {final _that = this;
switch (_that) {
case _Success() when success != null:
return success();case _Failure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _Success implements MessageOperationResult {
  const _Success();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageOperationResult.success()';
}


}




/// @nodoc


class _Failure implements MessageOperationResult {
  const _Failure(this.error);
  

 final  String error;

/// Create a copy of MessageOperationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailureCopyWith<_Failure> get copyWith => __$FailureCopyWithImpl<_Failure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Failure&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'MessageOperationResult.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class _$FailureCopyWith<$Res> implements $MessageOperationResultCopyWith<$Res> {
  factory _$FailureCopyWith(_Failure value, $Res Function(_Failure) _then) = __$FailureCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class __$FailureCopyWithImpl<$Res>
    implements _$FailureCopyWith<$Res> {
  __$FailureCopyWithImpl(this._self, this._then);

  final _Failure _self;
  final $Res Function(_Failure) _then;

/// Create a copy of MessageOperationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_Failure(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$MessageFilter {

 String? get searchQuery; bool? get withLinks; bool? get withAttachments;
/// Create a copy of MessageFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageFilterCopyWith<MessageFilter> get copyWith => _$MessageFilterCopyWithImpl<MessageFilter>(this as MessageFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.withLinks, withLinks) || other.withLinks == withLinks)&&(identical(other.withAttachments, withAttachments) || other.withAttachments == withAttachments));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,withLinks,withAttachments);

@override
String toString() {
  return 'MessageFilter(searchQuery: $searchQuery, withLinks: $withLinks, withAttachments: $withAttachments)';
}


}

/// @nodoc
abstract mixin class $MessageFilterCopyWith<$Res>  {
  factory $MessageFilterCopyWith(MessageFilter value, $Res Function(MessageFilter) _then) = _$MessageFilterCopyWithImpl;
@useResult
$Res call({
 String? searchQuery, bool? withLinks, bool? withAttachments
});




}
/// @nodoc
class _$MessageFilterCopyWithImpl<$Res>
    implements $MessageFilterCopyWith<$Res> {
  _$MessageFilterCopyWithImpl(this._self, this._then);

  final MessageFilter _self;
  final $Res Function(MessageFilter) _then;

/// Create a copy of MessageFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = freezed,Object? withLinks = freezed,Object? withAttachments = freezed,}) {
  return _then(_self.copyWith(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,withLinks: freezed == withLinks ? _self.withLinks : withLinks // ignore: cast_nullable_to_non_nullable
as bool?,withAttachments: freezed == withAttachments ? _self.withAttachments : withAttachments // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageFilter].
extension MessageFilterPatterns on MessageFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageFilter value)  $default,){
final _that = this;
switch (_that) {
case _MessageFilter():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageFilter value)?  $default,){
final _that = this;
switch (_that) {
case _MessageFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? searchQuery,  bool? withLinks,  bool? withAttachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageFilter() when $default != null:
return $default(_that.searchQuery,_that.withLinks,_that.withAttachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? searchQuery,  bool? withLinks,  bool? withAttachments)  $default,) {final _that = this;
switch (_that) {
case _MessageFilter():
return $default(_that.searchQuery,_that.withLinks,_that.withAttachments);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? searchQuery,  bool? withLinks,  bool? withAttachments)?  $default,) {final _that = this;
switch (_that) {
case _MessageFilter() when $default != null:
return $default(_that.searchQuery,_that.withLinks,_that.withAttachments);case _:
  return null;

}
}

}

/// @nodoc


class _MessageFilter extends MessageFilter {
  const _MessageFilter({this.searchQuery, this.withLinks, this.withAttachments}): super._();
  

@override final  String? searchQuery;
@override final  bool? withLinks;
@override final  bool? withAttachments;

/// Create a copy of MessageFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageFilterCopyWith<_MessageFilter> get copyWith => __$MessageFilterCopyWithImpl<_MessageFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.withLinks, withLinks) || other.withLinks == withLinks)&&(identical(other.withAttachments, withAttachments) || other.withAttachments == withAttachments));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,withLinks,withAttachments);

@override
String toString() {
  return 'MessageFilter(searchQuery: $searchQuery, withLinks: $withLinks, withAttachments: $withAttachments)';
}


}

/// @nodoc
abstract mixin class _$MessageFilterCopyWith<$Res> implements $MessageFilterCopyWith<$Res> {
  factory _$MessageFilterCopyWith(_MessageFilter value, $Res Function(_MessageFilter) _then) = __$MessageFilterCopyWithImpl;
@override @useResult
$Res call({
 String? searchQuery, bool? withLinks, bool? withAttachments
});




}
/// @nodoc
class __$MessageFilterCopyWithImpl<$Res>
    implements _$MessageFilterCopyWith<$Res> {
  __$MessageFilterCopyWithImpl(this._self, this._then);

  final _MessageFilter _self;
  final $Res Function(_MessageFilter) _then;

/// Create a copy of MessageFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = freezed,Object? withLinks = freezed,Object? withAttachments = freezed,}) {
  return _then(_MessageFilter(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,withLinks: freezed == withLinks ? _self.withLinks : withLinks // ignore: cast_nullable_to_non_nullable
as bool?,withAttachments: freezed == withAttachments ? _self.withAttachments : withAttachments // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

/// @nodoc
mixin _$PaginationState {

 int get loadedCount; bool get hasMore; int get totalCount; bool get allRemoteFetched;
/// Create a copy of PaginationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginationStateCopyWith<PaginationState> get copyWith => _$PaginationStateCopyWithImpl<PaginationState>(this as PaginationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginationState&&(identical(other.loadedCount, loadedCount) || other.loadedCount == loadedCount)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.allRemoteFetched, allRemoteFetched) || other.allRemoteFetched == allRemoteFetched));
}


@override
int get hashCode => Object.hash(runtimeType,loadedCount,hasMore,totalCount,allRemoteFetched);

@override
String toString() {
  return 'PaginationState(loadedCount: $loadedCount, hasMore: $hasMore, totalCount: $totalCount, allRemoteFetched: $allRemoteFetched)';
}


}

/// @nodoc
abstract mixin class $PaginationStateCopyWith<$Res>  {
  factory $PaginationStateCopyWith(PaginationState value, $Res Function(PaginationState) _then) = _$PaginationStateCopyWithImpl;
@useResult
$Res call({
 int loadedCount, bool hasMore, int totalCount, bool allRemoteFetched
});




}
/// @nodoc
class _$PaginationStateCopyWithImpl<$Res>
    implements $PaginationStateCopyWith<$Res> {
  _$PaginationStateCopyWithImpl(this._self, this._then);

  final PaginationState _self;
  final $Res Function(PaginationState) _then;

/// Create a copy of PaginationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? loadedCount = null,Object? hasMore = null,Object? totalCount = null,Object? allRemoteFetched = null,}) {
  return _then(_self.copyWith(
loadedCount: null == loadedCount ? _self.loadedCount : loadedCount // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,allRemoteFetched: null == allRemoteFetched ? _self.allRemoteFetched : allRemoteFetched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginationState].
extension PaginationStatePatterns on PaginationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginationState value)  $default,){
final _that = this;
switch (_that) {
case _PaginationState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginationState value)?  $default,){
final _that = this;
switch (_that) {
case _PaginationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int loadedCount,  bool hasMore,  int totalCount,  bool allRemoteFetched)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginationState() when $default != null:
return $default(_that.loadedCount,_that.hasMore,_that.totalCount,_that.allRemoteFetched);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int loadedCount,  bool hasMore,  int totalCount,  bool allRemoteFetched)  $default,) {final _that = this;
switch (_that) {
case _PaginationState():
return $default(_that.loadedCount,_that.hasMore,_that.totalCount,_that.allRemoteFetched);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int loadedCount,  bool hasMore,  int totalCount,  bool allRemoteFetched)?  $default,) {final _that = this;
switch (_that) {
case _PaginationState() when $default != null:
return $default(_that.loadedCount,_that.hasMore,_that.totalCount,_that.allRemoteFetched);case _:
  return null;

}
}

}

/// @nodoc


class _PaginationState implements PaginationState {
  const _PaginationState({this.loadedCount = 0, this.hasMore = true, this.totalCount = 0, this.allRemoteFetched = false});
  

@override@JsonKey() final  int loadedCount;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  int totalCount;
@override@JsonKey() final  bool allRemoteFetched;

/// Create a copy of PaginationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginationStateCopyWith<_PaginationState> get copyWith => __$PaginationStateCopyWithImpl<_PaginationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginationState&&(identical(other.loadedCount, loadedCount) || other.loadedCount == loadedCount)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.allRemoteFetched, allRemoteFetched) || other.allRemoteFetched == allRemoteFetched));
}


@override
int get hashCode => Object.hash(runtimeType,loadedCount,hasMore,totalCount,allRemoteFetched);

@override
String toString() {
  return 'PaginationState(loadedCount: $loadedCount, hasMore: $hasMore, totalCount: $totalCount, allRemoteFetched: $allRemoteFetched)';
}


}

/// @nodoc
abstract mixin class _$PaginationStateCopyWith<$Res> implements $PaginationStateCopyWith<$Res> {
  factory _$PaginationStateCopyWith(_PaginationState value, $Res Function(_PaginationState) _then) = __$PaginationStateCopyWithImpl;
@override @useResult
$Res call({
 int loadedCount, bool hasMore, int totalCount, bool allRemoteFetched
});




}
/// @nodoc
class __$PaginationStateCopyWithImpl<$Res>
    implements _$PaginationStateCopyWith<$Res> {
  __$PaginationStateCopyWithImpl(this._self, this._then);

  final _PaginationState _self;
  final $Res Function(_PaginationState) _then;

/// Create a copy of PaginationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? loadedCount = null,Object? hasMore = null,Object? totalCount = null,Object? allRemoteFetched = null,}) {
  return _then(_PaginationState(
loadedCount: null == loadedCount ? _self.loadedCount : loadedCount // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,allRemoteFetched: null == allRemoteFetched ? _self.allRemoteFetched : allRemoteFetched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
