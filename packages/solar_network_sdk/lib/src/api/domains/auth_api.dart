import 'package:solar_network_sdk/src/api/base_api.dart';
import 'package:solar_network_sdk/src/models/auth/auth_session.dart';
import 'package:solar_network_sdk/src/models/auth/auth_challenge.dart';
import 'package:solar_network_sdk/src/models/auth/misc.dart';
import 'package:solar_network_sdk/src/models/accounts/account.dart';

/// API for authentication-related endpoints (/padlock).
///
/// Handles authentication tokens, sessions, factors, and connections.
class AuthApi extends BaseApi {
  AuthApi(super.dio);

  /// Base path for all padlock endpoints.
  static const String _basePath = '/padlock';

  // ==========================================
  // Token endpoints
  // ==========================================

  /// Authenticates with username and password to get tokens.
  ///
  /// [username] - The user's username.
  /// [password] - The user's password.
  /// Returns a map containing 'token', 'refresh_token', 'expires_in', etc.
  Future<Map<String, dynamic>> authenticate({
    required String username,
    required String password,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/auth/token',
      data: {'username': username, 'password': password},
    );
    return response.data!;
  }

  /// Refreshes the access token using a refresh token.
  ///
  /// [refreshToken] - The refresh token.
  /// Returns a map containing the new tokens.
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/auth/token',
      data: {'grant_type': 'refresh_token', 'refresh_token': refreshToken},
    );
    return response.data!;
  }

  /// Revokes the current session token.
  Future<void> revokeToken() async {
    await delete('$_basePath/auth/token');
  }

  // ==========================================
  // Challenge approval endpoints
  // ==========================================

  /// Gets all pending challenges for the current user that are awaiting
  /// approval from another device.
  Future<List<SnAuthChallenge>> getPendingChallenges() async {
    final response = await get<List<dynamic>>(
      '$_basePath/auth/challenge/pending',
    );
    return parseList(response, SnAuthChallenge.fromJson);
  }

  /// Approves a pending challenge from another device.
  ///
  /// [challengeId] - The ID of the challenge to approve.
  /// [pinCode] - The user's PIN code (required if account has PIN configured).
  Future<void> approveChallenge({
    required String challengeId,
    String? pinCode,
  }) async {
    await post(
      '$_basePath/auth/challenge/$challengeId/approve',
      data: {'pin_code': pinCode},
    );
  }

  /// Declines a pending challenge from another device.
  ///
  /// [challengeId] - The ID of the challenge to decline.
  /// [pinCode] - The user's PIN code (required if account has PIN configured).
  Future<void> declineChallenge({
    required String challengeId,
    String? pinCode,
  }) async {
    await post(
      '$_basePath/auth/challenge/$challengeId/decline',
      data: {'pin_code': pinCode},
    );
  }

  // ==========================================
  // Session endpoints
  // ==========================================

  /// Gets the current session information.
  Future<SnAuthSession> getCurrentSession() async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/sessions/current',
    );
    return SnAuthSession.fromJson(response.data!);
  }

  /// Revokes the current session.
  Future<void> revokeCurrentSession() async {
    await delete('$_basePath/sessions/current');
  }

  /// Gets all sessions for the current user.
  Future<List<SnAuthSession>> getSessions() async {
    final response = await get<List<dynamic>>('$_basePath/sessions');
    return parseList(response, SnAuthSession.fromJson);
  }

  /// Revokes a specific session by ID.
  ///
  /// [sessionId] - The ID of the session to revoke.
  Future<void> revokeSession(String sessionId) async {
    await delete('$_basePath/sessions/$sessionId');
  }

  /// Revokes all sessions except the current one.
  Future<void> revokeAllOtherSessions() async {
    await delete('$_basePath/sessions/other');
  }

  // ==========================================
  // Factor endpoints
  // ==========================================

  /// Gets all authentication factors for the current user.
  Future<List<SnAuthFactor>> getFactors() async {
    final response = await get<List<dynamic>>('$_basePath/factors');
    return parseList(response, SnAuthFactor.fromJson);
  }

  /// Creates a new authentication factor.
  ///
  /// [type] - The type of factor (e.g., 'totp', 'webauthn').
  /// [label] - A label for the factor.
  /// [data] - Additional data for the factor.
  Future<SnAuthFactor> createFactor({
    required int type,
    required String? secret,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/factors',
      data: {'type': type, 'secret': secret},
    );
    return SnAuthFactor.fromJson(response.data!);
  }

  /// Deletes an authentication factor.
  ///
  /// [factorId] - The ID of the factor to delete.
  Future<void> deleteFactor(String factorId) async {
    await delete('$_basePath/factors/$factorId');
  }

  /// Disables an authentication factor.
  ///
  /// [factorId] - The ID of the factor to disable.
  Future<void> disableFactor(String factorId) async {
    await post('$_basePath/factors/$factorId/disable');
  }

  /// Enables an authentication factor.
  ///
  /// [factorId] - The ID of the factor to enable.
  Future<void> enableFactor(String factorId) async {
    await post('$_basePath/factors/$factorId/enable');
  }

  /// Creates a challenge for a specific factor.
  ///
  /// [factorId] - The ID of the factor to challenge.
  Future<SnAuthChallenge> createFactorChallenge({
    required String factorId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/factors/$factorId/challenge',
    );
    return SnAuthChallenge.fromJson(response.data!);
  }

  /// Verifies a factor challenge response.
  ///
  /// [factorId] - The ID of the factor.
  /// [challengeId] - The ID of the challenge.
  /// [response] - The challenge response (e.g., TOTP code).
  Future<bool> verifyFactorChallenge({
    required String factorId,
    required String challengeId,
    required String response,
  }) async {
    final result = await post<bool>(
      '$_basePath/factors/$factorId/challenges/$challengeId',
      data: {'response': response},
    );
    return result.data ?? false;
  }

  // ==========================================
  // Passkey endpoints
  // ==========================================

  /// Starts a passkey registration by generating a challenge.
  ///
  /// [deviceId] - The device identifier.
  /// [rpId] - The relying party ID (domain).
  /// [rpName] - The relying party name.
  /// Returns challenge and WebAuthn options.
  Future<Map<String, dynamic>> startPasskeyRegistration({
    required String deviceId,
    required String deviceName,
    required String rpId,
    required String rpName,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/factors/passkey/start',
      data: {
        'device_id': deviceId,
        'device_name': deviceName,
        'rp_id': rpId,
        'rp_name': rpName,
      },
    );
    return response.data!;
  }

  /// Completes a passkey registration by verifying attestation.
  ///
  /// [deviceId] - The device identifier.
  /// [attestationObject] - The attestation object from the authenticator.
  /// [clientDataJson] - The client data JSON from the authenticator.
  /// Returns the created factor.
  Future<SnAuthFactor> completePasskeyRegistration({
    required String deviceId,
    required String? deviceName,
    required String attestationObject,
    required String clientDataJson,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/factors/passkey/complete',
      data: {
        'device_id': deviceId,
        'device_name': deviceName,
        'attestation_object': attestationObject,
        'client_data_json': clientDataJson,
      },
    );
    return SnAuthFactor.fromJson(response.data!);
  }

  /// Starts a passkey authentication challenge for a login attempt.
  Future<Map<String, dynamic>> startPasskeyAuthentication({
    required String challengeId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/auth/challenge/$challengeId/passkey/start',
    );
    return response.data!;
  }

  /// Completes a passkey authentication challenge.
  Future<SnAuthChallenge> completePasskeyAuthentication({
    required String challengeId,
    required String factorId,
    required String credentialId,
    required String clientDataJson,
    required String authenticatorData,
    required String signature,
    String? userHandle,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/auth/challenge/$challengeId/passkey/complete',
      data: {
        'factor_id': factorId,
        'credential_id': credentialId,
        'client_data_json': clientDataJson,
        'authenticator_data': authenticatorData,
        'signature': signature,
        'user_handle': userHandle,
      },
    );
    return SnAuthChallenge.fromJson(response.data!);
  }

  // ==========================================
  // Contact endpoints
  // ==========================================

  /// Gets all contact methods for the current user.
  Future<List<SnContactMethod>> getContacts() async {
    final response = await get<List<dynamic>>('$_basePath/contacts');
    return parseList(response, SnContactMethod.fromJson);
  }

  /// Adds a new contact method.
  ///
  /// [type] - The type of contact (e.g., 'email', 'phone').
  /// [value] - The contact value.
  Future<SnContactMethod> addContact({
    required int type,
    required String content,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/contacts',
      data: {'type': type, 'content': content},
    );
    return SnContactMethod.fromJson(response.data!);
  }

  /// Deletes a contact method.
  ///
  /// [contactId] - The ID of the contact to delete.
  Future<void> deleteContact(String contactId) async {
    await delete('$_basePath/contacts/$contactId');
  }

  // ==========================================
  // Connection endpoints
  // ==========================================

  /// Gets all connected services/accounts.
  Future<List<SnAccountConnection>> getConnections() async {
    final response = await get<List<dynamic>>('$_basePath/connections');
    return parseList(response, SnAccountConnection.fromJson);
  }

  /// Disconnects a service/account.
  ///
  /// [connectionId] - The ID of the connection to remove.
  Future<void> disconnect(String connectionId) async {
    await delete('$_basePath/connections/$connectionId');
  }

  // ==========================================
  // Device endpoints
  // ==========================================

  /// Gets all authenticated devices.
  Future<List<SnAuthDeviceWithSession>> getDevices() async {
    final response = await get<List<dynamic>>('$_basePath/devices');
    return parseList(response, SnAuthDeviceWithSession.fromJson);
  }

  /// Revokes a specific device.
  ///
  /// [deviceId] - The ID of the device to revoke.
  Future<void> revokeDevice(String deviceId) async {
    await delete('$_basePath/devices/$deviceId');
  }

  /// Revokes all devices except the current one.
  Future<void> revokeAllOtherDevices() async {
    await delete('$_basePath/devices/other');
  }

  // ==========================================
  // WebAuth endpoints
  // ==========================================

  /// Initiates web authentication flow.
  ///
  /// [appSlug] - The application slug.
  /// [redirectUri] - The redirect URI after authentication.
  /// [state] - Optional state parameter.
  Future<Map<String, dynamic>> initiateWebAuth({
    required String appSlug,
    required String redirectUri,
    String? state,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/auth/web',
      data: {'app': appSlug, 'redirect_uri': redirectUri, 'state': ?state},
    );
    return response.data!;
  }

  /// Exchanges a web auth challenge for tokens.
  ///
  /// [signedChallenge] - The signed challenge response.
  /// [deviceInfo] - Optional device information.
  /// [secretId] - Optional secret ID for additional verification.
  Future<Map<String, dynamic>> exchangeWebAuth({
    required String signedChallenge,
    Map<String, dynamic>? deviceInfo,
    String? secretId,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/auth/web/exchange',
      data: {
        'signed_challenge': signedChallenge,
        'device_info': ?deviceInfo,
        'secret_id': ?secretId,
      },
    );
    return response.data!;
  }

  // ==========================================
  // OAuth/App endpoints
  // ==========================================

  /// Gets OAuth authorization URL.
  ///
  /// [appId] - The OAuth application ID.
  /// [redirectUri] - The redirect URI.
  /// [scopes] - Requested scopes.
  /// [state] - Optional state parameter.
  Future<String> getOAuthAuthorizationUrl({
    required String appId,
    required String redirectUri,
    required List<String> scopes,
    String? state,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$_basePath/oauth/authorize',
      queryParameters: {
        'app_id': appId,
        'redirect_uri': redirectUri,
        'scope': scopes.join(','),
        'state': ?state,
      },
    );
    return response.data!['url'] as String;
  }

  /// Exchanges an OAuth authorization code for tokens.
  ///
  /// [code] - The authorization code.
  /// [redirectUri] - The redirect URI used in authorization.
  Future<Map<String, dynamic>> exchangeOAuthCode({
    required String code,
    required String redirectUri,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '$_basePath/oauth/token',
      data: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
      },
    );
    return response.data!;
  }
}
