import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:restaurant_system/models/un_confirm_invoice_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/utils.dart';

class ConfirmInvoiceScreen extends StatefulWidget {
  const ConfirmInvoiceScreen({Key? key}) : super(key: key);

  @override
  State<ConfirmInvoiceScreen> createState() => _ConfirmInvoiceScreenState();
}

class _ConfirmInvoiceScreenState extends State<ConfirmInvoiceScreen> {
  List<UnConfirmInvoiceModel> unConfirmInvoice = [];
  final String dateFormat = 'yyyy-MM-dd HH:mm';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      getUnConfirmInvoice();
    });
  }

  getUnConfirmInvoice() async {
    unConfirmInvoice = await RestApi.getUnConfirmInvoice();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Invoice'.tr),
      ),
      body: ListView.separated(
        itemCount: unConfirmInvoice.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          title: Text('${unConfirmInvoice[index].invNo}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${'Date'.tr} : ${unConfirmInvoice[index].invDate.isEmpty ? "" : intl.DateFormat(dateFormat).format(DateTime.parse(unConfirmInvoice[index].invDate))}'),
            ],
          ),
          trailing: IconButton(
            onPressed: () async {
              var resultAreYouSure = await Utils.showAreYouSureDialog(title: 'Confirm');
              if (resultAreYouSure) {
                await RestApi.confirmInvoice(
                  id: unConfirmInvoice[index].invNo,
                );
                getUnConfirmInvoice();
              }
            },
            icon: const Icon(Icons.check),
          ),
        ),
      ),
    );
  }
}
