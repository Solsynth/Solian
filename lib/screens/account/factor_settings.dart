import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/auth.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

final Map<int, (String, String, IconData)> kFactorTypes = {
  0: ('authFactorPassword', 'authFactorPasswordDescription', Symbols.password),
  1: ('authFactorEmail', 'authFactorEmailDescription', Symbols.email),
  2: ('authFactorTOTP', 'authFactorTOTPDescription', Symbols.timer),
  3: (
    'authFactorInAppNotify',
    'authFactorInAppNotifyDescription',
    Symbols.notifications_active
  ),
};

class FactorSettingsScreen extends StatefulWidget {
  const FactorSettingsScreen({super.key});

  @override
  State<FactorSettingsScreen> createState() => _FactorSettingsScreenState();
}

class _FactorSettingsScreenState extends State<FactorSettingsScreen> {
  bool _isBusy = false;
  List<SnAuthFactor>? _factors;

  Future<void> _fetchFactors() async {
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/users/me/factors');
      _factors = List<SnAuthFactor>.from(
        resp.data
                ?.map((e) => SnAuthFactor.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
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
    _fetchFactors();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: true,
      appBar: AppBar(
        leading: PageBackButton(),
        title: Text('screenFactorSettings').tr(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingIndicator(
            isActive: _isBusy,
          ),
          ListTile(
            title: Text('authFactorAdd').tr(),
            subtitle: Text('authFactorAddSubtitle').tr(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Symbols.add),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _FactorNewDialog(
                  currentlyHave: _factors!,
                ),
              ).then((val) {
                if (val == true) _fetchFactors();
              });
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: RefreshIndicator(
                onRefresh: _fetchFactors,
                child: ListView.builder(
                  itemCount: _factors?.length ?? 0,
                  itemBuilder: (context, idx) {
                    final ele = _factors![idx];
                    return ListTile(
                      title: Text(kFactorTypes[ele.type]!.$1).tr(),
                      subtitle: Text(kFactorTypes[ele.type]!.$2).tr(),
                      contentPadding:
                          const EdgeInsets.only(left: 24, right: 12),
                      leading: Icon(kFactorTypes[ele.type]!.$3),
                      trailing: IconButton(
                        icon: const Icon(Symbols.close),
                        onPressed: ele.type > 0
                            ? () {
                                context
                                    .showConfirmDialog(
                                  'authFactorDelete'.tr(),
                                  'authFactorDeleteDescription'.tr(
                                      args: [kFactorTypes[ele.type]!.$1.tr()]),
                                )
                                    .then((val) async {
                                  if (!val) return;
                                  try {
                                    if (!context.mounted) return;
                                    final sn =
                                        context.read<SnNetworkProvider>();
                                    await sn.client.delete(
                                        '/cgi/id/users/me/factors/${ele.id}');
                                    _fetchFactors();
                                  } catch (err) {
                                    if (!context.mounted) return;
                                    context.showErrorDialog(err);
                                  }
                                });
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FactorNewDialog extends StatefulWidget {
  final List<SnAuthFactor> currentlyHave;

  const _FactorNewDialog({required this.currentlyHave});

  @override
  State<_FactorNewDialog> createState() => _FactorNewDialogState();
}

class _FactorNewDialogState extends State<_FactorNewDialog> {
  int? _factorType;
  bool _isBusy = false;

  Future<void> _submit() async {
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.post('/cgi/id/users/me/factors', data: {
        'type': _factorType,
      });
      final factor = SnAuthFactor.fromJson(resp.data);
      if (!mounted) return;
      if (factor.type == 2) {
        await showModalBottomSheet(
          context: context,
          builder: (context) => _FactorTotpFactorDialog(factor: factor),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('authFactorAdd').tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton2<int>(
              hint: Text(
                'Select Item',
                style: TextStyle(
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              value: _factorType,
              items: kFactorTypes.entries.map(
                (ele) {
                  final contains = widget.currentlyHave
                      .map((ele) => ele.type)
                      .contains(ele.key);
                  return DropdownMenuItem<int>(
                    enabled: !contains,
                    value: ele.key,
                    child: Text(
                      ele.value.$1.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ).opacity(contains ? 0.75 : 1),
                  );
                },
              ).toList(),
              onChanged: (val) => setState(() {
                _factorType = val;
              }),
              buttonStyleData: ButtonStyleData(
                height: 50,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
          child: Text('dialogCancel').tr(),
        ),
        TextButton(
          onPressed: _isBusy ? null : () => _submit(),
          child: Text('dialogConfirm').tr(),
        ),
      ],
    );
  }
}

class _FactorTotpFactorDialog extends StatelessWidget {
  final SnAuthFactor factor;

  const _FactorTotpFactorDialog({required this.factor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'totpPostSetup',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ).tr().width(280),
          ),
          const Gap(4),
          Center(
            child: Text(
              'totpPostSetupDescription',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ).tr().width(280),
          ),
          const Gap(16),
          QrImageView(
            padding: EdgeInsets.zero,
            data: factor.config!['url'],
            errorCorrectionLevel: QrErrorCorrectLevel.H,
            version: QrVersions.auto,
            size: 160,
            gapless: true,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.circle,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Gap(16),
          Center(
            child: Text(
              'totpNeverShare',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ).tr().bold().width(280),
          ),
        ],
      ),
    );
  }
}
