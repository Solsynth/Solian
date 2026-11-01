/// The user's Solar Network daily ritual, as tools.
///
/// Three small calls: the saying the day holds, whether today's check-in has
/// been claimed, and claiming it. They ride on every run rather than waiting
/// to be activated — three one-line definitions cost almost nothing, and "what
/// is my fortune today?" is asked in passing, not as a request the companion
/// should answer only after going to look for a skill.
///
/// The check-in is the one thing here that changes the account, and it is
/// worth its own tool even though [today_check_in] already reads the same
/// endpoint: a read the model can do freely and a write it should only do on
/// request are different decisions, and the prompt fragment says which is
/// which.
///
/// ## Why the fortune is drawn here rather than asked for
///
/// There is no fortune of the day to ask for. The Passport service serves the
/// sayings at `/stargate/fortune` and one of them at `/stargate/fortune/random`,
/// and the second answers a different saying on every call — which is the
/// opposite of what a daily fortune is. So [daily_fortune] reads the list and
/// picks, and is honest in its description that the app is the one picking.
library;

import 'package:dio/dio.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

/// The report version the check-in routes are asked for.
///
/// It is the generator's current version, not the user's, and asking for it is
/// what makes the service fill in a check-in's reading before answering.
const int _reportVersion = 2;

class RitualPlugin extends SnPlugin {
  const RitualPlugin();

  @override
  String get id => 'ritual';

  @override
  String get label => 'thoughtsSkillRitualLabel'.tr();

  @override
  String get description => 'thoughtsSkillRitualDescription'.tr();

  @override
  String get summary => 'Daily fortune and the Solar Network check-in';

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'daily_fortune',
        description:
            'One fortune saying for today, with where it comes from. Solar '
            'Network keeps no fortune of the day, so this app draws one from '
            'its list and holds it for the whole day: asking again today '
            'answers the same saying, and tomorrow it moves on.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final sayings = [
            for (final saying in solarPage(
              await solarGet(dio, '/stargate/fortune'),
            ))
              _saying(saying),
          ]..removeWhere((saying) => saying.isEmpty);
          if (sayings.isEmpty) {
            return {'error': 'Solar Network offered no sayings to draw from.'};
          }
          return sayings[_dayIndex(sayings.length)];
        }),
      ),
      SnLocalTool(
        name: 'today_check_in',
        description:
            'Whether the user has claimed today\'s Solar Network check-in, and '
            'what the day gave them when they have. An unclaimed day answers '
            '`checked_in` of false — that is the answer, not a failed call — '
            'and claiming it is what the check_in tool is for.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final Object? result;
          try {
            result = await solarGet(
              dio,
              '/stargate/accounts/me/check-in',
              query: {'version': _reportVersion},
            );
          } on DioException catch (error) {
            // A day that has not been claimed is not there to read, and the
            // endpoint says so with a 404. That is a state of the day rather
            // than a failed call, so it becomes the answer. Every other status
            // is left to the failure text, which names it.
            if (error.response?.statusCode == 404) {
              return {'checked_in': false};
            }
            rethrow;
          }
          return result == null ? _noRead : _checkIn(result);
        }),
      ),
      SnLocalTool(
        name: 'check_in',
        description:
            'Claims today\'s Solar Network check-in for the user and returns '
            'what it gave them. A day can be claimed once, so a day already '
            'claimed is refused rather than claimed again. Ask before claiming '
            'it: this one changes the user\'s account.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final result = await solarPost(
            dio,
            '/stargate/accounts/me/check-in',
            query: {'version': _reportVersion},
            // The route's whole body is an optional captcha token, and the
            // only honest value for it here is none: the app has no token to
            // offer, and a claim the service decides needs one is refused by
            // the service itself rather than fed a made-up token. A claim from
            // this app is a claim with no body.
            body: null,
          );
          return result == null ? _noRead : _checkIn(result);
        }),
      ),
    ];
  }

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'The fortune here is drawn for the user rather than written by you: Solar '
    'Network keeps no fortune of the day, so the app picks one saying out of '
    'its list and holds it for the whole day. Quote the saying as it stands '
    'and say where it comes from; do not pass its words off as your own '
    'advice.',
    'The check-in can be claimed once a day. Claiming it is a small favour to '
    'do when the user asks for it — it changes their account, so it is not '
    'something to do unprompted on every run.',
  ];
}

