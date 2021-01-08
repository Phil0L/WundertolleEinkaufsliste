import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';
import 'package:wundertolle_einkaufsliste/start/invite.dart';
import 'package:wundertolle_einkaufsliste/start/start_manager.dart';

import 'objects/data.dart';
import 'objects/user.dart';

void main() {
  // runs the main app
  runApp(Home());
  // handles different app starts for example an app start from a link
    // app start from an list invite
  Home.startManager.addListener(StartEvent(requireAppLoad: true, requireContext: true, requireLogin: true, callback: (startEvent) {
    (startEvent as Invitation).onInvitation();
  }));
  // initializes data handling for example login and database
  PhoneInfo.getMe().then((value) {
    User.me = value;
    print("This is your phone UUID: " + value.uuid);
    print("This is your phone Name: " + value.deviceName);
    Home.startManager.registerEvent(loadedMe: true);
    initializeDatabase();
  });
}

//TODO: reload feature

//TODO: after adding list goto this list
//TODO: on start goto list 1

//DEBUG: After changing list in general, changing items + reload states does not work

