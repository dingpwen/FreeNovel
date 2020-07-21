
import 'package:html/dom.dart';
import 'BaseSearch.dart';
import 'SearchFactory.dart';

class OtherSearch extends BaseSearch{
  int _type =  SearchFactory.TYPE_OTHER;

  @override
  int getSearchType() {
    // TODO: implement getSearchType
    return _type;
  }

  void setSearchType(int type){
    _type = type;
  }

  @override
  String getBaseUrl() {
    // TODO: implement getBaseUrl
    throw UnimplementedError();
  }

  @override
  Map<String, String> getContentParams() {
    // TODO: implement getContentParams
    throw UnimplementedError();
  }

  @override
  Map<String, String> getItemParams() {
    // TODO: implement getItemParams
    throw UnimplementedError();
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
  dynamic parseContent(Element element) {
    // TODO: implement parseContent
    throw UnimplementedError();
  }

  @override
  dynamic parseItemContent(Element element) {
    // TODO: implement parseItemContent
    throw UnimplementedError();
  }

  @override
  Future parseResult(String query) {
    // TODO: implement parseResult
    throw UnimplementedError();
  }

}