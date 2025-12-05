import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/chat_session.dart';

class ChatHistoryService {
  static const String _fileName = 'chat_history.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<ChatSession>> loadSessions() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(contents);
      return jsonList
          .map((json) => ChatSession.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  Future<void> saveSessions(List<ChatSession> sessions) async {
    try {
      final file = await _localFile;
      final jsonList = sessions.map((s) => s.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  Future<void> saveSession(ChatSession session) async {
    final sessions = await loadSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);

    if (index >= 0) {
      sessions[index] = session;
    } else {
      sessions.insert(0, session);
    }

    await saveSessions(sessions);
  }

  Future<void> deleteSession(String sessionId) async {
    final sessions = await loadSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await saveSessions(sessions);
  }
}
