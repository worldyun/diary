import 'dart:convert';
import 'dart:io';

import 'package:diary/api/Api.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import 'MyToast.dart';

class HttpUtil {
  static Dio _dio;

  static dynamic post(String api, {Map data}) async {
    _dio = Dio(BaseOptions(
      baseUrl: serverApi["url"],
      connectTimeout: 5000,
      receiveTimeout: 100000,
      headers: {
        HttpHeaders.userAgentHeader: "dio",
        "api": "1.0.0",
      },
      contentType: Headers.jsonContentType,
      responseType: ResponseType.plain,
    ));

    await _getLocalFile();

    try {
      Response response = await HttpUtil._dio.post(
        serverApi[api],
        data: data,
        // Send data with "application/x-www-form-urlencoded" format
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      // print("server msg: ${response.data}");
      //  MyToast.showToast(response.data);
      if(response.data.length == 0){
        return null;
      }
      return json.decode(response.data);
    } on DioError catch (e) {
      if (e.response != null) {
        MyToast.showToast("Http错误：${e.response.statusCode}");
        print(e.response.data);
      } else {
        MyToast.showToast("未知错误");
      }
      return null;
    }
  }

  static void _getLocalFile() async {
    // 获取文档目录的路径
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dir = appDocDir.path + "/.cookies/";
    // print(dir);
    var cookieJar = PersistCookieJar(dir: dir);
    _dio.interceptors.add(CookieManager(cookieJar));
  }
}
