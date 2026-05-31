import 'package:flutter/material.dart';

class SidePanel extends StatelessWidget {
  const SidePanel({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ListView(padding: const EdgeInsets.all(16), children: children),
    );
  }
}
