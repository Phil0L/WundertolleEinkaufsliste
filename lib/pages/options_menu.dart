import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/data.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';

// ignore: must_be_immutable
class OptionsMenu extends StatefulWidget {
  OptionsMenuState state;

  OptionsMenu({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = OptionsMenuState();
    return state;
  }
}

enum OptionItems { DELETE_LIST }

class OptionsMenuState extends State<OptionsMenu> {
  bool hasDeleteList;

  OptionsMenuState({this.hasDeleteList = true});

  updateItems({bool hasDeleteList}) {
    setState(() {
      this.hasDeleteList = hasDeleteList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) {
        List<PopupMenuEntry<dynamic>> out = [];
        if (hasDeleteList)
          out.add(PopupMenuItem(
            child: Text('Liste löschen'),
            value: OptionItems.DELETE_LIST,
          ));
        return out;
      },
      onSelected: (value) {
        if (value == OptionItems.DELETE_LIST) {
          int index = BarState.controller.index;
          ShoppingList list = Data.getLists()[index];
          FirestoreDeleter().deleteList(list);
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

class Appreciation extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FireStoreGetter().getDocument(
            documentReference: FireStoreLoader.firestore.collection('likes').doc('likes'),
            callback: (snapshot) {
              int likes = snapshot.data()['likes'];
              likes += 1;
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                  SnackBar(
                      content: Text('The app has been appreciated ' + likes.toString() + ' times!'),
                  )
              );
              FirestoreSaver().saveLikes(likes);
            }
        );
      },
      child: Icon(Icons.favorite),
    );
  }
  
}
