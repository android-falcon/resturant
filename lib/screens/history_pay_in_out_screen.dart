import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:get/get.dart';
import 'package:restaurant_system/models/get_pay_in_out_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/widgets/custom_data_table.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/utils.dart';

class HistoryPayInOutScreen extends StatefulWidget {
  const HistoryPayInOutScreen({Key? key}) : super(key: key);

  @override
  State<HistoryPayInOutScreen> createState() => _HistoryPayInOutScreenState();
}

class _HistoryPayInOutScreenState extends State<HistoryPayInOutScreen> {
  List<GetPayInOutModel> data = [];

  _getData() async {
    data = await RestApi.getPayInOut();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _getData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Pay In / Out'.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          child: CustomDataTable(
            minWidth: 344.w,
            showCheckboxColumn: true,
            rows: data.map((e) {
              return DataRow(
                cells: [
                  DataCell(
                    const Icon(Icons.delete),
                    onTap: () async {
                      var result = await Utils.showAreYouSureDialog(title: 'Delete Pay In / Out'.tr);
                      if (result) {
                        RestApi.deletePayInOut(model: e);
                        data.remove(e);
                        setState(() {});
                      }
                    },
                  ),
                  DataCell(Text(intl.DateFormat('yyyy-MM-dd').format(e.voucherDate))),
                  DataCell(Text(e.voucherType == 1 ? 'Cash In'.tr : 'Cash Out'.tr)),
                  DataCell(Text(allDataModel.cashInOutTypesModel.firstWhereOrNull((element) => element.id == e.descId)?.description ?? '')),
                  DataCell(Text('${e.posNo}')),
                  DataCell(Text('${e.cashNo}')),
                  DataCell(Text(e.voucherTime)),
                  DataCell(Text(allDataModel.employees.firstWhereOrNull((element) => element.id == e.userId)?.empName ?? '')),
                  DataCell(Text(e.voucherValue.toStringAsFixed(3))),
                  DataCell(Text(e.remark)),
                ],
              );
            }).toList(),
            columns: [
              DataColumn(label: Text('Action'.tr)),
              DataColumn(label: Text('Date'.tr)),
              DataColumn(label: Text('Type'.tr)),
              DataColumn(label: Text('Description'.tr)),
              DataColumn(label: Text('Pos No'.tr)),
              DataColumn(label: Text('Cash No'.tr)),
              DataColumn(label: Text('Time'.tr)),
              DataColumn(label: Text('Employee'.tr)),
              DataColumn(label: Text('Value'.tr)),
              DataColumn(label: Text('Remark'.tr)),
            ],
          ),
        ),
      ),
    );
  }
}
