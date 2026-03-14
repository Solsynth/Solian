import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/network.dart';

enum DiscoveryFeedbackKind { post, publisher, tag, category }

enum DiscoveryFeedbackValue { positive, negative }

enum DiscoveryWeightKind { publisher, tag, category }

extension DiscoveryFeedbackKindExtension on DiscoveryFeedbackKind {
  String get value {
    switch (this) {
      case DiscoveryFeedbackKind.post:
        return 'post';
      case DiscoveryFeedbackKind.publisher:
        return 'publisher';
      case DiscoveryFeedbackKind.tag:
        return 'tag';
      case DiscoveryFeedbackKind.category:
        return 'category';
    }
  }

  static DiscoveryFeedbackKind fromString(String value) {
    switch (value.toLowerCase()) {
      case 'post':
        return DiscoveryFeedbackKind.post;
      case 'publisher':
        return DiscoveryFeedbackKind.publisher;
      case 'tag':
        return DiscoveryFeedbackKind.tag;
      case 'category':
        return DiscoveryFeedbackKind.category;
      default:
        return DiscoveryFeedbackKind.post;
    }
  }
}

extension DiscoveryFeedbackValueExtension on DiscoveryFeedbackValue {
  String get value {
    switch (this) {
      case DiscoveryFeedbackValue.positive:
        return 'positive';
      case DiscoveryFeedbackValue.negative:
        return 'negative';
    }
  }

  String get alias {
    switch (this) {
      case DiscoveryFeedbackValue.positive:
        return 'good';
      case DiscoveryFeedbackValue.negative:
        return 'bad';
    }
  }

  static DiscoveryFeedbackValue fromString(String value) {
    switch (value.toLowerCase()) {
      case 'positive':
      case 'good':
        return DiscoveryFeedbackValue.positive;
      case 'negative':
      case 'bad':
        return DiscoveryFeedbackValue.negative;
      default:
        return DiscoveryFeedbackValue.positive;
    }
  }
}

extension DiscoveryWeightKindExtension on DiscoveryWeightKind {
  String get value {
    switch (this) {
      case DiscoveryWeightKind.publisher:
        return 'publisher';
      case DiscoveryWeightKind.tag:
        return 'tag';
      case DiscoveryWeightKind.category:
        return 'category';
    }
  }

  static DiscoveryWeightKind fromString(String value) {
    switch (value.toLowerCase()) {
      case 'publisher':
        return DiscoveryWeightKind.publisher;
      case 'tag':
        return DiscoveryWeightKind.tag;
      case 'category':
        return DiscoveryWeightKind.category;
      default:
        return DiscoveryWeightKind.publisher;
    }
  }
}

final discoveryFeedbackServiceProvider = Provider<DiscoveryFeedbackService>((
  ref,
) {
  final dio = ref.watch(apiClientProvider);
  return DiscoveryFeedbackService(dio);
});

class DiscoveryFeedbackService {
  final Dio _client;

  DiscoveryFeedbackService(this._client);

  Future<void> submitFeedback({
    required DiscoveryFeedbackKind kind,
    required String referenceId,
    required DiscoveryFeedbackValue feedback,
    String? reason,
    bool? suppress,
  }) async {
    await _client.post(
      '/sphere/timeline/discovery/feedback',
      data: {
        'kind': kind.value,
        'reference_id': referenceId,
        'feedback': feedback.alias,
        'reason': ?reason,
        'suppress': ?suppress,
      },
    );
  }

  Future<void> updateWeight({
    required DiscoveryWeightKind kind,
    required String referenceId,
    required double scoreDelta,
    int interactionCount = 1,
    String? signalType,
  }) async {
    await _client.put(
      '/sphere/timeline/discovery/weights',
      data: {
        'kind': kind.value,
        'reference_id': referenceId,
        'score_delta': scoreDelta,
        'interaction_count': interactionCount,
        'signal_type': ?signalType,
      },
    );
  }

  Future<void> markUninterested({
    required String kind,
    required String referenceId,
  }) async {
    await _client.post(
      '/sphere/timeline/discovery/uninterested',
      data: {'kind': kind, 'reference_id': referenceId},
    );
  }

  Future<void> removeUninterested({
    required String kind,
    required String referenceId,
  }) async {
    await _client.delete(
      '/sphere/timeline/discovery/uninterested',
      data: {'kind': kind, 'reference_id': referenceId},
    );
  }
}
