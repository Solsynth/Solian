// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compose.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostComposeInitialState {

 String? get title; String? get description; String? get content; List<UniversalFile> get attachments; int? get visibility;
/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostComposeInitialStateCopyWith<PostComposeInitialState> get copyWith => _$PostComposeInitialStateCopyWithImpl<PostComposeInitialState>(this as PostComposeInitialState, _$identity);

  /// Serializes this PostComposeInitialState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostComposeInitialState&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,content,const DeepCollectionEquality().hash(attachments),visibility);

@override
String toString() {
  return 'PostComposeInitialState(title: $title, description: $description, content: $content, attachments: $attachments, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class $PostComposeInitialStateCopyWith<$Res>  {
  factory $PostComposeInitialStateCopyWith(PostComposeInitialState value, $Res Function(PostComposeInitialState) _then) = _$PostComposeInitialStateCopyWithImpl;
@useResult
$Res call({
 String? title, String? description, String? content, List<UniversalFile> attachments, int? visibility
});




}
/// @nodoc
class _$PostComposeInitialStateCopyWithImpl<$Res>
    implements $PostComposeInitialStateCopyWith<$Res> {
  _$PostComposeInitialStateCopyWithImpl(this._self, this._then);

  final PostComposeInitialState _self;
  final $Res Function(PostComposeInitialState) _then;

/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? description = freezed,Object? content = freezed,Object? attachments = null,Object? visibility = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<UniversalFile>,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PostComposeInitialState implements PostComposeInitialState {
  const _PostComposeInitialState({this.title, this.description, this.content, final  List<UniversalFile> attachments = const [], this.visibility}): _attachments = attachments;
  factory _PostComposeInitialState.fromJson(Map<String, dynamic> json) => _$PostComposeInitialStateFromJson(json);

@override final  String? title;
@override final  String? description;
@override final  String? content;
 final  List<UniversalFile> _attachments;
@override@JsonKey() List<UniversalFile> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override final  int? visibility;

/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostComposeInitialStateCopyWith<_PostComposeInitialState> get copyWith => __$PostComposeInitialStateCopyWithImpl<_PostComposeInitialState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostComposeInitialStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostComposeInitialState&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.visibility, visibility) || other.visibility == visibility));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,content,const DeepCollectionEquality().hash(_attachments),visibility);

@override
String toString() {
  return 'PostComposeInitialState(title: $title, description: $description, content: $content, attachments: $attachments, visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class _$PostComposeInitialStateCopyWith<$Res> implements $PostComposeInitialStateCopyWith<$Res> {
  factory _$PostComposeInitialStateCopyWith(_PostComposeInitialState value, $Res Function(_PostComposeInitialState) _then) = __$PostComposeInitialStateCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? description, String? content, List<UniversalFile> attachments, int? visibility
});




}
/// @nodoc
class __$PostComposeInitialStateCopyWithImpl<$Res>
    implements _$PostComposeInitialStateCopyWith<$Res> {
  __$PostComposeInitialStateCopyWithImpl(this._self, this._then);

  final _PostComposeInitialState _self;
  final $Res Function(_PostComposeInitialState) _then;

/// Create a copy of PostComposeInitialState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? description = freezed,Object? content = freezed,Object? attachments = null,Object? visibility = freezed,}) {
  return _then(_PostComposeInitialState(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<UniversalFile>,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
