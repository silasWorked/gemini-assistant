import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'tool_base.dart';


class MemoryManager {
  static final MemoryManager _instance = MemoryManager._internal();
  factory MemoryManager() => _instance;
  MemoryManager._internal();

  final Map<String, MemoryEntry> _memories = {};
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await _loadFromDisk();
    _initialized = true;
  }

  Future<String> _getStoragePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}\\GeminiAssistant\\memory.json';
  }

  Future<void> _loadFromDisk() async {
    try {
      final path = await _getStoragePath();
      final file = File(path);
      if (await file.exists()) {
        final json = await file.readAsString();
        final data = jsonDecode(json) as Map<String, dynamic>;
        _memories.clear();
        for (final entry in data.entries) {
          _memories[entry.key] = MemoryEntry.fromJson(entry.value);
        }
      }
    } catch (e) {
      
    }
  }

  Future<void> _saveToDisk() async {
    try {
      final path = await _getStoragePath();
      final file = File(path);
      await file.parent.create(recursive: true);

      final data = <String, dynamic>{};
      for (final entry in _memories.entries) {
        data[entry.key] = entry.value.toJson();
      }

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      
    }
  }

  
  Future<void> remember({
    required String key,
    required String value,
    required MemoryType type,
    List<String> aliases = const [],
    String? description,
  }) async {
    await initialize();

    final entry = MemoryEntry(
      key: key.toLowerCase(),
      value: value,
      type: type,
      aliases: aliases.map((a) => a.toLowerCase()).toList(),
      description: description,
      createdAt: DateTime.now(),
      accessCount: 0,
    );

    _memories[key.toLowerCase()] = entry;

    
    for (final alias in aliases) {
      _memories[alias.toLowerCase()] = entry;
    }

    await _saveToDisk();
  }

  
  Future<MemoryEntry?> recall(String keyOrAlias) async {
    await initialize();

    final entry = _memories[keyOrAlias.toLowerCase()];
    if (entry != null) {
      entry.accessCount++;
      entry.lastAccessedAt = DateTime.now();
      await _saveToDisk();
    }
    return entry;
  }

  
  Future<List<MemoryEntry>> listAll({MemoryType? type}) async {
    await initialize();

    var results = _memories.values
        .toSet()
        .toList(); 

    if (type != null) {
      results = results.where((e) => e.type == type).toList();
    }

    
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return results;
  }

  
  Future<List<MemoryEntry>> search({
    String? query,
    MemoryType? type,
    int limit = 20,
  }) async {
    await initialize();

    var results = _memories.values
        .toSet()
        .toList(); 

    if (type != null) {
      results = results.where((e) => e.type == type).toList();
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results
          .where(
            (e) =>
                e.key.contains(q) ||
                e.value.toLowerCase().contains(q) ||
                (e.description?.toLowerCase().contains(q) ?? false) ||
                e.aliases.any((a) => a.contains(q)),
          )
          .toList();
    }

    
    results.sort((a, b) {
      final accessDiff = b.accessCount - a.accessCount;
      if (accessDiff != 0) return accessDiff;
      return (b.lastAccessedAt ?? b.createdAt).compareTo(
        a.lastAccessedAt ?? a.createdAt,
      );
    });

    return results.take(limit).toList();
  }

  
  Future<bool> forget(String keyOrAlias) async {
    await initialize();

    final entry = _memories[keyOrAlias.toLowerCase()];
    if (entry == null) return false;

    
    _memories.remove(entry.key);
    for (final alias in entry.aliases) {
      _memories.remove(alias);
    }

    await _saveToDisk();
    return true;
  }

  
  Future<String> getContextSummary() async {
    await initialize();

    if (_memories.isEmpty) return '';

    final unique = _memories.values.toSet().toList();
    final buffer = StringBuffer(
      '\n\nMEMORY (previously learned information):\n',
    );

    
    final byType = <MemoryType, List<MemoryEntry>>{};
    for (final entry in unique) {
      byType.putIfAbsent(entry.type, () => []).add(entry);
    }

    for (final type in byType.keys) {
      buffer.writeln('\n${_typeLabel(type)}:');
      for (final entry in byType[type]!.take(10)) {
        final aliasStr = entry.aliases.isNotEmpty
            ? ' (aliases: ${entry.aliases.join(", ")})'
            : '';
        buffer.writeln('- ${entry.key}$aliasStr: ${entry.value}');
      }
    }

    return buffer.toString();
  }

  String _typeLabel(MemoryType type) {
    switch (type) {
      case MemoryType.filePath:
        return 'Known Files/Paths';
      case MemoryType.command:
        return 'Useful Commands';
      case MemoryType.preference:
        return 'User Preferences';
      case MemoryType.fact:
        return 'Facts';
      case MemoryType.shortcut:
        return 'Shortcuts/Aliases';
      case MemoryType.project:
        return 'Projects';
      case MemoryType.other:
        return 'Other';
    }
  }
}

