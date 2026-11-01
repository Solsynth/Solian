/// The user's Solar Network wallet: what it holds, and what moved through it.
///
/// Read-only, and the boundary is load-bearing. Moving money on Solar Network
/// is authorised by the user's local payment PIN, which this app does not hold
/// and must never ask for — so there is no transfer, order, gift or
/// subscription tool here, and none should be added. A plugin that offered one
/// would have to collect a PIN the app is not entitled to see, and the model
/// would learn to ask the user for it. Reading a balance and asking the user
/// to spend it in the app is the whole of what this grant covers.
///
/// Both tools name the gateway path they read and project the decoded JSON,
/// rather than calling the SDK's typed methods. The wallet model has kept
/// moving — pockets grew `held_amount`, the statistics answer grew its
/// category maps — and a projection over the raw body reads a field the
/// service stops sending as a missing value instead of failing the call.
///
/// On demand: the companion needs a balance rarely, and a user who leaves the
/// switch off should not pay for the definitions on every run.
library;

import 'package:dio/dio.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

/// The window `wallet_stats` reports, in days.
///
/// It is the service's own default, named here so the answer cannot change
/// under the model when that default moves.
const int _statsPeriodDays = 30;

/// The currency `wallet_stats` reports.
///
/// A wallet holds one pocket per currency, and the points balance is the one a
/// user acts on; summing a period across currencies would report a total in
/// units the model cannot compare.
const String _statsCurrency = 'points';

class WalletPlugin extends SnPlugin {
  const WalletPlugin();

  @override
  String get id => 'wallet';

  @override
  String get label => 'thoughtsSkillWalletLabel'.tr();

  @override
  String get description => 'thoughtsSkillWalletDescription'.tr();

  @override
  String get summary => 'Read the wallet balance and statistics';

  @override
  bool get onDemand => true;

  /// The balance the server's `list_wallets` reads.
  ///
  /// Not claimed: `list_orders`, which is an order history these tools do not
  /// answer.
  @override
  Map<String, String> get overrides => const {'list_wallets': 'read_wallet'};

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'read_wallet',
        description:
            'The user\'s Solar Network wallet and what each of its currency '
            'pockets holds. Answers that the user has no wallet when that is '
            'the case. It can read a balance; it cannot move funds.',
        parameters: const {
          'type': 'object',
          'properties': <String, dynamic>{},
        },
        execute: (arguments) => solarToolResult(() async {
          final Object? found;
          try {
            found = await solarGet(dio, '/stargate/wallets');
          } on DioException catch (error) {
            // This route answers 404 when the account has no wallet yet. That
            // is a fact about the account, not a failed request, and the model
            // has to be able to say so without reporting an error.
            if (error.response?.statusCode == 404) return {'wallet': null};
            rethrow;
          }
          return {'wallet': found == null ? null : _wallet(found)};
        }),
      ),
      SnLocalTool(
        name: 'wallet_stats',
        description:
            'How the user\'s Solar Network wallet moved over the last 30 days, '
            'in points: the number of transactions and orders, what came in, '
            'what went out and the net, with a breakdown by category when the '
            'period had any. It can read history; it cannot move funds.',
        parameters: const {
          'type': 'object',
          'properties': <String, dynamic>{},
        },
        execute: (arguments) => solarToolResult(
          () async => _stats(
            await solarGet(
              dio,
              '/stargate/wallets/stats',
              // Both are spelled out rather than left to the service's
              // defaults: `currencies` defaults to points, and a request that
              // does not say so is one whose meaning changes if that default
              // ever does.
              query: const {
                'period': _statsPeriodDays,
                'currencies': _statsCurrency,
              },
            ),
          ),
        ),
      ),
    ];
  }

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'The user\'s Solar Network wallet tools are loaded: local_read_wallet and '
    'local_wallet_stats. They run as the signed-in user on their own '
    'connection.',
    'Those tools can see a balance and what moved through it; they cannot '
    'spend. Moving money on Solar Network needs the user\'s payment PIN, which '
    'this app does not hold and must never ask them for. When the user wants to '
    'transfer funds, buy or subscribe to something, say that it has to be done '
    'in the app, and never promise to carry it out from here.',
  ];
}

/// One wallet projected to what an answer needs.
///
/// A wallet embeds its account, its realm and every pocket's timestamps;
/// serializing it whole would spend the context window on bookkeeping. The
/// balance lives in the pockets, one per currency, so it is kept in full while
/// the rest of the record is dropped.
Map<String, dynamic> _wallet(Object? json) {
  final isDefault = solarField(json, 'is_default');
  return {
    'id': solarString(json, 'id'),
    'name': solarString(json, 'name'),
    // The model carries the flag twice; either one answers the same question.
    'is_default': isDefault is bool
        ? isDefault
        : solarField(json, 'is_primary') == true,
    // Set only once the user turns the public id on; the app never sets it.
    'public_id_enabled': solarString(json, 'public_id') != null,
    'pockets': [for (final pocket in solarList(json, 'pockets')) _pocket(pocket)],
  };
}

/// One currency pocket, as the model reads a balance.
///
/// `available` is omitted while nothing is held against the balance, because
/// then it repeats `balance` and a second identical number invites the model
/// to treat the two as different amounts. A pocket whose balance is zero is
/// kept: "no points left" is an answer, not an empty field.
Map<String, dynamic> _pocket(Object? json) {
  final balance = solarNumber(json, 'amount') ?? 0;
  final held = solarNumber(json, 'held_amount') ?? 0;
  final currency = solarString(json, 'currency');
  return {
    'currency': ?currency,
    'balance': balance,
    if (held > 0) 'held': held,
    if (held > 0)
      'available': solarNumber(json, 'available_amount') ?? balance - held,
  };
}

/// One period's totals, as the model reads them.
///
/// The category maps are sparse — most periods move money in one or two
/// categories — so an empty one is left out rather than sent as `{}`, and a
/// total the service did not report is left out rather than sent as `null`.
Map<String, dynamic> _stats(Object? json) => solarCompact({
  'period_begin': solarTimeField(json, 'period_begin'),
  'period_end': solarTimeField(json, 'period_end'),
  'transactions': solarInt(json, 'total_transactions'),
  'orders': solarInt(json, 'total_orders'),
  'income': solarNumber(json, 'total_income'),
  'outgoing': solarNumber(json, 'total_outgoing'),
  'net': solarNumber(json, 'sum'),
  'income_by_category': solarMap(json, 'income_categories'),
  'outgoing_by_category': solarMap(json, 'outgoing_categories'),
});
