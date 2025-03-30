// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SnAttachment {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get rid;
  String get uuid;
  int get size;
  String get name;
  String get alt;
  String get mimetype;
  String get hash;
  int get destination;
  int get refCount;
  int get contentRating;
  int get qualityRating;
  DateTime? get cleanedAt;
  bool get isAnalyzed;
  bool get isSelfRef;
  bool get isIndexable;
  SnAttachment? get ref;
  int? get refId;
  SnAttachmentPool? get pool;
  int? get poolId;
  SnAccount? get account;
  int get accountId;
  int? get thumbnailId;
  SnAttachment? get thumbnail;
  int? get compressedId;
  SnAttachment? get compressed;
  List<SnAttachmentBoost> get boosts;
  Map<String, dynamic> get usermeta;
  Map<String, dynamic> get metadata;

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<SnAttachment> get copyWith =>
      _$SnAttachmentCopyWithImpl<SnAttachment>(
          this as SnAttachment, _$identity);

  /// Serializes this SnAttachment to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnAttachment &&
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
            (identical(other.account, account) || other.account == account) &&
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
            const DeepCollectionEquality().equals(other.boosts, boosts) &&
            const DeepCollectionEquality().equals(other.usermeta, usermeta) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
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
        account,
        accountId,
        thumbnailId,
        thumbnail,
        compressedId,
        compressed,
        const DeepCollectionEquality().hash(boosts),
        const DeepCollectionEquality().hash(usermeta),
        const DeepCollectionEquality().hash(metadata)
      ]);

  @override
  String toString() {
    return 'SnAttachment(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, rid: $rid, uuid: $uuid, size: $size, name: $name, alt: $alt, mimetype: $mimetype, hash: $hash, destination: $destination, refCount: $refCount, contentRating: $contentRating, qualityRating: $qualityRating, cleanedAt: $cleanedAt, isAnalyzed: $isAnalyzed, isSelfRef: $isSelfRef, isIndexable: $isIndexable, ref: $ref, refId: $refId, pool: $pool, poolId: $poolId, account: $account, accountId: $accountId, thumbnailId: $thumbnailId, thumbnail: $thumbnail, compressedId: $compressedId, compressed: $compressed, boosts: $boosts, usermeta: $usermeta, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $SnAttachmentCopyWith<$Res> {
  factory $SnAttachmentCopyWith(
          SnAttachment value, $Res Function(SnAttachment) _then) =
      _$SnAttachmentCopyWithImpl;
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
      SnAccount? account,
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
  $SnAccountCopyWith<$Res>? get account;
  $SnAttachmentCopyWith<$Res>? get thumbnail;
  $SnAttachmentCopyWith<$Res>? get compressed;
}

/// @nodoc
class _$SnAttachmentCopyWithImpl<$Res> implements $SnAttachmentCopyWith<$Res> {
  _$SnAttachmentCopyWithImpl(this._self, this._then);