enum MemoryType {
  filePath, 
  command, 
  preference, 
  fact, 
  shortcut, 
  project, 
  other, 
}

class MemoryEntry {
  final String key;
  final String value;
  final MemoryType type;
  final List<String> aliases;
  final String? description;
  final DateTime createdAt;
  DateTime? lastAccessedAt;
  int accessCount;

  MemoryEntry({
    required this.key,
    required this.value,
    required this.type,
    this.aliases = const [],
    this.description,
    required this.createdAt,
    this.lastAccessedAt,
    this.accessCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'value': value,
    'type': type.name,
    'aliases': aliases,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'lastAccessedAt': lastAccessedAt?.toIso8601String(),
    'accessCount': accessCount,
  };

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
    key: json['key'],
    value: json['value'],
    type: MemoryType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => MemoryType.other,
    ),
    aliases: List<String>.from(json['aliases'] ?? []),
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    lastAccessedAt: json['lastAccessedAt'] != null
        ? DateTime.parse(json['lastAccessedAt'])
        : null,
    accessCount: json['accessCount'] ?? 0,
  );
}




class SaveMemoryTool extends Tool {
  final MemoryManager _memory = MemoryManager();

  @override
  String get name => 'save_memory';

  @override
  String get description =>
      'Store information in memory for future use. Use this to remember file paths, '
      'useful commands, user preferences, or any information that might be useful later. '
      'You can add aliases for quick recall.';

  @override
  Map<String, dynamic> get parameters => {
    'key': {
      'type': 'string',
      'description':
          'Short identifier for this memory (e.g., "chrome_path", "user_projects_folder")',
    },
    'value': {
      'type': 'string',
      'description':
          'The actual value to remember (e.g., path, command, information)',
    },
    'type': {
      'type': 'string',
      'description':
          'Type of memory: "file_path", "command", "preference", "fact", "shortcut", "project", "other"',
    },
    'aliases': {
      'type': 'string',
      'description':
          'Comma-separated aliases for quick recall (e.g., "chrome,browser,гугл")',
    },
    'description': {
      'type': 'string',
      'description': 'Optional description of what this memory is for',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final key = args['key'] as String?;
      final value = args['value'] as String?;
      final typeStr = args['type'] as String? ?? 'other';
      final aliasesStr = args['aliases'] as String? ?? '';
      final description = args['description'] as String?;

      if (key == null || key.isEmpty) {
        return ToolResult(success: false, message: 'Key is required');
      }
      if (value == null || value.isEmpty) {
        return ToolResult(success: false, message: 'Value is required');
      }

      final type = _parseType(typeStr);
      final aliases = aliasesStr.isNotEmpty
          ? aliasesStr
                .split(',')
                .map((a) => a.trim())
                .where((a) => a.isNotEmpty)
                .toList()
          : <String>[];

      await _memory.remember(
        key: key,
        value: value,
        type: type,
        aliases: aliases,
        description: description,
      );

      final aliasInfo = aliases.isNotEmpty
          ? '\nAliases: ${aliases.join(", ")}'
          : '';
      return ToolResult(
        success: true,
        message: 'Remembered: $key = $value$aliasInfo\nType: ${type.name}',
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error remembering: $e');
    }
  }

  MemoryType _parseType(String typeStr) {
    switch (typeStr.toLowerCase().replaceAll('_', '')) {
      case 'filepath':
      case 'file':
      case 'path':
        return MemoryType.filePath;
      case 'command':
      case 'cmd':
        return MemoryType.command;
      case 'preference':
      case 'pref':
        return MemoryType.preference;
      case 'fact':
        return MemoryType.fact;
      case 'shortcut':
      case 'alias':
        return MemoryType.shortcut;
      case 'project':
        return MemoryType.project;
      default:
        return MemoryType.other;
    }
  }
}


class RecallMemoryTool extends Tool {
  final MemoryManager _memory = MemoryManager();

  @override
  String get name => 'recall_memory';

