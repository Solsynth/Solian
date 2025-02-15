import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

import '../types/account.dart';

class AbuseReportScreen extends StatefulWidget {
  const AbuseReportScreen({super.key});

  @override
  State<AbuseReportScreen> createState() => _AbuseReportScreenState();
}

class _AbuseReportScreenState extends State<AbuseReportScreen> {
  bool _isBusy = false;

  List<SnAbuseReport> _reports = List.empty();

  Future<void> _fetchReports() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/reports/abuse');
      if (!mounted) return;
      _reports = resp.data.map((e) => SnAbuseReport.fromJson(e)).cast<SnAbuseReport>().toList();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _showAbuseReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AbuseReportDialog(),
    ).then((value) {
      if (value == true && mounted) {
        _fetchReports();
        context.showSnackbar('abuseReportSubmitted'.tr());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('screenAbuseReport').tr(),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('abuseReportAction').tr(),
            subtitle: Text('abuseReportActionDescription').tr(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.report),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAbuseReportDialog,
          ),
          const Divider(height: 1),
          if (_isBusy)
            Padding(
              padding: const EdgeInsets.all(24),
              child: const CircularProgressIndicator(),
            ).center()
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 8),
                itemCount: _reports.length,
                itemBuilder: (context, idx) {
                  return ListTile(
                    isThreeLine: true,
                    title: Text(_reports[idx].resource, style: GoogleFonts.robotoMono(fontSize: 13)),
                    subtitle: Text(_reports[idx].reason),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: const Icon(Icons.flag),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class AbuseReportDialog extends StatefulWidget {
  final String? resourceLocation;

  const AbuseReportDialog({super.key, this.resourceLocation});

  @override
  State<AbuseReportDialog> createState() => _AbuseReportDialogState();
}

class _AbuseReportDialogState extends State<AbuseReportDialog> {
  bool _isBusy = false;

  final _resourceController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.resourceLocation != null) {
      _resourceController.text = widget.resourceLocation!;
    }
  }

  @override
  dispose() {
    _resourceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _performAction() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post(
        '/cgi/id/reports/abuse',
        data: {
          'resource': _resourceController.text,
          'reason': _reasonController.text,
        },
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('abuseReport'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('abuseReportDescription'.tr()),
          const Gap(12),
          TextField(
            controller: _resourceController,
            readOnly: widget.resourceLocation != null,
            maxLength: null,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'abuseReportResource'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(4),
          TextField(
            controller: _reasonController,
            maxLength: null,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'abuseReportReason'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isBusy ? null : () => Navigator.pop(context),
          child: Text('dialogDismiss').tr(),
        ),
        TextButton(
          onPressed: _isBusy ? null : _performAction,
          child: Text('submit').tr(),
        ),
      ],
    );
  }
}
