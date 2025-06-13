// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i27;
import 'package:flutter/foundation.dart' as _i29;
import 'package:flutter/material.dart' as _i28;
import 'package:island/models/post.dart' as _i30;
import 'package:island/route.dart' as _i31;
import 'package:island/screens/account.dart' as _i2;
import 'package:island/screens/account/event_calendar.dart' as _i14;
import 'package:island/screens/account/me/settings.dart' as _i3;
import 'package:island/screens/account/me/update.dart' as _i25;
import 'package:island/screens/account/profile.dart' as _i1;
import 'package:island/screens/account/relationship.dart' as _i22;
import 'package:island/screens/auth/create_account.dart' as _i8;
import 'package:island/screens/auth/login.dart' as _i16;
import 'package:island/screens/auth/tabs.dart' as _i24;
import 'package:island/screens/chat/call.dart' as _i4;
import 'package:island/screens/chat/chat.dart' as _i6;
import 'package:island/screens/chat/room.dart' as _i7;
import 'package:island/screens/chat/room_detail.dart' as _i5;
import 'package:island/screens/creators/hub.dart' as _i9;
import 'package:island/screens/creators/publishers.dart' as _i10;
import 'package:island/screens/creators/stickers/pack_detail.dart' as _i13;
import 'package:island/screens/creators/stickers/stickers.dart' as _i12;
import 'package:island/screens/explore.dart' as _i15;
import 'package:island/screens/notification.dart' as _i17;
import 'package:island/screens/posts/compose.dart' as _i18;
import 'package:island/screens/posts/detail.dart' as _i19;
import 'package:island/screens/posts/pub_profile.dart' as _i20;
import 'package:island/screens/realm/detail.dart' as _i21;
import 'package:island/screens/realm/realms.dart' as _i11;
import 'package:island/screens/settings.dart' as _i23;
import 'package:island/screens/wallet.dart' as _i26;

/// generated route for
/// [_i1.AccountProfileScreen]
class AccountProfileRoute extends _i27.PageRouteInfo<AccountProfileRouteArgs> {
  AccountProfileRoute({
    _i28.Key? key,
    required String name,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         AccountProfileRoute.name,
         args: AccountProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'AccountProfileRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AccountProfileRouteArgs>(
        orElse:
            () => AccountProfileRouteArgs(name: pathParams.getString('name')),
      );
      return _i1.AccountProfileScreen(key: args.key, name: args.name);
    },
  );
}

class AccountProfileRouteArgs {
  const AccountProfileRouteArgs({this.key, required this.name});

  final _i28.Key? key;

  final String name;

  @override
  String toString() {
    return 'AccountProfileRouteArgs{key: $key, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AccountProfileRouteArgs) return false;
    return key == other.key && name == other.name;
  }

  @override
  int get hashCode => key.hashCode ^ name.hashCode;
}

/// generated route for
/// [_i2.AccountScreen]
class AccountRoute extends _i27.PageRouteInfo<AccountRouteArgs> {
  AccountRoute({
    _i29.Key? key,
    bool isAside = false,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         AccountRoute.name,
         args: AccountRouteArgs(key: key, isAside: isAside),
         initialChildren: children,
       );

  static const String name = 'AccountRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AccountRouteArgs>(
        orElse: () => const AccountRouteArgs(),
      );
      return _i2.AccountScreen(key: args.key, isAside: args.isAside);
    },
  );
}

class AccountRouteArgs {
  const AccountRouteArgs({this.key, this.isAside = false});

  final _i29.Key? key;

  final bool isAside;

  @override
  String toString() {
    return 'AccountRouteArgs{key: $key, isAside: $isAside}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AccountRouteArgs) return false;
    return key == other.key && isAside == other.isAside;
  }

  @override
  int get hashCode => key.hashCode ^ isAside.hashCode;
}

/// generated route for
/// [_i3.AccountSettingsScreen]
class AccountSettingsRoute extends _i27.PageRouteInfo<void> {
  const AccountSettingsRoute({List<_i27.PageRouteInfo>? children})
    : super(AccountSettingsRoute.name, initialChildren: children);

  static const String name = 'AccountSettingsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i3.AccountSettingsScreen();
    },
  );
}

/// generated route for
/// [_i2.AccountShellScreen]
class AccountShellRoute extends _i27.PageRouteInfo<void> {
  const AccountShellRoute({List<_i27.PageRouteInfo>? children})
    : super(AccountShellRoute.name, initialChildren: children);

