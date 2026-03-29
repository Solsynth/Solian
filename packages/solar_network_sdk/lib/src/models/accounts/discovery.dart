import 'package:freezed_annotation/freezed_annotation.dart';

part 'discovery.freezed.dart';
part 'discovery.g.dart';

@freezed
sealed class SnDiscoveryProfile with _$SnDiscoveryProfile {
  @JsonSerializable()
  const factory SnDiscoveryProfile({
    required DateTime generatedAt,
    required List<SnDiscoveryInterest> interests,
    required List<SnSuggestedData> suggestedPublishers,
    required List<SnSuggestedData> suggestedAccounts,
    required List<SnSuggestedData> suggestedRealms,
    required List<dynamic> suppressed,
  }) = _SnDiscoveryProfile;

  factory SnDiscoveryProfile.fromJson(Map<String, dynamic> json) =>
      _$SnDiscoveryProfileFromJson(json);
}

@freezed
sealed class SnDiscoveryInterest with _$SnDiscoveryInterest {
  @JsonSerializable()
  const factory SnDiscoveryInterest({
    required String kind,
    required String referenceId,
    required String label,
    required double score,
    required int interactionCount,
    required DateTime lastInteractedAt,
    required String lastSignalType,
  }) = _SnDiscoveryInterest;

  factory SnDiscoveryInterest.fromJson(Map<String, dynamic> json) =>
      _$SnDiscoveryInterestFromJson(json);
}

@freezed
sealed class SnSuggestedData with _$SnSuggestedData {
  @JsonSerializable()
  const factory SnSuggestedData({
    required int kind,
    required String referenceId,
    required String label,
    required double score,
    required List<String> reasons,
    required dynamic data,
  }) = _SnSuggestedData;

  factory SnSuggestedData.fromJson(Map<String, dynamic> json) =>
      _$SnSuggestedDataFromJson(json);
}
