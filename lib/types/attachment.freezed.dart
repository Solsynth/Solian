// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SnAttachment _$SnAttachmentFromJson(Map<String, dynamic> json) {
  return _SnAttachment.fromJson(json);
}

/// @nodoc
mixin _$SnAttachment {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String get rid => throw _privateConstructorUsedError;
  String get uuid => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get alt => throw _privateConstructorUsedError;
  String get mimetype => throw _privateConstructorUsedError;
  String get hash => throw _privateConstructorUsedError;
  int get destination => throw _privateConstructorUsedError;
  int get refCount => throw _privateConstructorUsedError;
  int get contentRating => throw _privateConstructorUsedError;
  int get qualityRating => throw _privateConstructorUsedError;
  DateTime? get cleanedAt => throw _privateConstructorUsedError;
  bool get isAnalyzed => throw _privateConstructorUsedError;
  bool get isSelfRef => throw _privateConstructorUsedError;
  bool get isIndexable => throw _privateConstructorUsedError;
  SnAttachment? get ref => throw _privateConstructorUsedError;
  int? get refId => throw _privateConstructorUsedError;
  SnAttachmentPool? get pool => throw _privateConstructorUsedError;
  int? get poolId => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;
  int? get thumbnailId => throw _privateConstructorUsedError;
  SnAttachment? get thumbnail => throw _privateConstructorUsedError;
  int? get compressedId => throw _privateConstructorUsedError;
  SnAttachment? get compressed => throw _privateConstructorUsedError;
  List<SnAttachmentBoost> get boosts => throw _privateConstructorUsedError;
  Map<String, dynamic> get usermeta => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this SnAttachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAttachmentCopyWith<SnAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAttachmentCopyWith<$Res> {
  factory $SnAttachmentCopyWith(
          SnAttachment value, $Res Function(SnAttachment) then) =
      _$SnAttachmentCopyWithImpl<$Res, SnAttachment>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String rid,
      String uuid,
      int size,
      String name,
      String alt,
      String mimetype,
      String hash,
      int destination,
      int refCount,
      int contentRating,
      int qualityRating,
      DateTime? cleanedAt,
      bool isAnalyzed,
      bool isSelfRef,
      bool isIndexable,
      SnAttachment? ref,
      int? refId,
      SnAttachmentPool? pool,
      int? poolId,
      int accountId,
      int? thumbnailId,
      SnAttachment? thumbnail,
      int? compressedId,
      SnAttachment? compressed,
      List<SnAttachmentBoost> boosts,
      Map<String, dynamic> usermeta,
      Map<String, dynamic> metadata});

  $SnAttachmentCopyWith<$Res>? get ref;
  $SnAttachmentPoolCopyWith<$Res>? get pool;
  $SnAttachmentCopyWith<$Res>? get thumbnail;
  $SnAttachmentCopyWith<$Res>? get compressed;
}

