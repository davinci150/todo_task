import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/home_page.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.watch<ModelTheme>().colorTheme;
    return AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: colorTheme.sidebarIconColor),
        actionsIconTheme: IconThemeData(color: colorTheme.sidebarIconColor),
        backgroundColor: colorTheme.appBarColor,
        centerTitle: true,
        actions: actions,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            drawerKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            color: colorTheme.sidebarIconColor,
          ),
        ));
  }
}
