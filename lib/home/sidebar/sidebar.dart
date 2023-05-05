import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/home/sidebar/sidebar_widget_model.dart';
import 'package:todo_task/widgets/context_menu.dart';
import 'package:todo_task/home/home_page.dart';
import 'package:todo_task/main.dart';
import 'package:todo_task/presentation/themes.dart';

import 'package:todo_task/widgets/expandable_section.dart';

import '../../api/auth_api.dart';
import '../../providers/theme_provider.dart';
import '../../router/router_generator.dart';
import '../../services/context_provider.dart';
import '../../dao/auth_dao.dart';
import '../../tasks_page/tasks_widget_model.dart';
import '../../widgets/dialog/adaptive_dialog.dart';
import '../../model/folder_model.dart';
import '../../model/user_model.dart';

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
    userModel = UserModel.fromUser(FirebaseAuth.instance.currentUser!);
    /*  authDao = GetIt.I<AuthDao>();
    initUser(); */
    super.initState();
  }

/*   Future<void> initUser() async {
    userModel = UserModel.fromUser(FirebaseAuth.instance.currentUser!);

    final user = await authDao.getLoggedUser();
    if (user != null) {
      userModel = user;
      setState(() {});
    }
  } */

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SidebarWidgetModel>();
    final isSmall = isDesktop && MediaQuery.of(context).size.width < 500;
    final themeNotifier = context.watch<ModelTheme>();
    final tasksModel = context.read<TasksWidgetModel>();
    print('##### ${model.selectedFolderStr ?? '1'}');
    return Drawer(
        backgroundColor: themeNotifier.colorTheme.sidebarBackgroundColor,
        width: isDesktop
            ? isSmall
                ? 65
                : 200
            : 300,
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
                                height: 53,
                                width: 53,
                                color: Colors.grey,
                                child: Image.network(
                                  userModel!.imageUrl,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                          Icons.image_not_supported_rounded),
                                ),
                              ),
                            ),
                            if (isDesktop && !isSmall)
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
                                  StreamBuilder<CustomNavRoute<dynamic>?>(
                                      stream: NavRepository.instance.nextPage(),
                                      builder: (context, snapshot) {
                                        return InkWell(
                                            onTap: snapshot.data != null
                                                ? () {
                                                    Navigator.of(
                                                            nestedNavigatorKey
                                                                .currentContext!)
                                                        .pushNamed(snapshot
                                                            .data!
                                                            .settings
                                                            .name!);
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
                            style: TextStyle(
                                color:
                                    themeNotifier.colorTheme.sidebarIconColor),
                            // Theme.of(context).textTheme.bodyMedium!,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        //if (userModel != null)
                        //  Text(
                        //    'UID: ${userModel!.uid}',
                        //    //style: TextStyle(color: Colors.grey),
                        //  ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 4, horizontal: isDesktop ? 0 : 8),
                          child: InkWell(
                            onTap: () {
                              isExpand = !isExpand;
                              setState(() {});
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  isExpand
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.navigate_next_rounded,
                                  color:
                                      themeNotifier.colorTheme.sidebarIconColor,
                                  /*  size: CustomTheme.of(context)
                                      .sidebarIconThemeData!
                                      .size,*/
                                  /*    color: themeNotifier.colorTheme.
                                  CustomTheme.of(context)
                                      .sidebarIconThemeData!
                                      .color,  */
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    'Folders',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: themeNotifier
                                            .colorTheme.sidebarIconColor),
                                    //  Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: InkWell(
                                    onTap: () async {
                                      /*    model?.selectFolder('123');
                                      Navigator.of(nestedNavigatorKey
                                              .currentContext!)
                                          .pushNamed('tasks_page',
                                              arguments: '123');
                                      if (!isDesktop) {
                                        Navigator.pop(context);
                                      } */
                                      final title = await inputTextDialog();
                                      if (title != null && title.isNotEmpty) {
                                        model.addFolder(title);
                                        await Navigator.of(nestedNavigatorKey
                                                .currentContext!)
                                            .pushNamed('tasks_page',
                                                arguments:
                                                    FolderModel(title: title));
                                      }
                                    },
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: themeNotifier
                                          .colorTheme.sidebarIconColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        ExpandedSection(
                            expand: isExpand,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: isDesktop ? 12.0 : 20),
                              child: Column(
                                children: model.list
                                    .map((e) => GroupItemWidget(
                                          e,
                                          onTap: () {},
                                        ))
                                    .toList(),
                              ),
                            )),
                        const SizedBox(
                          height: 6,
                        ),
                        ItemWidget(
                          onTap: () {
                            model.selectFolder('');
                            Navigator.of(nestedNavigatorKey.currentContext!)
                                .pushNamed('birthdays');
                            if (!isDesktop) {
                              Navigator.pop(context);
                            }
                          },
                          isSmall: isSmall,
                          title: 'Birthdays',
                          icon: Icons.cake,
                        ),
                        ItemWidget(
                          onTap: () {
                            Navigator.of(nestedNavigatorKey.currentContext!)
                                .pushNamed('settings');
                            if (!isDesktop) {
                              Navigator.pop(context);
                            }
                          },
                          isSmall: isSmall,
                          title: 'Settings',
                          icon: Icons.settings,
                        ),

                        ItemWidget(
                          onTap: () async {
                            await model.logout();
                            tasksModel.close();
                          },
                          isSmall: isSmall,
                          title: 'Logout',
                          iconColor: themeNotifier.colorTheme.logoutColor,
                          icon: Icons.logout_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                //    const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: IconButton(
                      onPressed: themeNotifier.changeTheme,
                      icon: Icon(
                          themeNotifier.isDark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny,
                          color: themeNotifier.colorTheme.sidebarIconColor
                          //  CustomTheme.of(context).sidebarIconThemeData!.color,
                          )),
                ),
              ],
            ),
          ),
        ));
  }

