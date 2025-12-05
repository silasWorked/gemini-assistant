import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/app_settings.dart';
import 'tools/tool_registry.dart';
import 'tools/tool_base.dart';

class GeminiService {
  final String apiKey;
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  //
  final ToolRegistry _toolRegistry = ToolRegistry();
  bool _toolsEnabled = true;
  Set<String> _enabledTools = {};
  String? _proxyHost;
  int _proxyPort = 8080;
  String? _proxyUsername;
  String? _proxyPassword;
  http.Client? _httpClient;
  GeminiModel _model = GeminiModel.gemini20Flash;

  GeminiService(this.apiKey) {
    _toolRegistry.initialize();
    _enabledTools = _toolRegistry.allTools.map((t) => t.name).toSet();
  }

  void setModel(GeminiModel model) {
    _model = model;
  }

  GeminiModel get model => _model;

  void setToolsEnabled(bool enabled) {
    _toolsEnabled = enabled;
  }

  void setEnabledTools(Set<String> toolIds) {
    _enabledTools = toolIds;
  }

  void setProxy(String? host, int port, String? username, String? password) {
    _proxyHost = host;
    _proxyPort = port;
    _proxyUsername = username;
    _proxyPassword = password;
    _httpClient?.close();
    _httpClient = null;
  }

  http.Client get _client {
    if (_httpClient != null) return _httpClient!;

    if (_proxyHost != null && _proxyHost!.isNotEmpty) {
      final proxy = HttpClient();
      proxy.findProxy = (uri) => 'PROXY $_proxyHost:$_proxyPort';
      proxy.badCertificateCallback = (cert, host, port) => true;

      if (_proxyUsername != null && _proxyUsername!.isNotEmpty) {
        proxy.addProxyCredentials(
          _proxyHost!,
          _proxyPort,
          'Basic',
          HttpClientBasicCredentials(_proxyUsername!, _proxyPassword ?? ''),
        );
      }

      _httpClient = IOClient(proxy);
    } else {
      _httpClient = http.Client();
    }
    return _httpClient!;
  }

  String get _systemInfo {
    final home =
        Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        'Unknown';
    final username =
        Platform.environment['USERNAME'] ??
        Platform.environment['USER'] ??
        'Unknown';

    return '''
SYSTEM INFORMATION:
- Operating System: ${Platform.operatingSystem} (${Platform.operatingSystemVersion})
- User: $username
- Home Directory: $home
- Desktop: $home\\Desktop
- Documents: $home\\Documents
- Downloads: $home\\Downloads
- Number of Processors: ${Platform.numberOfProcessors}
- Locale: ${Platform.localeName}
''';
  }

  String get _systemPrompt =>
      '''
You are a helpful AI assistant with access to the user's computer. You can perform various operations on the operating system.

$_systemInfo

CRITICAL PATH RULES:
1. This is Windows! Always use backslashes (\\) in paths
2. Always use FULL ABSOLUTE paths, never relative paths
3. Desktop path: Use the exact path from SYSTEM INFORMATION above
4. When user says "desktop" or "рабочий стол", use: ${Platform.environment['USERPROFILE']}\\Desktop
5. When user says "documents" or "документы", use: ${Platform.environment['USERPROFILE']}\\Documents
6. Example correct path: C:\\Users\\Username\\Desktop\\myfile.txt
7. Example WRONG path: ~/Desktop/myfile.txt (this is Linux format!)

When the user asks you to do something that requires interacting with files, running commands, or accessing system information, use the appropriate tool.

IMPORTANT TOOL TIPS:
- To find where a running process executable is located, use get_process_path tool (NOT search_files!)
- To list running processes, use list_processes
- To search for files by name, use search_files (but avoid searching in C:\\ root, Program Files, or Windows directories)
- When user asks to "run as admin" or "от админа" - use run_admin_command tool! This opens a NEW elevated PowerShell window for the user.
- run_command runs commands in background and returns output
- run_admin_command opens a visible elevated console window for the user to interact with

MEMORY SYSTEM - USE IT PROACTIVELY!
You have persistent memory tools. USE THEM to remember useful information:
- save_memory: Save info with a key and aliases. ALWAYS use this after finding file paths, process locations, or any useful info the user might need again!
- recall_memory: Retrieve saved info by key, alias, or search query. Check memory FIRST before searching the filesystem!
- list_memories: Show all saved memories
- forget_memory: Delete a memory entry
Example: After finding comet.exe path, IMMEDIATELY call save_memory with key="comet_path", content="C:\\Users\\...\\comet.exe", aliases=["comet", "comet.exe", "перплексити"]
When user asks to "save to memory" or "запомни" - USE save_memory tool!

Always respond in the same language as the user. If they write in Russian, respond in Russian.

Always explain what you're doing before and after using tools. If a tool fails, explain the error and suggest alternatives.

CRITICAL: After using ANY tool, you MUST provide a text response describing the result to the user. NEVER leave the conversation without a final text message!

DANGEROUS OPERATIONS - ALWAYS ASK FOR CONFIRMATION FIRST:
Before performing ANY of these operations, you MUST ask "Вы уверены?" (or "Are you sure?" in English) and WAIT for user's response:
- delete (удаление файлов или папок)
- kill_process (завершение процессов)  
- write_file (перезапись существующих файлов)
- run_command (опасные команды типа rm, del, format, shutdown)
Do NOT execute these tools until user confirms with "да" or "yes"!

When showing file contents or command output, format it nicely using markdown code blocks.
''';

