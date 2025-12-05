import 'dart:io';
import 'tool_base.dart';


class RunCommandTool extends Tool {
  @override
  String get name => 'run_command';

  @override
  String get description =>
      'Execute a shell command (PowerShell on Windows, bash on Linux/Mac). Returns stdout and stderr.';

  @override
  Map<String, dynamic> get parameters => {
    'command': {'type': 'string', 'description': 'The command to execute'},
    'working_directory': {
      'type': 'string',
      'description': 'Working directory for the command (optional)',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final command = args['command'] as String;
      final workingDir = args['working_directory'] as String?;

      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run(
          'powershell',
          ['-Command', command],
          workingDirectory: workingDir,
          runInShell: true,
        );
      } else {
        result = await Process.run(
          'bash',
          ['-c', command],
          workingDirectory: workingDir,
          runInShell: true,
        );
      }

      final output = StringBuffer();
      if (result.stdout.toString().isNotEmpty) {
        output.writeln('STDOUT:');
        output.writeln(result.stdout);
      }
      if (result.stderr.toString().isNotEmpty) {
        output.writeln('STDERR:');
        output.writeln(result.stderr);
      }
      output.writeln('Exit code: ${result.exitCode}');

      return ToolResult(
        success: result.exitCode == 0,
        message: result.exitCode == 0
            ? 'Command executed successfully'
            : 'Command failed',
        data: output.toString(),
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error running command: $e');
    }
  }
}


class OpenFileTool extends Tool {
  @override
  String get name => 'open_file';

  @override
  String get description =>
      'Open a file with its default associated application.';

  @override
  Map<String, dynamic> get parameters => {
    'path': {'type': 'string', 'description': 'Path to the file to open'},
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;

      if (!await File(path).exists() && !await Directory(path).exists()) {
        return ToolResult(success: false, message: 'Path not found: $path');
      }

      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('start', ['', path], runInShell: true);
      } else if (Platform.isMacOS) {
        result = await Process.run('open', [path]);
      } else {
        result = await Process.run('xdg-open', [path]);
      }

      return ToolResult(
        success: result.exitCode == 0,
        message: result.exitCode == 0
            ? 'File opened successfully'
            : 'Failed to open file',
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error opening file: $e');
    }
  }
}


class LaunchAppTool extends Tool {
  @override
  String get name => 'launch_app';

  @override
  String get description =>
      'Launch an application by name or path. On Windows, can use app name like "notepad", "calc", etc.';

  @override
  Map<String, dynamic> get parameters => {
    'app': {
      'type': 'string',
      'description': 'Application name or path to launch',
    },
    'arguments': {
      'type': 'string',
      'description': 'Arguments to pass to the application (optional)',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final app = args['app'] as String;
      final arguments = args['arguments'] as String? ?? '';

      final argList = arguments.isNotEmpty ? arguments.split(' ') : <String>[];

      final process = await Process.start(
        app,
        argList,
        mode: ProcessStartMode.detached,
      );

      return ToolResult(
        success: true,
        message: 'Application launched: $app (PID: ${process.pid})',
        data: {'pid': process.pid},
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error launching app: $e');
    }
  }
}


class OpenUrlTool extends Tool {
  @override
  String get name => 'open_url';

  @override
  String get description => 'Open a URL in the default web browser.';

  @override
  Map<String, dynamic> get parameters => {
    'url': {'type': 'string', 'description': 'URL to open'},
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final url = args['url'] as String;

      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('start', [url], runInShell: true);
      } else if (Platform.isMacOS) {
        result = await Process.run('open', [url]);
      } else {
        result = await Process.run('xdg-open', [url]);
      }

      return ToolResult(
        success: result.exitCode == 0,
        message: result.exitCode == 0
            ? 'URL opened in browser'
            : 'Failed to open URL',
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error opening URL: $e');
    }
  }
}


class RunAdminCommandTool extends Tool {
  @override
  String get name => 'run_admin_command';

  @override
  String get description =>
      'Open an elevated (administrator) PowerShell or CMD window for the user. Windows only. Shows UAC prompt.';

  @override
  Map<String, dynamic> get parameters => {
    'shell': {
      'type': 'string',
      'description':
          'Shell to open: "powershell" or "cmd" (default: powershell)',
    },
    'command': {
      'type': 'string',
      'description':
          'Optional command to run in the admin shell. If empty, just opens the shell.',
    },
    'keep_open': {
      'type': 'boolean',
      'description':
          'Keep the window open after command completes (default: true)',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      if (!Platform.isWindows) {
        return ToolResult(
          success: false,
          message: 'Admin command execution is only supported on Windows',
        );
      }

      final shell = (args['shell'] as String?) ?? 'powershell';
      final command = args['command'] as String? ?? '';
      final keepOpen = args['keep_open'] as bool? ?? true;

      String executable;
      List<String> shellArgs;

      if (shell.toLowerCase() == 'cmd') {
        executable = 'cmd.exe';
        if (command.isEmpty) {
          shellArgs = [];
        } else if (keepOpen) {
          shellArgs = ['/k', command];
        } else {
          shellArgs = ['/c', command];
        }
      } else {
        executable = 'powershell.exe';
        if (command.isEmpty) {
          shellArgs = ['-NoExit'];
        } else if (keepOpen) {
          shellArgs = ['-NoExit', '-Command', command];
        } else {
          shellArgs = ['-Command', command];
        }
      }

      
      final argsString = shellArgs.isEmpty
          ? ''
          : shellArgs.map((a) => a.contains(' ') ? "'$a'" : a).join(' ');

      final result = await Process.run('powershell', [
        '-Command',
        'Start-Process',
        executable,
        if (argsString.isNotEmpty) ...['-ArgumentList', '"$argsString"'],
        '-Verb',
        'RunAs',
      ], runInShell: true);

      if (result.exitCode == 0) {
        return ToolResult(
          success: true,
          message: command.isEmpty
              ? 'Открыто окно $shell с правами администратора'
              : 'Открыто окно $shell с правами администратора и выполнена команда',
        );
      } else {
        return ToolResult(
          success: false,
          message:
              'Не удалось открыть консоль администратора. Возможно, пользователь отменил UAC.',
        );
      }
    } catch (e) {
      return ToolResult(success: false, message: 'Error: $e');
    }
  }
}
