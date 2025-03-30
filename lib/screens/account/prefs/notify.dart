import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

final Map<String, String> kNotifyTopicMap = {
  'interactive.reply': 'notificationTopicPostReply'.tr(),
  'interactive.feedback': 'notificationTopicPostFeedback'.tr(),
  'interactive.subscription': 'notificationTopicPostSubscription'.tr(),
  'messaging.message': 'notificationTopicMessaging'.tr(),
  'messaging.call': 'notificationTopicMessagingCall'.tr(),
  'general': 'notificationTopicGeneral'.tr(),
};

class AccountNotifyPrefsScreen extends StatefulWidget {
  const AccountNotifyPrefsScreen({super.key});

  @override
  State<AccountNotifyPrefsScreen> createState() =>
      _AccountNotifyPrefsScreenState();
}

class _AccountNotifyPrefsScreenState extends State<AccountNotifyPrefsScreen> {
  bool _isBusy = true;

  Map<String, bool> _config = {};

  Future<void> _getPreferences() async {
    setState(() => _isBusy = true);

    final sn = context.read<SnNetworkProvider>();

    try {
      final resp = await sn.client.get('/cgi/id/preferences/notifications');
      _config = resp.data['config']
          .map((k, v) => MapEntry(k, v as bool))
          .cast<String, bool>();
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isBusy = true);

    final sn = context.read<SnNetworkProvider>();

    try {
      await sn.client.put(
        '/cgi/id/preferences/notifications',
        data: {
          'config': _config,
        },
      );
      if (!mounted) return;
      context.showSnackbar('accountSettingsApplied'.tr());
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: ResponsiveScaffold.getIsExpand(context),
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('accountSettingsNotify').tr(),
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          ListTile(
            tileColor: Theme.of(context).colorScheme.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.save),
            title: Text('save').tr(),
            enabled: !_isBusy,
            onTap: () {
              _savePreferences();
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: kNotifyTopicMap.length,
              itemBuilder: (context, index) {
                final element = kNotifyTopicMap.entries.elementAt(index);
                return CheckboxListTile(
                  title: Text(element.value),
                  subtitle: Text(
                    element.key,
                    style: GoogleFonts.robotoMono(fontSize: 12),
                  ),
                  value: _config[element.key] ?? true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  onChanged: (value) {
                    setState(() {
                      _config[element.key] = value ?? false;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
