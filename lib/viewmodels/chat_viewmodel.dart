import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/app_settings.dart';
import '../services/gemini_service.dart';
import '../services/chat_history_service.dart';
import '../l10n/app_localizations.dart';

class ChatViewModel extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ChatHistoryService _historyService = ChatHistoryService();
  GeminiService? _geminiService;

  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  bool _isApiKeySet = false;
  String? _errorMessage;
  bool _animationsEnabled = true;
  bool _toolsEnabled = true;
  List<ToolCategory> _toolCategories = ToolCategories.getDefaults();
  ProxySettings _proxySettings = ProxySettings();
  bool _isFirstLaunch = false;
  bool _isFromRestrictedRegion = false;
  bool _settingsLoaded = false;
  AppLanguage _language = AppLanguage.ru;

  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _currentSession?.messages ?? [];
  bool get isLoading => _isLoading;
  bool get isApiKeySet => _isApiKeySet;
  String? get errorMessage => _errorMessage;
  bool get animationsEnabled => _animationsEnabled;
  bool get toolsEnabled => _toolsEnabled;
  List<ToolCategory> get toolCategories => _toolCategories;
  ProxySettings get proxySettings => _proxySettings;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isFromRestrictedRegion => _isFromRestrictedRegion;
  bool get settingsLoaded => _settingsLoaded;
  AppLanguage get language => _language;

  ChatViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      
      final launched = await _storage.read(key: 'first_launch_complete');
      _isFirstLaunch = launched != 'true';

      
      if (_isFirstLaunch) {
        _isFromRestrictedRegion = await _checkRestrictedRegion();
      }

      final apiKey = await _storage.read(key: 'gemini_api_key');
      if (apiKey != null && apiKey.isNotEmpty) {
        _geminiService = GeminiService(apiKey);
        _isApiKeySet = true;
      }

      final animEnabled = await _storage.read(key: 'animations_enabled');
      _animationsEnabled = animEnabled != 'false';

      final toolsEnabled = await _storage.read(key: 'tools_enabled');
      _toolsEnabled = toolsEnabled != 'false';
      _geminiService?.setToolsEnabled(_toolsEnabled);

      
      final langStr = await _storage.read(key: 'language');
      _language = langStr == 'en' ? AppLanguage.en : AppLanguage.ru;

      
      final categoriesJson = await _storage.read(key: 'tool_categories');
      if (categoriesJson != null) {
        final List<dynamic> savedCategories = jsonDecode(categoriesJson);
        final defaults = ToolCategories.getDefaults();
        for (
          var i = 0;
          i < defaults.length && i < savedCategories.length;
          i++
        ) {
          defaults[i].enabled = savedCategories[i]['enabled'] ?? true;
        }
        _toolCategories = defaults;
      }
      _updateEnabledTools();

      
      final proxyJson = await _storage.read(key: 'proxy_settings');
      if (proxyJson != null) {
        _proxySettings = ProxySettings.fromJson(jsonDecode(proxyJson));
        if (_proxySettings.enabled) {
          _geminiService?.setProxy(
            _proxySettings.host,
            _proxySettings.port,
            _proxySettings.username,
            _proxySettings.password,
          );
        }
      }

      
      _sessions = await _historyService.loadSessions();
      if (_sessions.isEmpty) {
        _currentSession = ChatSession.create();
        _sessions.add(_currentSession!);
      } else {
        _currentSession = _sessions.first;
      }

      _settingsLoaded = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
      _settingsLoaded = true;
      notifyListeners();
    }
  }

  Future<bool> _checkRestrictedRegion() async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 5);

      
      final request = await httpClient.getUrl(
        Uri.parse('http://ip-api.com/json/?fields=countryCode'),
      );
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        final countryCode = data['countryCode'] as String?;

        
        final restrictedCountries = ['RU', 'BY'];
        return restrictedCountries.contains(countryCode);
      }
    } catch (e) {
      
      return true;
    }
    return false;
  }

  Future<void> markFirstLaunchComplete() async {
    _isFirstLaunch = false;
    await _storage.write(key: 'first_launch_complete', value: 'true');
    notifyListeners();
  }

  void _updateEnabledTools() {
    final enabledTools = <String>{};
    for (final category in _toolCategories) {
      if (category.enabled) {
        enabledTools.addAll(category.toolIds);
      }
    }
    _geminiService?.setEnabledTools(enabledTools);
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    _animationsEnabled = enabled;
    await _storage.write(key: 'animations_enabled', value: enabled.toString());
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    await _storage.write(
      key: 'language',
      value: lang == AppLanguage.en ? 'en' : 'ru',
    );
    notifyListeners();
  }

  Future<void> setToolsEnabled(bool enabled) async {
    _toolsEnabled = enabled;
    _geminiService?.setToolsEnabled(enabled);
    await _storage.write(key: 'tools_enabled', value: enabled.toString());
    notifyListeners();
  }

  Future<void> setToolCategoryEnabled(String categoryId, bool enabled) async {
    final category = _toolCategories.firstWhere((c) => c.id == categoryId);
    category.enabled = enabled;
    _updateEnabledTools();
    await _storage.write(
      key: 'tool_categories',
      value: jsonEncode(_toolCategories.map((c) => c.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> setProxySettings(ProxySettings settings) async {
    _proxySettings = settings;
    if (settings.enabled && settings.host.isNotEmpty) {
      _geminiService?.setProxy(
        settings.host,
        settings.port,
        settings.username,
        settings.password,
      );
    } else {
      _geminiService?.setProxy(null, 0, null, null);
    }
    await _storage.write(
      key: 'proxy_settings',
      value: jsonEncode(settings.toJson()),
    );
    notifyListeners();
  }

  Future<bool> setApiKey(String apiKey) async {
    try {
      final service = GeminiService(apiKey);
      final isValid = await service.validateApiKey();

      if (isValid) {
        await _storage.write(key: 'gemini_api_key', value: apiKey);
        _geminiService = service;
        _isApiKeySet = true;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid API key';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to validate API key: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _geminiService == null) return;
    if (_currentSession == null) {
      _currentSession = ChatSession.create();
      _sessions.insert(0, _currentSession!);
    }

    
    final targetSession = _currentSession!;

    
    final userMessage = ChatMessage(text: text, isUser: true);
    targetSession.messages.add(userMessage);
    targetSession.updatedAt = DateTime.now();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      
      final history = targetSession.messages
          .where((m) => m != userMessage)
          .map((m) => m.toJson())
          .toList();

      
      ChatMessage? currentToolMessage;
      final response = await _geminiService!.sendMessage(
        text,
        history: history,
        onToolCall: (toolInfo) {
          
          currentToolMessage = ChatMessage(text: toolInfo, isUser: false);
          targetSession.messages.add(currentToolMessage!);
          notifyListeners();
        },
        onToolComplete: (toolName) {
          
          if (currentToolMessage != null) {
            final index = targetSession.messages.indexOf(currentToolMessage!);
            if (index != -1) {
              targetSession.messages[index] = ChatMessage(
                text: '✓ $toolName',
                isUser: false,
                timestamp: currentToolMessage!.timestamp,
              );
              notifyListeners();
            }
          }
        },
      );

      
      final assistantMessage = ChatMessage(text: response, isUser: false);
      targetSession.messages.add(assistantMessage);
      targetSession.updatedAt = DateTime.now();

      
      if (targetSession.messages.length <= 2) {
        targetSession.updateTitle();
      }

      
      await _historyService.saveSession(targetSession);
    } catch (e) {
      _errorMessage = e.toString();
      final errorMessage = ChatMessage(
        text: 'Error: ${e.toString()}',
        isUser: false,
      );
      targetSession.messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSession(ChatSession session) {
    _currentSession = session;
    notifyListeners();
  }

  void createNewChat() {
    _currentSession = ChatSession.create();
    _sessions.insert(0, _currentSession!);
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    await _historyService.deleteSession(sessionId);
    _sessions.removeWhere((s) => s.id == sessionId);

    if (_currentSession?.id == sessionId) {
      if (_sessions.isNotEmpty) {
        _currentSession = _sessions.first;
      } else {
        _currentSession = ChatSession.create();
        _sessions.add(_currentSession!);
      }
    }
    notifyListeners();
  }

  void clearChat() {
    createNewChat();
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: 'gemini_api_key');
    _geminiService = null;
    _isApiKeySet = false;
    _currentSession?.messages.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
