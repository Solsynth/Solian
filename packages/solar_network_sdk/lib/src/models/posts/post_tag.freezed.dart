// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPostTag {

 String get id; String get slug; String? get name; String? get description;@JsonKey(name: 'owner_publisher_id') String? get ownerPublisherId;@JsonKey(name: 'owner_publisher') SnPublisher? get ownerPublisher;@JsonKey(name: 'is_protected') bool get isProtected;@JsonKey(name: 'is_event') bool get isEvent;@JsonKey(name: 'event_ends_at') DateTime? get eventEndsAt;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt; List<SnPost> get posts; int get usage;
/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SnPostTagCopyWith<SnPostTag> get copyWith => _$SnPostTagCopyWithImpl<SnPostTag>(this as SnPostTag, _$identity);

  /// Serializes this SnPostTag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SnPostTag&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerPublisherId, ownerPublisherId) || other.ownerPublisherId == ownerPublisherId)&&(identical(other.ownerPublisher, ownerPublisher) || other.ownerPublisher == ownerPublisher)&&(identical(other.isProtected, isProtected) || other.isProtected == isProtected)&&(identical(other.isEvent, isEvent) || other.isEvent == isEvent)&&(identical(other.eventEndsAt, eventEndsAt) || other.eventEndsAt == eventEndsAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.posts, posts)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,ownerPublisherId,ownerPublisher,isProtected,isEvent,eventEndsAt,createdAt,updatedAt,const DeepCollectionEquality().hash(posts),usage);

@override
String toString() {
  return 'SnPostTag(id: $id, slug: $slug, name: $name, description: $description, ownerPublisherId: $ownerPublisherId, ownerPublisher: $ownerPublisher, isProtected: $isProtected, isEvent: $isEvent, eventEndsAt: $eventEndsAt, createdAt: $createdAt, updatedAt: $updatedAt, posts: $posts, usage: $usage)';
}


}

/// @nodoc
abstract mixin class $SnPostTagCopyWith<$Res>  {
  factory $SnPostTagCopyWith(SnPostTag value, $Res Function(SnPostTag) _then) = _$SnPostTagCopyWithImpl;
@useResult
$Res call({
 String id, String slug, String? name, String? description,@JsonKey(name: 'owner_publisher_id') String? ownerPublisherId,@JsonKey(name: 'owner_publisher') SnPublisher? ownerPublisher,@JsonKey(name: 'is_protected') bool isProtected,@JsonKey(name: 'is_event') bool isEvent,@JsonKey(name: 'event_ends_at') DateTime? eventEndsAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<SnPost> posts, int usage
});


$SnPublisherCopyWith<$Res>? get ownerPublisher;

}
/// @nodoc
class _$SnPostTagCopyWithImpl<$Res>
    implements $SnPostTagCopyWith<$Res> {
  _$SnPostTagCopyWithImpl(this._self, this._then);

  final SnPostTag _self;
  final $Res Function(SnPostTag) _then;

/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? description = freezed,Object? ownerPublisherId = freezed,Object? ownerPublisher = freezed,Object? isProtected = null,Object? isEvent = null,Object? eventEndsAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? posts = null,Object? usage = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,ownerPublisherId: freezed == ownerPublisherId ? _self.ownerPublisherId : ownerPublisherId // ignore: cast_nullable_to_non_nullable
as String?,ownerPublisher: freezed == ownerPublisher ? _self.ownerPublisher : ownerPublisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,isProtected: null == isProtected ? _self.isProtected : isProtected // ignore: cast_nullable_to_non_nullable
as bool,isEvent: null == isEvent ? _self.isEvent : isEvent // ignore: cast_nullable_to_non_nullable
as bool,eventEndsAt: freezed == eventEndsAt ? _self.eventEndsAt : eventEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<SnPost>,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get ownerPublisher {
    if (_self.ownerPublisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.ownerPublisher!, (value) {
    return _then(_self.copyWith(ownerPublisher: value));
  });
}
}


