import 'dart:io';
import 'tool_base.dart';

class SystemInfoTool extends Tool {
  @override
  String get name => 'system_info';

  @override
  String get description =>
      'Get information about the operating system and hardware.';

  @override
  Map<String, dynamic> get parameters => {};

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final info = StringBuffer();
      info.writeln('Operating System: ${Platform.operatingSystem}');
      info.writeln('OS Version: ${Platform.operatingSystemVersion}');
      info.writeln('Hostname: ${Platform.localHostname}');
      info.writeln('Number of Processors: ${Platform.numberOfProcessors}');
      info.writeln('Locale: ${Platform.localeName}');
      info.writeln('Dart Version: ${Platform.version}');

      final home =
          Platform.environment['USERPROFILE'] ??
          Platform.environment['HOME'] ??
          'Unknown';
      info.writeln('User Home: $home');

      return ToolResult(
        success: true,
        message: 'System information retrieved',
        data: info.toString(),
      );
    } catch (e) {
      return ToolResult(
        success: false,
        message: 'Error getting system info: $e',
      );
    }
  }
}

class ListProcessesTool extends Tool {
  @override
  String get name => 'list_processes';

  @override
  String get description =>
      'List running processes on the system. Shows process name and PID.';

  @override
  Map<String, dynamic> get parameters => {};

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('tasklist', [
          '/FO',
          'CSV',
          '/NH',
        ], runInShell: true);
      } else {
        result = await Process.run('ps', ['aux'], runInShell: true);
      }

      if (result.exitCode != 0) {
        return ToolResult(
          success: false,
          message: 'Error listing processes: ${result.stderr}',
        );
      }

      return ToolResult(
        success: true,
        message: 'Processes listed',
        data: result.stdout,
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error listing processes: $e');
    }
  }
}

class GetProcessPathTool extends Tool {
  @override
  String get name => 'get_process_path';

  @override
  String get description =>
      'Get the executable file path of a running process by its name. Useful to find where a program is installed.';

  @override
  Map<String, dynamic> get parameters => {
    'process_name': {
      'type': 'string',
      'description': 'Name of the process (e.g., "chrome.exe", "notepad.exe")',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final processName = args['process_name'] as String;

      final nameWithoutExt = processName.replaceAll(
        RegExp(r'\.exe$', caseSensitive: false),
        '',
      );

      if (Platform.isWindows) {
        final result = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          "Get-Process -Name '$nameWithoutExt' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path | Sort-Object -Unique",
        ], runInShell: true);

        final output = result.stdout.toString().trim();

        if (output.isEmpty) {
          return ToolResult(
            success: false,
            message:
                'Process "$processName" not found or path not available. Make sure the process is running.',
          );
        }

        final paths = output
            .split('\n')
            .map((line) => line.trim())
            .where((path) => path.isNotEmpty)
            .toSet()
            .toList();

        return ToolResult(
          success: true,
          message: 'Found ${paths.length} instance(s) of $processName',
          data: paths.join('\n'),
        );
      } else {
        final result = await Process.run('ps', [
          '-eo',
          'comm,args',
        ], runInShell: true);
        return ToolResult(
          success: true,
          message: 'Process paths',
          data: result.stdout,
        );
      }
    } catch (e) {
      return ToolResult(
        success: false,
        message: 'Error getting process path: $e',
      );
    }
  }
}

class KillProcessTool extends Tool {
  @override
  String get name => 'kill_process';

  @override
  String get description => 'Terminate a process by its PID.';

  @override
  Map<String, dynamic> get parameters => {
    'pid': {'type': 'integer', 'description': 'Process ID to terminate'},
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final pid = args['pid'] as int;
      final killed = Process.killPid(pid);

      if (killed) {
        return ToolResult(success: true, message: 'Process $pid terminated');
      } else {
        return ToolResult(
          success: false,
          message: 'Could not terminate process $pid',
        );
      }
    } catch (e) {
      return ToolResult(success: false, message: 'Error killing process: $e');
    }
  }
}

class DiskInfoTool extends Tool {
  @override
  String get name => 'disk_info';

  @override
  String get description => 'Get disk space information for all drives.';

  @override
  Map<String, dynamic> get parameters => {};

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('powershell', [
          '-Command',
          'Get-Volume | Where-Object { \$_.DriveLetter } | Select-Object DriveLetter, @{N=\"SizeGB\";E={[math]::Round(\$_.Size/1GB,2)}}, @{N=\"FreeGB\";E={[math]::Round(\$_.SizeRemaining/1GB,2)}}, @{N=\"UsedPercent\";E={[math]::Round(100-(\$_.SizeRemaining/\$_.Size*100),1)}} | Format-Table -AutoSize | Out-String',
        ], runInShell: true);
      } else {
        result = await Process.run('df', ['-h'], runInShell: true);
      }

      if (result.exitCode != 0) {
        return ToolResult(
          success: false,
          message: 'Error getting disk info: ${result.stderr}',
        );
      }

      return ToolResult(
        success: true,
        message: 'Disk information retrieved',
        data: result.stdout,
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error getting disk info: $e');
    }
  }
}

class NetworkInfoTool extends Tool {
  @override
  String get name => 'network_info';

  @override
  String get description =>
      'Get network interface information and IP addresses.';

  @override
  Map<String, dynamic> get parameters => {};

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final interfaces = await NetworkInterface.list();
      final info = StringBuffer();

      for (final interface in interfaces) {
        info.writeln('Interface: ${interface.name}');
        for (final addr in interface.addresses) {
          info.writeln('  ${addr.type.name}: ${addr.address}');
        }
        info.writeln();
      }

      return ToolResult(
        success: true,
        message: 'Network information retrieved',
        data: info.toString(),
      );
    } catch (e) {
      return ToolResult(
        success: false,
        message: 'Error getting network info: $e',
      );
    }
  }
}
