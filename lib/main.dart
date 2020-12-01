
import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';

void main() {
  runApp(Home());
  initializeDatabase();
}



