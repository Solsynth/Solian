import 'package:island/data/database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

AppDatabase constructDb() {
  final directoryPathFuture = getDatabaseDirectoryPath();
  final legacyDirectoryPath = getApplicationSupportDirectory().then(
    (baseDir) => p.join(baseDir.path, 'objectbox'),
  );
  return AppDatabase.native(
    directoryPathFuture,
    legacyDirectoryPath: legacyDirectoryPath,
  );
}
