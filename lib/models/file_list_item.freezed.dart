// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_list_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileListItem {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileListItem);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FileListItem()';
}


}

/// @nodoc
class $FileListItemCopyWith<$Res>  {
$FileListItemCopyWith(FileListItem _, $Res Function(FileListItem) __);
}


/// Adds pattern-matching-related methods to [FileListItem].
extension FileListItemPatterns on FileListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FileItem value)?  file,TResult Function( FolderItem value)?  folder,TResult Function( UnindexedFileItem value)?  unindexedFile,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FileItem() when file != null:
return file(_that);case FolderItem() when folder != null:
return folder(_that);case UnindexedFileItem() when unindexedFile != null:
return unindexedFile(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FileItem value)  file,required TResult Function( FolderItem value)  folder,required TResult Function( UnindexedFileItem value)  unindexedFile,}){
final _that = this;
switch (_that) {
case FileItem():
return file(_that);case FolderItem():
return folder(_that);case UnindexedFileItem():
return unindexedFile(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FileItem value)?  file,TResult? Function( FolderItem value)?  folder,TResult? Function( UnindexedFileItem value)?  unindexedFile,}){
final _that = this;
switch (_that) {
case FileItem() when file != null:
return file(_that);case FolderItem() when folder != null:
return folder(_that);case UnindexedFileItem() when unindexedFile != null:
return unindexedFile(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( SnCloudFileIndex fileIndex)?  file,TResult Function( String folderName)?  folder,TResult Function( SnCloudFile file)?  unindexedFile,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FileItem() when file != null:
return file(_that.fileIndex);case FolderItem() when folder != null:
return folder(_that.folderName);case UnindexedFileItem() when unindexedFile != null:
return unindexedFile(_that.file);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( SnCloudFileIndex fileIndex)  file,required TResult Function( String folderName)  folder,required TResult Function( SnCloudFile file)  unindexedFile,}) {final _that = this;
switch (_that) {
case FileItem():
return file(_that.fileIndex);case FolderItem():
return folder(_that.folderName);case UnindexedFileItem():
return unindexedFile(_that.file);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( SnCloudFileIndex fileIndex)?  file,TResult? Function( String folderName)?  folder,TResult? Function( SnCloudFile file)?  unindexedFile,}) {final _that = this;
switch (_that) {
case FileItem() when file != null:
return file(_that.fileIndex);case FolderItem() when folder != null:
return folder(_that.folderName);case UnindexedFileItem() when unindexedFile != null:
return unindexedFile(_that.file);case _:
  return null;

}
}

}

/// @nodoc


class FileItem implements FileListItem {
  const FileItem(this.fileIndex);
  

 final  SnCloudFileIndex fileIndex;

/// Create a copy of FileListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FileItemCopyWith<FileItem> get copyWith => _$FileItemCopyWithImpl<FileItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileItem&&(identical(other.fileIndex, fileIndex) || other.fileIndex == fileIndex));
}


@override
int get hashCode => Object.hash(runtimeType,fileIndex);

@override
String toString() {
  return 'FileListItem.file(fileIndex: $fileIndex)';
}


}

/// @nodoc
abstract mixin class $FileItemCopyWith<$Res> implements $FileListItemCopyWith<$Res> {
  factory $FileItemCopyWith(FileItem value, $Res Function(FileItem) _then) = _$FileItemCopyWithImpl;
@useResult
$Res call({
 SnCloudFileIndex fileIndex
});


$SnCloudFileIndexCopyWith<$Res> get fileIndex;

}
/// @nodoc
class _$FileItemCopyWithImpl<$Res>
    implements $FileItemCopyWith<$Res> {
  _$FileItemCopyWithImpl(this._self, this._then);

  final FileItem _self;
  final $Res Function(FileItem) _then;

/// Create a copy of FileListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fileIndex = null,}) {
  return _then(FileItem(
null == fileIndex ? _self.fileIndex : fileIndex // ignore: cast_nullable_to_non_nullable
as SnCloudFileIndex,
  ));
}

/// Create a copy of FileListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileIndexCopyWith<$Res> get fileIndex {
  
  return $SnCloudFileIndexCopyWith<$Res>(_self.fileIndex, (value) {
    return _then(_self.copyWith(fileIndex: value));
  });
}
}

/// @nodoc


class FolderItem implements FileListItem {
  const FolderItem(this.folderName);
  

 final  String folderName;

/// Create a copy of FileListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FolderItemCopyWith<FolderItem> get copyWith => _$FolderItemCopyWithImpl<FolderItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FolderItem&&(identical(other.folderName, folderName) || other.folderName == folderName));
}


@override
int get hashCode => Object.hash(runtimeType,folderName);

@override
String toString() {
  return 'FileListItem.folder(folderName: $folderName)';
}


}

/// @nodoc
abstract mixin class $FolderItemCopyWith<$Res> implements $FileListItemCopyWith<$Res> {
  factory $FolderItemCopyWith(FolderItem value, $Res Function(FolderItem) _then) = _$FolderItemCopyWithImpl;
@useResult
$Res call({
 String folderName
});




}
/// @nodoc
class _$FolderItemCopyWithImpl<$Res>
    implements $FolderItemCopyWith<$Res> {
  _$FolderItemCopyWithImpl(this._self, this._then);

  final FolderItem _self;
  final $Res Function(FolderItem) _then;

/// Create a copy of FileListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? folderName = null,}) {
  return _then(FolderItem(
null == folderName ? _self.folderName : folderName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnindexedFileItem implements FileListItem {
  const UnindexedFileItem(this.file);
  

 final  SnCloudFile file;

/// Create a copy of FileListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnindexedFileItemCopyWith<UnindexedFileItem> get copyWith => _$UnindexedFileItemCopyWithImpl<UnindexedFileItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnindexedFileItem&&(identical(other.file, file) || other.file == file));
}


@override
int get hashCode => Object.hash(runtimeType,file);

@override
String toString() {
  return 'FileListItem.unindexedFile(file: $file)';
}


}

/// @nodoc
abstract mixin class $UnindexedFileItemCopyWith<$Res> implements $FileListItemCopyWith<$Res> {
  factory $UnindexedFileItemCopyWith(UnindexedFileItem value, $Res Function(UnindexedFileItem) _then) = _$UnindexedFileItemCopyWithImpl;
@useResult
$Res call({
 SnCloudFile file
});


$SnCloudFileCopyWith<$Res> get file;

}
/// @nodoc
class _$UnindexedFileItemCopyWithImpl<$Res>
    implements $UnindexedFileItemCopyWith<$Res> {
  _$UnindexedFileItemCopyWithImpl(this._self, this._then);

  final UnindexedFileItem _self;
  final $Res Function(UnindexedFileItem) _then;

/// Create a copy of FileListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? file = null,}) {
  return _then(UnindexedFileItem(
null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as SnCloudFile,
  ));
}

/// Create a copy of FileListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SnCloudFileCopyWith<$Res> get file {
  
  return $SnCloudFileCopyWith<$Res>(_self.file, (value) {
    return _then(_self.copyWith(file: value));
  });
}
}

// dart format on
