import 'package:flutter/material.dart';

class ToolsGuideDialog extends StatelessWidget {
  const ToolsGuideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF3A3A4A), width: 1),
      ),
      child: Container(
        width: 550,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.build_outlined,
                    color: Color(0xFF6366F1),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Инструменты ОС',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF0F0F0),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF888888)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'AI-ассистент может выполнять действия на вашем компьютере. '
              'Просто опишите что нужно сделать.',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 20),

            
            Expanded(
              child: ListView(
                children: const [
                  _ToolCategory(
                    icon: Icons.folder_outlined,
                    title: 'Файловая система',
                    tools: [
                      _ToolExample(
                        name: 'Просмотр папок',
                        example: '"Покажи что на рабочем столе"',
                      ),
                      _ToolExample(
                        name: 'Чтение файлов',
                        example: '"Прочитай файл C:\\config.txt"',
                      ),
                      _ToolExample(
                        name: 'Создание файлов',
                        example: '"Создай файл notes.txt с текстом Привет"',
                      ),
                      _ToolExample(
                        name: 'Поиск файлов',
                        example: '"Найди все .log файлы в папке Windows"',
                      ),
                      _ToolExample(
                        name: 'Удаление',
                        example: '"Удали файл temp.txt"',
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ToolCategory(
                    icon: Icons.computer_outlined,
                    title: 'Системная информация',
                    tools: [
                      _ToolExample(
                        name: 'Информация о системе',
                        example: '"Какая у меня система?"',
                      ),
                      _ToolExample(
                        name: 'Диски',
                        example: '"Сколько свободного места на дисках?"',
                      ),
                      _ToolExample(
                        name: 'Сеть',
                        example: '"Покажи мой IP адрес"',
                      ),
                      _ToolExample(
                        name: 'Процессы',
                        example: '"Какие процессы запущены?"',
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ToolCategory(
                    icon: Icons.terminal_outlined,
                    title: 'Команды и приложения',
                    tools: [
                      _ToolExample(
                        name: 'Выполнение команд',
                        example: '"Выполни команду ipconfig /all"',
                      ),
                      _ToolExample(
                        name: 'Запуск программ',
                        example: '"Открой блокнот" или "Запусти калькулятор"',
                      ),
                      _ToolExample(
                        name: 'Открытие файлов',
                        example: '"Открой документ report.docx"',
                      ),
                      _ToolExample(
                        name: 'Браузер',
                        example: '"Открой сайт google.com"',
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ToolCategory(
                    icon: Icons.content_paste_outlined,
                    title: 'Буфер обмена',
                    tools: [
                      _ToolExample(
                        name: 'Чтение',
                        example: '"Что у меня скопировано?"',
                      ),
                      _ToolExample(
                        name: 'Запись',
                        example: '"Скопируй в буфер текст: Hello World"',
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ToolCategory(
                    icon: Icons.auto_fix_high_outlined,
                    title: 'Комплексные задачи',
                    tools: [
                      _ToolExample(
                        name: 'Многошаговые операции',
                        example:
                            '"Создай папку Projects и внутри файл readme.md"',
                      ),
                      _ToolExample(
                        name: 'Анализ',
                        example:
                            '"Найди самые большие файлы в папке Downloads"',
                      ),
                      _ToolExample(
                        name: 'Автоматизация',
                        example: '"Переименуй все .jpeg файлы в .jpg"',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Будьте осторожны с командами удаления и изменения '
                      'системных файлов. AI предупредит о рисках.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_ToolExample> tools;

  const _ToolCategory({
    required this.icon,
    required this.title,
    required this.tools,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF0F0F0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...tools,
      ],
    );
  }
}

class _ToolExample extends StatelessWidget {
  final String name;
  final String example;

  const _ToolExample({required this.name, required this.example});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 26, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF888888),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  example,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6366F1),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
