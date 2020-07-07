import 'package:novel/db/BookDesc.dart';
import "package:sqflite/sqflite.dart";
import 'package:path/path.dart';
import 'dart:async';
import "package:novel/db/Novel.dart";

class NovelDatabase {
  final Future<Database> database = _getDataBase();
  static NovelDatabase _novelDatabase;
  static NovelDatabase getInstance() {
    if (_novelDatabase == null) {
      _novelDatabase = new NovelDatabase();
    }
    return _novelDatabase;
  }

  static Future<Database> _getDataBase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'novel_database.db'),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE books(id INTEGER PRIMARY KEY AUTOINCREMENT, bookName TEXT, bookUrl TEXT, author TEXT, lastUrl  TEXT, lastTitle TEXT, type TEXT, bookCover TEXT, bookDesc TEXT, status INTEGER DEFAULT(0))");
        db.execute(
            "CREATE TABLE novel(id INTEGER, page INTEGER, title TEXT, content TEXT, url TEXT, status INTEGER DEFAULT(0), PRIMARY KEY(id,page))");
      },
      version: 1,
    );
  }

  Future<void> insertNovel(Novel novel) async {
    final Database db = await database;
    await db.insert(
      'novel',
      novel.toJson(),
      // 插入冲突策略，新的替换旧的
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Novel>> findNovelById(int id, {int order = 0}) async {
    final Database db = await database;
    List<Map<String, dynamic>> result;
    if (order == 0) {
      result = await db.query('novel', where: "id=?", whereArgs: [id], orderBy: "page asc");
    } else {
      result = await db.query('novel', where: "id=?", whereArgs: [id], orderBy: "page desc");
    }
    List<Novel> novels = [];
    if (result != null) {
      novels = List.generate(result.length, (index) {
        return Novel.fromJson(result[index]);
      });
    }
    return novels;
  }

  Future<dynamic> getNovelContent(int id, int page) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
        "select content from novel where id=? and page=?", [id, page]);
    if (result != null && result.length > 0) {
      return result[0]['content'];
    }
    return null;
  }

  Future<dynamic> updateNovelContent(int id, int page, String content) async {
    final Database db = await database;
    return db.update(
      'novel',
      {'content': content, 'status': 1},
      where: 'id=? and page=?',
      whereArgs: [id, page],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertBook(BookDesc book) async {
    final Database db = await database;
    return db.insert(
      'books',
      book.toJson(),
      // 插入冲突策略，新的替换旧的
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BookDesc>> findAllBooks() async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query("books");
    List<BookDesc> books = [];
    if (result != null) {
      books = List.generate(result.length, (index) {
        return BookDesc.fromJson(result[index]);
      });
    }
    return books;
  }

  Future<dynamic> findBookFromUrl(String url) async {
    final Database db = await database;
    List<Map<String, dynamic>> result =
        await db.rawQuery("select * from books where bookUrl=?", [url]);
    if (result != null && result.length > 0) {
      return BookDesc.fromJson(result[0]);
    }
    return null;
  }
}
