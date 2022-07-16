import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  static late SharedPreferences _sharedPreferences;

  init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  clearData(){
    isLogin = false;
    userId = 0;
    username = '';
    fullName = '';
    phoneNumber = '';
    allData = '';
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


  String get username => _sharedPreferences.getString(keyUsername) ?? "";

  set username(String value) {
    _sharedPreferences.setString(keyUsername, value);
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
}

final mySharedPreferences = MySharedPreferences();

const String keyDeviceToken = "key_device_token";
const String keyAccessToken = "key_access_token";
const String keyLanguage = "key_language";
const String keyIsLogin = "key_is_login";
const String keyIsGMS = "key_is_gms";
const String keyUserId = "key_user_id";
const String keyUsername = "key_username";
const String keyFullName = "key_full_name";
const String keyPhoneNumber = "key_phone_number";
const String keyAllData = "key_all_data";
