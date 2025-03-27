import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

class AccountSecurityPrefsScreen extends StatefulWidget {
  const AccountSecurityPrefsScreen({super.key});

  @override
  State<AccountSecurityPrefsScreen> createState() =>
      _AccountSecurityPrefsScreenState();
}

class _AccountSecurityPrefsScreenState
    extends State<AccountSecurityPrefsScreen> {
  bool _isBusy = true;

  Map<String, dynamic> _config = {
    'maximum_auth_steps': 2,
    'always_risky': false,
  };

  Future<void> _getPreferences() async {
    setState(() => _isBusy = true);

    final sn = context.read<SnNetworkProvider>();

    try {
      final resp = await sn.client.get('/cgi/id/preferences/auth');
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
        '/cgi/id/preferences/auth',
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
      noBackground: true,
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('accountSettingsSecurity').tr(),
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  title: Text('authMaximumAuthSteps').tr(),
                  subtitle: Text('authMaximumAuthStepsDescription')
                      .plural(_config['maximum_auth_steps'] ?? 2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                        icon: const Icon(Symbols.remove),
                        onPressed: () {
                          if (_config['maximum_auth_steps'] > 1) {
                            setState(() => _config['maximum_auth_steps']--);
                          }
                        },
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                        icon: const Icon(Symbols.add),
                        onPressed: () {
                          if (_config['maximum_auth_steps'] < 99) {
                            setState(() => _config['maximum_auth_steps']++);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                CheckboxListTile(
                  title: Text('authAlwaysRisky').tr(),
                  subtitle: Text('authAlwaysRiskyDescription').tr(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  value: _config['always_risky'] ?? false,
                  onChanged: (value) {
                    setState(() => _config['always_risky'] = value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
