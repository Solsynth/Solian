import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_update/azhon_app_update.dart';
import 'package:flutter_app_update/update_model.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/config.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/markdown_content.dart';
import 'package:url_launcher/url_launcher_string.dart';

class VersionUpdatePopup extends StatelessWidget {
  const VersionUpdatePopup({super.key});

  void _update(BuildContext context) async {
    if (kIsWeb) return;

    final config = context.read<ConfigProvider>();

    if (Platform.isAndroid) {
      final model = UpdateModel(
        'https://files.solsynth.dev/d/c1/solian/app-arm64-v8a-release.apk',
        'solian-app-release-${config.updatableVersion!}.apk',
        'ic_launcher',
        'https://apps.apple.com/us/app/solian/id6499032345',
      );
      AzhonAppUpdate.update(model);
      context.showSnackbar('updateOngoing'.tr());
      return;
    }

    final resp = await Dio(
      BaseOptions(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    ).get(
      'https://api.github.com/repos/Solsynth/HyperNet.Surface/releases/latest',
    );

    launchUrlString(resp.data?['html_url']);
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.update),
            const Gap(16),
            Text('update')
                .tr()
                .textStyle(Theme.of(context).textTheme.titleLarge!),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                config.updatableVersion ?? 'unknown'.tr(),
                style: GoogleFonts.robotoMono(),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -3,
                ),
              ),
              onPressed: () => _update(context),
              child: Text('update').tr(),
            ),
          ],
        ).padding(horizontal: 20),
        const Divider(height: 1).padding(vertical: 8),
        Expanded(
          child: SingleChildScrollView(
            child: MarkdownTextContent(
              content: config.updatableChangelog ?? 'No changelog',
            ).padding(horizontal: 20),
          ),
        )
      ],
    );
  }
}
