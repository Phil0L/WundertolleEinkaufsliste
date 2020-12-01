import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/item.dart';

// ignore: must_be_immutable
class ListItemWidget extends StatefulWidget {
  final Item item;
  final int index;
  final GestureTapCallback deleteCallback;
  ListItemWidgetState state;

  ListItemWidget(this.item, {this.index, this.deleteCallback});

  @override
  State<StatefulWidget> createState() {
    state = ListItemWidgetState(item, index: index, deleteCallback: deleteCallback);
    return state;
  }
}

class ListItemWidgetState extends State<ListItemWidget> {
  final Item item;
  final int index;
  final GestureTapCallback deleteCallback;

  ListItemWidgetState(this.item, {this.index, this.deleteCallback});

  @override
  Widget build(BuildContext context) {
    //print('rebuilding item ' + item.name);
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 5, right: 5),
      //height: 100,
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 50,
                child: Checkbox(
                  value: item.checked,
                  onChanged: (checked) {
                    setState(() {
                      this.item.checked = checked;
                    });
                  },
                ),
              ),
              TextFields(item: item),
              SizedBox(width: 10,),
              Quantity(item: item),
              Delete(item: item, index: index, callback: deleteCallback,),
            ],
          ),
        ),
      ),
    );
  }
}

class Delete extends StatelessWidget {
  const Delete({
    Key key,
    @required this.item, this.index, this.callback
  }) : super(key: key);

  final Item item;
  final int index;
  final GestureTapCallback callback;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: callback,
        child: Padding(
          padding: EdgeInsets.only(
            right: 10,
          ),
          child: Icon(
            Icons.delete_outline,
            size: 30,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }
}

class Quantity extends StatelessWidget {
  const Quantity({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    if (item.hasQuantity)
      return Text(
        item.quantity.toString() + ' ' + item.quantityName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    else
      return SizedBox(width: 0);
  }
}

class TextFields extends StatelessWidget {
  const TextFields({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Name(item: item),
            Description(item: item),
          ],
        ),
      ),
    );
  }
}

class Description extends StatelessWidget {
  const Description({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    if (item.description != null && item.description != '')
      return Text(
        item.description,
        textAlign: TextAlign.left,
        overflow: TextOverflow.clip,
        maxLines: 3,
      );
    else
      return SizedBox(height: 0,);
  }
}

class Name extends StatelessWidget {
  const Name({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Text(
      item.name,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}