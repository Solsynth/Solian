import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:island/accounts/widgets/account/stellar_program_tab.dart';
import 'package:island/shared/widgets/app_scaffold.dart';

@RoutePage()
class StellarProgramScreen extends StatelessWidget {
  const StellarProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('stellarProgram'.tr()),
        leading: const AutoLeadingButton(),
      ),
      body: const StellarProgramView(),
    );
  }
}
