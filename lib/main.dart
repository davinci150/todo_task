import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const taskKey = 'taskKey';

class _MyHomePageState extends State<MyHomePage> {
  List<TaskModel> list = [];

  SharedPreferences? prefs;

  void _addTask() {
    setState(() {
      list.add(TaskModel(text: '', isDone: false));
    });
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      initTask();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TODO TASK'),
          
        ),
        body: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
          itemCount: list.length,
          itemBuilder: (ctx, index) {
            return TextItemWidget(
                index: index,
                key: ValueKey(list[index]),
                model: list[index],
                onTapEnter: () {
                  //_addTask();
                },
                onChanged: (value) {
                  final model = list[index];
                  list[index] = model.copyWith(isDone: () => value);
                  setState(() {});
                  saveTasks();
                },
                onTextChange: (text) {
                  final model = list[index];
                  list[index] = model.copyWith(text: text);
                  saveTasks();
                },
                onTapDelete: () {
                  list.removeAt(index);
                  setState(() {});
                  saveTasks();
                }
                //),
                );
          },
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
            });
            saveTasks();
          },
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => copyToCliboard(),
              tooltip: 'Copy to clipboard',
              child: const Icon(Icons.copy_all_outlined),
            ),
            const SizedBox(
              width: 20,
            ),
            FloatingActionButton(
              onPressed: _addTask,
              tooltip: 'Add new task',
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void initTask() {
    List<TaskModel> result = [];
    final jsonStr = prefs?.getString(taskKey);
    if ((jsonStr ?? '').isNotEmpty) {
      final map = jsonDecode(jsonStr!) as Map<String, dynamic>;
      map.forEach((key, value) {
        result.add(TaskModel.fromJson(value as Map<String, dynamic>));
      });
    }

    list = result;
    setState(() {});
  }

  void saveTasks() {
    Map<String, dynamic> saveMap = <String, dynamic>{};
    list.asMap().forEach((key, value) {
      saveMap[key.toString()] = value.toJson();
    });
    final result = jsonEncode(saveMap);

    prefs?.setString(taskKey, result);
  }

  void copyToCliboard() {
    String res = '';
    list
        .where((element) => element.isDone != null)
        .toList()
        .asMap()
        .forEach((key, value) {
      res = res +
          '${key + 1})' +
          (value.isDone! ? ' ✓ ' : ' ☐ ') +
          value.text! +
          '\n';
    });

    Clipboard.setData(ClipboardData(text: res));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All tasks copied to buffer'),
      duration: Duration(milliseconds: 500),
    ));
  }
}

class TextItemWidget extends StatelessWidget {
  const TextItemWidget(
      {Key? key,
      required this.model,
      required this.index,
      required this.onChanged,
      required this.onTapEnter,
      required this.onTextChange,
      required this.onTapDelete})
      : super(key: key);

  final int index;
  final TaskModel model;
  final void Function(bool?) onChanged;
  final void Function(String)? onTextChange;
  final VoidCallback onTapDelete;
  final VoidCallback onTapEnter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: const Icon(
            Icons.drag_handle,
            color: Colors.black38,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        CheckboxCustom(
          onChanged: onChanged,
          value: model.isDone,
        ),
        // Checkbox(
        //   value: model.isDone,
        //   onChanged: onChanged,
        //   //shape: CircleBorder(),
        // ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
            child: TextFormField(
          keyboardType: TextInputType.text,
          //autofocus: true,
          onEditingComplete: onTapEnter,
          onChanged: onTextChange,
          maxLines: null,
          initialValue: model.text,
          style: TextStyle(
            color: model.isDone != null ? Colors.black : Colors.grey,
          ),
          decoration: InputDecoration(
              suffixIcon: IconButton(
                  tooltip: 'Delete task',
                  onPressed: onTapDelete,
                  icon: Icon(
                    Icons.close,
                    color: Colors.red[300],
                  )),
              hintStyle: TextStyle(color: Colors.grey[500]),
              hintText: 'Enter text',
              border: InputBorder.none),
        )),
        //Text(model.text),
      ],
    );
  }
}

class TaskModel {
  TaskModel({
    required this.text,
    required this.isDone,
  });

  String? text;
  bool? isDone;

  TaskModel.fromJson(Map<String, dynamic> json) {
    text = json['Text'] as String;
    isDone = json['IsDone'] != null ? json['IsDone'] as bool : null;
  }

  TaskModel copyWith({String? text, bool? Function()? isDone}) {
    return TaskModel(
      text: text ?? this.text,
      isDone: isDone != null ? isDone() : this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Text'] = text;
    data['IsDone'] = isDone;

    return data;
  }

  @override
  String toString() => '{text: $text, isDone: $isDone}';
}

class CheckboxCustom extends StatefulWidget {
  const CheckboxCustom({Key? key, required this.value, required this.onChanged})
      : super(key: key);

  final bool? value;
  final void Function(bool?) onChanged;

  @override
  State<CheckboxCustom> createState() => _CheckboxCustomState();
}

class _CheckboxCustomState extends State<CheckboxCustom> {
  bool? curValue;
  late IconData icon;

  @override
  void initState() {
    curValue = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (curValue == true) {
      icon = Icons.check_box;
    } else if (curValue == false) {
      icon = Icons.check_box_outline_blank;
    } else {
      icon = Icons.visibility_off;
    }
    return InkWell(
      onLongPress: () {
        curValue = null;
        widget.onChanged(curValue);
        setState(() {});
      },
      onTap: () {
        if (curValue != null) {
          curValue = !curValue!;
        } else {
          curValue = false;
        }
        widget.onChanged(curValue);
        setState(() {});
      },
      child: Icon(icon,
          color:
              curValue != null ? Theme.of(context).primaryColor : Colors.grey),
    );
  }
}
