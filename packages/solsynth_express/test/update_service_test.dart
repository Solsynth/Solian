import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:solsynth_express/solsynth_express.dart';

class _RecordingApi extends SolsynthExpressApi {
  _RecordingApi()
    : super(
        baseUrl: 'https://distribution.example/api',
        productId: 'product-id',
      );

  String? requestedCurrentVersion;
  String? requestedClientVersion;
  String? requestedOSVersion;
  String? requestedLocale;

  @override
  Future<DistributionUpdateCheck> checkForUpdate({
    required String currentVersion,
    required String platform,
    required String architecture,
    String channel = 'stable',
    String? installationId,
    String? osVersion,
    String? clientVersion,
    String? locale,
  }) async {
    requestedCurrentVersion = currentVersion;
    requestedClientVersion = clientVersion;
    requestedOSVersion = osVersion;
    requestedLocale = locale;
    return DistributionUpdateCheck(
      updateAvailable: false,
      currentVersion: currentVersion,
      release: null,
    );
  }
}

void main() {
  testWidgets('update checks include the package build number', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'MaidKit',
      packageName: 'dev.solsynth.maidkit',
      version: '1.3.0',
      buildNumber: '20',
      buildSignature: '',
    );
    final api = _RecordingApi();
    final service = UpdateService(api: api);
    late BuildContext context;

    // The macOS host in the test environment has no native plugin registered;
    // mock the platform channel so the OS version is resolved synchronously.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/device_info'),
      (MethodCall call) async {
        if (call.method != 'getDeviceInfo') return null;
        return <String, dynamic>{
          'computerName': 'Test Mac',
          'hostName': 'test.local',
          'arch': 'arm64',
          'model': 'MacBookPro18,3',
          'modelName': 'MacBook Pro',
          'kernelVersion': 'Darwin Kernel Version 24.3.0',
          'osRelease': '24.3',
          'majorVersion': 24,
          'minorVersion': 3,
          'patchVersion': 0,
          'activeCPUs': 10,
          'memorySize': 17179869184,
          'cpuFrequency': 0,
          'systemGUID': 'TEST-GUID',
        };
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await service.checkForUpdates(context);

    expect(api.requestedCurrentVersion, '1.3.0+20');
    expect(api.requestedClientVersion, '1.3.0+20');
    // The MaterialApp default locale is en_US, which must be sent as a BCP-47
    // language tag for the metrics by_locale breakdown.
    expect(api.requestedLocale, 'en-US');
    expect(api.requestedOSVersion, '24.3');
  });
}
