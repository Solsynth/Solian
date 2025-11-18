// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:island/database/drift_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'generated/schema.dart';

import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test('migration from v6 to v7 does not corrupt data', () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // TODO: Fill these lists
    final oldChatMessagesData = <v6.ChatMessagesData>[];
    final expectedNewChatMessagesData = <v7.ChatMessagesData>[];

    final oldPostDraftsData = <v6.PostDraftsData>[];
    final expectedNewPostDraftsData = <v7.PostDraftsData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 6,
      newVersion: 7,
      createOld: v6.DatabaseAtV6.new,
      createNew: v7.DatabaseAtV7.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.chatMessages, oldChatMessagesData);
        batch.insertAll(oldDb.postDrafts, oldPostDraftsData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewChatMessagesData,
          await newDb.select(newDb.chatMessages).get(),
        );
        expect(
          expectedNewPostDraftsData,
          await newDb.select(newDb.postDrafts).get(),
        );
      },
    );
  });
}
