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

  Future<List<ItemView>> get() async {
    final Database db = await database;

    final List<Map<String, dynamic>> maps = await db.query("cachedApps");

    return List.generate(maps.length, (i) {
      return ItemView(
        packageName: maps[i]["pkg"],
        label: maps[i]["label"],
        icon: maps[i]["icon"],
        type: ItemViewType.app,
      );
    });
  }

  Future<void> updateApp(ItemView app) async {
    final Database db = await database;
    await db.update(
      'cachedApps',
      {'label': app.label, 'icon': ''}, //TODO: add BASE64 image storage
      where: "pkg = ?",
      whereArgs: [app.packageName],
    );
  }

  Future<void> updateApps(List<ItemView> apps) async {
    final Database db = await database;
    Batch batch = db.batch();

    for (var app in apps) {
      batch.insert(
        'cachedApps',
        {
          'pkg': app.packageName,
          'label': app.label,
          'icon': ''
        }, //TODO: add BASE64 image storage
      );
    }

    await batch.commit(noResult: true);
  }
}
