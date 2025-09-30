import 'package:flutter/material.dart';

class TabSwitchingView extends StatefulWidget {
  const TabSwitchingView({
    super.key,
    required this.currentTabIndex,
    required this.tabNumber,
    required this.tabBuilder,
  });

  final int currentTabIndex;
  final int tabNumber;
  final IndexedWidgetBuilder tabBuilder;

  @override
  TabSwitchingViewState createState() => TabSwitchingViewState();
}

class TabSwitchingViewState extends State<TabSwitchingView> {
  late List<Widget?> tabs;
  late List<FocusScopeNode> tabFocusNodes;

  @override
  void initState() {
    super.initState();
    tabs = List<Widget?>.generate(widget.tabNumber, (_) => null);
    tabFocusNodes = List<FocusScopeNode>.generate(
      widget.tabNumber,
      (int index) => FocusScopeNode(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusActiveTab();
  }

  @override
  void didUpdateWidget(TabSwitchingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _focusActiveTab();
  }

  void _focusActiveTab() {
    FocusScope.of(context).setFirstFocus(tabFocusNodes[widget.currentTabIndex]);
  }

  @override
  void dispose() {
    for (final FocusScopeNode focusScopeNode in tabFocusNodes) {
      focusScopeNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List<Widget>.generate(
        widget.tabNumber,
        (int index) {
          final bool active = index == widget.currentTabIndex;

          if (active) {
            tabs[index] = widget.tabBuilder(context, index);
          }

          return Offstage(
            offstage: !active,
            child: TickerMode(
              enabled: active,
              child: FocusScope(
                node: tabFocusNodes[index],
                child: tabs[index] ?? const SizedBox(),
              ),
            ),
          );
        },
      ),
    );
  }
}
