import 'package:flutter/material.dart';

// Creates a navigator, stores it, and exposes it to its descendants.
class AppNavigator {
  AppNavigator(this.rootNavigatorKey);

  final GlobalKey<NavigatorState> rootNavigatorKey;

  // Obtain a value from the nearest ancestor provider of type AppNavigator
  // TODO(Filippo): see Provider's read, the below should not be necessary
  // static AppNavigator of(BuildContext context) {
  //   return context.read<AppNavigator>();
  // }

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
