import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../api/tasks_api.dart';
import '../core/fcm.dart';
import '../main.dart';
import '../model/folder_model.dart';
import '../model/task_model.dart';
import '../presentation/color_scheme.dart';
import '../providers/theme_provider.dart';
import '../widgets/context_menu.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/dialog/adaptive_dialog.dart';
import '../widgets/dialog/members_dialog.dart';
import '../widgets/dialog/share_dialog.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/task_item_widget.dart';
import 'tasks_widget_model.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({required this.folder, Key? key}) : super(key: key);

  final FolderModel folder;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late TasksWidgetModel model;

  @override
  void initState() {
    model = TasksWidgetModel(widget.folder);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TasksWidgetModel>(
      create: (_) => model,
      child: TasksPageWidgetBody(folder: widget.folder),
    );
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }
}

class TasksPageWidgetBody extends StatefulWidget {
  const TasksPageWidgetBody({Key? key, required this.folder}) : super(key: key);

  final FolderModel folder;
  @override
  _TasksPageWidgetBodyState createState() => _TasksPageWidgetBodyState();
}

class _TasksPageWidgetBodyState extends State<TasksPageWidgetBody> {
  late TasksWidgetModel _model;
  late ColorTheme colorTheme;
  TasksSort sort = TasksSort.old_first;

  Future<void> scrollToBottom(ScrollController scrollController) async {
    await scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);

