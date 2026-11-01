/// The plugin registry: the one place that knows which capabilities exist.
///
/// [kBuiltInPlugins] is the list of everything the app ships. From it the
/// registry derives what the run is built from:
///
///  * [pluginEnablementProvider] — which plugins the user has switched on,
///    persisted per plugin. This is the permission boundary: a plugin that is
///    off is not offered to the model at all, so switching it off is a
///    capability removed rather than a refusal the model could argue past.
///  * [pluginToolsProvider] — the tools the loaded plugins offer, read by the
///    chat controller on every run and by the client-tool dispatch.
///  * [pluginSkillsProvider] — the names of the on-demand plugins that could
///    still be loaded, advertised to the server so its `list_skills` can offer
///    them alongside its own.
///  * [pluginSystemPromptProvider] — the prompt text the loaded ones
///    contribute, sent with the run as its `context`.
///
/// The settings page iterates the registry directly, so a new plugin appears
/// there — switch, description and any rows of its own — without an edit.
library;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/thoughts/personality_api.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/agenda_plugin.dart';
import 'package:island/thoughts/plugins/boards_plugin.dart';
import 'package:island/thoughts/plugins/chat_plugin.dart';
import 'package:island/thoughts/plugins/mail_plugin.dart';
import 'package:island/thoughts/plugins/notifications_plugin.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/profile_plugin.dart';
import 'package:island/thoughts/plugins/ritual_plugin.dart';
import 'package:island/thoughts/plugins/social_plugin.dart';
import 'package:island/thoughts/plugins/wallet_plugin.dart';
import 'package:island/thoughts/plugins/web_tools_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';

/// The client tool the model calls to load an on-demand plugin's tools.
///
/// Advertised only while something is still loadable, so a run whose plugins
/// are all eager carries no activation machinery at all. The model reads it
/// under the server's namespace — `local_load_skill` — like any other
/// client-owned name.
const String loadSkillToolName = 'load_skill';

/// Every plugin the app ships, in the order settings lists them and the model
/// is offered their tools.
///
/// Order is load-bearing for the tool list: it is what the model reads, and
/// the tests pin it. Add a plugin at the end unless there is a reason not to.
const List<SnPlugin> kBuiltInPlugins = [
  WebSearchPlugin(),
  WebFetchPlugin(),
  SocialPlugin(),
  ChatPlugin(),
  NotificationsPlugin(),
  AgendaPlugin(),
  RitualPlugin(),
  ProfilePlugin(),
  WalletPlugin(),
  MailPlugin(),
  BoardsPlugin(),
];

/// The plugins this build offers.
///
/// The companion hosts no script or MCP packs of its own here: what a run can
/// reach is exactly the set below, switched on per plugin in the AI console.
final pluginRegistryProvider = Provider<List<SnPlugin>>(
  (ref) => kBuiltInPlugins,
);

/// A bare client with no `Authorization` header.
///
/// Plugin traffic to third-party hosts must never carry the account token, so
/// the web-facing plugins are given this rather than the authenticated client.
/// One instance for the app's lifetime: connection reuse matters for the
/// search-engine chain, which walks several hosts per call.
final pluginHttpClientProvider = Provider<Dio>((ref) {
  final client = Dio();
  ref.onDispose(client.close);
  return client;
});

/// Everything a plugin is built from, resolved once.
///
/// [apiClientProvider] is the app's account-authenticated client against the
/// gateway, so a tool's call leaves from the user's own connection carrying
/// their own token — the same client every screen in the app reads with.
final pluginContextProvider = Provider<SnPluginContext>(
  (ref) => SnPluginContext(
    api: ref.watch(apiClientProvider),
    http: ref.watch(pluginHttpClientProvider),
  ),
);

