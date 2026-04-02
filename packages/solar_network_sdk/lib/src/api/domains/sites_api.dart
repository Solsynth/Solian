import 'package:dio/dio.dart';

import '../base_api.dart';

/// API for site-related endpoints (/site).
///
/// Handles user sites, pages, and site management.
class SitesApi extends BaseApi {
  SitesApi(super.dio);

  /// Base path for all site endpoints.
  static const String _basePath = '/site';

  // ==========================================
  // Site endpoints
  // ==========================================

  /// Gets all sites for the current user.
  Future<List<dynamic>> getSites() async {
    final response = await get<List<dynamic>>('$_basePath/sites');
    return response.data ?? [];
  }

  /// Gets a specific site by ID.
  ///
  /// [siteId] - The site ID.
  Future<Map<String, dynamic>> getSite(String siteId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/sites/$siteId',
    );
    return response.data!;
  }

  /// Creates a new site.
  ///
  /// [name] - The site name.
  /// [slug] - The site slug.
  /// [description] - Optional description.
  Future<Map<String, dynamic>> createSite({
    required String name,
    required String slug,
    String? description,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites',
      data: {
        'name': name,
        'slug': slug,
        if (description != null) 'description': description,
      },
    );
    return response.data!;
  }

  /// Updates a site.
  ///
  /// [siteId] - The site ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updateSite({
    required String siteId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/sites/$siteId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes a site.
  ///
  /// [siteId] - The site ID.
  Future<void> deleteSite(String siteId) async {
    await delete('$_basePath/sites/$siteId');
  }

  /// Gets site analytics.
  ///
  /// [siteId] - The site ID.
  /// [period] - The period (e.g., 'day', 'week', 'month').
  Future<Map<String, dynamic>> getSiteAnalytics({
    required String siteId,
    String period = 'month',
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/analytics',
      queryParameters: {'period': period},
    );
    return response.data!;
  }

  // ==========================================
  // Page endpoints
  // ==========================================

  /// Gets pages for a site.
  ///
  /// [siteId] - The site ID.
  Future<List<dynamic>> getPages(String siteId) async {
    final response = await get<List<dynamic>>('$_basePath/sites/$siteId/pages');
    return response.data ?? [];
  }

  /// Gets a specific page by ID.
  ///
  /// [siteId] - The site ID.
  /// [pageId] - The page ID.
  Future<Map<String, dynamic>> getPage({
    required String siteId,
    required String pageId,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/pages/$pageId',
    );
    return response.data!;
  }

  /// Creates a new page.
  ///
  /// [siteId] - The site ID.
  /// [title] - The page title.
  /// [slug] - The page slug.
  /// [content] - Optional initial content.
  Future<Map<String, dynamic>> createPage({
    required String siteId,
    required String title,
    required String slug,
    String? content,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/pages',
      data: {
        'title': title,
        'slug': slug,
        if (content != null) 'content': content,
      },
    );
    return response.data!;
  }

  /// Updates a page.
  ///
  /// [siteId] - The site ID.
  /// [pageId] - The page ID.
  /// [data] - The data to update.
  Future<Map<String, dynamic>> updatePage({
    required String siteId,
    required String pageId,
    required Map<String, dynamic> data,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/pages/$pageId',
      data: data,
    );
    return response.data!;
  }

  /// Deletes a page.
  ///
  /// [siteId] - The site ID.
  /// [pageId] - The page ID.
  Future<void> deletePage({
    required String siteId,
    required String pageId,
  }) async {
    await delete('$_basePath/sites/$siteId/pages/$pageId');
  }

  /// Publishes a page.
  ///
  /// [siteId] - The site ID.
  /// [pageId] - The page ID.
  Future<Map<String, dynamic>> publishPage({
    required String siteId,
    required String pageId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/pages/$pageId/publish',
    );
    return response.data!;
  }

  /// Unpublishes a page.
  ///
  /// [siteId] - The site ID.
  /// [pageId] - The page ID.
  Future<Map<String, dynamic>> unpublishPage({
    required String siteId,
    required String pageId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/pages/$pageId/unpublish',
    );
    return response.data!;
  }

  // ==========================================
  // Template endpoints
  // ==========================================

  /// Gets all templates.
  Future<List<dynamic>> getTemplates() async {
    final response = await get<List<dynamic>>('$_basePath/templates');
    return response.data ?? [];
  }

  /// Gets a specific template by ID.
  ///
  /// [templateId] - The template ID.
  Future<Map<String, dynamic>> getTemplate(String templateId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/templates/$templateId',
    );
    return response.data!;
  }

  /// Applies a template to a site.
  ///
  /// [siteId] - The site ID.
  /// [templateId] - The template ID.
  Future<Map<String, dynamic>> applyTemplate({
    required String siteId,
    required String templateId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/templates/$templateId',
    );
    return response.data!;
  }

  // ==========================================
  // Theme endpoints
  // ==========================================

  /// Gets theme settings for a site.
  ///
  /// [siteId] - The site ID.
  Future<Map<String, dynamic>> getThemeSettings(String siteId) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/theme',
    );
    return response.data!;
  }

  /// Updates theme settings for a site.
  ///
  /// [siteId] - The site ID.
  /// [settings] - The theme settings.
  Future<Map<String, dynamic>> updateThemeSettings({
    required String siteId,
    required Map<String, dynamic> settings,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/theme',
      data: settings,
    );
    return response.data!;
  }

  /// Gets available themes.
  Future<List<dynamic>> getThemes() async {
    final response = await get<List<dynamic>>('$_basePath/themes');
    return response.data ?? [];
  }

  /// Applies a theme to a site.
  ///
  /// [siteId] - The site ID.
  /// [themeId] - The theme ID.
  Future<Map<String, dynamic>> applyTheme({
    required String siteId,
    required String themeId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/theme/$themeId',
    );
    return response.data!;
  }

  // ==========================================
  // Custom domain endpoints
  // ==========================================

  /// Gets custom domains for a site.
  ///
  /// [siteId] - The site ID.
  Future<List<dynamic>> getCustomDomains(String siteId) async {
    final response = await get<List<dynamic>>(
      '$_basePath/sites/$siteId/domains',
    );
    return response.data ?? [];
  }

  /// Adds a custom domain to a site.
  ///
  /// [siteId] - The site ID.
  /// [domain] - The custom domain.
  Future<Map<String, dynamic>> addCustomDomain({
    required String siteId,
    required String domain,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/domains',
      data: {'domain': domain},
    );
    return response.data!;
  }

  /// Removes a custom domain from a site.
  ///
  /// [siteId] - The site ID.
  /// [domain] - The custom domain.
  Future<void> removeCustomDomain({
    required String siteId,
    required String domain,
  }) async {
    await delete('$_basePath/sites/$siteId/domains/$domain');
  }

  /// Verifies a custom domain.
  ///
  /// [siteId] - The site ID.
  /// [domain] - The custom domain.
  Future<Map<String, dynamic>> verifyCustomDomain({
    required String siteId,
    required String domain,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/domains/$domain/verify',
    );
    return response.data!;
  }

  // ==========================================
  // Deployment endpoints
  // ==========================================

  /// Deploys a site.
  ///
  /// [siteId] - The site ID.
  Future<Map<String, dynamic>> deploySite(String siteId) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/deploy',
    );
    return response.data!;
  }

  /// Gets deployment history.
  ///
  /// [siteId] - The site ID.
  /// [offset] - Pagination offset.
  /// [take] - Number of items to take.
  Future<List<dynamic>> getDeployments({
    required String siteId,
    int offset = 0,
    int take = 20,
  }) async {
    final response = await get<List<dynamic>>(
      '$_basePath/sites/$siteId/deployments',
      queryParameters: {'offset': offset, 'take': take},
    );
    return response.data ?? [];
  }

  /// Gets deployment status.
  ///
  /// [siteId] - The site ID.
  /// [deploymentId] - The deployment ID.
  Future<Map<String, dynamic>> getDeploymentStatus({
    required String siteId,
    required String deploymentId,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/deployments/$deploymentId',
    );
    return response.data!;
  }

  /// Rolls back to a previous deployment.
  ///
  /// [siteId] - The site ID.
  /// [deploymentId] - The deployment ID to rollback to.
  Future<Map<String, dynamic>> rollbackDeployment({
    required String siteId,
    required String deploymentId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/sites/$siteId/deployments/$deploymentId/rollback',
    );
    return response.data!;
  }
}
