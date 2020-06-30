import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:novel/model/SearchBookResult.dart';

class HtmlParse{
  static Future<dynamic> parseResult(String response) async {
    var document = parse(response);
    var content = document.querySelector('.result-list');
    List<Element> books = content.querySelectorAll(".result-item");
    List<SearchBookResult> data = [];
    if(books.isNotEmpty){
      data = List.generate(books.length, (i){
        var detail = books[i].querySelector('.result-game-item-detail');
        var itemInfo = detail.querySelector(".result-game-item-info");
        List<Element> infos = itemInfo.querySelectorAll('.result-game-item-info-tag');
        return SearchBookResult(
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
}