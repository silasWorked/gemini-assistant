enum GeminiModel {
  gemini25Flash('gemini-2.5-flash', 'Gemini 2.5 Flash'),
  gemini20Flash('gemini-2.0-flash', 'Gemini 2.0 Flash'),
  gemini20FlashLite('gemini-2.0-flash-lite', 'Gemini 2.0 Flash Lite'),
  gemini25FlashLite('gemini-2.5-flash-lite', 'Gemini 2.5 Flash Lite'),
  gemini25Pro('gemini-2.5-pro', 'Gemini 2.5 Pro');

  final String apiName;
  final String displayName;
  const GeminiModel(this.apiName, this.displayName);

  static GeminiModel fromApiName(String? name) {
    return GeminiModel.values.firstWhere(
      (m) => m.apiName == name,
      orElse: () => GeminiModel.gemini20Flash,
    );
  }
}

class ToolCategory {
  final String id;
  final String name;
  final String description;
  final List<String> toolIds;
  bool enabled;

  ToolCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.toolIds,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'enabled': enabled};

  static ToolCategory fromJson(
    Map<String, dynamic> json,
    ToolCategory defaults,
  ) {
    return ToolCategory(
      id: defaults.id,
      name: defaults.name,
      description: defaults.description,
      toolIds: defaults.toolIds,
      enabled: json['enabled'] ?? true,
    );
  }
}

class ProxySettings {
  bool enabled;
  String host;
  int port;
  String? username;
  String? password;

  ProxySettings({
    this.enabled = false,
    this.host = '',
    this.port = 8080,
    this.username,
    this.password,
  });

  String? get proxyUrl {
    if (!enabled || host.isEmpty) return null;
    if (username != null && username!.isNotEmpty) {
      return 'http://$username:$password@$host:$port';
    }
    return 'http://$host:$port';
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'host': host,
    'port': port,
    'username': username,
    'password': password,
  };

  static ProxySettings fromJson(Map<String, dynamic>? json) {
    if (json == null) return ProxySettings();
    return ProxySettings(
      enabled: json['enabled'] ?? false,
      host: json['host'] ?? '',
      port: json['port'] ?? 8080,
      username: json['username'],
      password: json['password'],
    );
  }
}

class ToolCategories {
  static List<ToolCategory> getDefaults() => [
    ToolCategory(
      id: 'files',
      name: 'Файлы',
      description: 'Чтение, запись, удаление файлов',
      toolIds: [
        'read_file',
        'write_file',
        'list_directory',
        'create_directory',
        'delete',
        'search_files',
      ],
    ),
    ToolCategory(
      id: 'system',
      name: 'Система',
      description: 'Информация о системе и процессах',
      toolIds: [
        'system_info',
        'list_processes',
        'get_process_path',
        'kill_process',
        'disk_info',
        'network_info',
      ],
    ),
    ToolCategory(
      id: 'commands',
      name: 'Команды',
      description: 'Выполнение команд и запуск программ',
      toolIds: [
        'run_command',
        'run_admin_command',
        'launch_app',
        'open_file',
        'open_url',
      ],
    ),
    ToolCategory(
      id: 'clipboard',
      name: 'Буфер обмена',
      description: 'Работа с буфером обмена',
      toolIds: ['read_clipboard', 'write_clipboard'],
    ),
    ToolCategory(
      id: 'timers',
      name: 'Таймеры',
      description: 'Таймеры и напоминания',
      toolIds: ['set_timer', 'list_timers', 'cancel_timer'],
    ),
    ToolCategory(
      id: 'memory',
      name: 'Память',
      description: 'Запоминание информации и алиасов',
      toolIds: [
        'save_memory',
        'recall_memory',
        'list_memories',
        'forget_memory',
      ],
    ),
  ];
}
