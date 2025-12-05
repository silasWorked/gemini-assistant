import 'dart:io';
import 'tool_base.dart';


class ReadFileTool extends Tool {
  @override
  String get name => 'read_file';

  @override
  String get description =>
      'Read the contents of a file. Use this to view text files, code, configs, etc.';

  @override
  Map<String, dynamic> get parameters => {
    'path': {
      'type': 'string',
      'description': 'Absolute path to the file to read',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;
      final file = File(path);

      if (!await file.exists()) {
        return ToolResult(success: false, message: 'File not found: $path');
      }

      final content = await file.readAsString();
      return ToolResult(
        success: true,
        message: 'File read successfully',
        data: content,
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error reading file: $e');
    }
  }
}


class WriteFileTool extends Tool {
  @override
  String get name => 'write_file';

  @override
  String get description =>
      'Write content to a file. Creates the file if it does not exist, overwrites if it does. Always use absolute Windows paths with backslashes.';

  @override
  Map<String, dynamic> get parameters => {
    'path': {
      'type': 'string',
      'description':
          'Absolute path to the file to write (e.g., C:\\Users\\User\\Desktop\\file.txt)',
    },
    'content': {
      'type': 'string',
      'description': 'Content to write to the file',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String?;
      final content = args['content'] as String?;

      if (path == null || path.isEmpty) {
        return ToolResult(
          success: false,
          message: 'Path is required. Please provide an absolute path.',
        );
      }

      if (content == null) {
        return ToolResult(success: false, message: 'Content is required.');
      }

      final file = File(path);

      
      await file.parent.create(recursive: true);
      await file.writeAsString(content);

      
      if (await file.exists()) {
        final size = await file.length();
        return ToolResult(
          success: true,
          message: 'File created successfully at: $path (${size} bytes)',
          data: {'path': path, 'size': size},
        );
      } else {
        return ToolResult(
          success: false,
          message: 'File was not created for unknown reason',
        );
      }
    } catch (e) {
      return ToolResult(success: false, message: 'Error writing file: $e');
    }
  }
}


class ListDirectoryTool extends Tool {
  @override
  String get name => 'list_directory';

  @override
  String get description =>
      'List all files and folders in a directory. Returns names with [DIR] prefix for directories.';

  @override
  Map<String, dynamic> get parameters => {
    'path': {
      'type': 'string',
      'description': 'Absolute path to the directory to list',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;
      final dir = Directory(path);

      if (!await dir.exists()) {
        return ToolResult(
          success: false,
          message: 'Directory not found: $path',
        );
      }

      final entries = await dir.list().toList();
      final items = <String>[];

      for (final entry in entries) {
        final name = entry.path.split(Platform.pathSeparator).last;
        if (entry is Directory) {
          items.add('[DIR] $name');
        } else {
          items.add(name);
        }
      }

      items.sort();
      return ToolResult(
        success: true,
        message: 'Found ${items.length} items',
        data: items.join('\n'),
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error listing directory: $e');
    }
  }
}


class CreateDirectoryTool extends Tool {
  @override
  String get name => 'create_directory';

  @override
  String get description =>
      'Create a new directory. Creates parent directories if needed.';

  @override
  Map<String, dynamic> get parameters => {
    'path': {
      'type': 'string',
      'description': 'Absolute path of the directory to create',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;
      final dir = Directory(path);

      await dir.create(recursive: true);
      return ToolResult(success: true, message: 'Directory created: $path');
    } catch (e) {
      return ToolResult(
        success: false,
        message: 'Error creating directory: $e',
      );
    }
  }
}


class DeleteTool extends Tool {
  @override
  String get name => 'delete';

  @override
  String get description =>
      'Delete a file or directory. For directories, deletes recursively.';

  @override
  Map<String, dynamic> get parameters => {
    'path': {
      'type': 'string',
      'description': 'Absolute path to the file or directory to delete',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final path = args['path'] as String;

      if (await FileSystemEntity.isDirectory(path)) {
        await Directory(path).delete(recursive: true);
      } else if (await File(path).exists()) {
        await File(path).delete();
      } else {
        return ToolResult(success: false, message: 'Path not found: $path');
      }

      return ToolResult(success: true, message: 'Deleted: $path');
    } catch (e) {
      return ToolResult(success: false, message: 'Error deleting: $e');
    }
  }
}


class SearchFilesTool extends Tool {
  @override
  String get name => 'search_files';

  @override
  String get description =>
      'Search for files by name pattern in a directory (recursive). Use * as wildcard. Limited to 100 results and 30 seconds timeout. Avoid searching in large system directories like Program Files.';

  @override
  Map<String, dynamic> get parameters => {
    'directory': {
      'type': 'string',
      'description':
          'Directory to search in. Avoid large directories like C:\\Program Files',
    },
    'pattern': {
      'type': 'string',
      'description':
          'File name pattern to search for (e.g., "*.txt", "report*")',
    },
    'max_results': {
      'type': 'integer',
      'description': 'Maximum number of results to return (default: 50)',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final directory = args['directory'] as String;
      final pattern = args['pattern'] as String;
      final maxResults = (args['max_results'] as int?) ?? 50;
      final dir = Directory(directory);

      if (!await dir.exists()) {
        return ToolResult(
          success: false,
          message: 'Directory not found: $directory',
        );
      }

      
      final lowerPath = directory.toLowerCase();
      if (lowerPath.contains('program files') ||
          lowerPath.contains('windows') ||
          lowerPath == 'c:\\') {
        return ToolResult(
          success: false,
          message:
              'Searching in system directories (Program Files, Windows, C:\\) is not recommended due to size. Please specify a more specific path.',
        );
      }

      
      final regexPattern = pattern
          .replaceAll('.', r'\.')
          .replaceAll('*', '.*')
          .replaceAll('?', '.');
      final regex = RegExp(regexPattern, caseSensitive: false);

      final results = <String>[];
      var scannedCount = 0;
      const maxScan = 10000; 

      try {
        await for (final entity in dir.list(recursive: true)) {
          scannedCount++;

          
          if (scannedCount > maxScan) {
            break;
          }

          if (entity is File) {
            final name = entity.path.split(Platform.pathSeparator).last;
            if (regex.hasMatch(name)) {
              results.add(entity.path);
              if (results.length >= maxResults) {
                break;
              }
            }
          }
        }
      } catch (e) {
        
        if (results.isNotEmpty) {
          return ToolResult(
            success: true,
            message:
                'Found ${results.length} files (search stopped due to permission errors)',
            data: results.join('\n'),
          );
        }
        rethrow;
      }

      final truncated = results.length >= maxResults || scannedCount >= maxScan;
      return ToolResult(
        success: true,
        message: truncated
            ? 'Found ${results.length} files (results limited, scanned $scannedCount items)'
            : 'Found ${results.length} files (scanned $scannedCount items)',
        data: results.isEmpty
            ? 'No files found matching pattern'
            : results.join('\n'),
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error searching files: $e');
    }
  }
}
