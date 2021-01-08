import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/objects/user.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';
import 'package:wundertolle_einkaufsliste/start/invite.dart';

String testOnOpenFromLink(String link) {
  RegExp regex = RegExp(
      r"^https:\/\/wundertolle.einkaufsliste\/\?list=(\d+)&\?inviter=(.*)");
  final matcher = regex.firstMatch(link);
  String listID = matcher.group(1);
  String inviter = matcher.group(2);
  return listID + " | " + inviter;
}

void onOpenFromLink(String link) {
  PhoneInfo.getMe().then((value) {
    User.me = value;
    RegExp regex = RegExp(
        r"^https:\/\/wundertolle.einkaufsliste\/listinvite\/\?list=(\d+)&\?inviter=(.*)");
    final matcher = regex.firstMatch(link);
    String listID = matcher.group(1);
    String inviter = matcher.group(2);
    Home.startManager
        .registerStartLink(Invitation(link, listID, userName: inviter));
  });
}

class InviteDialog extends StatelessWidget {
  final String message;
  final bool hasError;
  final IconData icon;
  final ShoppingList list;

  InviteDialog(
      {@required this.message, this.hasError: false, this.icon, this.list});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Card(
        color: Colors.white,
        elevation: 30,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Wrap(children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Row(
                    children: [
                      icon == null
                      ? SizedBox()
                      : Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: Icon(
                          icon,
                          size: 50,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          message,
                          textAlign: icon == null ? TextAlign.center : TextAlign.start,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        child: Text(hasError ? 'Schließen' : 'Abbrechen'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    hasError
                        ? SizedBox()
                        : TextButton(
                            child: Text('Liste beitreten'),
                            onPressed: () {
                              ShoppingList newList = list.clone();
                              newList.modify.addUser(User.me);
                              FirestoreSaver().updateList(newList, callback: () => Navigator.of(context).pop());
                            },
                          ),
                  ],
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
