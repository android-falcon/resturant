import 'dart:convert';
import 'dart:developer';

import 'package:restaurant_system/models/all_data/kitchen_monitor_model.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/socket/kitchen_socket_client.dart';
import 'package:restaurant_system/socket/network_kitchen.dart';
import 'package:restaurant_system/utils/global_variable.dart';

class KitchenInvoice {
  static init({required CartModel cart, required int orderNo}) async {
    // KitchenSocketClient.sendOrder(orderNo: mySharedPreferences.orderNo, cart: widget.cart);
    List<KitchenMonitorModel> kitchens = allDataModel.itemsKitchenMonitorModel.map((e) => e.kitchenMonitor).toSet().toList();
    for (var kitchen in kitchens) {
      List<CartItemModel> items = [];
      for (var item in cart.items) {
        var indexItemKitchen = allDataModel.itemsKitchenMonitorModel.indexWhere((element) => element.itemId == item.id && element.kitchenMonitor.id == kitchen.id);
        if (indexItemKitchen != -1) {
          items.add(item);
        }
      }
      if (items.isNotEmpty) {
        final networkKitchen = KitchenSocketClient(kitchen.ipAddress, port: kitchen.port);
        var data = jsonEncode({
          'orderNo': orderNo,
          'tableNo': cart.tableId,
          'sectionNo': 0,
          'orderType': cart.orderType.index,
          'items': cart.items
              .map((e) => {
                    'uuid': e.uuid,
                    'parentUuid': e.parentUuid,
                    'itemName': e.name,
                    'qty': e.qty,
                    'note': e.note,
                    'modifiers': List<dynamic>.from(e.modifiers.map((e) => e.toJson())),
                    'questions': List<dynamic>.from(e.questions.map((e) => e.toJson())),
                  })
              .toList(),
        });
        networkKitchen.connect(data: data);
        // final networkKitchen = NetworkKitchen();
        // final kitchenResult = await networkKitchen.connect('192.168.1.103', port: kitchen.port); // invoice.ipAddress
        // if (kitchenResult == KitchenResult.success) {
        //   try {
        //     var data = jsonEncode({
        //       'orderNo': orderNo,
        //       'tableNo': cart.tableNo,
        //       'sectionNo': 0,
        //       'orderType': cart.orderType.index,
        //       'items': cart.items
        //           .map((e) => {
        //                 'itemName': e.name,
        //                 'qty': e.qty,
        //                 'note': e.note,
        //               })
        //           .toList(),
        //     });
        //     networkKitchen.sendData(utf8.encode(data));
        //     await Future.delayed(const Duration(seconds: 1));
        //     networkKitchen.disconnect();
        //     await Future.delayed(const Duration(milliseconds: 200));
        //   } catch (e) {
        //     networkKitchen.disconnect();
        //     await Future.delayed(const Duration(milliseconds: 200));
        //     log('networkKitchen catch ${e.toString()}');
        //   }
        // } else {
        //   log('networkKitchen catch ${kitchenResult.msg} ${kitchen.ipAddress}');
        // }
      }
    }
  }
}