  static const String name = 'AccountShellRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountShellScreen();
    },
  );
}

/// generated route for
/// [_i4.CallScreen]
class CallRoute extends _i27.PageRouteInfo<CallRouteArgs> {
  CallRoute({
    _i28.Key? key,
    required String roomId,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         CallRoute.name,
         args: CallRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'CallRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CallRouteArgs>(
        orElse: () => CallRouteArgs(roomId: pathParams.getString('id')),
      );
      return _i4.CallScreen(key: args.key, roomId: args.roomId);
    },
  );
}

class CallRouteArgs {
  const CallRouteArgs({this.key, required this.roomId});

  final _i28.Key? key;

  final String roomId;

  @override
  String toString() {
    return 'CallRouteArgs{key: $key, roomId: $roomId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CallRouteArgs) return false;
    return key == other.key && roomId == other.roomId;
  }

  @override
  int get hashCode => key.hashCode ^ roomId.hashCode;
}

/// generated route for
/// [_i5.ChatDetailScreen]
class ChatDetailRoute extends _i27.PageRouteInfo<ChatDetailRouteArgs> {
  ChatDetailRoute({
    _i28.Key? key,
    required String id,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         ChatDetailRoute.name,
         args: ChatDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatDetailRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatDetailRouteArgs>(
        orElse: () => ChatDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i5.ChatDetailScreen(key: args.key, id: args.id);
    },
  );
}

class ChatDetailRouteArgs {
  const ChatDetailRouteArgs({this.key, required this.id});

  final _i28.Key? key;

  final String id;

  @override
  String toString() {
    return 'ChatDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i6.ChatListScreen]
class ChatListRoute extends _i27.PageRouteInfo<ChatListRouteArgs> {
  ChatListRoute({
    _i28.Key? key,
    bool isAside = false,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         ChatListRoute.name,
         args: ChatListRouteArgs(key: key, isAside: isAside),
         initialChildren: children,
       );

  static const String name = 'ChatListRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ChatListRouteArgs>(
        orElse: () => const ChatListRouteArgs(),
      );
      return _i6.ChatListScreen(key: args.key, isAside: args.isAside);
    },
  );
}

class ChatListRouteArgs {
  const ChatListRouteArgs({this.key, this.isAside = false});

  final _i28.Key? key;

  final bool isAside;

  @override
  String toString() {
    return 'ChatListRouteArgs{key: $key, isAside: $isAside}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatListRouteArgs) return false;
    return key == other.key && isAside == other.isAside;
  }

  @override
  int get hashCode => key.hashCode ^ isAside.hashCode;
}

/// generated route for
/// [_i7.ChatRoomScreen]
class ChatRoomRoute extends _i27.PageRouteInfo<ChatRoomRouteArgs> {
  ChatRoomRoute({
    _i29.Key? key,
    required String id,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         ChatRoomRoute.name,
         args: ChatRoomRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'ChatRoomRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChatRoomRouteArgs>(
        orElse: () => ChatRoomRouteArgs(id: pathParams.getString('id')),
      );
      return _i7.ChatRoomScreen(key: args.key, id: args.id);
    },
  );
}

class ChatRoomRouteArgs {
  const ChatRoomRouteArgs({this.key, required this.id});

  final _i29.Key? key;

  final String id;

  @override
  String toString() {
    return 'ChatRoomRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatRoomRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i6.ChatShellScreen]
class ChatShellRoute extends _i27.PageRouteInfo<void> {
  const ChatShellRoute({List<_i27.PageRouteInfo>? children})
    : super(ChatShellRoute.name, initialChildren: children);

  static const String name = 'ChatShellRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i6.ChatShellScreen();
    },
  );
}

/// generated route for
/// [_i8.CreateAccountScreen]
class CreateAccountRoute extends _i27.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i27.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i8.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i9.CreatorHubScreen]
class CreatorHubRoute extends _i27.PageRouteInfo<CreatorHubRouteArgs> {
  CreatorHubRoute({
    _i28.Key? key,
    bool isAside = false,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         CreatorHubRoute.name,
         args: CreatorHubRouteArgs(key: key, isAside: isAside),
         initialChildren: children,
       );

  static const String name = 'CreatorHubRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreatorHubRouteArgs>(
        orElse: () => const CreatorHubRouteArgs(),
      );
      return _i9.CreatorHubScreen(key: args.key, isAside: args.isAside);
    },
  );
}

