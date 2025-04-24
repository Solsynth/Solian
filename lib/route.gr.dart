// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:island/screens/account.dart' as _i1;
import 'package:island/screens/auth/create_account.dart' as _i2;
import 'package:island/screens/auth/login.dart' as _i4;
import 'package:island/screens/explore.dart' as _i3;

/// generated route for
/// [_i1.AccountScreen]
class AccountRoute extends _i5.PageRouteInfo<void> {
  const AccountRoute({List<_i5.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountScreen();
    },
  );
}

/// generated route for
/// [_i2.CreateAccountScreen]
class CreateAccountRoute extends _i5.PageRouteInfo<void> {
  const CreateAccountRoute({List<_i5.PageRouteInfo>? children})
    : super(CreateAccountRoute.name, initialChildren: children);

  static const String name = 'CreateAccountRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.CreateAccountScreen();
    },
  );
}

/// generated route for
/// [_i3.ExploreScreen]
class ExploreRoute extends _i5.PageRouteInfo<void> {
  const ExploreRoute({List<_i5.PageRouteInfo>? children})
    : super(ExploreRoute.name, initialChildren: children);

  static const String name = 'ExploreRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.ExploreScreen();
    },
  );
}

/// generated route for
/// [_i4.LoginScreen]
class LoginRoute extends _i5.PageRouteInfo<void> {
  const LoginRoute({List<_i5.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.LoginScreen();
    },
  );
}
