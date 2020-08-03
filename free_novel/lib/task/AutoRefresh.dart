import 'dart:async';

import 'package:novel/db/BookDesc.dart';
import 'package:novel/db/NovelDatabase.dart';
import 'package:novel/search/BaseSearch.dart';
import 'package:novel/search/SearchFactory.dart';
import 'package:novel/utils/SpUtils.dart';

class AutoRefresh{
  static Timer _timer;
  static Future<void> fetchAndUpdateAllBooks() async{
    int limit = await SpUtils.getRefreshValue();
    bool top = false;
    if(limit == null) {
      limit = 10;
    } else if(limit == -1){
      top = true;
      limit = 30;
    }
    final List<BookDesc> bookList = await NovelDatabase.getInstance().findAllBooks(limit: limit, top:top);
    if(bookList == null || bookList.length == 0){
      print("No books exist.");
    } else {
      int pos = 0;
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) async{
        if(pos == bookList.length) {
          onComplete();
        } else {
          final book = bookList[pos];
          BaseSearch search = SearchFactory.getSearchByType(book.search);
          if (search != null && search.getDownloadState() != 0) {
            await search.downloadItem(book.bookUrl, book.id);
            ++pos;
          } else if(search == null) {
            ++pos;
          }
        }
      });
      /*bookList.forEach((book) async{
        BaseSearch search = SearchFactory.getSearchByType(book.search);
        search.setGbk(book.gbk == 1);
        if(search != null) {
          await search.downloadItem(book.bookUrl, book.id);
        }
      });*/
    }
  }

  static void onComplete() {
    if(_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }
}