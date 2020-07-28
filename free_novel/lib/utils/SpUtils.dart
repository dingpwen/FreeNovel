import 'package:shared_preferences/shared_preferences.dart';

class SpUtils{
  static const String _PAGE_KEY = "novel_page";
  static const String _SEARCH_KEY = "search_name";
  static const String _REFRESH_KEY = "refresh_value";

  static Future<int> getSavedPage(int novelId) async{
    SharedPreferences sp  = await SharedPreferences.getInstance();
    final String key = "${_PAGE_KEY}_$novelId";
    return sp.getInt(key);
  }

  static Future<dynamic> savePage(int novelId, int page) async{
    SharedPreferences sp  = await SharedPreferences.getInstance();
    final String key = "${_PAGE_KEY}_$novelId";
    return sp.setInt(key, page);
  }

  static Future<String> getSearchName() async{
    SharedPreferences sp  = await SharedPreferences.getInstance();
    return sp.getString(_SEARCH_KEY);
  }

  static Future<dynamic> saveSearchName(String searchName) async{
    SharedPreferences sp  = await SharedPreferences.getInstance();
    return sp.setString(_SEARCH_KEY, searchName);
  }

  static Future<dynamic> saveRefreshValue(int refreshValue) async{
    SharedPreferences sp  = await SharedPreferences.getInstance();
    return sp.setInt(_REFRESH_KEY, refreshValue);
  }

  static Future<int> getRefreshValue() async{
    SharedPreferences sp  = await SharedPreferences.getInstance();
    return sp.getInt(_REFRESH_KEY);
  }
}