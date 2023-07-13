import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class BirthdayModel extends Equatable {
  const BirthdayModel({
    required this.uid,
    required this.name,
    required this.birthday,
  });

  factory BirthdayModel.fromJson(Map<String, dynamic> json, String uid) =>
      BirthdayModel(
        uid: uid,
        name: json['Name'] as String,
        birthday: DateTime.parse(json['Birthday'] as String),
      );

  factory BirthdayModel.empty() =>
      BirthdayModel(uid: '', name: '', birthday: DateTime.now());

  final String uid;
  final String name;
  final DateTime birthday;

  BirthdayModel copyWith({String? name, String? uid, DateTime? birthday}) {
    return BirthdayModel(
      name: name ?? this.name,
      uid: uid ?? this.uid,
      birthday: birthday ?? this.birthday,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Name'] = name;
    data['Birthday'] = birthday.toIso8601String();

    return data;
  }

  @override
  String toString() =>
      'BirthdayModel{name: $name, birthday: ${birthday.toIso8601String()}, uid: $uid}';

  @override
  List<Object?> get props => [name, birthday];
}

extension BirthdayExt on BirthdayModel {
  int get countdownDays {
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);

    final birthdayDate = DateTime(now.year, birthday.month, birthday.day);

    if (nowDate == birthdayDate) {
      return 0;
    }

    return correctDate.difference(nowDate).inDays;
  }

  DateTime get correctDate {
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final birthdayDate = DateTime(now.year, birthday.month, birthday.day);
    return DateTime(birthdayDate.isAfter(nowDate) ? now.year : now.year + 1,
        birthday.month, birthday.day);
  }

  String get getLabelDate {
    final DateTime appointedDate = correctDate;

    final nowDate = DateTime.now();
    final now = DateTime(nowDate.year, nowDate.month, nowDate.day);

    final DateTime currentWeekStart =
        now.subtract(Duration(days: now.weekday - 1));

    final DateTime currentWeekEnd =
        currentWeekStart.add(const Duration(days: 6));

    final DateTime nextWeekStart = currentWeekEnd.add(const Duration(days: 1));

    final bool isCurrentWeek = appointedDate == currentWeekStart ||
        (appointedDate.isAfter(currentWeekStart) &&
            appointedDate.isBefore(nextWeekStart));
    final bool isNextWeek = appointedDate == nextWeekStart ||
        (appointedDate.isAfter(nextWeekStart) &&
            appointedDate.isBefore(nextWeekStart.add(const Duration(days: 7))));

    final countDays = countdownDays;
    if (countDays == 0) return 'Today';
    if (countdownDays == 1) return 'Tomorrow';
    if (isCurrentWeek) return 'This week';
    if (isNextWeek) return 'Next week';
    return DateFormat('MMM yyyy').format(correctDate);
  }
}
