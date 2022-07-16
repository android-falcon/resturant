import 'package:restaurant_system/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NetworkTable {
  static const tableName = 'network_table';

  static const columnId = 'id';
  static const columnType = 'type';
  static const columnStatus = 'status';
  static const columnBaseUrl = 'base_url';
  static const columnPath = 'path';
  static const columnMethod = 'method';
  static const columnParams = 'params';
  static const columnBody = 'body';
  static const columnHeaders = 'headers';
  static const columnCreatedAt = 'created_at';
  static const columnUploadedAt = 'uploaded_at';

  Future<int> insert(NetworkTableModel model) async {
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
        columnCreatedAt: model.createdAt,
        columnUploadedAt: model.uploadedAt,
      },
    );
  }

  Future<int> update(NetworkTableModel model) async {
    Database db = await DatabaseHelper.instance.database;
    int id = model.toMap()['id'];
    return await db.update(tableName, model.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(tableName);
  }

  Future<List<Map<String, dynamic>>> queryRows(status) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.query(tableName, where: "$columnStatus = $status"); // LIKE '%$name%'
  }

  Future<int?> queryRowCount() async {
    Database db = await DatabaseHelper.instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
  }


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
  int createdAt;
  int uploadedAt;

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
    required this.createdAt,
    required this.uploadedAt,
  });

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
      NetworkTable.columnCreatedAt: createdAt,
      NetworkTable.columnUploadedAt: uploadedAt,
    };
  }
}
