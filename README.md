A Flutter-based to-do app prototype that explores how AI can help users split, organize, and plan tasks.

## Project Description

This is a student project built to understand how AI can assist with task management. The app lets users create to-do items and uses AI to help break down complex tasks into smaller, more manageable steps. I also experimented with adding task planning features and different UI elements like video backgrounds.

## Motivation

I started this project because I wanted to learn how to build mobile apps with Flutter and explore a practical use case for AI. When working on large projects or assignments, I often struggle with breaking tasks into smaller pieces and figuring out a good order to tackle them in. I thought it would be useful to prototype an app that could help with that process.

## Features

- **AI Task Splitting** - Users can ask the app to break down a task into smaller subtasks
- **Task Management** - Create, edit, delete, and track to-do items
- **Task Planning** - View suggested task order based on priority and due dates
- **Video Background** - The app includes an animated background
- **Basic UI** - Built with Flutter's Material Design

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **UI**: Material Design 3
- **State Management**: Provider / GetX
- **Storage**: SQLite / Hive
- **AI Integration**: OpenAI API for task analysis

## Project Structure

```
focus_ai_todo/
├── lib/
│   ├── main.dart           # App entry point
│   ├── screens/            # UI screens
│   ├── models/             # Data models
│   ├── services/           # Business logic and API calls
│   └── widgets/            # Reusable UI components
├── ios/                    # iOS configuration
├── android/                # Android configuration
└── pubspec.yaml           # Dependencies
```

## How to Run

### Requirements

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

## How It Works

**Creating a task**: Click the " + " button on the home screen and enter a task name and description.

**Using AI to split tasks**: From the task details screen, click the "AI Split" button. The app will suggest ways to break down the task into smaller steps.

**Viewing planned tasks**: The app can organize your tasks by priority and due date to suggest a good order to work on them.

## Future Improvements

- Improve the AI suggestions by training on task data
- Add support for recurring tasks and reminders
- Sync tasks across devices
- Better handling of task dependencies
- More options for customizing how the app organizes tasks

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
