import 'package:flutter/material.dart';
import 'package:todo_task/dao/tasks_dao.dart';
import 'package:todo_task/repository/tasks_repository.dart';

import 'model/folder_model.dart';

class SidebarWidgetModel extends ChangeNotifier {
  SidebarWidgetModel() {
    _setup();
  }

  List<FolderModel> list = [];

  String? selectedFolderStr;

  void _setup() {
    final selectedGroupIndex = TasksDao.instance.getSelectedGroup();

    list = TasksDao.instance.getFolders();

    if (selectedGroupIndex != null) {
      selectedFolderStr = selectedGroupIndex;
    }

    TasksRepository.instance.foldersStream().listen((event) {
      list = event ?? [];
      notifyListeners();
    });
  }

  void deleteGroup(FolderModel model) {
    TasksRepository.instance.deleteGroup(model);
    selectedFolderStr = null;
    notifyListeners();
  }

  void addFolder(String title) {
    final folderModel = FolderModel(title: title);
    TasksRepository.instance.createFolder(folderModel);
    selectFolder(title);
  }

  void selectFolder(String folderKey) {
    selectedFolderStr = folderKey;
    notifyListeners();
    TasksDao.instance.setSelectedGroup(selectedFolderStr!);
  }

  Future<void> renameFolder(String title, String folderKey) async {
    await TasksRepository.instance.renameFolder(title, folderKey);
    selectFolder(title);
    notifyListeners();
  }
}

class SidebarWidgetModelProvider extends InheritedNotifier {
  const SidebarWidgetModelProvider(
      {Key? key, required Widget child, required this.model})
      : super(key: key, child: child, notifier: model);

  final SidebarWidgetModel model;

  static SidebarWidgetModelProvider? watch(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SidebarWidgetModelProvider>();
  }

  static SidebarWidgetModelProvider? read(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<SidebarWidgetModelProvider>()
        ?.widget;
    return widget is SidebarWidgetModelProvider ? widget : null;
  }

  @override
  bool updateShouldNotify(covariant InheritedNotifier<Listenable> oldWidget) {
    return true;
  }
}
