import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_system/utils/constant.dart';

class CustomDataTable extends StatelessWidget {
  final double minWidth;
  final double? dataRowHeight;
  final double? headingRowHeight;
  final double? columnSpacing;
  final bool sortAscending;
  final int? sortColumnIndex;
  final List<DataRow> rows;
  final List<DataColumn> columns;
  final bool showCheckboxColumn;
  final TextStyle? headingTextStyle;
  final TextStyle? dataTextStyle;

  const CustomDataTable({
    Key? key,
    this.minWidth = 0.0,
    this.dataRowHeight = 30,
    this.headingRowHeight = 30,
    this.showCheckboxColumn = false,
    this.columnSpacing = 25,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.headingTextStyle,
    this.dataTextStyle,
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
          dataRowHeight: dataRowHeight,
          headingRowHeight: headingRowHeight,
          columnSpacing: columnSpacing,
          sortAscending: sortAscending,
          sortColumnIndex: sortColumnIndex,
          headingTextStyle: headingTextStyle?? kStyleHeaderTable,
          dataTextStyle: dataTextStyle?? kStyleDataTable,
          rows: rows,
          columns: columns,
        ),
      ),
    );
  }
}
