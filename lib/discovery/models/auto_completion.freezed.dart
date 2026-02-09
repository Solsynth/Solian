// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_completion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
AutoCompletionResponse _$AutoCompletionResponseFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'account':
          return AutoCompletionAccountResponse.fromJson(
            json
          );
                case 'sticker':
          return AutoCompletionStickerResponse.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'AutoCompletionResponse',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$AutoCompletionResponse {

 String get type; List<AutoCompletionItem> get items;
/// Create a copy of AutoCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoCompletionResponseCopyWith<AutoCompletionResponse> get copyWith => _$AutoCompletionResponseCopyWithImpl<AutoCompletionResponse>(this as AutoCompletionResponse, _$identity);

  /// Serializes this AutoCompletionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoCompletionResponse&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'AutoCompletionResponse(type: $type, items: $items)';
}


}

/// @nodoc
abstract mixin class $AutoCompletionResponseCopyWith<$Res>  {
  factory $AutoCompletionResponseCopyWith(AutoCompletionResponse value, $Res Function(AutoCompletionResponse) _then) = _$AutoCompletionResponseCopyWithImpl;
@useResult
$Res call({
 String type, List<AutoCompletionItem> items
});




}
/// @nodoc
class _$AutoCompletionResponseCopyWithImpl<$Res>
    implements $AutoCompletionResponseCopyWith<$Res> {
  _$AutoCompletionResponseCopyWithImpl(this._self, this._then);

  final AutoCompletionResponse _self;
  final $Res Function(AutoCompletionResponse) _then;

/// Create a copy of AutoCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? items = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<AutoCompletionItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoCompletionResponse].
extension AutoCompletionResponsePatterns on AutoCompletionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AutoCompletionAccountResponse value)?  account,TResult Function( AutoCompletionStickerResponse value)?  sticker,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AutoCompletionAccountResponse() when account != null:
return account(_that);case AutoCompletionStickerResponse() when sticker != null:
return sticker(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AutoCompletionAccountResponse value)  account,required TResult Function( AutoCompletionStickerResponse value)  sticker,}){
final _that = this;
switch (_that) {
case AutoCompletionAccountResponse():
return account(_that);case AutoCompletionStickerResponse():
return sticker(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AutoCompletionAccountResponse value)?  account,TResult? Function( AutoCompletionStickerResponse value)?  sticker,}){
final _that = this;
switch (_that) {
case AutoCompletionAccountResponse() when account != null:
return account(_that);case AutoCompletionStickerResponse() when sticker != null:
return sticker(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String type,  List<AutoCompletionItem> items)?  account,TResult Function( String type,  List<AutoCompletionItem> items)?  sticker,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AutoCompletionAccountResponse() when account != null:
return account(_that.type,_that.items);case AutoCompletionStickerResponse() when sticker != null:
return sticker(_that.type,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String type,  List<AutoCompletionItem> items)  account,required TResult Function( String type,  List<AutoCompletionItem> items)  sticker,}) {final _that = this;
switch (_that) {
case AutoCompletionAccountResponse():
return account(_that.type,_that.items);case AutoCompletionStickerResponse():
return sticker(_that.type,_that.items);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String type,  List<AutoCompletionItem> items)?  account,TResult? Function( String type,  List<AutoCompletionItem> items)?  sticker,}) {final _that = this;
switch (_that) {
case AutoCompletionAccountResponse() when account != null:
return account(_that.type,_that.items);case AutoCompletionStickerResponse() when sticker != null:
return sticker(_that.type,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class AutoCompletionAccountResponse implements AutoCompletionResponse {
  const AutoCompletionAccountResponse({required this.type, required final  List<AutoCompletionItem> items, final  String? $type}): _items = items,$type = $type ?? 'account';
  factory AutoCompletionAccountResponse.fromJson(Map<String, dynamic> json) => _$AutoCompletionAccountResponseFromJson(json);

@override final  String type;
 final  List<AutoCompletionItem> _items;
@override List<AutoCompletionItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of AutoCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoCompletionAccountResponseCopyWith<AutoCompletionAccountResponse> get copyWith => _$AutoCompletionAccountResponseCopyWithImpl<AutoCompletionAccountResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutoCompletionAccountResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoCompletionAccountResponse&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'AutoCompletionResponse.account(type: $type, items: $items)';
}


}

/// @nodoc
abstract mixin class $AutoCompletionAccountResponseCopyWith<$Res> implements $AutoCompletionResponseCopyWith<$Res> {
  factory $AutoCompletionAccountResponseCopyWith(AutoCompletionAccountResponse value, $Res Function(AutoCompletionAccountResponse) _then) = _$AutoCompletionAccountResponseCopyWithImpl;
@override @useResult
$Res call({
 String type, List<AutoCompletionItem> items
});




}
/// @nodoc
class _$AutoCompletionAccountResponseCopyWithImpl<$Res>
    implements $AutoCompletionAccountResponseCopyWith<$Res> {
  _$AutoCompletionAccountResponseCopyWithImpl(this._self, this._then);

  final AutoCompletionAccountResponse _self;
  final $Res Function(AutoCompletionAccountResponse) _then;

/// Create a copy of AutoCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? items = null,}) {
  return _then(AutoCompletionAccountResponse(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AutoCompletionItem>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class AutoCompletionStickerResponse implements AutoCompletionResponse {
  const AutoCompletionStickerResponse({required this.type, required final  List<AutoCompletionItem> items, final  String? $type}): _items = items,$type = $type ?? 'sticker';
  factory AutoCompletionStickerResponse.fromJson(Map<String, dynamic> json) => _$AutoCompletionStickerResponseFromJson(json);

@override final  String type;
 final  List<AutoCompletionItem> _items;
@override List<AutoCompletionItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of AutoCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoCompletionStickerResponseCopyWith<AutoCompletionStickerResponse> get copyWith => _$AutoCompletionStickerResponseCopyWithImpl<AutoCompletionStickerResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutoCompletionStickerResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoCompletionStickerResponse&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'AutoCompletionResponse.sticker(type: $type, items: $items)';
}


}

/// @nodoc
abstract mixin class $AutoCompletionStickerResponseCopyWith<$Res> implements $AutoCompletionResponseCopyWith<$Res> {
  factory $AutoCompletionStickerResponseCopyWith(AutoCompletionStickerResponse value, $Res Function(AutoCompletionStickerResponse) _then) = _$AutoCompletionStickerResponseCopyWithImpl;
@override @useResult
$Res call({
 String type, List<AutoCompletionItem> items
});




}
/// @nodoc
class _$AutoCompletionStickerResponseCopyWithImpl<$Res>
    implements $AutoCompletionStickerResponseCopyWith<$Res> {
  _$AutoCompletionStickerResponseCopyWithImpl(this._self, this._then);

  final AutoCompletionStickerResponse _self;
  final $Res Function(AutoCompletionStickerResponse) _then;

/// Create a copy of AutoCompletionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? items = null,}) {
  return _then(AutoCompletionStickerResponse(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<AutoCompletionItem>,
  ));
}


}


/// @nodoc
mixin _$AutoCompletionItem {

 String get id; String get displayName; String? get secondaryText; String get type; dynamic get data;
/// Create a copy of AutoCompletionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutoCompletionItemCopyWith<AutoCompletionItem> get copyWith => _$AutoCompletionItemCopyWithImpl<AutoCompletionItem>(this as AutoCompletionItem, _$identity);

  /// Serializes this AutoCompletionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutoCompletionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.secondaryText, secondaryText) || other.secondaryText == secondaryText)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,secondaryText,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AutoCompletionItem(id: $id, displayName: $displayName, secondaryText: $secondaryText, type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class $AutoCompletionItemCopyWith<$Res>  {
  factory $AutoCompletionItemCopyWith(AutoCompletionItem value, $Res Function(AutoCompletionItem) _then) = _$AutoCompletionItemCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String? secondaryText, String type, dynamic data
});




}
/// @nodoc
class _$AutoCompletionItemCopyWithImpl<$Res>
    implements $AutoCompletionItemCopyWith<$Res> {
  _$AutoCompletionItemCopyWithImpl(this._self, this._then);

  final AutoCompletionItem _self;
  final $Res Function(AutoCompletionItem) _then;

/// Create a copy of AutoCompletionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? secondaryText = freezed,Object? type = null,Object? data = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,secondaryText: freezed == secondaryText ? _self.secondaryText : secondaryText // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [AutoCompletionItem].
extension AutoCompletionItemPatterns on AutoCompletionItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutoCompletionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutoCompletionItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutoCompletionItem value)  $default,){
final _that = this;
switch (_that) {
case _AutoCompletionItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutoCompletionItem value)?  $default,){
final _that = this;
switch (_that) {
case _AutoCompletionItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String? secondaryText,  String type,  dynamic data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutoCompletionItem() when $default != null:
return $default(_that.id,_that.displayName,_that.secondaryText,_that.type,_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String? secondaryText,  String type,  dynamic data)  $default,) {final _that = this;
switch (_that) {
case _AutoCompletionItem():
return $default(_that.id,_that.displayName,_that.secondaryText,_that.type,_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String? secondaryText,  String type,  dynamic data)?  $default,) {final _that = this;
switch (_that) {
case _AutoCompletionItem() when $default != null:
return $default(_that.id,_that.displayName,_that.secondaryText,_that.type,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AutoCompletionItem implements AutoCompletionItem {
  const _AutoCompletionItem({required this.id, required this.displayName, required this.secondaryText, required this.type, required this.data});
  factory _AutoCompletionItem.fromJson(Map<String, dynamic> json) => _$AutoCompletionItemFromJson(json);

@override final  String id;
@override final  String displayName;
@override final  String? secondaryText;
@override final  String type;
@override final  dynamic data;

/// Create a copy of AutoCompletionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutoCompletionItemCopyWith<_AutoCompletionItem> get copyWith => __$AutoCompletionItemCopyWithImpl<_AutoCompletionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutoCompletionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutoCompletionItem&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.secondaryText, secondaryText) || other.secondaryText == secondaryText)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,secondaryText,type,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'AutoCompletionItem(id: $id, displayName: $displayName, secondaryText: $secondaryText, type: $type, data: $data)';
}


}

/// @nodoc
abstract mixin class _$AutoCompletionItemCopyWith<$Res> implements $AutoCompletionItemCopyWith<$Res> {
  factory _$AutoCompletionItemCopyWith(_AutoCompletionItem value, $Res Function(_AutoCompletionItem) _then) = __$AutoCompletionItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String? secondaryText, String type, dynamic data
});




}
/// @nodoc
class __$AutoCompletionItemCopyWithImpl<$Res>
    implements _$AutoCompletionItemCopyWith<$Res> {
  __$AutoCompletionItemCopyWithImpl(this._self, this._then);

  final _AutoCompletionItem _self;
  final $Res Function(_AutoCompletionItem) _then;

/// Create a copy of AutoCompletionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? secondaryText = freezed,Object? type = null,Object? data = freezed,}) {
  return _then(_AutoCompletionItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,secondaryText: freezed == secondaryText ? _self.secondaryText : secondaryText // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
