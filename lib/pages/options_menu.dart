import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:wundertolle_einkaufsliste/objects/data.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/objects/user.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';

// ignore: must_be_immutable
class OptionsMenu extends StatefulWidget {
  OptionsMenuState state;

  OptionsMenu({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = OptionsMenuState();
    return state;
  }
}

enum OptionItems { DELETE_LIST, LEAVE_LIST }

class OptionsMenuState extends State<OptionsMenu> {
  bool hasDeleteList;
  bool hasLeaveList;

  OptionsMenuState({this.hasDeleteList: true, this.hasLeaveList: true});

  updateItems({bool hasDeleteList, bool hasLeaveList}) {
    setState(() {
      this.hasDeleteList = hasDeleteList;
      this.hasLeaveList = hasLeaveList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        List<PopupMenuEntry<dynamic>> out = [];
        if (hasDeleteList)
          out.add(
            PopupMenuItem(
              child: Text('Liste löschen'),
              value: OptionItems.DELETE_LIST,
            ),
          );
        if (hasLeaveList)
          out.add(
            PopupMenuItem(
              child: Text('Liste verlassen'),
              value: OptionItems.LEAVE_LIST,
            )
          );
        return out;
      },
      onSelected: (value) {
        switch (value) {
          case OptionItems.DELETE_LIST:
            int index = MainPageState.tabController.index;
            ShoppingList list = Data.lists[index];
            FirestoreDeleter().deleteList(list);
            break;
          case OptionItems.LEAVE_LIST:
            int index = MainPageState.tabController.index;
            ShoppingList list = Data.lists[index];
            ShoppingList newList = list.clone();
            newList.modify.removeUser(User.me);
            FirestoreSaver().updateList(newList);
            break;
        }
      },
    );
  }
}

class OptionsItem extends StatelessWidget {

  const OptionsItem({
    Key key,
    @required this.icon,
    @required this.name,
  }) : super(key: key);

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Icon(icon), Text(name)],
    );
  }
}

class Appreciation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FireStoreGetter().getDocument(
            documentReference:
                FireStoreLoader.firestore.collection('likes').doc('likes'),
            callback: (snapshot) {
              int likes = snapshot.data()['likes'];
              likes += 1;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('The app has been appreciated ' +
                    likes.toString() +
                    ' times!'),
              ));
              FirestoreSaver().saveLikes(likes);
            });
      },
      child: Icon(Icons.favorite),
    );
  }
}

class ShareOption extends StatefulWidget {
  _ShareOptionState currentState;

  @override
  _ShareOptionState createState() => currentState = _ShareOptionState();
}

class _ShareOptionState extends State<ShareOption> {
  bool active;

  _ShareOptionState({this.active: true});

  updateItems({bool visible}) {
    setState(() {
      this.active = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.active)
      return GestureDetector(
        onTap: () {
          int index = MainPageState.tabController.index;
          ShoppingList list = Data.lists[index];
          User me = User.me;
          String link =
              "https://wundertolle.einkaufsliste/listinvite/?list=${list.id}&?inviter=${me.deviceName}";
          String message =
              "Trete meiner Wundertollen Einkaufsliste bei: $link";
          Share.share(message);
        },
        child: Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Icon(Icons.send),
        ),
      );
    return SizedBox();
  }
}
