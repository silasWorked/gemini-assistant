import 'package:flutter/services.dart';
import 'tool_base.dart';


class ReadClipboardTool extends Tool {
  @override
  String get name => 'read_clipboard';

  @override
  String get description => 'Read the current text content from the clipboard.';

  @override
  Map<String, dynamic> get parameters => {};

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null) {
        return ToolResult(
          success: true,
          message: 'Clipboard content retrieved',
          data: data!.text,
        );
      } else {
        return ToolResult(
          success: true,
          message: 'Clipboard is empty or contains non-text data',
          data: '',
        );
      }
    } catch (e) {
      return ToolResult(success: false, message: 'Error reading clipboard: $e');
    }
  }
}


class WriteClipboardTool extends Tool {
  @override
  String get name => 'write_clipboard';

  @override
  String get description => 'Write text content to the clipboard.';

  @override
  Map<String, dynamic> get parameters => {
    'text': {'type': 'string', 'description': 'Text to copy to clipboard'},
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final text = args['text'] as String;
      await Clipboard.setData(ClipboardData(text: text));
      return ToolResult(success: true, message: 'Text copied to clipboard');
    } catch (e) {
      return ToolResult(success: false, message: 'Error writing clipboard: $e');
    }
  }
}
