import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:wundertolle_einkaufsliste/objects/data.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/objects/item.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/pages/home.dart';

class AddItemDialog extends StatelessWidget {
  static final String nameText = "Name";
  static final String descriptionText = "Beschreibung";
  static final String useQuantityText = "Mit Menge";
  static final String quantityNameText = "Einheit";

  static final TextEditingController nameController = TextEditingController();
  static final TextEditingController descriptionController =
      TextEditingController();
  static final TextEditingController quantityNameController =
      TextEditingController();
  static int quantityAmount = 0;
  static bool hasQuantity = false;

  @override
  Widget build(BuildContext context) {
    quantityAmount = 1;
    hasQuantity = false;
    nameController.text = '';
    descriptionController.text = '';
    quantityNameController.text = '';

    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Card(
        color: Colors.white,
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Wrap(children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: DialogContent(),
          ),
        ]),
      ),
    );
  }
}

class DialogContent extends StatelessWidget {
  DialogContent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          autofocus: true,
          controller: AddItemDialog.nameController,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: AddItemDialog.nameText,
            fillColor: Colors.grey[500],
          ),
        ),
        TextField(
          keyboardType: TextInputType.multiline,
          controller: AddItemDialog.descriptionController,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: AddItemDialog.descriptionText,
            fillColor: Colors.grey[500],
          ),
        ),
        Quantity(
          startSelected: false,
          text: "Mit Menge",
          unit: "Einheit",
          startValue: 1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                child: Text('Abbrechen'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            TextButton(
              child: Text('Bestätigen'),
              onPressed: () {
                if (confirmed()) Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }
}

bool confirmed() {
  Item item = readItem();
  if (item.name == '') return false;
  AddItemDialog.nameController.clear();
  AddItemDialog.descriptionController.clear();
  AddItemDialog.quantityNameController.clear();
  addItem(item);
  return true;
}

Item readItem() {
  String name = AddItemDialog.nameController.text;
  String description = AddItemDialog.descriptionController.text;
  bool hasQuantity = AddItemDialog.hasQuantity;
  if (!hasQuantity) {
    Item item = Item(name: name, description: description);
    return item;
  } else {
    int amount = AddItemDialog.quantityAmount;
    String amountName = AddItemDialog.quantityNameController.text;
    Item item = Item(
        name: name,
        description: description,
        hasQuantity: true,
        quantity: amount,
        quantityName: amountName);
    return item;
  }
}

void addItem(Item item) {
  int listIndex = MainPageState.tabController.index;
  ShoppingList list = Data.lists[listIndex];
  FirestoreSaver().addItemToList(list, item);
}

class Quantity extends StatefulWidget {
  final bool startSelected;
  final String text;
  final String unit;
  final int startValue;

  Quantity(
      {this.startSelected: false,
      this.text: "",
      this.unit: "",
      this.startValue: 1});

  @override
  State<StatefulWidget> createState() {
    return QuantityState(startSelected, text, unit, startValue);
  }
}

class QuantityState extends State<Quantity> {
  bool active;
  final String text;
  final String unit;
  final int startValue;

  QuantityState(this.active, this.text, this.unit, this.startValue);

  void activateQuantity() {
    setState(() {
      active = true;
      AddItemDialog.hasQuantity = true;
    });
  }

  void deactivateQuantity() {
    setState(() {
      active = false;
      AddItemDialog.hasQuantity = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        generalLayout(),
        amountLayout(active),
      ],
    );
  }

  Widget generalLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          child: Checkbox(
            value: active,
            onChanged: (checked) {
              if (checked)
                activateQuantity();
              else
                deactivateQuantity();
            },
          ),
        ),
        Text(AddItemDialog.useQuantityText)
      ],
    );
  }

  Widget amountLayout(bool active) {
    if (active)
      return Row(
        children: [
          SizedBox(
            width: 120,
            child: SpinBox(

              direction: Axis.horizontal,
              min: 0,
              max: 1000,
              step: 1,
              value: AddItemDialog.quantityAmount.toDouble(),
              spacing: 0,
              decoration: InputDecoration(border: InputBorder.none),
              onChanged: ((amount) {
                AddItemDialog.quantityAmount = amount.toInt();
              }),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: AddItemDialog.quantityNameController,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AddItemDialog.quantityNameText,
                fillColor: Colors.grey[500],
              ),
            ),
          )
        ],
      );
    else
      return SizedBox(
        height: 0,
      );
  }
}
