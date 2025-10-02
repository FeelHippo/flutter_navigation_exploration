import 'package:flutter/material.dart';

import 'change_route_notifier.dart';
import 'interface.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({
    super.key,
    required this.routeNotifier,
    required this.items,
    required this.onItemSelected,
  });

  final CurrentRouteNotifier routeNotifier;
  final void Function(NavigationPageOrder next) onItemSelected;
  final List<NavigationPageView> items;

  @override
  BottomNavigationState createState() => BottomNavigationState();
}

class BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin, RouteAware {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: widget.items.map((NavigationPageView item) {
          return Flexible(
            child: GestureDetector(
              onTap: () => widget.onItemSelected(item.order),
              child: Container(
                height: 48,
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.icon,
                      size: 40,
                      color: item.order == widget.routeNotifier.value
                          ? Colors.redAccent
                          : Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