/// The plugin ids the user has switched on, persisted per plugin.
class PluginEnablementNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final preferences = ref.watch(sharedPreferencesProvider);
    return {
      for (final plugin in ref.watch(pluginRegistryProvider))
        if (_isEnabled(preferences, plugin)) plugin.id,
    };
  }

  /// Flips one plugin's switch and remembers it across launches.
  ///
  /// An unknown [id] is ignored: the persisted set only ever names plugins
  /// this build has, so a switch left behind by an older build cannot grant
  /// anything.
  Future<void> setEnabled(String id, bool enabled) async {
    final plugin = ref
        .read(pluginRegistryProvider)
        .firstWhereOrNull((plugin) => plugin.id == id);
    if (plugin == null) return;
    await ref.read(sharedPreferencesProvider).setBool(plugin.storeKey, enabled);
    final next = Set<String>.of(state);
    if (enabled) {
      next.add(id);
    } else {
      next.remove(id);
    }
    // A plugin switched off must not stay loaded: dropping it here means the
    // next message cannot reach a tool the user just withdrew.
    state = next;
    if (!enabled) {
      ref.read(activePluginsProvider.notifier).unload(id);
    }
  }
}

/// Whether one plugin is on: its own stored switch, the value stored under a
/// key it inherited from an earlier build, or its default when neither has
/// ever been written.
///
/// The inherited keys are consulted before the default and only until the
/// user touches the switch, which is what keeps a choice made against the
/// broader plugin it was split out of.
bool _isEnabled(SharedPreferences preferences, SnPlugin plugin) {
  final stored = preferences.getBool(plugin.storeKey);
  if (stored != null) return stored;
  for (final key in plugin.inheritedStoreKeys) {
    final inherited = preferences.getBool(key);
    if (inherited != null) return inherited;
  }
  return plugin.enabledByDefault;
}

final pluginEnablementProvider =
    NotifierProvider<PluginEnablementNotifier, Set<String>>(
      PluginEnablementNotifier.new,
    );

/// The enabled plugins, in registry order.
final enabledPluginsProvider = Provider<List<SnPlugin>>((ref) {
  final enabled = ref.watch(pluginEnablementProvider);
  return [
    for (final plugin in ref.watch(pluginRegistryProvider))
      if (enabled.contains(plugin.id)) plugin,
  ];
});

/// The enabled plugins whose tools are on the run.
///
/// An eager plugin always is; an on-demand plugin is once the model has
/// activated it. Every consumer of "what the model has" reads this, so the
/// tools offered, the prompt text that explains them and the dispatch that
/// resolves an incoming call can never disagree.
final loadedPluginsProvider = Provider<List<SnPlugin>>((ref) {
  final active = ref.watch(activePluginsProvider);
  return [
    for (final plugin in ref.watch(enabledPluginsProvider))
      if (!plugin.onDemand || active.contains(plugin.id)) plugin,
  ];
});

/// The on-demand plugin ids the model has loaded in this conversation.
///
/// Scoped to the conversation, like the server's own activated skills: the
/// chat controller clears it whenever the conversation changes, so a plugin
/// loaded while talking to one agent is not silently loaded for another.
class ActivePluginsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// Records that the model has loaded one plugin.
  void load(String id) {
    if (state.contains(id)) return;
    state = {...state, id};
  }

  /// Drops one plugin, so its tools leave the conversation. Called when its
  /// switch goes off — a withdrawn grant must not survive in the run.
  void unload(String id) {
    if (!state.contains(id)) return;
    state = {...state}..remove(id);
  }

  /// Called by the chat controller when the conversation changes.
  void clear() {
    if (state.isEmpty) return;
    state = const {};
  }
}

final activePluginsProvider =
    NotifierProvider<ActivePluginsNotifier, Set<String>>(
      ActivePluginsNotifier.new,
    );

/// The on-demand skills still available to load, in registry order: what the
/// server lists alongside its own skills, so the model asks in one place.
final pluginSkillsProvider = Provider<List<SnClientSkill>>((ref) {
  final loaded = ref.watch(loadedPluginsProvider);
  return [
    for (final plugin in ref.watch(enabledPluginsProvider))
      if (plugin.onDemand && !loaded.contains(plugin))
        SnClientSkill(name: plugin.skillName, description: plugin.summary),
  ];
});

