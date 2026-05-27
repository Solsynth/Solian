import 'package:island/accounts/account_pod.dart';
import 'package:island/core/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'relationship_pod.g.dart';

@riverpod
Future<String?> relationshipAlias(Ref ref, String targetAccountId) async {
  final user = ref.watch(userInfoProvider).value;
  if (user == null) return null;

  final db = ref.watch(databaseProvider);
  final relationship = await db.getRelationshipByAccounts(
    user.id,
    targetAccountId,
  );
  return relationship?.alias;
}
