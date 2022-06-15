import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_system/utils/constant.dart';

class CustomDataTable extends StatelessWidget {
  final double minWidth;
  final double? dataRowHeight;
  final double? headingRowHeight;
  final List<DataRow> rows;
  final List<DataColumn> columns;
  final bool showCheckboxColumn;

  const CustomDataTable({
    Key? key,
    this.minWidth = 0.0,
    this.dataRowHeight,
    this.headingRowHeight,
    this.showCheckboxColumn = false,
    required this.rows,
    required this.columns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: DataTable(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(3.r),
          ),
          showCheckboxColumn: showCheckboxColumn,
          dataRowHeight: dataRowHeight ?? 30.h,
          headingRowHeight: headingRowHeight ?? 30.h,
          headingTextStyle: kStyleHeaderTable,
          dataTextStyle: kStyleDataTable,
          rows: rows,
          columns: columns,
        ),
      ),
    );
  }
}