    while (scrollController.position.pixels !=
        scrollController.position.maxScrollExtent) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      await SchedulerBinding.instance.endOfFrame;
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Menu();
    _model = context.watch<TasksWidgetModel>();
    colorTheme = context.watch<ModelTheme>().colorTheme;
    return Scaffold(
      backgroundColor: colorTheme.mobileScaffoldColor,
      appBar: isDesktop
          ? null
          : CustomAppBar(
              title: _model.isEditingMode
                  ? ''
                  : _model.selectedFolderStr?.name ?? '',
              actions: [
                if (widget.folder.members.isNotEmpty) ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            showMembersDialog(context, widget.folder.members);
                          },
                          icon: const Icon(Icons.people)),
                      Container(
                        margin: const EdgeInsets.only(left: 26, bottom: 16),
                        alignment: Alignment.center,
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.blue,
                        ),
                        child: Text(
                          widget.folder.members.length.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                  if (_model.folder.createdBy == null)
                    IconButton(
                        onPressed: () {
                          showShareDialog(context, _model.selectedFolderStr!);
                        },
                        icon: const Icon(Icons.share)),
                ],
                if (_model.isEditingMode) ...[
                  IconButton(
                      onPressed: () {
                        _model.copyToClipboard(context, _model.selectedTasks);
                      },
                      icon: const Icon(Icons.copy_all)),
                  IconButton(
                      onPressed: _model.selectAllTasks,
                      icon: const Icon(Icons.done_all)),
                  IconButton(
                      onPressed: () {
                        _model.setEditingMode(false);
                      },
                      icon: const Icon(Icons.close)),
                ],
              ],
            ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop) _buildDesktopTitle(),
              if (_model.selectedFolderStr != null)
                Expanded(
                  child: ReorderableListView.builder(
                    // scrollController: scrollController,
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 80),
                    itemCount: _model.group?.length ?? 0,
                    itemBuilder: (ctx, index) {
                      final TaskModel item = _model.group![index];
                      return InkWell(
                        canRequestFocus: false,
                        key: ValueKey(item.createdOn),
                        onTap: _model.isEditingMode
                            ? () => _model.selectTask(item)
                            : null,
                        child: AbsorbPointer(
                          absorbing: _model.isEditingMode,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 0),
                            color: _model.selectedTasks.contains(item)
                                ? Colors.black.withOpacity(0.05)
                                : null,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextItemWidget(
                                    onLongPress: () => _model.selectTask(item),
                                    index: index,
                                    key: ValueKey(item.createdOn),
                                    model: item,
                                    onChanged: (newModel) {
                                      _model.onChangeGroupModel(
                                          newModel, index);
                                    },
                                    onTapDelete: () =>
                                        _model.deleteTasks([item]),
                                  ),
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
          if (_model.group == null)
            Center(
              child: ProgressIndicatorWidget(
                  size: 30, color: colorTheme.primaryColor),
            ),
        ],
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
                    final newModel = await showGroupEditor(TaskModel.empty(0));
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
            _model.selectedFolderStr?.name ?? 'TODO TASK',
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
                CustomPopupMenuItem(value: 'Copy all'),
                if (_model.group != null && widget.folder.members.isNotEmpty)
                  CustomPopupMenuItem(value: 'Members'),
                if (_model.group != null && widget.folder.members.isNotEmpty)
                  CustomPopupMenuItem(value: 'Share'),
              ];
            },
            onSelected: (value) {
              if (value == 'Copy all') {
                if (_model.group != null) {
                  _model.copyToClipboard(context, _model.group!);
                }
              } else if (value == 'Members') {
                showMembersDialog(context, widget.folder.members);
              } else if (value == 'Share') {
                showShareDialog(context, _model.selectedFolderStr!);
              }
            },
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              if (sort == TasksSort.old_first) {
                sort = TasksSort.new_first;
              } else {
                sort = TasksSort.old_first;
              }
              _model.changeSort(sort);
              setState(() {});
            },
            icon: Icon(sort == TasksSort.old_first
                ? CupertinoIcons.sort_up
                : CupertinoIcons.sort_down),
          ),
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
    );
  }
}

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  static const _menuTitles = [
    'Declarative style',
    'Premade widgets',
    'Stateful hot reload',
    'Native performance',
    'Great community',
  ];

  static const _initialDelayTime = Duration(milliseconds: 50);
  static const _itemSlideTime = Duration(milliseconds: 250);
  static const _staggerTime = Duration(milliseconds: 50);
  static const _buttonDelayTime = Duration(milliseconds: 150);
  static const _buttonTime = Duration(milliseconds: 500);
  final _animationDuration = _initialDelayTime +
      (_staggerTime * _menuTitles.length) +
      _buttonDelayTime +
      _buttonTime;

  late AnimationController _staggeredController;
  final List<Interval> _itemSlideIntervals = [];
  late Interval _buttonInterval;

  @override
  void initState() {
    super.initState();

    _createAnimationIntervals();

    _staggeredController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();
  }

  void _createAnimationIntervals() {
    for (var i = 0; i < _menuTitles.length; ++i) {
      final startTime = _initialDelayTime + (_staggerTime * i);
      final endTime = startTime + _itemSlideTime;
      _itemSlideIntervals.add(
        Interval(
          startTime.inMilliseconds / _animationDuration.inMilliseconds,
          endTime.inMilliseconds / _animationDuration.inMilliseconds,
        ),
      );
    }

    final buttonStartTime =
        Duration(milliseconds: (_menuTitles.length * 50)) + _buttonDelayTime;
    final buttonEndTime = buttonStartTime + _buttonTime;
    _buttonInterval = Interval(
      buttonStartTime.inMilliseconds / _animationDuration.inMilliseconds,
      buttonEndTime.inMilliseconds / _animationDuration.inMilliseconds,
    );
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ..._buildListItems(),
      ],
    );
  }

  List<Widget> _buildListItems() {
    final listItems = <Widget>[];
    for (var i = 0; i < _menuTitles.length; ++i) {
      listItems.add(
        AnimatedBuilder(
          animation: _staggeredController,
          builder: (context, child) {
            final animationPercent = Curves.easeOut.transform(
              _itemSlideIntervals[i].transform(_staggeredController.value),
            );
            final opacity = animationPercent;
            final slideDistance = (1.0 - animationPercent) * 150;

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(slideDistance, 0),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            child: Text(
              _menuTitles[i],
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }
    return listItems;
  }
}
