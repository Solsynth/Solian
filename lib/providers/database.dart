import 'package:flutter/material.dart';
import 'package:surface/database/database.dart';

class DatabaseProvider {
  late final AppDatabase db;

  DatabaseProvider(BuildContext context) {
    db = AppDatabase();
  }
}