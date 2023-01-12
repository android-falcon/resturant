import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:restaurant_system/database/network_table.dart';
import 'package:restaurant_system/models/report_sold_qty_model.dart';
import 'package:restaurant_system/screens/widgets/custom_data_table.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/credit_card_type_detector.dart';
import 'package:restaurant_system/utils/enums/enum_report_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/validation.dart';

class ReportScreen extends StatefulWidget {
  final ReportType type;

  const ReportScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final String dateFormat = 'yyyy-MM-dd';
  final TextEditingController _controllerFromDate = TextEditingController();
  final TextEditingController _controllerToDate = TextEditingController();
  Widget _buildWidget = Container();

  _init() async {
    switch (widget.type) {
      case ReportType.cashReport:
        List<NetworkTableModel> data = await NetworkTable.queryRowsReports(
          types: ['INVOICE', 'PAY_IN_OUT'],
          fromDate: intl.DateFormat(dateFormat).parse(_controllerFromDate.text).millisecondsSinceEpoch,
          toDate: intl.DateFormat(dateFormat).parse(_controllerToDate.text).millisecondsSinceEpoch,
        );
        double cash = 0;
        double creditCard = 0;
        double visa = 0;
        double payIn = 0;
        double payOut = 0;
        for (var element in data) {
          if (element.type == 'PAY_IN_OUT') {
            var body = jsonDecode(element.body);
            if (body['PosNo'] == mySharedPreferences.posNo && body['CashNo'] == mySharedPreferences.cashNo) {
              if (body['VoucherType'] == 1) {
                payIn += body['VoucherValue'];
              } else if (body['VoucherType'] == 2) {
                payOut += body['VoucherValue'];
              }
            }
          } else if (element.type == 'INVOICE') {
            var body = jsonDecode(element.body);
            if (body['InvoiceMaster']['PosNo'] == mySharedPreferences.posNo && body['InvoiceMaster']['CashNo'] == mySharedPreferences.cashNo && body['InvoiceMaster']['InvKind'] == 0) {
              cash += body['InvoiceMaster']['CashVal'];
              creditCard += body['InvoiceMaster']['CardsVal'];
              if (body['InvoiceMaster']['Card1Name'] == CreditCardType.visa.name) {
                visa += body['InvoiceMaster']['CardsVal'];
              }
            }
          }
        }
        _buildWidget = Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          child: SingleChildScrollView(
            child: CustomDataTable(
              minWidth: 344.w,
              showCheckboxColumn: true,
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text('Cash'.tr)),
                    DataCell(Text(cash.toStringAsFixed(3))),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('Credit Card'.tr)),
                    DataCell(Text(creditCard.toStringAsFixed(3))),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('***visa'.tr)),
                    DataCell(Text(visa.toStringAsFixed(3))),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('Pay In'.tr)),
                    DataCell(Text(payIn.toStringAsFixed(3))),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('Pay Out'.tr)),
                    DataCell(Text(payOut.toStringAsFixed(3))),
                  ],
                ),
              ],
              columns: [
                DataColumn(label: Text('Description'.tr)),
                DataColumn(label: Text('Value'.tr)),
              ],
            ),
          ),
        );
        break;
      case ReportType.cashInOutReport:
        List<NetworkTableModel> data = await NetworkTable.queryRowsReports(
          types: ['PAY_IN_OUT'],
          fromDate: intl.DateFormat(dateFormat).parse(_controllerFromDate.text).millisecondsSinceEpoch,
          toDate: intl.DateFormat(dateFormat).parse(_controllerToDate.text).millisecondsSinceEpoch,
        );
        _buildWidget = Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          child: SingleChildScrollView(
            child: CustomDataTable(
              minWidth: 344.w,
              showCheckboxColumn: true,
              rows: data.map((e) {
                var body = jsonDecode(e.body);
                return DataRow(
                  cells: [
                    DataCell(Text(body['VoucherDate'].split('T').first)),
                    DataCell(Text(body['VoucherType'] == 1 ? 'Cash In'.tr : 'Cash Out'.tr)),
                    DataCell(Text(allDataModel.cashInOutTypesModel.firstWhereOrNull((element) => element.id == body['DescId'])?.description ?? '')),
                    DataCell(Text('${body['PosNo']}')),
                    DataCell(Text('${body['CashNo']}')),
                    DataCell(Text(body['VoucherTime'])),
                    DataCell(Text(allDataModel.employees.firstWhereOrNull((element) => element.id == body['UserId'])?.empName ?? '')),
                    DataCell(Text(body['VoucherValue'].toStringAsFixed(3))),
                    DataCell(Text(body['Remark'])),
                  ],
                );
              }).toList(),
              columns: [
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
        );
        break;
      case ReportType.soldQtyReport:
        List<NetworkTableModel> data = await NetworkTable.queryRowsReports(
          types: ['INVOICE'],
          fromDate: intl.DateFormat(dateFormat).parse(_controllerFromDate.text).millisecondsSinceEpoch,
          toDate: intl.DateFormat(dateFormat).parse(_controllerToDate.text).millisecondsSinceEpoch,
        );
        List<ReportSoldQtyModel> items = [];
        for (var element in data) {
          var body = jsonDecode(element.body);
          if (body['InvoiceMaster']['PosNo'] == mySharedPreferences.posNo && body['InvoiceMaster']['CashNo'] == mySharedPreferences.cashNo && body['InvoiceMaster']['InvKind'] == 0) {
            for (var invoiceDetails in body['InvoiceDetails']) {
              var indexItem = items.indexWhere((e) => e.itemId == invoiceDetails['ItemId']);
              if (indexItem != -1) {
                items[indexItem].soldQty += invoiceDetails['Qty'];
                items[indexItem].disc += invoiceDetails['InvDisc'] + invoiceDetails['LineDisc'];
                items[indexItem].serviceValue += invoiceDetails['ServiceVal'];
                items[indexItem].itemTax += invoiceDetails['ItemTaxVal'];
                items[indexItem].totalNoTaxAndService += invoiceDetails['NetTotal'] - (invoiceDetails['ItemTaxVal'] - invoiceDetails['ServiceVal'] - invoiceDetails['ServiceTax']);
                items[indexItem].totalNoTax += invoiceDetails['NetTotal'] - invoiceDetails['ItemTaxVal'];
                items[indexItem].netTotal += invoiceDetails['NetTotal'];
              } else {
                var itemInAllData = allDataModel.items.firstWhereOrNull((e) => e.id == invoiceDetails['ItemId']);
                items.add(ReportSoldQtyModel(
                  itemId: invoiceDetails['ItemId'],
                  itemName: itemInAllData?.menuName ?? '',
                  categoryName: itemInAllData?.category.categoryName ?? '',
                  soldQty: invoiceDetails['Qty'],
                  disc: invoiceDetails['InvDisc'] + invoiceDetails['LineDisc'],
                  serviceValue: invoiceDetails['ServiceVal'],
                  itemTax: invoiceDetails['ItemTaxVal'],
                  totalNoTaxAndService: invoiceDetails['NetTotal'] - (invoiceDetails['ItemTaxVal'] - invoiceDetails['ServiceVal'] - invoiceDetails['ServiceTax']),
                  totalNoTax: invoiceDetails['NetTotal'] - invoiceDetails['ItemTaxVal'],
                  netTotal: invoiceDetails['NetTotal'],
                ));
              }
            }
          }
        }
        double soldQty = 0;
        double disc = 0;
        double serviceValue = 0;
        double itemTax = 0;
        double totalNoTaxAndService = 0;
        double totalNoTax = 0;
        double netTotal = 0;
        for (var item in items) {
          soldQty += item.soldQty;
          disc += item.disc;
          serviceValue += item.serviceValue;
          itemTax += item.itemTax;
          totalNoTaxAndService += item.totalNoTaxAndService;
          totalNoTax += item.totalNoTax;
          netTotal += item.netTotal;
        }
        _buildWidget = Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
          child: SingleChildScrollView(
            child: CustomDataTable(
              minWidth: 344.w,
              showCheckboxColumn: true,
              rows: [
                ...items
                    .where((e) => e.soldQty != 0)
                    .map((e) => DataRow(
                          cells: [
                            DataCell(Text(e.itemName)),
                            DataCell(Text(e.categoryName)),
                            DataCell(Text(e.soldQty.toStringAsFixed(3))),
                            DataCell(Text(e.disc.toStringAsFixed(3))),
                            DataCell(Text(e.serviceValue.toStringAsFixed(3))),
                            DataCell(Text(e.itemTax.toStringAsFixed(3))),
                            DataCell(Text(e.totalNoTaxAndService.toStringAsFixed(3))),
                            DataCell(Text(e.totalNoTax.toStringAsFixed(3))),
                            DataCell(Text(e.netTotal.toStringAsFixed(3))),
                          ],
                        ))
                    .toList(),
                DataRow(
                  cells: [
                    const DataCell(Text('')),
                    DataCell(Text('Totals'.tr, style: kStyleHeaderTable,)),
                    DataCell(Text(soldQty.toStringAsFixed(3))),
                    DataCell(Text(disc.toStringAsFixed(3))),
                    DataCell(Text(serviceValue.toStringAsFixed(3))),
                    DataCell(Text(itemTax.toStringAsFixed(3))),
                    DataCell(Text(totalNoTaxAndService.toStringAsFixed(3))),
                    DataCell(Text(totalNoTax.toStringAsFixed(3))),
                    DataCell(Text(netTotal.toStringAsFixed(3))),
                  ],
                )
              ],
              columns: [
                DataColumn(label: Text('Item Name'.tr)),
                DataColumn(label: Text('Category Name'.tr)),
                DataColumn(label: Text('Sold Qty'.tr)),
                DataColumn(label: Text('Disc'.tr)),
                DataColumn(label: Text('Service Value'.tr)),
                DataColumn(label: Text('Item Tax'.tr)),
                DataColumn(label: Text('Total No Tax and Service'.tr)),
                DataColumn(label: Text('Total No Tax'.tr)),
                DataColumn(label: Text('Net Total'.tr)),
              ],
            ),
          ),
        );
        break;
      default:
        _buildWidget = Container();
        break;
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controllerFromDate.text = intl.DateFormat(dateFormat).format(DateTime.now());
    _controllerToDate.text = intl.DateFormat(dateFormat).format(DateTime.now());
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.name.tr),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  controller: _controllerFromDate,
                  label: Text('From Date'.tr),
                  textDirection: TextDirection.ltr,
                  readOnly: true,
                  validator: (value) {
                    return Validation.isRequired(value);
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _controllerFromDate.text.isNotEmpty ? intl.DateFormat(dateFormat).parse(_controllerFromDate.text) : DateTime.now(),
                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      String formattedDate = intl.DateFormat(dateFormat).format(pickedDate);
                      _controllerFromDate.text = formattedDate; //set output date to TextField value.
                      _init();
                    }
                  },
                ),
              ),
              Expanded(
                child: CustomTextField(
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  controller: _controllerToDate,
                  label: Text('To Date'.tr),
                  textDirection: TextDirection.ltr,
                  readOnly: true,
                  validator: (value) {
                    return Validation.isRequired(value);
                  },
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _controllerToDate.text.isNotEmpty ? intl.DateFormat(dateFormat).parse(_controllerToDate.text) : DateTime.now(),
                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      String formattedDate = intl.DateFormat(dateFormat).format(pickedDate);
                      _controllerToDate.text = formattedDate; //set output date to TextField value.
                      _init();
                    }
                  },
                ),
              ),
            ],
          ),
          Expanded(child: _buildWidget),
        ],
      ),
    );
  }
}
