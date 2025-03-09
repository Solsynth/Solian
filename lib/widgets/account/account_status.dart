import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/account.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';

final Map<String, (Widget, String, String?)> kPresetStatus = {
  'online': (
    const Icon(Symbols.circle, color: Colors.green, fill: 1),
    'accountStatusOnline'.tr(),
    null,
  ),
  'silent': (
    const Icon(Symbols.do_not_disturb_on, color: Colors.red),
    'accountStatusSilent'.tr(),
    'accountStatusSilentDesc'.tr(),
  ),
  'invisible': (
    const Icon(Symbols.circle, color: Colors.grey),
    'accountStatusInvisible'.tr(),
    'accountStatusInvisibleDesc'.tr(),
  ),
};

class AccountStatusActionPopup extends StatefulWidget {
  final SnAccountStatusInfo? currentStatus;
  const AccountStatusActionPopup({super.key, this.currentStatus});

  @override
  State<AccountStatusActionPopup> createState() =>
      _AccountStatusActionPopupState();
}

class _AccountStatusActionPopupState extends State<AccountStatusActionPopup> {
  bool _isBusy = false;

  Future<void> setStatus(
    String type,
    String? label,
    int attitude, {
    bool isUpdate = false,
    bool isSilent = false,
    bool isInvisible = false,
    DateTime? clearAt,
  }) async {
    setState(() => _isBusy = true);
    final sn = context.read<SnNetworkProvider>();

    final payload = {
      'type': type,
      'label': label,
      'attitude': attitude,
      'is_no_disturb': isSilent,
      'is_invisible': isInvisible,
      'clear_at': clearAt?.toUtc().toIso8601String()
    };

    try {
      await sn.client.request(
        '/cgi/id/users/me/status',
        data: payload,
        options: Options(method: isUpdate ? 'PUT' : 'POST'),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _clearStatus() async {
    if (_isBusy) return;

    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.delete('/cgi/id/users/me/status');
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Symbols.mood, size: 24),
            const Gap(16),
            Text('accountChangeStatus',
                    style: Theme.of(context).textTheme.titleLarge)
                .tr(),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        LoadingIndicator(isActive: _isBusy),
        SizedBox(
          height: 48,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            children: kPresetStatus.entries
                .map(
                  (x) => StyledWidget(ActionChip(
                    avatar: x.value.$1,
                    label: Text(x.value.$2),
                    tooltip: x.value.$3,
                    onPressed: _isBusy
                        ? null
                        : () {
                            setStatus(
                              x.key,
                              x.value.$2,
                              0,
                              isInvisible: x.key == 'invisible',
                              isSilent: x.key == 'silent',
                            );
                          },
                  )).padding(right: 6),
                )
                .toList(),
          ),
        ),
        const Gap(16),
        const Divider(thickness: 0.3, height: 0.3),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          leading: widget.currentStatus != null
              ? const Icon(Icons.edit)
              : const Icon(Icons.add),
          title: Text('accountCustomStatus').tr(),
          subtitle: Text('accountCustomStatusDescription').tr(),
          onTap: _isBusy
              ? null
              : () async {
                  final val = await showDialog(
                    context: context,
                    builder: (context) => _AccountStatusEditorDialog(
                      currentStatus: widget.currentStatus,
                    ),
                  );
                  if (val == true && context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
        ),
        if (widget.currentStatus != null)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.clear),
            title: Text('accountClearStatus').tr(),
            subtitle: Text('accountClearStatusDescription').tr(),
            onTap: _isBusy
                ? null
                : () {
                    _clearStatus();
                  },
          ),
      ],
    );
  }
}

class _AccountStatusEditorDialog extends StatefulWidget {
  final SnAccountStatusInfo? currentStatus;
  const _AccountStatusEditorDialog({this.currentStatus});

  @override
  State<_AccountStatusEditorDialog> createState() =>
      _AccountStatusEditorDialogState();
}

