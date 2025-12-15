// lib/state/app_state.dart

import 'package:flutter/foundation.dart';
import '../models/task.dart';

class AppState extends ChangeNotifier {
  final List<Task> _tasks = [];

  /// 所有任务（只读）
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// 需要完成的任务（未完成）
  List<Task> get mustDoTasks =>
      _tasks.where((t) => t.mustDo && !t.done).toList();

  /// 仅提醒的任务（未完成）
  List<Task> get remindOnlyTasks =>
      _tasks.where((t) => !t.mustDo && !t.done).toList();

  /// 已完成的任务
  List<Task> get completedTasks => _tasks.where((t) => t.done).toList();

  /// 新增任务
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  /// 在未完成 / 已完成之间切换
  void toggleDone(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    _tasks[index].done = !_tasks[index].done;
    notifyListeners();
  }

  /// 删除任务（用于“已完成”里再点一下直接删除）
  void removeTask(Task task) {
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  /// 根据 AI 推荐结果，重新设置今日任务的顺序。
  ///
  /// - [mustOrder] 是「需要完成的任务」按 AI 推荐后的顺序
  /// - [remindOrder] 是「仅提醒的任务」按 AI 推荐后的顺序
  /// - 已完成的任务保持原来的顺序，排在最后
  void applyAiOrder({
    required List<Task> mustOrder,
    required List<Task> remindOrder,
  }) {
    // 1. 已经完成的任务，保持原顺序
    final completed = _tasks.where((t) => t.done).toList();

    // 2. 清空原列表，用新的顺序重新拼起来
    _tasks
      ..clear()
      ..addAll(mustOrder)
      ..addAll(remindOrder)
      ..addAll(completed);

    notifyListeners();
  }
}
