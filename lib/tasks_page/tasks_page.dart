import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/widgets/context_menu.dart';

import '../api/tasks_api.dart';
import '../core/fcm.dart';
import '../home/home_page.dart';
import '../main.dart';
import '../model/folder_model.dart';
import '../model/group_model.dart';
import '../presentation/color_scheme.dart';
import '../providers/theme_provider.dart';
import '../widgets/dialog/adaptive_dialog.dart';
import '../widgets/task_item_widget.dart';
import 'tasks_widget_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorTheme = context.watch<ModelTheme>().colorTheme;
    return AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: colorTheme.sidebarIconColor),
        actionsIconTheme: IconThemeData(color: colorTheme.sidebarIconColor),
        backgroundColor: colorTheme.appBarColor,
        centerTitle: true,
        actions: actions,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            drawerKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            color: colorTheme.sidebarIconColor,
          ),
        ));
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({required this.folder, Key? key}) : super(key: key);

  final FolderModel folder;

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late TasksWidgetModel _model;
  late ColorTheme colorTheme;

  @override
  void initState() {
    super.initState();
    context.read<TasksWidgetModel>().setup(widget.folder);
  }

  Future<void> showShareDialog(FolderModel folder) {
    String email = '';
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text(
                'Чтобы поделиться списком введите email пользователя'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                onChanged: (text) {
                  email = text;
                },
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () async {
                        final isSend =
                            await GetIt.I<TasksApi>().share(email, folder);
                        await showAlert(
                            title: isSend
                                ? 'Приглашение отправлено'
                                : 'Нет такого пользователя');
                        /*  if (isSend) {
                          Navigator.pop(context);
                        } */
                      },
                      child: const Text('Share')),
                ],
              ),
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _model = context.watch<TasksWidgetModel>();
    colorTheme = context.watch<ModelTheme>().colorTheme;
    return Scaffold(
      backgroundColor: isDesktop
          ? colorTheme.scaffoldDesktopColor
          : colorTheme.mobileScaffoldColor,
      appBar: isDesktop
          ? null
          : CustomAppBar(
              title: _model.isEditingMode
                  ? ''
                  : _model.selectedFolderStr?.title ?? '',
              actions: [
                if (_model.group != null && _model.group!.members.isNotEmpty)
                  InkWell(
                    onTap: () {
                      showDialog<void>(
                          context: context,
                          builder: (ctx) {
                            final usersUid = _model.group!.members
                                .map((e) => e.uid!)
                                .toList();
                            return AlertDialog(
                              content: FutureBuilder<List<String?>>(
                                  future: GetIt.I<TasksApi>()
                                      .getUsersByIds(usersUid),
                                  builder: (context, snapshot) {
                                    if (snapshot.data == null) {
                                      return const SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()));
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: snapshot.data!
                                          .map((e) => Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.person_outline),
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Text(
                                                    e ?? 'unknown',
                                                    style: TextStyle(
                                                        color: e == null
                                                            ? Colors.grey
                                                            : null),
                                                  ),
                                                ],
                                              ))
                                          .toList(),
                                    );
                                  }),
                            );
                          });
                    },
                    child: Center(
                      child: Stack(
                        alignment: const Alignment(2, -2),
                        children: [
                          const Icon(Icons.people),
                          Container(
                            alignment: Alignment.center,
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.blue,
                            ),
                            child: Text(
                              _model.group!.members.length.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_model.group != null && _model.group!.members.isNotEmpty)
                  IconButton(
                      onPressed: () {
                        showShareDialog(_model.selectedFolderStr!);
                      },
                      icon: const Icon(Icons.share)),
                if (_model.isEditingMode)
                  IconButton(
                      onPressed: () {
                        _model.copyToClipboard(context, _model.selectedTasks);
                      },
                      icon: const Icon(Icons.copy_all)),
                if (_model.isEditingMode)
                  IconButton(
                      onPressed: _model.selectAllTasks,
                      icon: const Icon(Icons.done_all)),
                if (_model.isEditingMode)
                  IconButton(
                      onPressed: () {
                        _model.setEditingMode(false);
                      },
                      icon: const Icon(Icons.close)),
              ],
            ),
      body: Container(
        margin: isDesktop ? const EdgeInsets.all(8) : null,
        decoration: BoxDecoration(
          borderRadius: isDesktop ? BorderRadius.circular(8) : null,
          color: isDesktop ? colorTheme.mobileScaffoldColor : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) _buildDesktopTitle(),
            if (_model.selectedFolderStr != null)
              Expanded(
                child: ReorderableListView.builder(
                  // scrollController: scrollController,
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 80),
                  itemCount: _model.group?.groups.length ?? 0,
                  itemBuilder: (ctx, index) {
                    final GroupModel item = _model.group!.groups[index];
                    return InkWell(
                      key: ValueKey(item.createdOn),
                      onTap: () {
                        _model.selectTask(item);
                      },
                      child: AbsorbPointer(
                        absorbing: _model.isEditingMode,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: _model.selectedTasks.contains(item)
                              ? Colors.black.withOpacity(0.05)
                              : null,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextItemWidget(
                                    isExpand: _model.isEditingMode,
                                    onLongPress: () {
                                      _model.selectTask(item);
                                      //  _model!.setEditingMode(true);
                                    },
                                    index: index,
                                    key: ValueKey(item.createdOn),
                                    model: item,
                                    onChanged: (newModel) {
                                      _model.onChangeGroupModel(
                                          newModel, index);
                                    },
                                    onTapDelete: () {
                                      _model.deleteTasks([item]);
                                    }),
                              ),
                              if (_model.selectedTasks.contains(item))
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    _model.onReorder(oldIndex, newIndex);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FloatingActionButton(
              backgroundColor: Colors.grey,
              onPressed: () async {
                String text = '';
                await showDialog<void>(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        content: TextField(
                          onChanged: (value) {
                            text = value;
                          },
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                sendMessage('f', text);

                                Navigator.pop(ctx);
                              },
                              child: const Text('ОТПРАВИТЬ УВЕДОМЛЕНИЕ'))
                        ],
                      );
                    });
              },
              tooltip: 'Add new task',
              child: const Icon(Icons.notification_add),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_model.isEditingMode == false)
                FloatingActionButton(
                  backgroundColor: colorTheme.primaryColor,
                  onPressed: () async {
                    final newModel = await showGroupEditor(GroupModel.empty(0));
                    //   final text = await inputTextDialog2();
                    if (newModel != null) {
                      _model.addTask(newModel);
                    }
                  },
                  tooltip: 'Add new task',
                  child: const Icon(Icons.add),
                )
              else
                FloatingActionButton(
                  backgroundColor: Colors.red[800],
                  onPressed: () async {
                    _model.deleteTasks(_model.selectedTasks);
                    _model.setEditingMode(false);
                  },
                  tooltip: 'Remove selected tasks',
                  child: const Icon(Icons.delete),
                ),
            ],
          ),
        ],
      ),
      /*    Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _model?.copyToCliboard(context),
            tooltip: 'Copy to clipboard',
            child: const Icon(Icons.copy_all_outlined),
          ),
          const SizedBox(
            width: 20,
          ),
          FloatingActionButton(
            onPressed: () async {
              final text = await inputTextDialog2();
              if (text != null) {
                _model?.addTask(text);
              }
            },
            tooltip: 'Add new task',
            child: const Icon(Icons.add),
          ),
        ],
      ), */
    );
  }

  Widget _buildDesktopTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
      child: Row(
        children: [
          Text(
            _model.selectedFolderStr?.title ?? 'TODO TASK',
            style: TextStyle(color: colorTheme.primaryTextColor, fontSize: 32),
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_horiz,
              color: colorTheme.sidebarIconColor,
            ),
            offset: const Offset(0, 40),
            itemBuilder: (ctx) {
              return [
                CustomPopupMenuItem(value: 'Copy'),
              ];
            },
            onSelected: (value) {
              if (value == 'Copy') {
                if (_model.group != null) {
                  _model.copyToClipboard(context, _model.group!.groups);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
