// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i11;
import 'package:flutter/material.dart' as _i12;
import 'package:island/models/post.dart' as _i13;
import 'package:island/screens/account.dart' as _i1;
import 'package:island/screens/account/me.dart' as _i6;
import 'package:island/screens/account/me/publishers.dart' as _i3;
import 'package:island/screens/account/me/update.dart' as _i10;
import 'package:island/screens/auth/create_account.dart' as _i2;
import 'package:island/screens/auth/login.dart' as _i5;
import 'package:island/screens/auth/tabs.dart' as _i9;
import 'package:island/screens/explore.dart' as _i4;
import 'package:island/screens/posts/compose.dart' as _i7;
import 'package:island/screens/posts/detail.dart' as _i8;

/// generated route for
/// [_i1.AccountScreen]
class AccountRoute extends _i11.PageRouteInfo<void> {
  const AccountRoute({List<_i11.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountScreen();
    },
  );
}

/// generated route for
/// [_i2.CreateAccountScreen]
class CreateAccountRoute extends _i11.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i11.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i2.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i3.EditPublisherScreen]
class EditPublisherRoute extends _i11.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i12.Key? key,
    String? name,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         rawPathParams: {'id': name},
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditPublisherRouteArgs>(
        orElse: () => EditPublisherRouteArgs(name: pathParams.optString('id')),
      );
      return _i3.EditPublisherScreen(key: args.key, name: args.name);
    },
  );
}

class EditPublisherRouteArgs {
  const EditPublisherRouteArgs({this.key, this.name});

  final _i12.Key? key;

  final String? name;

  @override
  String toString() {
    return 'EditPublisherRouteArgs{key: $key, name: $name}';
  }
}

/// generated route for
/// [_i4.ExploreScreen]
class ExploreRoute extends _i11.PageRouteInfo<void> {
  const ExploreRoute({List<_i11.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i4.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i5.LoginScreen]
class LoginRoute extends _i11.PageRouteInfo<void> {
  const LoginRoute({List<_i11.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i5.LoginScreen();
    },
  );
}

/// generated route for
/// [_i3.ManagedPublisherScreen]
class ManagedPublisherRoute extends _i11.PageRouteInfo<void> {
  const ManagedPublisherRoute({List<_i11.PageRouteInfo>? children})
    : super(ManagedPublisherRoute.name, initialChildren: children);

  static const String name = 'ManagedPublisherRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i3.ManagedPublisherScreen();
    },
  );
}

/// generated route for
/// [_i6.MyselfProfileScreen]
class MyselfProfileRoute extends _i11.PageRouteInfo<void> {
  const MyselfProfileRoute({List<_i11.PageRouteInfo>? children})
    : super(MyselfProfileRoute.name, initialChildren: children);

  static const String name = 'MyselfProfileRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i6.MyselfProfileScreen();
    },
  );
}

/// generated route for
/// [_i3.NewPublisherScreen]
class NewPublisherRoute extends _i11.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i11.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i3.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i7.PostComposeScreen]
class PostComposeRoute extends _i11.PageRouteInfo<PostComposeRouteArgs> {
  PostComposeRoute({
    _i12.Key? key,
    _i13.SnPost? originalPost,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         PostComposeRoute.name,
         args: PostComposeRouteArgs(key: key, originalPost: originalPost),
         initialChildren: children,
       );

  static const String name = 'PostComposeRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostComposeRouteArgs>(
        orElse: () => const PostComposeRouteArgs(),
      );
      return _i7.PostComposeScreen(
        key: args.key,
        originalPost: args.originalPost,
      );
    },
  );
}

class PostComposeRouteArgs {
  const PostComposeRouteArgs({this.key, this.originalPost});

  final _i12.Key? key;

  final _i13.SnPost? originalPost;

  @override
  String toString() {
    return 'PostComposeRouteArgs{key: $key, originalPost: $originalPost}';
  }
}

/// generated route for
/// [_i8.PostDetailScreen]
class PostDetailRoute extends _i11.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i12.Key? key,
    required int id,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostDetailRouteArgs>(
        orElse: () => PostDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i8.PostDetailScreen(key: args.key, id: args.id);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.id});

  final _i12.Key? key;

  final int id;

  @override
  String toString() {
    return 'PostDetailRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i7.PostEditScreen]
class PostEditRoute extends _i11.PageRouteInfo<PostEditRouteArgs> {
  PostEditRoute({
    _i12.Key? key,
    required int id,
    List<_i11.PageRouteInfo>? children,
  }) : super(
         PostEditRoute.name,
         args: PostEditRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PostEditRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PostEditRouteArgs>(
        orElse: () => PostEditRouteArgs(id: pathParams.getInt('id')),
      );
      return _i7.PostEditScreen(key: args.key, id: args.id);
    },
  );
}

class PostEditRouteArgs {
  const PostEditRouteArgs({this.key, required this.id});

  final _i12.Key? key;

  final int id;

  @override
  String toString() {
    return 'PostEditRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i9.TabsScreen]
class TabsRoute extends _i11.PageRouteInfo<void> {
  const TabsRoute({List<_i11.PageRouteInfo>? children})
    : super(TabsRoute.name, initialChildren: children);

  static const String name = 'TabsRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i9.TabsScreen();
    },
  );
}

/// generated route for
/// [_i10.UpdateProfileScreen]
class UpdateProfileRoute extends _i11.PageRouteInfo<void> {
  const UpdateProfileRoute({List<_i11.PageRouteInfo>? children})
    : super(UpdateProfileRoute.name, initialChildren: children);

  static const String name = 'UpdateProfileRoute';

  static _i11.PageInfo page = _i11.PageInfo(
    name,
    builder: (data) {
      return const _i10.UpdateProfileScreen();
    },
  );
}
