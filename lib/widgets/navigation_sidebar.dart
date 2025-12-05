import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../l10n/app_localizations.dart';

class NavigationSidebar extends StatelessWidget {
  final VoidCallback onNewChat;
  final VoidCallback onSettings;
  final VoidCallback? onToolsPage;
  final VoidCallback? onMemoryPage;
  final VoidCallback? onChatSelected;

  const NavigationSidebar({
    super.key,
    required this.onNewChat,
    required this.onSettings,
    this.onToolsPage,
    this.onMemoryPage,
    this.onChatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16162A)],
        ),
        border: Border(right: BorderSide(color: Color(0xFF2A2A3A), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_suggest_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).appTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF0F0F0),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _AnimatedButton(onTap: onNewChat),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.history, size: 14, color: Color(0xFF888888)),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context).history,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, viewModel, child) {
                final sessions = viewModel.sessions;
                final currentSession = viewModel.currentSession;

                if (sessions.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context).noChats,
                      style: const TextStyle(color: Color(0xFF888888)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return _ChatHistoryItem(
                      title: session.title,
                      isSelected: session.id == currentSession?.id,
                      onTap: () {
                        viewModel.selectSession(session);
                        onChatSelected?.call();
                      },
                      onDelete: () => viewModel.deleteSession(session.id),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          _NavigationItem(
            icon: Icons.psychology_outlined,
            label: AppLocalizations.of(context).memory,
            onTap: onMemoryPage ?? () {},
          ),

          _NavigationItem(
            icon: Icons.build_outlined,
            label: AppLocalizations.of(context).tools,
            onTap: onToolsPage ?? () {},
          ),

          _NavigationItem(
            icon: Icons.settings_outlined,
            label: AppLocalizations.of(context).settings,
            onTap: onSettings,
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedButton({required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final animationsEnabled = context.watch<ChatViewModel>().animationsEnabled;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: animationsEnabled
              ? const Duration(milliseconds: 100)
              : Duration.zero,
          curve: Curves.easeOut,
          width: double.infinity,
          height: 40,
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isHovered
                  ? [const Color(0xFF7C7AFF), const Color(0xFF9061F9)]
                  : [const Color(0xFF6366F1), const Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: _isHovered && animationsEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedRotation(
                duration: animationsEnabled
                    ? const Duration(milliseconds: 150)
                    : Duration.zero,
                turns: _isHovered ? 0.125 : 0,
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).newChat,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatHistoryItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ChatHistoryItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  State<_ChatHistoryItem> createState() => _ChatHistoryItemState();
}

class _ChatHistoryItemState extends State<_ChatHistoryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final animationsEnabled = context.watch<ChatViewModel>().animationsEnabled;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: animationsEnabled
              ? const Duration(milliseconds: 100)
              : Duration.zero,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF2A2A3A)
                : _isHovered
                ? const Color(0xFF2A2A3A).withOpacity(0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: widget.isSelected
                ? Border.all(color: const Color(0xFF3A3A4A), width: 1)
                : null,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 16,
                color: Color(0xFF888888),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.isSelected
                        ? const Color(0xFFF0F0F0)
                        : const Color(0xFFB0B0B0),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isHovered && widget.onDelete != null)
                GestureDetector(
                  onTap: widget.onDelete,
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Color(0xFF888888),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final animationsEnabled = context.watch<ChatViewModel>().animationsEnabled;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: animationsEnabled
              ? const Duration(milliseconds: 100)
              : Duration.zero,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFF6366F1).withOpacity(0.15)
                : _isHovered
                ? const Color(0xFF2A2A3A)
                : Colors.transparent,
            border: widget.isSelected
                ? const Border(
                    left: BorderSide(color: Color(0xFF6366F1), width: 3),
                  )
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: animationsEnabled
                    ? const Duration(milliseconds: 100)
                    : Duration.zero,
                transform: Matrix4.translationValues(
                  _isHovered && animationsEnabled ? 2 : 0,
                  0,
                  0,
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: _isHovered || widget.isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF888888),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  color: _isHovered || widget.isSelected
                      ? const Color(0xFFF0F0F0)
                      : const Color(0xFFB0B0B0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  final bool animate;

  const _PulsingDot({required this.color, this.animate = true});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.6),
                blurRadius: 6 + (_animation.value * 4),
                spreadRadius: _animation.value * 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
