import 'package:flutter/material.dart';

import 'interface.dart';

class CurrentRouteNotifier extends ValueNotifier<NavigationPageOrder> {
  CurrentRouteNotifier() : super(NavigationPageOrder.first);
}
