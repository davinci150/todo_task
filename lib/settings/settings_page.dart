import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).backgroundColor,
      ),
      child: Column(
        children: [
          Row(
            children: const [Text('Settings 1')],
          ),
          Row(
            children: const [Text('Settings 2')],
          ),
          Row(
            children: const [Text('Settings 3')],
          ),
        ],
      ),
    );
  }
}
