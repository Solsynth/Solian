// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drive_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriveTask {

 String get id; String get taskId; String get fileName; String get contentType; int get fileSize; int get uploadedBytes; int get totalChunks; int get uploadedChunks; DriveTaskStatus get status; DateTime get createdAt; DateTime get updatedAt; String get type;// Task type (e.g., 'FileUpload')
 double? get transmissionProgress;// Local file upload progress (0.0-1.0)
 String? get errorMessage; SnCloudFile? get result; String? get poolId; String? get bundleId; String? get encryptPassword; String? get expiredAt;
/// Create a copy of DriveTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveTaskCopyWith<DriveTask> get copyWith => _$DriveTaskCopyWithImpl<DriveTask>(this as DriveTask, _$identity);

  /// Serializes this DriveTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveTask&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.uploadedBytes, uploadedBytes) || other.uploadedBytes == uploadedBytes)&&(identical(other.totalChunks, totalChunks) || other.totalChunks == totalChunks)&&(identical(other.uploadedChunks, uploadedChunks) || other.uploadedChunks == uploadedChunks)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.transmissionProgress, transmissionProgress) || other.transmissionProgress == transmissionProgress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.result, result) || other.result == result)&&(identical(other.poolId, poolId) || other.poolId == poolId)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.encryptPassword, encryptPassword) || other.encryptPassword == encryptPassword)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,taskId,fileName,contentType,fileSize,uploadedBytes,totalChunks,uploadedChunks,status,createdAt,updatedAt,type,transmissionProgress,errorMessage,result,poolId,bundleId,encryptPassword,expiredAt]);

@override
String toString() {
  return 'DriveTask(id: $id, taskId: $taskId, fileName: $fileName, contentType: $contentType, fileSize: $fileSize, uploadedBytes: $uploadedBytes, totalChunks: $totalChunks, uploadedChunks: $uploadedChunks, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, type: $type, transmissionProgress: $transmissionProgress, errorMessage: $errorMessage, result: $result, poolId: $poolId, bundleId: $bundleId, encryptPassword: $encryptPassword, expiredAt: $expiredAt)';
}


}

