// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatRoomMemberState {

 List<SnChatMember> get members; bool get isLoading; int get total; String? get error;
/// Create a copy of ChatRoomMemberState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatRoomMemberStateCopyWith<ChatRoomMemberState> get copyWith => _$ChatRoomMemberStateCopyWithImpl<ChatRoomMemberState>(this as ChatRoomMemberState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatRoomMemberState&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.total, total) || other.total == total)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(members),isLoading,total,error);

@override
String toString() {
  return 'ChatRoomMemberState(members: $members, isLoading: $isLoading, total: $total, error: $error)';
}


}

/// @nodoc
abstract mixin class $ChatRoomMemberStateCopyWith<$Res>  {
  factory $ChatRoomMemberStateCopyWith(ChatRoomMemberState value, $Res Function(ChatRoomMemberState) _then) = _$ChatRoomMemberStateCopyWithImpl;
@useResult
$Res call({
 List<SnChatMember> members, bool isLoading, int total, String? error
});




}
/// @nodoc
class _$ChatRoomMemberStateCopyWithImpl<$Res>
    implements $ChatRoomMemberStateCopyWith<$Res> {
  _$ChatRoomMemberStateCopyWithImpl(this._self, this._then);

  final ChatRoomMemberState _self;
  final $Res Function(ChatRoomMemberState) _then;

/// Create a copy of ChatRoomMemberState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? members = null,Object? isLoading = null,Object? total = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<SnChatMember>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc


class _ChatRoomMemberState implements ChatRoomMemberState {
  const _ChatRoomMemberState({required final  List<SnChatMember> members, required this.isLoading, required this.total, this.error}): _members = members;
  

 final  List<SnChatMember> _members;
@override List<SnChatMember> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

@override final  bool isLoading;
@override final  int total;
@override final  String? error;

/// Create a copy of ChatRoomMemberState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatRoomMemberStateCopyWith<_ChatRoomMemberState> get copyWith => __$ChatRoomMemberStateCopyWithImpl<_ChatRoomMemberState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatRoomMemberState&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.total, total) || other.total == total)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_members),isLoading,total,error);

@override
String toString() {
  return 'ChatRoomMemberState(members: $members, isLoading: $isLoading, total: $total, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ChatRoomMemberStateCopyWith<$Res> implements $ChatRoomMemberStateCopyWith<$Res> {
  factory _$ChatRoomMemberStateCopyWith(_ChatRoomMemberState value, $Res Function(_ChatRoomMemberState) _then) = __$ChatRoomMemberStateCopyWithImpl;
@override @useResult
$Res call({
 List<SnChatMember> members, bool isLoading, int total, String? error
});




}
/// @nodoc
class __$ChatRoomMemberStateCopyWithImpl<$Res>
    implements _$ChatRoomMemberStateCopyWith<$Res> {
  __$ChatRoomMemberStateCopyWithImpl(this._self, this._then);

  final _ChatRoomMemberState _self;
  final $Res Function(_ChatRoomMemberState) _then;

/// Create a copy of ChatRoomMemberState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? members = null,Object? isLoading = null,Object? total = null,Object? error = freezed,}) {
  return _then(_ChatRoomMemberState(
members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<SnChatMember>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
