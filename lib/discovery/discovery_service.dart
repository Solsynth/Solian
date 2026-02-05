import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/discovery/discovery_models/autocomplete_response.dart';
import 'package:island/core/network.dart';

final autocompleteServiceProvider = Provider<AutocompleteService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AutocompleteService(dio);
});

class AutocompleteService {
  final Dio _client;

  AutocompleteService(this._client);

  Future<List<AutocompleteSuggestion>> getSuggestions(
    String roomId,
    String content,
  ) async {
    final response = await _client.post(
      '/messager/chat/$roomId/autocomplete',
      data: {'content': content},
    );

    final data = response.data as List<dynamic>;
    return data.map((json) => AutocompleteSuggestion.fromJson(json)).toList();
  }

  Future<List<AutocompleteSuggestion>> getGeneralSuggestions(
    String content,
  ) async {
    final response = await _client.post(
      '/sphere/autocomplete',
      data: {'content': content},
    );

    final data = response.data as List<dynamic>;
    return data.map((json) => AutocompleteSuggestion.fromJson(json)).toList();
  }
}
