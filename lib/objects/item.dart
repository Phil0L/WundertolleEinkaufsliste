
import 'dart:convert';

import 'package:wundertolle_einkaufsliste/objects/database/savable.dart';

class Item implements Savable, ItemUpdater{
  String name;
  String id;
  String description;
  bool hasQuantity;
  int quantity;
  String quantityName;
  bool checked;

  Item({this.name = 'Error', this.id, this.description = 'Error: Failed to load the data of this item!', this.hasQuantity = false, this.quantity = 0, this.quantityName = '', this.checked = false}){
    if (this.id == null)
      this.id = IDRandom().getSaltKeyID();
  }

  @override
  String toString() {
    return this.name;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> out = {
      'name': this.name,
      'description': this.description,
      'hasQuantity': this.hasQuantity
    };
    if (this.hasQuantity){
      out['quantity'] = this.quantity;
      if (this.quantityName != null)
        out['quantityName'] = this.quantityName;
    }
    return out;
  }

  @override
  String toJsonString(){
    return json.encode(toJson());
  }

  @override
  Item fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    String description = json['description'];
    bool hasQuantity = json['hasQuantity'];
    int quantity = json['quantity'];
    String quantityName = json['quantityName'];
    if (description == null)
      description = '';
    if (hasQuantity == null)
      hasQuantity = false;
    return Item(name: name, description: description, hasQuantity: hasQuantity, quantityName: quantityName, quantity: quantity);
  }

  @override
  void onCreate() {

  }

  @override
  void onDelete() {

  }

  @override
  void onModify(Item newItem) {

  }

  @override
  void onUpdate(Item newItem) {

  }

}

abstract class ItemUpdater{

  void onUpdate(Item newItem);

  void onCreate();

  void onDelete();

  void onModify(Item newItem);

}