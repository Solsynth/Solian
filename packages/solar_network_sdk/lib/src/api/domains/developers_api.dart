import 'package:solar_network_sdk/src/api/base_api.dart';

/// API for developer-related endpoints (/developer).
///
/// Handles developer projects, bots, apps, and API keys.
class DevelopersApi extends BaseApi {
  DevelopersApi(super.dio);

  /// Base path for all developer endpoints.
  static const String _basePath = '/developer';

  // ==========================================
  // Project endpoints
  // ==========================================

  /// Gets all developer projects.
  Future<List<dynamic>> getProjects() async {
    final response = await get<List<dynamic>>('$_basePath/projects');
    return response.data ?? [];
  }

  /// Gets a specific project by ID.
  ///
  /// [projectId] - The project ID.
  Future<Map<String, dynamic>> getProject(String projectId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/projects/$projectId',
    );
    return response.data!;
  }

  /// Creates a new project.
  ///
  /// [name] - The project name.
  /// [description] - Optional description.
  Future<Map<String, dynamic>> createProject({
    required String name,
    String? description,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/projects',
      data: {'name': name, 'description': ?description},
    );
    return response.data!;
  }

  /// Updates a project.
  ///
  /// [projectId] - The project ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updateProject({
    required String projectId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/projects/$projectId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes a project.
  ///
  /// [projectId] - The project ID.
  Future<void> deleteProject(String projectId) async {
    await delete('$_basePath/projects/$projectId');
  }

  // ==========================================
  // Bot endpoints
  // ==========================================

  /// Gets all bots for a project.
  ///
  /// [projectId] - The project ID.
  Future<List<dynamic>> getBots(String projectId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/projects/$projectId/bots',
    );
    return response.data ?? [];
  }

  /// Gets a specific bot by ID.
  ///
  /// [botId] - The bot ID.
  Future<Map<String, dynamic>> getBot(String botId) async {
    final response = await get<Map<String, dynamic>>('$_basePath/bots/$botId');
    return response.data!;
  }

  /// Creates a new bot.
  ///
  /// [projectId] - The project ID.
  /// [name] - The bot name.
  /// [description] - Optional description.
  Future<Map<String, dynamic>> createBot({
    required String projectId,
    required String name,
    String? description,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/projects/$projectId/bots',
      data: {'name': name, 'description': ?description},
    );
    return response.data!;
  }

  /// Updates a bot.
  ///
  /// [botId] - The bot ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updateBot({
    required String botId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/bots/$botId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes a bot.
  ///
  /// [botId] - The bot ID.
  Future<void> deleteBot(String botId) async {
    await delete('$_basePath/bots/$botId');
  }

  /// Gets bot activity logs.
  ///
  /// [botId] - The bot ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getBotLogs({
    required String botId,
    int offset = 0,
    int take = 100,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/bots/$botId/logs',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  // ==========================================
  // App endpoints
  // ==========================================

  /// Gets all apps for a project.
  ///
  /// [projectId] - The project ID.
  Future<List<dynamic>> getApps(String projectId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/projects/$projectId/apps',
    );
    return response.data ?? [];
  }

  /// Gets a specific app by ID.
  ///
  /// [appId] - The app ID.
  Future<Map<String, dynamic>> getApp(String appId) async {
    final response = await get<Map<String, dynamic>>('$_basePath/apps/$appId');
    return response.data!;
  }

  /// Creates a new app.
  ///
  /// [projectId] - The project ID.
  /// [name] - The app name.
  /// [redirectUris] - Allowed redirect URIs.
  /// [scopes] - Allowed scopes.
  Future<Map<String, dynamic>> createApp({
    required String projectId,
    required String name,
    required List<String> redirectUris,
    required List<String> scopes,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/projects/$projectId/apps',
      data: {'name': name, 'redirect_uris': redirectUris, 'scopes': scopes},
    );
    return response.data!;
  }

  /// Updates an app.
  ///
  /// [appId] - The app ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updateApp({
    required String appId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/apps/$appId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes an app.
  ///
  /// [appId] - The app ID.
  Future<void> deleteApp(String appId) async {
    await delete('$_basePath/apps/$appId');
  }

  // ==========================================
  // API key endpoints
  // ==========================================

  /// Gets all API keys for a bot.
  ///
  /// [botId] - The bot ID.
  Future<List<dynamic>> getBotKeys(String botId) async {
    final response = await get<List<dynamic>>('$_basePath/bots/$botId/keys');
    return response.data ?? [];
  }

  /// Creates a new API key for a bot.
  ///
  /// [botId] - The bot ID.
  /// [name] - The key name.
  /// [permissions] - Optional permissions.
  Future<Map<String, dynamic>> createBotKey({
    required String botId,
    required String name,
    List<String>? permissions,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/bots/$botId/keys',
      data: {'name': name, 'permissions': ?permissions},
    );
    return response.data!;
  }

  /// Revokes an API key.
  ///
  /// [botId] - The bot ID.
  /// [keyId] - The key ID.
  Future<void> revokeBotKey({
    required String botId,
    required String keyId,
  }) async {
    await delete('$_basePath/bots/$botId/keys/$keyId');
  }

  /// Gets all app secrets.
  ///
  /// [appId] - The app ID.
  Future<List<dynamic>> getAppSecrets(String appId) async {
    final response = await get<List<dynamic>>('$_basePath/apps/$appId/secrets');
    return response.data ?? [];
  }

  /// Creates a new app secret.
  ///
  /// [appId] - The app ID.
  /// [name] - The secret name.
  Future<Map<String, dynamic>> createAppSecret({
    required String appId,
    required String name,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/apps/$appId/secrets',
      data: {'name': name},
    );
    return response.data!;
  }

  /// Revokes an app secret.
  ///
  /// [appId] - The app ID.
  /// [secretId] - The secret ID.
  Future<void> revokeAppSecret({
    required String appId,
    required String secretId,
  }) async {
    await delete('$_basePath/apps/$appId/secrets/$secretId');
  }

  // ==========================================
  // Webhook endpoints
  // ==========================================

  /// Gets all webhooks for an app.
  ///
  /// [appId] - The app ID.
  Future<List<dynamic>> getWebhooks(String appId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/apps/$appId/webhooks',
    );
    return response.data ?? [];
  }

  /// Creates a new webhook.
  ///
  /// [appId] - The app ID.
  /// [url] - The webhook URL.
  /// [events] - The events to subscribe to.
  /// [secret] - Optional webhook secret.
  Future<Map<String, dynamic>> createWebhook({
    required String appId,
    required String url,
    required List<String> events,
    String? secret,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/apps/$appId/webhooks',
      data: {'url': url, 'events': events, 'secret': ?secret},
    );
    return response.data!;
  }

  /// Updates a webhook.
  ///
  /// [webhookId] - The webhook ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updateWebhook({
    required String webhookId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/webhooks/$webhookId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes a webhook.
  ///
  /// [webhookId] - The webhook ID.
  Future<void> deleteWebhook(String webhookId) async {
    await delete('$_basePath/webhooks/$webhookId');
  }

  /// Tests a webhook.
  ///
  /// [webhookId] - The webhook ID.
  Future<Map<String, dynamic>> testWebhook(String webhookId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/webhooks/$webhookId/test',
    );
    return response.data!;
  }

  // ==========================================
  // Documentation endpoints
  // ==========================================

  /// Gets API documentation.
  Future<Map<String, dynamic>> getDocumentation() async {
    final response = await get<Map<String, dynamic>>('$_basePath/docs');
    return response.data!;
  }

  /// Gets changelog.
  ///
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getChangelog({int offset = 0, int take = 20}) async {
    final response = await get<List<dynamic>>(
      '$_basePath/changelog',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Gets API status.
  Future<Map<String, dynamic>> getApiStatus() async {
    final response = await get<Map<String, dynamic>>('$_basePath/status');
    return response.data!;
  }

  /// Gets rate limit info.
  Future<Map<String, dynamic>> getRateLimitInfo() async {
    final response = await get<Map<String, dynamic>>('$_basePath/rate-limit');
    return response.data!;
  }
}
