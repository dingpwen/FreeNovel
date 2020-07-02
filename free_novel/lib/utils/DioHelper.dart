import "package:dio/dio.dart";
import "dart:async";

class DioHelper{
  static const ERROR_TYPE_NET = -1;
  static const ERROR_TYPE_OTHER = -2;
  static var header = {
    'user-agent' : 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) '+
        'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36',
  };
  static Dio _dio;
  static Dio _createInstance() {
    if (_dio == null) {
      final option = BaseOptions(
        headers: header,
          connectTimeout: 2000, receiveTimeout: 3000, responseType: ResponseType.json);
      _dio = Dio(option);
    }
    return _dio;
  }

  static void doGet<T>(String url,
      {params, Function(T t) success, Function(int errorType) error}) async {
    final dio = _createInstance();
    try {
      Response response;
      if(params == null) {
        response = await dio.request(url);
      } else {
        response = await dio.request(url, queryParameters: params);
      }
      if (response.statusCode == 200) {
        if (success != null) {
          success(response.data);
        }
      } else {
        if (error != null) {
          error(ERROR_TYPE_NET);
        }
      }
    } on DioError catch (e) {
      print(e.toString());
      if (error != null) {
        error(ERROR_TYPE_OTHER);
      }
    }
  }
}