import 'package:dio/dio.dart';
import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/think/thought.dart';

class ThoughtsApi extends BaseApi {
  ThoughtsApi(super.dio);

  static const String _basePath = '/personality';

  Future<List<SnThinkingSequence>> getSequences({
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/conversations',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data
            ?.map(
              (e) => SnThinkingSequence.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        const [];
  }

  Future<SnThinkingSequence> getSequence(String sequenceId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/conversations/$sequenceId',
    );
    return SnThinkingSequence.fromJson(response.data!);
  }

  Future<PersonalityConversation> createConversation({
    required String agentId,
    String? title,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/conversations',
      data: {
        'agent_id': agentId,
        if (title != null && title.isNotEmpty) 'title': title,
      },
    );
    return PersonalityConversation.fromJson(response.data!);
  }

  Future<List<SnThinkingThought>> getSequenceMessages(
    String sequenceId, {
    int offset = 0,
    int take = 50,
  }) async {
    final conversation = await getSequence(sequenceId);
    final response = await get<List<dynamic>>(
      '$_basePath/conversations/$sequenceId/messages',
      queryParameters: {'offset': offset, 'take': take},
    );

    return response.data
            ?.map((e) {
              final message = PersonalityMessage.fromJson(
                e as Map<String, dynamic>,
              );
              return SnThinkingThought.fromMessage(
                conversation: PersonalityConversation(
                  id: conversation.id,
                  accountId: conversation.accountId,
                  agentId: conversation.botName ?? '',
                  title: conversation.topic ?? 'New conversation',
                  createdAt: conversation.createdAt,
                  updatedAt: conversation.updatedAt,
                ),
                message: message,
              );
            })
            .toList()
            .reversed
            .toList() ??
        const [];
  }

  Future<PersonalityMessage> addMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/conversations/$conversationId/messages',
      data: {'content': content},
    );
    return PersonalityMessage.fromJson(response.data!);
  }

  Future<Response<dynamic>> createRun({
    required String conversationId,
    required Map<String, dynamic> data,
    bool stream = false,
  }) {
    return post(
      '$_basePath/conversations/$conversationId/runs',
      data: data,
      options: Options(
        responseType: stream ? ResponseType.stream : ResponseType.json,
        sendTimeout: const Duration(hours: 1),
        receiveTimeout: const Duration(hours: 1),
      ),
    );
  }

  Future<ThoughtServicesResponse> getServices() async {
    final response = await get<List<dynamic>>('$_basePath/agents');
    final services = response.data
            ?.map((e) => ThoughtService.fromJson(e as Map<String, dynamic>))
            .where((service) => service.id.isNotEmpty)
            .toList() ??
        const [];
    return ThoughtServicesResponse(
      defaultBot: services.isNotEmpty ? services.first.id : '',
      services: services,
    );
  }

  Future<Map<String, dynamic>> getBillingStatus() async {
    return const {'status': 'ok'};
  }

  Future<Map<String, dynamic>> getQuota() async {
    return const {'enabled': false, 'free_remaining': 0, 'free_used': 0, 'free_total': 0};
  }
}
