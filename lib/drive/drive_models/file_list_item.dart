import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/drive/drive_models/file.dart';

part 'file_list_item.freezed.dart';

@freezed
sealed class FileListItem with _$FileListItem {
  const factory FileListItem.file(SnCloudFileIndex fileIndex) = FileItem;
  const factory FileListItem.folder(String folderName) = FolderItem;
  const factory FileListItem.unindexedFile(SnCloudFile file) =
      UnindexedFileItem;
}
