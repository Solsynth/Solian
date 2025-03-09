// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnCheckInRecord {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  int get resultTier;
  int get resultExperience;
  double get resultCoin;
  int get currentStreak;
  List<int> get resultModifiers;
  int get accountId;

  /// Create a copy of SnCheckInRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnCheckInRecordCopyWith<SnCheckInRecord> get copyWith =>
      _$SnCheckInRecordCopyWithImpl<SnCheckInRecord>(
          this as SnCheckInRecord, _$identity);

  /// Serializes this SnCheckInRecord to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnCheckInRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.resultTier, resultTier) ||
                other.resultTier == resultTier) &&
            (identical(other.resultExperience, resultExperience) ||
                other.resultExperience == resultExperience) &&
            (identical(other.resultCoin, resultCoin) ||
                other.resultCoin == resultCoin) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            const DeepCollectionEquality()
                .equals(other.resultModifiers, resultModifiers) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      resultTier,
      resultExperience,
      resultCoin,
      currentStreak,
      const DeepCollectionEquality().hash(resultModifiers),
      accountId);

  @override
  String toString() {
    return 'SnCheckInRecord(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, resultTier: $resultTier, resultExperience: $resultExperience, resultCoin: $resultCoin, currentStreak: $currentStreak, resultModifiers: $resultModifiers, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class $SnCheckInRecordCopyWith<$Res> {
  factory $SnCheckInRecordCopyWith(
          SnCheckInRecord value, $Res Function(SnCheckInRecord) _then) =
      _$SnCheckInRecordCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int resultTier,
      int resultExperience,
      double resultCoin,
      int currentStreak,
      List<int> resultModifiers,
      int accountId});
}

/// @nodoc
class _$SnCheckInRecordCopyWithImpl<$Res>
    implements $SnCheckInRecordCopyWith<$Res> {
  _$SnCheckInRecordCopyWithImpl(this._self, this._then);

  final SnCheckInRecord _self;
  final $Res Function(SnCheckInRecord) _then;

  /// Create a copy of SnCheckInRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? resultTier = null,
    Object? resultExperience = null,
    Object? resultCoin = null,
    Object? currentStreak = null,
    Object? resultModifiers = null,
    Object? accountId = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resultTier: null == resultTier
          ? _self.resultTier
          : resultTier // ignore: cast_nullable_to_non_nullable
              as int,
      resultExperience: null == resultExperience
          ? _self.resultExperience
          : resultExperience // ignore: cast_nullable_to_non_nullable
              as int,
      resultCoin: null == resultCoin
          ? _self.resultCoin
          : resultCoin // ignore: cast_nullable_to_non_nullable
              as double,
      currentStreak: null == currentStreak
          ? _self.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      resultModifiers: null == resultModifiers
          ? _self.resultModifiers
          : resultModifiers // ignore: cast_nullable_to_non_nullable
              as List<int>,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnCheckInRecord extends SnCheckInRecord {
  const _SnCheckInRecord(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.resultTier,
      required this.resultExperience,
      required this.resultCoin,
      this.currentStreak = 0,
      required final List<int> resultModifiers,
      required this.accountId})
      : _resultModifiers = resultModifiers,
        super._();
  factory _SnCheckInRecord.fromJson(Map<String, dynamic> json) =>
      _$SnCheckInRecordFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final int resultTier;
  @override
  final int resultExperience;
  @override
  final double resultCoin;
  @override
  @JsonKey()
  final int currentStreak;
  final List<int> _resultModifiers;
  @override
  List<int> get resultModifiers {
    if (_resultModifiers is EqualUnmodifiableListView) return _resultModifiers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_resultModifiers);
  }

  @override
  final int accountId;

  /// Create a copy of SnCheckInRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnCheckInRecordCopyWith<_SnCheckInRecord> get copyWith =>
      __$SnCheckInRecordCopyWithImpl<_SnCheckInRecord>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnCheckInRecordToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnCheckInRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.resultTier, resultTier) ||
                other.resultTier == resultTier) &&
            (identical(other.resultExperience, resultExperience) ||
                other.resultExperience == resultExperience) &&
            (identical(other.resultCoin, resultCoin) ||
                other.resultCoin == resultCoin) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            const DeepCollectionEquality()
                .equals(other._resultModifiers, _resultModifiers) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      resultTier,
      resultExperience,
      resultCoin,
      currentStreak,
      const DeepCollectionEquality().hash(_resultModifiers),
      accountId);

  @override
  String toString() {
    return 'SnCheckInRecord(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, resultTier: $resultTier, resultExperience: $resultExperience, resultCoin: $resultCoin, currentStreak: $currentStreak, resultModifiers: $resultModifiers, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class _$SnCheckInRecordCopyWith<$Res>
    implements $SnCheckInRecordCopyWith<$Res> {
  factory _$SnCheckInRecordCopyWith(
          _SnCheckInRecord value, $Res Function(_SnCheckInRecord) _then) =
      __$SnCheckInRecordCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int resultTier,
      int resultExperience,
      double resultCoin,
      int currentStreak,
      List<int> resultModifiers,
      int accountId});
}

/// @nodoc
class __$SnCheckInRecordCopyWithImpl<$Res>
    implements _$SnCheckInRecordCopyWith<$Res> {
  __$SnCheckInRecordCopyWithImpl(this._self, this._then);

  final _SnCheckInRecord _self;
  final $Res Function(_SnCheckInRecord) _then;

  /// Create a copy of SnCheckInRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? resultTier = null,
    Object? resultExperience = null,
    Object? resultCoin = null,
    Object? currentStreak = null,
    Object? resultModifiers = null,
    Object? accountId = null,
  }) {
    return _then(_SnCheckInRecord(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resultTier: null == resultTier
          ? _self.resultTier
          : resultTier // ignore: cast_nullable_to_non_nullable
              as int,
      resultExperience: null == resultExperience
          ? _self.resultExperience
          : resultExperience // ignore: cast_nullable_to_non_nullable
              as int,
      resultCoin: null == resultCoin
          ? _self.resultCoin
          : resultCoin // ignore: cast_nullable_to_non_nullable
              as double,
      currentStreak: null == currentStreak
          ? _self.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      resultModifiers: null == resultModifiers
          ? _self._resultModifiers
          : resultModifiers // ignore: cast_nullable_to_non_nullable
              as List<int>,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
