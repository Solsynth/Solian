import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/thoughts/ai_console_api.dart';
import 'package:island/thoughts/personality_api.dart';
import 'package:island/thoughts/screens/ai_console.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The catalogue answer every console read is stubbed with: one agent on one
/// model, so the page draws its cards rather than its empty states.
const _agent = SnPersonalityAgent(
  id: 'a1',
  name: 'Michan',
  model: 'deepseek-flash',
  abilities: ['memory', 'humanizer'],
  enabled: true,
);

const _model = SnPersonaModel(
  id: 'deepseek-flash',
  provider: 'deepseek',
  name: 'DeepSeek Flash',
  modalities: ['text', 'image'],
  pricing: SnPersonaModelPricing(currency: 'USD', input: '0.1', output: '0.4'),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      kTokenPairStoreKey: '{"token":"stub","expires_at":"2099-01-01T00:00:00Z"}',
    });
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pump(WidgetTester tester, ProviderContainer container) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: EasyLocalization(
            supportedLocales: const [Locale('en', 'US')],
            path: 'assets/i18n',
            saveLocale: false,
            child: Builder(
              builder: (context) => MaterialApp(
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: [
                  ...context.localizationDelegates,
                  ...flutter_localizations.GlobalMaterialLocalizations
                      .delegates,
                ],
                home: const AiConsoleScreen(),
              ),
            ),
          ),
        ),
      );
      // The console's reads resolve outside the fake clock, so the future
      // completions need a real turn before the tree can draw them.
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<ProviderContainer> buildContainer() async {
    final preferences = await SharedPreferences.getInstance();
    return ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        personalityAgentsProvider.overrideWith((ref) async => [_agent]),
        personaModelsProvider.overrideWith((ref) async => [_model]),
        personaBillingProvider.overrideWith(
          (ref) async => const SnPersonaBilling(
            spendingQuota: '25',
            usage: SnPersonaBillingUsage(
              hourly: {'USD': SnPersonaRunUsage(used: '0.5', max: '10')},
              daily: {'USD': SnPersonaRunUsage(used: '4.2', max: '30')},
            ),
          ),
        ),
        personaLedgerSummaryProvider.overrideWith(
          (ref, query) async => const SnLedgerSummary(
            entries: 3,
            byAction: [
              SnLedgerBucket(
                key: 'generation',
                currency: 'USD',
                amount: '1.20',
              ),
            ],
            byCurrency: [
              SnLedgerBucket(key: 'USD', currency: 'USD', amount: '1.20'),
            ],
          ),
        ),
        personaBillingLedgerProvider.overrideWith(
          (ref, query) async => [
            SnLedgerEntry(
              id: 'l1',
              action: 'generation',
              surface: '/persona/conversations/:id/runs',
              model: 'deepseek-flash',
              currency: 'USD',
              originalAmount: '0.4',
              createdAt: DateTime.utc(2026, 10, 30, 12),
            ),
          ],
        ),
        personaSearchChoiceProvider.overrideWith(
          (ref) async => const SnWebSearchChoice(
            catalog: SnWebSearchCatalog(
              currency: 'USD',
              engines: [
                SnWebSearchEngine(id: 'tavily', price: '0.01'),
                SnWebSearchEngine(id: 'local', free: true),
              ],
            ),
            preference: SnWebSearchPreference(engine: 'tavily'),
          ),
        ),
      ],
    );
  }

  testWidgets('the console draws its catalogue, billing and spend', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = await buildContainer();
    addTearDown(container.dispose);

    await pump(tester, container);

    expect(tester.takeException(), isNull);
    // Catalogue: the agent and the model it runs on.
    expect(find.text('Michan'), findsOneWidget);
    expect(find.text('DeepSeek Flash'), findsOneWidget);

    // Billing: the standing, the quota field and the meters.
    await tester.tap(find.text('Billing'));
    await tester.pumpAndSettle();
    expect(find.text('Billing in good standing'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('0.50 / 10.00'), findsOneWidget);

    // Usage: the engine choice, the breakdown and the receipt line.
    await tester.tap(find.text('Usage'));
    await tester.pumpAndSettle();
    expect(find.text('Search provider'), findsOneWidget);
    // Named twice on purpose: once as a breakdown row, once as the receipt
    // line under it.
    expect(find.text('Reply'), findsNWidgets(2));
  });

  testWidgets('a suspended account is offered the way out', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        personaBillingProvider.overrideWith(
          (ref) async => const SnPersonaBilling(blacklisted: true),
        ),
      ],
    );
    addTearDown(container.dispose);

    await pump(tester, container);
    await tester.tap(find.text('Billing'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Billing suspended'), findsOneWidget);
    expect(find.text('Settle unpaid usage'), findsOneWidget);
  });
}
