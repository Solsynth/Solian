/// The user's Solar Network social account, as tools.
///
/// Reads the timeline, a single thread, a profile, and a search; writes posts,
/// replies and reactions. This is the plugin the rest of the Solar-backed set
/// is written against: one `solarToolResult` call per body, one projection
/// helper per shape, and a prompt fragment that says what the tools are for
/// rather than repeating what each description already says.
///
/// Reads and writes live in one plugin because they are one grant. The user
/// switching this on is saying "act as me on Solar Network"; splitting
/// publishing into a second switch would suggest the first one is harmless.
///
/// On demand: eight definitions cost context on every request, and the
/// companion reaches for the timeline in bursts, not constantly. The prompt
/// fragment below is only sent once the model has loaded the set.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

/// How many characters of a post body the model is given.
///
/// Enough for a short post in full — the common case — and a clipped opening
/// plus a marker for a long-form one.
const int _postChars = 600;

/// The most a `reaction` argument may be, counted in runes: one emoji, plus
/// room for a variation selector or a short zero-width-joiner sequence.
const int _maxReactionRunes = 8;

/// The attitude the server files a reaction under.
///
/// It tracks a reaction by whether it is praise, and the app only ever offers
/// the emoji — a reader takes a reaction at face value rather than as a vote,
/// so one that arrives without an attitude is filed as positive.
const int _positiveAttitude = 0;

class SocialPlugin extends SnPlugin {
  const SocialPlugin();

  @override
  String get id => 'social';

  @override
  String get label => 'thoughtsSkillSocialLabel'.tr();

  @override
  String get description => 'thoughtsSkillSocialDescription'.tr();

  @override
  String get summary =>
      'Read the timeline and threads, and post, reply or react as the user';

  @override
  bool get onDemand => true;

