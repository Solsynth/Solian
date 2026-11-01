/// The user's Solar Network mail, as tools.
///
/// Reads their mailboxes, a paged inbox, one email and the per-mailbox unread
/// tally; writes by sending mail from the user's own address and by changing
/// their inbox — read and star state, and the folder an email sits in.
///
/// The grant is the point of the plugin's shape: a private inbox is read and
/// mail is sent as the account holder, so the set is on demand — nothing is
/// offered until the user's switch grants it and the model loads it, and the
/// prompt text below only reaches the model then.
///
/// ## Pages and shapes
///
/// The listing endpoints count their pages in the `X-Total` header rather
/// than the payload, so `read_mail` reports a total a reader can trust.
/// `unread_mail` counts each mailbox with its own request, so the tally
/// belongs to that mailbox alone rather than to a shared page.
///
/// An email carries its sender as a nested `from` object or as flat
/// `from_address`/`from_name` fields, its recipients as a list tagged by
/// kind, and its attachments in two shapes too — every shape is read, and a
/// shape that is absent is an empty answer rather than a failure.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:island/thoughts/plugins/local_tool.dart';
import 'package:island/thoughts/plugins/plugin.dart';
import 'package:island/thoughts/plugins/solar_support.dart';

/// How much of a listing's subject the model is given.
const int _subjectChars = 200;

/// How much of a listing's body the model gets as a preview.
const int _previewChars = 300;

/// How much of one email's body the model is given.
const int _bodyChars = 8000;

/// The folders an email can be moved to, as the service spells them.
const Set<String> _folders = {'inbox', 'sent', 'drafts', 'spam', 'trash', 'archive'};

/// The mark actions the service accepts, each also the URL it is POSTed to.
const Set<String> _markActions = {'read', 'unread', 'star', 'unstar'};

class MailPlugin extends SnPlugin {
  const MailPlugin();

  @override
  String get id => 'mail';

  @override
  String get label => 'thoughtsSkillMailLabel'.tr();

  @override
  String get description => 'thoughtsSkillMailDescription'.tr();

  @override
  String get summary => 'Read the user\'s email inbox and send mail as them';

  @override
  bool get onDemand => true;

  @override
  bool get enabledByDefault => false;

  /// Nothing here replaces a server tool: the server offers no mail tools to
  /// take over, so claiming one would remove a capability rather than move it.
  @override
  Map<String, String> get overrides => const {};

