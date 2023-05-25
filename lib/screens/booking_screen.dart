import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:restaurant_system/models/booking_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/add_booking_screen.dart';
import 'package:restaurant_system/screens/order_screen.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/utils.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<BookingModel> booking = [];
  final String dateFormat = 'yyyy-MM-dd HH:mm';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      getBooking();
    });
  }

  getBooking() async {
    booking = await RestApi.getBooking();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking'.tr),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(const AddBookingScreen())!.then((value) {
                getBooking();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: booking.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          title: Text('${booking[index].customerPhone} - ${booking[index].customerName}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${'Date'.tr} : ${booking[index].bookingDate.isEmpty ? "" : intl.DateFormat(dateFormat).format(DateTime.parse(booking[index].bookingDate))}'),
              Text('${'Hours'.tr} : ${booking[index].noOfHours}'),
              Text('${'Persons'.tr} : ${booking[index].noOfPersons}'),
              Text('${'Booking Type'.tr} : ${allDataModel.bookingTypesModel.firstWhereOrNull((element) => element.id == booking[index].bookingType)?.name ?? ""}'),
              Text('${'Note'.tr} : ${booking[index].note}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  var resultAreYouSure = await Utils.showAreYouSureDialog(title: 'Finish');
                  if (resultAreYouSure) {
                    var result = await RestApi.deleteBooking(
                      id: booking[index].id,
                    );
                    if (result) {
                      Get.back();
                      Get.to(() => OrderScreen(type: OrderType.takeAway, customerName: booking[index].customerName, customerPhone: booking[index].customerPhone));
                    }
                  }
                },
                icon: const Icon(Icons.check),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () async {
                  var resultAreYouSure = await Utils.showAreYouSureDialog(title: 'Delete');
                  if (resultAreYouSure) {
                    var result = await RestApi.deleteBooking(
                      id: booking[index].id,
                    );
                    if (result) {
                      getBooking();
                    }
                  }
                },
                icon: const Icon(Icons.delete),
              )
            ],
          ),
        ),
      ),
    );
  }
}
