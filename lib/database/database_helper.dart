import 'dart:io';

import 'package:path/path.dart';
import 'package:restaurant_system/database/network_table.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class DatabaseHelper {
  static const _databaseName = "falcons.db";
  static const _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    if(Platform.isWindows){
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      return await databaseFactory.openDatabase(inMemoryDatabasePath, options: OpenDatabaseOptions(version: _databaseVersion, onCreate: _onCreate));
    } else {
      String path = join(await getDatabasesPath(), _databaseName);
      return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
    }

  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE ${NetworkTable.tableName} (
            ${NetworkTable.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${NetworkTable.columnType} TEXT NOT NULL,
            ${NetworkTable.columnStatus} INTEGER NOT NULL,
            ${NetworkTable.columnBaseUrl} TEXT NOT NULL,
            ${NetworkTable.columnPath} TEXT NOT NULL,
            ${NetworkTable.columnMethod} TEXT NOT NULL,
            ${NetworkTable.columnParams} TEXT NOT NULL,
            ${NetworkTable.columnBody} TEXT NOT NULL,
            ${NetworkTable.columnHeaders} TEXT NOT NULL,
            ${NetworkTable.columnCountRequest} INTEGER NOT NULL,
            ${NetworkTable.columnStatusCode} INTEGER NOT NULL,
            ${NetworkTable.columnResponse} TEXT,
            ${NetworkTable.columnCreatedAt} TEXT NOT NULL,
            ${NetworkTable.columnUploadedAt} TEXT NOT NULL
          )
          ''');
  }
}
