
import 'package:wundertolle_einkaufsliste/objects/user.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';

import 'item.dart';
import 'list.dart';

class Data {
  static List<ShoppingList> lists = <ShoppingList>[];

  @deprecated //expensive runtime! try not to use!
  static ShoppingList getListByID(String id) {
    for (ShoppingList list in lists) {
      if (list.id == id) return list;
    }
    return null;
  }

  static void onUpdate() {
    for (ShoppingList list in lists) list.onUpdate();
  }

  static void onListAdded(ShoppingList list) {
    if (!list.user.contains(User.me)) return;
    lists.add(list);
    MainPage.state.reloadTabList();
    list.onCreate();
  }

  static void onListRemoved(ShoppingList list) {
    if (!list.user.contains(User.me)) return;
    lists.remove(list);
    MainPage.state.reloadTabList();
    list.onDelete();
  }

  static void onListUpdate(ShoppingList newList, ShoppingList oldList) {
    if (!newList.user.contains(User.me)) return;
    if (oldList.toJsonString() == newList.toJsonString()) return;
    List<Item> existingItems = List.from(oldList.items).cast<Item>().toList();
    newList.items.forEach((item) {
      if (existingItems.contains(item)) {
        oldList.onItemModified(
            item,
            oldList.items
                .firstWhere((element) => element.id == item.id, orElse: null));
        existingItems.remove(item);
      } else
        // Item is born!
        oldList.onItemAdded(item);
    });
    if (existingItems.isNotEmpty)
      // Item has died!
      existingItems.forEach((element) => oldList.onItemRemoved(element));
  }
}

class Copy {
  static T copy<T>(T toCopy) {
    return List.from(List.filled(1, toCopy))[0];
  }
}