class CreatorHubRouteArgs {
  const CreatorHubRouteArgs({this.key, this.isAside = false});

  final _i28.Key? key;

  final bool isAside;

  @override
  String toString() {
    return 'CreatorHubRouteArgs{key: $key, isAside: $isAside}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreatorHubRouteArgs) return false;
    return key == other.key && isAside == other.isAside;
  }

  @override
  int get hashCode => key.hashCode ^ isAside.hashCode;
}

/// generated route for
/// [_i9.CreatorHubShellScreen]
class CreatorHubShellRoute extends _i27.PageRouteInfo<void> {
  const CreatorHubShellRoute({List<_i27.PageRouteInfo>? children})
    : super(CreatorHubShellRoute.name, initialChildren: children);

  static const String name = 'CreatorHubShellRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i9.CreatorHubShellScreen();
    },
  );
}

/// generated route for
/// [_i6.EditChatScreen]
class EditChatRoute extends _i27.PageRouteInfo<EditChatRouteArgs> {
  EditChatRoute({_i28.Key? key, String? id, List<_i27.PageRouteInfo>? children})
    : super(
        EditChatRoute.name,
        args: EditChatRouteArgs(key: key, id: id),
        rawPathParams: {'id': id},
        initialChildren: children,
      );

  static const String name = 'EditChatRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditChatRouteArgs>(
        orElse: () => EditChatRouteArgs(id: pathParams.optString('id')),
      );
      return _i6.EditChatScreen(key: args.key, id: args.id);
    },
  );
}

class EditChatRouteArgs {
  const EditChatRouteArgs({this.key, this.id});

  final _i28.Key? key;

  final String? id;

  @override
  String toString() {
    return 'EditChatRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditChatRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i10.EditPublisherScreen]
class EditPublisherRoute extends _i27.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i28.Key? key,
    String? name,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         rawPathParams: {'id': name},
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditPublisherRouteArgs>(
        orElse: () => EditPublisherRouteArgs(name: pathParams.optString('id')),
      );
      return _i10.EditPublisherScreen(key: args.key, name: args.name);
    },
  );
}

class EditPublisherRouteArgs {
  const EditPublisherRouteArgs({this.key, this.name});

  final _i28.Key? key;

  final String? name;

  @override
  String toString() {
    return 'EditPublisherRouteArgs{key: $key, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditPublisherRouteArgs) return false;
    return key == other.key && name == other.name;
  }

  @override
  int get hashCode => key.hashCode ^ name.hashCode;
}

/// generated route for
/// [_i11.EditRealmScreen]
class EditRealmRoute extends _i27.PageRouteInfo<EditRealmRouteArgs> {
  EditRealmRoute({
    _i28.Key? key,
    String? slug,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         EditRealmRoute.name,
         args: EditRealmRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'EditRealmRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditRealmRouteArgs>(
        orElse: () => EditRealmRouteArgs(slug: pathParams.optString('slug')),
      );
      return _i11.EditRealmScreen(key: args.key, slug: args.slug);
    },
  );
}

class EditRealmRouteArgs {
  const EditRealmRouteArgs({this.key, this.slug});

  final _i28.Key? key;

  final String? slug;

  @override
  String toString() {
    return 'EditRealmRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditRealmRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [_i12.EditStickerPacksScreen]
class EditStickerPacksRoute
    extends _i27.PageRouteInfo<EditStickerPacksRouteArgs> {
  EditStickerPacksRoute({
    _i28.Key? key,
    required String pubName,
    String? packId,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         EditStickerPacksRoute.name,
         args: EditStickerPacksRouteArgs(
           key: key,
           pubName: pubName,
           packId: packId,
         ),
         rawPathParams: {'name': pubName, 'packId': packId},
         initialChildren: children,
       );

  static const String name = 'EditStickerPacksRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditStickerPacksRouteArgs>(
        orElse:
            () => EditStickerPacksRouteArgs(
              pubName: pathParams.getString('name'),
              packId: pathParams.optString('packId'),
            ),
      );
      return _i12.EditStickerPacksScreen(
        key: args.key,
        pubName: args.pubName,
        packId: args.packId,
      );
    },
  );
}

class EditStickerPacksRouteArgs {
  const EditStickerPacksRouteArgs({
    this.key,
    required this.pubName,
    this.packId,
  });

