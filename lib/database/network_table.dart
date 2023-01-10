import 'package:restaurant_system/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NetworkTable {
  static const tableName = 'network_table';

  static const columnId = 'id';
  static const columnType = 'type';
  static const columnStatus = 'status'; // 1: continues request , 2: continues request finished , 3: normal request , 4: continues request deleted
  static const columnBaseUrl = 'base_url';
  static const columnPath = 'path';
  static const columnMethod = 'method';
  static const columnParams = 'params';
  static const columnBody = 'body';
  static const columnHeaders = 'headers';
  static const columnCountRequest = 'count_request';
  static const columnStatusCode = 'status_code';
  static const columnResponse = 'response';
  static const columnCreatedAt = 'created_at';
  static const columnUploadedAt = 'uploaded_at';
  static const columnDailyClose = 'daily_close';

  static Future<int> insert(NetworkTableModel model) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(
      tableName,
      {
        columnType: model.type,
        columnStatus: model.status,
        columnBaseUrl: model.baseUrl,
        columnPath: model.path,
        columnMethod: model.method,
        columnParams: model.params,
        columnBody: model.body,
        columnHeaders: model.headers,
        columnCountRequest: model.countRequest,
        columnStatusCode: model.statusCode,
        columnResponse: model.response,
        columnCreatedAt: model.createdAt,
        columnUploadedAt: model.uploadedAt,
        columnDailyClose: model.dailyClose,
      },
    );
  }

  static Future<int> update(NetworkTableModel model) async {
    Database db = await DatabaseHelper.instance.database;
    int id = model.toMap()['id'];
    return await db.update(tableName, model.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<int> delete(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<List<NetworkTableModel>> queryAllRows({bool desc = false}) async {
    Database db = await DatabaseHelper.instance.database;
    var query = await db.query(tableName, orderBy: '$columnId ${desc ? 'DESC' : 'ASC'}');
    return List<NetworkTableModel>.from(query.map((e) => NetworkTableModel.fromMap(e)));
  }

  static Future<List<NetworkTableModel>> queryRows({required int status}) async {
    Database db = await DatabaseHelper.instance.database;
    var query = await db.query(tableName, where: "$columnStatus = $status");
    return List<NetworkTableModel>.from(query.map((e) => NetworkTableModel.fromMap(e))); // LIKE '%$name%'
  }

  static Future<List<NetworkTableModel>> queryRowsReports({required List<String> types, required int fromDate, required int toDate}) async {
    Database db = await DatabaseHelper.instance.database;
    var query = await db.query(tableName, where: "((${types.map((e) => "$columnType = '$e'").toList().join(' OR ')}) AND $columnDailyClose >= $fromDate AND $columnDailyClose <= $toDate)"); //
    return List<NetworkTableModel>.from(query.map((e) => NetworkTableModel.fromMap(e))); // LIKE '%$name%'
  }

  static Future<int?> queryRowCount() async {
    Database db = await DatabaseHelper.instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
  }

  static Future<NetworkTableModel?> queryLastRow() async {
    Database db = await DatabaseHelper.instance.database;
    var query = await db.query(tableName, orderBy: '$columnId DESC', limit: 1);
    return query.isEmpty ? null : NetworkTableModel.fromMap(query.first);
  }

  static Future<NetworkTableModel?> queryById({required int id}) async {
    Database db = await DatabaseHelper.instance.database;
    var query = await db.query(tableName, where: "$columnId = $id");
    return query.isEmpty ? null : NetworkTableModel.fromMap(query.first);
  }

// SELECT * FROM tablename ORDER BY column DESC LIMIT 1;

// SELECT *
// FROM    TABLE
// WHERE   ID = (SELECT MAX(ID)  FROM TABLE);
}

class NetworkTableModel {
  int id;
  String type;
  int status;
  String baseUrl;
  String path;
  String method;
  String params;
  String body;
  String headers;
  int countRequest;
  int statusCode;
  String response;
  String createdAt;
  String uploadedAt;
  int dailyClose;

  NetworkTableModel({
    required this.id,
    required this.type,
    required this.status,
    required this.baseUrl,
    required this.path,
    required this.method,
    required this.params,
    required this.body,
    required this.headers,
    required this.countRequest,
    required this.statusCode,
    required this.response,
    required this.createdAt,
    required this.uploadedAt,
    required this.dailyClose,
  });

  factory NetworkTableModel.fromMap(Map<String, dynamic> map) => NetworkTableModel(
        id: map[NetworkTable.columnId],
        type: map[NetworkTable.columnType],
        status: map[NetworkTable.columnStatus],
        baseUrl: map[NetworkTable.columnBaseUrl],
        path: map[NetworkTable.columnPath],
        method: map[NetworkTable.columnMethod],
        params: map[NetworkTable.columnParams],
        body: map[NetworkTable.columnBody],
        headers: map[NetworkTable.columnHeaders],
        countRequest: map[NetworkTable.columnCountRequest],
        statusCode: map[NetworkTable.columnStatusCode],
        response: map[NetworkTable.columnResponse],
        createdAt: map[NetworkTable.columnUploadedAt],
        uploadedAt: map[NetworkTable.columnCreatedAt],
        dailyClose: map[NetworkTable.columnDailyClose],
      );

  Map<String, dynamic> toMap() {
    return {
      NetworkTable.columnId: id,
      NetworkTable.columnType: type,
      NetworkTable.columnStatus: status,
      NetworkTable.columnBaseUrl: baseUrl,
      NetworkTable.columnPath: path,
      NetworkTable.columnMethod: method,
      NetworkTable.columnParams: params,
      NetworkTable.columnBody: body,
      NetworkTable.columnHeaders: headers,
      NetworkTable.columnCountRequest: countRequest,
      NetworkTable.columnStatusCode: statusCode,
      NetworkTable.columnResponse: response,
      NetworkTable.columnCreatedAt: createdAt,
      NetworkTable.columnUploadedAt: uploadedAt,
      NetworkTable.columnDailyClose: dailyClose,
    };
  }
}