/// @nodoc
abstract mixin class $DriveTaskCopyWith<$Res>  {
  factory $DriveTaskCopyWith(DriveTask value, $Res Function(DriveTask) _then) = _$DriveTaskCopyWithImpl;
@useResult
$Res call({
 String id, String taskId, String fileName, String contentType, int fileSize, int uploadedBytes, int totalChunks, int uploadedChunks, DriveTaskStatus status, DateTime createdAt, DateTime updatedAt, String type, double? transmissionProgress, String? errorMessage, SnCloudFile? result, String? poolId, String? bundleId, String? encryptPassword, String? expiredAt
});


$SnCloudFileCopyWith<$Res>? get result;

}
/// @nodoc
class _$DriveTaskCopyWithImpl<$Res>
    implements $DriveTaskCopyWith<$Res> {
  _$DriveTaskCopyWithImpl(this._self, this._then);

  final DriveTask _self;
  final $Res Function(DriveTask) _then;

/// Create a copy of DriveTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? fileName = null,Object? contentType = null,Object? fileSize = null,Object? uploadedBytes = null,Object? totalChunks = null,Object? uploadedChunks = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? type = null,Object? transmissionProgress = freezed,Object? errorMessage = freezed,Object? result = freezed,Object? poolId = freezed,Object? bundleId = freezed,Object? encryptPassword = freezed,Object? expiredAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,uploadedBytes: null == uploadedBytes ? _self.uploadedBytes : uploadedBytes // ignore: cast_nullable_to_non_nullable
as int,totalChunks: null == totalChunks ? _self.totalChunks : totalChunks // ignore: cast_nullable_to_non_nullable
as int,uploadedChunks: null == uploadedChunks ? _self.uploadedChunks : uploadedChunks // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DriveTaskStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,transmissionProgress: freezed == transmissionProgress ? _self.transmissionProgress : transmissionProgress // ignore: cast_nullable_to_non_nullable
as double?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,poolId: freezed == poolId ? _self.poolId : poolId // ignore: cast_nullable_to_non_nullable
as String?,bundleId: freezed == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String?,encryptPassword: freezed == encryptPassword ? _self.encryptPassword : encryptPassword // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of DriveTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [DriveTask].
extension DriveTaskPatterns on DriveTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriveTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriveTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriveTask value)  $default,){
final _that = this;
switch (_that) {
case _DriveTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriveTask value)?  $default,){
final _that = this;
switch (_that) {
case _DriveTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String taskId,  String fileName,  String contentType,  int fileSize,  int uploadedBytes,  int totalChunks,  int uploadedChunks,  DriveTaskStatus status,  DateTime createdAt,  DateTime updatedAt,  String type,  double? transmissionProgress,  String? errorMessage,  SnCloudFile? result,  String? poolId,  String? bundleId,  String? encryptPassword,  String? expiredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriveTask() when $default != null:
return $default(_that.id,_that.taskId,_that.fileName,_that.contentType,_that.fileSize,_that.uploadedBytes,_that.totalChunks,_that.uploadedChunks,_that.status,_that.createdAt,_that.updatedAt,_that.type,_that.transmissionProgress,_that.errorMessage,_that.result,_that.poolId,_that.bundleId,_that.encryptPassword,_that.expiredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String taskId,  String fileName,  String contentType,  int fileSize,  int uploadedBytes,  int totalChunks,  int uploadedChunks,  DriveTaskStatus status,  DateTime createdAt,  DateTime updatedAt,  String type,  double? transmissionProgress,  String? errorMessage,  SnCloudFile? result,  String? poolId,  String? bundleId,  String? encryptPassword,  String? expiredAt)  $default,) {final _that = this;
switch (_that) {
case _DriveTask():
return $default(_that.id,_that.taskId,_that.fileName,_that.contentType,_that.fileSize,_that.uploadedBytes,_that.totalChunks,_that.uploadedChunks,_that.status,_that.createdAt,_that.updatedAt,_that.type,_that.transmissionProgress,_that.errorMessage,_that.result,_that.poolId,_that.bundleId,_that.encryptPassword,_that.expiredAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String taskId,  String fileName,  String contentType,  int fileSize,  int uploadedBytes,  int totalChunks,  int uploadedChunks,  DriveTaskStatus status,  DateTime createdAt,  DateTime updatedAt,  String type,  double? transmissionProgress,  String? errorMessage,  SnCloudFile? result,  String? poolId,  String? bundleId,  String? encryptPassword,  String? expiredAt)?  $default,) {final _that = this;
switch (_that) {
case _DriveTask() when $default != null:
return $default(_that.id,_that.taskId,_that.fileName,_that.contentType,_that.fileSize,_that.uploadedBytes,_that.totalChunks,_that.uploadedChunks,_that.status,_that.createdAt,_that.updatedAt,_that.type,_that.transmissionProgress,_that.errorMessage,_that.result,_that.poolId,_that.bundleId,_that.encryptPassword,_that.expiredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriveTask extends DriveTask {
  const _DriveTask({required this.id, required this.taskId, required this.fileName, required this.contentType, required this.fileSize, required this.uploadedBytes, required this.totalChunks, required this.uploadedChunks, required this.status, required this.createdAt, required this.updatedAt, required this.type, this.transmissionProgress, this.errorMessage, this.result, this.poolId, this.bundleId, this.encryptPassword, this.expiredAt}): super._();
  factory _DriveTask.fromJson(Map<String, dynamic> json) => _$DriveTaskFromJson(json);

@override final  String id;
@override final  String taskId;
@override final  String fileName;
@override final  String contentType;
@override final  int fileSize;
@override final  int uploadedBytes;
@override final  int totalChunks;
@override final  int uploadedChunks;
@override final  DriveTaskStatus status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String type;
// Task type (e.g., 'FileUpload')
@override final  double? transmissionProgress;
// Local file upload progress (0.0-1.0)
@override final  String? errorMessage;
@override final  SnCloudFile? result;
@override final  String? poolId;
@override final  String? bundleId;
@override final  String? encryptPassword;
@override final  String? expiredAt;

/// Create a copy of DriveTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriveTaskCopyWith<_DriveTask> get copyWith => __$DriveTaskCopyWithImpl<_DriveTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriveTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriveTask&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.contentType, contentType) || other.contentType == contentType)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.uploadedBytes, uploadedBytes) || other.uploadedBytes == uploadedBytes)&&(identical(other.totalChunks, totalChunks) || other.totalChunks == totalChunks)&&(identical(other.uploadedChunks, uploadedChunks) || other.uploadedChunks == uploadedChunks)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.type, type) || other.type == type)&&(identical(other.transmissionProgress, transmissionProgress) || other.transmissionProgress == transmissionProgress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.result, result) || other.result == result)&&(identical(other.poolId, poolId) || other.poolId == poolId)&&(identical(other.bundleId, bundleId) || other.bundleId == bundleId)&&(identical(other.encryptPassword, encryptPassword) || other.encryptPassword == encryptPassword)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,taskId,fileName,contentType,fileSize,uploadedBytes,totalChunks,uploadedChunks,status,createdAt,updatedAt,type,transmissionProgress,errorMessage,result,poolId,bundleId,encryptPassword,expiredAt]);

@override
String toString() {
  return 'DriveTask(id: $id, taskId: $taskId, fileName: $fileName, contentType: $contentType, fileSize: $fileSize, uploadedBytes: $uploadedBytes, totalChunks: $totalChunks, uploadedChunks: $uploadedChunks, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, type: $type, transmissionProgress: $transmissionProgress, errorMessage: $errorMessage, result: $result, poolId: $poolId, bundleId: $bundleId, encryptPassword: $encryptPassword, expiredAt: $expiredAt)';
}


}

/// @nodoc
abstract mixin class _$DriveTaskCopyWith<$Res> implements $DriveTaskCopyWith<$Res> {
  factory _$DriveTaskCopyWith(_DriveTask value, $Res Function(_DriveTask) _then) = __$DriveTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String taskId, String fileName, String contentType, int fileSize, int uploadedBytes, int totalChunks, int uploadedChunks, DriveTaskStatus status, DateTime createdAt, DateTime updatedAt, String type, double? transmissionProgress, String? errorMessage, SnCloudFile? result, String? poolId, String? bundleId, String? encryptPassword, String? expiredAt
});


@override $SnCloudFileCopyWith<$Res>? get result;

}
/// @nodoc
class __$DriveTaskCopyWithImpl<$Res>
    implements _$DriveTaskCopyWith<$Res> {
  __$DriveTaskCopyWithImpl(this._self, this._then);

  final _DriveTask _self;
  final $Res Function(_DriveTask) _then;

/// Create a copy of DriveTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? fileName = null,Object? contentType = null,Object? fileSize = null,Object? uploadedBytes = null,Object? totalChunks = null,Object? uploadedChunks = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? type = null,Object? transmissionProgress = freezed,Object? errorMessage = freezed,Object? result = freezed,Object? poolId = freezed,Object? bundleId = freezed,Object? encryptPassword = freezed,Object? expiredAt = freezed,}) {
  return _then(_DriveTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,contentType: null == contentType ? _self.contentType : contentType // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,uploadedBytes: null == uploadedBytes ? _self.uploadedBytes : uploadedBytes // ignore: cast_nullable_to_non_nullable
as int,totalChunks: null == totalChunks ? _self.totalChunks : totalChunks // ignore: cast_nullable_to_non_nullable
as int,uploadedChunks: null == uploadedChunks ? _self.uploadedChunks : uploadedChunks // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DriveTaskStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,transmissionProgress: freezed == transmissionProgress ? _self.transmissionProgress : transmissionProgress // ignore: cast_nullable_to_non_nullable
as double?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as SnCloudFile?,poolId: freezed == poolId ? _self.poolId : poolId // ignore: cast_nullable_to_non_nullable
as String?,bundleId: freezed == bundleId ? _self.bundleId : bundleId // ignore: cast_nullable_to_non_nullable
as String?,encryptPassword: freezed == encryptPassword ? _self.encryptPassword : encryptPassword // ignore: cast_nullable_to_non_nullable
as String?,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of DriveTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $SnCloudFileCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on
