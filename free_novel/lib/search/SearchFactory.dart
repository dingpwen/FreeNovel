import 'package:novel/search/BaseSearch.dart';
import 'package:novel/search/BiqugeSearch.dart';
import 'package:novel/utils/SpUtils.dart';

class SearchFactory{
  static const BIQUGE = "biquge";
  static const OTHER = "other";
  static const TYPE_BIQUGE = 0;
  static const TYPE_OTHER = 3;
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

  static BaseSearch getSearchByType(int type) {
    switch(type) {
      case TYPE_BIQUGE:
        return getSearch(BIQUGE);
      default:
        return getSearch(OTHER);
    }
  }

  static Future<BaseSearch> getDefault() async{
    final searchName  = await SpUtils.getSearchName();
    return getSearch(searchName);
  }
}