import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const denseButtonStyle = ButtonStyle(visualDensity: VisualDensity(vertical: -4));

    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('screenAbout').tr(),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Image.asset('assets/icon/icon-light-radius.png', width: 120, height: 120),
            ),
            const Gap(8),
            Text(
              'Solian',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 36),
            ),
            const Text(
              'The Solar Network',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Gap(8),
            FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                return Text(
                  'v${snapshot.data!.version} · ${snapshot.data!.buildNumber}',
                  style: const TextStyle(fontFamily: 'monospace'),
                );
              },
            ),
            Text('Copyright © ${DateTime.now().year} Solsynth LLC'),
            const Gap(16),
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    style: denseButtonStyle,
                    child: Text('appDetails').tr(),
                    onPressed: () async {
                      final info = await PackageInfo.fromPlatform();

                      if (!context.mounted) return;
                      showAboutDialog(
                        context: context,
                        applicationName: 'Solian',
                        applicationVersion: '${info.version}+${info.buildNumber}',
                        applicationLegalese:
                            'The Solar Network App is an intuitive and open-source social network and computing platform. Experience the freedom of a user-friendly design that empowers you to create and connect with communities on your own terms. Embrace the future of social networking with a platform that prioritizes your independence and privacy.',
                        applicationIcon: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: Image.asset(
                            'assets/icon/icon-light-radius.png',
                            width: 60,
                            height: 60,
                          ),
                        ),
                      );
                    },
                  ),
                  TextButton(
                    style: denseButtonStyle,
                    child: Text('termRelated').tr(),
                    onPressed: () {
                      launchUrlString('https://solsynth.dev/terms');
                    },
                  ),
                  TextButton(
                    style: denseButtonStyle,
                    child: Text('serviceStatus').tr(),
                    onPressed: () {
                      launchUrlString('https://status.solsynth.dev');
                    },
                  ),
                  TextButton(
                    style: denseButtonStyle,
                    child: Text('projectDetail').tr(),
                    onPressed: () {
                      launchUrlString('https://solsynth.dev/products/solar-network');
                    },
                  ),
                ],
              ),
            ).center(),
            const Gap(16),
            const Text(
              'Open-sourced under AGPLv3',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 12,
              ),
            ),
            InkWell(
              child: Text('GitHub', style: TextStyle(fontSize: 12)),
              onTap: () {
                launchUrlString('https://github.com/Solsynth/HyperNet.Surface');
              },
            )
          ],
        ),
      ),
    );
  }
}
