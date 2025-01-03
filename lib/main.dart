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

// Extends a ChangeNotifier, that holds a single value.
// When value (line 49) is replaced with something that is not equal to the old value
// as evaluated by the equality operator ==, this class notifies its listeners (line 65)
class CurrentRouteNotifier extends ValueNotifier<ChangeRouteEvent?> {
  CurrentRouteNotifier() : super(null);
}

// Extends the default interface for observing the behavior of a Navigator
// observables: didPush | didPop | didRemove | didReplace | didStartUserGesture | didStopUserGesture
class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this._routeNotifier);

  final CurrentRouteNotifier _routeNotifier;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Schedule a callback for the end of this frame
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
    // Creates a widget that maintains a stack-based history of child widgets.
    return Navigator(
      key: rootNavigatorKey,
      // Called to generate a route for a given RouteSettings
      // see https://api.flutter.dev/flutter/widgets/Navigator-class.html
      // and https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html
      onGenerateRoute: (RouteSettings settings) {
        builder(BuildContext context) => HomeScreen(
              rootNavigatorKey: rootNavigatorKey,
            );
        // A modal route that replaces the entire screen with a platform-adaptive transition.
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

// Creates a navigator, stores it, and exposes it to its descendants.
class AppNavigator {
  AppNavigator(this.rootNavigatorKey);

  final GlobalKey<NavigatorState> rootNavigatorKey;

  // Obtain a value from the nearest ancestor provider of type AppNavigator
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.rootNavigatorKey});

  final GlobalKey<NavigatorState> rootNavigatorKey;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;

  final List<NavigationPageView> _pages = <NavigationPageView>[
    NavigationPageView(NavigationPage.first, 'One', (_) => const FirstScreen()),
    NavigationPageView(
        NavigationPage.second, 'Two', (_) => const SecondScreen()),
    NavigationPageView(
        NavigationPage.third, 'Three', (_) => const ThirdScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Provider<AppNavigator>(
        // make AppNavigator  available to all descendants
        // it can be accessed like so: AppNavigator.of(context).pop()/.push(...etc
        create: (BuildContext context) => AppNavigator(widget.rootNavigatorKey),
        child: TabSwitchingView(
          currentTabIndex: _currentPageIndex,
          tabNumber: _pages.length,
          tabBuilder: (BuildContext context, int index) {
            return _pages[index].builder(context);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigation(
          items: _pages,
          selectedIndex: _currentPageIndex,
          onItemSelected: (int position) {
            setState(() {
              // make the bottom nav bar dirty and cause re-render of descendants
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
              child: _BottomNavigationItem(
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

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({required this.item, required this.isSelected});

  final NavigationPageView item;
  final bool isSelected;

  static TextStyle bottomMenuText({
    Color? textColor,
  }) =>
      TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(color: Colors.white),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 40,
              width: 1,
              decoration: const BoxDecoration(color: Colors.grey),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
          )
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
