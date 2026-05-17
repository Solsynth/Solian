import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'file_permissions.g.dart';

final driveInspectorFileProvider = NotifierProvider<DriveInspectorFileNotifier, SnCloudFile?>(
  DriveInspectorFileNotifier.new,
);

class DriveInspectorFileNotifier extends Notifier<SnCloudFile?> {
  @override
  SnCloudFile? build() => null;

  void setFile(SnCloudFile? file) {
    state = file;
  }
}

@riverpod
Future<SnCloudFile> driveFileInfo(Ref ref, String fileId) async {
  final driveApi = ref.read(solarNetworkClientProvider).drive;
  return driveApi.getFileInfo(fileId);
}

@riverpod
Future<List<SnFilePermission>> driveFilePermissions(
  Ref ref,
  String fileId,
) async {
  final driveApi = ref.read(solarNetworkClientProvider).drive;
  return driveApi.getFilePermissions(fileId);
}
