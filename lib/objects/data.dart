import 'package:wundertolle_einkaufsliste/pages/home.dart';

import 'list.dart';

class Data {
  static List<ShoppingList> _lists = <ShoppingList>[];

  static void addList(ShoppingList list) {
    _lists.add(list);
    Bar.state.notify();
  }

  static void updateList(ShoppingList list) {
    ShoppingList preList = getListByID(list.id);
    if (preList != null)
      preList.setItems(list.items);
    else {
      Data.addList(list);
    }
    Bar.state.notify();
  }

  static void removeListByID(String id){
    ShoppingList toRemove;
    _lists.forEach((element) {
      if (element.id == id)
        toRemove = element;
    });
    if (toRemove != null)
      _lists.remove(toRemove);
    Bar.state.notify();
  }

  static List<ShoppingList> getLists() {
    return _lists;
  }

  static ShoppingList getListByID(String id) {
    for (ShoppingList list in _lists) {
      if (list.id == id) return list;
    }
    return null;
  }
}
