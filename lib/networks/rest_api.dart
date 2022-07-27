import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart' as dio;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/database/network_table.dart';
import 'package:restaurant_system/models/all_data_model.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/networks/api_url.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enum_in_out_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/utils.dart';

class RestApi {
  static final dio.Dio restDio = dio.Dio(dio.BaseOptions(
    baseUrl: mySharedPreferences.baseUrl,
    connectTimeout: 30000,
    receiveTimeout: 30000,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${mySharedPreferences.accessToken}',
    },
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

  static Future<void> uploadNetworkTable(NetworkTableModel model) async {
    try {
      final dio.Dio uploadNetworkTableDio = dio.Dio(dio.BaseOptions(
        baseUrl: model.baseUrl,
        connectTimeout: 30000,
        receiveTimeout: 30000,
        headers: model.headers.isEmpty
            ? {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${mySharedPreferences.accessToken}',
              }
            : jsonDecode(model.headers),
      ));
      late dio.Response response;
      switch (model.method) {
        case "GET":
          response = await uploadNetworkTableDio.get(
            model.path,
            queryParameters: model.params.isEmpty ? null : jsonDecode(model.params),
          );
          break;
        case 'POST':
          response = await uploadNetworkTableDio.post(
            model.path,
            data: model.body,
            queryParameters: model.params.isEmpty ? null : jsonDecode(model.params),
          );
          break;
        default:
          response = await uploadNetworkTableDio.get('');
          break;
      }
      _networkLog(response);
      if (response.statusCode == 200) {
        var networkModel = await NetworkTable.queryById(id: model.id);
        if (networkModel != null) {
          networkModel.status = 2;
          networkModel.uploadedAt = DateTime.now().microsecondsSinceEpoch;
          await NetworkTable.update(networkModel);
        }
      }
    } on dio.DioError catch (e) {
      _traceError(e);
    } catch (e) {
      _traceCatch(e);
    }
  }

  static Future<void> getData() async {
    try {
      showLoadingDialog();
      final response = await restDio.get(ApiUrl.GET_DATA);
      _networkLog(response);
      if (response.statusCode == 200) {
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

  static Future<void> invoice(CartModel cart) async {
    try {
      var body = jsonEncode({
        "InvoiceMaster": cart.toInvoice(),
        "InvoiceDetails": List<dynamic>.from(cart.items.where((element) => !element.isDeleted).map((e) => e.toInvoice())).toList(),
      });
      await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'INVOICE',
        status: 1,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.INVOICE,
        method: 'POST',
        params: '',
        body: body,
        headers: '',
        createdAt: DateTime.now().microsecondsSinceEpoch,
        uploadedAt: DateTime.now().microsecondsSinceEpoch,
      ));
      final response = await restDio.post(ApiUrl.INVOICE, data: body);
      _networkLog(response);
      if (response.statusCode == 200) {
        var networkModel = await NetworkTable.queryLastRow();
        if (networkModel != null) {
          networkModel.status = 2;
          networkModel.uploadedAt = DateTime.now().microsecondsSinceEpoch;
          await NetworkTable.update(networkModel);
        }
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }

  static Future<void> payInOut({required double value, required int type, String remark = ''}) async {
    try {
      var body = jsonEncode({
        "CoYear": DateTime.now().year,
        "VoucherType": type,
        "VoucherNo": mySharedPreferences.inVocNo,
        "PosNo": mySharedPreferences.posNo,
        "CashNo": mySharedPreferences.cashNo,
        "VoucherDate": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
        "VoucherTime": DateFormat('HH:mm:ss').format(DateTime.now()),
        "VoucherValue": value,
        "Remark": remark,
        "UserId": mySharedPreferences.userId,
        "ShiftId": 0,
      });
      mySharedPreferences.inVocNo++;
      await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'PAY_IN_OUT',
        status: 1,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.PAY_IN_OUT,
        method: 'POST',
        params: '',
        body: body,
        headers: '',
        createdAt: DateTime.now().microsecondsSinceEpoch,
        uploadedAt: DateTime.now().microsecondsSinceEpoch,
      ));
      final response = await restDio.post(ApiUrl.PAY_IN_OUT, data: body);
      _networkLog(response);
      if (response.statusCode == 200) {
        var networkModel = await NetworkTable.queryLastRow();
        if (networkModel != null) {
          networkModel.status = 2;
          networkModel.uploadedAt = DateTime.now().microsecondsSinceEpoch;
          await NetworkTable.update(networkModel);
        }
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }
}
