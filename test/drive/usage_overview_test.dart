import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/drive/widgets/usage_overview.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 20,000 MB base quota + 5,000 MB extra; 12,800 MB used (51%); three pools.
const _usage = <String, dynamic>{
  'total_usage_bytes': 12 * 1024 * 1024,
  'total_file_count': 1204,
  'total_quota': 20000,
  'used_quota': 12800.0,
  'pool_usages': [
    {'pool_name': 'Photos', 'usage_bytes': 6 * 1024 * 1024 * 1024},
    {'pool_name': 'Documents', 'usage_bytes': 3 * 1024 * 1024 * 1024},
    {'pool_name': 'Backup archive', 'usage_bytes': 3 * 1024 * 1024 * 1024},
  ],
};

const _quota = <String, dynamic>{'based_quota': 20000, 'extra_quota': 5000};

Widget _wrap(
  Map<String, dynamic>? usage,
  Map<String, dynamic>? quota, {
  Brightness brightness = Brightness.light,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: context.localizationDelegates,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: brightness,
          ),
        ),
        home: Scaffold(
          body: UsageOverviewWidget(usage: usage, quota: quota),
        ),
      ),
    ),
  );
}

/// Pumps with real async room so EasyLocalization's file-backed load
/// completes, then flushes the entry fill animation.
Future<void> _pump(
  WidgetTester tester,
  Map<String, dynamic>? usage,
  Map<String, dynamic>? quota, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      _wrap(usage, quota, brightness: brightness),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('renders nothing when usage is null', (tester) async {
    await _pump(tester, null, _quota);
    expect(find.byType(UsageOverviewWidget), findsOneWidget);
    expect(find.text('Used'), findsNothing);
    expect(find.text('Pool Usage'), findsNothing);
  });

  testWidgets('headline readout shows used, available, percent and status', (
    tester,
  ) async {
    await _pump(tester, _usage, _quota);
    expect(find.text('Used'), findsOneWidget);
    expect(find.text('12.50 GB'), findsOneWidget);
    expect(find.text('/ 24.41 GB'), findsOneWidget);
    // 51%: readout percent and the free-space share.
    expect(find.text('51%'), findsNWidgets(2));
    expect(find.text('Moderate'), findsOneWidget);
  });

  testWidgets('shows base and extra quota legend', (tester) async {
    await _pump(tester, _usage, _quota);
    expect(find.text('Base quota'), findsOneWidget);
    expect(find.text('19.53 GB'), findsOneWidget);
    expect(find.text('Extra quota'), findsOneWidget);
    expect(find.text('4.88 GB'), findsOneWidget);
  });

  testWidgets('omits extra quota legend when none purchased', (tester) async {
    await _pump(
      tester,
      _usage,
      const {'based_quota': 20000, 'extra_quota': 0},
    );
    expect(find.text('Extra quota'), findsNothing);
  });

  testWidgets('pool tank lists pools with sizes and capacity shares', (
    tester,
  ) async {
    await _pump(tester, _usage, _quota);
    expect(find.text('Pool Usage'), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('6.00 GB'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Backup archive'), findsOneWidget);
    // Both 3 GB pools.
    expect(find.text('3.00 GB'), findsNWidgets(2));
    expect(find.text('12%'), findsNWidgets(2));
    // Free space remainder: 24.41 GB capacity - 12 GB pools.
    expect(find.text('Free space'), findsOneWidget);
    expect(find.text('12.41 GB'), findsOneWidget);
    // Capacity shares must sum to 100%.
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('12%'), findsNWidgets(2));
    expect(find.text('51%'), findsNWidgets(2));
  });

  testWidgets('omits the pool section when there are no pools', (tester) async {
    final usageWithoutPools = Map<String, dynamic>.from(_usage)
      ..remove('pool_usages');
    await _pump(tester, usageWithoutPools, _quota);
    expect(find.text('Pool Usage'), findsNothing);
    expect(find.text('Free space'), findsNothing);
  });

  testWidgets('shows critical status when nearly full', (tester) async {
    await _pump(tester, {..._usage, 'used_quota': 24000.0}, _quota);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('96%'), findsOneWidget);
  });

  testWidgets('file count uses thousands grouping', (tester) async {
    await _pump(tester, _usage, _quota);
    expect(find.text('Files'), findsOneWidget);
    expect(find.text('1,204'), findsOneWidget);
  });

  testWidgets('long pool names are truncated with an ellipsis', (tester) async {
    const longName = 'A very long pool name that will be truncated';
    final usage = {
      ..._usage,
      'pool_usages': [
        {'pool_name': longName, 'usage_bytes': 6 * 1024 * 1024 * 1024},
      ],
    };
    await _pump(tester, usage, _quota);
    final text = tester.widget<Text>(find.text(longName));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('no pie charts remain in the overhauled widget', (tester) async {
    await _pump(tester, _usage, _quota);
    expect(find.byType(PieChart), findsNothing);
  });
}