  final _i28.Key? key;

  final String pubName;

  final String? packId;

  @override
  String toString() {
    return 'EditStickerPacksRouteArgs{key: $key, pubName: $pubName, packId: $packId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditStickerPacksRouteArgs) return false;
    return key == other.key &&
        pubName == other.pubName &&
        packId == other.packId;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode ^ packId.hashCode;
}

/// generated route for
/// [_i13.EditStickersScreen]
class EditStickersRoute extends _i27.PageRouteInfo<EditStickersRouteArgs> {
  EditStickersRoute({
    _i28.Key? key,
    required String packId,
    required String? id,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         EditStickersRoute.name,
         args: EditStickersRouteArgs(key: key, packId: packId, id: id),
         rawPathParams: {'packId': packId, 'id': id},
         initialChildren: children,
       );

  static const String name = 'EditStickersRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditStickersRouteArgs>(
        orElse:
            () => EditStickersRouteArgs(
              packId: pathParams.getString('packId'),
              id: pathParams.optString('id'),
            ),
      );
      return _i13.EditStickersScreen(
        key: args.key,
        packId: args.packId,
        id: args.id,
      );
    },
  );
}

class EditStickersRouteArgs {
  const EditStickersRouteArgs({
    this.key,
    required this.packId,
    required this.id,
  });

  final _i28.Key? key;

  final String packId;

  final String? id;

  @override
  String toString() {
    return 'EditStickersRouteArgs{key: $key, packId: $packId, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditStickersRouteArgs) return false;
    return key == other.key && packId == other.packId && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ packId.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i14.EventCalanderScreen]
class EventCalanderRoute extends _i27.PageRouteInfo<EventCalanderRouteArgs> {
  EventCalanderRoute({
    _i28.Key? key,
    required String name,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         EventCalanderRoute.name,
         args: EventCalanderRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'EventCalanderRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EventCalanderRouteArgs>(
        orElse:
            () => EventCalanderRouteArgs(name: pathParams.getString('name')),
      );
      return _i14.EventCalanderScreen(key: args.key, name: args.name);
    },
  );
}

class EventCalanderRouteArgs {
  const EventCalanderRouteArgs({this.key, required this.name});

  final _i28.Key? key;

  final String name;

  @override
  String toString() {
    return 'EventCalanderRouteArgs{key: $key, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventCalanderRouteArgs) return false;
    return key == other.key && name == other.name;
  }

  @override
  int get hashCode => key.hashCode ^ name.hashCode;
}

/// generated route for
/// [_i15.ExploreScreen]
class ExploreRoute extends _i27.PageRouteInfo<ExploreRouteArgs> {
  ExploreRoute({
    _i28.Key? key,
    bool isAside = false,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         ExploreRoute.name,
         args: ExploreRouteArgs(key: key, isAside: isAside),
         initialChildren: children,
       );

  static const String name = 'ExploreRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ExploreRouteArgs>(
        orElse: () => const ExploreRouteArgs(),
      );
      return _i15.ExploreScreen(key: args.key, isAside: args.isAside);
    },
  );
}

class ExploreRouteArgs {
  const ExploreRouteArgs({this.key, this.isAside = false});

  final _i28.Key? key;

  final bool isAside;

  @override
  String toString() {
    return 'ExploreRouteArgs{key: $key, isAside: $isAside}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ExploreRouteArgs) return false;
    return key == other.key && isAside == other.isAside;
  }

  @override
  int get hashCode => key.hashCode ^ isAside.hashCode;
}

/// generated route for
/// [_i15.ExploreShellScreen]
class ExploreShellRoute extends _i27.PageRouteInfo<void> {
  const ExploreShellRoute({List<_i27.PageRouteInfo>? children})
    : super(ExploreShellRoute.name, initialChildren: children);

  static const String name = 'ExploreShellRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i15.ExploreShellScreen();
    },
  );
}

/// generated route for
/// [_i16.LoginScreen]
class LoginRoute extends _i27.PageRouteInfo<void> {
  const LoginRoute({List<_i27.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i16.LoginScreen();
    },
  );
}

/// generated route for
/// [_i6.NewChatScreen]
class NewChatRoute extends _i27.PageRouteInfo<void> {
  const NewChatRoute({List<_i27.PageRouteInfo>? children})
    : super(NewChatRoute.name, initialChildren: children);

