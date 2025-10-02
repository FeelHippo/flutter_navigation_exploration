import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snippets/navigator/service.dart';

import 'bottom_navigation_bar.dart';
import 'change_route_notifier.dart';
import 'interface.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key, required this.views});

  final List<NavigationPageView> views;

  @override
  State<StatefulWidget> createState() => NavigationWrapperState();
}

class NavigationWrapperState extends State<NavigationWrapper> {
  late CurrentRouteNotifier _routeNotifier;

  @override
  void initState() {
    super.initState();
    _routeNotifier = CurrentRouteNotifier();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>();
    // Creates a widget that maintains a stack-based history of child widgets
    return Provider<AppNavigator>(
      create: (_) => AppNavigator(
        rootNavigatorKey: rootNavigatorKey,
        routeNotifier: _routeNotifier,
        views: widget.views,
      ),
      builder: (BuildContext providerContext, _) {
        return ValueListenableBuilder<NavigationPageOrder?>(
          valueListenable: _routeNotifier,
          builder: (BuildContext context, _, Widget? _) => Scaffold(
            body: Navigator(
              key: rootNavigatorKey,
              pages: widget.views
                  .map<Page<dynamic>>(
                    (view) => MaterialPage<void>(child: view.child),
                  )
                  .toList()
                  .reversed // ??
                  .toList(),
              onGenerateRoute: (RouteSettings settings) {
                return null;
              },
              onDidRemovePage: (Page page) {},
            ),
            bottomNavigationBar: BottomNavigation(
              routeNotifier: _routeNotifier,
              items: widget.views,
              onItemSelected: (NavigationPageOrder next) {
                providerContext.read<AppNavigator>().push(next);
              },
            ),
          ),
        );
      },
    );
  }
}
