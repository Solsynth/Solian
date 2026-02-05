import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:island/core/config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tour.g.dart';
part 'tour.freezed.dart';

const kAppTourStatusKey = "app_tour_statuses";

const List<Tour> kAllTours = [
  // Tour(id: 'technical_review_intro', isStartup: true),
];

@freezed
sealed class Tour with _$Tour {
  const Tour._();

  const factory Tour({required String id, required bool isStartup}) = _Tour;

  Widget get widget => switch (id) {
    // 'technical_review_intro' => const TechicalReviewIntroWidget(),
    _ => throw UnimplementedError(),
  };
}

@riverpod
class TourStatusNotifier extends _$TourStatusNotifier {
  @override
  Map<String, bool> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final storedJson = prefs.getString(kAppTourStatusKey);
    if (storedJson != null) {
      try {
        final Map<String, dynamic> stored = jsonDecode(storedJson);
        return Map<String, bool>.from(stored);
      } catch (_) {
        return {for (final id in kAllTours.map((e) => e.id)) id: false};
      }
    }
    return {for (final id in kAllTours.map((e) => e.id)) id: false};
  }

  bool isTourShown(String tourId) => state[tourId] ?? false;

  Future<void> _saveState(Map<String, bool> newState) async {
    state = newState;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(kAppTourStatusKey, jsonEncode(newState));
  }

  Future<Widget?> showTour(String tourId) async {
    if (!isTourShown(tourId)) {
      final newState = {...state, tourId: true};
      await _saveState(newState);
      return kAllTours.firstWhere((e) => e.id == tourId).widget;
    }
    return null;
  }

  Future<void> resetTours() async {
    final newState = {for (final id in kAllTours.map((e) => e.id)) id: false};
    await _saveState(newState);
  }
}