/// What to say when the check-in endpoint answered with no result.
///
/// A `200` with nothing in it is not a state of the account: it does not say
/// whether the day was claimed, so it is named instead of being guessed at as
/// either. Guessing "unclaimed" is the worse of the two — the model would
/// offer the user a check-in they have already claimed, and the claim would
/// fail in their face.
const Map<String, dynamic> _noRead = {
  'error':
      'Solar Network answered without a check-in result, so whether today is '
      'claimed is unknown.',
};

/// Which of [count] sayings the app calls today's.
///
/// The app draws one itself, and the scheme is the day's ordinal number: the
/// calendar day counted from the epoch indexes the list. Every call on the
/// same date lands on the same saying — it does not depend on the clock or on
/// which device is asking — and the next date moves one along. The count is
/// the user's own day rather than UTC's, since "today's saying" is theirs.
int _dayIndex(int count) {
  final now = DateTime.now();
  final day =
      DateTime.utc(
        now.year,
        now.month,
        now.day,
      ).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
  return day % count;
}

/// One saying as the model should read it.
///
/// The saying carries the language it was written in, which is what keeps the
/// model from quoting it as something said in the conversation's own language.
/// A slot the list left blank says nothing a reader can use, so it is dropped.
Map<String, dynamic> _saying(Object? json) => solarCompact({
  'saying': solarString(json, 'content'),
  'source': solarString(json, 'source'),
  'language': solarString(json, 'language'),
});

/// One check-in as the model should read it: what the day gave the user.
///
/// The read and the claim answer with the same result, so both project here.
/// The rewards are optional in the model — a backdated claim carries neither —
/// and a reward the wire leaves out is a key this answer does not have rather
/// than a crash or a zero.
Map<String, dynamic> _checkIn(Object? json) {
  final report = _report(solarMap(json, 'fortune_report'));
  return _filled({
    'checked_in': true,
    'level': solarInt(json, 'level'),
    'claimed_at': solarTimeField(json, 'created_at'),
    'points': solarNumber(json, 'reward_points'),
    'experience': solarInt(json, 'reward_experience'),
    'tips': _tips(json),
    if (report.isNotEmpty) 'fortune': report,
  });
}

/// The day's tips, each kept as the two halves of one: whether it is the good
/// kind of news, and the line itself.
List<Map<String, dynamic>> _tips(Object? json) => [
  for (final tip in solarList(json, 'tips'))
    _filled({
      'positive': solarField(tip, 'is_positive'),
      'title': solarString(tip, 'title'),
      'content': solarString(tip, 'content'),
    }),
]..removeWhere((tip) => tip.isEmpty);

/// The report the check-in came with, which is the part the user actually
/// reads: the poem, the reading, and the day's lucky and unlucky things.
///
/// The version belongs to the generator rather than to the user, and a slot
/// the generator left empty carries nothing a reader can use, so neither is
/// passed on.
Map<String, dynamic> _report(Object? json) => solarCompact({
  'poem': solarString(json, 'poem'),
  'summary': solarString(json, 'summary'),
  'detail': solarString(json, 'summary_detail'),
  'wish': solarString(json, 'wish'),
  'love': solarString(json, 'love'),
  'study': solarString(json, 'study'),
  'career': solarString(json, 'career'),
  'health': solarString(json, 'health'),
  'lost_item': solarString(json, 'lost_item'),
  'lucky_color': solarString(json, 'lucky_color'),
  'lucky_direction': solarString(json, 'lucky_direction'),
  'lucky_time': solarString(json, 'lucky_time'),
  'lucky_item': solarString(json, 'lucky_item'),
  'lucky_action': solarString(json, 'lucky_action'),
  'avoid_action': solarString(json, 'avoid_action'),
  'ritual': solarString(json, 'ritual'),
});

/// The fields that carry something.
///
/// [solarCompact] drops zeroes along with the blanks, and a check-in has two
/// meaningful zeroes — a level of zero is the worst roll, and a reward of zero
/// is a day that paid nothing — so they are kept and only what says nothing is
/// dropped.
Map<String, dynamic> _filled(Map<String, dynamic> fields) => fields
  ..removeWhere(
    (_, value) =>
        value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is Iterable && value.isEmpty),
  );