/// @nodoc
class _$SnAttachmentCopyWithImpl<$Res, $Val extends SnAttachment>
    implements $SnAttachmentCopyWith<$Res> {
  _$SnAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? rid = null,
    Object? uuid = null,
    Object? size = null,
    Object? name = null,
    Object? alt = null,
    Object? mimetype = null,
    Object? hash = null,
    Object? destination = null,
    Object? refCount = null,
    Object? contentRating = null,
    Object? qualityRating = null,
    Object? cleanedAt = freezed,
    Object? isAnalyzed = null,
    Object? isSelfRef = null,
    Object? isIndexable = null,
    Object? ref = freezed,
    Object? refId = freezed,
    Object? pool = freezed,
    Object? poolId = freezed,
    Object? accountId = null,
    Object? thumbnailId = freezed,
    Object? thumbnail = freezed,
    Object? compressedId = freezed,
    Object? compressed = freezed,
    Object? boosts = null,
    Object? usermeta = null,
    Object? metadata = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rid: null == rid
          ? _value.rid
          : rid // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      mimetype: null == mimetype
          ? _value.mimetype
          : mimetype // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int,
      refCount: null == refCount
          ? _value.refCount
          : refCount // ignore: cast_nullable_to_non_nullable
              as int,
      contentRating: null == contentRating
          ? _value.contentRating
          : contentRating // ignore: cast_nullable_to_non_nullable
              as int,
      qualityRating: null == qualityRating
          ? _value.qualityRating
          : qualityRating // ignore: cast_nullable_to_non_nullable
              as int,
      cleanedAt: freezed == cleanedAt
          ? _value.cleanedAt
          : cleanedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAnalyzed: null == isAnalyzed
          ? _value.isAnalyzed
          : isAnalyzed // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelfRef: null == isSelfRef
          ? _value.isSelfRef
          : isSelfRef // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndexable: null == isIndexable
          ? _value.isIndexable
          : isIndexable // ignore: cast_nullable_to_non_nullable
              as bool,
      ref: freezed == ref
          ? _value.ref
          : ref // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      refId: freezed == refId
          ? _value.refId
          : refId // ignore: cast_nullable_to_non_nullable
              as int?,
      pool: freezed == pool
          ? _value.pool
          : pool // ignore: cast_nullable_to_non_nullable
              as SnAttachmentPool?,
      poolId: freezed == poolId
          ? _value.poolId
          : poolId // ignore: cast_nullable_to_non_nullable
              as int?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailId: freezed == thumbnailId
          ? _value.thumbnailId
          : thumbnailId // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      compressedId: freezed == compressedId
          ? _value.compressedId
          : compressedId // ignore: cast_nullable_to_non_nullable
              as int?,
      compressed: freezed == compressed
          ? _value.compressed
          : compressed // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      boosts: null == boosts
          ? _value.boosts
          : boosts // ignore: cast_nullable_to_non_nullable
              as List<SnAttachmentBoost>,
      usermeta: null == usermeta
          ? _value.usermeta
          : usermeta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get ref {
    if (_value.ref == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_value.ref!, (value) {
      return _then(_value.copyWith(ref: value) as $Val);
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentPoolCopyWith<$Res>? get pool {
    if (_value.pool == null) {
      return null;
    }

    return $SnAttachmentPoolCopyWith<$Res>(_value.pool!, (value) {
      return _then(_value.copyWith(pool: value) as $Val);
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get thumbnail {
    if (_value.thumbnail == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_value.thumbnail!, (value) {
      return _then(_value.copyWith(thumbnail: value) as $Val);
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get compressed {
    if (_value.compressed == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_value.compressed!, (value) {
      return _then(_value.copyWith(compressed: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnAttachmentImplCopyWith<$Res>
    implements $SnAttachmentCopyWith<$Res> {
  factory _$$SnAttachmentImplCopyWith(
          _$SnAttachmentImpl value, $Res Function(_$SnAttachmentImpl) then) =
      __$$SnAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String rid,
      String uuid,
      int size,
      String name,
      String alt,
      String mimetype,
      String hash,
      int destination,
      int refCount,
      int contentRating,
      int qualityRating,
      DateTime? cleanedAt,
      bool isAnalyzed,
      bool isSelfRef,
      bool isIndexable,
      SnAttachment? ref,
      int? refId,
      SnAttachmentPool? pool,
      int? poolId,
      int accountId,
      int? thumbnailId,
      SnAttachment? thumbnail,
      int? compressedId,
      SnAttachment? compressed,
      List<SnAttachmentBoost> boosts,
      Map<String, dynamic> usermeta,
      Map<String, dynamic> metadata});

  @override
  $SnAttachmentCopyWith<$Res>? get ref;
  @override
  $SnAttachmentPoolCopyWith<$Res>? get pool;
  @override
  $SnAttachmentCopyWith<$Res>? get thumbnail;
  @override
  $SnAttachmentCopyWith<$Res>? get compressed;
}

/// @nodoc
class __$$SnAttachmentImplCopyWithImpl<$Res>
    extends _$SnAttachmentCopyWithImpl<$Res, _$SnAttachmentImpl>
    implements _$$SnAttachmentImplCopyWith<$Res> {
  __$$SnAttachmentImplCopyWithImpl(
      _$SnAttachmentImpl _value, $Res Function(_$SnAttachmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? rid = null,
    Object? uuid = null,
    Object? size = null,
    Object? name = null,
    Object? alt = null,
    Object? mimetype = null,
    Object? hash = null,
    Object? destination = null,
    Object? refCount = null,
    Object? contentRating = null,
    Object? qualityRating = null,
    Object? cleanedAt = freezed,
    Object? isAnalyzed = null,
    Object? isSelfRef = null,
    Object? isIndexable = null,
    Object? ref = freezed,
    Object? refId = freezed,
    Object? pool = freezed,
    Object? poolId = freezed,
    Object? accountId = null,
    Object? thumbnailId = freezed,
    Object? thumbnail = freezed,
    Object? compressedId = freezed,
    Object? compressed = freezed,
    Object? boosts = null,
    Object? usermeta = null,
    Object? metadata = null,
  }) {
    return _then(_$SnAttachmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rid: null == rid
          ? _value.rid
          : rid // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      mimetype: null == mimetype
          ? _value.mimetype
          : mimetype // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int,
      refCount: null == refCount
          ? _value.refCount
          : refCount // ignore: cast_nullable_to_non_nullable
              as int,
      contentRating: null == contentRating
          ? _value.contentRating
          : contentRating // ignore: cast_nullable_to_non_nullable
              as int,
      qualityRating: null == qualityRating
          ? _value.qualityRating
          : qualityRating // ignore: cast_nullable_to_non_nullable
              as int,
      cleanedAt: freezed == cleanedAt
          ? _value.cleanedAt
          : cleanedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAnalyzed: null == isAnalyzed
          ? _value.isAnalyzed
          : isAnalyzed // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelfRef: null == isSelfRef
          ? _value.isSelfRef
          : isSelfRef // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndexable: null == isIndexable
          ? _value.isIndexable
          : isIndexable // ignore: cast_nullable_to_non_nullable
              as bool,
      ref: freezed == ref
          ? _value.ref
          : ref // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      refId: freezed == refId
          ? _value.refId
          : refId // ignore: cast_nullable_to_non_nullable
              as int?,
      pool: freezed == pool
          ? _value.pool
          : pool // ignore: cast_nullable_to_non_nullable
              as SnAttachmentPool?,
      poolId: freezed == poolId
          ? _value.poolId
          : poolId // ignore: cast_nullable_to_non_nullable
              as int?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailId: freezed == thumbnailId
          ? _value.thumbnailId
          : thumbnailId // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      compressedId: freezed == compressedId
          ? _value.compressedId
          : compressedId // ignore: cast_nullable_to_non_nullable
              as int?,
      compressed: freezed == compressed
          ? _value.compressed
          : compressed // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      boosts: null == boosts
          ? _value._boosts
          : boosts // ignore: cast_nullable_to_non_nullable
              as List<SnAttachmentBoost>,
      usermeta: null == usermeta
          ? _value._usermeta
          : usermeta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAttachmentImpl extends _SnAttachment {
  const _$SnAttachmentImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.rid,
      required this.uuid,
      required this.size,
      required this.name,
      required this.alt,
      required this.mimetype,
      required this.hash,
      required this.destination,
      required this.refCount,
      this.contentRating = 0,
      this.qualityRating = 0,
      required this.cleanedAt,
      required this.isAnalyzed,
      required this.isSelfRef,
      required this.isIndexable,
      required this.ref,
      required this.refId,
      required this.pool,
      required this.poolId,
      required this.accountId,
      this.thumbnailId,
      this.thumbnail,
      this.compressedId,
      this.compressed,
      final List<SnAttachmentBoost> boosts = const [],
      final Map<String, dynamic> usermeta = const {},
      final Map<String, dynamic> metadata = const {}})
      : _boosts = boosts,
        _usermeta = usermeta,
        _metadata = metadata,
        super._();

  factory _$SnAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAttachmentImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String rid;
  @override
  final String uuid;
  @override
  final int size;
  @override
  final String name;
  @override
  final String alt;
  @override
  final String mimetype;
  @override
  final String hash;
  @override
  final int destination;
  @override
  final int refCount;
  @override
  @JsonKey()
  final int contentRating;
  @override
  @JsonKey()
  final int qualityRating;
  @override
  final DateTime? cleanedAt;
  @override
  final bool isAnalyzed;
  @override
  final bool isSelfRef;
  @override
  final bool isIndexable;
  @override
  final SnAttachment? ref;
  @override
  final int? refId;
  @override
  final SnAttachmentPool? pool;
  @override
  final int? poolId;
  @override
  final int accountId;
  @override
  final int? thumbnailId;
  @override
  final SnAttachment? thumbnail;
  @override
  final int? compressedId;
  @override
  final SnAttachment? compressed;
  final List<SnAttachmentBoost> _boosts;
  @override
  @JsonKey()
  List<SnAttachmentBoost> get boosts {
    if (_boosts is EqualUnmodifiableListView) return _boosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boosts);
  }

  final Map<String, dynamic> _usermeta;
  @override
  @JsonKey()
  Map<String, dynamic> get usermeta {
    if (_usermeta is EqualUnmodifiableMapView) return _usermeta;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_usermeta);
  }

  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'SnAttachment(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, rid: $rid, uuid: $uuid, size: $size, name: $name, alt: $alt, mimetype: $mimetype, hash: $hash, destination: $destination, refCount: $refCount, contentRating: $contentRating, qualityRating: $qualityRating, cleanedAt: $cleanedAt, isAnalyzed: $isAnalyzed, isSelfRef: $isSelfRef, isIndexable: $isIndexable, ref: $ref, refId: $refId, pool: $pool, poolId: $poolId, accountId: $accountId, thumbnailId: $thumbnailId, thumbnail: $thumbnail, compressedId: $compressedId, compressed: $compressed, boosts: $boosts, usermeta: $usermeta, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAttachmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.rid, rid) || other.rid == rid) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.alt, alt) || other.alt == alt) &&
            (identical(other.mimetype, mimetype) ||
                other.mimetype == mimetype) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.refCount, refCount) ||
                other.refCount == refCount) &&
            (identical(other.contentRating, contentRating) ||
                other.contentRating == contentRating) &&
            (identical(other.qualityRating, qualityRating) ||
                other.qualityRating == qualityRating) &&
            (identical(other.cleanedAt, cleanedAt) ||
                other.cleanedAt == cleanedAt) &&
            (identical(other.isAnalyzed, isAnalyzed) ||
                other.isAnalyzed == isAnalyzed) &&
            (identical(other.isSelfRef, isSelfRef) ||
                other.isSelfRef == isSelfRef) &&
            (identical(other.isIndexable, isIndexable) ||
                other.isIndexable == isIndexable) &&
            (identical(other.ref, ref) || other.ref == ref) &&
            (identical(other.refId, refId) || other.refId == refId) &&
            (identical(other.pool, pool) || other.pool == pool) &&
            (identical(other.poolId, poolId) || other.poolId == poolId) &&
            (identical(other.accountId, accountId) ||
                other.accountId == accountId) &&
            (identical(other.thumbnailId, thumbnailId) ||
                other.thumbnailId == thumbnailId) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.compressedId, compressedId) ||
                other.compressedId == compressedId) &&
            (identical(other.compressed, compressed) ||
                other.compressed == compressed) &&
            const DeepCollectionEquality().equals(other._boosts, _boosts) &&
            const DeepCollectionEquality().equals(other._usermeta, _usermeta) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        createdAt,
        updatedAt,
        deletedAt,
        rid,
        uuid,
        size,
        name,
        alt,
        mimetype,
        hash,
        destination,
        refCount,
        contentRating,
        qualityRating,
        cleanedAt,
        isAnalyzed,
        isSelfRef,
        isIndexable,
        ref,
        refId,
        pool,
        poolId,
        accountId,
        thumbnailId,
        thumbnail,
        compressedId,
        compressed,
        const DeepCollectionEquality().hash(_boosts),
        const DeepCollectionEquality().hash(_usermeta),
        const DeepCollectionEquality().hash(_metadata)
      ]);

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAttachmentImplCopyWith<_$SnAttachmentImpl> get copyWith =>
      __$$SnAttachmentImplCopyWithImpl<_$SnAttachmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAttachmentImplToJson(
      this,
    );
  }
}

abstract class _SnAttachment extends SnAttachment {
  const factory _SnAttachment(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final String rid,
      required final String uuid,
      required final int size,
      required final String name,
      required final String alt,
      required final String mimetype,
      required final String hash,
      required final int destination,
      required final int refCount,
      final int contentRating,
      final int qualityRating,
      required final DateTime? cleanedAt,
      required final bool isAnalyzed,
      required final bool isSelfRef,
      required final bool isIndexable,
      required final SnAttachment? ref,
      required final int? refId,
      required final SnAttachmentPool? pool,
      required final int? poolId,
      required final int accountId,
      final int? thumbnailId,
      final SnAttachment? thumbnail,
      final int? compressedId,
      final SnAttachment? compressed,
      final List<SnAttachmentBoost> boosts,
      final Map<String, dynamic> usermeta,
      final Map<String, dynamic> metadata}) = _$SnAttachmentImpl;
  const _SnAttachment._() : super._();

  factory _SnAttachment.fromJson(Map<String, dynamic> json) =
      _$SnAttachmentImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  String get rid;
  @override
  String get uuid;
  @override
  int get size;
  @override
  String get name;
  @override
  String get alt;
  @override
  String get mimetype;
  @override
  String get hash;
  @override
  int get destination;
  @override
  int get refCount;
  @override
  int get contentRating;
  @override
  int get qualityRating;
  @override
  DateTime? get cleanedAt;
  @override
  bool get isAnalyzed;
  @override
  bool get isSelfRef;
  @override
  bool get isIndexable;
  @override
  SnAttachment? get ref;
  @override
  int? get refId;
  @override
  SnAttachmentPool? get pool;
  @override
  int? get poolId;
  @override
  int get accountId;
  @override
  int? get thumbnailId;
  @override
  SnAttachment? get thumbnail;
  @override
  int? get compressedId;
  @override
  SnAttachment? get compressed;
  @override
  List<SnAttachmentBoost> get boosts;
  @override
  Map<String, dynamic> get usermeta;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAttachmentImplCopyWith<_$SnAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAttachmentFragment _$SnAttachmentFragmentFromJson(Map<String, dynamic> json) {
  return _SnAttachmentFragment.fromJson(json);
}

/// @nodoc
mixin _$SnAttachmentFragment {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String get rid => throw _privateConstructorUsedError;
  String get uuid => throw _privateConstructorUsedError;
  int get size => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get alt => throw _privateConstructorUsedError;
  String get mimetype => throw _privateConstructorUsedError;
  String get hash => throw _privateConstructorUsedError;
  String? get fingerprint => throw _privateConstructorUsedError;
  Map<String, int> get fileChunks => throw _privateConstructorUsedError;
  List<String> get fileChunksMissing => throw _privateConstructorUsedError;

  /// Serializes this SnAttachmentFragment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAttachmentFragment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAttachmentFragmentCopyWith<SnAttachmentFragment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAttachmentFragmentCopyWith<$Res> {
  factory $SnAttachmentFragmentCopyWith(SnAttachmentFragment value,
          $Res Function(SnAttachmentFragment) then) =
      _$SnAttachmentFragmentCopyWithImpl<$Res, SnAttachmentFragment>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String rid,
      String uuid,
      int size,
      String name,
      String alt,
      String mimetype,
      String hash,
      String? fingerprint,
      Map<String, int> fileChunks,
      List<String> fileChunksMissing});
}

/// @nodoc
class _$SnAttachmentFragmentCopyWithImpl<$Res,
        $Val extends SnAttachmentFragment>
    implements $SnAttachmentFragmentCopyWith<$Res> {
  _$SnAttachmentFragmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAttachmentFragment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? rid = null,
    Object? uuid = null,
    Object? size = null,
    Object? name = null,
    Object? alt = null,
    Object? mimetype = null,
    Object? hash = null,
    Object? fingerprint = freezed,
    Object? fileChunks = null,
    Object? fileChunksMissing = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rid: null == rid
          ? _value.rid
          : rid // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      mimetype: null == mimetype
          ? _value.mimetype
          : mimetype // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      fingerprint: freezed == fingerprint
          ? _value.fingerprint
          : fingerprint // ignore: cast_nullable_to_non_nullable
              as String?,
      fileChunks: null == fileChunks
          ? _value.fileChunks
          : fileChunks // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      fileChunksMissing: null == fileChunksMissing
          ? _value.fileChunksMissing
          : fileChunksMissing // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnAttachmentFragmentImplCopyWith<$Res>
    implements $SnAttachmentFragmentCopyWith<$Res> {
  factory _$$SnAttachmentFragmentImplCopyWith(_$SnAttachmentFragmentImpl value,
          $Res Function(_$SnAttachmentFragmentImpl) then) =
      __$$SnAttachmentFragmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String rid,
      String uuid,
      int size,
      String name,
      String alt,
      String mimetype,
      String hash,
      String? fingerprint,
      Map<String, int> fileChunks,
      List<String> fileChunksMissing});
}

/// @nodoc
class __$$SnAttachmentFragmentImplCopyWithImpl<$Res>
    extends _$SnAttachmentFragmentCopyWithImpl<$Res, _$SnAttachmentFragmentImpl>
    implements _$$SnAttachmentFragmentImplCopyWith<$Res> {
  __$$SnAttachmentFragmentImplCopyWithImpl(_$SnAttachmentFragmentImpl _value,
      $Res Function(_$SnAttachmentFragmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAttachmentFragment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? rid = null,
    Object? uuid = null,
    Object? size = null,
    Object? name = null,
    Object? alt = null,
    Object? mimetype = null,
    Object? hash = null,
    Object? fingerprint = freezed,
    Object? fileChunks = null,
    Object? fileChunksMissing = null,
  }) {
    return _then(_$SnAttachmentFragmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rid: null == rid
          ? _value.rid
          : rid // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _value.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _value.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      mimetype: null == mimetype
          ? _value.mimetype
          : mimetype // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      fingerprint: freezed == fingerprint
          ? _value.fingerprint
          : fingerprint // ignore: cast_nullable_to_non_nullable
              as String?,
      fileChunks: null == fileChunks
          ? _value._fileChunks
          : fileChunks // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      fileChunksMissing: null == fileChunksMissing
          ? _value._fileChunksMissing
          : fileChunksMissing // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAttachmentFragmentImpl extends _SnAttachmentFragment {
  const _$SnAttachmentFragmentImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.rid,
      required this.uuid,
      required this.size,
      required this.name,
      required this.alt,
      required this.mimetype,
      required this.hash,
      this.fingerprint,
      final Map<String, int> fileChunks = const {},
      final List<String> fileChunksMissing = const []})
      : _fileChunks = fileChunks,
        _fileChunksMissing = fileChunksMissing,
        super._();

  factory _$SnAttachmentFragmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAttachmentFragmentImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String rid;
  @override
  final String uuid;
  @override
  final int size;
  @override
  final String name;
  @override
  final String alt;
  @override
  final String mimetype;
  @override
  final String hash;
  @override
  final String? fingerprint;
  final Map<String, int> _fileChunks;
  @override
  @JsonKey()
  Map<String, int> get fileChunks {
    if (_fileChunks is EqualUnmodifiableMapView) return _fileChunks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_fileChunks);
  }

  final List<String> _fileChunksMissing;
  @override
  @JsonKey()
  List<String> get fileChunksMissing {
    if (_fileChunksMissing is EqualUnmodifiableListView)
      return _fileChunksMissing;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fileChunksMissing);
  }

  @override
  String toString() {
    return 'SnAttachmentFragment(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, rid: $rid, uuid: $uuid, size: $size, name: $name, alt: $alt, mimetype: $mimetype, hash: $hash, fingerprint: $fingerprint, fileChunks: $fileChunks, fileChunksMissing: $fileChunksMissing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAttachmentFragmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.rid, rid) || other.rid == rid) &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.alt, alt) || other.alt == alt) &&
            (identical(other.mimetype, mimetype) ||
                other.mimetype == mimetype) &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.fingerprint, fingerprint) ||
                other.fingerprint == fingerprint) &&
            const DeepCollectionEquality()
                .equals(other._fileChunks, _fileChunks) &&
            const DeepCollectionEquality()
                .equals(other._fileChunksMissing, _fileChunksMissing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      deletedAt,
      rid,
      uuid,
      size,
      name,
      alt,
      mimetype,
      hash,
      fingerprint,
      const DeepCollectionEquality().hash(_fileChunks),
      const DeepCollectionEquality().hash(_fileChunksMissing));

  /// Create a copy of SnAttachmentFragment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAttachmentFragmentImplCopyWith<_$SnAttachmentFragmentImpl>
      get copyWith =>
          __$$SnAttachmentFragmentImplCopyWithImpl<_$SnAttachmentFragmentImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAttachmentFragmentImplToJson(
      this,
    );
  }
}

