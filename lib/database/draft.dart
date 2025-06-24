import 'package:drift/drift.dart';

class ComposeDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get attachmentIds => text().withDefault(const Constant('[]'))(); // JSON array as string
  TextColumn get visibility => text().withDefault(const Constant('public'))();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ArticleDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get visibility => text().withDefault(const Constant('public'))();
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}