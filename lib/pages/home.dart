import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:wundertolle_einkaufsliste/objects/data.dart';
import 'package:wundertolle_einkaufsliste/objects/database/firestore.dart';
import 'file:///E:/Code/wundertolle_einkaufsliste/lib/start/invite.dart';
import 'package:wundertolle_einkaufsliste/objects/item.dart';
import 'package:wundertolle_einkaufsliste/objects/list.dart';
import 'package:wundertolle_einkaufsliste/pages/add_item.dart';
import 'package:wundertolle_einkaufsliste/pages/add_list.dart';
import 'file:///E:/Code/wundertolle_einkaufsliste/lib/start/app_link.dart';
import 'package:wundertolle_einkaufsliste/pages/item_view.dart';
import 'package:wundertolle_einkaufsliste/pages/list_view.dart';
import 'package:wundertolle_einkaufsliste/pages/options_menu.dart';
import 'package:wundertolle_einkaufsliste/start/start_manager.dart';


const String app_name = 'Einkaufsliste';

class Home extends StatefulWidget {
  static StartManager startManager = StartManager();
  static _HomeState state;

  @override
  _HomeState createState() => state = _HomeState();
}

enum UniLinksType { string, uri }

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  static final UniLinksType _type = UniLinksType.string;

  String _latestLink = 'Unknown';
  Uri _latestUri;

  StreamSubscription _sub;

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  @override
  dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    if (_type == UniLinksType.string) {
      await initPlatformStateForStringUniLinks();
    } else {
      await initPlatformStateForUriUniLinks();
    }
    if (_latestLink != null && _latestLink != "Unknown")
      onOpenFromLink(_latestLink);
  }

  /// An implementation using a [String] link
  initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;
      setState(() {
        _latestLink = link ?? 'Unknown';
        _latestUri = null;
        try {
          if (link != null) _latestUri = Uri.parse(link);
        } on FormatException {}
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestLink = 'Failed to get latest link: $err.';
        _latestUri = null;
      });
    });

    // Attach a second listener to the stream
    getLinksStream().listen((String link) {
      print('got link: $link');
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest link
    String initialLink;
    Uri initialUri;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
      print('initial link: $initialLink');
      if (initialLink != null) initialUri = Uri.parse(initialLink);
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
      initialUri = null;
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
      initialUri = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestLink = initialLink;
      _latestUri = initialUri;
    });
  }

  /// An implementation using the [Uri] convenience helpers
  initPlatformStateForUriUniLinks() async {
    // Attach a listener to the Uri links stream
    _sub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      setState(() {
        _latestUri = uri;
        _latestLink = uri?.toString() ?? 'Unknown';
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        _latestLink = 'Failed to get latest link: $err.';
      });
    });

    // Attach a second listener to the stream
    getUriLinksStream().listen((Uri uri) {
      print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest Uri
    Uri initialUri;
    String initialLink;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialUri = await getInitialUri();
      print('initial uri: ${initialUri?.path}'
          ' ${initialUri?.queryParametersAll}');
      initialLink = initialUri?.toString();
    } on PlatformException {
      initialUri = null;
      initialLink = 'Failed to get initial uri.';
    } on FormatException {
      initialUri = null;
      initialLink = 'Bad parse the initial link as Uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _latestUri = initialUri;
      _latestLink = initialLink;
    });
  }

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
  static final ShareOption share = ShareOption();

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
      dropdown.state.updateItems(hasDeleteList: false, hasLeaveList: false);
      share.currentState.updateItems(visible: false);
    } else {
      FloatActionButton.state.show();
      dropdown.state.updateItems(hasDeleteList: true, hasLeaveList: true);
      share.currentState.updateItems(visible: true);
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

  void reloadTab(ShoppingList list) {
    ItemList itemList = pages[list];
    if (itemList == null || itemList.state == null) return;
    itemList.state.notifyListChanged();
    print("List: $list has been reloaded");
  }

  void reloadItemInTab(ShoppingList list, Item item) {
    ItemList itemList = pages[list];
    if (itemList == null) return;
    ItemListState itemListState = itemList.state;
    if (itemListState == null) return;
    Map<Item, ListItemWidget> widgets = itemListState.widgets;
    if (widgets == null) return;
    ListItemWidget widget = widgets[item];
    if (widget == null) return;
    widget.state.notifyItemChanged();
  }

  @override
  void initState() {
    tabController = TabController(length: lists.length + 1, vsync: this);
    tabController.animation.addListener(fabController);
    Home.startManager.registerEvent(loadedApp: true);
    Home.startManager.registerContext(context);
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
        title: Text(app_name,
          style: TextStyle(
            fontSize: 19,
          ),
        ),
        backgroundColor: Colors.deepOrange[700],
        actions: [
          appreciation,
          share,
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
