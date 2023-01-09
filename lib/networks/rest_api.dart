import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart' as dio;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/database/network_table.dart';
import 'package:restaurant_system/models/all_data/tables_model.dart';
import 'package:restaurant_system/models/all_data_model.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/dine_in_model.dart';
import 'package:restaurant_system/models/end_cash_model.dart';
import 'package:restaurant_system/models/refund_model.dart';
import 'package:restaurant_system/networks/api_url.dart';
import 'package:restaurant_system/utils/enums/enum_invoice_kind.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
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
        case 'PUT':
          response = await uploadNetworkTableDio.put(
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
      var networkModel = await NetworkTable.queryById(id: model.id);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.countRequest = networkModel.countRequest + 1;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      var networkModel = await NetworkTable.queryById(id: model.id);
      if (networkModel != null) {
        networkModel.countRequest = networkModel.countRequest + 1;
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    } catch (e) {
      _traceCatch(e);
      var networkModel = await NetworkTable.queryById(id: model.id);
      if (networkModel != null) {
        networkModel.countRequest = networkModel.countRequest + 1;
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    }
  }

  static Future<void> getData() async {
    try {
      Utils.showLoadingDialog();
      var queryParameters = {
        'PosNo': mySharedPreferences.posNo,
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'GET_DATA',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.GET_DATA,
        method: 'GET',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.get(ApiUrl.GET_DATA, queryParameters: queryParameters);
      _networkLog(response);
      if (response.statusCode == 200) {
        allDataModel = AllDataModel.fromJson(response.data);
        allDataModel.items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        allDataModel.categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        mySharedPreferences.allData = jsonEncode(allDataModel.toJson());
      } else {
        allDataModel = AllDataModel.fromJson(jsonDecode(mySharedPreferences.allData));
      }
      // if (allDataModel.tables.isNotEmpty) {
      //   var dineIn = List<DineInModel>.from(
      //     allDataModel.tables.map(
      //       (e) => DineInModel(
      //         isOpen: e.isOpened == 1,
      //         isReservation: false,
      //         tableId: e.id,
      //         tableNo: e.tableNo,
      //         floorNo: e.floorNo,
      //         numberSeats: 0,
      //         cart: CartModel.init(orderType: OrderType.dineIn),
      //       ),
      //     ),
      //   );
      //   if (mySharedPreferences.dineIn.isEmpty) {
      //     mySharedPreferences.dineIn = dineIn;
      //   } else {
      //     var dineInSaved = mySharedPreferences.dineIn;
      //     dineInSaved.removeWhere((elementSaved) => dineIn.every((element) => elementSaved.tableId != element.tableId));
      //     for (var element in dineIn) {
      //       var dineInSavedIndex = dineInSaved.indexWhere((elementSaved) => elementSaved.tableId == element.tableId);
      //       if (dineInSavedIndex == -1) {
      //         dineInSaved.add(element);
      //       } else {
      //         dineInSaved[dineInSavedIndex].isOpen == element.isOpen;
      //         dineInSaved[dineInSavedIndex].floorNo == element.floorNo;
      //         dineInSaved[dineInSavedIndex].tableNo == element.tableNo;
      //       }
      //     }
      //     mySharedPreferences.dineIn = dineInSaved;
      //   }
      // } else {
      //   mySharedPreferences.dineIn = [];
      // }
      Utils.hideLoadingDialog();
      if (networkModel != null) {
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      Utils.loadSortItems();
    } on dio.DioError catch (e) {
      _traceError(e);
      Utils.hideLoadingDialog();
      if (mySharedPreferences.allData.isNotEmpty) {
        allDataModel = AllDataModel.fromJson(jsonDecode(mySharedPreferences.allData));
        Utils.loadSortItems();
      }
      // Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Utils.hideLoadingDialog();
      if (mySharedPreferences.allData.isNotEmpty) {
        allDataModel = AllDataModel.fromJson(jsonDecode(mySharedPreferences.allData));
        Utils.loadSortItems();
      }
      // Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }

  static Future<void> invoice({required CartModel cart, required InvoiceKind invoiceKind}) async {
    try {
      List<Map<String, dynamic>> modifiers = [];
      for (var item in cart.items) {
        int rowSerial = 0;
        modifiers.addAll(item.modifiers.map((e) {
          rowSerial++;
          return e.toInvoice(itemId: item.id, rowSerial: rowSerial, orderType: item.orderType);
        }));
        for (var question in item.questions) {
          modifiers.addAll(question.modifiers.map((e) {
            rowSerial++;
            return e.toInvoice(itemId: item.id, rowSerial: rowSerial, orderType: item.orderType);
          }));
        }
      }
      var body = jsonEncode({
        "InvoiceMaster": invoiceKind == InvoiceKind.invoicePay ? cart.toInvoice() : cart.toReturnInvoice(),
        "InvoiceDetails": List<dynamic>.from(cart.items.map((e) => invoiceKind == InvoiceKind.invoicePay ? e.toInvoice() : e.toReturnInvoice())).toList(),
        "InvoiceModifires": modifiers,
      });
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'INVOICE',
        status: 1,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.INVOICE,
        method: 'POST',
        params: '',
        body: body,
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.INVOICE, data: body);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }

  static Future<CartModel?> getRefundInvoice({required int invNo}) async {
    try {
      Utils.showLoadingDialog();
      var queryParameters = {
        "PosNo": mySharedPreferences.posNo,
        "CashNo": mySharedPreferences.cashNo,
        "InvNo": invNo,
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'REFUND_INVOICE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.REFUND_INVOICE,
        method: 'GET',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.get(ApiUrl.REFUND_INVOICE, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      if (response.statusCode == 200) {
        CartModel refundModel = CartModel.fromJsonServer(response.data);
        Utils.hideLoadingDialog();
        return refundModel;
      } else {
        Utils.hideLoadingDialog();
        return null;
      }
    } on dio.DioError catch (e) {
      Utils.hideLoadingDialog();
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return null;
    } catch (e) {
      Utils.hideLoadingDialog();
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return null;
    }
  }

  static Future<CartModel?> getInvoice({required int invNo}) async {
    try {
      Utils.showLoadingDialog();
      var queryParameters = {
        "coYear": mySharedPreferences.dailyClose.year,
        "PosNo": mySharedPreferences.posNo,
        "CashNo": mySharedPreferences.cashNo,
        "InvNo": invNo,
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'GET_INVOICE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.GET_INVOICE,
        method: 'GET',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.get(ApiUrl.GET_INVOICE, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      if (response.statusCode == 200) {

        CartModel model = CartModel.fromJsonServer(response.data);
        Utils.hideLoadingDialog();
        return model;
      } else {
        Utils.hideLoadingDialog();
        return null;
      }
    } on dio.DioError catch (e) {
      Utils.hideLoadingDialog();
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return null;
    } catch (e) {
      Utils.hideLoadingDialog();
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return null;
    }
  }

  static Future<void> returnInvoiceQty({required CartModel refundModel, required int invNo}) async {
    try {
      var queryParameters = {
        'orgInvNo': invNo,
      };
      var body = jsonEncode(List<dynamic>.from(refundModel.items.map((e) => e.toReturnInvoiceQty())));
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'INVOICE_RETURNED_QTY',
        status: 1,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.INVOICE_RETURNED_QTY,
        method: 'POST',
        params: jsonEncode(queryParameters),
        body: body,
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.INVOICE_RETURNED_QTY, data: body, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }

  static Future<void> payInOut({required double value, required int type, String remark = ''}) async {
    try {
      var body = jsonEncode({
        "CoYear": mySharedPreferences.dailyClose.year,
        "VoucherType": type,
        "VoucherNo": mySharedPreferences.payInOutNo,
        "PosNo": mySharedPreferences.posNo,
        "CashNo": mySharedPreferences.cashNo,
        "VoucherDate": mySharedPreferences.dailyClose.toIso8601String(),
        "VoucherTime": DateFormat('HH:mm:ss').format(mySharedPreferences.dailyClose),
        "VoucherValue": value,
        "Remark": remark,
        "UserId": mySharedPreferences.employee.id,
        "ShiftId": 0,
      });
      mySharedPreferences.payInOutNo++;
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'PAY_IN_OUT',
        status: 1,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.PAY_IN_OUT,
        method: 'POST',
        params: '',
        body: body,
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.PAY_IN_OUT, data: body);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }

  static Future<void> posDailyClose({required DateTime closeDate}) async {
    try {
      Utils.showLoadingDialog();
      closeDate = DateFormat('yyyy-MM-dd').parse(DateFormat('yyyy-MM-dd').format(closeDate));
      var body = jsonEncode({
        "CoYear": mySharedPreferences.dailyClose.year,
        "PosNo": mySharedPreferences.posNo,
        "UserId": mySharedPreferences.employee.id,
        "CloseDate": closeDate.toIso8601String(),
      });
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'POS_DAILY_CLOSE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.POS_DAILY_CLOSE,
        method: 'POST',
        params: '',
        body: body,
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.POS_DAILY_CLOSE, data: body);
      _networkLog(response);
      mySharedPreferences.dailyClose = closeDate;
      allDataModel.posClose = closeDate;
      mySharedPreferences.allData = jsonEncode(allDataModel.toJson());

      Utils.hideLoadingDialog();
      Get.back();
      Fluttertoast.showToast(msg: 'Successfully'.tr, timeInSecForIosWeb: 3);
      if (networkModel != null) {
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Utils.hideLoadingDialog();
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Utils.hideLoadingDialog();
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }

  static Future<List<TablesModel>> getTables() async {
    try {
      var queryParameters = {
        'PosNo': mySharedPreferences.posNo,
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'GET_TABLES',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.GET_TABLES,
        method: 'GET',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.get(ApiUrl.GET_TABLES, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      return List<TablesModel>.from(response.data.map((x) => TablesModel.fromJson(x)));
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return [];
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return [];
    }
  }

  static Future<bool> openTable(int tableId) async {
    try {
      var queryParameters = {
        'tblId': tableId,
        'UserId': mySharedPreferences.employee.id,
        'PosNo': mySharedPreferences.posNo,
        'CashNo': mySharedPreferences.cashNo,
        'OpenDate': mySharedPreferences.dailyClose.toIso8601String(),
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'OPEN_TABLE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.OPEN_TABLE,
        method: 'POST',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.OPEN_TABLE, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      return true;
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return false;
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    }
  }

  static Future<bool> closeTable(int tableId) async {
    try {
      var queryParameters = {
        'tblId': tableId,
        'UserId': mySharedPreferences.employee.id,
        'PosNo': mySharedPreferences.posNo,
        'CashNo': mySharedPreferences.cashNo,
        'CloseDate': mySharedPreferences.dailyClose.toIso8601String(),
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'CLOSE_TABLE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.CLOSE_TABLE,
        method: 'POST',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.CLOSE_TABLE, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      return true;
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return false;
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    }
  }


  static Future<bool> unlockTable(int tableId) async {
    try {
      var queryParameters = {
        'tblId': tableId,
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'UNLOCK_TABLE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.UNLOCK_TABLE,
        method: 'POST',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.UNLOCK_TABLE, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      return true;
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return false;
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    }
  }

  static Future<bool> changeUserTable(int tableId, int oldUser, int newUserId) async {
    try {
      var queryParameters = {
        'TableId': tableId,
        'oldUser': oldUser,
        'NewUserId': newUserId,
        'PosNo': mySharedPreferences.posNo,
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'CHANGE_USER_TABLE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.CHANGE_USER_TABLE,
        method: 'PUT',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.put(ApiUrl.CHANGE_USER_TABLE, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      return true;
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return false;
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    }
  }

  static Future<bool> printTable(int tableId) async {
    try {
      var queryParameters = {
        'tblId': tableId,
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'PRINT_TABLE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.PRINT_TABLE,
        method: 'POST',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.PRINT_TABLE, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      return true;
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return false;
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    }
  }

  static Future<bool> moveTable(int oldTableId, int newTableId) async {
    try {
      var queryParameters = {
        'OldTblId': oldTableId,
        'NewTblId': newTableId,
        'UserId': mySharedPreferences.employee.id,
        'PosNo': mySharedPreferences.posNo,
        'CashNo': mySharedPreferences.cashNo,
        'MoveDate': mySharedPreferences.dailyClose.toIso8601String(),
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'MOVE_TABLE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.MOVE_TABLE,
        method: 'POST',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.MOVE_TABLE, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      return true;
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return false;
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    }
  }

  static Future<bool> mergeTable(int oldTableId, int newTableId) async {
    try {
      var queryParameters = {
        'OldTblId': oldTableId,
        'NewTblId': newTableId,
        'UserId': mySharedPreferences.employee.id,
        'PosNo': mySharedPreferences.posNo,
        'CashNo': mySharedPreferences.cashNo,
        'MergeDate': mySharedPreferences.dailyClose.toIso8601String(),
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'MERGE_TABLE',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.MERGE_TABLE,
        method: 'POST',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.MERGE_TABLE, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      return true;
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return false;
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    }
  }

  static Future<bool> saveTableOrder({required CartModel cart}) async {
    try {
      List<Map<String, dynamic>> modifiers = [];
      for (var item in cart.items) {
        int rowSerial = 0;
        modifiers.addAll(item.modifiers.map((e) {
          rowSerial++;
          return e.toSaveTable(itemId: item.id, rowSerial: rowSerial);
        }));
        for (var question in item.questions) {
          modifiers.addAll(question.modifiers.map((e) {
            rowSerial++;
            return e.toSaveTable(itemId: item.id, rowSerial: rowSerial);
          }));
        }
      }
      var body = jsonEncode({
        "TableOrderMaster": cart.toSaveTable(),
        "TableOrderDetails": List<dynamic>.from(cart.items.map((e) => e.toSaveTable())).toList(),
        "TableOrderModifire": modifiers,
        "TableCart": {
          "TBLCART": jsonEncode(cart.toJson()),
        },
      });
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'SAVE_TABLE_ORDER',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.SAVE_TABLE_ORDER,
        method: 'POST',
        params: '',
        body: body,
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.SAVE_TABLE_ORDER, data: body);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      return true;
    } on dio.DioError catch (e) {
      _traceError(e);
      // Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    } catch (e) {
      _traceCatch(e);
      // Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    }
  }

  static Future<void> saveVoidItem({required CartItemModel item, required String reason}) async {
    try {
      var body = jsonEncode({
        "CoYear": mySharedPreferences.dailyClose.year,
        "PosNo": mySharedPreferences.posNo,
        "CashNo": mySharedPreferences.cashNo,
        "VoidDate": mySharedPreferences.dailyClose.toIso8601String(),
        "RowNo": item.rowSerial,
        "Reason": reason,
        "ItemID": item.id,
        "Qty": item.qty,
        "UserID": mySharedPreferences.employee.id,
      });
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'SAVE_VOID_ITEMS',
        status: 1,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.SAVE_VOID_ITEMS,
        method: 'POST',
        params: '',
        body: body,
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.SAVE_VOID_ITEMS, data: body);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }

  static Future<void> saveVoidAllItems({required List<CartItemModel> items, required String reason}) async {
    try {
      var body = jsonEncode(items
          .map((e) => {
                "CoYear": mySharedPreferences.dailyClose.year,
                "PosNo": mySharedPreferences.posNo,
                "CashNo": mySharedPreferences.cashNo,
                "VoidDate": mySharedPreferences.dailyClose.toIso8601String(),
                "RowNo": e.rowSerial,
                "Reason": reason,
                "ItemID": e.id,
                "Qty": e.qty,
                "UserID": mySharedPreferences.employee.id,
              })
          .toList());
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'SAVE_VOID_ALL_ITEMS',
        status: 1,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.SAVE_VOID_ALL_ITEMS,
        method: 'POST',
        params: '',
        body: body,
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.SAVE_VOID_ALL_ITEMS, data: body);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }

  static Future<void> resetPOSOrderNo() async {
    try {
      var queryParameters = {
        "PosNo": mySharedPreferences.posNo,
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'RESET_POS_ORDER_NO',
        status: 1,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.RESET_POS_ORDER_NO,
        method: 'POST',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.RESET_POS_ORDER_NO, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
    } catch (e) {
      _traceCatch(e);
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
    }
  }

  static Future<bool> endCash({required double totalCash, required double totalCreditCard, required double totalCredit, required double netTotal}) async {
    try {
      Utils.showLoadingDialog();
      var body = jsonEncode({
        "CoYear": mySharedPreferences.dailyClose.year,
        "EndCashDate": mySharedPreferences.dailyClose.toIso8601String(),
        "PosNo": mySharedPreferences.posNo,
        "CashNo": mySharedPreferences.cashNo,
        "TotalCash": totalCash,
        "TotalCreditCard": totalCreditCard,
        "TotalCredit": totalCredit,
        "NetTotal": netTotal,
        "UserId": mySharedPreferences.employee.id,
      });
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'END_CASH',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.END_CASH,
        method: 'POST',
        params: '',
        body: body,
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.post(ApiUrl.END_CASH, data: body);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      Utils.hideLoadingDialog();
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Successfully'.tr, timeInSecForIosWeb: 3);
        return true;
      } else {
        return false;
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Utils.hideLoadingDialog();
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return false;
    } catch (e) {
      _traceCatch(e);
      Utils.hideLoadingDialog();
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return false;
    }
  }

  static Future<EndCashModel?> getEndCash() async {
    try {
      Utils.showLoadingDialog();
      var queryParameters = {
        "coYear": mySharedPreferences.dailyClose.year,
        "PosNo": mySharedPreferences.posNo,
        "CashNo": mySharedPreferences.cashNo,
        "UserId": mySharedPreferences.employee.id,
        "dayDate": mySharedPreferences.dailyClose.toIso8601String(),
      };
      var networkId = await NetworkTable.insert(NetworkTableModel(
        id: 0,
        type: 'GET_END_CASH',
        status: 3,
        baseUrl: restDio.options.baseUrl,
        path: ApiUrl.GET_END_CASH,
        method: 'GET',
        params: jsonEncode(queryParameters),
        body: '',
        headers: '',
        countRequest: 1,
        statusCode: 0,
        response: '',
        createdAt: DateTime.now().toIso8601String(),
        uploadedAt: DateTime.now().toIso8601String(),
      ));
      var networkModel = await NetworkTable.queryById(id: networkId);
      final response = await restDio.get(ApiUrl.GET_END_CASH, queryParameters: queryParameters);
      _networkLog(response);
      if (networkModel != null) {
        networkModel.status = 2;
        networkModel.statusCode = response.statusCode!;
        networkModel.response = response.data is String ? response.data : jsonEncode(response.data);
        networkModel.uploadedAt = DateTime.now().toIso8601String();
        await NetworkTable.update(networkModel);
      }
      Utils.hideLoadingDialog();
      if (response.statusCode == 200) {
        return EndCashModel.fromJson(response.data);
      } else {
        Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
        return null;
      }
    } on dio.DioError catch (e) {
      _traceError(e);
      Utils.hideLoadingDialog();
      Fluttertoast.showToast(msg: '${e.response?.data ?? 'Please try again'.tr}', timeInSecForIosWeb: 3);
      return null;
    } catch (e) {
      _traceCatch(e);
      Utils.hideLoadingDialog();
      Fluttertoast.showToast(msg: 'Please try again'.tr, timeInSecForIosWeb: 3);
      return null;
    }
  }
}
