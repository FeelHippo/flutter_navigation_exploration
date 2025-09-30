import 'package:flutter/material.dart';
import 'package:snippets/navigator/screen_wrapper.dart';

import 'change_route_notifier.dart';
import 'change_route_observer.dart';
import 'interface.dart';

class NavigationWrapper extends StatelessWidget {
  const NavigationWrapper({
    super.key,
    required this.views,
  });
  final List<NavigationPageView> views;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> rootNavigatorKey =
        GlobalKey<NavigatorState>();
    // Creates a widget that maintains a stack-based history of child widgets
    return Navigator(
      key: rootNavigatorKey,
      // Called to generate a route for a given RouteSettings
      // see https://api.flutter.dev/flutter/widgets/Navigator-class.html
      // and https://api.flutter.dev/flutter/material/MaterialPageRoute-class.html
      onGenerateRoute: (RouteSettings settings) {
        Widget builder(BuildContext context) => ScreenWrapper(
              rootNavigatorKey: rootNavigatorKey,
              views: views,
            );
        // A modal route that replaces the entire screen with a platform-adaptive transition.
        return MaterialPageRoute(
          builder: builder,
          settings: settings,
        );
      },
      observers: <NavigatorObserver>[
        AppNavigatorObserver(CurrentRouteNotifier()),
      ],
    );
  }
}
