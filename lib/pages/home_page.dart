import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/video_background.dart';

import '../models/task.dart';
import '../services/ai_client.dart';
import '../state/app_state.dart';
import '../widgets/splash_burst.dart';
import 'ai_plan_page.dart';
import 'task_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _stackKey = GlobalKey();
  final List<_BurstEntry> _bursts = [];
  int _burstIdCounter = 0;

  void _spawnBurst(Offset globalPosition) {
    final ctx = _stackKey.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject();
    if (box is! RenderBox) return;

    final local = box.globalToLocal(globalPosition);

    final id = _burstIdCounter++;
    setState(() {
      _bursts.add(_BurstEntry(id: id, position: local));
    });
  }

  void _removeBurst(int id) {
    if (!mounted) return;
    setState(() {
      _bursts.removeWhere((b) => b.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return VideoBackground(
      assetPath: 'assets/video/bg.mp4',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('今日任务'),
          actions: [
            // 右上角 AI 图标
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'AI 推荐计划',
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AiPlanPage()));
              },
            ),
          ],
        ),
        body: Stack(
          key: _stackKey,
          fit: StackFit.expand,
          children: [
            Consumer<AppState>(
              builder: (context, appState, child) {
                final mustDo = appState.mustDoTasks;
                final remindOnly = appState.remindOnlyTasks;
                final completed = appState.completedTasks;

                if (mustDo.isEmpty && remindOnly.isEmpty && completed.isEmpty) {
                  return const Center(child: Text('今天还没有任务'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 未完成的任务（重任务 + 轻任务）
                    ...mustDo.map(
                      (task) => _buildTaskItem(
                        context,
                        appState,
                        task,
                        isHeavy: true,
                      ),
                    ),
                    ...remindOnly.map(
                      (task) => _buildTaskItem(
                        context,
                        appState,
                        task,
                        isHeavy: false,
                      ),
                    ),

                    // 已完成任务区域
                    if (completed.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        '已完成 (${completed.length})',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ...completed.map(
                        (task) => _buildCompletedItem(context, appState, task),
                      ),
                    ],
                  ],
                );
              },
            ),

            // 水花碎裂动画层
            IgnorePointer(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  for (final b in _bursts)
                    SplashBurst(
                      key: ValueKey('burst_${b.id}'),
                      position: b.position,
                      onComplete: () => _removeBurst(b.id),
                    ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 小的"快速填入"按钮
            FloatingActionButton.small(
              heroTag: 'quick_fill',
              onPressed: () {
                _showQuickFillDialog(context);
              },
              child: const Icon(Icons.text_fields),
            ),
            const SizedBox(height: 12),
            // 原来的 "+" 按钮（新增单个任务）
            FloatingActionButton(
              heroTag: 'add_task',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TaskEditorPage()),
                );
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  // 构建未完成任务项
  Widget _buildTaskItem(
    BuildContext context,
    AppState appState,
    Task task, {
    required bool isHeavy,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: ListTile(
        // 重任务显示勾选框，轻任务不显示
        leading: isHeavy
            ? Checkbox(
                value: task.done,
                onChanged: (_) {
                  appState.toggleDone(task);
                },
              )
            : null,
        title: Text(task.title),
        subtitle: task.note != null ? Text(task.note!) : null,
        // 不显示右边的trailing图标
        onTap: () {
          // 点击任务切换完成状态
          appState.toggleDone(task);
        },
      ),
    );
  }

  // 构建已完成任务项
  Widget _buildCompletedItem(
    BuildContext context,
    AppState appState,
    Task task,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        // 先放水花，再删任务（视觉更自然）
        _spawnBurst(details.globalPosition);

        appState.removeTask(task);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已删除任务'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        color: Colors.grey[100],
        child: ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(
            task.title,
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
          subtitle: task.note != null
              ? Text(task.note!, style: const TextStyle(color: Colors.grey))
              : null,
        ),
      ),
    );
  }
}

class _BurstEntry {
  final int id;
  final Offset position;

  const _BurstEntry({required this.id, required this.position});
}

// 右下角"快速填入"对话框
void _showQuickFillDialog(BuildContext context) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('快速填入任务'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入你今天要做的事情，AI会帮你拆分成多个任务',
            helperText: '例如：给小猫加水，给小狗加粮，路过花店买花，花要插在粉色花瓶里',
          ),
          maxLines: 5,
          autofocus: true,
        ),
        actions: [
          // 取消按钮
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('取消'),
          ),

          // 确定按钮：调用 AI + 生成任务
          TextButton(
            onPressed: () async {
              final rawText = controller.text.trim();

              // 空内容就直接关掉对话框
              if (rawText.isEmpty) {
                Navigator.of(dialogContext).pop();
                return;
              }

              // 先关闭输入对话框
              Navigator.of(dialogContext).pop();

              // 显示 loading 对话框
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) {
                  return const AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('AI 正在分析任务中...'),
                      ],
                    ),
                  );
                },
              );

              try {
                // 1. 调用 AI，拿到拆分后的任务标题列表
                final lines = await AiClient.splitParagraphToTasks(rawText);

                if (!context.mounted) return;

                // 关闭 loading 对话框
                Navigator.of(context).pop();

                // 2. 把每一行变成真正的 Task，加到 AppState 里
                if (lines.isNotEmpty) {
                  final appState = Provider.of<AppState>(
                    context,
                    listen: false,
                  );

                  for (final line in lines) {
                    if (line.isEmpty) continue;

                    final task = Task(
                      id:
                          DateTime.now().millisecondsSinceEpoch.toString() +
                          line.hashCode.toString(),
                      title: line,
                      mustDo: true, // 默认放到「需要完成的任务」
                      difficulty: TaskDifficulty.normal,
                      done: false,
                      note: null,
                    );

                    appState.addTask(task);
                  }

                  // 显示成功提示
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ AI 已成功添加 ${lines.length} 个任务'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  // 没有识别出任何任务
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ AI 没有识别出任何任务'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;

                // 关闭 loading 对话框
                Navigator.of(context).pop();

                // 显示错误提示
                showDialog(
                  context: context,
                  builder: (errorContext) {
                    return AlertDialog(
                      title: const Text('❌ AI 调用失败'),
                      content: Text(
                        '错误信息：$e\n\n'
                        '可能原因：\n'
                        '1. API Key 无效或已过期\n'
                        '2. 网络连接问题\n'
                        '3. OpenAI 服务暂时不可用\n\n'
                        '请检查网络和 API Key 配置',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(errorContext).pop();
                          },
                          child: const Text('确定'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}
