import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart' as dio;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/all_data_model.dart';
import 'package:restaurant_system/networks/api_url.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/utils.dart';

class RestApi {
  static final dio.Dio _dio = dio.Dio(dio.BaseOptions(
    baseUrl: baseURL,
    connectTimeout: 30000,
    receiveTimeout: 30000,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${mySharedPreferences.accessToken}',
    }
  ));

  static void _traceError(dio.DioError e) {
    String trace = '════════════════════════════════════════ \n'
        '╔╣ Dio [ERROR] info ==> \n'
        '╟ BASE_URL: ${e.requestOptions.baseUrl}\n'
        '╟ PATH: ${e.requestOptions.path}\n'
        '╟ Method: ${e.requestOptions.method}\n'
        '╟ Params: ${e.requestOptions.queryParameters}\n'
        '╟ Body: ${e.requestOptions.data}\n'
        '╟ Header: ${e.requestOptions.headers}\n'
        '╟ statusCode: ${e.response == null ? '' : e.response!.statusCode}\n'
        '╟ RESPONSE: ${e.response == null ? '' : e.response!.data} \n'
        '╟ stackTrace: ${e.stackTrace} \n'
        '╚ [END] ════════════════════════════════════════╝';
    developer.log(trace);
  }

  static void _traceCatch(e) {
    String trace = '════════════════════════════════════════ \n'
        '╔╣ Dio [Catch] info ==> \n'
        '╟ Runtime Type: ${e.runtimeType}\n'
        '╟ Catch: ${e.toString()}\n'
        '╚ [END] ════════════════════════════════════════╝';
    developer.log(trace);
  }

  static void _networkLog(dio.Response response) {
    String trace = '════════════════════════════════════════ \n'
        '╔╣ Dio [RESPONSE] info ==> \n'
        '╟ BASE_URL: ${response.requestOptions.baseUrl}\n'
        '╟ PATH: ${response.requestOptions.path}\n'
        '╟ Method: ${response.requestOptions.method}\n'
        '╟ Params: ${response.requestOptions.queryParameters}\n'
        '╟ Body: ${response.requestOptions.data}\n'
        '╟ Header: ${response.requestOptions.headers}\n'
        '╟ statusCode: ${response.statusCode}\n'
        '╟ RESPONSE: ${jsonEncode(response.data)} \n'
        '╚ [END] ════════════════════════════════════════╝';
    developer.log(trace);
  }

  static Future<void> getData() async {
    try {
      showLoadingDialog();
      final response = await _dio.get(ApiUrl.GET_DATA);
      _networkLog(response);
      if(response.statusCode == 200){
        mySharedPreferences.allData = jsonEncode(response.data);
        allDataModel = AllDataModel.fromJson(response.data);
      } else {
        allDataModel = AllDataModel.fromJson(jsonDecode(mySharedPreferences.allData));
      }
      hideLoadingDialog();
    } on dio.DioError catch (e) {
      _traceError(e);
      allDataModel = AllDataModel.fromJson(jsonDecode(mySharedPreferences.allData));
      hideLoadingDialog();
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      allDataModel = AllDataModel.fromJson(jsonDecode(mySharedPreferences.allData));
      hideLoadingDialog();
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }
}
