// lib/models/task.dart

/// 任务难度：
/// - easy   = 胸有成竹的任务
/// - normal = 普通任务
/// - hard   = 有挑战性的任务
enum TaskDifficulty { easy, normal, hard }

class Task {
  final String id; // 唯一 ID
  final String title; // 标题
  final String? note; // 备注（可选）
  final DateTime? deadline; // 截止日期（可选）
  final bool mustDo; // 是否“需要打勾”的任务（而不是仅提醒）
  final TaskDifficulty difficulty; // 难度
  bool done; // 是否已完成

  Task({
    required this.id,
    required this.title,
    this.note,
    this.deadline,
    required this.mustDo,
    this.difficulty = TaskDifficulty.normal, // 默认普通难度
    this.done = false,
  });
}
