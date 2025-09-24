import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_pool.freezed.dart';
part 'file_pool.g.dart';

@freezed
sealed class SnFilePool with _$SnFilePool {
  const factory SnFilePool({
    required String id,
    required String name,
    String? description,
    Map<String, dynamic>? storageConfig,
    Map<String, dynamic>? billingConfig,
    Map<String, dynamic>? policyConfig,
    bool? isHidden,
    String? accountId,
    String? resourceIdentifier,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _SnFilePool;

  factory SnFilePool.fromJson(Map<String, dynamic> json) =>
      _$SnFilePoolFromJson(json);
}

extension SnFilePoolList on List<SnFilePool> {
  static List<SnFilePool> listFromResponse(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(SnFilePool.fromJson)
          .toList();
    }
    throw ArgumentError('Unexpected response format: $data');
  }
}
