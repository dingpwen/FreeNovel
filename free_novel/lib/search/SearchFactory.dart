import 'BaseSearch.dart';
import 'BiqugeSearch.dart';
import 'OtherSearch.dart';
import 'WxcSearch.dart';
import 'package:novel/utils/SpUtils.dart';

class SearchFactory{
  static const BIQUGE = "biquge";
  static const  WXC = "23wxc";
  static const OTHER = "other";
  static const TYPE_BIQUGE = 0;
  static const TYPE_WXC = 1;
  static const TYPE_OTHER = 2;
  static const TYPE_DEFAULT = 1;
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
      case WXC:
        search = WxcSearch();
        _searchMap[WXC] = search;
        break;
      default:
        search = OtherSearch();
        _searchMap[OTHER] = search;
        break;
    }
    return search;
  }

  static BaseSearch getSearchByType(int type) {
    switch(type) {
      case TYPE_BIQUGE:
        return getSearch(BIQUGE);
      case TYPE_WXC:
        return getSearch(WXC);
      default:
        return getSearch(OTHER);
    }
  }

  static Future<BaseSearch> getDefault() async{
    final searchName  = await SpUtils.getSearchName();
    if(searchName == null || searchName.isEmpty) {
      return getSearchByType(TYPE_DEFAULT);
    } else {
      return getSearch(searchName);
    }
  }
}