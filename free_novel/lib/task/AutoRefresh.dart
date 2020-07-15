import 'package:novel/db/BookDesc.dart';
import 'package:novel/db/NovelDatabase.dart';
import 'package:novel/search/BaseSearch.dart';
import 'package:novel/search/SearchFactory.dart';

class AutoRefresh{
  static Future<void> fetchAndUpdateAllBooks() async{
    final List<BookDesc> bookList = await NovelDatabase.getInstance().findAllBooks();
    if(bookList == null || bookList.length == 0){
      print("No books exist.");
    } else {
      bookList.forEach((book) {
        BaseSearch search = SearchFactory.getSearchByType(book.search);
        if(search != null) {
          search.downloadItem(book.bookUrl, book.id);
        }
      });
    }
  }
}