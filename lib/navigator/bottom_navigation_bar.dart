import 'package:flutter/material.dart';

import 'interface.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({
    super.key,
    required this.items,
    required this.onItemSelected,
    this.selectedIndex = 0,
  });

  final void Function(int position) onItemSelected;
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
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(offset: Offset(0, -2), color: Colors.white, blurRadius: 2),
        ],
      ),
      child: Row(
        children: widget.items.map((NavigationPageView item) {
          final int index = widget.items.indexOf(item);
          return Flexible(
            child: GestureDetector(
              onTap: () => widget.onItemSelected(index),
              child: Container(
                height: 48,
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.icon,
                      size: 32,
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
