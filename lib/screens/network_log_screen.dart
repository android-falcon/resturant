import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/database/network_table.dart';
import 'package:restaurant_system/screens/widgets/custom_data_table.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/utils.dart';

class NetworkLogScreen extends StatefulWidget {
  const NetworkLogScreen({Key? key}) : super(key: key);

  @override
  State<NetworkLogScreen> createState() => _NetworkLogScreenState();
}

class _NetworkLogScreenState extends State<NetworkLogScreen> {
  List<NetworkTableModel> _networkModel = [];
  bool _filterApply = true;
  int _indexSelected = -1;
  int? _sortColumnIndex;
  bool _sortAsc = true;

  getLog() async {
    Utils.showLoadingDialog();
    _filterApply = true;
    _indexSelected = -1;
    _networkModel = await NetworkTable.queryRows(status: 1);
    Utils.hideLoadingDialog();
    setState(() {});
  }

  getAllLog() async {
    Utils.showLoadingDialog();
    _filterApply = false;
    _indexSelected = -1;
    _networkModel = await NetworkTable.queryAllRows(desc: true);
    Utils.hideLoadingDialog();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      getLog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Network Log'.tr),
        actions: [
          if (_indexSelected != -1 && _networkModel[_indexSelected].status == 1)
            IconButton(
              onPressed: () async {
                var networkModel = await NetworkTable.queryById(id: _networkModel[_indexSelected].id);
                if (networkModel != null) {
                  networkModel.status = 4;
                  networkModel.uploadedAt = DateTime.now().toIso8601String();
                  await NetworkTable.update(networkModel);
                  _networkModel[_indexSelected].status = 4;
                  setState(() {});
                }
              },
              icon: const Icon(
                Icons.delete_outline,
              ),
            ),
          IconButton(
            onPressed: () async {
              if (_filterApply) {
                await getAllLog();
              } else {
                await getLog();
              }
            },
            icon: Icon(
              Icons.filter_alt_outlined,
              color: _filterApply ? ColorsApp.orange : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8),
              child: CustomDataTable(
                minWidth: constraints.minWidth,
                showCheckboxColumn: true,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAsc,
                rows: _networkModel
                    .map(
                      (e) => DataRow(
                        selected: _indexSelected == -1 ? false : _networkModel[_indexSelected] == e,
                        onSelectChanged: (value) {
                          _indexSelected = _networkModel.indexOf(e);
                          setState(() {});
                        },
                        cells: [
                          DataCell(Text('${e.id}')),
                          DataCell(Text(e.type)),
                          DataCell(Text(e.method)),
                          DataCell(Text(e.baseUrl)),
                          DataCell(Text(e.path)),
                          DataCell(
                            SizedBox(
                              width: 50.w,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(e.params),
                              ),
                            ),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: e.params));
                            },
                          ),
                          DataCell(
                            SizedBox(
                              width: 50.w,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(e.body),
                              ),
                            ),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: e.body));
                            },
                          ),
                          DataCell(
                            SizedBox(
                              width: 50.w,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(e.headers),
                              ),
                            ),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: e.headers));
                            },
                          ),
                          DataCell(Text('${e.countRequest}')),
                          DataCell(Text('${e.statusCode}')),
                          DataCell(
                            SizedBox(
                              width: 50.w,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(e.response),
                              ),
                            ),
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: e.response));
                            },
                          ),
                          DataCell(Text('${e.status}')),
                          DataCell(Text(DateTime.parse(e.createdAt).toString())),
                          DataCell(Text(DateTime.parse(e.uploadedAt).toString())),
                        ],
                      ),
                    )
                    .toList(),
                columns: [
                  DataColumn(
                    label: Text('Id'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.id.compareTo(b.id));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('Type'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.type.compareTo(b.type));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('Method'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.method.compareTo(b.method));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('BaseUrl'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.baseUrl.compareTo(b.baseUrl));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('Path'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.path.compareTo(b.path));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('Params'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.params.compareTo(b.params));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('Body'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.body.compareTo(b.body));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('Headers'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.headers.compareTo(b.headers));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('CountRequest'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.countRequest.compareTo(b.countRequest));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('StatusCode'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.statusCode.compareTo(b.statusCode));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('Response'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.response.compareTo(b.response));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('Status'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.status.compareTo(b.status));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('CreatedAt'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                  DataColumn(
                    label: Text('UploadedAt'.tr),
                    onSort: (columnIndex, sortAscending) {
                      _indexSelected = -1;
                      _sortAsc = sortAscending;
                      _sortColumnIndex = columnIndex;
                      _networkModel.sort((a, b) => a.uploadedAt.compareTo(b.uploadedAt));
                      if (!sortAscending) {
                        _networkModel = _networkModel.reversed.toList();
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
