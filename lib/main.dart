import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'screens/chat_screen.dart';
import 'services/tray_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      title: 'Gemini Assistant',
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setPreventClose(true);
    });
  }

  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final TrayService _trayService = TrayService();

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      windowManager.addListener(this);
      _initTray();
    }
  }

  Future<void> _initTray() async {
    await _trayService.initialize(
      onShowWindow: () {
        windowManager.show();
        windowManager.focus();
      },
      onExit: () {
        _trayService.destroy();
      },
    );
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      windowManager.removeListener(this);
      _trayService.destroy();
    }
    super.dispose();
  }

  @override
  void onWindowClose() async {
    
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Consumer<ChatViewModel>(
        builder: (context, viewModel, _) {
          final locale = viewModel.language == AppLanguage.en
              ? const Locale('en')
              : const Locale('ru');

          return MaterialApp(
            title: 'AI Assistant',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [Locale('ru'), Locale('en')],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              fontFamily: 'Segoe UI',

              
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF6366F1), 
                secondary: Color(0xFF8B5CF6), 
                tertiary: Color(0xFF22C55E), 
                surface: Color(0xFF1A1A2E), 
                background: Color(0xFF0F0F1E), 
                onPrimary: Colors.white,
                onSurface: Color(0xFFFFFFFF),
                surfaceContainer: Color(0xFF2A2A3A),
                outline: Color(0xFF3A3A4A),
              ),

              scaffoldBackgroundColor: const Color(0xFF0F0F1E),

              
              textTheme: const TextTheme(
                bodyMedium: TextStyle(fontSize: 14.0, letterSpacing: 0.2),
                titleLarge: TextStyle(fontWeight: FontWeight.w600),
              ),

              
              appBarTheme: const AppBarTheme(
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Color(0xFF1A1A2E),
                foregroundColor: Color(0xFFFFFFFF),
                centerTitle: false,
                titleTextStyle: TextStyle(
                  fontFamily: 'Segoe UI',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              
              cardTheme: CardThemeData(
                elevation: 0,
                color: const Color(0xFF2A2A3A),
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF3A3A4A), width: 1),
                ),
              ),

              
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF2A2A3A),
                hintStyle: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF3A3A4A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
                ),
              ),

              
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Segoe UI',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),

              
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),

              
              iconButtonTheme: IconButtonThemeData(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(
                    const Color(0xFFF0F0F0),
                  ),
                  overlayColor: WidgetStateProperty.all(
                    const Color(0xFFFFFFFF).withOpacity(0.1),
                  ),
                  padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
                ),
              ),

              
              dividerTheme: const DividerThemeData(
                color: Color(0xFF3A3A4A),
                thickness: 1,
                space: 1,
              ),

              
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(const Color(0xFF555555)),
                radius: const Radius.circular(4),
                thickness: WidgetStateProperty.all(4),
                interactive: true,
              ),
            ),
            themeMode: ThemeMode.dark,
            home: const ChatScreen(),
          );
        },
      ),
    );
  }
}
