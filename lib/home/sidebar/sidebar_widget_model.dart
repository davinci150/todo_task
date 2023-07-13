import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:todo_task/dao/tasks_dao.dart';
import 'package:todo_task/repository/tasks_repository.dart';

import '../../api/auth_api.dart';
import '../../model/folder_model.dart';

class SidebarWidgetModel extends ChangeNotifier {
  SidebarWidgetModel() {
    setup();
  }

  List<FolderModel> list = [];

  String? selectedFolderStr;

  Future<void> logout() async {
    await GetIt.I<AuthApi>().logout();
    /*    list.clear();
    selectedFolderStr = null;
    notifyListeners(); 
    await sub?.cancel();*/
  }

  StreamSubscription<List<FolderModel>?>? sub;
  void setup() {
    //  final selectedGroupIndex = TasksDao.instance.getSelectedGroup();

    //  list = TasksDao.instance.getFolders();

    //  if (selectedGroupIndex != null) {
    //    selectedFolderStr = selectedGroupIndex;
    //  }
    //sub?.cancel();
    sub = GetIt.I<TasksRepository>().foldersStream().listen((event) {
      list = event ?? [];
      notifyListeners();
    });
  }

  bool _disposed = false;

  @override
  void notifyListeners() {
   // print('### CHANGE NOTI');
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    sub?.cancel();
    if (!_disposed) {
      super.dispose();
    }

    _disposed = true;
  }

  void deleteFolder(FolderModel model) {
    GetIt.I<TasksRepository>().deleteFolder(model);
    selectedFolderStr = null;
    notifyListeners();
  }

  void removeFolderForMe(FolderModel model) {
    GetIt.I<TasksRepository>().removeFolderForMe(model, model.createdBy!);
    selectedFolderStr = null;
    notifyListeners();
  }

  Future<FolderModel> addFolder(String title) {
    final folderModel = FolderModel(
        name: title,
        createdBy: GetIt.I<AuthApi>().getUid!,
        members: [],
        id: '');
    selectFolder(title);
    return GetIt.I<TasksRepository>().createFolder(folderModel);
  }

  void selectFolder(String folderKey) {
    selectedFolderStr = folderKey;
    notifyListeners();
    GetIt.I<TasksDao>().setSelectedGroup(selectedFolderStr!);
  }

  Future<void> renameFolder(String title, FolderModel folder) async {
    await GetIt.I<TasksRepository>().renameFolder(title, folder);
    selectFolder(title);
    notifyListeners();
  }
}
