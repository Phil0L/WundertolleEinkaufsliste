import 'package:flutter/cupertino.dart';
import 'package:wundertolle_einkaufsliste/objects/item.dart';

import '../list.dart';

class ShoppingListSavable {
  String name;
  String id;
  int iconCodePoint;
  List<Item> items;

  ShoppingListSavable({this.name, this.id, this.iconCodePoint, this.items});

  ShoppingListSavable withShoppingList(ShoppingList list) {
    this.name = list.name;
    this.id = list.id;
    this.iconCodePoint = (list.icon == null ? null : list.icon.codePoint);
    this.items = list.items();
    return this;
  }

  ShoppingList toShoppingList() {
    return ShoppingList(name, icon: (iconCodePoint == null ? null : IconData(iconCodePoint, fontFamily: 'MaterialIcons'))).withID(this.id).withItems(items);
  }

  factory ShoppingListSavable.fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    String id = json['id'];
    int iconCodePoint = json['iconCodePoint'];
    var items = json['items'];
    List<Item> itemsList = <Item>[];
    items.values.forEach((itemJson) {
      itemsList.add(Item.fromJson(itemJson));
    });
    return ShoppingListSavable(
        name: name, id: id, iconCodePoint: iconCodePoint, items: itemsList);
  }

  Map<String, dynamic> toJson() {
    var items = {};
    int i = 0;
    this.items.forEach((item) {
      items[i.toString()] = item.toJson();
      i += 1;
    });
    Map<String, dynamic> out = {
      'name': this.name,
      'id': this.id
    };
    if (iconCodePoint != null)
      out['iconCodePoint'] = this.iconCodePoint;
    out['items'] = items;
    return out;
  }
}

class ListParser{

  static ShoppingList parse(Map<String, dynamic> data){
    return ShoppingListSavable.fromJson(data).toShoppingList();
  }

}
