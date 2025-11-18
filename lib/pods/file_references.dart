import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/models/reference.dart';
import 'package:island/pods/network.dart';

part 'file_references.g.dart';

@riverpod
Future<List<Reference>> fileReferences(
  FileReferencesRef ref,
  String fileId,
) async {
  final client = ref.read(apiClientProvider);
  final response = await client.get('/drive/files/$fileId/references');
  final list = response.data as List<dynamic>;
  return list
      .map((json) => Reference.fromJson(json as Map<String, dynamic>))
      .toList();
}
