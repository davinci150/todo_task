import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../model/folder_model.dart';
import '../model/task_model.dart';
import 'auth_api.dart';

@LazySingleton()
class TasksApi {
  TasksApi({required this.authApi});

  final AuthApi authApi;

  Stream<List<FolderModel>> foldersStream() {
    return groupsRef()
        .where('Members', arrayContains: authApi.getUid)
        .snapshots()
        .map((event) {
      return event.docs
          .map((e) => FolderModel.fromJson(e.data(), e.id))
          .toList();
    });
  }

  Future<void> renameFolder(FolderModel folder, String title) async {
    await groupsRef().doc(folder.id).update(<String, dynamic>{'Name': title});
  }

  Future<List<String?>> getUsersByIds(List<String> ids) async {
    final List<String?> users = [];
    for (final uid in ids) {
      final usersByEmail = await usersRef().doc(uid).get();

      users.add(usersByEmail.data()?['Name'] as String?);
    }
    return users;
  }

  Future<FolderModel> getGroupById(String id) async {
    final groupModel = await groupsRef().doc(id).get();
    return FolderModel.fromJson(groupModel.data()!, groupModel.id);
  }

  Future<void> share(String email, FolderModel folder) async {
    final usersByEmail = usersRef().where('Email', isEqualTo: email);
    final usersDocs = await usersByEmail.get().then((value) => value.docs);

    if (usersDocs.isEmpty) {
      throw Exception('Нет такого пользователя');
    } else {
      final userId = usersDocs.first.id;
      final groupModel = await getGroupById(folder.id);

      if (groupModel.members.contains(userId)) {
        throw Exception('У пользователя уже есть доступ к этому списку');
      }
      final members = List.of(groupModel.members)..add(userId);
      await groupsRef()
          .doc(folder.id)
          .update(<String, dynamic>{'Members': members});
    }
  }

  Stream<List<TaskModel>> getGroups(FolderModel folder) {
    return tasksRef(folder.id).snapshots().map((event) {
      final tasks = event.docs
          .map((e) => TaskModel.fromJson(e.data(), e.id))
          .toList()
        ..sort((a, b) => a.createdOn.compareTo(b.createdOn));
      return tasks;
    });
  }

  void onChangeGroupModel(FolderModel folder, TaskModel model) {
    tasksRef(folder.id).doc(model.id).set(model.toJson());
  }

  Future<void> createGroup(FolderModel folder, TaskModel model) async {
    final groupModel = model.copyWith(ownerUid: authApi.getUid);
    await tasksRef(folder.id).add(groupModel.toJson());
  }

  void deleteGroup(FolderModel folder, TaskModel model) {
    tasksRef(folder.id).doc(model.id).delete();
  }

  Future<FolderModel> createFolder(String title) async {
    final userId = authApi.getUid!;
    final FolderModel folderModel =
        FolderModel(id: '', name: title, createdBy: userId, members: [userId]);
    final response = await groupsRef().add(folderModel.toJson());

    return folderModel.copyWith(id: response.id);
  }

  Future<void> deleteFolder(String folderId) async {
    print('### ${folderId}');
   // await groupsRef().doc(folderId).delete();

    await FirebaseFirestore.instance.collection('tasks').doc('MlG8EjUbarT0Lt3ZHGkm').delete();
  }

  Future<void> removeFolderForMe(String folderKey, String ownerUid) async {
    final userId = authApi.getUid!;
    await groupsRef().doc(folderKey).update({
      'Members': FieldValue.arrayRemove(<dynamic>[userId])
    });
  }

  CollectionReference<Map<String, dynamic>> groupsRef() {
    return FirebaseFirestore.instance.collection('groups');
  }

  CollectionReference<Map<String, dynamic>> usersRef() {
    return FirebaseFirestore.instance.collection('users');
  }

  CollectionReference<Map<String, dynamic>> tasksRef(String folderId) {
    return FirebaseFirestore.instance
        .collection('tasks')
        .doc(folderId)
        .collection('tasks');
  }

  /*  Future<void> batchDelete() {
  WriteBatch batch = FirebaseFirestore.instance.batch();

  return users.get().then((querySnapshot) {
    querySnapshot.docs.forEach((document) {
      batch.delete(document.reference);
    });

    return batch.commit();
  });
} */
}
