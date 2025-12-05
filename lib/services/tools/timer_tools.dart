import 'dart:async';
import 'dart:io';
import 'tool_base.dart';


class TimerManager {
  static final TimerManager _instance = TimerManager._internal();
  factory TimerManager() => _instance;
  TimerManager._internal();

  final Map<String, _ActiveTimer> _timers = {};
  int _nextId = 1;

  String addTimer({
    required Duration duration,
    required String message,
    required Function(String) onComplete,
  }) {
    final id = 'timer_${_nextId++}';
    final endTime = DateTime.now().add(duration);

    final timer = Timer(duration, () {
      _showNotification(message);
      onComplete(message);
      _timers.remove(id);
    });

    _timers[id] = _ActiveTimer(
      id: id,
      message: message,
      endTime: endTime,
      timer: timer,
    );

    return id;
  }

  bool cancelTimer(String id) {
    final activeTimer = _timers[id];
    if (activeTimer != null) {
      activeTimer.timer.cancel();
      _timers.remove(id);
      return true;
    }
    return false;
  }

  List<Map<String, dynamic>> getActiveTimers() {
    final now = DateTime.now();
    return _timers.values.map((t) {
      final remaining = t.endTime.difference(now);
      return {
        'id': t.id,
        'message': t.message,
        'end_time': t.endTime.toIso8601String(),
        'remaining_seconds': remaining.inSeconds,
        'remaining_formatted': _formatDuration(remaining),
      };
    }).toList();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '0с';

    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}ч ${minutes}м ${seconds}с';
    } else if (minutes > 0) {
      return '${minutes}м ${seconds}с';
    } else {
      return '${seconds}с';
    }
  }

  void _showNotification(String message) {
    
    final script =
        '''
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

\$template = @"
<toast duration="long">
    <visual>
        <binding template="ToastText02">
            <text id="1">⏰ Таймер</text>
            <text id="2">$message</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.Reminder"/>
</toast>
"@

\$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
\$xml.LoadXml(\$template)
\$toast = [Windows.UI.Notifications.ToastNotification]::new(\$xml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("AI Assistant").Show(\$toast)
''';

    Process.run('powershell', ['-Command', script]);

    
    Process.run('powershell', [
      '-Command',
      '[System.Media.SystemSounds]::Exclamation.Play()',
    ]);
  }
}

class _ActiveTimer {
  final String id;
  final String message;
  final DateTime endTime;
  final Timer timer;

  _ActiveTimer({
    required this.id,
    required this.message,
    required this.endTime,
    required this.timer,
  });
}


class SetTimerTool extends Tool {
  final TimerManager _timerManager = TimerManager();
  Function(String)? onTimerComplete;

  @override
  String get name => 'set_timer';

  @override
  String get description =>
      'Sets a timer or reminder. When time is up, shows a notification. '
      'Use for reminders like "remind me in 5 minutes" or "set timer for 30 seconds".';

  @override
  Map<String, dynamic> get parameters => {
    'duration_seconds': {
      'type': 'integer',
      'description':
          'Duration in seconds. Examples: 60 for 1 minute, 300 for 5 minutes, 3600 for 1 hour.',
    },
    'message': {
      'type': 'string',
      'description':
          'Message to show when timer completes. Should describe what the reminder is for.',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    try {
      final seconds = args['duration_seconds'] as int;
      final message = args['message'] as String? ?? 'Таймер завершён!';

      if (seconds <= 0) {
        return ToolResult(
          success: false,
          message: 'Error: Duration must be positive',
        );
      }

      if (seconds > 86400) {
        return ToolResult(
          success: false,
          message: 'Error: Maximum timer duration is 24 hours (86400 seconds)',
        );
      }

      final duration = Duration(seconds: seconds);
      final id = _timerManager.addTimer(
        duration: duration,
        message: message,
        onComplete: onTimerComplete ?? (_) {},
      );

      final endTime = DateTime.now().add(duration);
      final formatted = _formatDuration(duration);

      return ToolResult(
        success: true,
        message:
            'Timer set successfully!\n'
            'ID: $id\n'
            'Duration: $formatted\n'
            'Message: $message\n'
            'Will complete at: ${_formatTime(endTime)}',
      );
    } catch (e) {
      return ToolResult(success: false, message: 'Error setting timer: $e');
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('$hours ч');
    if (minutes > 0) parts.add('$minutes мин');
    if (seconds > 0) parts.add('$seconds сек');

    return parts.isEmpty ? '0 сек' : parts.join(' ');
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}


class ListTimersTool extends Tool {
  final TimerManager _timerManager = TimerManager();

  @override
  String get name => 'list_timers';

  @override
  String get description =>
      'Lists all active timers and reminders with their remaining time.';

  @override
  Map<String, dynamic> get parameters => {};

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    final timers = _timerManager.getActiveTimers();

    if (timers.isEmpty) {
      return ToolResult(success: true, message: 'No active timers.');
    }

    final buffer = StringBuffer('Active timers:\n\n');
    for (final t in timers) {
      buffer.writeln('ID: ${t['id']}');
      buffer.writeln('Message: ${t['message']}');
      buffer.writeln('Remaining: ${t['remaining_formatted']}');
      buffer.writeln('Ends at: ${t['end_time']}');
      buffer.writeln();
    }

    return ToolResult(success: true, message: buffer.toString());
  }
}


class CancelTimerTool extends Tool {
  final TimerManager _timerManager = TimerManager();

  @override
  String get name => 'cancel_timer';

  @override
  String get description => 'Cancels an active timer by its ID.';

  @override
  Map<String, dynamic> get parameters => {
    'timer_id': {
      'type': 'string',
      'description': 'The ID of the timer to cancel (e.g., "timer_1").',
    },
  };

  @override
  Future<ToolResult> execute(Map<String, dynamic> args) async {
    final timerId = args['timer_id'] as String?;

    if (timerId == null || timerId.isEmpty) {
      return ToolResult(success: false, message: 'Error: timer_id is required');
    }

    final success = _timerManager.cancelTimer(timerId);

    if (success) {
      return ToolResult(
        success: true,
        message: 'Timer $timerId cancelled successfully.',
      );
    } else {
      return ToolResult(
        success: false,
        message:
            'Timer $timerId not found. Use list_timers to see active timers.',
      );
    }
  }
}