  @override
  List<SnLocalTool> buildTools(SnPluginContext context) {
    final dio = context.api;
    return [
      SnLocalTool(
        name: 'read_mailbox',
        description:
            'The user\'s email mailboxes: the addresses their mail can be '
            'read from and sent from, and which one is the default. Use it to '
            'find the mailbox the user means before reading or sending.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final body = await solarGet(dio, '/postal/mailboxes');
          return {
            // Always present: an account with no mailbox is an answer, an
            // omitted key would read as unknown.
            'mailboxes': [
              for (final mailbox in solarPage(body)) _mailbox(mailbox),
            ],
          };
        }),
      ),
      SnLocalTool(
        name: 'read_mail',
        description:
            'A page of the user\'s email, newest first, with the total count '
            'for the filters given. Filter by mailbox, folder, text, sender, '
            'recipient or flags; leave the filters out to read the whole '
            'inbox. Each row carries a short preview, not the full body — '
            'read one email for that.',
        parameters: {
          'type': 'object',
          'properties': {
            'mailbox_id': {
              'type': 'string',
              'description': 'The mailbox id, from read_mailbox.',
            },
            'folder': {
              'type': 'string',
              'description': 'inbox, sent, drafts, spam, trash or archive.',
            },
            'q': {'type': 'string', 'description': 'A text search.'},
            'is_read': {
              'type': 'boolean',
              'description': 'True for read mail only, false for unread.',
            },
            'is_starred': {
              'type': 'boolean',
              'description': 'True for starred mail only.',
            },
            'has_attachments': {
              'type': 'boolean',
              'description': 'True for mail with attachments only.',
            },
            'from': {
              'type': 'string',
              'description': 'An address the sender matches.',
            },
            'to': {
              'type': 'string',
              'description': 'An address a recipient matches.',
            },
            'offset': {
              'type': 'integer',
              'description': 'Where to start the page (default 0).',
            },
            'take': {
              'type': 'integer',
              'description': 'How many to return (1-30, default 10).',
            },
          },
        },
        execute: (arguments) => solarToolResult(() async {
          final response = await solarGetResponse(
            dio,
            '/postal/emails',
            query: {
              'offset': solarInt(arguments, 'offset') ?? 0,
              'take': solarTake(arguments),
              'mailbox_id': solarText(arguments, 'mailbox_id'),
              'folder': solarText(arguments, 'folder'),
              'q': solarText(arguments, 'q'),
              'is_read': arguments['is_read'] is bool
                  ? arguments['is_read']
                  : null,
              'is_starred': arguments['is_starred'] is bool
                  ? arguments['is_starred']
                  : null,
              'has_attachments': arguments['has_attachments'] is bool
                  ? arguments['has_attachments']
                  : null,
              'from': solarText(arguments, 'from'),
              'to': solarText(arguments, 'to'),
            },
          );
          final page = solarPage(response.data);
          final total = solarTotal(response);
          return {
            // The service counts its pages in the header; without it the page
            // length is what the answer actually holds.
            'total': total != 0 ? total : page.length,
            'emails': [for (final email in page) _emailSummary(email)],
          };
        }),
      ),
      SnLocalTool(
        name: 'read_email',
        description:
            'One email in full: its sender, recipients, attachments, flags '
            'and body. Takes an email id from read_mail.',
        parameters: {
          'type': 'object',
          'properties': {
            'email_id': {
              'type': 'string',
              'description': 'The email id, from read_mail.',
            },
          },
          'required': ['email_id'],
        },
        execute: (arguments) => solarToolResult(() async {
          final emailId = solarText(arguments, 'email_id');
          if (emailId == null) return solarMissing('email_id');
          final email = await solarGet(
            dio,
            '/postal/emails/${Uri.encodeComponent(emailId)}',
          );
          return _email(email);
        }),
      ),
      SnLocalTool(
        name: 'unread_mail',
        description:
            'How many unread emails sit in the inbox of each of the user\'s '
            'mailboxes — the cheapest answer to "any new mail?", without '
            'reading any of it.',
        parameters: {'type': 'object', 'properties': <String, dynamic>{}},
        execute: (arguments) => solarToolResult(() async {
          final body = await solarGet(dio, '/postal/mailboxes');
          final mailboxes = <Map<String, dynamic>>[];
          for (final mailbox in solarPage(body)) {
            final id = solarString(mailbox, 'id');
            if (id == null) continue;
            // One request per mailbox, each counted by its own page's
            // X-Total header, so the tally belongs to that mailbox alone.
            final response = await solarGetResponse(
              dio,
              '/postal/emails?mailbox_id=${Uri.encodeQueryComponent(id)}'
              '&folder=inbox&is_read=false&take=1',
            );
            mailboxes.add(
              solarCompact({
                'mailbox_id': id,
                'address': solarString(mailbox, 'address'),
                // Zero is the answer for a quiet inbox; it is kept on purpose.
                'unread': solarTotal(response),
              }),
            );
          }
          return {'mailboxes': mailboxes};
        }),
      ),
      SnLocalTool(
        name: 'send_email',
        description:
            'Sends an email from the user\'s own mailbox address. It goes '
            'out immediately from their account and cannot be unsent, so send '
            'only what the user asked you to send.',
        parameters: {
          'type': 'object',
          'properties': {
            'mailbox_id': {
              'type': 'string',
              'description': 'The mailbox to send from, from read_mailbox.',
            },
            'to': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'The recipient email addresses.',
            },
            'cc': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'Carbon-copy addresses.',
            },
            'bcc': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'Blind carbon-copy addresses.',
            },
            'subject': {
              'type': 'string',
              'description': 'The subject line.',
            },
            'body': {
              'type': 'string',
              'description': 'The message body, in the user\'s own words.',
            },
            'content_type': {
              'type': 'string',
              'description': 'text/plain (default) or text/html.',
            },
            'reply_to_id': {
              'type': 'string',
              'description': 'The email id this replies to, from read_mail.',
            },
          },
          'required': ['mailbox_id', 'to', 'body'],
        },
        execute: (arguments) => solarToolResult(() async {
          final mailboxId = solarText(arguments, 'mailbox_id');
          final body = solarText(arguments, 'body');
          final to = arguments['to'];
          if (mailboxId == null) return solarMissing('mailbox_id');
          // Checked before the request: a send that cannot be addressed is a
          // call the model can fix, not a mail to put in the outbox.
          if (to is! List || to.isEmpty) {
            return {
              'error': 'The "to" argument needs at least one email address.',
            };
          }
          final toAddresses = <String>[];
          for (final entry in to) {
            final address = '$entry'.trim();
            if (address.isEmpty || !address.contains('@')) {
              return {
                'error':
                    'The "to" argument holds an address that is not an email: '
                    '"$address".',
              };
            }
            toAddresses.add(address);
          }
          if (body == null) return solarMissing('body');
          final replyToId = solarText(arguments, 'reply_to_id');
          final sent = await solarPost(
            dio,
            '/postal/emails',
            body: {
              'mailbox_id': mailboxId,
              'to': [
                for (final address in toAddresses)
                  {'address': address, 'kind': 'to'},
              ],
              'cc': _addresses(arguments['cc'], 'cc'),
              'bcc': _addresses(arguments['bcc'], 'bcc'),
              'subject': solarText(arguments, 'subject') ?? '',
              'body': body,
              'content_type': solarText(arguments, 'content_type') ?? 'text/plain',
              'reply_to_id': ?replyToId,
            },
          );
          return {'sent': _sent(sent)};
        }),
      ),
      SnLocalTool(
        name: 'mark_mail',
        description:
            'Marks one email read or unread, or stars or unstars it. Changes '
            'the user\'s inbox, so do it when the user asked for it rather '
            'than as a tidy-up after reading.',
        parameters: {
          'type': 'object',
          'properties': {
            'email_id': {
              'type': 'string',
              'description': 'The email id, from read_mail.',
            },
            'action': {
              'type': 'string',
              'description': 'read, unread, star or unstar.',
            },
          },
          'required': ['email_id', 'action'],
        },
        execute: (arguments) => solarToolResult(() async {
          final emailId = solarText(arguments, 'email_id');
          if (emailId == null) return solarMissing('email_id');
          final action = solarText(arguments, 'action');
          if (action == null) return solarMissing('action');
          if (!_markActions.contains(action)) {
            return {
              'error':
                  'The "action" argument must be read, unread, star or '
                  'unstar.',
            };
          }
          await solarPost(
            dio,
            '/postal/emails/${Uri.encodeComponent(emailId)}/$action',
          );
          return {'ok': true, 'email_id': emailId, 'action': action};
        }),
      ),
      SnLocalTool(
        name: 'move_mail',
        description:
            'Moves one email to another folder: inbox, sent, drafts, spam, '
            'trash or archive. Trash is recoverable, but the move still '
            'changes the user\'s inbox, so do it when the user asked.',
        parameters: {
          'type': 'object',
          'properties': {
            'email_id': {
              'type': 'string',
              'description': 'The email id, from read_mail.',
            },
            'folder': {
              'type': 'string',
              'description': 'inbox, sent, drafts, spam, trash or archive.',
            },
          },
          'required': ['email_id', 'folder'],
        },
        execute: (arguments) => solarToolResult(() async {
          final emailId = solarText(arguments, 'email_id');
          if (emailId == null) return solarMissing('email_id');
          final folder = solarText(arguments, 'folder');
          if (folder == null) return solarMissing('folder');
          if (!_folders.contains(folder)) {
            return {
              'error':
                  'The "folder" argument must be inbox, sent, drafts, spam, '
                  'trash or archive.',
            };
          }
          await solarPost(
            dio,
            '/postal/emails/${Uri.encodeComponent(emailId)}/move',
            body: {'folder': folder},
          );
          return {'ok': true, 'email_id': emailId, 'folder': folder};
        }),
      ),
    ];
  }

  @override
  List<String> systemPrompt(SnPluginContext context) => const [
    'The user\'s email tools are loaded: local_read_mailbox, local_read_mail, '
    'local_read_email, local_unread_mail, local_send_email, local_mark_mail '
    'and local_move_mail. They read the user\'s private inbox on their own '
    'connection — a grant the user made by switching the plugin on.',
    'local_send_email sends as the user from their own mailbox address and '
    'cannot be unsent, so call it only when the user has asked you to send.',
    'local_mark_mail and local_move_mail change the user\'s inbox. Trash is '
    'recoverable, but the change is still real, so do it when asked, not as a '
    'tidy-up after reading.',
    'Mailbox and email ids come from the read tools — never invent one.',
  ];
}