  static const String name = 'NewChatRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i6.NewChatScreen();
    },
  );
}

/// generated route for
/// [_i10.NewPublisherScreen]
class NewPublisherRoute extends _i27.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i27.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i10.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i11.NewRealmScreen]
class NewRealmRoute extends _i27.PageRouteInfo<void> {
  const NewRealmRoute({List<_i27.PageRouteInfo>? children})
    : super(NewRealmRoute.name, initialChildren: children);

  static const String name = 'NewRealmRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i11.NewRealmScreen();
    },
  );
}

/// generated route for
/// [_i12.NewStickerPacksScreen]
class NewStickerPacksRoute
    extends _i27.PageRouteInfo<NewStickerPacksRouteArgs> {
  NewStickerPacksRoute({
    _i28.Key? key,
    required String pubName,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         NewStickerPacksRoute.name,
         args: NewStickerPacksRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'name': pubName},
         initialChildren: children,
       );

  static const String name = 'NewStickerPacksRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<NewStickerPacksRouteArgs>(
        orElse:
            () =>
                NewStickerPacksRouteArgs(pubName: pathParams.getString('name')),
      );
      return _i12.NewStickerPacksScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class NewStickerPacksRouteArgs {
  const NewStickerPacksRouteArgs({this.key, required this.pubName});

  final _i28.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'NewStickerPacksRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NewStickerPacksRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i13.NewStickersScreen]
class NewStickersRoute extends _i27.PageRouteInfo<NewStickersRouteArgs> {
  NewStickersRoute({
    _i28.Key? key,
    required String packId,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         NewStickersRoute.name,
         args: NewStickersRouteArgs(key: key, packId: packId),
         rawPathParams: {'packId': packId},
         initialChildren: children,
       );

  static const String name = 'NewStickersRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<NewStickersRouteArgs>(
        orElse:
            () => NewStickersRouteArgs(packId: pathParams.getString('packId')),
      );
      return _i13.NewStickersScreen(key: args.key, packId: args.packId);
    },
  );
}

class NewStickersRouteArgs {
  const NewStickersRouteArgs({this.key, required this.packId});

  final _i28.Key? key;

  final String packId;

  @override
  String toString() {
    return 'NewStickersRouteArgs{key: $key, packId: $packId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NewStickersRouteArgs) return false;
    return key == other.key && packId == other.packId;
  }

  @override
  int get hashCode => key.hashCode ^ packId.hashCode;
}

/// generated route for
/// [_i17.NotificationScreen]
class NotificationRoute extends _i27.PageRouteInfo<void> {
  const NotificationRoute({List<_i27.PageRouteInfo>? children})
    : super(NotificationRoute.name, initialChildren: children);

  static const String name = 'NotificationRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i17.NotificationScreen();
    },
  );
}

/// generated route for
/// [_i18.PostComposeScreen]
class PostComposeRoute extends _i27.PageRouteInfo<PostComposeRouteArgs> {
  PostComposeRoute({
    _i28.Key? key,
    _i30.SnPost? originalPost,
    _i30.SnPost? repliedPost,
    _i30.SnPost? forwardedPost,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         PostComposeRoute.name,
         args: PostComposeRouteArgs(
           key: key,
           originalPost: originalPost,
           repliedPost: repliedPost,
           forwardedPost: forwardedPost,
         ),
         initialChildren: children,
       );

  static const String name = 'PostComposeRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostComposeRouteArgs>(
        orElse: () => const PostComposeRouteArgs(),
      );
      return _i18.PostComposeScreen(
        key: args.key,
        originalPost: args.originalPost,
        repliedPost: args.repliedPost,
        forwardedPost: args.forwardedPost,
      );
    },
  );
}

class PostComposeRouteArgs {
  const PostComposeRouteArgs({
    this.key,
    this.originalPost,
    this.repliedPost,
    this.forwardedPost,
  });

  final _i28.Key? key;

  final _i30.SnPost? originalPost;

  final _i30.SnPost? repliedPost;

  final _i30.SnPost? forwardedPost;

