import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';

import 'objects/data.dart';
import 'objects/user.dart';

void main() {
  runApp(Home());
  PhoneInfo.getMe().then((value) {
    User.me = value;
    print("This is your phone UUID: " + value.uuid);
    print("This is your phone Name: " + value.deviceName);
    initializeDatabase();
  });
}

//TODO: In all savable classes in fromJson: Instead of returning a new value, set the fields and return this.

//TODO: Rework DataGetter

//TODO: AppLink

//TODO: Add me to created List.
