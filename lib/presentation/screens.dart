import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigator/service.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: IconButton(
        icon: const Icon(Icons.add),
        iconSize: 64,
        onPressed: () {
          context.read<AppNavigator>().push(AppRoutes.toSecondScreen());
        },
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: IconButton(
        icon: const Icon(Icons.add),
        iconSize: 64,
        onPressed: () {
          context.read<AppNavigator>().push(AppRoutes.toThirdScreen());
        },
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: IconButton(
        icon: const Icon(Icons.add),
        iconSize: 64,
        onPressed: () {
          context.read<AppNavigator>().push(AppRoutes.toFirstScreen());
        },
      ),
    );
  }
}
