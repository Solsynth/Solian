import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/app_scaffold.dart';

@RoutePage()
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Login'),
            onTap: () {
              context.router.push(LoginRoute());
            },
          ),
          ListTile(
            title: Text('Create an account'),
            onTap: () {
              context.router.push(CreateAccountRoute());
            },
          ),
        ],
      ),
    );
  }
}
