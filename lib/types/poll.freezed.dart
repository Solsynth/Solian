// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poll.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnPoll {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  dynamic get deletedAt;
  dynamic get expiredAt;
  List<SnPollOption> get options;
  int get accountId;
  SnPollMetric get metric;

  /// Create a copy of SnPoll
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnPollCopyWith<SnPoll> get copyWith =>
      _$SnPollCopyWithImpl<SnPoll>(this as SnPoll, _$identity);

  /// Serializes this SnPoll to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnPoll &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.deletedAt, deletedAt) &&
            const DeepCollectionEquality().equals(other.expiredAt, expiredAt) &&
            const DeepCollectionEquality().equals(other.options, options) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.metric, metric) || other.metric == metric));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(deletedAt),
      const DeepCollectionEquality().hash(expiredAt),
      const DeepCollectionEquality().hash(options),
      accountId,
      metric);

  @override
  String toString() {
    return 'SnPoll(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiredAt: $expiredAt, options: $options, accountId: $accountId, metric: $metric)';
  }
}

/// @nodoc
abstract mixin class $SnPollCopyWith<$Res> {
  factory $SnPollCopyWith(SnPoll value, $Res Function(SnPoll) _then) =
      _$SnPollCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      dynamic expiredAt,
      List<SnPollOption> options,
      int accountId,
      SnPollMetric metric});

  $SnPollMetricCopyWith<$Res> get metric;
}

/// @nodoc
class _$SnPollCopyWithImpl<$Res> implements $SnPollCopyWith<$Res> {
  _$SnPollCopyWithImpl(this._self, this._then);

  final SnPoll _self;
  final $Res Function(SnPoll) _then;

  /// Create a copy of SnPoll
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? expiredAt = freezed,
    Object? options = null,
    Object? accountId = null,
    Object? metric = null,
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
              as dynamic,
      expiredAt: freezed == expiredAt
          ? _self.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      options: null == options
          ? _self.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<SnPollOption>,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      metric: null == metric
          ? _self.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as SnPollMetric,
    ));
  }

  /// Create a copy of SnPoll
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPollMetricCopyWith<$Res> get metric {
    return $SnPollMetricCopyWith<$Res>(_self.metric, (value) {
      return _then(_self.copyWith(metric: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnPoll implements SnPoll {
  const _SnPoll(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.expiredAt,
      required final List<SnPollOption> options,
      required this.accountId,
      required this.metric})
      : _options = options;
  factory _SnPoll.fromJson(Map<String, dynamic> json) => _$SnPollFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final dynamic deletedAt;
  @override
  final dynamic expiredAt;
  final List<SnPollOption> _options;
  @override
  List<SnPollOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final int accountId;
  @override
  final SnPollMetric metric;

  /// Create a copy of SnPoll
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnPollCopyWith<_SnPoll> get copyWith =>
      __$SnPollCopyWithImpl<_SnPoll>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnPollToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnPoll &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other.deletedAt, deletedAt) &&
            const DeepCollectionEquality().equals(other.expiredAt, expiredAt) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.metric, metric) || other.metric == metric));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(deletedAt),
      const DeepCollectionEquality().hash(expiredAt),
      const DeepCollectionEquality().hash(_options),
      accountId,
      metric);

  @override
  String toString() {
    return 'SnPoll(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, expiredAt: $expiredAt, options: $options, accountId: $accountId, metric: $metric)';
  }
}

/// @nodoc
abstract mixin class _$SnPollCopyWith<$Res> implements $SnPollCopyWith<$Res> {
  factory _$SnPollCopyWith(_SnPoll value, $Res Function(_SnPoll) _then) =
      __$SnPollCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      dynamic deletedAt,
      dynamic expiredAt,
      List<SnPollOption> options,
      int accountId,
      SnPollMetric metric});

  @override
  $SnPollMetricCopyWith<$Res> get metric;
}

/// @nodoc
class __$SnPollCopyWithImpl<$Res> implements _$SnPollCopyWith<$Res> {
  __$SnPollCopyWithImpl(this._self, this._then);

  final _SnPoll _self;
  final $Res Function(_SnPoll) _then;

