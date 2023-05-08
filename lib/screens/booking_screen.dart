import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/booking_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/add_booking_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<BookingModel> booking = [];

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
              Text('${'Date'.tr} : ${booking[index].bookingDate}'),
              Text('${'Hours'.tr} : ${booking[index].noOfHours}'),
              Text('${'Persons'.tr} : ${booking[index].noOfPersons}'),
            ],
          ),
          trailing: IconButton(
            onPressed: () async {
              var result = await RestApi.deleteBooking(
                id: booking[index].id,
              );
              if (result) {
                getBooking();
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}
