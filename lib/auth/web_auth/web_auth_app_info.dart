import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/developers/models/dev_project.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'web_auth_app_info.freezed.dart';
part 'web_auth_app_info.g.dart';

@freezed
sealed class WebAuthAppInfo with _$WebAuthAppInfo {
  const factory WebAuthAppInfo({
    required String id,
    required String slug,
    required String name,
    required String description,
    required int status,
    required SnCloudFile? picture,
    required SnCloudFile? background,
    required SnVerificationMark? verification,
    required Map<String, String?> links,
    required String projectId,
    required SnDevProject project,
    required String resourceIdentifier,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime? deletedAt,
  }) = _WebAuthAppInfo;

  factory WebAuthAppInfo.fromJson(Map<String, dynamic> json) =>
      _$WebAuthAppInfoFromJson(json);
}
