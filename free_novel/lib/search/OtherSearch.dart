import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:novel/db/BookDesc.dart';
import 'package:novel/db/Novel.dart';
import 'package:novel/db/NovelDatabase.dart';
import 'BaseSearch.dart';
import 'SearchFactory.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fast_gbk/fast_gbk.dart';

class OtherSearch extends BaseSearch{
  bool _isGbk = false;
  String _baseUrl;
  BookDesc _book;
  Novel _novel;
  int _curMode = 0;

  @override
  int getSearchType() {
    return SearchFactory.TYPE_OTHER;
  }

  setGbk(bool isGbk) {
    _isGbk = isGbk;
  }

  @override
  bool needGbk() {
    return _isGbk;
  }

  @override
  String getBaseUrl() {
    return _baseUrl;
  }

  @override
  Map<String, String> getContentParams() {
    return {};
  }

  @override
  Map<String, String> getItemParams() {
    return {};
  }

  Future<dynamic> parseItem(String response, final int novelId) async {
    _book = await NovelDatabase.getInstance().findBookFromId(novelId);
    _curMode = 0;
    await super.parseItem(response, novelId);
  }

  @override
  List<Element> getTargetElement(
      String response, Map<String, dynamic> params){
    if(_curMode == 1) {
      return _getTargetElement(response);
    }
    var document = parse(response);
    if(document.head.innerHtml.contains('charset=gbk')){
      _isGbk = true;
      //response = Utf8Decoder(allowMalformed: true).convert(response.codeUnits);
      //document = parse(response);
    }
    print('response:${response.substring(0,800)}');
    String title = document.head.querySelector('title').text.trim();
    int start = title.indexOf('(');
    int endPos = title.indexOf('最新');
    if(endPos > start && start > 0) {
      endPos = start;
    }
    String name = (endPos > 0)?title.substring(0, endPos):'';
    String author = (start > 0)?title.substring(start + 1, title.indexOf(')')):'';
    print("name:$name author:$author");
    if(_book != null) {
      NovelDatabase.getInstance().updateBookContent(
          _book.id, name, author);
    }

    int pos = response.indexOf('第一章');
    if(pos < 0) {
      pos = response.indexOf('第1章');
      if(pos< 0) {
        return [];
      }
    }
    String sub = response.substring(0, pos);
    pos = sub.lastIndexOf('id=\"');
    sub = sub.substring(pos + 4);
    pos = sub.indexOf('\"');
    String pid = sub.substring(0, pos);
    print("pid:$pid");
    Element pElement = document.getElementById(pid);
    final List<Element> elementList =  pElement.querySelectorAll(_findPath(pElement));
    if(elementList != null && elementList.length > 0){
      final itemContent = parseItemContent(elementList[0]);
      String url = itemContent[BaseSearch.ITEM_URL];
      endPos = url.lastIndexOf('/');
      if(_book != null) {
        pos = _book.bookUrl.lastIndexOf('/');
        if(endPos == -1) {
          pos = _book.bookUrl.lastIndexOf('/');
          _baseUrl = _book.bookUrl.substring(0, pos + 1);
        } else {
          url =url.substring(0, endPos + 1);
          pos = _book.bookUrl.lastIndexOf(url);
          _baseUrl = _book.bookUrl.substring(0, pos);
        }
      }
    }
    return elementList;
  }

  String _findPath(Element element) {
    String inner = element.innerHtml;
    int pos = inner.indexOf('第一章');
    if(pos<0) {
      pos = inner.indexOf('第1章');
    }
    int endMark = 0;
    String path = '';
    while(pos > 0) {
      if(inner[pos] == '<') {
        if(inner[pos + 1] == '/'){
          ++endMark;
        } else if(endMark > 0) {
          --endMark;
        } else {
          String name = _findPathName(inner, pos);
          path = '>$name$path';
        }
      }
      --pos;
    }
    print('path:$path');
    return path.substring(1);
  }

  String _findPathName(String inner, int pos) {
    int i = pos;
    for(; i<inner.length; ++i) {
      if(inner[i] == ' ' || inner[i] == '>'){
        break;
      }
    }
    return inner.substring(pos + 1, i);
  }

  List<Element> _getTargetElement(
      String response){
    var document = parse(response);
    String inner = document.body.innerHtml;
    int pos = inner.indexOf(_novel.title);
    print('title:${_novel.title}  pos:$pos');
    if(pos<0) {
      return [document.body];
    }
    String sub = inner.substring(pos);
    pos = sub.indexOf('id=');
    sub = sub.substring(pos + 4);
    pos = sub.indexOf('\"');
    String cid = sub.substring(0, pos);
    return [document.getElementById(cid)];
  }

  @override
  dynamic parseContentResponse(
      String response, Novel novel) {
    _curMode = 1;
    _novel = novel;
    return super.parseContentResponse(response, novel);
  }

  @override
  Map<String, String> getParams(dynamic query) {
    // TODO: implement getParams
    throw UnimplementedError();
  }

  @override
  String getSearchUrl() {
    // TODO: implement getSearchUrl
    throw UnimplementedError();
  }

  @override
  Future parseResult(String query) {
    // TODO: implement parseResult
    throw UnimplementedError();
  }

}