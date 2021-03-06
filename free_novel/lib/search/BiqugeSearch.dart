import 'BaseSearch.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:novel/db/BookDesc.dart';
import 'SearchFactory.dart';

class BiqugeSearch extends BaseSearch{
  static const _SEARCH_URL = "https://www.xsbiquge.com/search.php";
  static const _searchKey = "keyword";

  @override
  Map<String, String> getParams(dynamic query) {
    return {_searchKey: query};
  }

  @override
  String getSearchUrl() {
    return _SEARCH_URL;
  }

  @override
  int getSearchType() {
    // TODO: implement getSearchType
    return SearchFactory.TYPE_BIQUGE;
  }

  @override
  String getBaseUrl(){
    return "https://www.xsbiquge.com";
  }

  Future<dynamic> parseResult(String response) async {
    var document = parse(response);
    List<Element> books = document.querySelectorAll(".result-item");
    List<BookDesc> data = [];
    if(books != null && books.isNotEmpty){
      data = List.generate(books.length, (i){
        var detail = books[i].querySelector('.result-game-item-detail');
        var itemInfo = detail.querySelector(".result-game-item-info");
        List<Element> infos = itemInfo.querySelectorAll('.result-game-item-info-tag');
        return BookDesc(
            detail.querySelectorAll('.result-item-title>a>span')[0].text.trim(),
            detail.querySelector('.result-item-title>a').attributes['href'].trim(),
            infos[0].querySelectorAll('span')[1].text.trim(),
            infos[3].querySelector('a').attributes['href'].trim(),
            infos[3].querySelector('a').text.trim(),
            infos[1].querySelectorAll('span')[1].text.trim(),
            books[i].querySelector("div>a>img").attributes['src'].trim(),
            detail.querySelector('.result-game-item-desc').text.trim()
        );
      });
    }
    return data;
  }

  @override
  Map<String, dynamic> getItemParams(){
    return {BaseSearch.ITEM_ID: "list", BaseSearch.ITEM_PATH:"dl>dd>a"};
  }

  @override
  Map<String, dynamic> getContentParams(){
    return {BaseSearch.ITEM_ID: "content"};
  }
}