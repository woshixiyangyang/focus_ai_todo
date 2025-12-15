// lib/services/ai_client.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiClient {
  static const String _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4o-mini';

  static String get _apiKey {
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isEmpty) {
      throw Exception(
        'OPENAI_API_KEY is empty. Did you forget --dart-define=OPENAI_API_KEY=xxx?',
      );
    }
    return apiKey;
  }

  /// 调用 OpenAI，把一大段话拆成多个可以执行的任务（每个任务一行文字）
  static Future<List<String>> splitParagraphToTasks(String paragraph) async {
    final text = paragraph.trim();
    if (text.isEmpty) return [];

    final apiKey = _apiKey;

    // 调试输出：只打印后4位
    final keySuffix = apiKey.length >= 4
        ? apiKey.substring(apiKey.length - 4)
        : 'TOO_SHORT';
    debugPrint('🔑 OPENAI_KEY_SUFFIX=$keySuffix');
    debugPrint('📝 输入文本: $text');

    try {
      debugPrint('🤖 正在调用 OpenAI API [splitParagraphToTasks]...');

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  '你是一个智能待办清单助手。用户会给你一段自然语言描述，里面可能包含多个要做的事情。\n\n'
                  '你的任务：\n'
                  '1. 仔细分析用户的描述，识别出所有独立的任务\n'
                  '2. 将每个任务拆分成一个独立的、可执行的待办事项\n'
                  '3. 每个任务要简洁明了，用中文表达\n'
                  '4. 保留关键细节（如"粉色花瓶"这样的重要信息）\n'
                  '5. 按照逻辑顺序排列任务\n\n'
                  '输出格式要求：\n'
                  '- 每行一个任务\n'
                  '- 不要加数字编号、破折号、星号等前缀\n'
                  '- 不要输出任何解释或额外文字\n'
                  '- 直接输出任务列表\n\n'
                  '示例：\n'
                  '输入："给小猫加水，给小狗加粮，路过花店买花，花要插在粉色花瓶里"\n'
                  '输出：\n'
                  '给小猫加水\n'
                  '给小狗加粮\n'
                  '路过花店买花\n'
                  '花要插在粉色花瓶里',
            },
            {'role': 'user', 'content': text},
          ],
          'temperature': 0.3,
        }),
      );

      debugPrint('📡 OpenAI status=${response.statusCode}');

      if (response.statusCode != 200) {
        final errorMsg = 'API调用失败 [${response.statusCode}]: ${response.body}';
        debugPrint('❌ $errorMsg');
        throw Exception(errorMsg);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'] as String? ?? '';

      debugPrint('✅ AI 返回内容:\n$content');

      // 把模型返回的内容按行拆开，并去掉可能的 "1."、"- " 这种前缀
      final lines = content
          .split('\n')
          .map((e) => e.replaceFirst(RegExp(r'^\s*[\d\-•\*]+[\.、、]?\s*'), ''))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      debugPrint('📋 最终任务列表(${lines.length}条): $lines');
      return lines;
    } catch (e) {
      debugPrint('❌ 调用出错: $e');
      rethrow;
    }
  }

  /// AI分析任务的优先级和推荐顺序
  /// 返回：按优先级排序后的任务标题列表
  static Future<List<Map<String, dynamic>>> analyzeTaskPriority({
    required List<String> tasks,
    required String strategy, // 'hardFirst', 'easyFirst', 'balanced'
  }) async {
    if (tasks.isEmpty) return [];

    final apiKey = _apiKey;

    final keySuffix = apiKey.length >= 4
        ? apiKey.substring(apiKey.length - 4)
        : 'TOO_SHORT';
    debugPrint('🔑 OPENAI_KEY_SUFFIX=$keySuffix');
    debugPrint('📊 AI分析任务优先级，策略=$strategy，任务数=${tasks.length}');

    String strategyDesc;
    switch (strategy) {
      case 'hardFirst':
        strategyDesc = '挑战自我（难到易）：困难的任务排在前面，简单的任务排在后面';
        break;
      case 'easyFirst':
        strategyDesc = '胸有成竹（易到难）：简单的任务排在前面，困难的任务排在后面';
        break;
      case 'balanced':
        strategyDesc = '劳逸结合（难易掺杂）：困难和简单的任务交替排列';
        break;
      default:
        strategyDesc = '按合理顺序排列';
    }

    try {
      debugPrint('🤖 正在调用 OpenAI API [analyzeTaskPriority]...');

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  '你是一个专业的任务优先级分析助手。你需要分析用户的待办任务列表，评估每个任务的难度和优先级。\n\n'
                  '你的任务：\n'
                  '1. 分析每个任务的难度（easy/normal/hard）\n'
                  '2. 根据用户指定的策略，给出推荐的执行顺序\n'
                  '3. 返回严格的JSON格式\n\n'
                  '输出格式（必须是有效的JSON数组）：\n'
                  '[\n'
                  '  {"title": "任务标题", "difficulty": "easy|normal|hard", "priority": 1},\n'
                  '  {"title": "任务标题", "difficulty": "easy|normal|hard", "priority": 2}\n'
                  ']\n\n'
                  '难度判断标准：\n'
                  '- easy: 5分钟内能完成的简单任务，不需要思考\n'
                  '- normal: 需要10-30分钟，需要一定专注度\n'
                  '- hard: 超过30分钟，需要深度思考或有挑战性\n\n'
                  '重要：只输出JSON数组，不要有任何其他文字！',
            },
            {
              'role': 'user',
              'content':
                  '策略：$strategyDesc\n\n'
                  '待分析的任务列表：\n${tasks.map((t) => '- $t').join('\n')}\n\n'
                  '请按照指定策略，返回JSON格式的任务优先级分析结果。',
            },
          ],
          'temperature': 0.3,
        }),
      );

      debugPrint('📡 OpenAI status=${response.statusCode}');

      if (response.statusCode != 200) {
        final errorMsg = 'API调用失败 [${response.statusCode}]: ${response.body}';
        debugPrint('❌ $errorMsg');
        throw Exception(errorMsg);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      var content = data['choices'][0]['message']['content'] as String? ?? '';

      debugPrint('✅ AI 返回原始内容:\n$content');

      // 清理可能的markdown代码块标记
      content = content.replaceAll(RegExp(r'```json\s*'), '');
      content = content.replaceAll(RegExp(r'```\s*'), '');
      content = content.trim();

      // 解析JSON
      final List<dynamic> parsed = jsonDecode(content);
      final result = parsed.map((item) {
        return {
          'title': item['title'] as String,
          'difficulty': item['difficulty'] as String,
          'priority': item['priority'] as int,
        };
      }).toList();

      debugPrint('📋 AI分析结果: ${result.length}个任务已排序');
      return result;
    } catch (e) {
      debugPrint('❌ AI分析出错: $e');
      rethrow;
    }
  }
}
