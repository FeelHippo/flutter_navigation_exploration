import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snippets/navigator/change_route_event.dart';
import 'package:snippets/navigator/service.dart';

import 'bottom_navigation_bar.dart';
import 'change_route_notifier.dart';
import 'change_route_observer.dart';
import 'interface.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key, required this.views});

  final List<NavigationPageView> views;

  @override
  State<StatefulWidget> createState() => NavigationWrapperState();
}

class NavigationWrapperState extends State<NavigationWrapper>
    with ChangeNotifier {
  int _currentPosition = 0;
  final CurrentRouteNotifier _routeNotifier = CurrentRouteNotifier();

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>();
    // Creates a widget that maintains a stack-based history of child widgets
    return Provider<AppNavigator>(
      create: (_) => AppNavigator(rootNavigatorKey),
      child: ValueListenableProvider<ChangeRouteEvent?>.value(
        value: _routeNotifier,
        child: Scaffold(
          body: Navigator(
            key: rootNavigatorKey,
            pages: widget.views
                .map<Page<dynamic>>(
                  (view) => MaterialPage<void>(child: view.child),
                )
                .toList()
                .reversed // ??
                .toList(),
            onGenerateRoute: (RouteSettings settings) {},
            onDidRemovePage: (Page page) {},
            observers: <NavigatorObserver>[
              AppNavigatorObserver(_routeNotifier),
            ],
          ),
          bottomNavigationBar: BottomNavigation(
            items: widget.views,
            selectedIndex: _currentPosition,
            onItemSelected: (int position, AppRoute appRoute) {
              setState(() {
                _currentPosition = position;
              });
              // TODO(Filippo): try to use context.read<AppNavigator>().push(...) here
              // make sure to hot restart the app when making changes
            },
          ),
        ),
      ),
    );
  }
}