abstract class _SnAttachmentFragment extends SnAttachmentFragment {
  const factory _SnAttachmentFragment(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final String rid,
      required final String uuid,
      required final int size,
      required final String name,
      required final String alt,
      required final String mimetype,
      required final String hash,
      final String? fingerprint,
      final Map<String, int> fileChunks,
      final List<String> fileChunksMissing}) = _$SnAttachmentFragmentImpl;
  const _SnAttachmentFragment._() : super._();

  factory _SnAttachmentFragment.fromJson(Map<String, dynamic> json) =
      _$SnAttachmentFragmentImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  String get rid;
  @override
  String get uuid;
  @override
  int get size;
  @override
  String get name;
  @override
  String get alt;
  @override
  String get mimetype;
  @override
  String get hash;
  @override
  String? get fingerprint;
  @override
  Map<String, int> get fileChunks;
  @override
  List<String> get fileChunksMissing;

  /// Create a copy of SnAttachmentFragment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAttachmentFragmentImplCopyWith<_$SnAttachmentFragmentImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SnAttachmentPool _$SnAttachmentPoolFromJson(Map<String, dynamic> json) {
  return _SnAttachmentPool.fromJson(json);
}

/// @nodoc
mixin _$SnAttachmentPool {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String get alias => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic> get config => throw _privateConstructorUsedError;
  int? get accountId => throw _privateConstructorUsedError;

  /// Serializes this SnAttachmentPool to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAttachmentPool
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAttachmentPoolCopyWith<SnAttachmentPool> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAttachmentPoolCopyWith<$Res> {
  factory $SnAttachmentPoolCopyWith(
          SnAttachmentPool value, $Res Function(SnAttachmentPool) then) =
      _$SnAttachmentPoolCopyWithImpl<$Res, SnAttachmentPool>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String alias,
      String name,
      String description,
      Map<String, dynamic> config,
      int? accountId});
}

