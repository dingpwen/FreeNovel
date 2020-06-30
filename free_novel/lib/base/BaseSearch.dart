import "package:novel/utils/DioHelper.dart";

abstract class BaseSearch{
  Map<String, dynamic> getParams(String query);
  String getSearchUrl();

  doSearch<T>(String query, {Function(T t) success, Function(int errorType) error}) async{
    DioHelper.doGet(getSearchUrl(), params: getParams(query), success: success, error: error);
  }

  Future<dynamic> parseResult(String response);
}