  @override
  String toString() {
    return 'PostComposeRouteArgs{key: $key, originalPost: $originalPost, repliedPost: $repliedPost, forwardedPost: $forwardedPost}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostComposeRouteArgs) return false;
    return key == other.key &&
        originalPost == other.originalPost &&
        repliedPost == other.repliedPost &&
        forwardedPost == other.forwardedPost;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      originalPost.hashCode ^
      repliedPost.hashCode ^
      forwardedPost.hashCode;
}

/// generated route for
/// [_i19.PostDetailScreen]
class PostDetailRoute extends _i27.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i28.Key? key,
    required String id,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostDetailRouteArgs>(
        orElse: () => PostDetailRouteArgs(id: pathParams.getString('id')),
      );
      return _i19.PostDetailScreen(key: args.key, id: args.id);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.id});

  final _i28.Key? key;

  final String id;

  @override
  String toString() {
    return 'PostDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i18.PostEditScreen]
class PostEditRoute extends _i27.PageRouteInfo<PostEditRouteArgs> {
  PostEditRoute({
    _i28.Key? key,
    required String id,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         PostEditRoute.name,
         args: PostEditRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostEditRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostEditRouteArgs>(
        orElse: () => PostEditRouteArgs(id: pathParams.getString('id')),
      );
      return _i18.PostEditScreen(key: args.key, id: args.id);
    },
  );
}

class PostEditRouteArgs {
  const PostEditRouteArgs({this.key, required this.id});

  final _i28.Key? key;

  final String id;

  @override
  String toString() {
    return 'PostEditRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostEditRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i20.PublisherProfileScreen]
class PublisherProfileRoute
    extends _i27.PageRouteInfo<PublisherProfileRouteArgs> {
  PublisherProfileRoute({
    _i28.Key? key,
    required String name,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         PublisherProfileRoute.name,
         args: PublisherProfileRouteArgs(key: key, name: name),
         rawPathParams: {'name': name},
         initialChildren: children,
       );

  static const String name = 'PublisherProfileRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PublisherProfileRouteArgs>(
        orElse:
            () => PublisherProfileRouteArgs(name: pathParams.getString('name')),
      );
      return _i20.PublisherProfileScreen(key: args.key, name: args.name);
    },
  );
}

class PublisherProfileRouteArgs {
  const PublisherProfileRouteArgs({this.key, required this.name});

  final _i28.Key? key;

  final String name;

  @override
  String toString() {
    return 'PublisherProfileRouteArgs{key: $key, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PublisherProfileRouteArgs) return false;
    return key == other.key && name == other.name;
  }

  @override
  int get hashCode => key.hashCode ^ name.hashCode;
}

/// generated route for
/// [_i21.RealmDetailScreen]
class RealmDetailRoute extends _i27.PageRouteInfo<RealmDetailRouteArgs> {
  RealmDetailRoute({
    _i28.Key? key,
    required String slug,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         RealmDetailRoute.name,
         args: RealmDetailRouteArgs(key: key, slug: slug),
         rawPathParams: {'slug': slug},
         initialChildren: children,
       );

  static const String name = 'RealmDetailRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RealmDetailRouteArgs>(
        orElse: () => RealmDetailRouteArgs(slug: pathParams.getString('slug')),
      );
      return _i21.RealmDetailScreen(key: args.key, slug: args.slug);
    },
  );
}

class RealmDetailRouteArgs {
  const RealmDetailRouteArgs({this.key, required this.slug});

  final _i28.Key? key;

  final String slug;

  @override
  String toString() {
    return 'RealmDetailRouteArgs{key: $key, slug: $slug}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RealmDetailRouteArgs) return false;
    return key == other.key && slug == other.slug;
  }

  @override
  int get hashCode => key.hashCode ^ slug.hashCode;
}

/// generated route for
/// [_i11.RealmListScreen]
class RealmListRoute extends _i27.PageRouteInfo<void> {
  const RealmListRoute({List<_i27.PageRouteInfo>? children})
    : super(RealmListRoute.name, initialChildren: children);

  static const String name = 'RealmListRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i11.RealmListScreen();
    },
  );
}

/// generated route for
/// [_i22.RelationshipScreen]
class RelationshipRoute extends _i27.PageRouteInfo<void> {
  const RelationshipRoute({List<_i27.PageRouteInfo>? children})
    : super(RelationshipRoute.name, initialChildren: children);

  static const String name = 'RelationshipRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i22.RelationshipScreen();
    },
  );
}