/// @nodoc
class _$SnAttachmentPoolCopyWithImpl<$Res, $Val extends SnAttachmentPool>
    implements $SnAttachmentPoolCopyWith<$Res> {
  _$SnAttachmentPoolCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAttachmentPool
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? description = null,
    Object? config = null,
    Object? accountId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      config: null == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnAttachmentPoolImplCopyWith<$Res>
    implements $SnAttachmentPoolCopyWith<$Res> {
  factory _$$SnAttachmentPoolImplCopyWith(_$SnAttachmentPoolImpl value,
          $Res Function(_$SnAttachmentPoolImpl) then) =
      __$$SnAttachmentPoolImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String alias,
      String name,
      String description,
      Map<String, dynamic> config,
      int? accountId});
}

/// @nodoc
class __$$SnAttachmentPoolImplCopyWithImpl<$Res>
    extends _$SnAttachmentPoolCopyWithImpl<$Res, _$SnAttachmentPoolImpl>
    implements _$$SnAttachmentPoolImplCopyWith<$Res> {
  __$$SnAttachmentPoolImplCopyWithImpl(_$SnAttachmentPoolImpl _value,
      $Res Function(_$SnAttachmentPoolImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAttachmentPool
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? description = null,
    Object? config = null,
    Object? accountId = freezed,
  }) {
    return _then(_$SnAttachmentPoolImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      config: null == config
          ? _value._config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      accountId: freezed == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAttachmentPoolImpl implements _SnAttachmentPool {
  const _$SnAttachmentPoolImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.alias,
      required this.name,
      required this.description,
      required final Map<String, dynamic> config,
      required this.accountId})
      : _config = config;

  factory _$SnAttachmentPoolImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAttachmentPoolImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String alias;
  @override
  final String name;
  @override
  final String description;
  final Map<String, dynamic> _config;
  @override
  Map<String, dynamic> get config {
    if (_config is EqualUnmodifiableMapView) return _config;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_config);
  }

  @override
  final int? accountId;

  @override
  String toString() {
    return 'SnAttachmentPool(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, config: $config, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAttachmentPoolImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._config, _config) &&
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
      alias,
      name,
      description,
      const DeepCollectionEquality().hash(_config),
      accountId);

  /// Create a copy of SnAttachmentPool
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAttachmentPoolImplCopyWith<_$SnAttachmentPoolImpl> get copyWith =>
      __$$SnAttachmentPoolImplCopyWithImpl<_$SnAttachmentPoolImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAttachmentPoolImplToJson(
      this,
    );
  }
}

