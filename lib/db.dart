import 'package:intl/intl.dart';
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
    //DBのパスを消す用のコード 本来はonCreateの後にonUpgradeを使う
    // deleteDatabase(join(await getDatabasesPath(), 'record_database.db'));
    final Future<Database> _database = openDatabase(
      join(await getDatabasesPath(), 'record_database.db'),
      onCreate: (db, version) async {
        // return db.execute(
        //   "create table tag(id integer primary key autoincrement, text text, color integer, visibleFlg integer)"
        // );
        await db.execute(
          "create table tag(id integer primary key autoincrement, text text, color integer, visibleFlg integer)"
        );
        await db.execute(
          "create table record(id integer primary key autoincrement, text text, tagId integer,"
          "year integer, month integer, day integer, hour integer, minute integer, second integer,"
          "endToStartSecond integer, restSecond integer,"
          "foreign key(tagId) references tag(id))"
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
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      // 'select tag.id, tag.text, tag.color, tag.visibleFlg from tag '
      // 'where id = 1 '
      // 'union '
      'select tag.id, tag.text, tag.color, tag.visibleFlg, max(record.id) from tag '
      'left join record on tag.id = record.tagId '
      'where visibleFlg = 1 '
      'group by tag.id, tag.text, tag.color, tag.visibleFlg '
      'order by record.id desc'
    );
    return List.generate(maps.length, (i) {
      return Tag(
        id: maps[i]['id'],
        text: maps[i]['text'],
        color: maps[i]['color'],
        visibleFlg: maps[i]['visibleFlg'],
      );
    });
  }

  static Future<List<Tag>> getAllTags() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tag');
    return List.generate(maps.length, (i) {
      return Tag(
        id: maps[i]['id'],
        text: maps[i]['text'],
        color: maps[i]['color'],
        visibleFlg: maps[i]['visibleFlg'],
      );
    });
  }

  static Future<void> insertOtherTag() async {
    final Database db = await database;
    await db.insert(
      'tag',
      {
        'id': 1,
        'text': 'その他',
        'color': 0xffffffff,
        'visibleFlg': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
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

// Record クラス
class RecordDb {
  final int? id;
  final String text;
  final int tagId;
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;
  final int endToStartSecond;
  final int restSecond;

  RecordDb({
    this.id,
    required this.text,
    required this.tagId,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
    required this.endToStartSecond,
    required this.restSecond,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'tagId': tagId,
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'second': second,
      'endToStartSecond': endToStartSecond,
      'restSecond': restSecond
    };
  }

  //理論場これでもいけると思う！
  static Future<Database> database = Tag.database;

  static Future<void> insertRecord(RecordDb record) async {
    final Database db = await database;
    await db.insert(
      'record',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // static Future<List<RecordDb>> getRecords() async {
  //   final Database db = await database;
  //   final List<Map<String, dynamic>> maps = await db.rawQuery(
  //     // 'select * from record r inner join tag t on r.tagId = t.id'
  //     'select * from record'
  //   );
  //   return List.generate(maps.length, (i) {
  //     return RecordDb(
  //       id: maps[i]['id'],
  //       text: maps[i]['text'],
  //       tagId: maps[i]['tagId'],
  //     );
  //   });
  // }

  // // visibleFlg = 1 を 0 に変換する。
  // static Future<void> deleteRecord(int i) async {
  //   final db = await database;
  //   // await db.update(
  //   //   'Record',
  //   //   Record.toMap(),
  //   //   where: "visibleFlg = ?",
  //   //   whereArgs: [Record.visibleFlg],
  //   //   conflictAlgorithm: ConflictAlgorithm.rollback,
  //   // );
  //   await db.rawUpdate('update Record set visibleFlg = 0 where id = ?', [i]);
  // }

  static Future<void> deleteRecordList(int id) async {
    final db = await database;
    await db.rawDelete('delete from record where id = ?', [id]);
  }

  // データ全削除用
  static Future<void> deleteAllRecord() async {
    final db = await database;
    await db.rawDelete('delete from Record');
  }
}

// RecordDBTagクラス
class RecordDbTag {
  final int? id;
  final String recordText;
  final String tagText;
  final int color;
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final int second;
  final int endToStartSecond;
  final int restSecond;

  RecordDbTag({
    required this.id,
    required this.recordText,
    required this.tagText,
    required this.color,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
    required this.endToStartSecond,
    required this.restSecond,
  });

    Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recordText': recordText,
      'tagText': tagText,
      'color' : color,
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'minute': minute,
      'second': second,
      'endToStartSecond': endToStartSecond,
      'restSecond': restSecond
    };
  }

  //理論場これでもいけると思う！
  static Future<Database> database = Tag.database;

  static Future<List<RecordDbTag>> getAllRecordDbTag() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'select '
      'r.id, r.text as recordText, t.text as tagText, color, '
      'year, month, day, hour, minute, second, '
      'endToStartSecond, restSecond '
      'from record r inner join tag t on r.tagId = t.id order by r.id desc'
    );
    return List.generate(maps.length, (i) {
      return RecordDbTag(
        id: maps[i]['id'],
        recordText: maps[i]['recordText'],
        tagText: maps[i]['tagText'],
        color: maps[i]['color'],
        year: maps[i]['year'],
        month: maps[i]['month'],
        day: maps[i]['day'],
        hour: maps [i]['hour'],
        minute: maps[i]['minute'],
        second: maps[i]['second'],
        endToStartSecond: maps[i]['endToStartSecond'],
        restSecond: maps[i]['restSecond'],
      );
    });
  }

  static Future<List<RecordDbTag>> getAllGraphRecord() async {

    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'select '
      'r.id, r.text as recordText, t.text as tagText, color, '
      'year, month, day, hour, minute, second, '
      'endToStartSecond, restSecond '
      'from record r inner join tag t on r.tagId = t.id '
    );
    return List.generate(maps.length, (i) {
      return RecordDbTag(
        id: maps[i]['id'],
        recordText: maps[i]['recordText'],
        tagText: maps[i]['tagText'],
        color: maps[i]['color'],
        year: maps[i]['year'],
        month: maps[i]['month'],
        day: maps[i]['day'],
        hour: maps [i]['hour'],
        minute: maps[i]['minute'],
        second: maps[i]['second'],
        endToStartSecond: maps[i]['endToStartSecond'],
        restSecond: maps[i]['restSecond'],
      );
    });
  }
}
