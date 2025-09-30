import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snippets/navigator/interface.dart';
import 'package:snippets/navigator/service.dart';
import 'package:snippets/navigator/tab_switching_view.dart';

import 'bottom_navigation_bar.dart';

class ScreenWrapper extends StatefulWidget {
  const ScreenWrapper({
    super.key,
    required this.rootNavigatorKey,
    required this.views,
  });

  final GlobalKey<NavigatorState> rootNavigatorKey;
  final List<NavigationPageView> views;

  @override
  ScreenWrapperState createState() => ScreenWrapperState();
}

class ScreenWrapperState extends State<ScreenWrapper> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Provider<AppNavigator>(
        // make AppNavigator  available to all descendants
        // it can be accessed like so: AppNavigator.of(context).pop()/.push(...etc
        // TODO(Filippo): see Provider's read: it must be possible to context.read<AppNavigator>.push()
        create: (BuildContext context) => AppNavigator(widget.rootNavigatorKey),
        child: TabSwitchingView(
          currentTabIndex: _currentPageIndex,
          tabNumber: widget.views.length,
          tabBuilder: (BuildContext context, int index) {
            return widget.views[index].builder(context);
          },
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        items: widget.views,
        selectedIndex: _currentPageIndex,
        onItemSelected: (int position) {
          setState(
            () {
              // make the bottom nav bar dirty and cause re-render of descendants
              _currentPageIndex = position;
            },
          );
        },
      ),
    );
  }
}
