import 'package:flutter/material.dart';
import 'package:snippets/navigator/service.dart';

import 'interface.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.selectedIndex = 0,
  });

  final void Function(int position, AppRoute appRoute) onItemSelected;
  final List<NavigationPageView> items;
  final int selectedIndex;

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
          final int index = widget.items.indexOf(item);
          return Flexible(
            child: GestureDetector(
              onTap: () => widget.onItemSelected(
                index,
                AppRoutes.toSecondScreen(),
              ), // TODO(Filippo): map item to AppRoutes's route
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
                      color: index == widget.selectedIndex
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
