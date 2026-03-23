# 🎯 Focus AI Todo

一个功能强大的 Flutter 待办应用，集成 AI 能力支持智能任务拆分、规划和视觉化管理。

**[English](#english) | 中文**

## 功能特性

✨ **AI 任务拆分** - 自动将复杂任务分解为可执行的子任务
📋 **智能任务管理** - 支持任务创建、编辑、删除和状态管理
🎬 **视频背景** - 炫彩动态视频背景增强用户体验
📊 **任务规划** - AI 驱动的任务优先级和执行计划
⚡ **流畅体验** - 原生 Flutter 性能，支持真机运行
🎨 **现代 UI** - 优雅的界面设计和平滑动画

## 快速开始

### 前置要求

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- iOS 11.0+ 或 Android 5.0+

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/woshixiyangyang/focus_ai_todo.git
   cd focus_ai_todo
   ```

2. **获取依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   flutter run
   ```

## 项目结构

```
focus_ai_todo/
├── lib/
│   ├── main.dart           # 应用入口
│   ├── screens/            # 页面组件
│   ├── models/             # 数据模型
│   ├── services/           # 业务逻辑和 API 服务
│   └── widgets/            # 可复用组件
├── ios/                    # iOS 配置
├── android/                # Android 配置
└── pubspec.yaml           # 依赖配置
```

## 使用指南

### 创建任务
1. 点击主页的"+"按钮
2. 输入任务名称和描述
3. 点击"AI 拆分"自动生成子任务（可选）
4. 确认保存

### 使用 AI 任务拆分
- 在任务详情页点击"AI 拆分"按钮
- 系统将自动分析任务并推荐拆分方案
- 根据建议调整或直接确认

### 任务规划
- 查看"规划"页面获取智能排序建议
- 系统基于优先级、截止日期和依赖关系规划任务
- 支持自定义调整任务顺序

## 技术栈

- **框架**: Flutter
- **语言**: Dart
- **UI 库**: Material Design 3
- **状态管理**: Provider / GetX
- **API**: RESTful / GraphQL
- **存储**: SQLite / Hive

## API 集成

本应用集成 AI 服务，支持：
- OpenAI GPT 系列模型用于任务分析
- 其他主流大语言模型

详见 [API 配置指南](docs/API_CONFIG.md)

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 联系方式

- GitHub Issues: [提交问题](https://github.com/woshixiyangyang/focus_ai_todo/issues)
- Email: [联系作者]

---

## English

# 🎯 Focus AI Todo

A powerful Flutter todo application with AI-powered task splitting, planning, and management capabilities.

## Features

✨ **AI Task Splitting** - Automatically break down complex tasks into actionable subtasks
📋 **Smart Task Management** - Create, edit, delete, and manage tasks
🎬 **Video Background** - Dynamic video backgrounds for enhanced visual experience
📊 **Task Planning** - AI-driven task prioritization and execution plans
⚡ **Smooth Performance** - Native Flutter performance with real device support
🎨 **Modern UI** - Elegant design with smooth animations

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- iOS 11.0+ or Android 5.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/woshixiyangyang/focus_ai_todo.git
   cd focus_ai_todo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
focus_ai_todo/
├── lib/
│   ├── main.dart           # Application entry point
│   ├── screens/            # UI screens
│   ├── models/             # Data models
│   ├── services/           # Business logic and API services
│   └── widgets/            # Reusable widgets
├── ios/                    # iOS configuration
├── android/                # Android configuration
└── pubspec.yaml           # Dependencies
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.