import 'package:sqflite/sqflite.dart' as sql;

import '../model/note.dart';

class SqlHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute('''
CREATE TABLE data(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  desc TEXT
)''');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase("data.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTable(database);
    });
  }

  static Future<int> createdata(Note note) async {
    final db = await SqlHelper.db();
    // final data = {'title': title, 'desc': desc};
    final id = await db.insert("data", note.toJson(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    final db = await SqlHelper.db();
    return db.query('data', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getDetail(int id) async {
    final db = await SqlHelper.db();
    return db.query('data', where: 'id=?', whereArgs: [id], limit: 1);
  }

  static Future<int> updatedata(Note note) async {
    final db = await SqlHelper.db();
    // final data = {
    //   'title': title,
    //   'desc': desc,
    // };

    final result = await db
        .update('data', note.toJson(), where: "id=?", whereArgs: [note.id]);
    return result;
  }

  static Future<void> deleteData(int id) async {
    final db = await SqlHelper.db();
    try {
      await db.delete('data', where: "id=?", whereArgs: [id]);
    } catch (e) {}
  }
}
