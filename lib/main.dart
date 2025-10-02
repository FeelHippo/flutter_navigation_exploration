import 'package:flutter/material.dart';
import 'package:snippets/presentation/screens.dart';

import 'navigator/interface.dart';
import 'navigator/navigation_wrapper.dart';

void main() => runApp(const NavigatorApp());

class NavigatorApp extends StatelessWidget {
  const NavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavigationWrapper(
        views: <NavigationPageView>[
          NavigationPageView(
            NavigationPageOrder.first,
            Icons.home,
            const FirstScreen(),
          ),
          NavigationPageView(
            NavigationPageOrder.second,
            Icons.search,
            const SecondScreen(),
          ),
          NavigationPageView(
            NavigationPageOrder.third,
            Icons.account_box,
            const ThirdScreen(),
          ),
        ],
      ),
    );
  }
}