/// Every tool the loaded plugins offer, plus the activation tool while
/// anything is still loadable.
///
/// This is what the run request carries as `client_tools` and what the
/// client-tool dispatch resolves an incoming name against, so the two can
/// never disagree about what the model was offered.
final pluginToolsProvider = Provider<List<SnLocalTool>>((ref) {
  final context = ref.watch(pluginContextProvider);
  final loadable = ref.watch(pluginSkillsProvider);
  return [
    for (final plugin in ref.watch(loadedPluginsProvider))
      ...plugin.buildTools(context),
    if (loadable.isNotEmpty) _loadSkillTool(ref, context),
  ];
});

/// The server-owned tool names the loaded plugins replace.
///
/// Sent with the run so the server leaves its own copies out of the tool list
/// the model reads: one tool per job, and the one that survives is the one
/// that runs from the user's own address. Derived from the loaded set rather
/// than the enabled one for the same reason the tools are — a capability the
/// model has not loaded yet is not replacing anything.
///
/// Sorted, so an unchanged set is recognisably unchanged in a run body and in
/// a diff of one.
final pluginOverridesProvider = Provider<List<String>>((ref) {
  final names = <String>{};
  for (final plugin in ref.watch(loadedPluginsProvider)) {
    names.addAll(plugin.overrides.keys);
  }
  return names.toList()..sort();
});

/// The system prompt text the loaded plugins contribute, in registry order.
///
/// Sent with the run as its `context` and appended to the agent's own system
/// prompt server-side. Blank fragments are dropped here rather than left for
/// the server to trim.
final pluginSystemPromptProvider = Provider<List<String>>((ref) {
  final context = ref.watch(pluginContextProvider);
  final fragments = <String>[];
  for (final plugin in ref.watch(loadedPluginsProvider)) {
    for (final fragment in plugin.systemPrompt(context)) {
      final text = fragment.trim();
      if (text.isNotEmpty) fragments.add(text);
    }
  }
  return fragments;
});

/// The tool that loads an on-demand plugin, and reports what it loaded.
///
/// Loading is the whole of its work: the tool list is derived from
/// [activePluginsProvider], so flipping the switch here is what makes the
/// plugin's tools — and its prompt text — part of the conversation. The chat
/// controller notices the new tools when it resumes the paused run and hands
/// them to the server, which is what makes them callable without waiting for
/// the next message.
///
/// A skill is named as the model read it, so the server's namespace is
/// stripped from the argument before the plugin is looked up.
SnLocalTool _loadSkillTool(Ref ref, SnPluginContext context) {
  return SnLocalTool(
    name: loadSkillToolName,
    description:
        'Load a skill that runs on the user\'s own device. Call list_skills '
        'for the ones available; a skill listed as local runs here rather '
        'than on the server. Loading is what makes its tools callable.',
    parameters: const <String, dynamic>{
      'type': 'object',
      'properties': <String, dynamic>{
        'skill': <String, dynamic>{
          'type': 'string',
          'description': 'Name of the local skill to load.',
        },
      },
      'required': <String>['skill'],
    },
    execute: (arguments) async {
      final asCalled = (arguments['skill'] ?? '').toString().trim();
      final requested = unnamespacedToolName(asCalled) ?? asCalled;
      final enabled = ref.read(enabledPluginsProvider);
      final plugin = enabled.firstWhereOrNull(
        (plugin) => plugin.onDemand && plugin.skillName == requested,
      );
      if (plugin == null) {
        // A miss is answered with the catalogue rather than a bare refusal:
        // the model asked for something, and the useful reply is what it can
        // ask for instead.
        final available = [
          for (final candidate in ref.read(pluginSkillsProvider))
            namespacedToolName(candidate.name),
        ];
        return jsonEncode({
          'ok': false,
          'error': 'no such local skill: $asCalled',
          'available': available,
        });
      }
      final id = plugin.id;
      ref.read(activePluginsProvider.notifier).load(id);
      return jsonEncode({
        'ok': true,
        'skill': requested,
        'tools': [for (final tool in plugin.buildTools(context)) tool.name],
        'message': 'Skill loaded. Its tools are callable now.',
      });
    },
  );
}
