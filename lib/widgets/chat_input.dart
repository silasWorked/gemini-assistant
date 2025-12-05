import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInput({super.key, required this.onSend, this.isLoading = false});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF3A3A4A), width: 1),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !widget.isLoading,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).typeMessage,
                    hintStyle: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Segoe UI',
                    color: Color(0xFFFFFFFF),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: widget.isLoading
                    ? const Color(0xFF3A3A4A)
                    : const Color(0xFF0078D4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: IconButton(
                onPressed: widget.isLoading ? null : _handleSend,
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF888888),
                          ),
                        ),
                      )
                    : const Icon(Icons.send_outlined, size: 18),
                color: Colors.white,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
