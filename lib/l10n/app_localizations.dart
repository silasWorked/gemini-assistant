import 'package:flutter/material.dart';

enum AppLanguage { ru, en }

class AppLocalizations {
  final AppLanguage language;

  AppLocalizations(this.language);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(AppLanguage.ru);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  
  String get appTitle => _t('AI Ассистент', 'AI Assistant');
  String get newChat => _t('Новый чат', 'New Chat');
  String get settings => _t('Настройки', 'Settings');
  String get tools => _t('Инструменты', 'Tools');
  String get memory => _t('Память AI', 'AI Memory');
  String get history => _t('ИСТОРИЯ', 'HISTORY');
  String get noChats => _t('Нет чатов', 'No chats');
  String get cancel => _t('Отмена', 'Cancel');
  String get save => _t('Сохранить', 'Save');
  String get delete => _t('Удалить', 'Delete');
  String get close => _t('Закрыть', 'Close');
  String get yes => _t('Да', 'Yes');
  String get no => _t('Нет', 'No');
  String get error => _t('Ошибка', 'Error');
  String get success => _t('Успешно', 'Success');
  String get loading => _t('Загрузка...', 'Loading...');
  String get copied => _t('Скопировано', 'Copied');

  
  String get clearChat => _t('Очистить чат', 'Clear chat');
  String get typeMessage => _t('Напишите сообщение...', 'Type a message...');
  String get thinking => _t('Думаю...', 'Thinking...');
  String get welcomeMessage => _t(
    'Привет! Я AI ассистент с доступом к вашему компьютеру. Чем могу помочь?',
    'Hello! I\'m an AI assistant with access to your computer. How can I help?',
  );
  String get collapseSidebar => _t('Свернуть панель', 'Collapse sidebar');
  String get expandSidebar => _t('Развернуть панель', 'Expand sidebar');

  
  String get apiKey => _t('API Ключ', 'API Key');
  String get enterApiKey => _t('Введите API ключ', 'Enter API key');
  String get apiKeyHint =>
      _t('Ваш Google AI API ключ', 'Your Google AI API key');
  String get apiKeyRequired => _t('API ключ обязателен', 'API key is required');
  String get apiKeyConfigured => _t('Ключ настроен', 'Key configured');
  String get apiKeyNotConfigured =>
      _t('Ключ не настроен', 'Key not configured');
  String get apiKeySetup => _t('Настройка API ключа', 'API Key Setup');
  String get apiKeySetupDesc => _t(
    'Введите ваш Google Gemini API ключ.\nПолучить можно на: ai.google.dev',
    'Enter your Google Gemini API key.\nGet one at: ai.google.dev',
  );
  String get invalidApiKey => _t('Неверный API ключ', 'Invalid API key');
  String get getApiKey => _t('Получить ключ', 'Get key');
  String get change => _t('Изменить', 'Change');
  String get configure => _t('Настроить', 'Configure');
  String get configureApiKey => _t('Настройте API ключ', 'Configure API Key');
  String get apiKeyRequiredDesc => _t(
    'Для начала работы требуется Google Gemini API ключ',
    'Google Gemini API key is required to start',
  );
  String get howCanIHelp => _t('Чем могу помочь?', 'How can I help?');
  String get assistantDescription => _t(
    'Я ваш AI-ассистент. Я могу писать код, отвечать на вопросы, анализировать изображения и помогать с творческими задачами.',
    'I\'m your AI assistant. I can write code, answer questions, analyze images, and help with creative tasks.',
  );
  String get appearance => _t('Внешний вид', 'Appearance');
  String get languageLabel => _t('Язык', 'Language');
  String get russian => _t('Русский', 'Russian');
  String get english => _t('English', 'English');
  String get animations => _t('Анимации', 'Animations');
  String get animationsDesc =>
      _t('Плавные переходы и эффекты', 'Smooth transitions and effects');
  String get on => _t('Вкл', 'On');
  String get off => _t('Выкл', 'Off');
  String get proxy => _t('Прокси', 'Proxy');
  String get proxyHost => _t('Хост', 'Host');
  String get proxyPort => _t('Порт', 'Port');
  String get proxyUsername => _t('Логин', 'Username');
  String get proxyPassword => _t('Пароль', 'Password');
  String get proxyEnabled => _t('Использовать прокси', 'Use proxy');
  String get checkProxy => _t('Проверить', 'Check');
  String get proxyWorking => _t('Прокси работает ✓', 'Proxy is working ✓');
  String get proxyNotWorking => _t('Прокси не работает', 'Proxy not working');
  String get proxyHostRequired =>
      _t('Укажите хост прокси', 'Specify proxy host');
  String get connectionFailed =>
      _t('Не удалось подключиться', 'Connection failed');
  String get httpError => _t('Ошибка HTTP', 'HTTP error');
  String get httpProxy => _t('HTTP Прокси', 'HTTP Proxy');
  String get notConfigured => _t('Не настроен', 'Not configured');
  String get hostNotSpecified => _t('Хост не указан', 'Host not specified');
  String get auth => _t('Авторизация', 'Authorization');
  String get loginOptional => _t('Логин (опц.)', 'Login (opt.)');
  String get passwordOptional => _t('Пароль (опц.)', 'Password (opt.)');
  String get checking => _t('Проверка...', 'Checking...');

  
  String get toolsAI => _t('Инструменты AI', 'AI Tools');
  String get toolsEnabled => _t('Инструменты включены', 'Tools enabled');
  String get toolsDisabled => _t('Инструменты выключены', 'Tools disabled');
  String get toolsDescription => _t(
    'AI может выполнять действия на вашем компьютере',
    'AI can perform actions on your computer',
  );

  
  String get fileSystem => _t('Файловая система', 'File System');
  String get fileSystemDesc =>
      _t('Работа с файлами и папками', 'Work with files and folders');
  String get systemCategory => _t('Система', 'System');
  String get systemDesc =>
      _t('Информация и процессы', 'Information and processes');
  String get commandsCategory => _t('Команды', 'Commands');
  String get commandsDesc =>
      _t('Выполнение команд и запуск программ', 'Run commands and launch apps');
  String get clipboardCategory => _t('Буфер обмена', 'Clipboard');
  String get clipboardDesc =>
      _t('Чтение и запись в буфер', 'Read and write to clipboard');
  String get timersCategory => _t('Таймеры', 'Timers');
  String get timersDesc => _t('Таймеры и напоминания', 'Timers and reminders');
  String get memoryCategory => _t('Память', 'Memory');
  String get memoryDesc => _t('Запоминание информации', 'Remember information');

  
  String get descReadFile => _t('Чтение файлов', 'Read files');
  String get descWriteFile => _t('Запись файлов', 'Write files');
  String get descListDir => _t('Список папки', 'List directory');
  String get descCreateDir => _t('Создание папок', 'Create directories');
  String get descDelete => _t('Удаление', 'Delete');
  String get descSearchFiles => _t('Поиск файлов', 'Search files');
  String get descSystemInfo => _t('Инфо о системе', 'System info');
  String get descDiskInfo => _t('Инфо о дисках', 'Disk info');
  String get descNetworkInfo => _t('Сеть и IP', 'Network and IP');
  String get descListProcesses => _t('Список процессов', 'List processes');
  String get descProcessPath => _t('Путь процесса', 'Process path');
  String get descKillProcess => _t('Завершить процесс', 'Kill process');
  String get descRunCommand => _t('Команда PowerShell', 'PowerShell command');
  String get descRunAdmin => _t('Команда от админа', 'Admin command');
  String get descLaunchApp => _t('Запуск приложения', 'Launch app');
  String get descOpenFile => _t('Открыть файл', 'Open file');
  String get descOpenUrl => _t('Открыть URL', 'Open URL');
  String get descReadClipboard => _t('Читать буфер', 'Read clipboard');
  String get descWriteClipboard => _t('Записать в буфер', 'Write to clipboard');
  String get descSetTimer => _t('Установить таймер', 'Set timer');
  String get descListTimers => _t('Список таймеров', 'List timers');
  String get descCancelTimer => _t('Отменить таймер', 'Cancel timer');
  String get descSaveMemory => _t('Сохранить информацию', 'Save information');
  String get descRecallMemory =>
      _t('Вспомнить информацию', 'Recall information');
  String get descListMemories => _t('Список сохранённого', 'List saved');
  String get descForgetMemory => _t('Забыть информацию', 'Forget information');

  
  String get securityTitle => _t('Безопасность', 'Security');
  String get securityText => _t(
    'AI будет спрашивать подтверждение перед опасными операциями (удаление, завершение процессов)',
    'AI will ask for confirmation before dangerous operations (deletion, killing processes)',
  );

