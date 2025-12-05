import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';


class TrayService {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  final SystemTray _systemTray = SystemTray();
  bool _initialized = false;
  VoidCallback? _onShowWindow;
  VoidCallback? _onExit;

  Future<void> initialize({
    VoidCallback? onShowWindow,
    VoidCallback? onExit,
  }) async {
    if (_initialized) return;

    _onShowWindow = onShowWindow;
    _onExit = onExit;

    
    await windowManager.ensureInitialized();

    
    final exePath = Platform.resolvedExecutable;
    final exeDir = exePath.substring(0, exePath.lastIndexOf('\\'));
    String iconPath = '$exeDir\\data\\flutter_assets\\assets\\app_icon.ico';

    
    if (!await File(iconPath).exists()) {
      final projectRoot = exeDir.replaceAll(
        '\\build\\windows\\x64\\runner\\Debug',
        '',
      );
      iconPath = '$projectRoot\\windows\\runner\\resources\\app_icon.ico';
    }

    
    await _systemTray.initSystemTray(
      title: 'Gemini Assistant',
      iconPath: iconPath,
      toolTip: 'Gemini AI Assistant',
    );

    
    final menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Открыть', onClicked: (item) => _showWindow()),
      MenuSeparator(),
      MenuItemLabel(label: 'Выход', onClicked: (item) => _exitApp()),
    ]);

    await _systemTray.setContextMenu(menu);

    
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        _showWindow();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });

    _initialized = true;
  }

  void _showWindow() {
    windowManager.show();
    windowManager.focus();
    _onShowWindow?.call();
  }

  void _exitApp() {
    _onExit?.call();
    _systemTray.destroy();
    exit(0);
  }

  
  Future<void> hideToTray() async {
    await windowManager.hide();
  }

  
  void destroy() {
    _systemTray.destroy();
  }
}


class TrayWindowListener extends WindowListener {
  final TrayService _trayService = TrayService();

  @override
  void onWindowClose() async {
    
    await _trayService.hideToTray();
  }
}
