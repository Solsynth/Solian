import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/models/file.dart';
import 'package:island/models/folder.dart';

part 'file_list_item.freezed.dart';

@freezed
sealed class FileListItem with _$FileListItem {
  const factory FileListItem.file(SnCloudFileIndex fileIndex) = FileItem;
  const factory FileListItem.folder(SnCloudFolder folder) = FolderItem;
}