abstract class _SnAttachmentPool implements SnAttachmentPool {
  const factory _SnAttachmentPool(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final String alias,
      required final String name,
      required final String description,
      required final Map<String, dynamic> config,
      required final int? accountId}) = _$SnAttachmentPoolImpl;

  factory _SnAttachmentPool.fromJson(Map<String, dynamic> json) =
      _$SnAttachmentPoolImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  String get alias;
  @override
  String get name;
  @override
  String get description;
  @override
  Map<String, dynamic> get config;
  @override
  int? get accountId;

  /// Create a copy of SnAttachmentPool
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAttachmentPoolImplCopyWith<_$SnAttachmentPoolImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAttachmentDestination _$SnAttachmentDestinationFromJson(
    Map<String, dynamic> json) {
  return _SnAttachmentDestination.fromJson(json);
}

/// @nodoc
mixin _$SnAttachmentDestination {
  int get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get region => throw _privateConstructorUsedError;
  bool get isBoost => throw _privateConstructorUsedError;

  /// Serializes this SnAttachmentDestination to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAttachmentDestination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAttachmentDestinationCopyWith<SnAttachmentDestination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAttachmentDestinationCopyWith<$Res> {
  factory $SnAttachmentDestinationCopyWith(SnAttachmentDestination value,
          $Res Function(SnAttachmentDestination) then) =
      _$SnAttachmentDestinationCopyWithImpl<$Res, SnAttachmentDestination>;
  @useResult
  $Res call({int id, String type, String label, String region, bool isBoost});
}

/// @nodoc
class _$SnAttachmentDestinationCopyWithImpl<$Res,
        $Val extends SnAttachmentDestination>
    implements $SnAttachmentDestinationCopyWith<$Res> {
  _$SnAttachmentDestinationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAttachmentDestination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? region = null,
    Object? isBoost = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      isBoost: null == isBoost
          ? _value.isBoost
          : isBoost // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnAttachmentDestinationImplCopyWith<$Res>
    implements $SnAttachmentDestinationCopyWith<$Res> {
  factory _$$SnAttachmentDestinationImplCopyWith(
          _$SnAttachmentDestinationImpl value,
          $Res Function(_$SnAttachmentDestinationImpl) then) =
      __$$SnAttachmentDestinationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String type, String label, String region, bool isBoost});
}

/// @nodoc
class __$$SnAttachmentDestinationImplCopyWithImpl<$Res>
    extends _$SnAttachmentDestinationCopyWithImpl<$Res,
        _$SnAttachmentDestinationImpl>
    implements _$$SnAttachmentDestinationImplCopyWith<$Res> {
  __$$SnAttachmentDestinationImplCopyWithImpl(
      _$SnAttachmentDestinationImpl _value,
      $Res Function(_$SnAttachmentDestinationImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAttachmentDestination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? region = null,
    Object? isBoost = null,
  }) {
    return _then(_$SnAttachmentDestinationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      isBoost: null == isBoost
          ? _value.isBoost
          : isBoost // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAttachmentDestinationImpl implements _SnAttachmentDestination {
  const _$SnAttachmentDestinationImpl(
      {this.id = 0,
      required this.type,
      required this.label,
      required this.region,
      required this.isBoost});

  factory _$SnAttachmentDestinationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAttachmentDestinationImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  final String type;
  @override
  final String label;
  @override
  final String region;
  @override
  final bool isBoost;

  @override
  String toString() {
    return 'SnAttachmentDestination(id: $id, type: $type, label: $label, region: $region, isBoost: $isBoost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAttachmentDestinationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.isBoost, isBoost) || other.isBoost == isBoost));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, label, region, isBoost);

  /// Create a copy of SnAttachmentDestination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAttachmentDestinationImplCopyWith<_$SnAttachmentDestinationImpl>
      get copyWith => __$$SnAttachmentDestinationImplCopyWithImpl<
          _$SnAttachmentDestinationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAttachmentDestinationImplToJson(
      this,
    );
  }
}

abstract class _SnAttachmentDestination implements SnAttachmentDestination {
  const factory _SnAttachmentDestination(
      {final int id,
      required final String type,
      required final String label,
      required final String region,
      required final bool isBoost}) = _$SnAttachmentDestinationImpl;

  factory _SnAttachmentDestination.fromJson(Map<String, dynamic> json) =
      _$SnAttachmentDestinationImpl.fromJson;

  @override
  int get id;
  @override
  String get type;
  @override
  String get label;
  @override
  String get region;
  @override
  bool get isBoost;

  /// Create a copy of SnAttachmentDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAttachmentDestinationImplCopyWith<_$SnAttachmentDestinationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SnAttachmentBoost _$SnAttachmentBoostFromJson(Map<String, dynamic> json) {
  return _SnAttachmentBoost.fromJson(json);
}

/// @nodoc
mixin _$SnAttachmentBoost {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  int get destination => throw _privateConstructorUsedError;
  int get attachmentId => throw _privateConstructorUsedError;
  SnAttachment get attachment => throw _privateConstructorUsedError;
  int get account => throw _privateConstructorUsedError;

  /// Serializes this SnAttachmentBoost to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAttachmentBoostCopyWith<SnAttachmentBoost> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAttachmentBoostCopyWith<$Res> {
  factory $SnAttachmentBoostCopyWith(
          SnAttachmentBoost value, $Res Function(SnAttachmentBoost) then) =
      _$SnAttachmentBoostCopyWithImpl<$Res, SnAttachmentBoost>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int status,
      int destination,
      int attachmentId,
      SnAttachment attachment,
      int account});

  $SnAttachmentCopyWith<$Res> get attachment;
}