class _AccountStatusEditorDialogState
    extends State<_AccountStatusEditorDialog> {
  bool _isBusy = false;

  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _clearAtController = TextEditingController();

  int _attitude = 0;
  bool _isSilent = false;
  bool _isInvisible = false;
  DateTime? _clearAt;

  Future<void> _selectClearAt() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _clearAt?.toLocal() ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;
    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;
    if (!mounted) return;
    final picked = pickedDate.copyWith(
      hour: pickedTime.hour,
      minute: pickedTime.minute,
    );
    setState(() {
      _clearAt = picked;
      _clearAtController.text = DateFormat('y/M/d HH:mm').format(_clearAt!);
    });
  }

  Future<void> _applyStatus() async {
    if (_isBusy) return;

    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.request(
        '/cgi/id/users/me/status',
        data: {
          'type': 'custom',
          'label': _labelController.text,
          'attitude': _attitude,
          'is_no_disturb': _isSilent,
          'is_invisible': _isInvisible,
          'clear_at': _clearAt?.toUtc().toIso8601String(),
        },
        options: Options(
          method: widget.currentStatus?.status != null ? 'PUT' : 'POST',
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _syncWidget() {
    if (widget.currentStatus?.status != null) {
      _clearAt = widget.currentStatus!.status!.clearAt;
      if (_clearAt != null) {
        _clearAtController.text = DateFormat('y/M/d HH:mm').format(_clearAt!);
      }

      _labelController.text = widget.currentStatus!.status!.label;
      _attitude = widget.currentStatus!.status!.attitude;
      _isInvisible = widget.currentStatus!.status!.isInvisible;
      _isSilent = widget.currentStatus!.status!.isNoDisturb;
    }
  }

  @override
  void initState() {
    _syncWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('accountCustomStatus').tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingIndicator(isActive: _isBusy),
          TextField(
            controller: _labelController,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.label),
              border: const OutlineInputBorder(),
              labelText: 'fieldAccountStatusLabel'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(8),
          TextField(
            controller: _clearAtController,
            readOnly: true,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.event_busy),
              border: const OutlineInputBorder(),
              labelText: 'fieldAccountStatusClearAt'.tr(),
            ),
            onTap: () => _selectClearAt(),
          ),
          const Gap(8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 6,
              runSpacing: 0,
              children: [
                ChoiceChip(
                  avatar: Icon(
                    Symbols.radio_button_unchecked,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  selected: _attitude == 2,
                  label: Text('accountStatusNegative'.tr()),
                  onSelected: (val) {
                    if (val) setState(() => _attitude = 2);
                  },
                ),
                ChoiceChip(
                  avatar: Icon(
                    Symbols.contrast,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  selected: _attitude == 0,
                  label: Text('accountStatusNeutral'.tr()),
                  onSelected: (val) {
                    if (val) setState(() => _attitude = 0);
                  },
                ),
                ChoiceChip(
                  avatar: Icon(
                    Symbols.circle,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  selected: _attitude == 1,
                  label: Text('accountStatusPositive'.tr()),
                  onSelected: (val) {
                    if (val) setState(() => _attitude = 1);
                  },
                ),
              ],
            ),
          ),
          const Gap(4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 6,
              runSpacing: 0,
              children: [
                ChoiceChip(
                  selected: _isSilent,
                  label: Text('accountStatusSilent').tr(),
                  onSelected: (val) {
                    setState(() => _isSilent = val);
                  },
                ),
                ChoiceChip(
                  selected: _isInvisible,
                  label: Text('accountStatusInvisible').tr(),
                  onSelected: (val) {
                    setState(() => _isInvisible = val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
          onPressed: _isBusy ? null : () => Navigator.pop(context),
          child: Text('dialogCancel').tr(),
        ),
        TextButton(
          onPressed: _isBusy ? null : () => _applyStatus(),
          child: Text('dialogConfirm').tr(),
        ),
      ],
    );
  }
}