  /// Create a copy of SnPoll
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? expiredAt = freezed,
    Object? options = null,
    Object? accountId = null,
    Object? metric = null,
  }) {
    return _then(_SnPoll(
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
              as dynamic,
      expiredAt: freezed == expiredAt
          ? _self.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as dynamic,
      options: null == options
          ? _self._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<SnPollOption>,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      metric: null == metric
          ? _self.metric
          : metric // ignore: cast_nullable_to_non_nullable
              as SnPollMetric,
    ));
  }

  /// Create a copy of SnPoll
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnPollMetricCopyWith<$Res> get metric {
    return $SnPollMetricCopyWith<$Res>(_self.metric, (value) {
      return _then(_self.copyWith(metric: value));
    });
  }
}

/// @nodoc
mixin _$SnPollMetric {
  int get totalAnswer;
  Map<String, int> get byOptions;
  Map<String, double> get byOptionsPercentage;

  /// Create a copy of SnPollMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnPollMetricCopyWith<SnPollMetric> get copyWith =>
      _$SnPollMetricCopyWithImpl<SnPollMetric>(
          this as SnPollMetric, _$identity);

  /// Serializes this SnPollMetric to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnPollMetric &&
            (identical(other.totalAnswer, totalAnswer) ||
                other.totalAnswer == totalAnswer) &&
            const DeepCollectionEquality().equals(other.byOptions, byOptions) &&
            const DeepCollectionEquality()
                .equals(other.byOptionsPercentage, byOptionsPercentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalAnswer,
      const DeepCollectionEquality().hash(byOptions),
      const DeepCollectionEquality().hash(byOptionsPercentage));

  @override
  String toString() {
    return 'SnPollMetric(totalAnswer: $totalAnswer, byOptions: $byOptions, byOptionsPercentage: $byOptionsPercentage)';
  }
}

/// @nodoc
abstract mixin class $SnPollMetricCopyWith<$Res> {
  factory $SnPollMetricCopyWith(
          SnPollMetric value, $Res Function(SnPollMetric) _then) =
      _$SnPollMetricCopyWithImpl;
  @useResult
  $Res call(
      {int totalAnswer,
      Map<String, int> byOptions,
      Map<String, double> byOptionsPercentage});
}

/// @nodoc
class _$SnPollMetricCopyWithImpl<$Res> implements $SnPollMetricCopyWith<$Res> {
  _$SnPollMetricCopyWithImpl(this._self, this._then);

  final SnPollMetric _self;
  final $Res Function(SnPollMetric) _then;

  /// Create a copy of SnPollMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalAnswer = null,
    Object? byOptions = null,
    Object? byOptionsPercentage = null,
  }) {
    return _then(_self.copyWith(
      totalAnswer: null == totalAnswer
          ? _self.totalAnswer
          : totalAnswer // ignore: cast_nullable_to_non_nullable
              as int,
      byOptions: null == byOptions
          ? _self.byOptions
          : byOptions // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      byOptionsPercentage: null == byOptionsPercentage
          ? _self.byOptionsPercentage
          : byOptionsPercentage // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnPollMetric implements SnPollMetric {
  const _SnPollMetric(
      {required this.totalAnswer,
      final Map<String, int> byOptions = const {},
      final Map<String, double> byOptionsPercentage = const {}})
      : _byOptions = byOptions,
        _byOptionsPercentage = byOptionsPercentage;
  factory _SnPollMetric.fromJson(Map<String, dynamic> json) =>
      _$SnPollMetricFromJson(json);

  @override
  final int totalAnswer;
  final Map<String, int> _byOptions;
  @override
  @JsonKey()
  Map<String, int> get byOptions {
    if (_byOptions is EqualUnmodifiableMapView) return _byOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byOptions);
  }

  final Map<String, double> _byOptionsPercentage;
  @override
  @JsonKey()
  Map<String, double> get byOptionsPercentage {
    if (_byOptionsPercentage is EqualUnmodifiableMapView)
      return _byOptionsPercentage;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byOptionsPercentage);
  }

  /// Create a copy of SnPollMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnPollMetricCopyWith<_SnPollMetric> get copyWith =>
      __$SnPollMetricCopyWithImpl<_SnPollMetric>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnPollMetricToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnPollMetric &&
            (identical(other.totalAnswer, totalAnswer) ||
                other.totalAnswer == totalAnswer) &&
            const DeepCollectionEquality()
                .equals(other._byOptions, _byOptions) &&
            const DeepCollectionEquality()
                .equals(other._byOptionsPercentage, _byOptionsPercentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalAnswer,
      const DeepCollectionEquality().hash(_byOptions),
      const DeepCollectionEquality().hash(_byOptionsPercentage));

  @override
  String toString() {
    return 'SnPollMetric(totalAnswer: $totalAnswer, byOptions: $byOptions, byOptionsPercentage: $byOptionsPercentage)';
  }
}