  /// The server offers the same posts under its own names — the feed as
  /// `list_feed`, a thread as `get_post` plus `list_post_replies`, publishing
  /// as `create_post`. Reading a post here already returns its replies, so one
  /// local tool answers both of the server's read tools.
  ///
  /// Not claimed: `repost_post` and `list_my_posts`, which no tool here does.
  /// Overriding those would take the capability away rather than move it.
  @override
  Map<String, String> get overrides => const {
    'list_feed': 'read_timeline',
    'get_post': 'read_post',
    'get_post_replies': 'read_post',
    'list_post_replies': 'read_post',
    'list_user_posts': 'read_profile',
    'search_posts': 'search_posts',
    'create_post': 'create_post',
    'reply_to_post': 'reply_to_post',
    'react_to_post': 'react_to_post',
  };

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'read_timeline',
        description:
            'The user\'s Solar Network home timeline: the most recent posts '
            'from the publishers they follow, newest first. Use it to answer '
            'what is happening, or to find a post to reply to.',
        parameters: {
          'type': 'object',
          'properties': {
            'take': {
              'type': 'integer',
              'description': 'How many posts to return (1-30, default 10).',
            },
          },
        },
        execute: (arguments) => solarToolResult(() async {
          final page = await solarGet(
            dio,
            '/sphere/timeline',
            query: {'offset': 0, 'take': solarTake(arguments)},
          );
          return {
            'posts': [for (final post in solarPage(page)) _post(post)],
          };
        }),
      ),
      SnLocalTool(
        name: 'read_post',
        description:
            'One Solar Network post and its replies: the full conversation '
            'around a post id. Returns the post itself and its replies, '
            'newest first.',
        parameters: {
          'type': 'object',
          'properties': {
            'post_id': {
              'type': 'string',
              'description': 'The post id, as returned by another tool.',
            },
            'take': {
              'type': 'integer',
              'description': 'How many replies to return (1-30, default 10).',
            },
          },
          'required': ['post_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final postId = solarText(arguments, 'post_id');
          if (postId == null) return solarMissing('post_id');
          final post = await solarGet(dio, '/sphere/posts/$postId');
          if (post == null) return {'error': 'There is no post $postId.'};
          final replies = await solarGet(
            dio,
            '/sphere/posts/$postId/replies',
            query: {'offset': 0, 'take': solarTake(arguments)},
          );
          return {
            'post': _post(post),
            'replies': [for (final reply in solarPage(replies)) _post(reply)],
          };
        }),
      ),
      SnLocalTool(
        name: 'search_posts',
        description:
            'Searches Solar Network for posts matching a query, newest first. '
            'Use it to find what people have said about a topic rather than to '
            'search the open web.',
        parameters: {
          'type': 'object',
          'properties': {
            'query': {
              'type': 'string',
              'description': 'What to search for.',
            },
            'take': {
              'type': 'integer',
              'description': 'How many posts to return (1-30, default 10).',
            },
          },
          'required': ['query'],
        },
        execute: (arguments) => solarToolResult(() async {
          final query = solarText(arguments, 'query');
          if (query == null) return solarMissing('query');
          final page = await solarGet(
            dio,
            '/sphere/posts',
            // The parameter is `query`: `q` belongs to the search service the
            // SDK assumed, which this endpoint is not.
            query: {'query': query, 'offset': 0, 'take': solarTake(arguments)},
          );
          return {
            'posts': [for (final post in solarPage(page)) _post(post)],
          };
        }),
      ),
      SnLocalTool(
        name: 'read_profile',
        description:
            'A Solar Network publisher\'s profile and their most recent posts. '
            'Takes the username as it appears in a profile URL, without the '
            'leading @.',
        parameters: {
          'type': 'object',
          'properties': {
            'username': {
              'type': 'string',
              'description': 'The publisher username, e.g. "littleSheep".',
            },
            'take': {
              'type': 'integer',
              'description': 'How many posts to return (1-30, default 10).',
            },
          },
          'required': ['username'],
        },
        execute: (arguments) => solarToolResult(() async {
          final username = solarText(arguments, 'username');
          if (username == null) return solarMissing('username');
          final encoded = Uri.encodeComponent(username);
          final publisher = await solarGet(dio, '/sphere/publishers/$encoded');
          if (publisher == null) {
            return {'error': 'There is no publisher "$username".'};
          }
          // A publisher's posts are the post listing filtered, not a route of
          // their own: `/publishers/{name}/posts` does not exist.
          final posts = await solarGet(
            dio,
            '/sphere/posts',
            query: {'pub': username, 'offset': 0, 'take': solarTake(arguments)},
          );
          return {
            'publisher': solarCompact({
              'username': solarString(publisher, 'name'),
              'display_name': solarString(publisher, 'nick'),
              'bio': solarClip(solarString(publisher, 'bio'), limit: 300),
              'rating': solarNumber(publisher, 'rating'),
            }),
            'posts': [for (final post in solarPage(posts)) _post(post)],
          };
        }),
      ),
      SnLocalTool(
        name: 'create_post',
        description:
            'Publishes a post on Solar Network as the user. The content is '
            'public and attributed to them, so post only text the user has '
            'given you for this purpose — never invent one, and never write a '
            'post from a summary of your own. Returns the created post.',
        parameters: {
          'type': 'object',
          'properties': {
            'content': {
              'type': 'string',
              'description':
                  'The post body, in the user\'s own words. Markdown is '
                  'supported.',
            },
          },
          'required': ['content'],
        },
        execute: (arguments) => solarToolResult(() async {
          final content = solarText(arguments, 'content');
          if (content == null) return solarMissing('content');
          return _post(
            await solarPost(dio, '/sphere/posts', body: {'content': content}),
          );
        }),
      ),
      SnLocalTool(
        name: 'reply_to_post',
        description:
            'Replies to an existing Solar Network post as the user. The reply '
            'is public, so use the user\'s own words rather than inventing a '
            'response. Returns the created reply.',
        parameters: {
          'type': 'object',
          'properties': {
            'post_id': {
              'type': 'string',
              'description': 'The id of the post being replied to.',
            },
            'content': {
              'type': 'string',
              'description': 'The reply body, in the user\'s own words.',
            },
          },
          'required': ['post_id', 'content'],
        },
        execute: (arguments) => solarToolResult(() async {
          final postId = solarText(arguments, 'post_id');
          final content = solarText(arguments, 'content');
          if (postId == null) return solarMissing('post_id');
          if (content == null) return solarMissing('content');
          // A reply is a post that names its parent: `POST /posts/{id}/replies`
          // is a read route and answers 405 to a write.
          return _post(
            await solarPost(
              dio,
              '/sphere/posts',
              body: {'content': content, 'replied_post_id': postId},
            ),
          );
        }),
      ),
      SnLocalTool(
        name: 'react_to_post',
        description:
            'Adds one emoji reaction to a Solar Network post as the user. '
            'Adding a reaction replaces the user\'s previous one on that post.',
        parameters: {
          'type': 'object',
          'properties': {
            'post_id': {
              'type': 'string',
              'description': 'The id of the post to react to.',
            },
            'reaction': {
              'type': 'string',
              'description': 'A single emoji, e.g. "👍" or "🎉".',
            },
          },
          'required': ['post_id', 'reaction'],
        },
        execute: (arguments) => solarToolResult(() async {
          final postId = solarText(arguments, 'post_id');
          final reaction = solarText(arguments, 'reaction');
          if (postId == null) return solarMissing('post_id');
          if (reaction == null) return solarMissing('reaction');
          if (reaction.runes.length > _maxReactionRunes) {
            return {'error': 'A reaction is one emoji, not "$reaction".'};
          }
          await solarPost(
            dio,
            '/sphere/posts/$postId/reactions',
            body: {'symbol': reaction, 'attitude': _positiveAttitude},
          );
          return {'ok': true, 'post_id': postId, 'reaction': reaction};
        }),
      ),
    ];
  }

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'The user\'s Solar Network social tools are loaded: local_read_timeline, '
    'local_read_post, local_search_posts, local_read_profile, '
    'local_create_post, local_reply_to_post and local_react_to_post. They run '
    'as the signed-in user on their own connection.',
    'Posting, replying and reacting are visible to other people and attributed '
    'to the user by name. Offer to do them; do them when asked. Never invent '
    'the text of a post or a reply — write only what the user said, and ask for '
    'the wording when they have not given it.',
  ];
}

