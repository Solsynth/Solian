import 'package:auto_route/auto_route.dart';
import 'package:island/accounts/widgets/account/stellar_program_tab.dart';

@RoutePage()
class StoreScreen extends StellarProgramView {
  const StoreScreen({super.key}) : super(showStoreHeader: true);
}
