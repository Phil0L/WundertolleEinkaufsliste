import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/item.dart';

class ShoppingList {
  String name;
  String id;
  IconData icon;
  List<Item> _items;

  ShoppingList(this.name, {this.icon}) {
    _items = <Item>[];
    id = _getSaltKeyID();
  }

  ShoppingList withID(String id) {
    this.id = id;
    return this;
  }

  ShoppingList withItems(List<Item> items) {
    _items = items;
    return this;
  }

  List<Item> items() {
    return _items;
  }

  ShoppingList addItem(Item item) {
    _items.add(item);
    return this;
  }

  void deleteItem(Item item) {
    _items.remove(item);
  }

  void deleteItemByIndex(int index) {
    _items.removeAt(index);
  }

  static String _getSaltKeyID() {
    return DateTime.now().toString().replaceAll(new RegExp(r'[-:. ]*'), '') +
        _getRandomString(5);
  }

  static const String _chars = '1234567890';
  static Random _rnd = Random();

  static String _getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  String toString() {
    return this.name;
  }
}
