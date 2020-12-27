import 'dart:convert';

import 'package:wundertolle_einkaufsliste/objects/data.dart';
import 'package:wundertolle_einkaufsliste/objects/database/savable.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';

class Item implements Savable, ItemUpdater {
  String name;
  String id;
  String description;
  bool hasQuantity;
  int quantity;
  String quantityName;
  bool checked;

  ShoppingList parent;

  Item(
      {this.name = 'Error',
      this.id,
      this.description = 'Error: Failed to load the data of this item!',
      this.hasQuantity = false,
      this.quantity = 0,
      this.quantityName = '',
      this.checked = false,
      this.parent}) {
    if (this.id == null) this.id = IDRandom().getSaltKeyID();
  }

  Item clone() {
    return Item(
        name: Copy.copy(name),
        id: id,
        description: Copy.copy(description),
        hasQuantity: Copy.copy(hasQuantity),
        quantity: Copy.copy(quantity),
        quantityName: Copy.copy(quantityName),
        checked: Copy.copy(checked),
        parent: parent);
  }

  @override
  String toString() {
    return "$name:[id:$id, desc:$description]";
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> out = {
      'name': this.name,
      'id': this.id,
      'description': this.description,
      'checked': this.checked,
      'hasQuantity': this.hasQuantity
    };
    if (this.hasQuantity) {
      out['quantity'] = this.quantity;
      if (this.quantityName != null) out['quantityName'] = this.quantityName;
    }
    return out;
  }

  @override
  String toJsonString() {
    return json.encode(toJson());
  }

  @override
  Item fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    String id = json["id"];
    String description = json['description'];
    bool checked = json['checked'];
    bool hasQuantity = json['hasQuantity'];
    int quantity = json['quantity'];
    String quantityName = json['quantityName'];
    if (name == null) name = 'Error: Failed to load the data of this item!';
    if (description == null) description = '';
    if (hasQuantity == null) hasQuantity = false;
    if (checked == null) checked = false;
    if (id == null) id = IDRandom().getSaltKeyID();
    if (quantity == null) quantity = 0;
    if (quantityName == null) quantityName = '';
    return Item(
        name: name,
        id: id,
        description: description,
        checked: checked,
        hasQuantity: hasQuantity,
        quantityName: quantityName,
        quantity: quantity);
  }

  @override
  void onUpdate() {}

  @override
  void onCreate(ShoppingList parent) {
    if (parent == null) this.parent = parent;
  }

  @override
  void onDelete() {}

  @override
  void onModify(Item newItem) {
    if (name != newItem.name) name = newItem.name;
    if (description != newItem.description) description = newItem.description;
    if (checked != newItem.checked) checked = newItem.checked;
    if (hasQuantity != newItem.hasQuantity) hasQuantity = newItem.hasQuantity;
    if (quantity != newItem.quantity) quantity = newItem.quantity;
    if (quantityName != newItem.quantityName)
      quantityName = newItem.quantityName;
  }
}

abstract class ItemUpdater {
  void onUpdate();

  void onCreate(ShoppingList parent);

  void onDelete();

  void onModify(Item newItem);
}
