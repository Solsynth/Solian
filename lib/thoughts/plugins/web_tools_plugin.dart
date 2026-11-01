/// The on-device web tools, as two plugins.
///
/// Search and fetch are separate switches because the server is a different
/// quality of stand-in for each: its search is the more powerful one, so a
/// user may want to leave search to it, while its address is the one search
/// engines and sites challenge with a bot check, so fetching from the user's
/// own connection is the only fetch that reliably works.
///
/// Both tools only make requests the server would have made anyway, merely
/// from the user's own connection — which is why they are on by default and
/// eager: two small definitions the companion reaches for constantly.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/local_web_tools.dart';
import 'package:island/thoughts/plugins/plugin.dart';

/// The key the single web switch was stored under before search and fetch
/// became switches of their own.
///
/// Both plugins inherit it rather than starting from their own default, so
/// the choice every user who already made it stands — including the one that
/// matters most, a user who had turned the pair off and must not find a
/// network capability granted back to them.
const String kLocalWebToolsStoreKey = 'solian_thought_local_tools_web';

/// Search the web from the user's own connection.
///
/// The switch is a choice between two searches rather than a grant of any:
/// while it is on the server's own `web_search` is dropped from the tool
/// list, and turning it off hands the job back.
class WebSearchPlugin extends SnPlugin {
  const WebSearchPlugin();

  @override
  String get id => 'web_search';

  @override
  String get label => 'thoughtsSkillWebSearchLabel'.tr();

  @override
  String get description => 'thoughtsSkillWebSearchDescription'.tr();

  @override
  String get summary =>
      'Search the web from the user\'s own connection, without the bot checks '
      'a server\'s address attracts';

  @override
  bool get enabledByDefault => true;

  @override
  List<String> get inheritedStoreKeys => const [kLocalWebToolsStoreKey];

  @override
  Map<String, String> get overrides => const {'web_search': 'web_search'};

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) => [
    buildLocalWebSearchTool(context.http),
  ];

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'Web search that runs on the user\'s own device is loaded: '
        'local_web_search leaves from the user\'s IP address, which search '
        'engines do not challenge with bot checks.',
  ];
}

/// Fetch pages from the user's own connection.
///
/// Separate from search because its reason is not preference: a site that
/// challenges the server's address with a captcha is fetched from the user's
/// own, so this is the fetch that works rather than the one the user picked.
class WebFetchPlugin extends SnPlugin {
  const WebFetchPlugin();

  @override
  String get id => 'web_fetch';

  @override
  String get label => 'thoughtsSkillWebFetchLabel'.tr();

  @override
  String get description => 'thoughtsSkillWebFetchDescription'.tr();

  @override
  String get summary =>
      'Fetch pages from the user\'s own connection, where a captcha aimed at '
      'the server\'s address cannot stop them';

  @override
  bool get enabledByDefault => true;

  @override
  List<String> get inheritedStoreKeys => const [kLocalWebToolsStoreKey];

  @override
  Map<String, String> get overrides => const {'read_webpage': 'web_fetch'};

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) => [
    buildLocalWebFetchTool(context.http),
  ];

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'Web fetch that runs on the user\'s own device is loaded: '
        'local_web_fetch leaves from the user\'s IP address, so a page that '
        'challenges the server\'s address is read from the user\'s own '
        'connection instead.',
  ];
}
