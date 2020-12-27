import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:wundertolle_einkaufsliste/objects/database/savable.dart';

class User implements Savable{
  static User me;

  final String uuid;
  final String deviceName;

  User({this.uuid, this.deviceName});



  @override
  User fromJson(Map<String, dynamic> json) {
    return User(uuid: json["uuid"], deviceName: json["name"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "name": deviceName
    };
  }

  @override
  String toJsonString() {
    return json.encode(toJson());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && runtimeType == other.runtimeType && uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
}

class PhoneInfo{

  static Future<String> getPhoneID() async {
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        identifier = build.androidId;  //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        identifier = data.identifierForVendor;  //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
    return identifier;
  }

  static Future<String> getPhoneName() async {
    String deviceName;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
    return deviceName;
  }

  static Future<User> getMe() async {
    return User(uuid: await getPhoneID(), deviceName: await getPhoneName());
  }

}