  final SnAttachment _self;
  final $Res Function(SnAttachment) _then;

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
    Object? account = freezed,
    Object? accountId = null,
    Object? thumbnailId = freezed,
    Object? thumbnail = freezed,
    Object? compressedId = freezed,
    Object? compressed = freezed,
    Object? boosts = null,
    Object? usermeta = null,
    Object? metadata = null,
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
      rid: null == rid
          ? _self.rid
          : rid // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _self.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      mimetype: null == mimetype
          ? _self.mimetype
          : mimetype // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _self.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int,
      refCount: null == refCount
          ? _self.refCount
          : refCount // ignore: cast_nullable_to_non_nullable
              as int,
      contentRating: null == contentRating
          ? _self.contentRating
          : contentRating // ignore: cast_nullable_to_non_nullable
              as int,
      qualityRating: null == qualityRating
          ? _self.qualityRating
          : qualityRating // ignore: cast_nullable_to_non_nullable
              as int,
      cleanedAt: freezed == cleanedAt
          ? _self.cleanedAt
          : cleanedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAnalyzed: null == isAnalyzed
          ? _self.isAnalyzed
          : isAnalyzed // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelfRef: null == isSelfRef
          ? _self.isSelfRef
          : isSelfRef // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndexable: null == isIndexable
          ? _self.isIndexable
          : isIndexable // ignore: cast_nullable_to_non_nullable
              as bool,
      ref: freezed == ref
          ? _self.ref
          : ref // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      refId: freezed == refId
          ? _self.refId
          : refId // ignore: cast_nullable_to_non_nullable
              as int?,
      pool: freezed == pool
          ? _self.pool
          : pool // ignore: cast_nullable_to_non_nullable
              as SnAttachmentPool?,
      poolId: freezed == poolId
          ? _self.poolId
          : poolId // ignore: cast_nullable_to_non_nullable
              as int?,
      account: freezed == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailId: freezed == thumbnailId
          ? _self.thumbnailId
          : thumbnailId // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      compressedId: freezed == compressedId
          ? _self.compressedId
          : compressedId // ignore: cast_nullable_to_non_nullable
              as int?,
      compressed: freezed == compressed
          ? _self.compressed
          : compressed // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      boosts: null == boosts
          ? _self.boosts
          : boosts // ignore: cast_nullable_to_non_nullable
              as List<SnAttachmentBoost>,
      usermeta: null == usermeta
          ? _self.usermeta
          : usermeta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get ref {
    if (_self.ref == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.ref!, (value) {
      return _then(_self.copyWith(ref: value));
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentPoolCopyWith<$Res>? get pool {
    if (_self.pool == null) {
      return null;
    }

    return $SnAttachmentPoolCopyWith<$Res>(_self.pool!, (value) {
      return _then(_self.copyWith(pool: value));
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
      return null;
    }

    return $SnAccountCopyWith<$Res>(_self.account!, (value) {
      return _then(_self.copyWith(account: value));
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get thumbnail {
    if (_self.thumbnail == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.thumbnail!, (value) {
      return _then(_self.copyWith(thumbnail: value));
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get compressed {
    if (_self.compressed == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.compressed!, (value) {
      return _then(_self.copyWith(compressed: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnAttachment extends SnAttachment {
  const _SnAttachment(
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
      required this.account,
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
  factory _SnAttachment.fromJson(Map<String, dynamic> json) =>
      _$SnAttachmentFromJson(json);

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
  final SnAccount? account;
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

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnAttachmentCopyWith<_SnAttachment> get copyWith =>
      __$SnAttachmentCopyWithImpl<_SnAttachment>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnAttachmentToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnAttachment &&
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
            (identical(other.account, account) || other.account == account) &&
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
        account,
        accountId,
        thumbnailId,
        thumbnail,
        compressedId,
        compressed,
        const DeepCollectionEquality().hash(_boosts),
        const DeepCollectionEquality().hash(_usermeta),
        const DeepCollectionEquality().hash(_metadata)
      ]);

  @override
  String toString() {
    return 'SnAttachment(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, rid: $rid, uuid: $uuid, size: $size, name: $name, alt: $alt, mimetype: $mimetype, hash: $hash, destination: $destination, refCount: $refCount, contentRating: $contentRating, qualityRating: $qualityRating, cleanedAt: $cleanedAt, isAnalyzed: $isAnalyzed, isSelfRef: $isSelfRef, isIndexable: $isIndexable, ref: $ref, refId: $refId, pool: $pool, poolId: $poolId, account: $account, accountId: $accountId, thumbnailId: $thumbnailId, thumbnail: $thumbnail, compressedId: $compressedId, compressed: $compressed, boosts: $boosts, usermeta: $usermeta, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$SnAttachmentCopyWith<$Res>
    implements $SnAttachmentCopyWith<$Res> {
  factory _$SnAttachmentCopyWith(
          _SnAttachment value, $Res Function(_SnAttachment) _then) =
      __$SnAttachmentCopyWithImpl;
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
      SnAccount? account,
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
  $SnAccountCopyWith<$Res>? get account;
  @override
  $SnAttachmentCopyWith<$Res>? get thumbnail;
  @override
  $SnAttachmentCopyWith<$Res>? get compressed;
}

/// @nodoc
class __$SnAttachmentCopyWithImpl<$Res>
    implements _$SnAttachmentCopyWith<$Res> {
  __$SnAttachmentCopyWithImpl(this._self, this._then);

  final _SnAttachment _self;
  final $Res Function(_SnAttachment) _then;

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    Object? account = freezed,
    Object? accountId = null,
    Object? thumbnailId = freezed,
    Object? thumbnail = freezed,
    Object? compressedId = freezed,
    Object? compressed = freezed,
    Object? boosts = null,
    Object? usermeta = null,
    Object? metadata = null,
  }) {
    return _then(_SnAttachment(
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
      rid: null == rid
          ? _self.rid
          : rid // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _self.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      mimetype: null == mimetype
          ? _self.mimetype
          : mimetype // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _self.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int,
      refCount: null == refCount
          ? _self.refCount
          : refCount // ignore: cast_nullable_to_non_nullable
              as int,
      contentRating: null == contentRating
          ? _self.contentRating
          : contentRating // ignore: cast_nullable_to_non_nullable
              as int,
      qualityRating: null == qualityRating
          ? _self.qualityRating
          : qualityRating // ignore: cast_nullable_to_non_nullable
              as int,
      cleanedAt: freezed == cleanedAt
          ? _self.cleanedAt
          : cleanedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isAnalyzed: null == isAnalyzed
          ? _self.isAnalyzed
          : isAnalyzed // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelfRef: null == isSelfRef
          ? _self.isSelfRef
          : isSelfRef // ignore: cast_nullable_to_non_nullable
              as bool,
      isIndexable: null == isIndexable
          ? _self.isIndexable
          : isIndexable // ignore: cast_nullable_to_non_nullable
              as bool,
      ref: freezed == ref
          ? _self.ref
          : ref // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      refId: freezed == refId
          ? _self.refId
          : refId // ignore: cast_nullable_to_non_nullable
              as int?,
      pool: freezed == pool
          ? _self.pool
          : pool // ignore: cast_nullable_to_non_nullable
              as SnAttachmentPool?,
      poolId: freezed == poolId
          ? _self.poolId
          : poolId // ignore: cast_nullable_to_non_nullable
              as int?,
      account: freezed == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as SnAccount?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailId: freezed == thumbnailId
          ? _self.thumbnailId
          : thumbnailId // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _self.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      compressedId: freezed == compressedId
          ? _self.compressedId
          : compressedId // ignore: cast_nullable_to_non_nullable
              as int?,
      compressed: freezed == compressed
          ? _self.compressed
          : compressed // ignore: cast_nullable_to_non_nullable
              as SnAttachment?,
      boosts: null == boosts
          ? _self._boosts
          : boosts // ignore: cast_nullable_to_non_nullable
              as List<SnAttachmentBoost>,
      usermeta: null == usermeta
          ? _self._usermeta
          : usermeta // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get ref {
    if (_self.ref == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.ref!, (value) {
      return _then(_self.copyWith(ref: value));
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentPoolCopyWith<$Res>? get pool {
    if (_self.pool == null) {
      return null;
    }

    return $SnAttachmentPoolCopyWith<$Res>(_self.pool!, (value) {
      return _then(_self.copyWith(pool: value));
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAccountCopyWith<$Res>? get account {
    if (_self.account == null) {
      return null;
    }

    return $SnAccountCopyWith<$Res>(_self.account!, (value) {
      return _then(_self.copyWith(account: value));
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get thumbnail {
    if (_self.thumbnail == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.thumbnail!, (value) {
      return _then(_self.copyWith(thumbnail: value));
    });
  }

  /// Create a copy of SnAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res>? get compressed {
    if (_self.compressed == null) {
      return null;
    }

    return $SnAttachmentCopyWith<$Res>(_self.compressed!, (value) {
      return _then(_self.copyWith(compressed: value));
    });
  }
}

/// @nodoc
mixin _$SnAttachmentFragment {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get rid;
  String get uuid;
  int get size;
  String get name;
  String get alt;
  String get mimetype;
  String get hash;
  String? get fingerprint;
  Map<String, int> get fileChunks;
  List<String> get fileChunksMissing;

  /// Create a copy of SnAttachmentFragment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnAttachmentFragmentCopyWith<SnAttachmentFragment> get copyWith =>
      _$SnAttachmentFragmentCopyWithImpl<SnAttachmentFragment>(
          this as SnAttachmentFragment, _$identity);

  /// Serializes this SnAttachmentFragment to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnAttachmentFragment &&
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
                .equals(other.fileChunks, fileChunks) &&
            const DeepCollectionEquality()
                .equals(other.fileChunksMissing, fileChunksMissing));
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
      const DeepCollectionEquality().hash(fileChunks),
      const DeepCollectionEquality().hash(fileChunksMissing));

  @override
  String toString() {
    return 'SnAttachmentFragment(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, rid: $rid, uuid: $uuid, size: $size, name: $name, alt: $alt, mimetype: $mimetype, hash: $hash, fingerprint: $fingerprint, fileChunks: $fileChunks, fileChunksMissing: $fileChunksMissing)';
  }
}

/// @nodoc
abstract mixin class $SnAttachmentFragmentCopyWith<$Res> {
  factory $SnAttachmentFragmentCopyWith(SnAttachmentFragment value,
          $Res Function(SnAttachmentFragment) _then) =
      _$SnAttachmentFragmentCopyWithImpl;
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
class _$SnAttachmentFragmentCopyWithImpl<$Res>
    implements $SnAttachmentFragmentCopyWith<$Res> {
  _$SnAttachmentFragmentCopyWithImpl(this._self, this._then);

  final SnAttachmentFragment _self;
  final $Res Function(SnAttachmentFragment) _then;

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
      rid: null == rid
          ? _self.rid
          : rid // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _self.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      mimetype: null == mimetype
          ? _self.mimetype
          : mimetype // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _self.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      fingerprint: freezed == fingerprint
          ? _self.fingerprint
          : fingerprint // ignore: cast_nullable_to_non_nullable
              as String?,
      fileChunks: null == fileChunks
          ? _self.fileChunks
          : fileChunks // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      fileChunksMissing: null == fileChunksMissing
          ? _self.fileChunksMissing
          : fileChunksMissing // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnAttachmentFragment extends SnAttachmentFragment {
  const _SnAttachmentFragment(
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
  factory _SnAttachmentFragment.fromJson(Map<String, dynamic> json) =>
      _$SnAttachmentFragmentFromJson(json);

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

  /// Create a copy of SnAttachmentFragment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnAttachmentFragmentCopyWith<_SnAttachmentFragment> get copyWith =>
      __$SnAttachmentFragmentCopyWithImpl<_SnAttachmentFragment>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnAttachmentFragmentToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnAttachmentFragment &&
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

  @override
  String toString() {
    return 'SnAttachmentFragment(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, rid: $rid, uuid: $uuid, size: $size, name: $name, alt: $alt, mimetype: $mimetype, hash: $hash, fingerprint: $fingerprint, fileChunks: $fileChunks, fileChunksMissing: $fileChunksMissing)';
  }
}

/// @nodoc
abstract mixin class _$SnAttachmentFragmentCopyWith<$Res>
    implements $SnAttachmentFragmentCopyWith<$Res> {
  factory _$SnAttachmentFragmentCopyWith(_SnAttachmentFragment value,
          $Res Function(_SnAttachmentFragment) _then) =
      __$SnAttachmentFragmentCopyWithImpl;
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
class __$SnAttachmentFragmentCopyWithImpl<$Res>
    implements _$SnAttachmentFragmentCopyWith<$Res> {
  __$SnAttachmentFragmentCopyWithImpl(this._self, this._then);

  final _SnAttachmentFragment _self;
  final $Res Function(_SnAttachmentFragment) _then;

  /// Create a copy of SnAttachmentFragment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnAttachmentFragment(
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
      rid: null == rid
          ? _self.rid
          : rid // ignore: cast_nullable_to_non_nullable
              as String,
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      alt: null == alt
          ? _self.alt
          : alt // ignore: cast_nullable_to_non_nullable
              as String,
      mimetype: null == mimetype
          ? _self.mimetype
          : mimetype // ignore: cast_nullable_to_non_nullable
              as String,
      hash: null == hash
          ? _self.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      fingerprint: freezed == fingerprint
          ? _self.fingerprint
          : fingerprint // ignore: cast_nullable_to_non_nullable
              as String?,
      fileChunks: null == fileChunks
          ? _self._fileChunks
          : fileChunks // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      fileChunksMissing: null == fileChunksMissing
          ? _self._fileChunksMissing
          : fileChunksMissing // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$SnAttachmentPool {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get alias;
  String get name;
  String get description;
  Map<String, dynamic> get config;
  int? get accountId;

  /// Create a copy of SnAttachmentPool
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnAttachmentPoolCopyWith<SnAttachmentPool> get copyWith =>
      _$SnAttachmentPoolCopyWithImpl<SnAttachmentPool>(
          this as SnAttachmentPool, _$identity);

  /// Serializes this SnAttachmentPool to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnAttachmentPool &&
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
            const DeepCollectionEquality().equals(other.config, config) &&
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
      const DeepCollectionEquality().hash(config),
      accountId);

  @override
  String toString() {
    return 'SnAttachmentPool(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, config: $config, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class $SnAttachmentPoolCopyWith<$Res> {
  factory $SnAttachmentPoolCopyWith(
          SnAttachmentPool value, $Res Function(SnAttachmentPool) _then) =
      _$SnAttachmentPoolCopyWithImpl;
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
class _$SnAttachmentPoolCopyWithImpl<$Res>
    implements $SnAttachmentPoolCopyWith<$Res> {
  _$SnAttachmentPoolCopyWithImpl(this._self, this._then);

  final SnAttachmentPool _self;
  final $Res Function(SnAttachmentPool) _then;

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
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      config: null == config
          ? _self.config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnAttachmentPool implements SnAttachmentPool {
  const _SnAttachmentPool(
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
  factory _SnAttachmentPool.fromJson(Map<String, dynamic> json) =>
      _$SnAttachmentPoolFromJson(json);

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

  /// Create a copy of SnAttachmentPool
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnAttachmentPoolCopyWith<_SnAttachmentPool> get copyWith =>
      __$SnAttachmentPoolCopyWithImpl<_SnAttachmentPool>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnAttachmentPoolToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnAttachmentPool &&
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

  @override
  String toString() {
    return 'SnAttachmentPool(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, description: $description, config: $config, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class _$SnAttachmentPoolCopyWith<$Res>
    implements $SnAttachmentPoolCopyWith<$Res> {
  factory _$SnAttachmentPoolCopyWith(
          _SnAttachmentPool value, $Res Function(_SnAttachmentPool) _then) =
      __$SnAttachmentPoolCopyWithImpl;
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
class __$SnAttachmentPoolCopyWithImpl<$Res>
    implements _$SnAttachmentPoolCopyWith<$Res> {
  __$SnAttachmentPoolCopyWithImpl(this._self, this._then);

  final _SnAttachmentPool _self;
  final $Res Function(_SnAttachmentPool) _then;

  /// Create a copy of SnAttachmentPool
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnAttachmentPool(
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
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      config: null == config
          ? _self._config
          : config // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      accountId: freezed == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$SnAttachmentDestination {
  int get id;
  String get type;
  String get label;
  String get region;
  bool get isBoost;

  /// Create a copy of SnAttachmentDestination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnAttachmentDestinationCopyWith<SnAttachmentDestination> get copyWith =>
      _$SnAttachmentDestinationCopyWithImpl<SnAttachmentDestination>(
          this as SnAttachmentDestination, _$identity);

  /// Serializes this SnAttachmentDestination to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnAttachmentDestination &&
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

  @override
  String toString() {
    return 'SnAttachmentDestination(id: $id, type: $type, label: $label, region: $region, isBoost: $isBoost)';
  }
}

/// @nodoc
abstract mixin class $SnAttachmentDestinationCopyWith<$Res> {
  factory $SnAttachmentDestinationCopyWith(SnAttachmentDestination value,
          $Res Function(SnAttachmentDestination) _then) =
      _$SnAttachmentDestinationCopyWithImpl;
  @useResult
  $Res call({int id, String type, String label, String region, bool isBoost});
}

/// @nodoc
class _$SnAttachmentDestinationCopyWithImpl<$Res>
    implements $SnAttachmentDestinationCopyWith<$Res> {
  _$SnAttachmentDestinationCopyWithImpl(this._self, this._then);

  final SnAttachmentDestination _self;
  final $Res Function(SnAttachmentDestination) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _self.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      isBoost: null == isBoost
          ? _self.isBoost
          : isBoost // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnAttachmentDestination implements SnAttachmentDestination {
  const _SnAttachmentDestination(
      {this.id = 0,
      required this.type,
      required this.label,
      required this.region,
      required this.isBoost});
  factory _SnAttachmentDestination.fromJson(Map<String, dynamic> json) =>
      _$SnAttachmentDestinationFromJson(json);

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

  /// Create a copy of SnAttachmentDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnAttachmentDestinationCopyWith<_SnAttachmentDestination> get copyWith =>
      __$SnAttachmentDestinationCopyWithImpl<_SnAttachmentDestination>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnAttachmentDestinationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnAttachmentDestination &&
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

  @override
  String toString() {
    return 'SnAttachmentDestination(id: $id, type: $type, label: $label, region: $region, isBoost: $isBoost)';
  }
}

/// @nodoc
abstract mixin class _$SnAttachmentDestinationCopyWith<$Res>
    implements $SnAttachmentDestinationCopyWith<$Res> {
  factory _$SnAttachmentDestinationCopyWith(_SnAttachmentDestination value,
          $Res Function(_SnAttachmentDestination) _then) =
      __$SnAttachmentDestinationCopyWithImpl;
  @override
  @useResult
  $Res call({int id, String type, String label, String region, bool isBoost});
}

/// @nodoc
class __$SnAttachmentDestinationCopyWithImpl<$Res>
    implements _$SnAttachmentDestinationCopyWith<$Res> {
  __$SnAttachmentDestinationCopyWithImpl(this._self, this._then);

  final _SnAttachmentDestination _self;
  final $Res Function(_SnAttachmentDestination) _then;

  /// Create a copy of SnAttachmentDestination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? label = null,
    Object? region = null,
    Object? isBoost = null,
  }) {
    return _then(_SnAttachmentDestination(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      region: null == region
          ? _self.region
          : region // ignore: cast_nullable_to_non_nullable
              as String,
      isBoost: null == isBoost
          ? _self.isBoost
          : isBoost // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$SnAttachmentBoost {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  int get status;
  int get destination;
  int get attachmentId;
  SnAttachment get attachment;
  int get account;

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnAttachmentBoostCopyWith<SnAttachmentBoost> get copyWith =>
      _$SnAttachmentBoostCopyWithImpl<SnAttachmentBoost>(
          this as SnAttachmentBoost, _$identity);

  /// Serializes this SnAttachmentBoost to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnAttachmentBoost &&
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

  @override
  String toString() {
    return 'SnAttachmentBoost(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, status: $status, destination: $destination, attachmentId: $attachmentId, attachment: $attachment, account: $account)';
  }
}

/// @nodoc
abstract mixin class $SnAttachmentBoostCopyWith<$Res> {
  factory $SnAttachmentBoostCopyWith(
          SnAttachmentBoost value, $Res Function(SnAttachmentBoost) _then) =
      _$SnAttachmentBoostCopyWithImpl;
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
class _$SnAttachmentBoostCopyWithImpl<$Res>
    implements $SnAttachmentBoostCopyWith<$Res> {
  _$SnAttachmentBoostCopyWithImpl(this._self, this._then);

  final SnAttachmentBoost _self;
  final $Res Function(SnAttachmentBoost) _then;

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
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int,
      attachmentId: null == attachmentId
          ? _self.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int,
      attachment: null == attachment
          ? _self.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as SnAttachment,
      account: null == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res> get attachment {
    return $SnAttachmentCopyWith<$Res>(_self.attachment, (value) {
      return _then(_self.copyWith(attachment: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnAttachmentBoost implements SnAttachmentBoost {
  const _SnAttachmentBoost(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.status,
      required this.destination,
      required this.attachmentId,
      required this.attachment,
      required this.account});
  factory _SnAttachmentBoost.fromJson(Map<String, dynamic> json) =>
      _$SnAttachmentBoostFromJson(json);

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

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnAttachmentBoostCopyWith<_SnAttachmentBoost> get copyWith =>
      __$SnAttachmentBoostCopyWithImpl<_SnAttachmentBoost>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnAttachmentBoostToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnAttachmentBoost &&
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

  @override
  String toString() {
    return 'SnAttachmentBoost(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, status: $status, destination: $destination, attachmentId: $attachmentId, attachment: $attachment, account: $account)';
  }
}

/// @nodoc
abstract mixin class _$SnAttachmentBoostCopyWith<$Res>
    implements $SnAttachmentBoostCopyWith<$Res> {
  factory _$SnAttachmentBoostCopyWith(
          _SnAttachmentBoost value, $Res Function(_SnAttachmentBoost) _then) =
      __$SnAttachmentBoostCopyWithImpl;
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
class __$SnAttachmentBoostCopyWithImpl<$Res>
    implements _$SnAttachmentBoostCopyWith<$Res> {
  __$SnAttachmentBoostCopyWithImpl(this._self, this._then);

  final _SnAttachmentBoost _self;
  final $Res Function(_SnAttachmentBoost) _then;

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnAttachmentBoost(
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
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      destination: null == destination
          ? _self.destination
          : destination // ignore: cast_nullable_to_non_nullable
              as int,
      attachmentId: null == attachmentId
          ? _self.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int,
      attachment: null == attachment
          ? _self.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as SnAttachment,
      account: null == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of SnAttachmentBoost
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res> get attachment {
    return $SnAttachmentCopyWith<$Res>(_self.attachment, (value) {
      return _then(_self.copyWith(attachment: value));
    });
  }
}

/// @nodoc
mixin _$SnSticker {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get alias;
  String get name;
  int get attachmentId;
  SnAttachment get attachment;
  int get packId;
  SnStickerPack get pack;
  int get accountId;

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnStickerCopyWith<SnSticker> get copyWith =>
      _$SnStickerCopyWithImpl<SnSticker>(this as SnSticker, _$identity);

  /// Serializes this SnSticker to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnSticker &&
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

  @override
  String toString() {
    return 'SnSticker(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, attachmentId: $attachmentId, attachment: $attachment, packId: $packId, pack: $pack, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class $SnStickerCopyWith<$Res> {
  factory $SnStickerCopyWith(SnSticker value, $Res Function(SnSticker) _then) =
      _$SnStickerCopyWithImpl;
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
class _$SnStickerCopyWithImpl<$Res> implements $SnStickerCopyWith<$Res> {
  _$SnStickerCopyWithImpl(this._self, this._then);

  final SnSticker _self;
  final $Res Function(SnSticker) _then;

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
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      attachmentId: null == attachmentId
          ? _self.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int,
      attachment: null == attachment
          ? _self.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as SnAttachment,
      packId: null == packId
          ? _self.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as int,
      pack: null == pack
          ? _self.pack
          : pack // ignore: cast_nullable_to_non_nullable
              as SnStickerPack,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res> get attachment {
    return $SnAttachmentCopyWith<$Res>(_self.attachment, (value) {
      return _then(_self.copyWith(attachment: value));
    });
  }

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnStickerPackCopyWith<$Res> get pack {
    return $SnStickerPackCopyWith<$Res>(_self.pack, (value) {
      return _then(_self.copyWith(pack: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _SnSticker implements SnSticker {
  const _SnSticker(
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
  factory _SnSticker.fromJson(Map<String, dynamic> json) =>
      _$SnStickerFromJson(json);

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

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnStickerCopyWith<_SnSticker> get copyWith =>
      __$SnStickerCopyWithImpl<_SnSticker>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnStickerToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnSticker &&
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

  @override
  String toString() {
    return 'SnSticker(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, alias: $alias, name: $name, attachmentId: $attachmentId, attachment: $attachment, packId: $packId, pack: $pack, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class _$SnStickerCopyWith<$Res>
    implements $SnStickerCopyWith<$Res> {
  factory _$SnStickerCopyWith(
          _SnSticker value, $Res Function(_SnSticker) _then) =
      __$SnStickerCopyWithImpl;
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
class __$SnStickerCopyWithImpl<$Res> implements _$SnStickerCopyWith<$Res> {
  __$SnStickerCopyWithImpl(this._self, this._then);

  final _SnSticker _self;
  final $Res Function(_SnSticker) _then;

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnSticker(
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
      alias: null == alias
          ? _self.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      attachmentId: null == attachmentId
          ? _self.attachmentId
          : attachmentId // ignore: cast_nullable_to_non_nullable
              as int,
      attachment: null == attachment
          ? _self.attachment
          : attachment // ignore: cast_nullable_to_non_nullable
              as SnAttachment,
      packId: null == packId
          ? _self.packId
          : packId // ignore: cast_nullable_to_non_nullable
              as int,
      pack: null == pack
          ? _self.pack
          : pack // ignore: cast_nullable_to_non_nullable
              as SnStickerPack,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnAttachmentCopyWith<$Res> get attachment {
    return $SnAttachmentCopyWith<$Res>(_self.attachment, (value) {
      return _then(_self.copyWith(attachment: value));
    });
  }

  /// Create a copy of SnSticker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SnStickerPackCopyWith<$Res> get pack {
    return $SnStickerPackCopyWith<$Res>(_self.pack, (value) {
      return _then(_self.copyWith(pack: value));
    });
  }
}

/// @nodoc
mixin _$SnStickerPack {
  int get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get prefix;
  String get name;
  String get description;
  List<SnSticker>? get stickers;
  int get accountId;

  /// Create a copy of SnStickerPack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnStickerPackCopyWith<SnStickerPack> get copyWith =>
      _$SnStickerPackCopyWithImpl<SnStickerPack>(
          this as SnStickerPack, _$identity);

  /// Serializes this SnStickerPack to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnStickerPack &&
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
            const DeepCollectionEquality().equals(other.stickers, stickers) &&
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
      const DeepCollectionEquality().hash(stickers),
      accountId);

  @override
  String toString() {
    return 'SnStickerPack(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, prefix: $prefix, name: $name, description: $description, stickers: $stickers, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class $SnStickerPackCopyWith<$Res> {
  factory $SnStickerPackCopyWith(
          SnStickerPack value, $Res Function(SnStickerPack) _then) =
      _$SnStickerPackCopyWithImpl;
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
class _$SnStickerPackCopyWithImpl<$Res>
    implements $SnStickerPackCopyWith<$Res> {
  _$SnStickerPackCopyWithImpl(this._self, this._then);

  final SnStickerPack _self;
  final $Res Function(SnStickerPack) _then;

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
      prefix: null == prefix
          ? _self.prefix
          : prefix // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      stickers: freezed == stickers
          ? _self.stickers
          : stickers // ignore: cast_nullable_to_non_nullable
              as List<SnSticker>?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnStickerPack implements SnStickerPack {
  const _SnStickerPack(
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
  factory _SnStickerPack.fromJson(Map<String, dynamic> json) =>
      _$SnStickerPackFromJson(json);

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

  /// Create a copy of SnStickerPack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnStickerPackCopyWith<_SnStickerPack> get copyWith =>
      __$SnStickerPackCopyWithImpl<_SnStickerPack>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnStickerPackToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnStickerPack &&
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

  @override
  String toString() {
    return 'SnStickerPack(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, prefix: $prefix, name: $name, description: $description, stickers: $stickers, accountId: $accountId)';
  }
}

/// @nodoc
abstract mixin class _$SnStickerPackCopyWith<$Res>
    implements $SnStickerPackCopyWith<$Res> {
  factory _$SnStickerPackCopyWith(
          _SnStickerPack value, $Res Function(_SnStickerPack) _then) =
      __$SnStickerPackCopyWithImpl;
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
class __$SnStickerPackCopyWithImpl<$Res>
    implements _$SnStickerPackCopyWith<$Res> {
  __$SnStickerPackCopyWithImpl(this._self, this._then);

  final _SnStickerPack _self;
  final $Res Function(_SnStickerPack) _then;

  /// Create a copy of SnStickerPack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_SnStickerPack(
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
      prefix: null == prefix
          ? _self.prefix
          : prefix // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      stickers: freezed == stickers
          ? _self._stickers
          : stickers // ignore: cast_nullable_to_non_nullable
              as List<SnSticker>?,
      accountId: null == accountId
          ? _self.accountId
          : accountId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$SnAttachmentBilling {
  int get currentBytes;
  int get discountFileSize;
  double get includedRatio;

  /// Create a copy of SnAttachmentBilling
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SnAttachmentBillingCopyWith<SnAttachmentBilling> get copyWith =>
      _$SnAttachmentBillingCopyWithImpl<SnAttachmentBilling>(
          this as SnAttachmentBilling, _$identity);

  /// Serializes this SnAttachmentBilling to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SnAttachmentBilling &&
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

  @override
  String toString() {
    return 'SnAttachmentBilling(currentBytes: $currentBytes, discountFileSize: $discountFileSize, includedRatio: $includedRatio)';
  }
}

/// @nodoc
abstract mixin class $SnAttachmentBillingCopyWith<$Res> {
  factory $SnAttachmentBillingCopyWith(
          SnAttachmentBilling value, $Res Function(SnAttachmentBilling) _then) =
      _$SnAttachmentBillingCopyWithImpl;
  @useResult
  $Res call({int currentBytes, int discountFileSize, double includedRatio});
}

/// @nodoc
class _$SnAttachmentBillingCopyWithImpl<$Res>
    implements $SnAttachmentBillingCopyWith<$Res> {
  _$SnAttachmentBillingCopyWithImpl(this._self, this._then);

  final SnAttachmentBilling _self;
  final $Res Function(SnAttachmentBilling) _then;

  /// Create a copy of SnAttachmentBilling
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentBytes = null,
    Object? discountFileSize = null,
    Object? includedRatio = null,
  }) {
    return _then(_self.copyWith(
      currentBytes: null == currentBytes
          ? _self.currentBytes
          : currentBytes // ignore: cast_nullable_to_non_nullable
              as int,
      discountFileSize: null == discountFileSize
          ? _self.discountFileSize
          : discountFileSize // ignore: cast_nullable_to_non_nullable
              as int,
      includedRatio: null == includedRatio
          ? _self.includedRatio
          : includedRatio // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SnAttachmentBilling implements SnAttachmentBilling {
  const _SnAttachmentBilling(
      {required this.currentBytes,
      required this.discountFileSize,
      required this.includedRatio});
  factory _SnAttachmentBilling.fromJson(Map<String, dynamic> json) =>
      _$SnAttachmentBillingFromJson(json);

  @override
  final int currentBytes;
  @override
  final int discountFileSize;
  @override
  final double includedRatio;

  /// Create a copy of SnAttachmentBilling
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SnAttachmentBillingCopyWith<_SnAttachmentBilling> get copyWith =>
      __$SnAttachmentBillingCopyWithImpl<_SnAttachmentBilling>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SnAttachmentBillingToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SnAttachmentBilling &&
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

  @override
  String toString() {
    return 'SnAttachmentBilling(currentBytes: $currentBytes, discountFileSize: $discountFileSize, includedRatio: $includedRatio)';
  }
}

/// @nodoc
abstract mixin class _$SnAttachmentBillingCopyWith<$Res>
    implements $SnAttachmentBillingCopyWith<$Res> {
  factory _$SnAttachmentBillingCopyWith(_SnAttachmentBilling value,
          $Res Function(_SnAttachmentBilling) _then) =
      __$SnAttachmentBillingCopyWithImpl;
  @override
  @useResult
  $Res call({int currentBytes, int discountFileSize, double includedRatio});
}

/// @nodoc
class __$SnAttachmentBillingCopyWithImpl<$Res>
    implements _$SnAttachmentBillingCopyWith<$Res> {
  __$SnAttachmentBillingCopyWithImpl(this._self, this._then);

  final _SnAttachmentBilling _self;
  final $Res Function(_SnAttachmentBilling) _then;

  /// Create a copy of SnAttachmentBilling
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currentBytes = null,
    Object? discountFileSize = null,
    Object? includedRatio = null,
  }) {
    return _then(_SnAttachmentBilling(
      currentBytes: null == currentBytes
          ? _self.currentBytes
          : currentBytes // ignore: cast_nullable_to_non_nullable
              as int,
      discountFileSize: null == discountFileSize
          ? _self.discountFileSize
          : discountFileSize // ignore: cast_nullable_to_non_nullable
              as int,
      includedRatio: null == includedRatio
          ? _self.includedRatio
          : includedRatio // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
