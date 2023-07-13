import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/birthday_model.dart';
import '../../presentation/my_flutter_app_icons.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/context_menu.dart';
import '../birthdays_widget_model.dart';

class BirthdayCardWidget extends StatelessWidget {
  const BirthdayCardWidget({Key? key, required this.model}) : super(key: key);

  final BirthdayModel model;

  @override
  Widget build(BuildContext context) {
    final _model = context.read<BirthdaysWidgetModel>();

    final colorTheme = context.watch<ModelTheme>().colorTheme;

    final now = DateTime.now();

    final bool birthdayIsToday =
        model.birthday.month == now.month && model.birthday.day == now.day;

    final int turnsYear = now.year - model.birthday.year + 1;

    return Container(
      //  padding: const EdgeInsets.all(12),
      // margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 10,
                color: Color.fromRGBO(0, 0, 0, 0.25))
          ]),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          onTapUp: (det) {
            showContextMenu(
                globalPosition: det.globalPosition,
                items: [CustomPopupMenuItem(value: 'delete')],
                onSelected: (value) {
                  if (value == 'delete') {
                    _model.deleteBirthday(model.uid);
                  }
                });
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: stringToHslColor(model.uid, 0.4, 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    getInitials(model.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (birthdayIsToday)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              MyFlutterApp.birthday_cake,
                              size: 16,
                              color: colorTheme.primaryColor,
                            ),
                          ),
                        if (!birthdayIsToday)
                          Text(
                            '${DateFormat('dd MMM').format(model.birthday)} -',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        Text(
                          'Turns $turnsYear${birthdayIsToday ? '!' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: birthdayIsToday
                                ? colorTheme.primaryColor
                                : null,
                          ),
                        ),
                      ],
                    )
                    /*   Text(
                      model.uid.hashCode.toString(),
                      style: const TextStyle(fontSize: 10),
                    ), */
                  ],
                ),
                const Spacer(),
                if (birthdayIsToday)
                  Image.asset(
                    'assets/images/birthday_congradulation.png',
                    width: 36,
                  )
                else
                  Column(
                    children: [
                      Text(
                        model.countdownDays.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: colorTheme.primaryColor,
                        ),
                      ),
                      Text(
                        'Days',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colorTheme.primaryColor,
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getInitials(String input) {
    String result = '';
    final List<String> words = input.trim().split(' ');
    if (input.trim().isEmpty) {
      result = '-';
    } else if (words.isEmpty) {
      result = '-';
    } else if (words.length == 1) {
      result = words.first[0];
    } else if (words.length == 2) {
      result = '${words.first[0]}${words.last[0]}';
    } else {
      result = '${words.first[0]}${words.last[0]}';
    }
    return result.toUpperCase();
  }

  Color stringToHslColor(String str, double saturation, double lightness) {
    int hash = 0;

    for (int i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final int hue = hash % 360;

    //alpha 0.0-1.0, hue 0.0-360.0,  saturation 0.0-1.0,  lightness 0.0-1.0
    return HSLColor.fromAHSL(1.0, hue.toDouble(), saturation, lightness)
        .toColor();
  }
}
