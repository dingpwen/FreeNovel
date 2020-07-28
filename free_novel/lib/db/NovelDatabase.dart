import 'package:novel/db/BookDesc.dart';
import "package:sqflite/sqflite.dart";
import 'package:path/path.dart';
import 'dart:async';
import "package:novel/db/Novel.dart";

import 'SearchDesc.dart';

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
            "CREATE TABLE books(id INTEGER PRIMARY KEY AUTOINCREMENT, bookName TEXT, bookUrl TEXT, author TEXT, lastUrl  TEXT, lastTitle TEXT, type TEXT, bookCover TEXT, bookDesc TEXT, status INTEGER DEFAULT(0), search status INTEGER DEFAULT(0))");
        db.execute(
            "CREATE TABLE novel(id INTEGER, page INTEGER, title TEXT, content TEXT, url TEXT, status INTEGER DEFAULT(0), PRIMARY KEY(id,page))");
        db.execute(
            "CREATE TABLE search(id INTEGER PRIMARY KEY AUTOINCREMENT, pid TEXT, path TEXT, myid TEXT)");
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

  Future<void> insertNovels(List<Novel> novelList) async {
    final Database db = await database;
    var batch = db.batch();
    novelList.forEach((novel) {
      batch.insert(
        'novel',
        novel.toJson(),
        // 插入冲突策略，新的替换旧的
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit();
  }

  Future<List<Novel>> findNovelById(int id, {int order = 0}) async {
    final Database db = await database;
    List<Map<String, dynamic>> result;
    if (order == 0) {
      result = await db.query('novel',
          columns: ['id', 'page', 'title', 'status'],
          where: "id=?",
          whereArgs: [id],
          orderBy: "page asc");
    } else {
      result = await db.query('novel',
          columns: ['id', 'page', 'title', 'status'],
          where: "id=?",
          whereArgs: [id],
          orderBy: "page desc");
    }
    List<Novel> novels = [];
    if (result != null) {
      novels = List.generate(result.length, (index) {
        return Novel.fromJsonNoContent(result[index]);
      });
    }
    return novels;
  }

  Future<dynamic> getNovelContent(int id, int page) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db
        .rawQuery("select * from novel where id=? and page=?", [id, page]);
    if (result != null && result.length > 0) {
      return Novel.fromJson(result[0]);
    }
    return null;
  }

  Future<dynamic> getNovelMaxPage(int id, {int status = -1}) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = [];
    if (status == -1) {
      result = await db.query('novel',
          where: "id=?", whereArgs: [id], orderBy: "page desc", limit: 1);
    } else {
      result = await db.query('novel',
          where: "id=? and status=?",
          whereArgs: [id, status],
          orderBy: "page desc",
          limit: 1);
    }
    if (result != null && result.length > 0) {
      return Novel.fromJson(result[0]);
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

  Future<dynamic> deleteBook(int id) async {
    final Database db = await database;
    return db.delete('books', where: "id=?", whereArgs: [id]);
  }

  Future<List<BookDesc>> findAllBooks({int limit, bool top = false}) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query("books",
        where: top ? 'status=1' : null,
        orderBy: "status desc, id desc",
        limit: limit);
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

  Future<dynamic> findBookFromId(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query('books',
        where: 'id=?',
        whereArgs: [id]);
    if (result != null && result.length > 0) {
      return BookDesc.fromJson(result[0]);
    }
    return null;
  }

  Future<dynamic> updateBookStatus(int id, int status) async {
    final Database db = await database;
    return db.update(
      'books',
      {'status': status},
      where: 'id=?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<dynamic> updateBookLast(
      int id, String lastTitle, String lastUrl) async {
    final Database db = await database;
    return db.update(
      'books',
      {'lastTitle': lastTitle, 'lastUrl': lastUrl},
      where: 'id=?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<dynamic> updateBookContent(
      int id, String name, String author) async {
    final Database db = await database;
    return db.update(
      'books',
      {'bookName': name, 'author': author},
      where: 'id=?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /********************** other search part*******************************/
  Future<int> insertSearch(SearchDesc searchDesc) async {
    final Database db = await database;
    return db.insert(
      'search',
      searchDesc.toJson(),
      // 插入冲突策略，新的替换旧的
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<SearchDesc> findSearch(String pid, String path, String myid) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query('search',
        where: 'pid=? and path=? and myid=?',
        whereArgs: [pid, path, myid]);
    if(result != null && result.length != 0) {
      return SearchDesc.fromJson(result[0]);
    }
    return null;
  }

  Future<SearchDesc> findSearchById(int id) async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.query('search',
        where: 'id=?',
        whereArgs: [id]);
    if(result != null && result.length != 0) {
      return SearchDesc.fromJson(result[0]);
    }
    return null;
  }
}
