import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'views/item.dart';

const String sqlCreateHistory =
    "CREATE TABLE historyApps(pkg TEXT PRIMARY KEY, weight INTEGER)";

class FirmDB {
  late Future<Database> database;

  FirmDB._create();

  static Future<FirmDB> load() async {
    var firmdb = FirmDB._create();

    firmdb.database = openDatabase(
      join(await getDatabasesPath(), 'firmus.db'),
      onCreate: (db, version) {
        return db.execute(sqlCreateHistory);
      },
      version: 1,
    );

    return firmdb;
  }

  Future<List<String>> getHistory() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query("historyApps", orderBy: 'weight');

    return List.generate(maps.length, (i) {
      return maps[i]["pkg"];
    });
  }

  Future<void> updateHistory(ItemView app, int weight) async {
    final Database db = await database;
    await db.update(
      'historyApps',
      {'weight': weight},
      where: "pkg = ?",
      whereArgs: [app.packageName],
    );
  }
}
