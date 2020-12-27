import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/database/savable.dart';
import 'package:wundertolle_einkaufsliste/objects/item.dart';
import 'package:wundertolle_einkaufsliste/objects/user.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';

import 'data.dart';

class ShoppingList implements Savable<ShoppingList>, ShoppingListUpdater {
  String _name;
  String _id;
  int _icon;
  List<Item> _items;
  List<User> _user;

  ShoppingList();

  ShoppingList._(this._name, this._id, this._icon, this._items, this._user);

  String get name => _name;

  String get id => _id;

  List get items => _items;

  List<User> get user => _user;

  int get iconData => _icon;

  IconData get icon {
    if (_icon != null) return IconData(_icon, fontFamily: 'MaterialIcons');
    return null;
  }

  ListModifier get modify => ListModifier(this);

  @override
  void onUpdate() {
    _items.forEach((element) => element.onUpdate());
  }

  @override
  void onCreate() {
    print("List: $this has been created");
  }

  @override
  void onDelete() {
    print("List: $this has been deleted");
  }

  @override
  void onItemAdded(Item item) {
    _items.add(item);
    print("Item: $item has been added to List: $this");
    item.onCreate(this);
    MainPage.state.reloadTab(this);
  }

  @override
  void onItemModified(Item newItem, Item oldItem) {
    if (newItem.toJsonString() == oldItem.toJsonString()) return;
    oldItem.onModify(newItem);
    print("Item: $oldItem in List: $this has benn modified to Item: $newItem");
    MainPage.state.reloadItemInTab(this, oldItem);
  }

  @override
  void onItemRemoved(Item item) {
    _items.remove(item);
    print("Item: $item has been removed in List: $this");
    item.onDelete();
    MainPage.state.reloadTab(this);
  }

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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingList &&
          runtimeType == other.runtimeType &&
          _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  ShoppingList clone() {
    return ShoppingListBuilder(
            id: id,
            name: Copy.copy(name),
            icon: Copy.copy(_icon),
            items: List.from(_items).cast<Item>().toList(),
            users: List.from(_user).cast<User>().toList())
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
    var users = json['users'];
    List<User> usersList = <User>[];
    users.values.forEach((userJson) {
      usersList.add(User().fromJson(userJson));
    });
    ShoppingList out = ShoppingListBuilder(
            name: name, id: id, icon: iconCodePoint, items: itemsList, users: usersList)
        .build();
    itemsList.forEach((item) => item.parent = out);
    return out;
  }

  @override
  Map<String, dynamic> toJson() {
    var items = {};
    var users = {};
    int i = 0;
    _items.forEach((item) {
      items[i.toString()] = item.toJson();
      i += 1;
    });
    i = 0;
    _user.forEach((user) {
      users[i.toString()] = user.toJson();
      i += 1;
    });
    Map<String, dynamic> out = {'name': _name, 'id': _id};
    if (_icon != null) out['iconCodePoint'] = _id;
    out['items'] = items;
    out['users'] = users;
    return out;
  }

  @override
  String toJsonString() {
    return json.encode(toJson());
  }
}

class ShoppingListBuilder {
  String _name;
  String _id;
  int _icon;
  List<Item> _items;
  List<User> _users;

  ShoppingListBuilder(
      {@required String name, @required int icon, id, items, users}) {
    _name = name;
    _icon = icon;
    if (id == null)
      _id = IDRandom().getSaltKeyID();
    else
      _id = id;
    if (items != null)
      this._items = items;
    else
      this._items = [];
    if (users != null)
      this._users = users;
    else
      this._users = [];
  }

  set items(List<Item> value) {
    _items = value;
  }

  void addItem(Item value) {
    _items.add(value);
  }

  void addItems(List<Item> items) {
    _items.addAll(items);
  }

  set users(List<User> value) {
    _users = value;
  }

  void addUser(User value) {
    _users.add(value);
  }

  void addUsers(List<User> users) {
    _users.addAll(users);
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
    return ShoppingList._(_name, _id, _icon, _items, _users);
  }
}

abstract class ShoppingListUpdater {
  void onUpdate();

  void onCreate();

  void onDelete();

  void onItemAdded(Item item);

  void onItemRemoved(Item item);

  void onItemModified(Item item, Item item2);
}

class ListModifier {
  final ShoppingList list;

  ListModifier(this.list);

  void addItem(Item item) {
    list._items.add(item);
  }

  void removeItem(Item item) {
    List<Item> toRemove = <Item>[];
    for (Item i in list._items) {
      if (i.id == item.id) {
        toRemove.add(item);
      }
    }
    toRemove.forEach((element) => list._items.remove(element));
  }

  void updateItem(Item newItem) {
    int x = 0;
    for (Item i in list._items) {
      if (i.id == newItem.id) list._items[x] = newItem;
      x++;
    }
  }
}
