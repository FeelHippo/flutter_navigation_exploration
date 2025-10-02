import 'package:flutter/material.dart';
import 'package:snippets/navigator/interface.dart';

import 'change_route_notifier.dart';

// Creates a navigator, stores it, and exposes it to its descendants.
class AppNavigator {
  AppNavigator({
    required this.rootNavigatorKey,
    required this.routeNotifier,
    required this.views,
  });

  final GlobalKey<NavigatorState> rootNavigatorKey;
  final CurrentRouteNotifier routeNotifier;
  final List<NavigationPageView> views;

  void pop() {
    rootNavigatorKey.currentState?.pop();
  }

  Future push(NavigationPageOrder next) async {
    final BuildContext? currentContext = rootNavigatorKey.currentContext;
    if (currentContext == null) {
      return null;
    }
    final NavigatorState? currentState = rootNavigatorKey.currentState;
    if (currentState == null) {
      return null;
    }

    routeNotifier.value = next;
    final Widget childWidget = views
        .firstWhere((route) => route.order == next)
        .child;
    return currentState.push(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (BuildContext context, _, _) {
          return childWidget;
        },
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) {
          return FadeTransition(
            opacity: animation,
            child: RotationTransition(
              turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
