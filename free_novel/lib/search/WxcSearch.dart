import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:novel/db/BookDesc.dart';
import 'BaseSearch.dart';
import 'SearchFactory.dart';
import 'package:fast_gbk/fast_gbk.dart';

class WxcSearch extends BaseSearch {
  static const _SEARCH_URL = "https://www.23wxc.com/modules/article/search.php";
  static const _searchKey = "searchkey";
  final platform = const MethodChannel("org.wen.icude/my");
  String _url;
  String _baseUrl;

  @override
  String getSearchUrl(){
    return _url;
  }

  /*String getMethod() {
    return 'POST';
  }*/

  @override
  bool needGbk() {
    return true;
  }

  @override
  dynamic getParams(String query) {
    //return FormData.fromMap({'searchtype':'articlename', _searchKey: query});
    //return {'searchtype':'articlename', _searchKey: query};
    return null;
  }

  doSearch<T>(String query,
      {Function(T t) success, Function(int errorType) error}) async {
    try {
      var response = await platform.invokeMethod("gbk", {"content":query});
      _url = _SEARCH_URL + "?" + _searchKey + "=" + response;
      print("url:$_url");
    } on PlatformException catch(e) {
      print(e.toString());
    }
    super.doSearch(query, success:success, error:error);
  }

  @override
  Future parseResult(String response) async {
    //print("response:$response");
    _baseUrl = null;
    var document = parse(response);
    var list = document.getElementById('content');
    List<Element> books = list.querySelectorAll("table>tbody>tr");
    List<BookDesc> data = [];
    if (books != null && books.isNotEmpty) {
      for (int i = 0; i < books.length; ++i) {
        List<Element> infos = books[i].querySelectorAll('td');
        if (infos == null || infos.length == 0) {
          continue;
        }
        //this.bookName, this.bookUrl, this.author, this.lastUrl,
        //this.lastTitle, this.type, this.bookCover, this.bookDesc
        final url = infos[1].querySelector('a').attributes['href'].trim();
        int last = url.lastIndexOf('/');
        if(_baseUrl == null){
          _baseUrl = url.substring(0, last + 1);
        }
        var imageUrl = url
            .replaceAll('https://www.23wxc.com/',
                'https://www.23wxc.com/files/article/image/')
            .replaceAll("/index.html", '');
        last = imageUrl.lastIndexOf('/');
        imageUrl = imageUrl + imageUrl.substring(last) + 's.jpg';
        BookDesc book = BookDesc(
            infos[0].querySelector('a').text.trim(),//bookName
            url,//bookUrl
            infos[2].text.trim(),//author
            url,//lastUrl
            infos[1].querySelector('a').text.trim(),//lastTitle
            "",//type
            imageUrl,//bookCover
            "");//bookDesc
        data.add(book);
      }
    }
    return data;
  }

  @override
  int getSearchType() {
    // TODO: implement getSearchType
    return SearchFactory.TYPE_WXC;
  }

  @override
  String getBaseUrl() {
    return _baseUrl;
  }

  @override
  Map<String, String> getItemParams() {
    return {BaseSearch.ITEM_ID: "at", BaseSearch.ITEM_PATH:"tbody>tr>td>a"};
  }

  @override
  dynamic parseItemContent(Element element) {
    String url = element.attributes['href'].trim();
    String content = element.text.trim();
    return {BaseSearch.ITEM_URL:url, BaseSearch.ITEM_TITLE:content};
  }

  @override
  Map<String, String> getContentParams() {
    return {BaseSearch.ITEM_ID: "contents"};
  }
}
