import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_task/model/group_model.dart';

import '../model/folder_model.dart';

class TasksDao {
  TasksDao._();

  static final TasksDao instance = TasksDao._();

  late SharedPreferences prefs;

  static const folderKeys = kDebugMode ? 'folderKeysDebugV1' : 'folderKeysV1';

  static const selectedGroupKey =
      kDebugMode ? 'selectedGroupTestV2' : 'selectedGroupV2';

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  void saveTasks(List<GroupModel> list, String folderKey) {
    final saveJson = list.map((e) => e.toJson()).toList();
    final result = jsonEncode(saveJson);

    prefs.setString(folderKey, result);
  }

  void setSelectedGroup(String? id) {
    if (id == null) {
      prefs.remove(selectedGroupKey);
    } else {
      prefs.setString(selectedGroupKey, id);
    }
  }

  String? getSelectedGroup() {
    return prefs.getString(selectedGroupKey);
  }

  List<FolderModel>? folders;
  List<GroupModel>? groups;

  List<FolderModel> getFolders() {
    if (folders != null) {
      return folders!;
    }
    List<FolderModel> result = [];
    final jsonStr = prefs.getString(folderKeys);
    log('keysFolders $jsonStr');
    if ((jsonStr ?? '').isNotEmpty) {
      final map = jsonDecode(jsonStr!) as List<dynamic>;
      for (var value in map) {
        result.add(FolderModel.fromJson(value as Map<String, dynamic>));
      }
    }
    folders = result;
    return result;
  }

  List<GroupModel> getGroups(String folderKey) {
    if (groups != null) {
      return groups!;
    }
    List<GroupModel> result = [];
    final jsonStr = prefs.getString(folderKey);
    log('keysGroups $jsonStr');
    if ((jsonStr ?? '').isNotEmpty) {
      final map = jsonDecode(jsonStr!) as List<dynamic>;
      for (var value in map) {
        result.add(GroupModel.fromJson(value as Map<String, dynamic>));
      }
    }

    return result;
  }

  void _saveFolders() {
    final saveJson = folders!.map((e) => e.toJson()).toList();
    final result = jsonEncode(saveJson);
    log('save $result');
    prefs.setString(folderKeys, result);
  }

  // void removeAll() {
  //   prefs.remove(taskKey);
  // }

  void deleteFolder(FolderModel model) {
    folders!.remove(model);

    _saveFolders();
  }

  void createFolder(FolderModel model) {
    log(model.toString());
    log('folder lng before: ${folders!}');
    folders!.add(model);
    log('folder lng after: ${folders!}');

    _saveFolders();
  }
}
