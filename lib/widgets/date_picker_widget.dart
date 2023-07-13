import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({
    Key? key,
    required this.onDateTimeChanged,
    this.initDate,
  }) : super(key: key);

  final void Function(DateTime) onDateTimeChanged;
  final DateTime? initDate;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late int dayIndex;
  late int monthIndex;
  late int yearIndex;

  @override
  void initState() {
    final DateTime startDate = widget.initDate ?? DateTime.now();
    dayIndex = startDate.day;
    monthIndex = startDate.month;
    yearIndex = startDate.year;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final countDays = daysCount(DateTime(yearIndex, monthIndex));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PickerItemWidget(
            title: 'Day',
            onChangeValue: (value) {
              dayIndex = value;
              widget
                  .onDateTimeChanged(DateTime(yearIndex, monthIndex, dayIndex));
              setState(() {});
            },
            max: countDays,
            initValueIndex: dayIndex),
        PickerItemWidget(
            title: 'Month',
            isShowName: true,
            onChangeValue: (value) {
              monthIndex = value;
              widget
                  .onDateTimeChanged(DateTime(yearIndex, monthIndex, dayIndex));
              setState(() {});
            },
            max: 12,
            initValueIndex: monthIndex),
        PickerItemWidget(
            title: 'Year',
            onChangeValue: (value) {
              yearIndex = value;
              widget
                  .onDateTimeChanged(DateTime(yearIndex, monthIndex, dayIndex));
              setState(() {});
            },
            max: DateTime.now().year,
            min: 1930,
            initValueIndex: yearIndex)
      ],
    );
  }

  int daysCount(DateTime dateTime) {
    final DateTime init = DateTime(dateTime.year, dateTime.month).toUtc();
    final count = DateTime(dateTime.year, dateTime.month + 1)
        .toUtc()
        .difference(init)
        .inDays;
    return count;
  }
}

class PickerItemWidget extends StatefulWidget {
  const PickerItemWidget({
    required this.title,
    required this.onChangeValue,
    required this.max,
    this.min,
    required this.initValueIndex,
    this.isShowName = false,
    Key? key,
  }) : super(key: key);

  final bool isShowName;
  final String title;
  final int? min;
  final int max;
  final int initValueIndex;
  final void Function(int) onChangeValue;

  @override
  State<PickerItemWidget> createState() => _PickerItemWidgetState();
}

class _PickerItemWidgetState extends State<PickerItemWidget> {
  FixedExtentScrollController scrollController = FixedExtentScrollController();
  int ind = 0;
  bool isInitialize = false;
  @override
  void initState() {
    Future<dynamic>.delayed(const Duration(seconds: 0)).then((dynamic value) {
      scrollController
          .animateTo((widget.initValueIndex - 1) * 40,
              duration: const Duration(seconds: 1), curve: Curves.easeIn)
          .then((value) {
        isInitialize = true;
      });
      ind = widget.initValueIndex;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Intl.defaultLocale = "zh_HK";
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const SizedBox(
          height: 12,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: ListWheelScrollView.useDelegate(
                controller: scrollController,
                physics: const FixedExtentScrollPhysics(),
                itemExtent: 40,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    ind = index;
                    widget.onChangeValue(index + 1 + (widget.min??0));
                  });
                  if (!Platform.isMacOS && isInitialize) {
                    Vibration.vibrate(duration: 1);
                  }
                },
                childDelegate: ListWheelChildBuilderDelegate(
                    childCount: widget.max - (widget.min ?? 0),
                    builder: (BuildContext context, int index) {
                      if (widget.isShowName) {
                        final date = DateTime(DateTime.now().year, index + 1);
                        return Text(
                          DateFormat('MMM').format(date),
                          style: TextStyle(
                            fontSize: 30,
                            color: ind == index ? Colors.black : Colors.grey,
                            //color: Colors.grey,
                          ),
                        );
                      }
                      return Text(
                        '${index + 1 + (widget.min??0)}',
                        style: TextStyle(
                          fontSize: 30,
                          color: ind == index ? Colors.black : Colors.grey,
                          //color: Colors.grey,
                        ),
                      );
                    }),
              ),
            ),
            //  IgnorePointer(
            //    child: Container(
            //      color: Colors.black.withOpacity(0.1),
            //      height: 40,
            //      width: 100,
            //    ),
            //  )
            //ColorFiltered(
            //  child: Container(
            //    //color: Colors.transparent,
            //    width: 100,
            //    height: 40,
            //  ),
            //  colorFilter: ColorFilter.mode(Colors.black, BlendMode.clear),
            //)
          ],
        ),
      ],
    );
  }
}
