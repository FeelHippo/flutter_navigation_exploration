import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'change_route_event.dart';
import 'change_route_notifier.dart';

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this._routeNotifier);

  final CurrentRouteNotifier _routeNotifier;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      _routeNotifier.value = ChangeRouteEvent(
        route,
        previousRoute,
        ChangeRouteEventType.pop,
      );
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      _routeNotifier.value = ChangeRouteEvent(
        route,
        previousRoute,
        ChangeRouteEventType.push,
      );
    });
  }
}
