import 'package:dio/dio.dart';
import 'package:solar_network_sdk/src/api/domains/padlock_api.dart';

import 'domains/auth_api.dart';
import 'domains/accounts_api.dart';
import 'domains/sphere_api.dart';
import 'domains/wallet_api.dart';
import 'domains/chat_api.dart';
import 'domains/thoughts_api.dart';
import 'domains/e2ee_api.dart';
import 'domains/drive_api.dart';
import 'domains/stickers_api.dart';
import 'domains/livestreams_api.dart';
import 'domains/notifications_api.dart';
import 'domains/tickets_api.dart';
import 'domains/polls_api.dart';
import 'domains/sites_api.dart';
import 'domains/developers_api.dart';
import 'domains/payments_api.dart';
import 'domains/realms_api.dart';
import 'domains/fitness_api.dart';

/// Main client for interacting with the Solar Network API.
///
/// Provides typed API methods organized by domain, with access to the
/// underlying Dio instance for custom calls.
///
/// Usage:
/// ```dart
/// final client = SolarNetworkClient(
///   baseUrl: 'https://api.example.com',
/// );
///
/// // Use typed domain APIs
/// final post = await client.posts.getPost('post-id');
/// final wallet = await client.wallet.getWallet();
///
/// // Or use the Dio instance directly for custom calls
/// final response = await client.dio.get('/custom/endpoint');
///
/// // Don't forget to close when done
/// client.close();
/// ```
class SolarNetworkClient {
  /// The underlying Dio instance.
  /// Exposed for making custom API calls not covered by the typed methods.
  final Dio dio;

  /// Authentication API (padlock endpoints).
  late final AuthApi auth;

  /// Accounts API (passport endpoints).
  late final AccountsApi accounts;

  /// Posts API (sphere endpoints).
  late final SphereApi sphere;

  /// Wallet API (wallet endpoints).
  late final WalletApi wallet;

  /// Chat API (messager endpoints).
  late final ChatApi chat;

  /// Thoughts API (insight endpoints).
  late final ThoughtsApi thoughts;

  /// End-to-End Encryption API (e2ee endpoints).
  late final E2EEApi e2ee;

  /// Drive/Cloud Storage API (drive endpoints).
  late final DriveApi drive;

  /// Stickers API (sticker endpoints).
  late final StickersApi stickers;

  /// Livestreams API (livestream endpoints).
  late final LivestreamsApi livestreams;

  /// Notifications API (notification endpoints).
  late final NotificationsApi notifications;

  /// Tickets API (ticket endpoints).
  late final TicketsApi tickets;

  /// Polls API (poll endpoints).
  late final PollsApi polls;

  /// Sites API (site endpoints).
  late final SitesApi sites;

  /// Developers API (developer endpoints).
  late final DevelopersApi developers;

  /// Payments API (payment endpoints).
  late final PaymentsApi payments;

  /// Realms API (realm endpoints).
  late final RealmsApi realms;

  /// Padlock API (security endpoints)
  late final PadlockApi padlock;

  /// Fitness API (fitness endpoints).
  late final FitnessApi fitness;

  /// Creates a new SolarNetworkClient with the given configuration.
  ///
  /// [baseUrl] - The base URL for all API requests.
  /// [connectTimeout] - Timeout for establishing a connection.
  /// [receiveTimeout] - Timeout for receiving a response.
  /// [headers] - Additional headers to include in all requests.
  /// [interceptors] - Additional Dio interceptors.
  SolarNetworkClient({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
    Map<String, dynamic>? headers,
    List<Interceptor>? interceptors,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
           headers: {
             'Accept': 'application/json',
             'Content-Type': 'application/json',
             ...?headers,
           },
         ),
       ) {
    if (interceptors != null) {
      dio.interceptors.addAll(interceptors);
    }
    _initializeApis();
  }

  /// Creates a SolarNetworkClient from an existing Dio instance.
  ///
  /// This is useful when you want to reuse an existing Dio instance
  /// with custom configuration, interceptors, etc.
  ///
  /// [dio] - The Dio instance to use.
  SolarNetworkClient.fromDio(this.dio) {
    _initializeApis();
  }

  void _initializeApis() {
    auth = AuthApi(dio);
    accounts = AccountsApi(dio);
    sphere = SphereApi(dio);
    wallet = WalletApi(dio);
    chat = ChatApi(dio);
    thoughts = ThoughtsApi(dio);
    e2ee = E2EEApi(dio);
    drive = DriveApi(dio);
    stickers = StickersApi(dio);
    livestreams = LivestreamsApi(dio);
    notifications = NotificationsApi(dio);
    tickets = TicketsApi(dio);
    polls = PollsApi(dio);
    sites = SitesApi(dio);
    developers = DevelopersApi(dio);
    payments = PaymentsApi(dio);
    realms = RealmsApi(dio);
    padlock = PadlockApi(dio);
    fitness = FitnessApi(dio);
  }

  /// Closes the Dio client and releases resources.
  ///
  /// Should be called when the client is no longer needed.
  void close() {
    dio.close();
  }

  /// Adds an interceptor to the underlying Dio instance.
  void addInterceptor(Interceptor interceptor) {
    dio.interceptors.add(interceptor);
  }

  /// Removes an interceptor from the underlying Dio instance.
  void removeInterceptor(Interceptor interceptor) {
    dio.interceptors.remove(interceptor);
  }

  /// Updates the base URL for all subsequent requests.
  void setBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }

  /// Updates the default headers for all subsequent requests.
  void setDefaultHeaders(Map<String, dynamic> headers) {
    dio.options.headers.addAll(headers);
  }

  /// Removes a default header.
  void removeDefaultHeader(String key) {
    dio.options.headers.remove(key);
  }
}