/// @nodoc
class _$SnAttachmentBoostCopyWithImpl<$Res, $Val extends SnAttachmentBoost>
    implements $SnAttachmentBoostCopyWith<$Res> {
  _$SnAttachmentBoostCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? status = null,
    Object? destination = null,
    Object? attachmentId = null,
    Object? attachment = null,
    Object? account = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int,
      attachmentId: null == attachmentId
          ? _value.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int,
      attachment: null == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as SnAttachment,
      account: null == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res> get attachment {
    return $SnAttachmentCopyWith<$Res>(_value.attachment, (value) {
      return _then(_value.copyWith(attachment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnAttachmentBoostImplCopyWith<$Res>
    implements $SnAttachmentBoostCopyWith<$Res> {
  factory _$$SnAttachmentBoostImplCopyWith(_$SnAttachmentBoostImpl value,
          $Res Function(_$SnAttachmentBoostImpl) then) =
      __$$SnAttachmentBoostImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      int status,
      int destination,
      int attachmentId,
      SnAttachment attachment,
      int account});

  @override
  $SnAttachmentCopyWith<$Res> get attachment;
}

/// @nodoc
class __$$SnAttachmentBoostImplCopyWithImpl<$Res>
    extends _$SnAttachmentBoostCopyWithImpl<$Res, _$SnAttachmentBoostImpl>
    implements _$$SnAttachmentBoostImplCopyWith<$Res> {
  __$$SnAttachmentBoostImplCopyWithImpl(_$SnAttachmentBoostImpl _value,
      $Res Function(_$SnAttachmentBoostImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? status = null,
    Object? destination = null,
    Object? attachmentId = null,
    Object? attachment = null,
    Object? account = null,
  }) {
    return _then(_$SnAttachmentBoostImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      destination: null == destination
          ? _value.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int,
      attachmentId: null == attachmentId
          ? _value.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int,
      attachment: null == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as SnAttachment,
      account: null == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAttachmentBoostImpl implements _SnAttachmentBoost {
  const _$SnAttachmentBoostImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.status,
      required this.destination,
      required this.attachmentId,
      required this.attachment,
      required this.account});

  factory _$SnAttachmentBoostImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAttachmentBoostImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final int status;
  @override
  final int destination;
  @override
  final int attachmentId;
  @override
  final SnAttachment attachment;
  @override
  final int account;

  @override
  String toString() {
    return 'SnAttachmentBoost(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, status: $status, destination: $destination, attachmentId: $attachmentId, attachment: $attachment, account: $account)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAttachmentBoostImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.attachmentId, attachmentId) ||
                other.attachmentId == attachmentId) &&
            (identical(other.attachment, attachment) ||
                other.attachment == attachment) &&
            (identical(other.account, account) || other.account == account));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, updatedAt,
      deletedAt, status, destination, attachmentId, attachment, account);

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAttachmentBoostImplCopyWith<_$SnAttachmentBoostImpl> get copyWith =>
      __$$SnAttachmentBoostImplCopyWithImpl<_$SnAttachmentBoostImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAttachmentBoostImplToJson(
      this,
    );
  }
}

abstract class _SnAttachmentBoost implements SnAttachmentBoost {
  const factory _SnAttachmentBoost(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final int status,
      required final int destination,
      required final int attachmentId,
      required final SnAttachment attachment,
      required final int account}) = _$SnAttachmentBoostImpl;

  factory _SnAttachmentBoost.fromJson(Map<String, dynamic> json) =
      _$SnAttachmentBoostImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  int get status;
  @override
  int get destination;
  @override
  int get attachmentId;
  @override
  SnAttachment get attachment;
  @override
  int get account;

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAttachmentBoostImplCopyWith<_$SnAttachmentBoostImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnSticker _$SnStickerFromJson(Map<String, dynamic> json) {
  return _SnSticker.fromJson(json);
}

/// @nodoc
mixin _$SnSticker {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String get alias => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get attachmentId => throw _privateConstructorUsedError;
  SnAttachment get attachment => throw _privateConstructorUsedError;
  int get packId => throw _privateConstructorUsedError;
  SnStickerPack get pack => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;

  /// Serializes this SnSticker to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnStickerCopyWith<SnSticker> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnStickerCopyWith<$Res> {
  factory $SnStickerCopyWith(SnSticker value, $Res Function(SnSticker) then) =
      _$SnStickerCopyWithImpl<$Res, SnSticker>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String alias,
      String name,
      int attachmentId,
      SnAttachment attachment,
      int packId,
      SnStickerPack pack,
      int accountId});

  $SnAttachmentCopyWith<$Res> get attachment;
  $SnStickerPackCopyWith<$Res> get pack;
}

