/// The user's Solar Network account and standing, as read-only tools.
///
/// Tells the companion who it is talking to — the username to address them by,
/// their display name, their level, their credits and their achievements — and
/// lets it look up someone else's public profile. Nothing here writes: the
/// grant is the reading of account data, so switching this on cannot change an
/// account, and the prompt says so rather than leaving the model to infer it.
///
/// Each request names the route it calls and projects the decoded JSON down to
/// the fields the answer is about, rather than going through the SDK's account
/// methods. Two of those are wrong at runtime: `getSocialCredits` reads
/// `/stargate/accounts/me/credits`, which serves `ActionResult<bool>` — a
/// receipt for the read, not a balance — and the progression models behind the
/// achievements lag the service's DTOs far enough that one field the wire
/// stopped sending ends the call with a cast error. The routes here are the
/// ones the app's own account and progression pages read.
///
/// On demand: four definitions cost context on every request, and an identity
/// fact is needed occasionally rather than in a burst.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

/// How many characters of a bio the model is given.
///
/// A bio is prose a person wrote for other people to read, so the opening is
/// the part that carries meaning; the rest is marked as cut rather than spent
/// on the context window.
const int _bioChars = 300;

/// The signed-in account, merged with its profile, badges, perk and contacts.
///
/// One request answers identity and standing together: the profile is
/// embedded, so the level, the credit balance and the active badge ride along
/// with the name, and a second lookup would re-fetch what is already in hand.
const String _accountPath = '/stargate/accounts/me';

/// Where the account's progression lives.
///
/// The states are a bare array and the totals are the `/stats` sibling; the
/// service does not serve the single-record shape the typed client reads. The
/// list route also takes an optional `query`, which no tool here needs.
const String _achievementsPath =
    '/stargate/accounts/me/progression/achievements';

class ProfilePlugin extends SnPlugin {
  const ProfilePlugin();

  @override
  String get id => 'profile';

  @override
  String get label => 'thoughtsSkillProfileLabel'.tr();

  @override
  String get description => 'thoughtsSkillProfileDescription'.tr();

  @override
  String get summary =>
      'Look up the user\'s account, other accounts, credits and achievements';

  @override
  bool get onDemand => true;

  /// The two lookups the server also offers.
  ///
  /// Not claimed: `get_my_leveling`, which is a different thing from the
  /// achievements and credits read here — a level and its history, not what
  /// has been unlocked.
  @override
  Map<String, String> get overrides => const {
    'get_current_user_profile': 'whoami',
    'get_user_profile': 'read_account',
  };

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'whoami',
        description:
            'The signed-in Solar Network account: the username to address the '
            'user by, their display name, bio, level, social credit balance '
            'and the date they joined. Read it whenever an answer depends on '
            'who the user is, rather than assuming a name.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          return _account(await solarGet(dio, _accountPath));
        }),
      ),
      SnLocalTool(
        name: 'read_account',
        description:
            'Another Solar Network account by username: the public profile and '
            'the standing it carries — level, credits, active badge, bio. '
            'Takes the username as it appears in a profile URL, without the '
            'leading @.',
        parameters: {
          'type': 'object',
          'properties': {
            'username': {
              'type': 'string',
              'description': 'The account username, e.g. "littleSheep".',
            },
          },
          'required': ['username'],
        },
        execute: (arguments) => solarToolResult(() async {
          final username = solarText(arguments, 'username');
          if (username == null) return solarMissing('username');
          final account = await solarGet(
            dio,
            '/stargate/accounts/${Uri.encodeComponent(username)}',
          );
          // An account the service does not know is a 404, which reads as
          // "there is no such item"; a route that answers an empty body is
          // named here so the model is not handed an empty object.
          if (account == null) {
            return {'error': 'There is no account "$username".'};
          }
          return _account(account);
        }),
      ),
      SnLocalTool(
        name: 'social_credits',
        description:
            'The user\'s Solar Network social credit balance and credit level, '
            'as their own account profile reports them: the balance is a field '
            'of the profile rather than a counter of its own. Read it when they '
            'ask about their score, rather than estimating one from anything '
            'else.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final profile = solarMap(await solarGet(dio, _accountPath), 'profile');
          final credits = solarNumber(profile, 'social_credits');
          // A balance of zero is the answer "zero"; only a profile that does
          // not carry the field at all is a gap worth naming, because the
          // whole of what this tool reports is that number.
          if (credits == null) {
            return {
              'error': 'The account profile does not report a social credit '
                  'balance.',
            };
          }
          final level = solarInt(profile, 'social_credits_level');
          return {
            'credits': credits,
            'credits_level': ?level,
          };
        }),
      ),
      SnLocalTool(
        name: 'achievements',
        description:
            'The user\'s Solar Network achievement progress: what they have '
            'unlocked, what is still in progress, and the totals across every '
            'achievement.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          // The list goes first and the totals second, rather than both at
          // once: a refused list would otherwise leave a second request in
          // flight whose error nobody reads, which surfaces as a crash the run
          // has to absorb. One extra round trip on a rarely-called read is the
          // cheaper trade.
          final states = solarPage(await solarGet(dio, _achievementsPath));
          final counts = await solarGet(dio, '$_achievementsPath/stats');
          return _progress(states, counts);
        }),
      ),
    ];
  }

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'The user\'s Solar Network account tools are loaded: local_whoami, '
    'local_read_account, local_social_credits and local_achievements. They are '
    'read-only facts about the user\'s own account — including the credit '
    'balance its profile carries — and other people\'s public profiles, and '
    'they change nothing.',
    'A username is not an id: use the username a tool returned, as the server '
    'spells it, rather than inventing one or reading an id as a name.',
  ];
}