  @override
  String get description =>
      'Recall information from memory by key or alias. Use this before searching '
      'the file system or running commands - you might already know the answer!';

  @override
  Map<String, dynamic> get parameters => {
    'query': {
      'type': 'string',
      'description': 'Key, alias, or search term to find in memory',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final query = args['query'] as String?;

      if (query == null || query.isEmpty) {
        return ToolResult(success: false, message: 'Query is required');
      }

      
      final exact = await _memory.recall(query);
      if (exact != null) {
        return ToolResult(
          success: true,
          message:
              'Found: ${exact.key}\n'
              'Value: ${exact.value}\n'
              'Type: ${exact.type.name}\n'
              '${exact.aliases.isNotEmpty ? "Aliases: ${exact.aliases.join(", ")}\n" : ""}'
              '${exact.description != null ? "Description: ${exact.description}\n" : ""}'
              'Used ${exact.accessCount} times',
        );
      }

      
      final results = await _memory.search(query: query, limit: 5);
      if (results.isEmpty) {
        return ToolResult(
          success: false,
          message: 'Nothing found in memory for "$query"',
        );
      }

      final buffer = StringBuffer(
        'Found ${results.length} related memories:\n\n',
      );
      for (final entry in results) {
        buffer.writeln('• ${entry.key}: ${entry.value}');
        if (entry.aliases.isNotEmpty) {
          buffer.writeln('  Aliases: ${entry.aliases.join(", ")}');
        }
      }

      return ToolResult(success: true, message: buffer.toString());
    } catch (e) {
      return ToolResult(success: false, message: 'Error recalling: $e');
    }
  }
}


class ListMemoriesTool extends Tool {
  final MemoryManager _memory = MemoryManager();

  @override
  String get name => 'list_memories';

  @override
  String get description =>
      'List all stored memories, optionally filtered by type.';

  @override
  Map<String, dynamic> get parameters => {
    'type': {
      'type': 'string',
      'description':
          'Optional filter by type: "file_path", "command", "preference", "fact", "shortcut", "project", "other"',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final typeStr = args['type'] as String?;
      MemoryType? type;

      if (typeStr != null && typeStr.isNotEmpty) {
        type = _parseType(typeStr);
      }

      final results = await _memory.search(type: type, limit: 50);

      if (results.isEmpty) {
        return ToolResult(
          success: true,
          message: type != null
              ? 'No memories of type "${type.name}"'
              : 'Memory is empty',
        );
      }

      final buffer = StringBuffer('Stored memories (${results.length}):\n\n');

      
      final byType = <MemoryType, List<MemoryEntry>>{};
      for (final entry in results) {
        byType.putIfAbsent(entry.type, () => []).add(entry);
      }

      for (final t in byType.keys) {
        buffer.writeln('${t.name.toUpperCase()}:');
        for (final entry in byType[t]!) {
          buffer.writeln('  • ${entry.key}: ${entry.value}');
        }
        buffer.writeln();
      }

      return ToolResult(success: true, message: buffer.toString());
    } catch (e) {
      return ToolResult(success: false, message: 'Error listing memories: $e');
    }
  }

  MemoryType? _parseType(String typeStr) {
    switch (typeStr.toLowerCase().replaceAll('_', '')) {
      case 'filepath':
      case 'file':
      case 'path':
        return MemoryType.filePath;
      case 'command':
      case 'cmd':
        return MemoryType.command;
      case 'preference':
      case 'pref':
        return MemoryType.preference;
      case 'fact':
        return MemoryType.fact;
      case 'shortcut':
      case 'alias':
        return MemoryType.shortcut;
      case 'project':
        return MemoryType.project;
      default:
        return null;
    }
  }
}


class ForgetMemoryTool extends Tool {
  final MemoryManager _memory = MemoryManager();

  @override
  String get name => 'forget_memory';

  @override
  String get description => 'Remove a memory entry by key or alias.';

  @override
  Map<String, dynamic> get parameters => {
    'key': {
      'type': 'string',
      'description': 'Key or alias of the memory to forget',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final key = args['key'] as String?;

      if (key == null || key.isEmpty) {
        return ToolResult(success: false, message: 'Key is required');
      }

      final success = await _memory.forget(key);

      if (success) {
        return ToolResult(success: true, message: 'Forgot: $key');
      } else {
        return ToolResult(success: false, message: 'Memory "$key" not found');
      }
    } catch (e) {
      return ToolResult(success: false, message: 'Error forgetting: $e');
    }
  }
}
