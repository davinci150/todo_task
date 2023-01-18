import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_task/tasks_repository.dart';
import 'package:todo_task/tasks_widget_model.dart';

import 'api/auth_api.dart';
import 'dao/auth_dao.dart';
import 'model/folder_model.dart';
import 'model/user_model.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late AuthDao authDao;
  UserModel? userModel;

  @override
  void initState() {
    authDao = AuthDao();
    initUser();
    super.initState();
  }

  Future<void> initUser() async {
    final user = await authDao.getLoggedUser();
    if (user != null) {
      userModel = user;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    //final model = TaskWidgetModelProvider.watch(context)?.model;
    return Drawer(
        width: 200,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 55,
                  width: 55,
                  color: Colors.grey,
                  child: userModel == null
                      ? InkWell(onTap: signUp, child: const Icon(Icons.account_box))
                      : Image.network(userModel!.imageUrl),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              if (userModel != null)
                Text(
                  userModel!.name.isEmpty ? 'NONE' : userModel!.name,
                  //style: TextStyle(color: Colors.grey),
                ),
              const SizedBox(
                height: 8,
              ),
              if (userModel != null)
                Text(
                  userModel!.email,
                  style: const TextStyle(color: Colors.grey),
                ),
              if (userModel != null)
                Text(
                  'UID: ${userModel!.uid}',
                  //style: TextStyle(color: Colors.grey),
                ),
              StreamBuilder<List<FolderModel>?>(
                  stream: TasksRepository.instance.foldersStream(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const Offstage();
                    }
                    return Column(children: <Widget>[
                      ...snapshot.data!.map((e) => GroupItemWidget(e)).toList(),
                      ...[addNewGroupDrawerButton()]
                    ]);
                  }),
            ],
          ),
        ));
  }

  Widget addNewGroupDrawerButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        showAddGroupDialog();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.fromLTRB(6, 0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Add new group'),
            Container(
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(6)),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signUp() async {
    final user = await AuthApi().signUp();
    if (user != null) {
      userModel = user;
      setState(() {});
    }
  }

  void showAddGroupDialog() {
    String title = '';
    showDialog(
        context: context,
        builder: (ctx) {
          final model = TaskWidgetModelProvider.read(context)?.model;
          return AlertDialog(
            title: const Text('Input title'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onEditingComplete: () => model?.addFolder(title),
                autofocus: true,
                onChanged: (text) {
                  title = text;
                },
                decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red))),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => model?.addFolder(title),
                  child: const Text('OK')),
            ],
          );
        });
  }
}

class GroupItemWidget extends StatelessWidget {
  const GroupItemWidget(this.folderModel, {Key? key}) : super(key: key);
  final FolderModel folderModel;

  @override
  Widget build(BuildContext context) {
    final model = TaskWidgetModelProvider.watch(context)?.model;
    return GestureDetector(
      onSecondaryTapUp: (det) {
        showButtonMenu(context, det);
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          model?.selectGroup(folderModel);
        },
        child: Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          height: 36,
          padding: const EdgeInsets.only(left: 6),
          decoration: model?.selectedFolderStr != folderModel.title
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).backgroundColor),
          child: Text(folderModel.title!),
        ),
      ),
    );
  }

  void showButtonMenu(BuildContext context, TapUpDetails tapDetails) {
    final position = RelativeRect.fromLTRB(
        tapDetails.globalPosition.dx,
        tapDetails.globalPosition.dy,
        tapDetails.globalPosition.dx,
        tapDetails.globalPosition.dy);

    final items = [
      CustomPopupMenuItem(value: 'share', iconData: Icons.share),
      CustomPopupMenuItem(
          value: 'delete',
          iconData: Icons.delete,
          iconColor: Colors.redAccent,
          textColor: Colors.redAccent),
    ];

    if (items.isNotEmpty) {
      showMenu<String>(
        context: context,
        elevation: 2,
        items: items,
        position: position,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).then<void>((dynamic newValue) {
        if (newValue == 'delete') {
          showDeleteGroupDialog(folderModel, context);
        } else if (newValue == 'share') {
          //
        }
      });
    }
  }

  void showDeleteGroupDialog(FolderModel folderModel, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          final model = TaskWidgetModelProvider.read(context)?.model;
          return Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                model?.deleteGroup(folderModel);
              }
              return KeyEventResult.ignored;
            },
            child: AlertDialog(
              title: Text('DELETE "${folderModel.title ?? ''}" ?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => model?.deleteGroup(folderModel),
                    child: const Text('OK')),
              ],
            ),
          );
        });
  }
}

class CustomPopupMenuItem extends PopupMenuItem<String> {
  CustomPopupMenuItem({
    Key? key,
    required String value,
    IconData? iconData,
    Color? textColor,
    Color? iconColor,
  }) : super(
            key: key,
            child: Row(
              children: [
                if (iconData != null)
                  Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(iconData, size: 18, color: iconColor)),
                Text(value, style: TextStyle(color: textColor))
              ],
            ),
            value: value,
            height: 38);
}
