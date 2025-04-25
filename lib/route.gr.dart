// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:island/screens/account.dart' as _i1;
import 'package:island/screens/auth/account/me.dart' as _i6;
import 'package:island/screens/auth/account/me/publishers.dart' as _i3;
import 'package:island/screens/auth/account/me/update.dart' as _i8;
import 'package:island/screens/auth/create_account.dart' as _i2;
import 'package:island/screens/auth/login.dart' as _i5;
import 'package:island/screens/auth/tabs.dart' as _i7;
import 'package:island/screens/explore.dart' as _i4;

/// generated route for
/// [_i1.AccountScreen]
class AccountRoute extends _i9.PageRouteInfo<void> {
  const AccountRoute({List<_i9.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountScreen();
    },
  );
}

/// generated route for
/// [_i2.CreateAccountScreen]
class CreateAccountRoute extends _i9.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i9.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i3.EditPublisherScreen]
class EditPublisherRoute extends _i9.PageRouteInfo<EditPublisherRouteArgs> {
  EditPublisherRoute({
    _i10.Key? key,
    String? name,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         EditPublisherRoute.name,
         args: EditPublisherRouteArgs(key: key, name: name),
         rawPathParams: {'id': name},
         initialChildren: children,
       );

  static const String name = 'EditPublisherRoute';

  static _i9.PageInfo page = _i9.PageInfo(
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

  final _i10.Key? key;

  final String? name;

  @override
  String toString() {
    return 'EditPublisherRouteArgs{key: $key, name: $name}';
  }
}

/// generated route for
/// [_i4.ExploreScreen]
class ExploreRoute extends _i9.PageRouteInfo<void> {
  const ExploreRoute({List<_i9.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i5.LoginScreen]
class LoginRoute extends _i9.PageRouteInfo<void> {
  const LoginRoute({List<_i9.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.LoginScreen();
    },
  );
}

/// generated route for
/// [_i3.ManagedPublisherScreen]
class ManagedPublisherRoute extends _i9.PageRouteInfo<void> {
  const ManagedPublisherRoute({List<_i9.PageRouteInfo>? children})
    : super(ManagedPublisherRoute.name, initialChildren: children);

  static const String name = 'ManagedPublisherRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.ManagedPublisherScreen();
    },
  );
}

/// generated route for
/// [_i6.MyselfProfileScreen]
class MyselfProfileRoute extends _i9.PageRouteInfo<void> {
  const MyselfProfileRoute({List<_i9.PageRouteInfo>? children})
    : super(MyselfProfileRoute.name, initialChildren: children);

  static const String name = 'MyselfProfileRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.MyselfProfileScreen();
    },
  );
}

/// generated route for
/// [_i3.NewPublisherScreen]
class NewPublisherRoute extends _i9.PageRouteInfo<void> {
  const NewPublisherRoute({List<_i9.PageRouteInfo>? children})
    : super(NewPublisherRoute.name, initialChildren: children);

  static const String name = 'NewPublisherRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.NewPublisherScreen();
    },
  );
}

/// generated route for
/// [_i7.TabsScreen]
class TabsRoute extends _i9.PageRouteInfo<void> {
  const TabsRoute({List<_i9.PageRouteInfo>? children})
    : super(TabsRoute.name, initialChildren: children);

  static const String name = 'TabsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i7.TabsScreen();
    },
  );
}

/// generated route for
/// [_i8.UpdateProfileScreen]
class UpdateProfileRoute extends _i9.PageRouteInfo<void> {
  const UpdateProfileRoute({List<_i9.PageRouteInfo>? children})
    : super(UpdateProfileRoute.name, initialChildren: children);

  static const String name = 'UpdateProfileRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i8.UpdateProfileScreen();
    },
  );
}
