
abstract class Tool {
  String get name;
  String get description;
  Map<String, dynamic> get parameters;

  Future<ToolResult> execute(Map<String, dynamic> args);

  Map<String, dynamic> toFunctionDeclaration() {
    return {
      'name': name,
      'description': description,
      'parameters': {
        'type': 'object',
        'properties': parameters,
        'required': parameters.keys.toList(),
      },
    };
  }
}

class ToolResult {
  final bool success;
  final String message;
  final dynamic data;

  ToolResult({required this.success, required this.message, this.data});

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (data != null) 'data': data,
    };
  }
}
