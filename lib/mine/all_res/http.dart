// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/router/routes.dart';
import 'local_storage.dart';

const String APPLICATION_JSON = "application/json";
const String CONTENT_TYPE = "content-type";
const String ACCEPT = "accept";
const String AUTHORIZATION = "authorization";
const String DEFAULT_LANGUAGE = "en";
const String TOKEN = "Bearer token";
const String BASE_URL = "https://api.xnet-api.site";
const String NETWORK_BASE_URL = "https://api.onelight.site/geturl"; // 用于获取基础 URL 的地址

typedef Fail = Function( String msg);

/// woo 电商 api 请求工具类
class WooHttpUtil {
  static final WooHttpUtil _instance = WooHttpUtil._internal();

  factory WooHttpUtil() => _instance;
  late String baseUrl;

  late Dio _dio;

  /// 单例初始
  WooHttpUtil._internal() {
    // header 头
    Map<String, String> headers = {
      CONTENT_TYPE: APPLICATION_JSON,
      ACCEPT: APPLICATION_JSON,
      AUTHORIZATION: TOKEN,
      DEFAULT_LANGUAGE: DEFAULT_LANGUAGE
    };
    // 初始选项
    var options = BaseOptions(
      baseUrl: BASE_URL,
      headers: headers,
      connectTimeout: const Duration(seconds: 10),
      // 5秒
      receiveTimeout: const Duration(seconds: 7),
      // 3秒
      responseType: ResponseType.json,
    );

    // 初始 dio
    _dio = Dio(options);

    // 拦截器 - 日志打印
    if (!kReleaseMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ));
    }

    // 拦截器
    _dio.interceptors.add(RequestInterceptors());
    _fetchBaseUrl();
  }

  Future<void> _fetchBaseUrl() async {
    try {
      Response response = await _dio.get(NETWORK_BASE_URL);
      baseUrl = response.data['url']; // 假设响应中包含 'url' 字段
      _updateDioBaseOptions(); // 更新 Dio 的基础选项
    } catch (e) {
      // 处理获取基础 URL 的错误
      print("获取基础 URL 时发生错误: $e");
      baseUrl = BASE_URL; // 如果需要则回退到默认基础 URL
    }
  }

  void _updateDioBaseOptions() {
    _dio.options.baseUrl = baseUrl;
  }
  /// get 请求
  Future<Response> get(String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    Fail? fail,
  }) async {
    Options requestOptions = options ?? Options();
    try {
      Response response = await _dio.get(
        url,
        options: requestOptions,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      if(fail!=null){
        fail(e.response.toString());
      }
      rethrow;
    }
  }

  /// post 请求
  Future<Response> post(String url, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    Fail? fail,
  }) async {
    var requestOptions = options ?? Options();
    try {
      Response response = await _dio.post(
        url,
        data: data ?? {},
        options: requestOptions,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      if(fail!=null){
        fail(e.response!.data["message"].toString());
      }
      rethrow;
    }
  }

  /// put 请求
  Future<Response> put(String url, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var requestOptions = options ?? Options();
    Response response = await _dio.put(
      url,
      data: data ?? {},
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response;
  }

  /// delete 请求
  Future<Response> delete(String url, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var requestOptions = options ?? Options();
    Response response = await _dio.delete(
      url,
      data: data ?? {},
      options: requestOptions,
      cancelToken: cancelToken,
    );
    return response;
  }
}

/// 拦截
class RequestInterceptors extends Interceptor {
  //

  /// 发送请求
  /// 我们这里可以添加一些公共参数，或者对参数进行加密
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // super.onRequest(options, handler);
   String locale = SpUtil.get("locale");
   if(locale.contains("zh")){
      locale="zh-CN";
   }else{
     locale="en-US";
   }
   print(locale);
    // http header 头加入 Authorization
    options.headers['Authorization'] =SpUtil.get("auth_data")??"";
    options.headers['content-language'] =locale;

    return handler.next(options);
    // 如果你想完成请求并返回一些自定义数据，你可以resolve一个Response对象 `handler.resolve(response)`。
    // 这样请求将会被终止，上层then会被调用，then中返回的数据将是你的自定义response.
    //
    // 如果你想终止请求并触发一个错误,你可以返回一个`DioError`对象,如`handler.reject(error)`，
    // 这样请求将被中止并触发异常，上层catchError会被调用。
  }

  /// 响应
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 200 请求成功, 201 添加成功
    if (response.statusCode != 200 && response.statusCode != 201) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
        true,
      );
    } else {
      handler.next(response);
    }
  }

  // // 退出并重新登录
  // Future<void> _errorNoAuthLogout() async {
  //   await UserService.to.logout();
  //   IMService.to.logout();
  //   Get.toNamed(RouteNames.systemLogin);
  // }

  /// 错误
  @override
  Future<void> onError(DioException err,
      ErrorInterceptorHandler handler) async {
    final exception = HttpException(err.message ?? "error message");
    switch (err.type) {
      case DioExceptionType.badResponse: // 服务端自定义错误体处理
        {
          final response = err.response;
          final errorMessage = ErrorMessageModel.fromJson(
              response!.data as Map<String, dynamic>);
          // ToastUtils.show(errorMessage.message ?? "");
          switch (response.statusCode) {
          // 401 未登录
            case 401:
              const LoginRoute().push(rootNavigatorKey.currentState!.context);

              // 注销 并跳转到登录页面
            // _errorNoAuthLogout();
              break;
            case 404:
              break;
            case 403:
              const LoginRoute().push(rootNavigatorKey.currentState!.context);
              break;
            case 500:
              break;
            case 502:
              break;
            default:
              break;
          }
          // 显示错误信息
          // if(errorMessage.message != null){
          //   Loading.error(errorMessage.message);
          // }
        }
        break;
      case DioExceptionType.unknown:
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.connectionTimeout:
        break;
      default:
        break;
    }
    DioException errNext = err.copyWith(
      error: exception,
    );
    handler.next(errNext);
  }
}

/// 错误体信息
class ErrorMessageModel {

  String? message;

  ErrorMessageModel({this.message});

  factory ErrorMessageModel.fromJson(Map<String, dynamic> json) {
    return ErrorMessageModel(
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'message': message,
      };
}

// /// 错误体信息
// class ErrorMessageModel {
//   int? statusCode;
//   String? error;
//   String? message;
//
//   ErrorMessageModel({this.statusCode, this.error, this.message});
//
//   factory ErrorMessageModel.fromJson(Map<String, dynamic> json) {
//     return ErrorMessageModel(
//       statusCode: json['statusCode'] as int?,
//       error: json['error'] as String?,
//       message: json['message'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'statusCode': statusCode,
//     'error': error,
//     'message': message,
//   };
// }