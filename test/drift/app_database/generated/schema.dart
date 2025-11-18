// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';
import 'package:drift/internal/migrations.dart';
import 'schema_v6.dart' as v6;
import 'schema_v7.dart' as v7;

class GeneratedHelper implements SchemaInstantiationHelper {
  @override
  GeneratedDatabase databaseForVersion(QueryExecutor db, int version) {
    switch (version) {
      case 6:
        return v6.DatabaseAtV6(db);
      case 7:
        return v7.DatabaseAtV7(db);
      default:
        throw MissingSchemaException(version, versions);
    }
  }

  static const versions = const [6, 7];
}
