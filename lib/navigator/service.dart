import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:snippets/presentation/screens.dart';

// Creates a navigator, stores it, and exposes it to its descendants.
class AppNavigator {
  AppNavigator(this.rootNavigatorKey);

  final GlobalKey<NavigatorState> rootNavigatorKey;

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

    if (appRoute != null) {
      return currentState.push(appRoute.child);
    }
    return Future<T>.value();
  }
}

abstract class AppRoutes {
  static AppRoute<dynamic> toFirstScreen() => AppRoute<dynamic>(
    PageRouteBuilder<void>(
      opaque: false,
      pageBuilder: (BuildContext context, _, _) {
        return const FirstScreen();
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
  static AppRoute<dynamic> toSecondScreen() => AppRoute<dynamic>(
    PageRouteBuilder<void>(
      opaque: false,
      pageBuilder: (BuildContext context, _, _) {
        return const SecondScreen();
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
  static AppRoute<dynamic> toThirdScreen() => AppRoute<dynamic>(
    PageRouteBuilder<void>(
      opaque: false,
      pageBuilder: (BuildContext context, _, _) {
        return const ThirdScreen();
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

class AppRoute<T> extends Equatable {
  const AppRoute(this.child);

  final Route<T> child;

  @override
  List<Object?> get props => <Object?>[child];
}
