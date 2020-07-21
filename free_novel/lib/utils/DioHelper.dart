import 'dart:io';

import "package:dio/dio.dart";
import 'package:fast_gbk/fast_gbk.dart';

class DioHelper {
  static const ERROR_TYPE_NET = -1;
  static const ERROR_TYPE_OTHER = -2;
  static var header = {
    HttpHeaders.userAgentHeader:
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36',
  };
  static Dio _dio;
  static Dio _createInstance() {
    if (_dio == null) {
      final option = BaseOptions(
          headers: header,
          connectTimeout: 2000,
          receiveTimeout: 3000,
          responseType: ResponseType.json);
      _dio = Dio(option);
    }
    return _dio;
  }

  static void doGet<T>(String url,
      {String method,
        bool needGbk,
        params,
        Function(T t) success,
        Function(int errorType) error}) async {
    if(needGbk) {
      _doGetGbk(url, method:method, params: params, success: success, error: error);
    } else {
      _doGet(url, method:method, params: params, success: success, error: error);
    }
  }

  static void _doGet<T>(String url,
      {String method,
      params,
      Function(T t) success,
      Function(int errorType) error}) async {
    final dio = _createInstance();
    try {
      Response response;
      if (params == null) {
        response = await dio.request(url);
      } else {
        if ('POST' == method) {
          response = await dio.request(url, data: params);
        } else {
          response = await dio.request(url, queryParameters: params);
        }
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

  static void _doGetGbk<T>(String url,
      {String method,
      params,
      Function(T t) success,
      Function(int errorType) error}) async {
    final dio = _createInstance();
    try {
      Response response;
      var options = Options(
          contentType: "application/json; charset=gbk",
          responseDecoder: (msg, opt, bd) => gbk.decode(msg));
      if (params == null) {
        response = await dio.request(url, options:options);
      } else {
        if ('POST' == method) {
          response = await dio.request(url, data: params, options: options);
        } else {
          response = await dio.request(url, queryParameters: params, options: options);
        }
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
