import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/objects/user.dart';

List<SelectableIcon> icons = <SelectableIcon>[
  SelectableIcon(Icons.shopping_cart_outlined),
  SelectableIcon(Icons.assignment_outlined),
  SelectableIcon(Icons.attach_money),
  SelectableIcon(Icons.home),
  SelectableIcon(Icons.fastfood),
  SelectableIcon(Icons.check_box_outlined),
  SelectableIcon(Icons.directions_car),
  SelectableIcon(Icons.book_outlined),
];

class AddDialog extends StatelessWidget {
  static IconData activeIcon;
  static final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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

void confirmed(String name, {IconData icon}) {
  print('Adding list $name to database');
  ShoppingList list = ShoppingListBuilder(name: name, icon: (icon == null ? null : icon.codePoint), users: List.filled(1, User.me)).build();
  FirestoreSaver().addList(list);
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
          controller: AddDialog.nameController,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Listenname',
            fillColor: Colors.grey[500],
          ),
        ),
        Wrap(
          children: icons,
          spacing: 10,
          runSpacing: 10,
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
                if (AddDialog.activeIcon == null)
                  confirmed(AddDialog.nameController.text);
                else
                  confirmed(AddDialog.nameController.text, icon: AddDialog.activeIcon);
                Navigator.of(context).pop();
              },
            ),
          ],
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class SelectableIcon extends StatefulWidget {
  static List<SelectableIcon> icons = <SelectableIcon>[];
  final IconData icon;
  int id;

  SelectableIcon(
    this.icon, {
    Key key,
  }) : super(key: key) {
    this.id = icons.length;
    icons.add(this);
  }

  @override
  State<StatefulWidget> createState() => SelectableIconState(icon);
}

class SelectableIconState extends State<SelectableIcon> {
  static SelectableIconState currentActive;
  bool _selected = false;
  final IconData icon;

  SelectableIconState(this.icon);

  void select() {
    setState(() {
      _selected = true;
    });
  }

  void deselect() {
    setState(() {
      _selected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (_selected ? Colors.blue[500] : Colors.grey[300]),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: InkWell(
        splashColor: Colors.white.withAlpha(30),
        onTap: () {
          if (_selected) {
            deselect();
            currentActive = null;
            AddDialog.activeIcon = null;
          } else {
            select();
            if (currentActive != null) currentActive.deselect();
            currentActive = this;
            AddDialog.activeIcon = icon;
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          child: Icon(icon),
        ),
      ),
    );
  }
}
