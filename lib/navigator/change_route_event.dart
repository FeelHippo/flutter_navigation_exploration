import 'package:flutter/material.dart';

enum ChangeRouteEventType {
  pop,
  push,
}

class ChangeRouteEvent {
  ChangeRouteEvent(this.currentRoute, this.previousRoute, this.type);

  final Route<dynamic>? currentRoute;
  final Route<dynamic>? previousRoute;
  final ChangeRouteEventType type;
}