/// One account as the model reads it: who this is, how to name them, and the
/// standing the profile carries.
///
/// The profile is embedded in both account answers, so the level, the credits
/// and the active badge come with the name in the same request. Every field is
/// read tolerantly and a key the wire omits is simply absent from the answer:
/// a name without a bio is still a name, and it is not a cast failure.
Map<String, dynamic> _account(Object? json) {
  final profile = solarMap(json, 'profile');
  final badge = solarMap(profile, 'active_badge');
  return solarCompact({
    'id': solarString(json, 'id'),
    'username': solarString(json, 'name'),
    'display_name': solarString(json, 'nick'),
    'bio': solarClip(solarString(profile, 'bio'), limit: _bioChars),
    'level': solarInt(profile, 'level'),
    'credits': solarNumber(profile, 'social_credits'),
    'credits_level': solarInt(profile, 'social_credits_level'),
    'verified': solarField(profile, 'verification') != null,
    'badge': solarString(badge, 'label'),
    'created_at':
        solarTimeField(json, 'created_at') ??
        solarTimeField(profile, 'created_at'),
  });
}

/// The achievement state as the model reads it.
///
/// Every record carries its reward definition and its whole series of stages;
/// a long-lived account has dozens of them, and none of that detail changes
/// the answer to "what have I unlocked". Only what identifies a record and how
/// far along it is is kept, split by whether it is done.
Map<String, dynamic> _progress(List<Object?> achievements, Object? counts) {
  final unlocked = <Map<String, dynamic>>[];
  final inProgress = <Map<String, dynamic>>[];
  for (final achievement in achievements) {
    final projected = _achievement(achievement);
    // An element that identifies nothing is not a record the model can act on.
    if (projected.isEmpty) continue;
    // A record the wire did not mark as completed is in progress: unknown is
    // told apart from done, and never from a cast.
    (solarField(achievement, 'is_completed') == true ? unlocked : inProgress)
        .add(projected);
  }
  return {
    'counts': solarCompact({
      'total': solarInt(counts, 'total_count'),
      'completed': solarInt(counts, 'completed_count'),
      'hidden_total': solarInt(counts, 'hidden_total_count'),
      'hidden_completed': solarInt(counts, 'hidden_completed_count'),
      'completion_percent': solarNumber(counts, 'completion_percentage'),
    }),
    // Both lists are always present: an empty one answers "nothing here",
    // which is not the same as a key the model has to guess about.
    'unlocked': unlocked,
    'in_progress': inProgress,
  };
}

/// One achievement, down to where it stands.
///
/// The two counters are read one at a time: a record the wire barely fills in
/// still names itself and still reports the half of its progress that arrived.
Map<String, dynamic> _achievement(Object? json) {
  final progress = solarInt(json, 'progress_count');
  final target = solarInt(json, 'target_count');
  return solarCompact({
    'identifier': solarString(json, 'identifier'),
    'title': solarString(json, 'title'),
    'progress': progress == null && target == null
        ? null
        : '${progress ?? 0}/${target ?? 0}',
    'completed_at': solarTimeField(json, 'completed_at'),
    'series': solarString(json, 'series_title'),
  });
}
