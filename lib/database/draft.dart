import 'package:drift/drift.dart';

class PostDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get post => text()(); // Store SnPost model as JSON string
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
