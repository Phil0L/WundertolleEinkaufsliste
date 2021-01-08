import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/data.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/objects/user.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';
import 'package:wundertolle_einkaufsliste/start/app_link.dart';
import 'package:wundertolle_einkaufsliste/start/start_manager.dart';

class Invitation extends StartLink{

  final String listID;
  final String userName;

  Invitation(link, this.listID, {this.userName}) : super(link);

  ShoppingList get shoppingList => Data.getListByID(listID);

  String getDisplayText({String listName}){
    if (userName == "" && listName == null)
      return "Du wurdest eingeladen einer Liste beizutreten!";
    else if (userName == null)
      return "Du wurdest eingeladen \"$listName\" beizutreten!";
    else if (listName == null)
      return "$userName hat dich eingeladen einer Liste beizutreten!";
    else
      return "$userName hat dich eingeladen \"$listName\" beizutreten!";
  }

  void onInvitation() {
    ShoppingList list = this.shoppingList;
    if (list != null) {
      onListLoaded(list);
    } else {
      FireStoreLoader((_) {
        FireStoreGetter().getListDocument(
            this.listID, callback: (snapshot) {
          ShoppingList list = ShoppingList().fromJson(snapshot.data());
          if (list == null)
            showDialog(
                context: Home.startManager.context,
                builder: (BuildContext context) {
                  print("Opening Invite Dialog");
                  return (InviteDialog(
                      message: "Es ist ein Fehler bei der Einladung aufgetreten",
                      icon: Icons.error_outline,
                      hasError: true,
                  ));
                }
            );
          else
            onListLoaded(list);
        });
      });
    }
  }

  void onListLoaded(ShoppingList list){
    if (list.user.contains(User.me))
      showDialog(
          context: Home.startManager.context,
          builder: (BuildContext context) {
            print("Opening Invite Dialog");
            return (InviteDialog(
              message: "Du bist der Liste bereits beigetreten",
              icon: Icons.error_outline,
              hasError: true,
            ));
          }
      );
    else
    showDialog(
        context: Home.startManager.context,
        builder: (BuildContext context) {
          print("Opening Invite Dialog");
          return (InviteDialog(
              message: this.getDisplayText(listName: list.name),
              list: list,
              icon: list.icon
          ));
        }
    );
  }

}