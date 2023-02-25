import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_task/context_menu.dart';
import 'package:todo_task/home_page.dart';
import 'package:todo_task/main.dart';
import 'package:todo_task/tasks_widget_model.dart';
import 'package:todo_task/widget/expandable_section.dart';

import 'api/auth_api.dart';
import 'context_provider.dart';
import 'dao/auth_dao.dart';
import 'dialog/input_text_dialog.dart';
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
  bool isExpand = true;
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
    final model = TaskWidgetModelProvider.watch(context)?.model;
    final isSmall = isDesktop && MediaQuery.of(context).size.width < 500;
    final themeNotifier = ThemeModelProvider.watch(context)
        ?.model; // Provider.of<ModelTheme>(context);
    return Drawer(
        width: isSmall ? 65 : 200,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 55,
                                width: 55,
                                color: Colors.grey,
                                child: userModel == null
                                    ? InkWell(
                                        onTap: signUp,
                                        child: const Icon(Icons.account_box))
                                    : Image.network(userModel!.imageUrl),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StreamBuilder<bool>(
                                    stream: NavRepository.instance.canPop(),
                                    builder: (context, snapshot) {
                                      return InkWell(
                                          onTap: snapshot.data == true
                                              ? () {
                                                  Navigator.of(
                                                          nestedNavigatorKey
                                                              .currentContext!)
                                                      .pop();
                                                }
                                              : null,
                                          child: Icon(
                                            Icons.chevron_left,
                                            color: snapshot.data == true
                                                ? null
                                                : Colors.grey,
                                          ));
                                    }),
                                const SizedBox(
                                  width: 10,
                                ),
                                StreamBuilder<CustomNavRoute?>(
                                    stream: NavRepository.instance.nextPage(),
                                    builder: (context, snapshot) {
                                      return InkWell(
                                          onTap: snapshot.data != null
                                              ? () {
                                                  Navigator.of(
                                                          nestedNavigatorKey
                                                              .currentContext!)
                                                      .pushNamed(snapshot.data!
                                                          .settings.name!);
                                                }
                                              : null,
                                          child: Icon(
                                            Icons.chevron_right,
                                            color: snapshot.data != null
                                                ? null
                                                : Colors.grey,
                                          ));
                                    }),
                              ],
                            )
                          ],
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              userModel!.email,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        //if (userModel != null)
                        //  Text(
                        //    'UID: ${userModel!.uid}',
                        //    //style: TextStyle(color: Colors.grey),
                        //  ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: const Color(0xFF272437),
                              borderRadius: BorderRadius.circular(16)),
                          child: Column(children: <Widget>[
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    isExpand = !isExpand;
                                    setState(() {});
                                  },
                                  child: Icon(
                                    isExpand
                                        ? Icons.keyboard_arrow_down
                                        : Icons.navigate_next_rounded,
                                    color: const Color(0xFF8D8D95),
                                  ),
                                ),
                                const Text(
                                  'Folders',
                                  style: TextStyle(color: Color(0xFF8D8D95)),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: InkWell(
                                    onTap: showAddGroupDialog,
                                    child: const Icon(
                                      Icons.add,
                                      size: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            if (model != null)
                              ExpandedSection(
                                  expand: isExpand,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Column(
                                      children: model.list
                                          .map((e) => GroupItemWidget(e))
                                          .toList(),
                                    ),
                                  ))

                            //...[addNewGroupDrawerButton(isSmall)]
                          ]),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        ItemWidget(
                          onTap: () {
                            Navigator.of(nestedNavigatorKey.currentContext!)
                                .pushNamed('birthdays');
                          },
                          isSmall: isSmall,
                          title: 'Birthdays',
                          icon: Icons.cake,
                        ),
                        ItemWidget(
                          onTap: () {
                            Navigator.of(nestedNavigatorKey.currentContext!)
                                .pushNamed('settings');
                          },
                          isSmall: isSmall,
                          title: 'Settings',
                          icon: Icons.settings,
                        ),
                      ],
                    ),
                  ),
                ),
                //    const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: IconButton(
                      onPressed: () {
                        themeNotifier!.changeTheme();
                      },
                      icon: Icon(themeNotifier!.isDark
                          ? Icons.nightlight_round
                          : Icons.wb_sunny)),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> signUp() async {
    final user = await AuthApi().signUp();
    if (user != null) {
      userModel = user;
      setState(() {});
    }
  }

  void addFolder(String title) {
    final model = TaskWidgetModelProvider.read(context)?.model;
    model?.addFolder(title);

    Navigator.pop(context);
    if (!isDesktop) {
      Navigator.pop(context);
    }
  }

  void showAddGroupDialog() {
    String title = '';
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Input title'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onEditingComplete: () => addFolder(title),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => addFolder(title), child: const Text('OK')),
            ],
          );
        });
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget(
      {Key? key,
      required this.icon,
      required this.isSmall,
      required this.onTap,
      required this.title})
      : super(key: key);

  final IconData icon;
  final String title;
  final bool isSmall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment:
              isSmall ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon),
            if (isSmall == false)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(title),
              )
          ],
        ),
      ),
    );
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
        showButtonMenu(context, det, folderModel);
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          model?.selectFolder(folderModel.title);
          if (!isDesktop) {
            Navigator.pop(context);
          }
        },
        child: Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          height: 30,
          padding: const EdgeInsets.only(left: 6),
          decoration: model?.selectedFolderStr != folderModel.title
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).backgroundColor),
          child: Text(
            folderModel.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void showButtonMenu(
      BuildContext context, TapUpDetails tapDetails, FolderModel folderModel) {
    final model = TaskWidgetModelProvider.watch(context)?.model;
    showContextMenu(
        tapDetails: tapDetails,
        items: [
          CustomPopupMenuItem(value: 'share', iconData: Icons.share),
          CustomPopupMenuItem(value: 'rename', iconData: Icons.edit),
          CustomPopupMenuItem(
              value: 'delete',
              iconData: Icons.delete,
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent),
        ],
        onSelected: (String? value) async {
          if (value == 'delete') {
            showDeleteGroupDialog(folderModel.title, context, () {
              model?.deleteGroup(folderModel);
            });
          } else if (value == 'share') {
            //
          } else if (value == 'rename') {
            final newTitle = await inpuTextDialog(folderModel.title);
            if (newTitle != null) {
              model?.renameFolder(newTitle, folderModel.title);
            }
          }
        });
  }

  void showDeleteGroupDialog(
      String folderName, BuildContext context, VoidCallback onConfirmTap) {
    showDialog(
        context: context,
        builder: (ctx) {
          return Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                onConfirmTap();
                Navigator.pop(context);
              }

              return KeyEventResult.ignored;
            },
            child: AlertDialog(
              title: Text('DELETE "$folderName" ?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirmTap();
                    },
                    child: const Text('OK')),
              ],
            ),
          );
        });
  }
}
