import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/keypair.dart';
import 'package:surface/types/keypair.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

class KeyPairScreen extends StatefulWidget {
  const KeyPairScreen({super.key});

  @override
  State<KeyPairScreen> createState() => _KeyPairScreenState();
}

class _KeyPairScreenState extends State<KeyPairScreen> {
  bool _isBusy = false;
  List<SnKeyPair>? _keyPairs;

  Future<void> _loadKeyPairs() async {
    setState(() => _isBusy = true);
    final kps = await context.read<KeyPairProvider>().listKeyPair();
    setState(() {
      _keyPairs = kps;
      _isBusy = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadKeyPairs();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: ResponsiveScaffold.getIsExpand(context),
      appBar: AppBar(
        title: Text('screenKeyPairs').tr(),
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          ListTile(
            leading: const Icon(Symbols.add),
            title: Text('enrollNewKeyPair').tr(),
            subtitle: Text('enrollNewKeyPairDescription').tr(),
            onTap: () async {
              await context.read<KeyPairProvider>().enrollNew();
              _loadKeyPairs();
            },
          ),
          const Divider(height: 1),
          if (_keyPairs != null)
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: RefreshIndicator(
                  onRefresh: _loadKeyPairs,
                  child: ListView.builder(
                    itemCount: _keyPairs!.length,
                    itemBuilder: (context, index) {
                      final kp = _keyPairs![index];
                      return ListTile(
                        title: Text(kp.id.toUpperCase()),
                        subtitle: Row(
                          spacing: 8,
                          children: [
                            if (kp.privateKey != null)
                              Text(
                                'keyPairHasPrivateKey'.tr(),
                              ),
                            if (kp.privateKey != null) Text('·'),
                            Flexible(
                              flex: 1,
                              child: Text(
                                'UID #${kp.accountId.toString().padLeft(8, '0')}',
                                style: GoogleFonts.robotoMono(),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Symbols.check),
                          onPressed: kp.isActive == true
                              ? null
                              : () async {
                                  final k = context.read<KeyPairProvider>();
                                  await k.activeKeyPair(kp.id);
                                  _loadKeyPairs();
                                },
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
