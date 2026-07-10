import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Resolve Material Symbols by name using **const** [IconData] only.
///
/// Flutter release builds tree-shake icon fonts and reject non-constant
/// [IconData] (see `Symbols.get` / dynamic code points). This lookup is a
/// curated map of `Symbols.*` constants so the app can tree-shake normally.
///
/// For arbitrary / brand glyphs, register a plugin font via
/// [PluginIconFontRegistry] and render with [PluginIconFontRegistry.buildIcon]
/// (uses [Text] + [FontLoader], not [IconData]).
class MaterialSymbolLookup {
  MaterialSymbolLookup._();

  /// Default when a name is missing or unknown.
  static IconData get fallback => Symbols.extension;

  /// Canonicalize a free-form name: lower-case, hyphens/spaces → underscores.
  static String normalize(String name) {
    var n = name.trim().toLowerCase();
    n = n.replaceAll(RegExp(r'[\s\-]+'), '_');
    n = n.replaceAll(RegExp(r'_+'), '_');
    if (n.endsWith('_outlined') && n != 'outlined') {
      n = n.substring(0, n.length - '_outlined'.length);
    }
    return n;
  }

  /// Parse optional style suffix (`dashboard_rounded`) or explicit style.
  static ({String name, String? style}) parseNameAndStyle(
    String raw, {
    String? style,
  }) {
    var n = normalize(raw);
    var s = style?.trim().toLowerCase();

    if (n.endsWith('_rounded')) {
      n = n.substring(0, n.length - '_rounded'.length);
      s = 'rounded';
    } else if (n.endsWith('_sharp')) {
      n = n.substring(0, n.length - '_sharp'.length);
      s = 'sharp';
    } else if (n.endsWith('_outlined')) {
      n = n.substring(0, n.length - '_outlined'.length);
      s = 'outlined';
    }

    return (name: n, style: s);
  }

  static String _lookupKey(String name, String? style) {
    final s = style?.toLowerCase();
    if (s == 'rounded') return '${name}_rounded';
    if (s == 'sharp') return '${name}_sharp';
    return name;
  }

