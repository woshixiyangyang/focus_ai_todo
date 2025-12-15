import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../services/ai_client.dart';
import '../state/app_state.dart';
import '../widgets/video_background.dart';

/// 开始策略：今天想怎么开始？
enum StartStrategy {
  hardFirst, // 挑战自我：难到易
  easyFirst, // 胸有成竹：易到难
  balanced, // 劳逸结合：难易掺杂
}

class AiPlanPage extends StatefulWidget {
  const AiPlanPage({super.key});

  @override
  State<AiPlanPage> createState() => _AiPlanPageState();
}

class _AiPlanPageState extends State<AiPlanPage> {
  final _textController = TextEditingController();

  StartStrategy _strategy = StartStrategy.hardFirst;

  // 生成后的排序结果
  List<Task> _planned = [];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// AI分析并导入任务
  Future<void> _analyzeAndImport() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先输入要分析的文本')));
      return;
    }

    // 显示loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI 正在分析任务中...'),
          ],
        ),
      ),
    );

    try {
      // 调用AI分析
      final lines = await AiClient.splitParagraphToTasks(text);

      // 关闭loading
      if (mounted) Navigator.of(context).pop();

      if (lines.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('⚠️ 没有识别出任何任务')));
        }
        return;
      }

      // 导入任务到AppState
      final appState = context.read<AppState>();
      for (final line in lines) {
        final task = Task(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              line.hashCode.toString(),
          title: line,
          mustDo: true,
          difficulty: TaskDifficulty.normal,
          done: false,
          note: null,
        );
        appState.addTask(task);
      }

      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 成功导入 ${lines.length} 个任务'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // 清空输入框
        _textController.clear();
      }
    } catch (e) {
      // 关闭loading
      if (mounted) Navigator.of(context).pop();

      // 显示错误
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ AI调用失败'),
            content: Text('$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// 点击按钮时生成计划（使用真实AI分析）
  Future<void> _generatePlan() async {
    final appState = context.read<AppState>();
    // 所有未完成任务：需要完成 + 仅提醒
    final allTodo = [...appState.mustDoTasks, ...appState.remindOnlyTasks];

    if (allTodo.isEmpty) {
      setState(() {
        _planned = [];
      });
      return;
    }

    // 显示loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI 正在分析任务难度和优先级...'),
          ],
        ),
      ),
    );

    try {
      // 提取任务标题列表
      final taskTitles = allTodo.map((t) => t.title).toList();

      // 调用真实AI分析
      String strategyKey;
      switch (_strategy) {
        case StartStrategy.hardFirst:
          strategyKey = 'hardFirst';
          break;
        case StartStrategy.easyFirst:
          strategyKey = 'easyFirst';
          break;
        case StartStrategy.balanced:
          strategyKey = 'balanced';
          break;
      }

      final aiResult = await AiClient.analyzeTaskPriority(
        tasks: taskTitles,
        strategy: strategyKey,
      );

      // 关闭loading
      if (mounted) Navigator.of(context).pop();

      // 根据AI返回的结果重新排序任务
      final sortedTasks = <Task>[];
      for (final aiTask in aiResult) {
        final matchedTask = allTodo.firstWhere(
          (t) => t.title == aiTask['title'],
          orElse: () => allTodo.first,
        );

        // 根据AI判断的难度更新任务
        TaskDifficulty newDifficulty;
        switch (aiTask['difficulty']) {
          case 'easy':
            newDifficulty = TaskDifficulty.easy;
            break;
          case 'hard':
            newDifficulty = TaskDifficulty.hard;
            break;
          default:
            newDifficulty = TaskDifficulty.normal;
        }

        // 创建新任务对象（更新难度）
        final updatedTask = Task(
          id: matchedTask.id,
          title: matchedTask.title,
          note: matchedTask.note,
          deadline: matchedTask.deadline,
          mustDo: matchedTask.mustDo,
          difficulty: newDifficulty,
          done: matchedTask.done,
        );

        sortedTasks.add(updatedTask);
      }

      setState(() {
        _planned = sortedTasks;
      });

      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ AI 已完成分析，推荐 ${sortedTasks.length} 个任务的执行顺序'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 关闭loading
      if (mounted) Navigator.of(context).pop();

      // 显示错误
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ AI分析失败'),
            content: Text('$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    }
  }

  String _difficultyLabel(TaskDifficulty d) {
    switch (d) {
      case TaskDifficulty.hard:
        return '有挑战性的任务';
      case TaskDifficulty.normal:
        return '普通任务';
      case TaskDifficulty.easy:
        return '胸有成竹的任务';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final totalTodo =
        appState.mustDoTasks.length + appState.remindOnlyTasks.length;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI 助手'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: VideoBackground(
        assetPath: 'assets/video/bg.mp4',
        overlayOpacity: 0.35,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ======== 新增：AI分析并导入 ========
              Card(
                color: Colors.white.withOpacity(0.85),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 AI 分析并导入任务',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '粘贴一大段话，AI会帮你拆分成多个任务',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: '例如：给小猫加水，给小狗加粮，路过花店买花，花要插在粉色花瓶里',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.80),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _analyzeAndImport,
                          icon: const Icon(Icons.psychology),
                          label: const Text('分析并导入'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(color: Colors.white70),
              const SizedBox(height: 24),

              // ======== 原有：任务排序功能 ========
              Card(
                color: Colors.white.withOpacity(0.80),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 本地任务排序',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '现在共有 $totalTodo 个未完成任务，'
                        '告诉我你想怎么开始，我来帮你排个顺序。',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      // 今天想怎么开始？
                      Text('今天想怎么开始？', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),

                      _buildStrategyOption(
                        context,
                        value: StartStrategy.hardFirst,
                        title: '挑战自我（难到易）',
                        subtitle: '先啃硬骨头，后面会轻松很多',
                      ),
                      const SizedBox(height: 8),
                      _buildStrategyOption(
                        context,
                        value: StartStrategy.easyFirst,
                        title: '胸有成竹（易到难）',
                        subtitle: '先暖身，建立一点自信再挑战难题',
                      ),
                      const SizedBox(height: 8),
                      _buildStrategyOption(
                        context,
                        value: StartStrategy.balanced,
                        title: '劳逸结合（难易掺杂）',
                        subtitle: '难题和简单任务交替进行，不容易累',
                      ),

                      const SizedBox(height: 24),

                      // 生成计划按钮（放在较下方）
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: totalTodo == 0 ? null : _generatePlan,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('生成今天的学习计划'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (_planned.isNotEmpty) ...[
                        _buildPlanList(context),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 左边：重新排序
                            OutlinedButton(
                              onPressed: totalTodo == 0 ? null : _generatePlan,
                              child: const Text('重新排序'),
                            ),
                            // 右边：接受排序
                            TextButton(
                              onPressed: () {
                                final appState = context.read<AppState>();

                                // 把 AI 排好的列表拆成两组
                                final mustOrder = _planned
                                    .where((t) => t.mustDo)
                                    .toList();
                                final remindOrder = _planned
                                    .where((t) => !t.mustDo)
                                    .toList();

                                // 调用 AppState 里的方法，真正修改今日任务的顺序
                                appState.applyAiOrder(
                                  mustOrder: mustOrder,
                                  remindOrder: remindOrder,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('已将今日任务按推荐顺序排序'),
                                  ),
                                );
                              },
                              child: Text(
                                '接受排序',
                                style: TextStyle(color: primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建一个竖着排列的大选择框
  Widget _buildStrategyOption(
    BuildContext context, {
    required StartStrategy value,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final selected = _strategy == value;
    final primary = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _strategy = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? primary.withOpacity(0.12)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade300,
            width: 1.4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? primary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall!.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "今日推荐顺序"列表
  Widget _buildPlanList(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('今日推荐顺序', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._planned.map(_buildPlanTile),
      ],
    );
  }

  /// 用于展示每一条推荐任务
  Widget _buildPlanTile(Task t) {
    final difficulty = _difficultyLabel(t.difficulty);
    final items = <String>[difficulty];
    if (t.note != null && t.note!.isNotEmpty) {
      items.add(t.note!);
    }
    final subtitle = items.join(' · ');

    return Card(
      child: ListTile(
        leading: t.mustDo
            ? const Icon(Icons.star, color: Colors.orange)
            : const Icon(Icons.circle_outlined),
        title: Text(t.title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
