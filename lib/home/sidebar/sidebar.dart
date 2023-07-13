import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';

import '../../api/auth_api.dart';
import '../../main.dart';
import '../../model/folder_model.dart';
import '../../model/user_model.dart';
import '../../presentation/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../router/router_generator.dart';
import '../../services/context_provider.dart';
import '../../tasks_page/tasks_widget_model.dart';
import '../../widgets/context_menu.dart';
import '../../widgets/dialog/adaptive_dialog.dart';
import '../../widgets/dialog/share_dialog.dart';
import '../../widgets/expandable_section.dart';
import '../home_page.dart';
import 'sidebar_widget_model.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  UserModel? userModel;
  bool isExpand = true;
  late String myId;
  @override
  void initState() {
    myId = GetIt.I<AuthApi>().getUid!;
    userModel = Platform.isMacOS
        ? const UserModel(
            name: 'Stanislav',
            email: 'mijndert.veugelers@example.com',
            uid: 'uid',
            imageUrl: '')
        : UserModel.fromUser(FirebaseAuth.instance.currentUser!);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SidebarWidgetModel>();
    final isSmall = isDesktop && MediaQuery.of(context).size.width < 500;
    final themeNotifier = context.watch<ModelTheme>();
    // final tasksModel = context.read<TasksWidgetModel>();
    // print('##### ${model.selectedFolderStr ?? '1'}');
    final sharedFolders =
        model.list.where((element) => element.createdBy != myId);
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
                        /*  const SizedBox(
                          height: 20,
                        ), */
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(top: isDesktop ? 30 : 20),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      // color: Colors.grey,
                                      borderRadius: BorderRadius.circular(100)),
                                  height: 50,
                                  width: 50,
                                  child: Image.network(
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT09TXtR2mVJH3UEs0Hzd9IyQJeMV3jTPbo_g&usqp=CAU', //   userModel!.imageUrl,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.image_not_supported_rounded,
                                      color: themeNotifier
                                          .colorTheme.sidebarIconColor,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            if (isDesktop && !isSmall)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
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
                                                CupertinoIcons.chevron_left,
                                                size: 14,
                                                color: snapshot.data == true
                                                    ? null
                                                    : Colors.grey,
                                              ));
                                        }),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    StreamBuilder<CustomNavRoute<dynamic>?>(
                                        stream:
                                            NavRepository.instance.nextPage(),
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
                                                CupertinoIcons.chevron_right,
                                                size: 14,
                                                color: snapshot.data != null
                                                    ? null
                                                    : Colors.grey,
                                              ));
                                        }),
                                  ],
                                ),
                              )
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        if (userModel != null)
                          Text(
                            userModel!.name.isEmpty ? 'NONE' : userModel!.name,
                            maxLines: 1,
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
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
                        if (userModel != null)
                          Text(
                            'UID: ${userModel!.uid}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 4, horizontal: isDesktop ? 0 : 8),
                          child: InkWell(
                            onTap: () {
                              isExpand = !isExpand;
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 24,
                                  height: 24,
                                  child: Icon(
                                    isExpand
                                        ? CupertinoIcons.chevron_down
                                        : CupertinoIcons.chevron_right,
                                    size: 12,
                                    color: themeNotifier
                                        .colorTheme.sidebarIconColor,
                                    /*  size: CustomTheme.of(context)
                                        .sidebarIconThemeData!
                                        .size,*/
                                    /*    color: themeNotifier.colorTheme.
                                    CustomTheme.of(context)
                                        .sidebarIconThemeData!
                                        .color,  */
                                  ),
                                ),
                                if (!isSmall)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        /*   Icon(
                                        CupertinoIcons.folder,
                                        size: 16,
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ), */
                                        Text(
                                          'Folders',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: themeNotifier
                                                  .colorTheme.sidebarIconColor),
                                          //  Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
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
                                        final newFolder =
                                            await model.addFolder(title);
                                        await Navigator.of(nestedNavigatorKey
                                                .currentContext!)
                                            .pushNamed('tasks_page',
                                                arguments: newFolder);
                                      }
                                    },
                                    child: Icon(
                                      CupertinoIcons.folder_badge_plus,
                                      //  Icons.add,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: model.list
                                        .where((element) =>
                                            element.createdBy == myId)
                                        .map((e) => GroupItemWidget(
                                              e,
                                              onTap: () {},
                                              myId: myId,
                                              isSmall: isSmall,
                                            ))
                                        .toList(),
                                  ),
                                  if (sharedFolders.isNotEmpty)
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              right: isDesktop ? 19 : 24),
                                          width: 1,
                                          height: 34,
                                          color: Colors.grey,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            top: 10,
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            'Shared by me:',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.bermudaGray),
                                            //  Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  Column(
                                    children: sharedFolders
                                        .map((e) => GroupItemWidget(
                                              e,
                                              onTap: () {},
                                              myId: myId,
                                              isSmall: isSmall,
                                            ))
                                        .toList(),
                                  ),
                                ],
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
                          icon: CupertinoIcons.gift,
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
                          title: 'Notifications',
                          icon: CupertinoIcons.bell,
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
                          icon: CupertinoIcons.gear_alt,
                        ),
                        ItemWidget(
                          onTap: () async {
                            await model.logout();
                            //tasksModel.close();
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
  const GroupItemWidget(this.folderModel,
      {required this.onTap,
      Key? key,
      required this.isSmall,
      required this.myId})
      : super(key: key);
  final FolderModel folderModel;
  final VoidCallback onTap;
  final bool isSmall;
  final String myId;

  @override
  Widget build(BuildContext context) {
    final model = context.read<SidebarWidgetModel>();
    final colorTheme = context.watch<ModelTheme>().colorTheme;
    final child = Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      height: 30,
      padding: const EdgeInsets.only(left: 6),
      decoration: model.selectedFolderStr != folderModel.name
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: colorTheme.primaryColor.withOpacity(0.05)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.folder,
            size: 14,
            color: model.selectedFolderStr == folderModel.name
                ? colorTheme.primaryColor
                : colorTheme.sidebarIconColor,
          ),
          if (!isSmall)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                folderModel.name,
                style: TextStyle(
                  fontSize: 14,
                  color: model.selectedFolderStr == folderModel.name
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
        ],
      ),
    );
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
              showButtonMenu(context, det.globalPosition, folderModel, myId);
            },
            onSecondaryTapUp: (det) {
              showButtonMenu(context, det.globalPosition, folderModel, myId);
            },
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                model.selectFolder(folderModel.name);
                Navigator.of(nestedNavigatorKey.currentContext!)
                    .pushNamedAndRemoveUntil(
                        'tasks_page', (route) => route.isFirst,
                        arguments: folderModel);
                if (!isDesktop) {
                  Navigator.pop(context);
                }
              },
              child: isSmall
                  ? JustTheTooltip(
                      backgroundColor: AppColors.jumbo,
                      tailLength: 0, shadow: const BoxShadow(), elevation: 1,
                      preferredDirection: AxisDirection.right,
                      //margin: const EdgeInsets.only(left: 50),
                      content: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            folderModel.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          )),
                      child: SizedBox(width: 40, child: child),
                    )
                  : child,
            ),
          ),
        ),
      ],
    );
  }

  void showButtonMenu(BuildContext context, Offset globalPosition,
      FolderModel folderModel, String myId) {
    final model = context.read<SidebarWidgetModel>();
    showContextMenu(
        globalPosition: globalPosition,
        items: [
          if (folderModel.createdBy == myId) ...[
            CustomPopupMenuItem(
              value: 'share',
              iconData: Icons.share,
            ),
            CustomPopupMenuItem(
              value: 'rename',
              iconData: Icons.edit,
            ),
            CustomPopupMenuItem(
                value: 'delete',
                iconData: Icons.delete,
                iconColor: Colors.redAccent,
                textColor: Colors.redAccent)
          ] else
            CustomPopupMenuItem(
                value: 'delete for me',
                iconData: Icons.delete,
                iconColor: Colors.redAccent,
                textColor: Colors.redAccent)
        ],
        onSelected: (String? value) async {
          if (value == 'delete') {
            showDeleteGroupDialog(folderModel.name, context, () {
              model.deleteFolder(folderModel);
              Navigator.of(nestedNavigatorKey.currentContext!)
                  .pushNamed('preview_page', arguments: folderModel.name);
            });
          } else if (value == 'share') {
            await showShareDialog(context, folderModel);
          } else if (value == 'rename') {
            final newTitle = await inputTextDialog(folderModel.name);
            if (newTitle != null) {
              await model.renameFolder(newTitle, folderModel);
            }
          } else if (value == 'delete for me') {
            showDeleteGroupDialog(folderModel.name, context, () {
              model.removeFolderForMe(folderModel);
              Navigator.of(nestedNavigatorKey.currentContext!)
                  .pushNamed('preview_page', arguments: folderModel.name);
            });
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
