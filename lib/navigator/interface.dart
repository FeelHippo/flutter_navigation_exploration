import 'package:flutter/material.dart';

enum NavigationPageOrder { first, second, third, fourth, fifth }

class NavigationPageView {
  NavigationPageView(this.order, this.icon, this.child);

  final NavigationPageOrder order;
  final IconData icon;
  final Widget child;
}

class AppRoute<T> {
  const AppRoute({required this.order, required this.route, this.icon});

  final NavigationPageOrder order;
  final Route<T> route;
  final IconData? icon;
}
