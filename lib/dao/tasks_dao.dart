import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/folder_model.dart';

class TasksDao {
  TasksDao._();

  static final TasksDao instance = TasksDao._();

  late SharedPreferences prefs;

  static const taskKey = kDebugMode ? 'testKeyV1' : 'taskKeyV2';

  static const selectedGroupKey =
      kDebugMode ? 'selectedGroupTestV1' : 'selectedGroupV1';

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  void saveTasks(List<FolderModel> list) {
    final saveJson = list.map((e) => e.toJson()).toList();
    final result = jsonEncode(saveJson);
    log(list.toString());
    prefs.setString(taskKey, result);
  }

  void setSelectedGroup(int id) {
    prefs.setInt(selectedGroupKey, id);
  }

  int getSelectedGroup() {
    return prefs.getInt(selectedGroupKey) ?? -1;
  }

  List<FolderModel> getFolders() {
    List<FolderModel> result = [];
    final jsonStr = prefs.getString(taskKey);
    if ((jsonStr ?? '').isNotEmpty) {
      final map = jsonDecode(jsonStr!) as List<dynamic>;
      for (var value in map) {
        result.add(FolderModel.fromJson(value as Map<String, dynamic>));
      }
    }
    return result;
  }

  void removeAll() {
    prefs.remove(taskKey);
  }
}
