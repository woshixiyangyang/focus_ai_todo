// lib/pages/task_editor_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../state/app_state.dart';
import '../models/task.dart';

class TaskEditorPage extends StatefulWidget {
  const TaskEditorPage({super.key});

  @override
  State<TaskEditorPage> createState() => _TaskEditorPageState();
}

class _TaskEditorPageState extends State<TaskEditorPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  bool _mustDo = true;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final appState = context.read<AppState>();
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      mustDo: _mustDo,
      deadline: null,
    );
    appState.addTask(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建任务'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '任务标题'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: '备注（可选）'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('重任务'),
              subtitle: const Text('关闭时为轻任务'),
              value: _mustDo,
              onChanged: (v) {
                setState(() {
                  _mustDo = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
