
class Item{
  String name;
  String description;
  bool hasQuantity;
  int quantity;
  String quantityName;
  bool checked;

  Item({this.name = '', this.description = '', this.hasQuantity = false, this.quantity = 0, this.quantityName = '', this.checked = false});

  @override
  String toString() {
    return this.name;
  }

  factory Item.fromJson(Map<String, dynamic> json) {
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

}