  Future<String> sendMessage(
    String message, {
    List<Map<String, dynamic>>? history,
    Function(String)? onToolCall,
    Function(String)? onToolComplete,
  }) async {
    try {
      final contents = <Map<String, dynamic>>[];

      contents.add({
        'role': 'user',
        'parts': [
          {'text': _systemPrompt},
        ],
      });
      contents.add({
        'role': 'model',
        'parts': [
          {
            'text':
                'I understand. I\'m ready to help you with your computer. I have access to various tools for file operations, system information, running commands, and more.',
          },
        ],
      });

      if (history != null) {
        contents.addAll(history);
      }

      contents.add({
        'role': 'user',
        'parts': [
          {'text': message},
        ],
      });

      return await _sendRequest(
        contents,
        onToolCall: onToolCall,
        onToolComplete: onToolComplete,
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> _sendRequest(
    List<Map<String, dynamic>> contents, {
    Function(String)? onToolCall,
    Function(String)? onToolComplete,
    int depth = 0,
  }) async {
    if (depth > 10) {
      return 'Maximum tool call depth reached. Please try a simpler request.';
    }

    final requestBody = <String, dynamic>{
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 4096,
      },
    };

    if (_toolsEnabled && _enabledTools.isNotEmpty) {
      final enabledDeclarations = _toolRegistry.allTools
          .where((t) => _enabledTools.contains(t.name))
          .map((t) => t.toFunctionDeclaration())
          .toList();
      if (enabledDeclarations.isNotEmpty) {
        requestBody['tools'] = [
          {'function_declarations': enabledDeclarations},
        ];
      }
    }

    final response = await _client
        .post(
          Uri.parse('$baseUrl/${_model.apiName}:generateContent'),
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode(requestBody),
        )
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () =>
              throw Exception('Request timed out after 60 seconds'),
        );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error']['message'] ?? 'Failed to get response');
    }

    final data = jsonDecode(response.body);
    if (data['candidates'] == null || data['candidates'].isEmpty) {
      return 'No response generated';
    }

    final candidate = data['candidates'][0];
    final parts = candidate['content']['parts'] as List;

    for (final part in parts) {
      if (part['functionCall'] != null) {
        final functionCall = part['functionCall'];
        final functionName = functionCall['name'] as String;
        final functionArgs = Map<String, dynamic>.from(
          functionCall['args'] ?? {},
        );

        onToolCall?.call('🔧 Вызов инструмента: $functionName');

        ToolResult result;
        try {
          result = await _toolRegistry
              .executeTool(functionName, functionArgs)
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () => ToolResult(
                  success: false,
                  message: 'Tool execution timed out after 30 seconds',
                ),
              );
        } catch (e) {
          result = ToolResult(
            success: false,
            message: 'Tool execution error: $e',
          );
        }

        onToolComplete?.call(functionName);

        contents.add({
          'role': 'model',
          'parts': [
            {
              'functionCall': {'name': functionName, 'args': functionArgs},
            },
          ],
        });

        contents.add({
          'role': 'user',
          'parts': [
            {
              'functionResponse': {
                'name': functionName,
                'response': result.toJson(),
              },
            },
          ],
        });

        return await _sendRequest(
          contents,
          onToolCall: onToolCall,
          onToolComplete: onToolComplete,
          depth: depth + 1,
        );
      }
    }

    for (final part in parts) {
      if (part['text'] != null) {
        return part['text'] as String;
      }
    }

    if (depth > 0) {
      return 'Операция выполнена.';
    }

    return 'No response generated';
  }

  Future<bool> validateApiKey() async {
    try {
      final oldToolsEnabled = _toolsEnabled;
      _toolsEnabled = false;
      await sendMessage('Hello');
      _toolsEnabled = oldToolsEnabled;
      return true;
    } catch (e) {
      return false;
    }
  }
}
