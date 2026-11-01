/// The plugin contract: one self-contained capability pack for the companion.
///
/// A plugin owns everything a feature needs to exist — the tools the model may
/// call on this device, the system prompt text that tells the model they are
/// there, and the settings row the user grants it with. Nothing in the chat
/// loop, the run request, the tool dispatch or the settings page names an
/// individual plugin: they all read the registry in [plugin_registry.dart].
///
/// Adding a feature is therefore: write one class, add it to `kBuiltInPlugins`.
/// Nothing else has to change.
///
/// ## Eager and on-demand tools
///
/// A plugin with [SnPlugin.onDemand] false offers its tools on every run: the
/// right choice for a small set the companion reaches for constantly. An
/// on-demand plugin offers nothing until the model activates it by name, which
/// is the right choice for a large or rarely-used set — the definitions cost
/// context on every request whether or not they are called. The registry
/// advertises [activateLocalSkillToolName], and the server lists what is
/// available to activate alongside its own skills, so the model sees one
/// catalogue either way.
///
/// ## Two rules a plugin author inherits from the wire format
///
///  * Name a tool for what it does (`web_search`), not for where it runs. The
///    server puts every client-owned name under [kLocalToolNamespace] before
///    the model sees it, so a plugin's name can never collide with a
///    server-owned tool however it is chosen.
///  * Everything a plugin does is account-scoped: it runs as the signed-in
///    user, on the user's own connection.
library;

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:island/thoughts/plugins/local_tool.dart';

/// What a plugin is handed when the app asks it for its tools and prompt text.
///
/// Passing the dependencies explicitly keeps a plugin a plain function of its
/// inputs — testable without a running app, and unable to reach into the app
/// for anything the context does not offer.
@immutable
class SnPluginContext {
  const SnPluginContext({required this.api, required this.http});

  /// The account-authenticated client for Solar Network. A plugin that reads
  /// Solar Network resources calls through this, so the request leaves from
  /// the user's own IP carrying the app's own token: risk control sees one
  /// user's connection rather than the whole deployment behind the server.
  final Dio api;

  /// A bare client with no `Authorization` header, for third-party hosts that
  /// must never see the account token.
  final Dio http;
}

/// The namespace the server puts in front of every client-owned tool and skill
/// name.
///
/// A plugin names its tools and skills plainly. The server prefixes them
/// before the model sees them, which is what makes a plugin name unable to
/// shadow a server tool however it is chosen, and what lets the model tell
/// which side of the wire a capability runs on. It is the server's to add —
/// `clientToolNamespace` in PersonalityCore — so nothing here should apply it
/// twice.
const String kLocalToolNamespace = 'local_';

/// What the model calls a tool that is registered under [name].
String namespacedToolName(String name) => '$kLocalToolNamespace$name';

/// The name a tool was registered under, from the name the model called, or
/// null when [namespaced] names a server tool rather than a client one.
String? unnamespacedToolName(String namespaced) =>
    namespaced.startsWith(kLocalToolNamespace)
    ? namespaced.substring(kLocalToolNamespace.length)
    : null;

/// The `SharedPreferences` key a plugin's switch is stored under.
///
/// Derived from the id rather than declared per switch, so a caller can ask
/// whether a plugin is on without holding its instance — which is what startup
/// does, before the registry exists.
String pluginStoreKey(String pluginId) => 'solian_thought_plugin_$pluginId';

/// One capability pack.
///
/// Instances are `const` and stateless: the whole of a plugin's state is the
/// user's switch and whether the model has activated it, and the whole of its
/// behaviour is the tools and prompt text it returns for the context it is
/// given.
@immutable
abstract class SnPlugin {
  const SnPlugin();

  /// Stable key, unique across the registry. Names the switch, and names the
  /// plugin in the [`SharedPreferences`] entry that remembers it.
  String get id;

  /// The switch's title in settings.
  String get label;

  /// What turning this on grants, in the user's own words. Shown under the
  /// switch, so it has to be honest about the reach of the grant.
  String get description;

  /// One line describing the capability to the model, in the third person —
  /// this is what it reads when it asks what it could load, so it says what
  /// the tools do, not what the switch grants.
  String get summary;

  /// Whether a fresh install starts with this plugin on.
  ///
  /// Defaults to off: a capability that reads the user's machine or spends
  /// their credentials is not something to grant on their behalf.
  bool get enabledByDefault => false;

  /// Whether the tools load only once the model activates the plugin.
  ///
  /// Defaults to off — the tools ride on every run. Switch a plugin on demand
  /// when its descriptions are large or its calls are rare enough that paying
  /// for them on every request is waste.
  bool get onDemand => false;

  /// The `SharedPreferences` key the switch is stored under.
  ///
  /// Derived from [id] by default. The plugins that predate this interface
  /// override it so the switch the user already flipped keeps its value.
  String get storeKey => pluginStoreKey(id);

  /// The `SharedPreferences` keys an earlier build stored this switch under,
  /// tried in order when [storeKey] itself has nothing.
  ///
  /// A plugin split out of a broader one reads the key the broader switch
  /// used, so a user who already made the choice keeps it — turning the old
  /// switch off must not hand the narrower capability back. The keys are only
  /// ever read: the first write goes to [storeKey].
  List<String> get inheritedStoreKeys => const [];

  /// The name the model activates this plugin under.
  ///
  /// The server namespaces it like any other caller-owned name, so this is
  /// what the plugin calls itself, not what the model reads.
  String get skillName => id;

  /// The server-owned tools this plugin's own tools replace, keyed by the
  /// server tool's name and holding the local tool that replaces it.
  ///
  /// Declaring one is what tells the server to stop offering its own copy, so
  /// the model is offered one tool for the job rather than two it has to
  /// choose between. The reason to prefer the local one is the reason these
  /// plugins exist at all: the call leaves from the user's own address
  /// carrying their own token, which is what risk control sees.
  ///
  /// Only declare what the plugin actually covers. An override removes the
  /// server's tool, so claiming one without a local tool that does the same
  /// work removes the capability outright. The value is never sent — it is
  /// the claim written down where a test can hold the plugin to it.
  Map<String, String> get overrides => const {};

  /// The tools the model is offered while this plugin is on, in the order it
  /// should see them.
  ///
  /// Called whenever the enabled or active set changes. A tool that has to
  /// reach the network should close over the context it is given rather than
  /// build a client of its own.
  List<SnLocalTool> buildTools(SnPluginContext context) => const [];

  /// System prompt text sent with every run while this plugin is on and
  /// loaded.
  ///
  /// This is where a plugin says what a tool description cannot: that its
  /// tools run on the user's own machine rather than the server's, what their
  /// answers therefore mean, what to confirm before acting. Blank entries are
  /// dropped by the registry.
  List<String> systemPrompt(SnPluginContext context) => const [];

  /// Extra settings rows drawn under this plugin's switch, for state a switch
  /// cannot show — a daemon that may or may not be running.
  List<Widget> settingsRows(WidgetRef ref) => const [];
}
