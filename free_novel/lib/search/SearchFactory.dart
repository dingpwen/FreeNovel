import 'package:novel/search/BaseSearch.dart';
import 'package:novel/search/BiqugeSearch.dart';

class SearchFactory{
  static const BIQUGE = "biquge";
  static Map<String, BaseSearch> _searchMap = {};

  static BaseSearch getSearch(String name) {
    if(_searchMap.containsKey(name)) {
      return _searchMap[name];
    }
    BaseSearch search;
    switch(name) {
      case BIQUGE:
        search = BiqugeSearch();
        _searchMap[BIQUGE] = search;
        break;
      default:
        break;
    }
    return search;
  }
}