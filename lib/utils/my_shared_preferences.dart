import 'dart:convert';

import 'package:restaurant_system/models/dine_in_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  static late SharedPreferences _sharedPreferences;

  init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  clearData() {
    isLogin = false;
    userId = 0;
    fullName = '';
    phoneNumber = '';
    allData = '';
    baseUrl = '';
    inVocNo = 1;
    outVocNo = 1;
    posNo = 0;
    cashNo = 0;
    storeNo = 0;
  }

  String get language => _sharedPreferences.getString(keyLanguage) ?? "";

  set language(String value) {
    _sharedPreferences.setString(keyLanguage, value);
  }

  String get deviceToken => _sharedPreferences.getString(keyDeviceToken) ?? "";

  set deviceToken(String value) {
    _sharedPreferences.setString(keyDeviceToken, value);
  }

  String get accessToken => _sharedPreferences.getString(keyAccessToken) ?? "";

  set accessToken(String value) {
    _sharedPreferences.setString(keyAccessToken, value);
  }

  bool get isLogin => _sharedPreferences.getBool(keyIsLogin) ?? false;

  set isLogin(bool value) {
    _sharedPreferences.setBool(keyIsLogin, value);
  }

  bool get isGMS => _sharedPreferences.getBool(keyIsGMS) ?? true;

  set isGMS(bool value) {
    _sharedPreferences.setBool(keyIsGMS, value);
  }

  int get userId => _sharedPreferences.getInt(keyUserId) ?? 0;

  set userId(int value) {
    _sharedPreferences.setInt(keyUserId, value);
  }

  String get fullName => _sharedPreferences.getString(keyFullName) ?? "";

  set fullName(String value) {
    _sharedPreferences.setString(keyFullName, value);
  }

  String get phoneNumber => _sharedPreferences.getString(keyPhoneNumber) ?? "";

  set phoneNumber(String value) {
    _sharedPreferences.setString(keyPhoneNumber, value);
  }

  String get allData => _sharedPreferences.getString(keyAllData) ?? "";

  set allData(String value) {
    _sharedPreferences.setString(keyAllData, value);
  }

  List<DineInModel> get dineIn => List<DineInModel>.from(jsonDecode(_sharedPreferences.getString(keyDineIn) ?? "[]").map((e) => DineInModel.fromJson(e)));

  set dineIn(List<DineInModel> value) {
    _sharedPreferences.setString(keyDineIn, jsonEncode(List<dynamic>.from(value.map((e) => e.toJson()))));
  }

  String get baseUrl => _sharedPreferences.getString(keyBaseUrl) ?? "";

  set baseUrl(String value) {
    _sharedPreferences.setString(keyBaseUrl, value);
  }

  int get inVocNo => _sharedPreferences.getInt(keyInVocNo) ?? 1;

  set inVocNo(int value) {
    _sharedPreferences.setInt(keyInVocNo, value);
  }

  int get outVocNo => _sharedPreferences.getInt(keyOutVocNo) ?? 1;

  set outVocNo(int value) {
    _sharedPreferences.setInt(keyOutVocNo, value);
  }

  int get posNo => _sharedPreferences.getInt(keyPosNo) ?? 0;

  set posNo(int value) {
    _sharedPreferences.setInt(keyPosNo, value);
  }

  int get cashNo => _sharedPreferences.getInt(keyCashNo) ?? 0;

  set cashNo(int value) {
    _sharedPreferences.setInt(keyCashNo, value);
  }
  int get storeNo => _sharedPreferences.getInt(keyStoreNo) ?? 0;

  set storeNo(int value) {
    _sharedPreferences.setInt(keyStoreNo, value);
  }

}

final mySharedPreferences = MySharedPreferences();

const String keyDeviceToken = "key_device_token";
const String keyAccessToken = "key_access_token";
const String keyLanguage = "key_language";
const String keyIsLogin = "key_is_login";
const String keyIsGMS = "key_is_gms";
const String keyUserId = "key_user_id";
const String keyFullName = "key_full_name";
const String keyPhoneNumber = "key_phone_number";
const String keyAllData = "key_all_data";
const String keyDineIn = "key_dine_in";
const String keyBaseUrl = "key_base_url";
const String keyInVocNo = "key_in_voc_no";
const String keyOutVocNo = "key_out_voc_no";
const String keyPosNo = "key_pos_no";
const String keyCashNo = "key_cash_no";
const String keyStoreNo = "key_store_no";
