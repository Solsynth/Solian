import 'package:drift/drift.dart';

class ComposeDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get attachmentIds => text().withDefault(const Constant('[]'))(); // JSON array as string
  IntColumn get visibility => integer().withDefault(const Constant(0))(); // 0=public, 1=unlisted, 2=friends, 3=selected, 4=private
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ArticleDrafts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  IntColumn get visibility => integer().withDefault(const Constant(0))(); // 0=public, 1=unlisted, 2=friends, 3=private
  DateTimeColumn get lastModified => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}