/*   Future<void> signUp() async {
    if (userModel == null) {
      final user = await AuthApi().signUp();
      if (user != null) {
        userModel = user;
        setState(() {});
      }
    }
  } */
}

class ItemWidget extends StatelessWidget {
  const ItemWidget(
      {Key? key,
      required this.icon,
      required this.isSmall,
      required this.onTap,
      this.iconColor,
      required this.title})
      : super(key: key);

  final IconData icon;
  final String title;
  final Color? iconColor;
  final bool isSmall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.read<ModelTheme>().colorTheme;
    return Container(
      height: 35,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: isDesktop ? 0 : 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment:
              isSmall ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: iconColor ?? colorTheme.sidebarIconColor,
              /*   size: CustomTheme.of(context).sidebarIconThemeData!.size,
              color: CustomTheme.of(context).sidebarIconThemeData!.color, */
            ),
            if (isSmall == false)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorTheme.sidebarIconColor,
                  ),
                  // style: Theme.of(context).textTheme.bodySmall,
                ),
              )
          ],
        ),
      ),
    );
  }
}

class GroupItemWidget extends StatelessWidget {
  const GroupItemWidget(this.folderModel, {required this.onTap, Key? key})
      : super(key: key);
  final FolderModel folderModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final model = context.read<SidebarWidgetModel>();
    final colorTheme = context.watch<ModelTheme>().colorTheme;
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(right: isDesktop ? 15 : 20),
          width: 1,
          height: 34,
          color: Colors.grey,
        ),
        Expanded(
          child: GestureDetector(
            onLongPressStart: (det) {
              showButtonMenu(context, det.globalPosition, folderModel);
            },
            onSecondaryTapUp: (det) {
              showButtonMenu(context, det.globalPosition, folderModel);
            },
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                model.selectFolder(folderModel.title);
                Navigator.of(nestedNavigatorKey.currentContext!)
                    .pushNamedAndRemoveUntil(
                        'tasks_page', (route) => route.isFirst,
                        arguments: folderModel);
                if (!isDesktop) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                height: 30,
                padding: const EdgeInsets.only(left: 6),
                decoration: model.selectedFolderStr != folderModel.title
                    ? null
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colorTheme.primaryColor.withOpacity(0.05)),
                child: Opacity(
                  opacity: folderModel.ownerUid != null ? 0.5 : 1,
                  child: Text(
                    folderModel.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: model.selectedFolderStr == folderModel.title
                          ? colorTheme.primaryColor
                          : colorTheme.sidebarIconColor,
                    ),
                    /*   Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: model.selectedFolderStr != folderModel.title
                            ? null
                            : colorTheme.primaryColor), */
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showButtonMenu(
      BuildContext context, Offset globalPosition, FolderModel folderModel) {
    final model = context.read<SidebarWidgetModel>();
    showContextMenu(
        globalPosition: globalPosition,
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
              model.deleteFolder(folderModel);
              Navigator.of(nestedNavigatorKey.currentContext!)
                  .pushNamed('preview_page', arguments: folderModel.title);
            });
          } else if (value == 'share') {
            //
          } else if (value == 'rename') {
            final newTitle = await inputTextDialog(folderModel.title);
            if (newTitle != null) {
              await model.renameFolder(newTitle, folderModel);
            }
          }
        });
  }

  void showDeleteGroupDialog(
      String folderName, BuildContext context, VoidCallback onConfirmTap) {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return Focus(
            autofocus: true,
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                onConfirmTap();
                Navigator.pop(ctx);
              }

              return KeyEventResult.ignored;
            },
            child: AlertDialog(
              title: Text('DELETE "$folderName" ?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onConfirmTap();
                    },
                    child: const Text('OK')),
              ],
            ),
          );
        });
  }
}
