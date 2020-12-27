import 'package:flutter/material.dart';
import 'package:wundertolle_einkaufsliste/objects/data.dart';
import 'package:wundertolle_einkaufsliste/objects/item.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/pages/add_item.dart';
import 'package:wundertolle_einkaufsliste/pages/add_list.dart';
import 'package:wundertolle_einkaufsliste/pages/item_view.dart';
import 'package:wundertolle_einkaufsliste/pages/list_view.dart';
import 'package:wundertolle_einkaufsliste/pages/options_menu.dart';

const String app_name = 'Wundertolle Einkaufsliste';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  static MainPageState state;

  @override
  State<StatefulWidget> createState() {
    state = MainPageState(Data.lists);
    return state;
  }
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
  MainPageState(this.lists);

  // data
  final List<ShoppingList> lists;
  final Map<ShoppingList, ItemList> pages = {};

  // menus
  static final OptionsMenu dropdown = OptionsMenu(key: UniqueKey());
  static final Appreciation appreciation = Appreciation();

  //controller
  static TabController tabController;
  static bool isInNewListTab;
  final VoidCallback fabController = () {
    double position = tabController.animation.value;
    int border = tabController.length - 2;
    bool newIsInNewTab = (position > border);
    if (newIsInNewTab == isInNewListTab) return;
    if (position > border) {
      FloatActionButton.state.hide();
      dropdown.state.updateItems(hasDeleteList: false);
    } else {
      FloatActionButton.state.show();
      dropdown.state.updateItems(hasDeleteList: true);
    }
    isInNewListTab = newIsInNewTab;
  };

  void reloadTabList() {
    if (mounted)
      setState(() {
        int index = tabController.index;
        int length = tabController.length;
        tabController = TabController(length: lists.length + 1, vsync: this);
        tabController.animation.addListener(fabController);
        if (length > tabController.length) {
          if (index == length - 1)
            tabController.animateTo(tabController.length - 1);
          else
            tabController.animateTo(index - 1 > 0 ? index - 1 : 0);
        } else if (length < tabController.length) {
          if (index == length - 1)
            tabController.animateTo(tabController.length - 1);
          else
            tabController.animateTo(index);
        } else {
          tabController.animateTo(index);
        }
      });
  }

  void reloadTab(ShoppingList list){
    ItemList itemList = pages[list];
    if (itemList == null)
      return;
    itemList.state.notifyListChanged();
    print("List: $list has been reloaded");
  }

  void reloadItemInTab(ShoppingList list, Item item){
    ItemList itemList = pages[list];
    if (itemList == null)
      return;
    Map<Item, ListItemWidget> widgets = itemList.state.widgets;
    if (widgets == null)
      return;
    ListItemWidget widget = widgets[item];
    if (widget == null)
      return;
    widget.state.notifyItemChanged();
  }

  @override
  void initState() {
    tabController = TabController(length: lists.length + 1, vsync: this);
    tabController.animation.addListener(fabController);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key(tabController.length.toString()),
      appBar: AppBar(
        title: Text(app_name),
        backgroundColor: Colors.deepOrange[700],
        actions: [
          appreciation,
          dropdown,
        ],
        bottom: TabBar(
          key: Key(tabController.length.toString()),
          controller: tabController,
          isScrollable: true,
          indicatorColor: Colors.green[800],
          tabs: _buildTabBarContent(),
          onTap: ((int position) =>
              _tabClicked(position, from: tabController.previousIndex)),
        ),
      ),
      body: TabBarView(
        key: Key(tabController.length.toString()),
        controller: tabController,
        children: _buildTabBarViewContent(),
      ),
      floatingActionButton: FloatActionButton(),
    );
  }

  List<Tab> _buildTabBarContent() {
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

  List<Widget> _buildTabBarViewContent() {
    final List<Widget> list = lists.map((ShoppingList list) {
      ItemList view = ItemList(list);
      if (view.state != null || pages[list] == null) pages[list] = view;
      return view;
    }).toList();
    list.add(ItemList(null, onTabClickedCallback: _addListClicked));
    return list;
  }

  void _tabClicked(int position, {int from}) {
    int tabLength = lists.length;
    if (position == tabLength) {
      _addListClicked();
      tabController.animateTo(from);
    }
  }

  void _addListClicked() {
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

  void show() {
    if (mounted)
      setState(() {
        visible = true;
      });
  }

  void hide() {
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
        child: Icon(
          Icons.add,
          size: 30,
        ),
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
