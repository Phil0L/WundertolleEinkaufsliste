
import 'package:wundertolle_einkaufsliste/pages/home.dart';

import 'list.dart';

class Data {
  static List<ShoppingList> lists = <ShoppingList>[];

  static ShoppingList getListByID(String id) {
    for (ShoppingList list in lists) {
      if (list.id == id) return list;
    }
    return null;
  }

  static void onUpdate(){
    for (ShoppingList list in lists)
      list.onUpdate();
  }

  static void onListAdded(ShoppingList list){
    lists.add(list);
    MainPage.state.reloadTabs();
    list.onCreate();
  }

  static void onListRemoved(ShoppingList list){
    lists.remove(list);
    MainPage.state.reloadTabs();
    list.onDelete();
  }

  static void onListUpdate(ShoppingList newList, ShoppingList oldList){
    if (oldList.toJsonString() == newList.toJsonString())
      return;
    print("Update: \n" + oldList.toJsonString() + "\n->\n" + newList.toJsonString());
  }
}

