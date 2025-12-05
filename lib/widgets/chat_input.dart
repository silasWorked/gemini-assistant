import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/app_settings.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInput({super.key, required this.onSend, this.isLoading = false});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _modelButtonKey = GlobalKey();

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

  void _showModelSelector(BuildContext context) {
    final viewModel = context.read<ChatViewModel>();
    final RenderBox button =
        _modelButtonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final buttonPos = button.localToGlobal(Offset.zero, ancestor: overlay);

    showMenu<GeminiModel>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPos.dx,
        buttonPos.dy - 290,
        overlay.size.width - buttonPos.dx - button.size.width,
        overlay.size.height - buttonPos.dy,
      ),
      color: const Color(0xFF1E1E2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF3A3A4A)),
      ),
      items: GeminiModel.values.map((model) {
        final isSelected = model == viewModel.selectedModel;
        return PopupMenuItem<GeminiModel>(
          value: model,
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  model.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : const Color(0xFFF0F0F0),
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, color: Color(0xFF6366F1), size: 16),
            ],
          ),
        );
      }).toList(),
    ).then((selected) {
      if (selected != null) {
        viewModel.setSelectedModel(selected);
      }
    });
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
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
                          contentPadding: const EdgeInsets.symmetric(
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
                    Consumer<ChatViewModel>(
                      builder: (context, viewModel, child) {
                        return InkWell(
                          key: _modelButtonKey,
                          onTap: () => _showModelSelector(context),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8, bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E2E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getShortModelName(viewModel.selectedModel),
                                  style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.unfold_more,
                                  size: 14,
                                  color: Color(0xFF888888),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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

  String _getShortModelName(GeminiModel model) {
    switch (model) {
      case GeminiModel.gemini25Flash:
        return '2.5 Flash';
      case GeminiModel.gemini20Flash:
        return '2.0 Flash';
      case GeminiModel.gemini20FlashLite:
        return '2.0 Lite';
      case GeminiModel.gemini25FlashLite:
        return '2.5 Lite';
      case GeminiModel.gemini25Pro:
        return '2.5 Pro';
    }
  }
}
