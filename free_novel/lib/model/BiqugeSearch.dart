import "package:novel/utils/DioHelper.dart";

class BiqugeSearch{
  static const _BASE_URL = "https://www.xsbiquge.com/search.php";
  static const _searchKey = "keyword";

  static void doSearch<T>(String query, {Function(T t) success, Function(int errorType) error}) async{
    DioHelper.doGet(_BASE_URL, params: {_searchKey: query}, success: success, error: error);
  }
}