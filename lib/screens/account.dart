import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/route.gr.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class AccountScreen extends HookConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);

    if (!user.hasValue) return _UnauthorizedAccountScreen();

    return AppScaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.value?.profile.background != null)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 7,
                        child: CloudFileWidget(
                          item: user.value!.profile.background!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                      ProfilePictureWidget(
                        item: user.value!.profile.picture,
                        radius: 24,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            spacing: 4,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(user.value!.nick).bold().fontSize(16),
                              Text('@${user.value!.name}'),
                            ],
                          ),
                          Text(
                            user.value!.profile.bio ?? 'No description yet.',
                          ),
                        ],
                      ),
                    ],
                  ).padding(horizontal: 16, vertical: 16),
                ],
              ),
            ).padding(horizontal: 8),
            const Gap(8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.public),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('managedPublisher').tr(),
              onTap: () {
                context.router.push(ManagedPublisherRoute());
              },
            ),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.edit),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('updateYourProfile').tr(),
              onTap: () {
                context.router.push(UpdateProfileRoute());
              },
            ),
            if (kDebugMode) const Divider(height: 1).padding(vertical: 8),
            if (kDebugMode)
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.copy_all),
                trailing: const Icon(Symbols.chevron_right),
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                title: Text('Copy access token'),
                onTap: () async {
                  final tk = ref.watch(tokenPairProvider);
                  Clipboard.setData(ClipboardData(text: tk!.accessToken));
                },
              ),
            const Divider(height: 1).padding(vertical: 8),
            ListTile(
              minTileHeight: 48,
              leading: const Icon(Symbols.logout),
              trailing: const Icon(Symbols.chevron_right),
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
              title: Text('logout').tr(),
              onTap: () {
                final userNotifier = ref.read(userInfoProvider.notifier);
                userNotifier.logOut();
              },
            ),
          ],
        ).padding(top: 8, bottom: MediaQuery.of(context).padding.bottom),
      ),
    );
  }
}

class _UnauthorizedAccountScreen extends StatelessWidget {
  const _UnauthorizedAccountScreen();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Symbols.person_add),
            trailing: const Icon(Symbols.chevron_right),
            title: Text('createAccount').tr(),
            subtitle: Text('New to here? We got you covered!'),
            contentPadding: EdgeInsets.symmetric(horizontal: 24),
            onTap: () {
              context.router.push(CreateAccountRoute());
            },
          ),
          ListTile(
            leading: const Icon(Symbols.login),
            trailing: const Icon(Symbols.chevron_right),
            subtitle: Text('Existing user? We\'re welcome you back!'),
            contentPadding: EdgeInsets.symmetric(horizontal: 24),
            title: Text('login').tr(),
            onTap: () {
              context.router.push(LoginRoute());
            },
          ),
        ],
      ),
    );
  }
}
