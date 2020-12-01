import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/data.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/pages/add_item.dart';
import 'package:wundertolle_einkaufsliste/pages/add_list.dart';
import 'package:wundertolle_einkaufsliste/pages/list_view.dart';
import 'package:wundertolle_einkaufsliste/pages/options_menu.dart';

const String app_name = 'Wundertolle Einkaufsliste';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Bar(),
    );
  }
}

class Bar extends StatefulWidget {
  static BarState state;

  @override
  State<StatefulWidget> createState() {
    state = BarState(Data.getLists());
    return state;
  }
}

class BarState extends State<Bar> with TickerProviderStateMixin {
  final List<ShoppingList> lists;
  static TabController controller;
  static final OptionsMenu threeDot = OptionsMenu(key: UniqueKey(),);

  static final Map<ShoppingList, ItemList> pages = {};

  VoidCallback swipeListener = () {
    print('changing from ' + controller.previousIndex.toString() + " to " + controller.index.toString());
    if (controller.index == controller.length -1) {
      FloatActionButton.state.hide();
      threeDot.state.updateItems(hasDeleteList: false);
    }
    if (controller.previousIndex == controller.length -1 || controller.index != controller.length -1) {
      FloatActionButton.state.show();
      threeDot.state.updateItems(hasDeleteList: true);
    }
  };

  static bool crossedBorder;
  VoidCallback swipeAnimationListener = () {
    double position = controller.animation.value;
    int border = controller.length -2;
    bool newCrossedBorder = (position > border);
    if (newCrossedBorder == crossedBorder)
      return;
    if (position > border){
      FloatActionButton.state.hide();
      threeDot.state.updateItems(hasDeleteList: false);
    }
    else {
      FloatActionButton.state.show();
      threeDot.state.updateItems(hasDeleteList: true);
    }
    crossedBorder = newCrossedBorder;
  };

  BarState(this.lists);

  void notify() {
    int index = controller.index;
    int length = controller.length;
    controller = TabController(length: lists.length + 1, vsync: this);
    controller.addListener(swipeListener);
    controller.animation.addListener(swipeAnimationListener);
    setState(() {
      if (index == length)
        controller.animateTo(controller.length - 1);
      else
        controller.animateTo(index);
    });
  }

  @override
  void initState() {
    controller = TabController(length: lists.length + 1, vsync: this);
    controller.addListener(swipeListener);
    controller.animation.addListener(swipeAnimationListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key(controller.length.toString()),
      appBar: AppBar(
        title: Text(app_name),
        backgroundColor: Colors.deepOrange[700],
        actions: [
          Appreciation(),
          threeDot,
        ],
        bottom: TabBar(
          key: Key(controller.length.toString()),
          controller: controller,
          isScrollable: true,
          indicatorColor: Colors.green[800],
          tabs: buildTabBarContent(),
          onTap: ((int position) =>
            tabClicked(position, from: controller.previousIndex)),
        ),
      ),
      body: TabBarView(
        key: Key(controller.length.toString()),
        controller: controller,
        children: buildTabBarViewContent(),
      ),
      floatingActionButton: FloatActionButton(),
    );
  }

  List<Tab> buildTabBarContent() {
    final List<Tab> list = lists.map((ShoppingList list) {
      if (list.icon != null)
        return Tab(
          child: Row(
            children: [
              Icon(list.icon),
              Text(list.name),
            ],
          ),
        );
      else
        return Tab(
          text: list.name,
        );
    }).toList();
    list.add(Tab(
      child: Row(
        children: [
          Icon(Icons.add),
          Text('Liste hinzufügen'),
        ],
      ),
    ));
    return list;
  }

  List<Widget> buildTabBarViewContent() {
    final List<Widget> list = lists.map((ShoppingList list) {
      ItemList view = ItemList(list);
      if (view.state != null || pages[list] == null)
        pages[list] = view;
      return view;
    }).toList();
    list.add(ItemList(null, callback: addList));
    return list;
  }

  void tabClicked(int position, {int from}) {
    print('switched tab from $from to $position');
    int tabLength = lists.length;
    if (position == tabLength) {
      addList();
      controller.animateTo(from);
    }
  }

  void addList() {
    print('opening dialog');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddDialog();
        });
  }
}

class FloatActionButton extends StatefulWidget {
  static FloatActionButtonState state;

  const FloatActionButton({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    state = FloatActionButtonState(true);
    return state;
  }
}

class FloatActionButtonState extends State<FloatActionButton> {
  bool visible;

  void show(){
    if (mounted)
      setState(() {
        visible = true;
      });
  }

  void hide(){
    if (mounted)
      setState(() {
        visible = false;
      });
  }

  FloatActionButtonState(this.visible);

  @override
  Widget build(BuildContext context) {
    if (visible)
      return FloatingActionButton(
        onPressed: () => addItem(),
        backgroundColor: Colors.deepOrange[700],
        child: Icon(Icons.add, size: 30,),
      );
    else
      return SizedBox();
  }

  void addItem() {
    print('opening dialog');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddItemDialog();
        });
  }
}
