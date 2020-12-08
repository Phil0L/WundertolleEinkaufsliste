import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/database/savable.dart';
import 'package:wundertolle_einkaufsliste/objects/item.dart';

class ShoppingList implements Savable<ShoppingList>, ShoppingListUpdater {
  String _name;
  String _id;
  int _icon;
  List<Item> _items;

  ShoppingList();

  ShoppingList._(this._name, this._id, this._icon, this._items);

  String get name => _name;

  String get id => _id;

  List get items => _items;

  int get iconData => _icon;

  IconData get icon{
    if (_icon != null) return IconData(_icon, fontFamily: 'MaterialIcons');
    return null;
  }

  ListModifier get modify => ListModifier(this);

  @override
  void onUpdate() {}

  @override
  void onCreate() {}

  @override
  void onDelete() {}

  @override
  void onItemAdded(Item item) {}

  @override
  void onItemModified(Item item) {}

  @override
  void onItemRemoved(Item item) {}

  @override
  String toString() {
    return this._name +
        ":[id:" +
        this._id +
        ", size:" +
        this._items.length.toString() +
        "]";
  }

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ShoppingList) if (other._id == _id) return true;
    return false;
  }

  ShoppingList clone() {
    return ShoppingListBuilder(name: name, icon: _icon, id: id, items: List.from(_items).cast<Item>().toList())
        .build();
  }

  @override
  ShoppingList fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    String id = json['id'];
    int iconCodePoint = json['iconCodePoint'];
    var items = json['items'];
    List<Item> itemsList = <Item>[];
    items.values.forEach((itemJson) {
      itemsList.add(Item().fromJson(itemJson));
    });
    return ShoppingListBuilder(
            name: name, id: id, icon: iconCodePoint, items: itemsList)
        .build();
  }

  @override
  Map<String, dynamic> toJson() {
    var items = {};
    int i = 0;
    _items.forEach((item) {
      items[i.toString()] = item.toJson();
      i += 1;
    });
    Map<String, dynamic> out = {'name': _name, 'id': _id};
    if (_icon != null) out['iconCodePoint'] = _id;
    out['items'] = items;
    return out;
  }

  @override
  String toJsonString(){
    return json.encode(toJson());
  }


}

class ShoppingListBuilder {
  String _name;
  String _id;
  int _icon;
  List<Item> _items;

  ShoppingListBuilder({@required String name, @required int icon, id, items}) {
    _name = name;
    _icon = icon;
    if (id == null) _id = IDRandom().getSaltKeyID();
    else _id = id;
    if (items != null)
      this._items = items;
    else
      this._items = [];
  }

  set items(List<Item> value) {
    _items = value;
  }

  void add(Item value) {
    _items.add(value);
  }

  void addAll(List<Item> items) {
    _items.addAll(_items);
  }

  set icon(int value) {
    _icon = value;
  }

  set id(String value) {
    _id = value;
  }

  set name(String value) {
    _name = value;
  }

  ShoppingList build() {
    return ShoppingList._(_name, _id, _icon, _items);
  }
}

abstract class ShoppingListUpdater {
  void onUpdate();

  void onCreate();

  void onDelete();

  void onItemAdded(Item item);

  void onItemRemoved(Item item);

  void onItemModified(Item item);
}

class ListModifier {
  final ShoppingList list;

  ListModifier(this.list);

  void addItem(Item item) {
    list._items.add(item);
  }

  void removeItem(Item item) {
    for (Item i in list._items) {
      if (i.id == item.id) {
        list._items.remove(i);
      }
    }
  }
}
