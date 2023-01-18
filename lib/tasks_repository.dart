import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_task/model/group_model.dart';

import 'package:rxdart/rxdart.dart';
import 'dao/tasks_dao.dart';
import 'home_page.dart';
import 'model/folder_model.dart';

class TasksRepository {
  TasksRepository._();

  static final TasksRepository instance = TasksRepository._();

  BehaviorSubject<List<GroupModel>>? streamGroups;
  BehaviorSubject<List<FolderModel>>? streamFolders;

  String? selectedFolderStr;

  Stream<List<FolderModel>?> foldersStream() {
    final Stream<List<FolderModel>> firestoreStream = FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .snapshots()
        .map((event) {
      final list = event.docs
          .map((e) => FolderModel(title: e.id, createdOn: null))
          .toList();
      log('listFromFirestore: ${list.length}');
      return list;
    });
    streamFolders ??= BehaviorSubject();

    final fold = List.of(TasksDao.instance.getFolders());
    log('load folder ${fold.length}');

    streamFolders!.sink.add(fold);

    return Rx.merge([
      firestoreStream,
      streamFolders!.stream,
    ]);
  }

  Stream<List<GroupModel>?> groupsStream(String? folderKey) {
    if (folderKey == null) return Stream.value(null);

    log('getStream: $folderKey');
    final Stream<List<GroupModel>> firestoreStream = FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(folderKey)
        .snapshots()
        .map((event) {
      if (event.data() == null) {
        return [];
      }
      final list = event
          .data()!
          .values
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
      log('listFromFirestore: ${list.length}');
      return list;
    });
    streamGroups ??= BehaviorSubject();

    if (selectedFolderStr != folderKey) {
      selectedFolderStr = folderKey;
      final list = TasksDao.instance.getGroups(folderKey);
      log('load list ${list.length}');

      streamGroups!.sink.add(list);
    }
    return Rx.merge([
      // firestoreStream,
      streamGroups!.stream,
    ]);
    /* return Rx.combineLatest2(firestoreStream, streamGroups!.stream,
        (List<GroupModel> a, List<GroupModel> b) {
      log('Firestore lng: ${a.length},  Local lng: ${b.length}');
      return a;
    });*/
  }

  Future<void> createTask(String folderName) async {
    log('create task to $folderName');
    final group = GroupModel.empty();
    final list = streamGroups!.value..add(group);
    streamGroups!.sink.add(list);

    saveTasks(list, folderName);

    //--
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(folderName)
        .update({
      group.createdOn!.millisecondsSinceEpoch.toString(): group.toJson()
    });
  }

  Future<void> deleteTask(GroupModel model, String folderName) async {
    log('remove task $folderName');

    final list = streamGroups!.value..remove(model);

    saveTasks(list, folderName);
    streamGroups!.sink.add(list);
    //--
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(folderName)
        .update({
      model.createdOn!.millisecondsSinceEpoch.toString(): FieldValue.delete()
    });
  }

  Future<void> createFolder(String folderName) async {
    final folderModel =
        FolderModel(title: folderName, createdOn: DateTime.now());
    final l = streamFolders!.value..add(folderModel);
    streamFolders!.add(l);

    TasksDao.instance.createFolder(folderModel);

    //--
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(folderName)
        .set({});
  }

  void onChangedGroupModel(String folderName, GroupModel newModel, int index) {
    final list = streamGroups!.value..[index] = newModel;

    saveTasks(list, folderName);
    streamGroups!.sink.add(list);

    //--
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(folderName)
        .update({
      newModel.createdOn!.millisecondsSinceEpoch.toString(): newModel.toJson()
    });
  }

  void deleteGroup(FolderModel model) {
    final l = streamFolders!.value..remove(model);
    streamFolders!.add(l);
    TasksDao.instance.deleteFolder(model);
    TasksDao.instance.setSelectedGroup(-1);

    //--
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('folders')
        .doc(model.title)
        .delete();
  }

  void saveTasks(List<GroupModel> list, String folderKey) {
    TasksDao.instance.saveTasks(list, folderKey);
  }
}