/// Adds pattern-matching-related methods to [SnPostTag].
extension SnPostTagPatterns on SnPostTag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SnPostTag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SnPostTag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SnPostTag value)  $default,){
final _that = this;
switch (_that) {
case _SnPostTag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SnPostTag value)?  $default,){
final _that = this;
switch (_that) {
case _SnPostTag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  String? description, @JsonKey(name: 'owner_publisher_id')  String? ownerPublisherId, @JsonKey(name: 'owner_publisher')  SnPublisher? ownerPublisher, @JsonKey(name: 'is_protected')  bool isProtected, @JsonKey(name: 'is_event')  bool isEvent, @JsonKey(name: 'event_ends_at')  DateTime? eventEndsAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<SnPost> posts,  int usage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SnPostTag() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.ownerPublisherId,_that.ownerPublisher,_that.isProtected,_that.isEvent,_that.eventEndsAt,_that.createdAt,_that.updatedAt,_that.posts,_that.usage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String slug,  String? name,  String? description, @JsonKey(name: 'owner_publisher_id')  String? ownerPublisherId, @JsonKey(name: 'owner_publisher')  SnPublisher? ownerPublisher, @JsonKey(name: 'is_protected')  bool isProtected, @JsonKey(name: 'is_event')  bool isEvent, @JsonKey(name: 'event_ends_at')  DateTime? eventEndsAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<SnPost> posts,  int usage)  $default,) {final _that = this;
switch (_that) {
case _SnPostTag():
return $default(_that.id,_that.slug,_that.name,_that.description,_that.ownerPublisherId,_that.ownerPublisher,_that.isProtected,_that.isEvent,_that.eventEndsAt,_that.createdAt,_that.updatedAt,_that.posts,_that.usage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String slug,  String? name,  String? description, @JsonKey(name: 'owner_publisher_id')  String? ownerPublisherId, @JsonKey(name: 'owner_publisher')  SnPublisher? ownerPublisher, @JsonKey(name: 'is_protected')  bool isProtected, @JsonKey(name: 'is_event')  bool isEvent, @JsonKey(name: 'event_ends_at')  DateTime? eventEndsAt, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt,  List<SnPost> posts,  int usage)?  $default,) {final _that = this;
switch (_that) {
case _SnPostTag() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.description,_that.ownerPublisherId,_that.ownerPublisher,_that.isProtected,_that.isEvent,_that.eventEndsAt,_that.createdAt,_that.updatedAt,_that.posts,_that.usage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SnPostTag extends SnPostTag {
  const _SnPostTag({required this.id, required this.slug, this.name, this.description, @JsonKey(name: 'owner_publisher_id') this.ownerPublisherId, @JsonKey(name: 'owner_publisher') this.ownerPublisher, @JsonKey(name: 'is_protected') this.isProtected = false, @JsonKey(name: 'is_event') this.isEvent = false, @JsonKey(name: 'event_ends_at') this.eventEndsAt, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, final  List<SnPost> posts = const [], this.usage = 0}): _posts = posts,super._();
  factory _SnPostTag.fromJson(Map<String, dynamic> json) => _$SnPostTagFromJson(json);

@override final  String id;
@override final  String slug;
@override final  String? name;
@override final  String? description;
@override@JsonKey(name: 'owner_publisher_id') final  String? ownerPublisherId;
@override@JsonKey(name: 'owner_publisher') final  SnPublisher? ownerPublisher;
@override@JsonKey(name: 'is_protected') final  bool isProtected;
@override@JsonKey(name: 'is_event') final  bool isEvent;
@override@JsonKey(name: 'event_ends_at') final  DateTime? eventEndsAt;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;
 final  List<SnPost> _posts;
@override@JsonKey() List<SnPost> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

@override@JsonKey() final  int usage;

/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SnPostTagCopyWith<_SnPostTag> get copyWith => __$SnPostTagCopyWithImpl<_SnPostTag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SnPostTagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SnPostTag&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerPublisherId, ownerPublisherId) || other.ownerPublisherId == ownerPublisherId)&&(identical(other.ownerPublisher, ownerPublisher) || other.ownerPublisher == ownerPublisher)&&(identical(other.isProtected, isProtected) || other.isProtected == isProtected)&&(identical(other.isEvent, isEvent) || other.isEvent == isEvent)&&(identical(other.eventEndsAt, eventEndsAt) || other.eventEndsAt == eventEndsAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._posts, _posts)&&(identical(other.usage, usage) || other.usage == usage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,description,ownerPublisherId,ownerPublisher,isProtected,isEvent,eventEndsAt,createdAt,updatedAt,const DeepCollectionEquality().hash(_posts),usage);

@override
String toString() {
  return 'SnPostTag(id: $id, slug: $slug, name: $name, description: $description, ownerPublisherId: $ownerPublisherId, ownerPublisher: $ownerPublisher, isProtected: $isProtected, isEvent: $isEvent, eventEndsAt: $eventEndsAt, createdAt: $createdAt, updatedAt: $updatedAt, posts: $posts, usage: $usage)';
}


}

/// @nodoc
abstract mixin class _$SnPostTagCopyWith<$Res> implements $SnPostTagCopyWith<$Res> {
  factory _$SnPostTagCopyWith(_SnPostTag value, $Res Function(_SnPostTag) _then) = __$SnPostTagCopyWithImpl;
@override @useResult
$Res call({
 String id, String slug, String? name, String? description,@JsonKey(name: 'owner_publisher_id') String? ownerPublisherId,@JsonKey(name: 'owner_publisher') SnPublisher? ownerPublisher,@JsonKey(name: 'is_protected') bool isProtected,@JsonKey(name: 'is_event') bool isEvent,@JsonKey(name: 'event_ends_at') DateTime? eventEndsAt,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt, List<SnPost> posts, int usage
});


@override $SnPublisherCopyWith<$Res>? get ownerPublisher;

}
/// @nodoc
class __$SnPostTagCopyWithImpl<$Res>
    implements _$SnPostTagCopyWith<$Res> {
  __$SnPostTagCopyWithImpl(this._self, this._then);

  final _SnPostTag _self;
  final $Res Function(_SnPostTag) _then;

/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = null,Object? name = freezed,Object? description = freezed,Object? ownerPublisherId = freezed,Object? ownerPublisher = freezed,Object? isProtected = null,Object? isEvent = null,Object? eventEndsAt = freezed,Object? createdAt = null,Object? updatedAt = null,Object? posts = null,Object? usage = null,}) {
  return _then(_SnPostTag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,ownerPublisherId: freezed == ownerPublisherId ? _self.ownerPublisherId : ownerPublisherId // ignore: cast_nullable_to_non_nullable
as String?,ownerPublisher: freezed == ownerPublisher ? _self.ownerPublisher : ownerPublisher // ignore: cast_nullable_to_non_nullable
as SnPublisher?,isProtected: null == isProtected ? _self.isProtected : isProtected // ignore: cast_nullable_to_non_nullable
as bool,isEvent: null == isEvent ? _self.isEvent : isEvent // ignore: cast_nullable_to_non_nullable
as bool,eventEndsAt: freezed == eventEndsAt ? _self.eventEndsAt : eventEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<SnPost>,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SnPostTag
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnPublisherCopyWith<$Res>? get ownerPublisher {
    if (_self.ownerPublisher == null) {
    return null;
  }

  return $SnPublisherCopyWith<$Res>(_self.ownerPublisher!, (value) {
    return _then(_self.copyWith(ownerPublisher: value));
  });
}
}

// dart format on