/// @nodoc
class _$SnStickerCopyWithImpl<$Res, $Val extends SnSticker>
    implements $SnStickerCopyWith<$Res> {
  _$SnStickerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? attachmentId = null,
    Object? attachment = null,
    Object? packId = null,
    Object? pack = null,
    Object? accountId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      attachmentId: null == attachmentId
          ? _value.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int,
      attachment: null == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as SnAttachment,
      packId: null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as int,
      pack: null == pack
          ? _value.pack
          : pack // ignore: cast_nullable_to_non_nullable
              as SnStickerPack,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res> get attachment {
    return $SnAttachmentCopyWith<$Res>(_value.attachment, (value) {
      return _then(_value.copyWith(attachment: value) as $Val);
    });
  }

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnStickerPackCopyWith<$Res> get pack {
    return $SnStickerPackCopyWith<$Res>(_value.pack, (value) {
      return _then(_value.copyWith(pack: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SnStickerImplCopyWith<$Res>
    implements $SnStickerCopyWith<$Res> {
  factory _$$SnStickerImplCopyWith(
          _$SnStickerImpl value, $Res Function(_$SnStickerImpl) then) =
      __$$SnStickerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String alias,
      String name,
      int attachmentId,
      SnAttachment attachment,
      int packId,
      SnStickerPack pack,
      int accountId});

  @override
  $SnAttachmentCopyWith<$Res> get attachment;
  @override
  $SnStickerPackCopyWith<$Res> get pack;
}

/// @nodoc
class __$$SnStickerImplCopyWithImpl<$Res>
    extends _$SnStickerCopyWithImpl<$Res, _$SnStickerImpl>
    implements _$$SnStickerImplCopyWith<$Res> {
  __$$SnStickerImplCopyWithImpl(
      _$SnStickerImpl _value, $Res Function(_$SnStickerImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? alias = null,
    Object? name = null,
    Object? attachmentId = null,
    Object? attachment = null,
    Object? packId = null,
    Object? pack = null,
    Object? accountId = null,
  }) {
    return _then(_$SnStickerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      alias: null == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      attachmentId: null == attachmentId
          ? _value.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int,
      attachment: null == attachment
          ? _value.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as SnAttachment,
      packId: null == packId
          ? _value.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as int,
      pack: null == pack
          ? _value.pack
          : pack // ignore: cast_nullable_to_non_nullable
              as SnStickerPack,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnStickerImpl implements _SnSticker {
  const _$SnStickerImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.alias,
      required this.name,
      required this.attachmentId,
      required this.attachment,
      required this.packId,
      required this.pack,
      required this.accountId});

  factory _$SnStickerImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnStickerImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String alias;
  @override
  final String name;
  @override
  final int attachmentId;
  @override
  final SnAttachment attachment;
  @override
  final int packId;
  @override
  final SnStickerPack pack;
  @override
  final int accountId;

  @override
  String toString() {
    return 'SnSticker(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, attachmentId: $attachmentId, attachment: $attachment, packId: $packId, pack: $pack, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnStickerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.attachmentId, attachmentId) ||
                other.attachmentId == attachmentId) &&
            (identical(other.attachment, attachment) ||
                other.attachment == attachment) &&
            (identical(other.packId, packId) || other.packId == packId) &&
            (identical(other.pack, pack) || other.pack == pack) &&
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
      alias,
      name,
      attachmentId,
      attachment,
      packId,
      pack,
      accountId);

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnStickerImplCopyWith<_$SnStickerImpl> get copyWith =>
      __$$SnStickerImplCopyWithImpl<_$SnStickerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnStickerImplToJson(
      this,
    );
  }
}

abstract class _SnSticker implements SnSticker {
  const factory _SnSticker(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final String alias,
      required final String name,
      required final int attachmentId,
      required final SnAttachment attachment,
      required final int packId,
      required final SnStickerPack pack,
      required final int accountId}) = _$SnStickerImpl;

  factory _SnSticker.fromJson(Map<String, dynamic> json) =
      _$SnStickerImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  String get alias;
  @override
  String get name;
  @override
  int get attachmentId;
  @override
  SnAttachment get attachment;
  @override
  int get packId;
  @override
  SnStickerPack get pack;
  @override
  int get accountId;

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnStickerImplCopyWith<_$SnStickerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnStickerPack _$SnStickerPackFromJson(Map<String, dynamic> json) {
  return _SnStickerPack.fromJson(json);
}

/// @nodoc
mixin _$SnStickerPack {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  String get prefix => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<SnSticker>? get stickers => throw _privateConstructorUsedError;
  int get accountId => throw _privateConstructorUsedError;

  /// Serializes this SnStickerPack to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnStickerPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnStickerPackCopyWith<SnStickerPack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnStickerPackCopyWith<$Res> {
  factory $SnStickerPackCopyWith(
          SnStickerPack value, $Res Function(SnStickerPack) then) =
      _$SnStickerPackCopyWithImpl<$Res, SnStickerPack>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String prefix,
      String name,
      String description,
      List<SnSticker>? stickers,
      int accountId});
}

/// @nodoc
class _$SnStickerPackCopyWithImpl<$Res, $Val extends SnStickerPack>
    implements $SnStickerPackCopyWith<$Res> {
  _$SnStickerPackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnStickerPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? prefix = null,
    Object? name = null,
    Object? description = null,
    Object? stickers = freezed,
    Object? accountId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      prefix: null == prefix
          ? _value.prefix
          : prefix // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      stickers: freezed == stickers
          ? _value.stickers
          : stickers // ignore: cast_nullable_to_non_nullable
              as List<SnSticker>?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnStickerPackImplCopyWith<$Res>
    implements $SnStickerPackCopyWith<$Res> {
  factory _$$SnStickerPackImplCopyWith(
          _$SnStickerPackImpl value, $Res Function(_$SnStickerPackImpl) then) =
      __$$SnStickerPackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String prefix,
      String name,
      String description,
      List<SnSticker>? stickers,
      int accountId});
}

