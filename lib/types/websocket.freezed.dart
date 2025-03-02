// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'websocket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WebSocketPackage {
  @JsonKey(name: 'w')
  String get method;
  @JsonKey(name: 'e')
  String? get endpoint;
  @JsonKey(name: 'm')
  String? get message;
  @JsonKey(name: 'p')
  Map<String, dynamic>? get payload;

  /// Create a copy of WebSocketPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WebSocketPackageCopyWith<WebSocketPackage> get copyWith =>
      _$WebSocketPackageCopyWithImpl<WebSocketPackage>(
          this as WebSocketPackage, _$identity);

  /// Serializes this WebSocketPackage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WebSocketPackage &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.payload, payload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, method, endpoint, message,
      const DeepCollectionEquality().hash(payload));

  @override
  String toString() {
    return 'WebSocketPackage(method: $method, endpoint: $endpoint, message: $message, payload: $payload)';
  }
}

/// @nodoc
abstract mixin class $WebSocketPackageCopyWith<$Res> {
  factory $WebSocketPackageCopyWith(
          WebSocketPackage value, $Res Function(WebSocketPackage) _then) =
      _$WebSocketPackageCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'w') String method,
      @JsonKey(name: 'e') String? endpoint,
      @JsonKey(name: 'm') String? message,
      @JsonKey(name: 'p') Map<String, dynamic>? payload});
}

/// @nodoc
class _$WebSocketPackageCopyWithImpl<$Res>
    implements $WebSocketPackageCopyWith<$Res> {
  _$WebSocketPackageCopyWithImpl(this._self, this._then);

  final WebSocketPackage _self;
  final $Res Function(WebSocketPackage) _then;

  /// Create a copy of WebSocketPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? method = null,
    Object? endpoint = freezed,
    Object? message = freezed,
    Object? payload = freezed,
  }) {
    return _then(_self.copyWith(
      method: null == method
          ? _self.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      endpoint: freezed == endpoint
          ? _self.endpoint
          : endpoint // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      payload: freezed == payload
          ? _self.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _WebSocketPackage implements WebSocketPackage {
  const _WebSocketPackage(
      {@JsonKey(name: 'w') this.method = 'unknown',
      @JsonKey(name: 'e') this.endpoint,
      @JsonKey(name: 'm') this.message,
      @JsonKey(name: 'p') final Map<String, dynamic>? payload = const {}})
      : _payload = payload;
  factory _WebSocketPackage.fromJson(Map<String, dynamic> json) =>
      _$WebSocketPackageFromJson(json);

  @override
  @JsonKey(name: 'w')
  final String method;
  @override
  @JsonKey(name: 'e')
  final String? endpoint;
  @override
  @JsonKey(name: 'm')
  final String? message;
  final Map<String, dynamic>? _payload;
  @override
  @JsonKey(name: 'p')
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of WebSocketPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WebSocketPackageCopyWith<_WebSocketPackage> get copyWith =>
      __$WebSocketPackageCopyWithImpl<_WebSocketPackage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WebSocketPackageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WebSocketPackage &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._payload, _payload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, method, endpoint, message,
      const DeepCollectionEquality().hash(_payload));

  @override
  String toString() {
    return 'WebSocketPackage(method: $method, endpoint: $endpoint, message: $message, payload: $payload)';
  }
}

/// @nodoc
abstract mixin class _$WebSocketPackageCopyWith<$Res>
    implements $WebSocketPackageCopyWith<$Res> {
  factory _$WebSocketPackageCopyWith(
          _WebSocketPackage value, $Res Function(_WebSocketPackage) _then) =
      __$WebSocketPackageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'w') String method,
      @JsonKey(name: 'e') String? endpoint,
      @JsonKey(name: 'm') String? message,
      @JsonKey(name: 'p') Map<String, dynamic>? payload});
}

/// @nodoc
class __$WebSocketPackageCopyWithImpl<$Res>
    implements _$WebSocketPackageCopyWith<$Res> {
  __$WebSocketPackageCopyWithImpl(this._self, this._then);

  final _WebSocketPackage _self;
  final $Res Function(_WebSocketPackage) _then;

  /// Create a copy of WebSocketPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? method = null,
    Object? endpoint = freezed,
    Object? message = freezed,
    Object? payload = freezed,
  }) {
    return _then(_WebSocketPackage(
      method: null == method
          ? _self.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      endpoint: freezed == endpoint
          ? _self.endpoint
          : endpoint // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      payload: freezed == payload
          ? _self._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
