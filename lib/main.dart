import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

void main() => runApp(const NavigatorApp());

class NavigatorApp extends StatelessWidget {
  const NavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

enum ChangeRouteEventType {
  pop,
  // ...
}

class ChangeRouteEvent {
  ChangeRouteEvent(this.currentRoute, this.previousRoute, this.type);

  final Route<dynamic>? currentRoute;
  final Route<dynamic>? previousRoute;
  final ChangeRouteEventType type;
}

class CurrentRouteNotifier extends ValueNotifier<ChangeRouteEvent?> {
  CurrentRouteNotifier() : super(null);
}

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this._routeNotifier);

  final CurrentRouteNotifier _routeNotifier;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      _routeNotifier.value =
          ChangeRouteEvent(route, previousRoute, ChangeRouteEventType.pop);
    });
  }

  // ...
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>();
    final CurrentRouteNotifier routeNotifier = CurrentRouteNotifier();
    return Navigator(
      key: rootNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder = (BuildContext context) => HomeScreen(
              rootNavigatorKey: rootNavigatorKey,
            );
        return MaterialPageRoute(builder: builder, settings: settings);
      },
      observers: <NavigatorObserver>[
        AppNavigatorObserver(routeNotifier),
      ],
    );
  }
}

class AppRoute<T> {
  const AppRoute(
    this.name, {
    this.routeBuilder,
  });
  final String name;
  final Route<T>? Function(
    BuildContext context,
    AppNavigator navigator,
  )? routeBuilder;
}

class AppNavigator {
  AppNavigator(this.rootNavigatorKey, this.bottomNavigationController);

  final GlobalKey<NavigatorState> rootNavigatorKey;
  final BottomNavigationController bottomNavigationController;

  static AppNavigator of(BuildContext context) {
    return context.read<AppNavigator>();
  }

  void pop([dynamic result]) {
    rootNavigatorKey.currentState?.pop(result);
  }

  Future<T?> push<T extends Object?>(AppRoute<T>? appRoute) async {
    final BuildContext? currentContext = rootNavigatorKey.currentContext;
    if (currentContext == null) {
      return null;
    }
    final NavigatorState? currentState = rootNavigatorKey.currentState;
    if (currentState == null) {
      return null;
    }

    final Route<T>? route = appRoute?.routeBuilder?.call(currentContext, this);
    if (route != null) {
      return currentState.push(route);
    }
    return Future<T>.value();
  }
}

enum NavigationPage {
  first,
  second,
  third,
}

class NavigationPageView {
  NavigationPageView(
    this.id,
    this.name,
    this.builder,
  );
  final NavigationPage id;
  final String name;
  final WidgetBuilder builder;
}

abstract class BottomNavigationController {
  void showFirst();
  void showSecond();
  void showThird();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.rootNavigatorKey});
  final GlobalKey<NavigatorState> rootNavigatorKey;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    implements BottomNavigationController {
  int _currentPageIndex = 0;
  final List<NavigationPageView> _pages = <NavigationPageView>[
    NavigationPageView(NavigationPage.first, 'One', (_) => const FirstScreen()),
    NavigationPageView(
        NavigationPage.second, 'Two', (_) => const SecondScreen()),
    NavigationPageView(
        NavigationPage.third, 'Three', (_) => const ThirdScreen()),
  ];

  @override
  void showFirst() {
    final int pageIndex = _findPageById(NavigationPage.first);
    if (pageIndex > -1) {
      setState(() {
        _currentPageIndex = pageIndex;
      });
    }
  }

  @override
  void showSecond() {
    final int pageIndex = _findPageById(NavigationPage.second);
    if (pageIndex > -1) {
      setState(() {
        _currentPageIndex = pageIndex;
      });
    }
  }

  @override
  void showThird() {
    final int pageIndex = _findPageById(NavigationPage.third);
    if (pageIndex > -1) {
      setState(() {
        _currentPageIndex = pageIndex;
      });
    }
  }

  int _findPageById(NavigationPage id) {
    return _pages.indexWhere((NavigationPageView page) => page.id == id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Provider<BottomNavigationController>.value(
        value: this,
        child: Provider<AppNavigator>(
          create: (BuildContext context) => AppNavigator(
            widget.rootNavigatorKey,
            this,
          ),
          child: TabSwitchingView(
              currentTabIndex: _currentPageIndex,
              tabNumber: _pages.length,
              tabBuilder: (BuildContext context, int index) {
                return _pages[index].builder(context);
              }),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
          items: _pages,
          selectedIndex: _currentPageIndex,
          onItemSelected: (int position) {
            setState(() {
              _currentPageIndex = position;
            });
          }),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.selectedIndex = 0,
  });

  final void Function(int position) onItemSelected;
  final List<NavigationPageView> items;
  final int selectedIndex;

  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin, RouteAware {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration:
          const BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
        BoxShadow(
          offset: Offset(0, -2),
          color: Colors.white,
          blurRadius: 2,
        ),
      ]),
      child: Row(
        children: widget.items.map((NavigationPageView item) {
          final int index = widget.items.indexOf(item);
          return Flexible(
            child: GestureDetector(
              onTap: () => widget.onItemSelected(index),
              child: _bottomNavigationItem(
                item: item,
                isSelected: index == widget.selectedIndex,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _bottomNavigationItem extends StatelessWidget {
  const _bottomNavigationItem({required this.item, required this.isSelected});

  final NavigationPageView item;
  final bool isSelected;

  static TextStyle bottomMenuText({
    Color? textColor,
  }) =>
      TextStyle(
        color: textColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 29,
              width: 1,
              decoration: const BoxDecoration(color: Colors.grey),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Column(
              children: <Widget>[
                Text(
                  item.name,
                  style: isSelected
                      ? bottomMenuText()
                      : bottomMenuText(textColor: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabSwitchingView extends StatefulWidget {
  const TabSwitchingView({
    super.key,
    required this.currentTabIndex,
    required this.tabNumber,
    required this.tabBuilder,
  });

  final int currentTabIndex;
  final int tabNumber;
  final IndexedWidgetBuilder tabBuilder;

  @override
  TabSwitchingViewState createState() => TabSwitchingViewState();
}

class TabSwitchingViewState extends State<TabSwitchingView> {
  late List<Widget?> tabs;
  late List<FocusScopeNode> tabFocusNodes;

  @override
  void initState() {
    super.initState();
    tabs = List<Widget?>.generate(widget.tabNumber, (_) => null);
    tabFocusNodes = List<FocusScopeNode>.generate(
      widget.tabNumber,
      (int index) => FocusScopeNode(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusActiveTab();
  }

  @override
  void didUpdateWidget(TabSwitchingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _focusActiveTab();
  }

  void _focusActiveTab() {
    FocusScope.of(context).setFirstFocus(tabFocusNodes[widget.currentTabIndex]);
  }

  @override
  void dispose() {
    for (final FocusScopeNode focusScopeNode in tabFocusNodes) {
      focusScopeNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List<Widget>.generate(widget.tabNumber, (int index) {
        final bool active = index == widget.currentTabIndex;

        if (active) {
          tabs[index] = widget.tabBuilder(context, index);
        }

        return Offstage(
          offstage: !active,
          child: TickerMode(
            enabled: active,
            child: FocusScope(
              node: tabFocusNodes[index],
              child: tabs[index] ?? const SizedBox(),
            ),
          ),
        );
      }),
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      constraints: const BoxConstraints.expand(),
      child: const Text("One"),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      constraints: const BoxConstraints.expand(),
      child: const Text("Two"),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      constraints: const BoxConstraints.expand(),
      child: const Text("Three"),
    );
  }
}