  /// Curated const icons available to plugins (tree-shake friendly).
  static final Map<String, IconData> _icons = {
    // Core / chrome
    'extension': Symbols.extension,
    'apps': Symbols.apps,
    'dashboard': Symbols.dashboard,
    'dashboard_rounded': Symbols.dashboard_rounded,
    'home': Symbols.home,
    'settings': Symbols.settings,
    'settings_rounded': Symbols.settings_rounded,
    'search': Symbols.search,
    'menu': Symbols.menu,
    'more_vert': Symbols.more_vert,
    'more_horiz': Symbols.more_horiz,
    'close': Symbols.close,
    'check': Symbols.check,
    'check_circle': Symbols.check_circle,
    'cancel': Symbols.cancel,
    'add': Symbols.add,
    'add_circle': Symbols.add_circle,
    'remove': Symbols.remove,
    'delete': Symbols.delete,
    'delete_forever': Symbols.delete_forever,
    'edit': Symbols.edit,
    'refresh': Symbols.refresh,
    'sync': Symbols.sync,
    'info': Symbols.info,
    'warning': Symbols.warning,
    'error': Symbols.error,
    'help': Symbols.help,
    'question_mark': Symbols.question_mark,

    // Navigation
    'arrow_back': Symbols.arrow_back,
    'arrow_forward': Symbols.arrow_forward,
    'arrow_upward': Symbols.arrow_upward,
    'arrow_downward': Symbols.arrow_downward,
    'chevron_left': Symbols.chevron_left,
    'chevron_right': Symbols.chevron_right,
    'expand_more': Symbols.expand_more,
    'expand_less': Symbols.expand_less,
    'open_in_new': Symbols.open_in_new,
    'open_in_new_rounded': Symbols.open_in_new_rounded,
    'link': Symbols.link,
    'share': Symbols.share,

    // Social / content
    'person': Symbols.person,
    'group': Symbols.group,
    'groups': Symbols.groups,
    'account_circle': Symbols.account_circle,
    'chat': Symbols.chat,
    'chat_bubble': Symbols.chat_bubble,
    'forum': Symbols.forum,
    'mail': Symbols.mail,
    'notifications': Symbols.notifications,
    'notifications_rounded': Symbols.notifications_rounded,
    'article': Symbols.article,
    'post_add': Symbols.post_add,
    'edit_note': Symbols.edit_note,
    'description': Symbols.description,
    'image': Symbols.image,
    'photo': Symbols.photo,
    'videocam': Symbols.videocam,
    'mic': Symbols.mic,
    'mic_off': Symbols.mic_off,
    'volume_up': Symbols.volume_up,
    'attach_file': Symbols.attach_file,
    'attachment': Symbols.attachment,
    'folder': Symbols.folder,
    'folder_open': Symbols.folder_open,
    'cloud': Symbols.cloud,
    'cloud_upload': Symbols.cloud_upload,
    'cloud_download': Symbols.cloud_download,
    'download': Symbols.download,
    'upload': Symbols.upload,
    'favorite': Symbols.favorite,
    'favorite_border': Symbols.favorite_border,
    'star': Symbols.star,
    'star_border': Symbols.star_border,
    'thumb_up': Symbols.thumb_up,
    'thumb_down': Symbols.thumb_down,
    'bookmark': Symbols.bookmark,
    'tag': Symbols.tag,
    'tag_rounded': Symbols.tag_rounded,
    'tag_sharp': Symbols.tag_sharp,
    'label': Symbols.label,
    'public': Symbols.public,
    'lock': Symbols.lock,
    'lock_open': Symbols.lock_open,
    'visibility': Symbols.visibility,
    'visibility_off': Symbols.visibility_off,

    // Status / media
    'play_arrow': Symbols.play_arrow,
    'pause': Symbols.pause,
    'stop': Symbols.stop,
    'schedule': Symbols.schedule,
    'calendar_today': Symbols.calendar_today,
    'event': Symbols.event,
    'alarm': Symbols.alarm,
    'bolt': Symbols.bolt,
    'lightbulb': Symbols.lightbulb,
    'show_chart': Symbols.show_chart,
    'bar_chart': Symbols.bar_chart,
    'insights': Symbols.insights,
    'bug_report': Symbols.bug_report,
    'terminal': Symbols.terminal,
    'code': Symbols.code,
    'build': Symbols.build,
    'palette': Symbols.palette,
    'brush': Symbols.brush,
    'auto_awesome': Symbols.auto_awesome,
    'celebration': Symbols.celebration,
    'emoji_emotions': Symbols.emoji_emotions,
    'sports_esports': Symbols.sports_esports,
    'music_note': Symbols.music_note,
    'fitness_center': Symbols.fitness_center,
    'location_on': Symbols.location_on,
    'map': Symbols.map,
    'language': Symbols.language,
    'translate': Symbols.translate,
    'dark_mode': Symbols.dark_mode,
    'light_mode': Symbols.light_mode,
    'contrast': Symbols.contrast,
    'filter_list': Symbols.filter_list,
    'sort': Symbols.sort,
    'content_copy': Symbols.content_copy,
    'content_paste': Symbols.content_paste,
    'undo': Symbols.undo,
    'redo': Symbols.redo,
    'save': Symbols.save,
    'print': Symbols.print,
    'qr_code': Symbols.qr_code,
    'qr_code_2': Symbols.qr_code_2,
    'smartphone': Symbols.smartphone,
    'computer': Symbols.computer,
    'wifi': Symbols.wifi,
    'bluetooth': Symbols.bluetooth,
    'battery_full': Symbols.battery_full,
    'payments': Symbols.payments,
    'account_balance_wallet': Symbols.account_balance_wallet,
    'shopping_cart': Symbols.shopping_cart,
    'store': Symbols.store,
    'work': Symbols.work,
    'school': Symbols.school,
    'science': Symbols.science,
    'rocket_launch': Symbols.rocket_launch,
    'verified': Symbols.verified,
    'shield': Symbols.shield,
    'security': Symbols.security,
    'key': Symbols.key,
    'password': Symbols.password,
    'login': Symbols.login,
    'logout': Symbols.logout,
    'person_add': Symbols.person_add,
    'block': Symbols.block,
    'report': Symbols.report,
    'flag': Symbols.flag,
    'push_pin': Symbols.push_pin,
    'keep': Symbols.keep,
    'history': Symbols.history,
    'update': Symbols.update,
    'pending': Symbols.pending,
    'hourglass_empty': Symbols.hourglass_empty,
    'done': Symbols.done,
    'done_all': Symbols.done_all,
    'circle': Symbols.circle,
    'radio_button_unchecked': Symbols.radio_button_unchecked,
    'check_box': Symbols.check_box,
    'check_box_outline_blank': Symbols.check_box_outline_blank,
    'toggle_on': Symbols.toggle_on,
    'toggle_off': Symbols.toggle_off,

    // Aliases matching older Material Icons names plugins may use
    'info_outline': Symbols.info,
    'warning_amber': Symbols.warning,
    'dashboard_outlined': Symbols.dashboard,
    'extension_outlined': Symbols.extension,
    'insert_drive_file': Symbols.draft,
    'insert_drive_file_outlined': Symbols.draft,
  };

