// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keypair.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnKeyPair {
  String get id;
  int get accountId;
  String get publicKey;
  bool? get isActive;
  String? get privateKey;

  /// Create a copy of SnKeyPair
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnKeyPairCopyWith<SnKeyPair> get copyWith =>
      _$SnKeyPairCopyWithImpl<SnKeyPair>(this as SnKeyPair, _$identity);

  /// Serializes this SnKeyPair to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnKeyPair &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.privateKey, privateKey) ||
                other.privateKey == privateKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, accountId, publicKey, isActive, privateKey);

  @override
  String toString() {
    return 'SnKeyPair(id: $id, accountId: $accountId, publicKey: $publicKey, isActive: $isActive, privateKey: $privateKey)';
  }
}

/// @nodoc
abstract mixin class $SnKeyPairCopyWith<$Res> {
  factory $SnKeyPairCopyWith(SnKeyPair value, $Res Function(SnKeyPair) _then) =
      _$SnKeyPairCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      int accountId,
      String publicKey,
      bool? isActive,
      String? privateKey});
}

/// @nodoc
class _$SnKeyPairCopyWithImpl<$Res> implements $SnKeyPairCopyWith<$Res> {
  _$SnKeyPairCopyWithImpl(this._self, this._then);

  final SnKeyPair _self;
  final $Res Function(SnKeyPair) _then;

  /// Create a copy of SnKeyPair
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? publicKey = null,
    Object? isActive = freezed,
    Object? privateKey = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      publicKey: null == publicKey
          ? _self.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: freezed == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      privateKey: freezed == privateKey
          ? _self.privateKey
          : privateKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnKeyPair implements SnKeyPair {
  const _SnKeyPair(
      {required this.id,
      required this.accountId,
      required this.publicKey,
      this.isActive,
      this.privateKey});
  factory _SnKeyPair.fromJson(Map<String, dynamic> json) =>
      _$SnKeyPairFromJson(json);

  @override
  final String id;
  @override
  final int accountId;
  @override
  final String publicKey;
  @override
  final bool? isActive;
  @override
  final String? privateKey;

  /// Create a copy of SnKeyPair
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnKeyPairCopyWith<_SnKeyPair> get copyWith =>
      __$SnKeyPairCopyWithImpl<_SnKeyPair>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnKeyPairToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnKeyPair &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.privateKey, privateKey) ||
                other.privateKey == privateKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, accountId, publicKey, isActive, privateKey);

  @override
  String toString() {
    return 'SnKeyPair(id: $id, accountId: $accountId, publicKey: $publicKey, isActive: $isActive, privateKey: $privateKey)';
  }
}

/// @nodoc
abstract mixin class _$SnKeyPairCopyWith<$Res>
    implements $SnKeyPairCopyWith<$Res> {
  factory _$SnKeyPairCopyWith(
          _SnKeyPair value, $Res Function(_SnKeyPair) _then) =
      __$SnKeyPairCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      int accountId,
      String publicKey,
      bool? isActive,
      String? privateKey});
}

/// @nodoc
class __$SnKeyPairCopyWithImpl<$Res> implements _$SnKeyPairCopyWith<$Res> {
  __$SnKeyPairCopyWithImpl(this._self, this._then);

  final _SnKeyPair _self;
  final $Res Function(_SnKeyPair) _then;

  /// Create a copy of SnKeyPair
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? accountId = null,
    Object? publicKey = null,
    Object? isActive = freezed,
    Object? privateKey = freezed,
  }) {
    return _then(_SnKeyPair(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      publicKey: null == publicKey
          ? _self.publicKey
          : publicKey // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: freezed == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      privateKey: freezed == privateKey
          ? _self.privateKey
          : privateKey // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
