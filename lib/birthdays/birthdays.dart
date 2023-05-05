import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/birthdays/birthdays_widget_model.dart';
import 'package:todo_task/widgets/dialog/adaptive_dialog.dart';

import '../api/birthdays_api.dart';
import '../main.dart';
import '../model/birthday_model.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../tasks_page/tasks_page.dart';

class BirthdaysPage extends StatefulWidget {
  const BirthdaysPage({Key? key}) : super(key: key);

  @override
  State<BirthdaysPage> createState() => _BirthdaysPageState();
}

class _BirthdaysPageState extends State<BirthdaysPage> {
  @override
  Widget build(BuildContext context) {
    final _model = BirthdaysWidgetModel();
    return BirthdaysModelProvider(
      model: _model,
      child: const BdPage(),
    );
  }
}

class BdPage extends StatefulWidget {
  const BdPage({Key? key}) : super(key: key);

  @override
  State<BdPage> createState() => _BdPageState();
}

class _BdPageState extends State<BdPage> {
  @override
  Widget build(BuildContext context) {
    final _model = BirthdaysModelProvider.watch(context)?.model;
    final colorTheme = context.watch<ModelTheme>().colorTheme;
    return Scaffold(
      backgroundColor: isDesktop
          ? colorTheme.scaffoldDesktopColor
          : colorTheme.mobileScaffoldColor,
      appBar: isDesktop ? null : const CustomAppBar(title: 'Bdays'),
      body: Container(
        margin: isDesktop ? const EdgeInsets.all(8) : null,
        decoration: isDesktop
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDesktop ? colorTheme.mobileScaffoldColor : null,
              )
            : null,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            TextButton(
                onPressed: () async {
                  await checkAndSetNotifications();
                },
                child: const Text('Set notifications')),
            TextButton(
                onPressed: () async {
                  final list =
                      await NotificationService().pendingNotificationRequests();
                  await showAlert(
                      title:
                          'Notifications length: ${list.length} \n${list.map((e) => 'id:${e.id}, title:${e.body}')}');
                },
                child: const Text('Check notifications')),
            TextButton(
                onPressed: () async {
                  final createModel = await showCreateBirthdayDialog();

                  if (createModel != null &&
                      (createModel.name ?? '').isNotEmpty &&
                      createModel.birthday != null) {
                    _model?.addBirthday(createModel);
                  }
                },
                child: const Text('Add birthday')),
            ..._model!.birthdays.map((BirthdayModel e) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(e.name ?? ''),
                        const Spacer(),
                        if (e.birthday != null)
                          Text(DateFormat('dd MMM yyyy').format(e.birthday!)),
                      ],
                    ),
                    Text(
                      e.uid.hashCode.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> checkAndSetNotifications() async {
    int count = 0;
    final bdays = await GetIt.I<BirthdaysApi>().getBdays();

    final notifications =
        await NotificationService().pendingNotificationRequests();
    final notifIds = notifications.map((e) => e.id);

    for (final item in bdays) {
      final id = item.uid.hashCode;
      if (!notifIds.contains(id)) {
        await NotificationService()
            .yearlyNotification(item.uid.hashCode, item.birthday!, item.name!);
        count++;
      }
    }
    await showAlert(title: 'Add $count new birthdays');
  }

  Future<BirthdayModel?> showCreateBirthdayDialog() async {
    BirthdayModel birthdayModel = const BirthdayModel();
    return showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Введите имя'),
                  onChanged: (name) {
                    birthdayModel = birthdayModel.copyWith(name: name);
                  },
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365 * 1)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 1)));
                    if (date != null) {
                      final time = await showTimePicker(
                          initialTime: TimeOfDay.now(), context: context);
                      if (time != null) {
                        date = DateTime(date.year, date.month, date.day,
                            time.hour, time.minute);

                        birthdayModel = birthdayModel.copyWith(birthday: date);
                        snapshot(() {});
                      }
                    }
                  },
                  child: Text(birthdayModel.birthday == null
                      ? 'Set date'
                      : DateFormat('dd MMM yyyy HH:mm')
                          .format(birthdayModel.birthday!)),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context, birthdayModel);
                      },
                      child: const Text('OK')),
                )
              ]),
            );
          });
        });
    return showDialog<BirthdayModel>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(builder: (context, snapshot) {
            return AlertDialog(
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, birthdayModel);
                    },
                    child: const Text('OK'))
              ],
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  decoration: const InputDecoration(hintText: 'Введите имя'),
                  onChanged: (name) {
                    birthdayModel = birthdayModel.copyWith(name: name);
                  },
                ),
                TextButton(
                  onPressed: () async {
                    DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365 * 1)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 1)));
                    if (date != null) {
                      final time = await showTimePicker(
                          initialTime: TimeOfDay.now(), context: context);
                      if (time != null) {
                        date = DateTime(date.year, date.month, date.day,
                            time.hour, time.minute);

                        birthdayModel = birthdayModel.copyWith(birthday: date);
                        snapshot(() {});
                      }
                    }
                  },
                  child: Text(birthdayModel.birthday == null
                      ? 'Set date'
                      : birthdayModel.birthday.toString()),
                )
              ]),
            );
          });
        });
  }
}
