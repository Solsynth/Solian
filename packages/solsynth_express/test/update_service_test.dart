import 'package:flutter/material.dart';
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
  });
}
