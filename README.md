# Gemini Assistant

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.0+-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
</p>

AI-powered desktop assistant built with Flutter and Google Gemini 2.0 Flash API with full OS interaction capabilities.

## ✨ Features

- 💬 **Natural Conversation** with Google Gemini AI (2.0 Flash model)
- 🛠️ **26 OS Tools** - AI can interact with your computer
- 🧠 **Persistent Memory** - AI remembers important information between sessions
- ⏰ **Timers & Reminders** - Set timers with notifications
- 🌍 **Localization** - Russian and English languages
- 🔒 **Proxy Support** - Works in restricted regions
- 📥 **System Tray** - Minimize to tray, quick access
- 🎨 **Beautiful Dark UI** - Elegant gradient design with purple accents
- ✨ **Smooth Animations** - Optional, can be disabled
- 📜 **Chat History** - Persistent chat sessions
- 🔐 **Secure Storage** - API keys stored securely
- 📝 **Markdown Support** - Rich text with code highlighting

## 🛠️ Available Tools (26 total)

### 📁 File System (6 tools)
| Tool | Description |
|------|-------------|
| `read_file` | Read text file contents |
| `write_file` | Create or overwrite files |
| `list_directory` | Show folder contents |
| `create_directory` | Create new folders |
| `delete` | Delete files or folders |
| `search_files` | Search files by name pattern |

### 💻 System (6 tools)
| Tool | Description |
|------|-------------|
| `system_info` | OS, CPU, memory info |
| `disk_info` | Disk space information |
| `network_info` | Network interfaces and IPs |
| `list_processes` | List running processes |
| `get_process_path` | Find process executable path |
| `kill_process` | Terminate process by PID |

### ⚡ Commands (5 tools)
| Tool | Description |
|------|-------------|
| `run_command` | Execute PowerShell commands |
| `run_admin_command` | Execute as administrator |
| `launch_app` | Launch applications |
| `open_file` | Open file in default app |
| `open_url` | Open URL in browser |

### 📋 Clipboard (2 tools)
| Tool | Description |
|------|-------------|
| `read_clipboard` | Read clipboard text |
| `write_clipboard` | Copy text to clipboard |

### ⏰ Timers (3 tools)
| Tool | Description |
|------|-------------|
| `set_timer` | Create timer with message |
| `list_timers` | Show active timers |
| `cancel_timer` | Cancel timer by ID |

### 🧠 Memory (4 tools)
| Tool | Description |
|------|-------------|
| `save_memory` | Remember information |
| `recall_memory` | Retrieve saved info |
| `list_memories` | Show all memories |
| `forget_memory` | Delete memory entry |

## 📋 Prerequisites

- Google Gemini API key from [ai.google.dev](https://ai.google.dev)

## 🚀 Installation

### Option 1: Download Release (Recommended)

1. Go to [Releases](https://github.com/silasWorked/gemini-assistant/releases/latest)
2. Download `gemini-assistant-windows-x64.zip`
3. Extract to any folder
4. Run `gemini_assistant.exe`
5. Enter your API key in settings

### Option 2: Build from Source

**Requirements:** Flutter SDK 3.10.3 or higher

1. **Clone the repository:**
```bash
git clone https://github.com/silasWorked/gemini-assistant.git
cd gemini-assistant
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Run the app:**
```bash
flutter run -d windows
```

## ⚙️ Configuration

On first launch, you'll be prompted to enter your Gemini API key:

1. Click the settings icon (⚙️) in the sidebar
2. Enter your API key from [Google AI Studio](https://ai.google.dev)
3. The key will be securely stored locally

### Proxy Setup (Optional)

If you're in a region where Google API is blocked:

1. Go to Settings
2. Enable HTTP Proxy
3. Enter your proxy details (host, port, optional auth)
4. Click "Check" to verify connection

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry point
├── l10n/
│   └── app_localizations.dart    # Localization strings
├── models/
│   ├── app_settings.dart         # Settings model
│   ├── chat_message.dart         # Message model
│   └── chat_session.dart         # Session model
├── screens/
│   ├── chat_screen.dart          # Main chat UI
│   ├── tools_page.dart           # Tools management
│   └── memory_page.dart          # Memory viewer
├── services/
│   ├── gemini_service.dart       # Gemini API client
│   ├── chat_history_service.dart # History persistence
│   ├── tray_service.dart         # System tray
│   └── tools/                    # OS tools
│       ├── tool_base.dart
│       ├── tool_registry.dart
│       ├── file_tools.dart
│       ├── system_tools.dart
│       ├── command_tools.dart
│       ├── clipboard_tools.dart
│       ├── timer_tools.dart
│       └── memory_tools.dart
├── viewmodels/
│   └── chat_viewmodel.dart       # State management
└── widgets/
    ├── chat_bubble.dart
    ├── chat_input.dart
    ├── navigation_sidebar.dart
    ├── settings_dialog.dart
    └── ...
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `http` | API requests |
| `flutter_secure_storage` | Secure key storage |
| `flutter_markdown` | Markdown rendering |
| `path_provider` | Local storage paths |
| `uuid` | Unique IDs |
| `system_tray` | System tray integration |
| `window_manager` | Window control |
| `local_notifier` | Desktop notifications |

## 💬 Usage Examples

Ask the AI to:

**English:**
- "Show what's on my desktop"
- "Find all .log files in Windows folder"
- "What processes are using the most memory?"
- "Open google.com"
- "Remember that my project is in C:\Projects\MyApp"
- "Set a timer for 5 minutes"

**Russian:**
- "Покажи что на рабочем столе"
- "Найди все .log файлы в папке Windows"
- "Какие процессы занимают больше всего памяти?"
- "Открой google.com"
- "Запомни что мой проект находится в C:\Projects\MyApp"
- "Поставь таймер на 5 минут"

## 🔨 Building for Production
> ⚠️ **Note:** OS tools are optimized for **Windows**. On macOS/Linux the chat works, but some tools (commands, processes, system info) may not work correctly or require adaptation.

### Windows
```bash
flutter build windows --release
```

The executable will be at `build/windows/x64/runner/Release/`

### macOS
```bash
flutter build macos --release
```

### Linux
```bash
flutter build linux --release
```

## 🔒 Security Notes

- API keys are stored using platform-secure storage
- Dangerous operations (delete, kill process) require user confirmation
- Tool execution can be disabled in settings
- Individual tool categories can be toggled on/off

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Google Gemini API](https://ai.google.dev) for the AI backend
- [Flutter](https://flutter.dev) for the amazing framework