/// One mailbox as the model reads it.
///
/// A mailbox carries its account, its workspace and its verification state;
/// what a reader needs is the address to send from, whether it is the default
/// and which workspace it belongs to. A `false` flag is left out the same way
/// a missing one is: the mailbox that is default or verified says so, the
/// rest do not need to.
Map<String, dynamic> _mailbox(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'address': solarString(json, 'address'),
  'name': solarString(json, 'name'),
  'is_default': solarField(json, 'is_default') == true ? true : null,
  'is_verified': solarField(json, 'is_verified') == true ? true : null,
  'workspace_id': solarString(json, 'workspace_id'),
});

/// The sender's address, from whichever shape the email carries it in.
String? _fromAddress(Object? json) =>
    solarString(solarMap(json, 'from'), 'address') ??
    solarString(json, 'from_address');

/// The sender's name, from whichever shape the email carries it in.
String? _fromName(Object? json) =>
    solarString(solarMap(json, 'from'), 'name') ?? solarString(json, 'from_name');

/// One email as a listing row: enough to pick one out, not enough to answer.
Map<String, dynamic> _emailSummary(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'mailbox_id': solarString(json, 'mailbox_id'),
  'subject': solarClip(solarString(json, 'subject'), limit: _subjectChars),
  'from_address': _fromAddress(json),
  'from_name': _fromName(json),
  'preview': solarClip(solarString(json, 'body'), limit: _previewChars),
  'is_read': solarField(json, 'is_read') == true ? true : null,
  'is_starred': solarField(json, 'is_starred') == true ? true : null,
  'has_attachments': solarList(json, 'attachments').isNotEmpty ? true : null,
  'folder': solarString(json, 'folder'),
  'created_at': solarTimeField(json, 'created_at'),
});