  String get warningTitle => _t('⚠️ Предупреждение', '⚠️ Warning');
  String get warningText => _t(
    'AI может выполнять команды на вашем компьютере. Будьте осторожны с запросами на удаление файлов или изменение системы.',
    'AI can execute commands on your computer. Be careful with requests to delete files or modify the system.',
  );

  
  String get memoryEmpty => _t('Память пуста', 'Memory is empty');
  String get memoryEmptyHint =>
      _t('Попросите AI запомнить что-нибудь', 'Ask AI to remember something');
  String get savedInfo => _t('Сохранённая информация', 'Saved information');
  String get allTypes => _t('Все типы', 'All types');
  String get deleteMemory => _t('Удалить запись?', 'Delete entry?');
  String get deleteMemoryConfirm =>
      _t('Удалить из памяти?', 'Delete from memory?');
  String get copiedToClipboard =>
      _t('Скопировано в буфер', 'Copied to clipboard');
  String get created => _t('Создано', 'Created');
  String get used => _t('Использовано', 'Used');
  String get times => _t('раз', 'times');
  String get copy => _t('Копировать', 'Copy');

  String entriesCount(int count) {
    if (language == AppLanguage.en) {
      return count == 1 ? 'entry' : 'entries';
    }
    
    if (count % 10 == 1 && count % 100 != 11) return 'запись';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20))
      return 'записи';
    return 'записей';
  }

  
  String get typePath => _t('Путь', 'Path');
  String get typeCommand => _t('Команда', 'Command');
  String get typePreference => _t('Настройка', 'Preference');
  String get typeFact => _t('Факт', 'Fact');
  String get typeShortcut => _t('Ярлык', 'Shortcut');
  String get typeProject => _t('Проект', 'Project');
  String get typeOther => _t('Другое', 'Other');

  
  String get trayOpen => _t('Открыть', 'Open');
  String get trayExit => _t('Выход', 'Exit');

  
  String get proxySetupTitle => _t('Настройка прокси', 'Proxy Setup');
  String get proxySetupDesc => _t(
    'Похоже, вы находитесь в регионе, где Google API может быть недоступен. Рекомендуем настроить прокси.',
    'It looks like you\'re in a region where Google API might be unavailable. We recommend setting up a proxy.',
  );
  String get skip => _t('Пропустить', 'Skip');
  String get apply => _t('Применить', 'Apply');

  
  String get toolReadFile => _t('Читать файл', 'Read file');
  String get toolWriteFile => _t('Записать файл', 'Write file');
  String get toolListDir => _t('Список файлов', 'List directory');
  String get toolCreateDir => _t('Создать папку', 'Create directory');
  String get toolDelete => _t('Удалить', 'Delete');
  String get toolSearch => _t('Поиск файлов', 'Search files');
  String get toolSystemInfo => _t('Инфо о системе', 'System info');
  String get toolProcesses => _t('Список процессов', 'List processes');
  String get toolProcessPath => _t('Путь процесса', 'Process path');
  String get toolKillProcess => _t('Завершить процесс', 'Kill process');
  String get toolDiskInfo => _t('Инфо о дисках', 'Disk info');
  String get toolNetworkInfo => _t('Инфо о сети', 'Network info');
  String get toolRunCommand => _t('Выполнить команду', 'Run command');
  String get toolRunAdmin => _t('Команда от админа', 'Admin command');
  String get toolOpenFile => _t('Открыть файл', 'Open file');
  String get toolLaunchApp => _t('Запустить приложение', 'Launch app');
  String get toolOpenUrl => _t('Открыть URL', 'Open URL');
  String get toolReadClipboard => _t('Читать буфер', 'Read clipboard');
  String get toolWriteClipboard => _t('Записать в буфер', 'Write clipboard');
  String get toolSetTimer => _t('Установить таймер', 'Set timer');
  String get toolListTimers => _t('Список таймеров', 'List timers');
  String get toolCancelTimer => _t('Отменить таймер', 'Cancel timer');
  String get toolSaveMemory => _t('Сохранить в память', 'Save to memory');
  String get toolRecallMemory => _t('Вспомнить', 'Recall');
  String get toolListMemories => _t('Список памяти', 'List memories');
  String get toolForgetMemory => _t('Забыть', 'Forget');

  
  String memoryTypeName(String type) {
    switch (type) {
      case 'filePath':
        return typePath;
      case 'command':
        return typeCommand;
      case 'preference':
        return typePreference;
      case 'fact':
        return typeFact;
      case 'shortcut':
        return typeShortcut;
      case 'project':
        return typeProject;
      default:
        return typeOther;
    }
  }

  
  String categoryTitle(String id) {
    switch (id) {
      case 'files':
        return _t('Файловая система', 'File System');
      case 'system':
        return _t('Система', 'System');
      case 'commands':
        return _t('Команды', 'Commands');
      case 'clipboard':
        return _t('Буфер обмена', 'Clipboard');
      case 'timers':
        return _t('Таймеры', 'Timers');
      case 'memory':
        return _t('Память', 'Memory');
      default:
        return id;
    }
  }

  
  String categoryDescription(String id) {
    switch (id) {
      case 'files':
        return _t('Работа с файлами и папками', 'Work with files and folders');
      case 'system':
        return _t('Информация и процессы', 'Information and processes');
      case 'commands':
        return _t(
          'Выполнение команд и запуск программ',
          'Run commands and apps',
        );
      case 'clipboard':
        return _t('Чтение и запись в буфер', 'Read and write to clipboard');
      case 'timers':
        return _t('Таймеры и напоминания', 'Timers and reminders');
      case 'memory':
        return _t('Запоминание информации', 'Remember information');
      default:
        return '';
    }
  }

  
  String toolDescription(String name) {
    switch (name) {
      case 'read_file':
        return _t('Чтение файлов', 'Read files');
      case 'write_file':
        return _t('Запись файлов', 'Write files');
      case 'list_directory':
        return _t('Список папки', 'List directory');
      case 'create_directory':
        return _t('Создание папок', 'Create directories');
      case 'delete':
        return _t('Удаление', 'Delete');
      case 'search_files':
        return _t('Поиск файлов', 'Search files');
      case 'system_info':
        return _t('Инфо о системе', 'System info');
      case 'disk_info':
        return _t('Инфо о дисках', 'Disk info');
      case 'network_info':
        return _t('Сеть и IP', 'Network and IP');
      case 'list_processes':
        return _t('Список процессов', 'List processes');
      case 'get_process_path':
        return _t('Путь процесса', 'Process path');
      case 'kill_process':
        return _t('Завершить процесс', 'Kill process');
      case 'run_command':
        return _t('Команда PowerShell', 'PowerShell command');
      case 'run_admin_command':
        return _t('Команда от админа', 'Admin command');
      case 'launch_app':
        return _t('Запуск приложения', 'Launch app');
      case 'open_file':
        return _t('Открыть файл', 'Open file');
      case 'open_url':
        return _t('Открыть URL', 'Open URL');
      case 'read_clipboard':
        return _t('Читать буфер', 'Read clipboard');
      case 'write_clipboard':
        return _t('Записать в буфер', 'Write to clipboard');
      case 'set_timer':
        return _t('Установить таймер', 'Set timer');
      case 'list_timers':
        return _t('Список таймеров', 'List timers');
      case 'cancel_timer':
        return _t('Отменить таймер', 'Cancel timer');
      case 'save_memory':
        return _t('Сохранить информацию', 'Save information');
      case 'recall_memory':
        return _t('Вспомнить информацию', 'Recall information');
      case 'list_memories':
        return _t('Список сохранённого', 'List saved');
      case 'forget_memory':
        return _t('Забыть информацию', 'Forget information');
      default:
        return name;
    }
  }

  
  String _t(String ru, String en) => language == AppLanguage.ru ? ru : en;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final lang = locale.languageCode == 'en' ? AppLanguage.en : AppLanguage.ru;
    return AppLocalizations(lang);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
