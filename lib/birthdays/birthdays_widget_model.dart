import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '../model/birthday_model.dart';
import '../repository/birthdays_repository.dart';

class BirthdaysWidgetModel extends ChangeNotifier {
  BirthdaysWidgetModel() {
    _setup();
  }

  List<BirthdayModel>? birthdays;

  BehaviorSubject<String> searchSubj = BehaviorSubject.seeded('');
  StreamSubscription<dynamic>? streamSub;

  void _setup() {
    final bdStream = GetIt.I<BirthdaysRepository>().birthdaysStream();
    streamSub = Rx.combineLatest2(bdStream, searchSubj,
        (List<BirthdayModel>? event, String searchText) {
      final list = List<BirthdayModel>.of(event ?? []);

      if (searchText.isNotEmpty) {
        return list
            .where((element) =>
                element.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      } else {
        return list;
      }
    }).listen((event) {
      birthdays = event;
      notifyListeners();
    });
  }

  void addBirthday(BirthdayModel model) {
    GetIt.I<BirthdaysRepository>().addBirthday(model);
  }

  void deleteBirthday(String id) {
    GetIt.I<BirthdaysRepository>().deleteBirthday(id);
  }

  void onSearch(String text) {
    searchSubj.sink.add(text);
  }

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    if (!_disposed) super.dispose();
    _disposed = true;
    streamSub?.cancel();
    searchSubj.close();
  }
}
