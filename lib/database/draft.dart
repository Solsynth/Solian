import 'package:drift/drift.dart';

class PostDrafts extends Table {
  TextColumn get id => text()();
  // Searchable fields stored separately for performance
  TextColumn get title => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get content => text().nullable()();
  IntColumn get visibility => integer().withDefault(const Constant(0))();
  IntColumn get type => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastModified => dateTime()();
  // Full post data stored as JSON for complete restoration
  TextColumn get postData => text()();

  @override
  Set<Column> get primaryKey => {id};
}