/// @nodoc
abstract mixin class _$SnPollMetricCopyWith<$Res>
    implements $SnPollMetricCopyWith<$Res> {
  factory _$SnPollMetricCopyWith(
          _SnPollMetric value, $Res Function(_SnPollMetric) _then) =
      __$SnPollMetricCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int totalAnswer,
      Map<String, int> byOptions,
      Map<String, double> byOptionsPercentage});
}

/// @nodoc
class __$SnPollMetricCopyWithImpl<$Res>
    implements _$SnPollMetricCopyWith<$Res> {
  __$SnPollMetricCopyWithImpl(this._self, this._then);

  final _SnPollMetric _self;
  final $Res Function(_SnPollMetric) _then;

  /// Create a copy of SnPollMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalAnswer = null,
    Object? byOptions = null,
    Object? byOptionsPercentage = null,
  }) {
    return _then(_SnPollMetric(
      totalAnswer: null == totalAnswer
          ? _self.totalAnswer
          : totalAnswer // ignore: cast_nullable_to_non_nullable
              as int,
      byOptions: null == byOptions
          ? _self._byOptions
          : byOptions // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      byOptionsPercentage: null == byOptionsPercentage
          ? _self._byOptionsPercentage
          : byOptionsPercentage // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ));
  }
}

/// @nodoc
mixin _$SnPollOption {
  String get id;
  String get icon;
  String get name;
  String get description;

  /// Create a copy of SnPollOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnPollOptionCopyWith<SnPollOption> get copyWith =>
      _$SnPollOptionCopyWithImpl<SnPollOption>(
          this as SnPollOption, _$identity);

  /// Serializes this SnPollOption to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnPollOption &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, icon, name, description);

  @override
  String toString() {
    return 'SnPollOption(id: $id, icon: $icon, name: $name, description: $description)';
  }
}

/// @nodoc
abstract mixin class $SnPollOptionCopyWith<$Res> {
  factory $SnPollOptionCopyWith(
          SnPollOption value, $Res Function(SnPollOption) _then) =
      _$SnPollOptionCopyWithImpl;
  @useResult
  $Res call({String id, String icon, String name, String description});
}

/// @nodoc
class _$SnPollOptionCopyWithImpl<$Res> implements $SnPollOptionCopyWith<$Res> {
  _$SnPollOptionCopyWithImpl(this._self, this._then);

  final SnPollOption _self;
  final $Res Function(SnPollOption) _then;

  /// Create a copy of SnPollOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? icon = null,
    Object? name = null,
    Object? description = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnPollOption implements SnPollOption {
  const _SnPollOption(
      {required this.id,
      required this.icon,
      required this.name,
      required this.description});
  factory _SnPollOption.fromJson(Map<String, dynamic> json) =>
      _$SnPollOptionFromJson(json);

  @override
  final String id;
  @override
  final String icon;
  @override
  final String name;
  @override
  final String description;

  /// Create a copy of SnPollOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnPollOptionCopyWith<_SnPollOption> get copyWith =>
      __$SnPollOptionCopyWithImpl<_SnPollOption>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnPollOptionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnPollOption &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, icon, name, description);

  @override
  String toString() {
    return 'SnPollOption(id: $id, icon: $icon, name: $name, description: $description)';
  }
}

/// @nodoc
abstract mixin class _$SnPollOptionCopyWith<$Res>
    implements $SnPollOptionCopyWith<$Res> {
  factory _$SnPollOptionCopyWith(
          _SnPollOption value, $Res Function(_SnPollOption) _then) =
      __$SnPollOptionCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String icon, String name, String description});
}

/// @nodoc
class __$SnPollOptionCopyWithImpl<$Res>
    implements _$SnPollOptionCopyWith<$Res> {
  __$SnPollOptionCopyWithImpl(this._self, this._then);

  final _SnPollOption _self;
  final $Res Function(_SnPollOption) _then;

  /// Create a copy of SnPollOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? icon = null,
    Object? name = null,
    Object? description = null,
  }) {
    return _then(_SnPollOption(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
