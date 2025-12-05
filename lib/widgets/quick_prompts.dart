import 'package:flutter/material.dart';

class QuickPrompts extends StatelessWidget {
  final Function(String) onPromptTap;

  const QuickPrompts({super.key, required this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    final prompts = [
      ('Sumarize', Icons.summarize_outlined),
      ('Generate Code', Icons.code_outlined),
      ('Translate', Icons.translate_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: prompts
            .map(
              (prompt) => OutlinedButton.icon(
                onPressed: () => onPromptTap(prompt.$1),
                icon: Icon(prompt.$2, size: 16),
                label: Text(prompt.$1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0078D4),
                  side: const BorderSide(color: Color(0xFF3A3A3A)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