/// One email in full, as the model reads it.
///
/// The addressee lists and the attachments answer "who was this to?" and "did
/// it carry anything?", so an empty one is kept as the answer rather than
/// compacted away as if it had never been sent.
Map<String, dynamic> _email(Object? json) => {
  ...solarCompact({
    'id': solarString(json, 'id'),
    'mailbox_id': solarString(json, 'mailbox_id'),
    'subject': solarString(json, 'subject'),
    'body': solarClip(solarString(json, 'body'), limit: _bodyChars),
    'content_type': solarString(json, 'content_type'),
    'from_address': _fromAddress(json),
    'from_name': _fromName(json),
    'is_read': solarField(json, 'is_read') == true ? true : null,
    'is_starred': solarField(json, 'is_starred') == true ? true : null,
    'folder': solarString(json, 'folder'),
    'created_at': solarTimeField(json, 'created_at'),
    'delivery_status': solarString(json, 'delivery_status'),
    'delivery_error': solarString(json, 'delivery_error'),
  }),
  'to': _recipients(json, 'to'),
  'cc': _recipients(json, 'cc'),
  'attachments': _attachments(json),
};

/// The recipients of one kind — to or cc — from the tagged list.
///
/// The wire tags every recipient with its kind; only the two the answer names
/// are projected, and a missing list is an empty one rather than a failure.
List<Map<String, dynamic>> _recipients(Object? json, String kind) => [
  for (final recipient in solarList(json, 'recipients'))
    if (solarString(recipient, 'kind') == kind)
      solarCompact({
        'address': solarString(recipient, 'address'),
        'name': solarString(recipient, 'name'),
      }),
];

/// One email's attachments, in either shape the wire sends them.
///
/// Some attachments carry their file nested under `file` with the content id
/// beside it, some are flat; both read the same, and a field either shape
/// omits is a missing value rather than a failure.
List<Map<String, dynamic>> _attachments(Object? json) {
  final attachments = <Map<String, dynamic>>[];
  for (final attachment in solarList(json, 'attachments')) {
    final file = solarMap(attachment, 'file');
    attachments.add(
      solarCompact({
        'id':
            solarString(file, 'id') ??
            solarString(file, 'file_id') ??
            solarString(attachment, 'id'),
        'name':
            solarString(file, 'name') ??
            solarString(attachment, 'name') ??
            solarString(attachment, 'filename'),
        'mime_type':
            solarString(file, 'mime_type') ??
            solarString(attachment, 'mime_type'),
        'size': solarInt(file, 'size') ?? solarInt(attachment, 'size'),
      }),
    );
  }
  return attachments;
}

/// The created email, as the model reads it.
Map<String, dynamic> _sent(Object? json) => solarCompact({
  'id': solarString(json, 'id'),
  'subject': solarString(json, 'subject'),
  'delivery_status': solarString(json, 'delivery_status'),
  'folder': solarString(json, 'folder'),
});

/// A bare address list as the send body wants it: one entry per address.
///
/// The tool takes addresses as plain strings — no names — and the wire wants
/// each tagged with the kind it plays in the message.
List<Map<String, String>> _addresses(Object? given, String kind) {
  if (given is! List) return const [];
  return [
    for (final entry in given) {'address': '$entry'.trim(), 'kind': kind},
  ];
}
