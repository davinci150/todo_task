import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/birthday_model.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/dialog/adaptive_dialog.dart';
import '../widgets/progress_indicator_widget.dart';
import 'birthdays_widget_model.dart';
import 'widgets/birthday_card.dart';

class BirthdaysPage extends StatefulWidget {
  const BirthdaysPage({Key? key}) : super(key: key);

  @override
  State<BirthdaysPage> createState() => _BirthdaysPageState();
}

class _BirthdaysPageState extends State<BirthdaysPage> {
  BirthdaysWidgetModel model = BirthdaysWidgetModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BirthdaysWidgetModel>(
      create: (_) => model,
      child: const BirthdaysWidgetBody(),
    );
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }
}

class BirthdaysWidgetBody extends StatefulWidget {
  const BirthdaysWidgetBody({Key? key}) : super(key: key);

  @override
  State<BirthdaysWidgetBody> createState() => _BirthdaysWidgetBodyState();
}

class _BirthdaysWidgetBodyState extends State<BirthdaysWidgetBody> {
  final labels = [
    LabelWidget(isActive: true, text: 'All', onTap: () {}),
    LabelWidget(isActive: false, text: 'Friends', onTap: () {}),
    LabelWidget(isActive: false, text: 'Work', onTap: () {}),
    LabelWidget(isActive: false, text: 'Family', onTap: () {}),
  ];

  List<int> pendingNotificationIds = [];

  @override
  void initState() {
    loadPendingNotificationRequests();
    super.initState();
  }

  void loadPendingNotificationRequests() {
    NotificationService().pendingNotificationRequests().then((value) {
      pendingNotificationIds = value.map((e) => e.id).toList();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final _model = context.watch<BirthdaysWidgetModel>();

    final colorTheme = context.watch<ModelTheme>().colorTheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final birthdayModel = await showCreateBirthdayDialog();

            if (birthdayModel.name.isNotEmpty) {
              _model.addBirthday(birthdayModel);
            }
          }),
      backgroundColor: isDesktop
          ? colorTheme.mobileScaffoldColor
          : colorTheme.mobileScaffoldColor,
      appBar: isDesktop
          ? null
          : CustomAppBar(title: 'Birthdays', actions: [
              IconButton(
                onPressed: checkAndSetNotifications,
                icon: const Icon(CupertinoIcons.refresh),
              )
            ]),
      body: Stack(
        children: [
          if (_model.birthdays != null)
            Column(
              //padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                const SizedBox(
                  height: 22,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 46,
                  decoration: const BoxDecoration(),
                  child: TextField(
                    onChanged: _model.onSearch,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintStyle: const TextStyle(fontSize: 16),
                        labelStyle: const TextStyle(fontSize: 16),
                        prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100))),
                  ),
                ),
                const SizedBox(
                  height: 22,
                ),
                SizedBox(
                  height: 29,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (BuildContext context, int index) {
                      return labels[index];
                    },
                    itemCount: labels.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 8);
                    },
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Expanded(
                  child: ListView.separated(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 150),
                      itemBuilder: (context, index) {
                        final model = _model.birthdays![index];

                        final isShowLabel = index == 0 ||
                            model.getLabelDate !=
                                _model.birthdays![index - 1].getLabelDate;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isShowLabel)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 18, bottom: 16),
                                child: Text(
                                  model.getLabelDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            Opacity(
                                opacity: pendingNotificationIds
                                        .contains(model.uid.hashCode)
                                    ? 1
                                    : 0.4,
                                child: BirthdayCardWidget(model: model)),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      itemCount: _model.birthdays!.length),
                ),
                /*    ..._model.birthdays.map((BirthdayModel e) {
                return BirthdayCardWidget(
                  model: e,
                );
              }).toList(), */
              ],
            )
          else
            Align(
              alignment: const Alignment(0, 0.5),
              child: ProgressIndicatorWidget(
                size: 30,
                color: colorTheme.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> checkAndSetNotifications() async {
    int count = 0;
    final birthdays = context.read<BirthdaysWidgetModel>().birthdays;

    final notifications =
        await NotificationService().pendingNotificationRequests();
    final notificationIds = notifications.map((e) => e.id);

    for (final item in birthdays!) {
      final id = item.uid.hashCode;
      if (!notificationIds.contains(id)) {
        await NotificationService()
            .yearlyNotification(item.uid.hashCode, item.birthday, item.name);
        count++;
      }
    }
    loadPendingNotificationRequests();
    await showAlert(title: 'Add $count new birthdays');
  }

  Future<BirthdayModel> showCreateBirthdayDialog() async {
    BirthdayModel birthdayModel = BirthdayModel.empty();
    DateTime date = DateTime.now();

    String errorText = '';

    return showModalBottomSheet<BirthdayModel>(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            context: context,
            builder: (ctx) {
              return StatefulBuilder(builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        errorText: errorText.isEmpty ? null : errorText,
                        prefixIcon: const Icon(CupertinoIcons.person),
                        hintText: 'Введите имя',
                        enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF1F0F5)),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        disabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF1F0F5)),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF1F0F5)),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                      onChanged: (name) {
                        errorText = '';
                        state(() {});
                        birthdayModel = birthdayModel.copyWith(name: name);
                      },
                    ),
                    /*   TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                          hintText: 'Введите имя',
                          errorText: errorText.isEmpty ? null : errorText),
                      onChanged: (name) {
                        errorText = '';
                        state(() {});
                        birthdayModel = birthdayModel.copyWith(name: name);
                      },
                    ), */
                    const SizedBox(
                      height: 20,
                    ),
                    DatePickerWidget(
                      onDateTimeChanged: (DateTime dateTime) {
                        date = dateTime;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            if ((birthdayModel.name).trim().isEmpty) {
                              errorText = 'Введите имя';
                              state(() {});
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('OK')),
                    )
                  ]),
                );
              });
            })
        .then((value) => birthdayModel.copyWith(
            birthday: DateTime(date.year, date.month, date.day, 10)));
    /*  return showDialog<BirthdayModel>(
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
        }); */
  }
}

class LabelWidget extends StatelessWidget {
  const LabelWidget({
    Key? key,
    required this.text,
    required this.onTap,
    required this.isActive,
  }) : super(key: key);

  final String text;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.watch<ModelTheme>().colorTheme;
    final color = isActive ? colorTheme.primaryColor : Colors.grey;

    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: () {},
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minWidth: 70),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(100)),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
