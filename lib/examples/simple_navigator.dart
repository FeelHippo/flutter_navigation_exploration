import 'package:flutter/material.dart';

void main() => runApp(const SimpleNavigatorApp());

class SimpleNavigatorApp extends StatelessWidget {
  const SimpleNavigatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const SimpleHomePage(),
        '/child': (BuildContext context) => const ChildPage(),
      },
    );
  }
}

class SimpleHomePage extends StatelessWidget {
  const SimpleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headlineMedium!,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/child');
        },
        child: Container(
          color: Colors.white,
          alignment: Alignment.center,
          child: const Text('Home Page => Child'),
        ),
      ),
    );
  }
}

class ChildRoot extends StatelessWidget {
  const ChildRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      /// Descendant widgets obtain the current theme's [ThemeData] object using
      /// [Theme.of]. When a widget uses [Theme.of], it is automatically rebuilt if
      /// the theme later changes, so that the changes can be applied.
      style: Theme.of(context).textTheme.headlineSmall!,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('child/global');
        },
        child: Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: const Text('Child Root => Child Global'),
        ),
      ),
    );
  }
}

class ChildGlobal extends StatelessWidget {
  const ChildGlobal({
    super.key,
    required this.callback,
  });

  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      /// Descendant widgets obtain the current theme's [ThemeData] object using
      /// [Theme.of]. When a widget uses [Theme.of], it is automatically rebuilt if
      /// the theme later changes, so that the changes can be applied.
      style: Theme.of(context).textTheme.headlineSmall!,
      child: GestureDetector(
        onTap: () {
          callback();
        },
        child: Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: const Text('Child Global => Home'),
        ),
      ),
    );
  }
}

class ChildPage extends StatelessWidget {
  const ChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    // the following is a nested Navigator
    return Navigator(
      initialRoute: 'child/root',
      // Called to generate a new route
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'child/root':
            // redirect to the root of the nested navigator
            builder = (BuildContext _) => const ChildRoot();
          case 'child/global':
            // note how the below BuildContext is "_"
            // hence, the callback "Navigator.of(context)"
            // references the global context, from the enclosing build()
            builder = (BuildContext _) => ChildGlobal(
                  callback: () {
                    Navigator.of(context).pop();
                  },
                );
          case 'child/nested':
            // note how the below BuildContext is "contextNested"
            // hence, the callback "Navigator.of(context)"
            // references a new node created by WidgetBuilder
            builder = (BuildContext contextNested) => ChildGlobal(
                  callback: () {
                    Navigator.of(contextNested).pop();
                  },
                );
          default:
            throw Exception('Invalid Route');
        }
        return MaterialPageRoute<void>(
          builder: builder,
          settings: settings,
        );
      },
    );
  }
}
