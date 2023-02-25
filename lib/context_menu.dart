import 'package:flutter/material.dart';
import 'package:todo_task/context_provider.dart';

void showContextMenu({
  required TapUpDetails tapDetails,
  required List<CustomPopupMenuItem> items,
  required void Function(String? value) onSelected,
}) {
  BuildContext context = navigatorKey.currentContext!;
  final position = RelativeRect.fromLTRB(
      tapDetails.globalPosition.dx,
      tapDetails.globalPosition.dy,
      tapDetails.globalPosition.dx,
      tapDetails.globalPosition.dy);

  if (items.isNotEmpty) {
    showMenu<String>(
      context: context,
      elevation: 2,
      items: items,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ).then(onSelected);
  }
}

class CustomPopupMenuItem extends PopupMenuItem<String> {
  CustomPopupMenuItem({
    Key? key,
    required String value,
    IconData? iconData,
    Color? textColor,
    Color? iconColor,
  }) : super(
            key: key,
            child: Row(
              children: [
                if (iconData != null)
                  Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(iconData, size: 18, color: iconColor)),
                Text(value, style: TextStyle(color: textColor))
              ],
            ),
            value: value,
            height: 38);
}