/// One post projected to the fields that carry meaning.
///
/// A post embeds its author, its own parent, its forwarded original and its
/// collections; serializing it whole would spend the context window on one
/// item, so only what a reader needs is kept — and a field the wire stops
/// sending is a missing value here, not a failure.
Map<String, dynamic> _post(Object? json) {
  final publisher = solarMap(json, 'publisher');
  return solarCompact({
    'id': solarString(json, 'id'),
    'author':
        solarString(publisher, 'nick') ?? solarString(publisher, 'name'),
    'username': solarString(publisher, 'name'),
    'posted_at':
        solarTimeField(json, 'published_at') ??
        solarTimeField(json, 'created_at'),
    'content': solarClip(solarString(json, 'content'), limit: _postChars),
    'replies': solarInt(json, 'replies_count'),
    'reactions': solarMap(json, 'reactions_count'),
    'tags': _tags(json),
    'replied_to': solarString(json, 'replied_post_id'),
  });
}

/// A post's tags, however this service spells them.
///
/// The listing has carried them as objects with a slug and as bare strings;
/// a reader wants the names either way.
List<String> _tags(Object? json) => [
  for (final tag in solarList(json, 'tags'))
    ?(tag is Map
        ? solarString(tag, 'slug') ?? solarString(tag, 'name')
        : solarString({'tag': tag}, 'tag')),
];