  /// Whether [name] is in the curated const set (can be rendered as [IconData]).
  static bool exists(String? name, {String? style}) {
    if (name == null || name.trim().isEmpty) return false;
    final parsed = parseNameAndStyle(name, style: style);
    final key = _lookupKey(parsed.name, parsed.style);
    return _icons.containsKey(key) || _icons.containsKey(parsed.name);
  }

  /// Resolve [name] to a **const** [IconData]. Unknown → [orElse] or [fallback].
  static IconData resolve(
    String? name, {
    String? style,
    IconData? orElse,
  }) {
    if (name == null || name.trim().isEmpty) {
      return orElse ?? fallback;
    }
    final parsed = parseNameAndStyle(name, style: style);
    final key = _lookupKey(parsed.name, parsed.style);
    return _icons[key] ?? _icons[parsed.name] ?? orElse ?? fallback;
  }

  /// Metadata for a curated name, or `null` if not in the const set.
  static Map<String, dynamic>? lookup(String? name, {String? style}) {
    if (name == null || name.trim().isEmpty) return null;
    final parsed = parseNameAndStyle(name, style: style);
    final key = _lookupKey(parsed.name, parsed.style);
    final icon = _icons[key] ?? _icons[parsed.name];
    if (icon == null) return null;
    return {
      'name': _icons.containsKey(key) ? key : parsed.name,
      'style': parsed.style ?? 'outlined',
      'codePoint': icon.codePoint,
      'fontFamily': icon.fontFamily,
      'found': true,
      'const': true,
    };
  }

  /// Search curated icon names containing [query].
  static List<String> search(String query, {int limit = 50}) {
    final q = normalize(query);
    if (q.isEmpty || limit <= 0) return const [];
    final matches = <String>[];
    for (final key in _icons.keys) {
      if (!key.contains(q)) continue;
      // Prefer base names in results (skip style variants when base exists).
      if (key.endsWith('_rounded') || key.endsWith('_sharp')) continue;
      matches.add(key);
      if (matches.length >= limit) break;
    }
    return matches;
  }

  static Iterable<String> get allNames => _icons.keys.where(
    (k) => !k.endsWith('_rounded') && !k.endsWith('_sharp'),
  );

  static int get count => _icons.length;
}