/// @nodoc
class __$$SnStickerPackImplCopyWithImpl<$Res>
    extends _$SnStickerPackCopyWithImpl<$Res, _$SnStickerPackImpl>
    implements _$$SnStickerPackImplCopyWith<$Res> {
  __$$SnStickerPackImplCopyWithImpl(
      _$SnStickerPackImpl _value, $Res Function(_$SnStickerPackImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnStickerPack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? prefix = null,
    Object? name = null,
    Object? description = null,
    Object? stickers = freezed,
    Object? accountId = null,
  }) {
    return _then(_$SnStickerPackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      prefix: null == prefix
          ? _value.prefix
          : prefix // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      stickers: freezed == stickers
          ? _value._stickers
          : stickers // ignore: cast_nullable_to_non_nullable
              as List<SnSticker>?,
      accountId: null == accountId
          ? _value.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnStickerPackImpl implements _SnStickerPack {
  const _$SnStickerPackImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.prefix,
      required this.name,
      required this.description,
      required final List<SnSticker>? stickers,
      required this.accountId})
      : _stickers = stickers;

  factory _$SnStickerPackImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnStickerPackImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String prefix;
  @override
  final String name;
  @override
  final String description;
  final List<SnSticker>? _stickers;
  @override
  List<SnSticker>? get stickers {
    final value = _stickers;
    if (value == null) return null;
    if (_stickers is EqualUnmodifiableListView) return _stickers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int accountId;

  @override
  String toString() {
    return 'SnStickerPack(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, prefix: $prefix, name: $name, description: $description, stickers: $stickers, accountId: $accountId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnStickerPackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.prefix, prefix) || other.prefix == prefix) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._stickers, _stickers) &&
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
      prefix,
      name,
      description,
      const DeepCollectionEquality().hash(_stickers),
      accountId);

  /// Create a copy of SnStickerPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnStickerPackImplCopyWith<_$SnStickerPackImpl> get copyWith =>
      __$$SnStickerPackImplCopyWithImpl<_$SnStickerPackImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnStickerPackImplToJson(
      this,
    );
  }
}

abstract class _SnStickerPack implements SnStickerPack {
  const factory _SnStickerPack(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final DateTime? deletedAt,
      required final String prefix,
      required final String name,
      required final String description,
      required final List<SnSticker>? stickers,
      required final int accountId}) = _$SnStickerPackImpl;

  factory _SnStickerPack.fromJson(Map<String, dynamic> json) =
      _$SnStickerPackImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  String get prefix;
  @override
  String get name;
  @override
  String get description;
  @override
  List<SnSticker>? get stickers;
  @override
  int get accountId;

  /// Create a copy of SnStickerPack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnStickerPackImplCopyWith<_$SnStickerPackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SnAttachmentBilling _$SnAttachmentBillingFromJson(Map<String, dynamic> json) {
  return _SnAttachmentBilling.fromJson(json);
}

/// @nodoc
mixin _$SnAttachmentBilling {
  int get currentBytes => throw _privateConstructorUsedError;
  int get discountFileSize => throw _privateConstructorUsedError;
  double get includedRatio => throw _privateConstructorUsedError;

  /// Serializes this SnAttachmentBilling to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SnAttachmentBilling
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SnAttachmentBillingCopyWith<SnAttachmentBilling> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SnAttachmentBillingCopyWith<$Res> {
  factory $SnAttachmentBillingCopyWith(
          SnAttachmentBilling value, $Res Function(SnAttachmentBilling) then) =
      _$SnAttachmentBillingCopyWithImpl<$Res, SnAttachmentBilling>;
  @useResult
  $Res call({int currentBytes, int discountFileSize, double includedRatio});
}

/// @nodoc
class _$SnAttachmentBillingCopyWithImpl<$Res, $Val extends SnAttachmentBilling>
    implements $SnAttachmentBillingCopyWith<$Res> {
  _$SnAttachmentBillingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SnAttachmentBilling
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBytes = null,
    Object? discountFileSize = null,
    Object? includedRatio = null,
  }) {
    return _then(_value.copyWith(
      currentBytes: null == currentBytes
          ? _value.currentBytes
          : currentBytes // ignore: cast_nullable_to_non_nullable
              as int,
      discountFileSize: null == discountFileSize
          ? _value.discountFileSize
          : discountFileSize // ignore: cast_nullable_to_non_nullable
              as int,
      includedRatio: null == includedRatio
          ? _value.includedRatio
          : includedRatio // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SnAttachmentBillingImplCopyWith<$Res>
    implements $SnAttachmentBillingCopyWith<$Res> {
  factory _$$SnAttachmentBillingImplCopyWith(_$SnAttachmentBillingImpl value,
          $Res Function(_$SnAttachmentBillingImpl) then) =
      __$$SnAttachmentBillingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int currentBytes, int discountFileSize, double includedRatio});
}

/// @nodoc
class __$$SnAttachmentBillingImplCopyWithImpl<$Res>
    extends _$SnAttachmentBillingCopyWithImpl<$Res, _$SnAttachmentBillingImpl>
    implements _$$SnAttachmentBillingImplCopyWith<$Res> {
  __$$SnAttachmentBillingImplCopyWithImpl(_$SnAttachmentBillingImpl _value,
      $Res Function(_$SnAttachmentBillingImpl) _then)
      : super(_value, _then);

  /// Create a copy of SnAttachmentBilling
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBytes = null,
    Object? discountFileSize = null,
    Object? includedRatio = null,
  }) {
    return _then(_$SnAttachmentBillingImpl(
      currentBytes: null == currentBytes
          ? _value.currentBytes
          : currentBytes // ignore: cast_nullable_to_non_nullable
              as int,
      discountFileSize: null == discountFileSize
          ? _value.discountFileSize
          : discountFileSize // ignore: cast_nullable_to_non_nullable
              as int,
      includedRatio: null == includedRatio
          ? _value.includedRatio
          : includedRatio // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SnAttachmentBillingImpl implements _SnAttachmentBilling {
  const _$SnAttachmentBillingImpl(
      {required this.currentBytes,
      required this.discountFileSize,
      required this.includedRatio});

  factory _$SnAttachmentBillingImpl.fromJson(Map<String, dynamic> json) =>
      _$$SnAttachmentBillingImplFromJson(json);

  @override
  final int currentBytes;
  @override
  final int discountFileSize;
  @override
  final double includedRatio;

  @override
  String toString() {
    return 'SnAttachmentBilling(currentBytes: $currentBytes, discountFileSize: $discountFileSize, includedRatio: $includedRatio)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SnAttachmentBillingImpl &&
            (identical(other.currentBytes, currentBytes) ||
                other.currentBytes == currentBytes) &&
            (identical(other.discountFileSize, discountFileSize) ||
                other.discountFileSize == discountFileSize) &&
            (identical(other.includedRatio, includedRatio) ||
                other.includedRatio == includedRatio));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, currentBytes, discountFileSize, includedRatio);

  /// Create a copy of SnAttachmentBilling
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SnAttachmentBillingImplCopyWith<_$SnAttachmentBillingImpl> get copyWith =>
      __$$SnAttachmentBillingImplCopyWithImpl<_$SnAttachmentBillingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SnAttachmentBillingImplToJson(
      this,
    );
  }
}

abstract class _SnAttachmentBilling implements SnAttachmentBilling {
  const factory _SnAttachmentBilling(
      {required final int currentBytes,
      required final int discountFileSize,
      required final double includedRatio}) = _$SnAttachmentBillingImpl;

  factory _SnAttachmentBilling.fromJson(Map<String, dynamic> json) =
      _$SnAttachmentBillingImpl.fromJson;

  @override
  int get currentBytes;
  @override
  int get discountFileSize;
  @override
  double get includedRatio;

  /// Create a copy of SnAttachmentBilling
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SnAttachmentBillingImplCopyWith<_$SnAttachmentBillingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
