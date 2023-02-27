import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Tag クラス
class Tag {
  final int? id;
  final String text;
  final int color;
  final int visibleFlg;

  Tag({
    this.id,
    required this.text,
    required this.color,
    required this.visibleFlg,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'color': color,
      'visibleFlg': visibleFlg,
    };
  }

  static Future<Database> get database async {
    final Future<Database> _database = openDatabase(
      join(await getDatabasesPath(), 'record_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "create table tag(id integer primary key autoincrement, text text, color integer, visibleFlg integer)"
        );
      },
      version: 1,
    );
    return _database;
  }

  static Future<void> insertTag(Tag tag) async {
    final Database db = await database;
    await db.insert(
      'tag',
      tag.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Tag>> getTags() async {
    final Database db = await database;
    // visibleFlg = 1 のタグを取得する。
    final List<Map<String, dynamic>> maps = await db.query('tag', where: 'visibleFlg = ?', whereArgs: [1]);
    return List.generate(maps.length, (i) {
      return Tag(
        id: maps[i]['id'],
        text: maps[i]['text'],
        color: maps[i]['color'],
        visibleFlg: maps[i]['visibleFlg'],
      );
    });
  }

  // visibleFlg = 1 を 0 に変換する。
  static Future<void> deleteTag(int i) async {
    final db = await database;
    // await db.update(
    //   'tag',
    //   tag.toMap(),
    //   where: "visibleFlg = ?",
    //   whereArgs: [tag.visibleFlg],
    //   conflictAlgorithm: ConflictAlgorithm.rollback,
    // );
    await db.rawUpdate('update tag set visibleFlg = 0 where id = ?', [i]);
  }

  // データ削除用
  static Future<void> deleteAllTag() async {
    final db = await database;
    await db.rawDelete('delete from tag');
  }
}