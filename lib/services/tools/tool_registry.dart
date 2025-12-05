import 'tool_base.dart';
import 'file_tools.dart';
import 'system_tools.dart';
import 'command_tools.dart';
import 'clipboard_tools.dart';
import 'timer_tools.dart';
import 'memory_tools.dart';


class ToolRegistry {
  static final ToolRegistry _instance = ToolRegistry._internal();
  factory ToolRegistry() => _instance;
  ToolRegistry._internal();

  final Map<String, Tool> _tools = {};

  
  void initialize() {
    _registerTool(ReadFileTool());
    _registerTool(WriteFileTool());
    _registerTool(ListDirectoryTool());
    _registerTool(CreateDirectoryTool());
    _registerTool(DeleteTool());
    _registerTool(SearchFilesTool());
    _registerTool(SystemInfoTool());
    _registerTool(ListProcessesTool());
    _registerTool(GetProcessPathTool());
    _registerTool(KillProcessTool());
    _registerTool(DiskInfoTool());
    _registerTool(NetworkInfoTool());
    _registerTool(RunCommandTool());
    _registerTool(RunAdminCommandTool());
    _registerTool(OpenFileTool());
    _registerTool(LaunchAppTool());
    _registerTool(OpenUrlTool());
    _registerTool(ReadClipboardTool());
    _registerTool(WriteClipboardTool());
    _registerTool(SetTimerTool());
    _registerTool(ListTimersTool());
    _registerTool(CancelTimerTool());
    _registerTool(SaveMemoryTool());
    _registerTool(RecallMemoryTool());
    _registerTool(ListMemoriesTool());
    _registerTool(ForgetMemoryTool());
  }

  void _registerTool(Tool tool) {
    _tools[tool.name] = tool;
  }

  Tool? getTool(String name) => _tools[name];

  List<Tool> get allTools => _tools.values.toList();

  
  List<Map<String, dynamic>> getToolDeclarations() {
    return _tools.values.map((t) => t.toFunctionDeclaration()).toList();
  }

  
  Future<ToolResult> executeTool(String name, Map<String, dynamic> args) async {
    final tool = _tools[name];
    if (tool == null) {
      return ToolResult(success: false, message: 'Unknown tool: $name');
    }
    return await tool.execute(args);
  }
}
