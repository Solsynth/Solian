import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';

class DomainTrustResult {
  final bool isAllowed;
  final String? blockReason;

  const DomainTrustResult({
    required this.isAllowed,
    this.blockReason,
  });

  factory DomainTrustResult.fromJson(Map<String, dynamic> json) {
    return DomainTrustResult(
      isAllowed: json['is_allowed'] as bool? ?? false,
      blockReason: json['block_reason'] as String?,
    );
  }
}

class DomainTrustService {
  final Dio _dio;
  final Map<String, DomainTrustResult> _cache = {};

  DomainTrustService(this._dio);

  Future<DomainTrustResult> validateUrl(Uri url) async {
    final normalizedHost = url.host.toLowerCase();
    final cacheKey = '$normalizedHost:${url.scheme}:${url.hasPort ? url.port : ''}';
    
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await _dio.get(
        '/passport/domain-blocks/check',
        queryParameters: {'url': url.toString()},
      );

      final result = DomainTrustResult.fromJson(response.data);
      _cache[cacheKey] = result;
      return result;
    } catch (e) {
      return DomainTrustResult(
        isAllowed: false,
        blockReason: 'Unable to verify URL safety',
      );
    }
  }

  void clearCache() {
    _cache.clear();
  }
}

final domainTrustServiceProvider = Provider<DomainTrustService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return DomainTrustService(dio);
});