/// generated route for
/// [_i23.SettingsScreen]
class SettingsRoute extends _i27.PageRouteInfo<void> {
  const SettingsRoute({List<_i27.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i23.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i13.StickerPackDetailScreen]
class StickerPackDetailRoute
    extends _i27.PageRouteInfo<StickerPackDetailRouteArgs> {
  StickerPackDetailRoute({
    _i28.Key? key,
    required String pubName,
    required String id,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         StickerPackDetailRoute.name,
         args: StickerPackDetailRouteArgs(key: key, pubName: pubName, id: id),
         rawPathParams: {'name': pubName, 'packId': id},
         initialChildren: children,
       );

  static const String name = 'StickerPackDetailRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<StickerPackDetailRouteArgs>(
        orElse:
            () => StickerPackDetailRouteArgs(
              pubName: pathParams.getString('name'),
              id: pathParams.getString('packId'),
            ),
      );
      return _i13.StickerPackDetailScreen(
        key: args.key,
        pubName: args.pubName,
        id: args.id,
      );
    },
  );
}

class StickerPackDetailRouteArgs {
  const StickerPackDetailRouteArgs({
    this.key,
    required this.pubName,
    required this.id,
  });

  final _i28.Key? key;

  final String pubName;

  final String id;

  @override
  String toString() {
    return 'StickerPackDetailRouteArgs{key: $key, pubName: $pubName, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StickerPackDetailRouteArgs) return false;
    return key == other.key && pubName == other.pubName && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i12.StickersScreen]
class StickersRoute extends _i27.PageRouteInfo<StickersRouteArgs> {
  StickersRoute({
    _i28.Key? key,
    required String pubName,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         StickersRoute.name,
         args: StickersRouteArgs(key: key, pubName: pubName),
         rawPathParams: {'name': pubName},
         initialChildren: children,
       );

  static const String name = 'StickersRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<StickersRouteArgs>(
        orElse: () => StickersRouteArgs(pubName: pathParams.getString('name')),
      );
      return _i12.StickersScreen(key: args.key, pubName: args.pubName);
    },
  );
}

class StickersRouteArgs {
  const StickersRouteArgs({this.key, required this.pubName});

  final _i28.Key? key;

  final String pubName;

  @override
  String toString() {
    return 'StickersRouteArgs{key: $key, pubName: $pubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StickersRouteArgs) return false;
    return key == other.key && pubName == other.pubName;
  }

  @override
  int get hashCode => key.hashCode ^ pubName.hashCode;
}

/// generated route for
/// [_i24.TabsNavigationWidget]
class TabsNavigationWidget
    extends _i27.PageRouteInfo<TabsNavigationWidgetArgs> {
  TabsNavigationWidget({
    _i28.Key? key,
    required _i28.Widget child,
    required _i31.AppRouter router,
    List<_i27.PageRouteInfo>? children,
  }) : super(
         TabsNavigationWidget.name,
         args: TabsNavigationWidgetArgs(key: key, child: child, router: router),
         initialChildren: children,
       );

  static const String name = 'TabsNavigationWidget';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TabsNavigationWidgetArgs>();
      return _i24.TabsNavigationWidget(
        key: args.key,
        child: args.child,
        router: args.router,
      );
    },
  );
}

class TabsNavigationWidgetArgs {
  const TabsNavigationWidgetArgs({
    this.key,
    required this.child,
    required this.router,
  });

  final _i28.Key? key;

  final _i28.Widget child;

  final _i31.AppRouter router;

  @override
  String toString() {
    return 'TabsNavigationWidgetArgs{key: $key, child: $child, router: $router}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TabsNavigationWidgetArgs) return false;
    return key == other.key && child == other.child && router == other.router;
  }

  @override
  int get hashCode => key.hashCode ^ child.hashCode ^ router.hashCode;
}

/// generated route for
/// [_i25.UpdateProfileScreen]
class UpdateProfileRoute extends _i27.PageRouteInfo<void> {
  const UpdateProfileRoute({List<_i27.PageRouteInfo>? children})
    : super(UpdateProfileRoute.name, initialChildren: children);

  static const String name = 'UpdateProfileRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i25.UpdateProfileScreen();
    },
  );
}

/// generated route for
/// [_i26.WalletScreen]
class WalletRoute extends _i27.PageRouteInfo<void> {
  const WalletRoute({List<_i27.PageRouteInfo>? children})
    : super(WalletRoute.name, initialChildren: children);

  static const String name = 'WalletRoute';

  static _i27.PageInfo page = _i27.PageInfo(
    name,
    builder: (data) {
      return const _i26.WalletScreen();
    },
  );
}
