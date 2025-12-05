import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final int index;
  final bool isLastMessage;
  final Function(String)? onQuickReply;

  const ChatBubble({
    super.key,
    required this.message,
    this.index = 0,
    this.isLastMessage = false,
    this.onQuickReply,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();

  
  static bool isToolCall(String text) {
    return text.startsWith('🔧') ||
        text.startsWith('✓') ||
        text.startsWith('Tool call:') ||
        text.startsWith('Вызов инструмента:');
  }

  
  static bool isToolComplete(String text) {
    return text.startsWith('✓');
  }

  
  static bool asksForConfirmation(String text) {
    final lower = text.toLowerCase();
    return lower.contains('вы уверены') ||
        lower.contains('вы уверенны') ||
        lower.contains('подтвердите') ||
        lower.contains('хотите продолжить') ||
        lower.contains('are you sure') ||
        lower.contains('do you want') ||
        lower.contains('confirm') ||
        (lower.contains('delete') || lower.contains('удалить')) &&
            lower.contains('?') ||
        (lower.contains('execute') || lower.contains('выполнить')) &&
            lower.contains('?');
  }
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    
    timeDilation = 1.0;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 0.15 : -0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = context.read<ChatViewModel>();
        if (viewModel.animationsEnabled) {
          _controller.forward();
        } else {
          _controller.value = 1.0;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationsEnabled = context.watch<ChatViewModel>().animationsEnabled;

    
    if (ChatBubble.isToolCall(widget.message.text)) {
      return _buildToolCallWidget(context, animationsEnabled);
    }

    if (!animationsEnabled) {
      return _buildBubble(context);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildBubble(context),
      ),
    );
  }

  Widget _buildToolCallWidget(BuildContext context, bool animate) {
    
    final text = widget.message.text;
    final isComplete = ChatBubble.isToolComplete(text);
    final toolName = text
        .replaceAll('🔧 Tool call: ', '')
        .replaceAll('Tool call: ', '')
        .replaceAll('🔧 Вызов инструмента: ', '')
        .replaceAll('Вызов инструмента: ', '')
        .replaceAll('✓ ', '');

    final content = Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isComplete
                    ? const Color(0xFF22C55E).withOpacity(0.3)
                    : const Color(0xFF6366F1).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isComplete)
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Color(0xFF22C55E),
                  )
                else
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF6366F1).withOpacity(0.7),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  toolName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isComplete
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF888888),
                    fontFamily: 'Consolas',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!animate) return content;

    return FadeTransition(opacity: _fadeAnimation, child: content);
  }

  Widget _buildBubble(BuildContext context) {
    
    final showConfirmButtons =
        !widget.message.isUser &&
        widget.isLastMessage &&
        ChatBubble.asksForConfirmation(widget.message.text);

    return Align(
      alignment: widget.message.isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            decoration: BoxDecoration(
              color: widget.message.isUser
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF2A2A3A),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(widget.message.isUser ? 16 : 4),
                bottomRight: Radius.circular(widget.message.isUser ? 4 : 16),
              ),
              border: widget.message.isUser
                  ? null
                  : Border.all(color: const Color(0xFF3A3A4A), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.message.isUser)
                  SelectableText(
                    widget.message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  )
                else
                  _buildSelectableMarkdown(widget.message.text),
                const SizedBox(height: 6),
                Text(
                  _formatTime(widget.message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.message.isUser
                        ? Colors.white70
                        : const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          
          if (showConfirmButtons)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ConfirmButton(
                    text: AppLocalizations.of(context).yes,
                    isPositive: true,
                    onTap: () => widget.onQuickReply?.call(
                      AppLocalizations.of(context).yes,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ConfirmButton(
                    text: AppLocalizations.of(context).no,
                    isPositive: false,
                    onTap: () => widget.onQuickReply?.call(
                      AppLocalizations.of(context).no,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSelectableMarkdown(String text) {
    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(color: Color(0xFFF0F0F0), fontSize: 14, height: 1.6),
        h1: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        h2: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        h3: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
        code: const TextStyle(
          backgroundColor: Color(0xFF252540),
          color: Color(0xFF22C55E),
          fontFamily: 'Consolas',
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF151525),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3A3A5A)),
        ),
        codeblockPadding: const EdgeInsets.all(14),
        blockquote: const TextStyle(
          color: Color(0xFFAAAAAA),
          fontSize: 14,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: const Color(0xFF6366F1).withOpacity(0.5),
              width: 3,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
        listBullet: const TextStyle(color: Color(0xFF6366F1), fontSize: 14),
        listIndent: 20,
        strong: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        em: const TextStyle(
          color: Color(0xFFDDDDDD),
          fontStyle: FontStyle.italic,
        ),
        a: const TextStyle(
          color: Color(0xFF8B5CF6),
          decoration: TextDecoration.underline,
        ),
        tableHead: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        tableBody: const TextStyle(color: Color(0xFFE0E0E0)),
        tableBorder: TableBorder.all(color: const Color(0xFF3A3A5A), width: 1),
        tableHeadAlign: TextAlign.center,
        tableCellsPadding: const EdgeInsets.all(8),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: const Color(0xFF3A3A5A), width: 1),
          ),
        ),
      ),
      builders: {'code': _CodeBlockBuilder()},
    );
  }
}


class _CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    final code = element.textContent;

    
    if (!code.contains('\n') && code.length < 100) {
      return _CopyableInlineCode(code: code);
    }

    return _CopyableCodeBlock(code: code);
  }
}

class _CopyableInlineCode extends StatefulWidget {
  final String code;
  const _CopyableInlineCode({required this.code});

  @override
  State<_CopyableInlineCode> createState() => _CopyableInlineCodeState();
}

class _CopyableInlineCodeState extends State<_CopyableInlineCode> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => _copyToClipboard(context, widget.code),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF303050) : const Color(0xFF252540),
            borderRadius: BorderRadius.circular(4),
            border: _hovered
                ? Border.all(color: const Color(0xFF6366F1).withOpacity(0.5))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.code,
                style: const TextStyle(
                  color: Color(0xFF22C55E),
                  fontFamily: 'Consolas',
                  fontSize: 13,
                ),
              ),
              if (_hovered) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.copy,
                  size: 12,
                  color: const Color(0xFF6366F1).withOpacity(0.8),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).copied),
          ],
        ),
        backgroundColor: const Color(0xFF2A2A3A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _CopyableCodeBlock extends StatefulWidget {
  final String code;
  const _CopyableCodeBlock({required this.code});

  @override
  State<_CopyableCodeBlock> createState() => _CopyableCodeBlockState();
}

class _CopyableCodeBlockState extends State<_CopyableCodeBlock> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF252535),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => _copyToClipboard(context),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _copied ? Icons.check : Icons.copy,
                          size: 14,
                          color: _copied
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF888888),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _copied
                              ? AppLocalizations.of(context).copied
                              : AppLocalizations.of(context).copy,
                          style: TextStyle(
                            fontSize: 11,
                            color: _copied
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              widget.code.trim(),
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontFamily: 'Consolas',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.code.trim()));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }
}


class _ConfirmButton extends StatelessWidget {
  final String text;
  final bool isPositive;
  final VoidCallback onTap;

  const _ConfirmButton({
    required this.text,
    required this.isPositive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPositive
                ? const Color(0xFF22C55E).withOpacity(0.15)
                : const Color(0xFFEF4444).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPositive
                  ? const Color(0xFF22C55E).withOpacity(0.4)
                  : const Color(0xFFEF4444).withOpacity(0.4),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isPositive
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
            ),
          ),
        ),
      ),
    );
  }
}
