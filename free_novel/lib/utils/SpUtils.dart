import 'package:shared_preferences/shared_preferences.dart';

class SpUtils{
  static const String PAGE_KEY = "novel_page";
  static Future<int> getSavedPage(int novelId) async{
    SharedPreferences sp  = await SharedPreferences.getInstance();
    final String key = "${PAGE_KEY}_$novelId";
    return sp.getInt(key);
  }

  static Future<dynamic> savePage(int novelId, int page) async{
    SharedPreferences sp  = await SharedPreferences.getInstance();
    final String key = "${PAGE_KEY}_$novelId";
    return sp.setInt(key, page);
  }
}