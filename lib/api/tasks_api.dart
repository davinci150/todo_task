import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../model/folder_model.dart';
import '../model/group_model.dart';
import '../widgets/dialog/adaptive_dialog.dart';
import 'auth_api.dart';

@LazySingleton()
class TasksApi {
  TasksApi({required this.authApi});

  final AuthApi authApi;

  Stream<List<FolderModel>> foldersStream() {
    /*  documentReference().snapshots().map((event) {
      print('####qq ${event.data()}');
      final folders = <FolderModel>[];
      event.data()!.forEach((key, dynamic value) {
        final dataMap = value as Map<String, dynamic>;
        dataMap.forEach((key, dynamic item) {
          final folderName = item as String;
          folders.add(FolderModel(title: folderName.toString()));
        });
      });
      return folders;
    }); */

    return Rx.combineLatest2(
        documentReference1().collection('folders').snapshots(),
        documentReference1().snapshots(),
        (QuerySnapshot<Map<String, dynamic>> a,
            DocumentSnapshot<Map<String, dynamic>> b) {
      final List<FolderModel> myFolders = [];
      for (final element in a.docs) {
        myFolders.add(FolderModel(title: element.id));
      }

      final folders = <FolderModel>[];
      if (b.data() != null) {
        b.data()!.forEach((key, dynamic value) {
          final folderName = value as String;
          folders.add(FolderModel(title: folderName.toString(), ownerUid: key));
        });
      }

      return [...myFolders, ...folders];
    });
  }

  Future<void> renameFolder(FolderModel folder, String title) async {
    await showAlert(title: 'ПОКА НЕ ДОСТУПНО');
    return;
    /*   final doc =
        await documentReference().collection('folders').doc(folderKey).get();
    if (doc.exists) {
      final data = doc.data()!;
      await documentReference().collection('folders').doc(title).set(data);
      await documentReference().collection('folders').doc(folderKey).delete();
    } */
  }

  Future<List<String?>> getUsersByIds(List<String> uids) async {
    final List<String?> users = [];
    print('### GET BY ID ${uids}');
    for (final uid in uids) {
      final usersByEmail =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      users.add(usersByEmail.data()?['Name'] as String?);
    }
    return users;
  }

  Future<bool> share(String email, FolderModel folder) async {
    final usersByEmail = FirebaseFirestore.instance
        .collection('users')
        .where('Email', isEqualTo: email);
    final doc = await usersByEmail.get();
    if (doc.docs.isEmpty) {
      return false;
    } else {
      print(doc.docs.first.data());
      final userUid = doc.docs.first.id;
      print(userUid);
      await FirebaseFirestore.instance
          .collection(authApi.getPath)
          .doc(userUid)
          .update(<String, dynamic>{authApi.getUid!: folder.title});
      await documentReference1()
          .collection('folders')
          .doc(folder.title)
          .collection('members')
          .doc(userUid)
          .set(<String, dynamic>{});
      /*   await FirebaseFirestore.instance
          .collection(authApi.getPath)
          .doc(authApi.getUid)
          .update(<String, dynamic>{authApi.getUid!: folder.title}); */

      return true;
    }

    /*   final doc =
        await documentReference().collection('folders').doc(folderKey).get();
    if (doc.exists) {
      final data = doc.data()!;
      await documentReference().collection('folders').doc(title).set(data);
      await documentReference().collection('folders').doc(folderKey).delete();
    } */
  }

  Stream<GroupWrapper> getGroups(FolderModel folder) {
    /*   return documentReference()
        .collection('folders')
        .doc(folderKey)
          .collection('tasks')
        .snapshots()
        .map((event) {
        
      print('####qq ${event.reference.collection('tasks')}');
      /*   final members = [];
      final groups = event
          .data()['tasks']
          .map((e) => GroupModel.fromJson(e.data(), e.id))
          .toList();
      groups.sort((a, b) => a.createdOn.compareTo(b.createdOn)); */
      return GroupWrapper(groups: [], members: []);
    }); */

    return Rx.combineLatest2(
        documentReference(folder)
            .collection('folders')
            .doc(folder.title)
            .collection('tasks')
            .snapshots(),
        documentReference(folder)
            .collection('folders')
            .doc(folder.title)
            .collection('members')
            .snapshots(),
        (QuerySnapshot<Map<String, dynamic>> a,
            QuerySnapshot<Map<String, dynamic>> b) {
      final groups = a.docs
          .map((e) => GroupModel.fromJson(e.data(), e.id))
          .toList()
        ..sort((a, b) => a.createdOn.compareTo(b.createdOn));

      final members = b.docs.map((e) => Members(uid: e.id)).toList();
      /*   groups.forEach((element) {
        if (element.viewedUid.contains(authApi.getUid)) return;
        if (element.ownerUid == authApi.getUid) return;
        final viewedUid = List.of(element.viewedUid)..add(authApi.getUid!);
        final groupModel = element.copyWith(viewedUid: viewedUid);
        onChangeGroupModel(folder, groupModel);
      }); */

      return GroupWrapper(groups: groups, members: members);
    });
  }

  void onChangeGroupModel(FolderModel folder, GroupModel model) {
    documentReference(folder)
        .collection('folders')
        .doc(folder.title)
        .collection('tasks')
        .doc(model.uid)
        .set(model.toJson());
  }

  void createGroup(FolderModel folder, GroupModel model) {
    final mod = model.copyWith(ownerUid: authApi.getUid);

    documentReference(folder)
        .collection('folders')
        .doc(folder.title)
        .collection('tasks')
        .doc()
        .set(mod.toJson());
  }

  void deleteGroup(FolderModel folder, GroupModel model) {
    documentReference(folder)
        .collection('folders')
        .doc(folder.title)
        .collection('tasks')
        .doc(model.uid)
        .delete();
  }

  DocumentReference<Map<String, dynamic>> documentReference(FolderModel model) {
    return FirebaseFirestore.instance
        .collection(authApi.getPath)
        .doc(model.ownerUid ?? authApi.getUid);
  }

  DocumentReference<Map<String, dynamic>> documentReference1() {
    return FirebaseFirestore.instance
        .collection(authApi.getPath)
        .doc(authApi.getUid);
  }

  Future<void> createFolder(String title) async {
    final doc =
        await documentReference1().collection('folders').doc(title).get();
    if (doc.exists) {
      await showAlert(title: 'This folder is exists');
    } else {
      await documentReference1()
          .collection('folders')
          .doc(title)
          .set(<String, dynamic>{});
      await documentReference1()
          .collection('folders')
          .doc(title)
          .collection('members')
          .doc(authApi.getUid)
          .set(<String, dynamic>{});
    }
  }

  void deleteFolder(String folderKey) {
    documentReference1().collection('folders').doc(folderKey).delete();
  }
}
