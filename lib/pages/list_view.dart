import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/objects/item.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';

import 'item_view.dart';

// ignore: must_be_immutable
class ItemList extends StatefulWidget {
   ItemListState state;
  final ShoppingList list;
  final Function onTabClickedCallback;

  ItemList(this.list, {this.onTabClickedCallback});

  @override
  State<StatefulWidget> createState() {
    state = ItemListState(list, onTabClickedCallback: onTabClickedCallback);
    return state;
  }
}

class ItemListState extends State<ItemList> {
  final ShoppingList list;
  final Function onTabClickedCallback;
  List<ListItemWidget> activeWidgets = [];

  ItemListState(this.list, {this.onTabClickedCallback});

  //TODO: hmmmmm, not like this!
  void notifyListChanged(){
    if (mounted) {
      setState(() {});
      activeWidgets.forEach((element) {
        if (element.state != null)
          element.state.setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (list == null) {
      return AddListButton(callback: onTabClickedCallback);
    }
    activeWidgets.clear();
    Widget listW = Container(
      child: ListView.builder(
        key: Key(list.items.length.toString()),
        padding: EdgeInsets.zero,
        cacheExtent: 100,
        itemCount: list.items.length,
        itemBuilder: (BuildContext context, int index) {
          Item item = list.items[index];
          ListItemWidget widget = ListItemWidget(item,
            index: index,
            deleteCallback: () {
              FirestoreSaver().removeItemFromList(list, item);
            },
          );
          activeWidgets.add(widget);
          return widget;
        },
      ),
    );
    return listW;
  }
}

////////////
//Add/Page//
////////////

class AddListButton extends StatelessWidget {
  const AddListButton({
    Key key,
    @required this.callback,
  }) : super(key: key);

  final Function callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Card(
          color: Colors.deepOrange[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
          ),
          child: InkWell(
            splashColor: Colors.white.withAlpha(30),
            onTap: () {
              if (callback != null) callback.call();
            },
            child: Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Text(
                    'Liste hinzufügen',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
