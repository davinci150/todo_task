import 'package:flutter/material.dart';

import '../widgets/custom_appbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: Column(
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
