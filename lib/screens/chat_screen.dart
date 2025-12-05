import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/proxy_setup_dialog.dart';
import '../l10n/app_localizations.dart';
import 'tools_page.dart';
import 'memory_page.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

enum MainView { chat, tools, memory }

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isSidebarVisible = true;
  MainView _currentView = MainView.chat;
  bool _proxyDialogShown = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showProxyDialogIfNeeded(ChatViewModel viewModel) {
    if (!_proxyDialogShown &&
        viewModel.settingsLoaded &&
        viewModel.isFirstLaunch &&
        viewModel.isFromRestrictedRegion) {
      _proxyDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.7),
          builder: (context) => const ProxySetupDialog(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        _showProxyDialogIfNeeded(viewModel);

        return Scaffold(
          body: Row(
            children: [
              
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: _isSidebarVisible ? 280 : 0,
                child: _isSidebarVisible
                    ? NavigationSidebar(
                        onNewChat: () {
                          setState(() => _currentView = MainView.chat);
                          context.read<ChatViewModel>().clearChat();
                        },
                        onSettings: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.5),
                            builder: (context) => const SettingsDialog(),
                          );
                        },
                        onToolsPage: () {
                          setState(() => _currentView = MainView.tools);
                        },
                        onMemoryPage: () {
                          setState(() => _currentView = MainView.memory);
                        },
                        onChatSelected: () {
                          setState(() => _currentView = MainView.chat);
                        },
                      )
                    : null,
              ),

              
              Expanded(
                child: _currentView == MainView.tools
                    ? const ToolsPage()
                    : _currentView == MainView.memory
                    ? const MemoryPage()
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF1A1A2E),
                              const Color(0xFF0F0F1E),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1A1A2E),
                              ),
                              child: Row(
                                children: [
                                  
                                  IconButton(
                                    icon: Icon(
                                      _isSidebarVisible
                                          ? Icons.menu_open_outlined
                                          : Icons.menu_outlined,
                                      size: 20,
                                      color: const Color(0xFF888888),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isSidebarVisible = !_isSidebarVisible;
                                      });
                                    },
                                    tooltip: _isSidebarVisible
                                        ? AppLocalizations.of(
                                            context,
                                          ).collapseSidebar
                                        : AppLocalizations.of(
                                            context,
                                          ).expandSidebar,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context).newChat,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFF0F0F0),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.refresh_outlined,
                                      size: 18,
                                    ),
                                    tooltip: AppLocalizations.of(
                                      context,
                                    ).clearChat,
                                    color: const Color(0xFF888888),
                                    onPressed: () {
                                      context.read<ChatViewModel>().clearChat();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert, size: 18),
                                    color: const Color(0xFF888888),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),

                            
                            Expanded(child: _buildChatContent(context)),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.isApiKeySet) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.vpn_key_outlined,
                    size: 40,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.configureApiKey,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.apiKeyRequiredDesc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.3),
                      builder: (context) => const ApiKeyDialog(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      l10n.configure,
                      style: const TextStyle(
                        fontFamily: 'Segoe UI',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        _scrollToBottom();

        return Column(
          children: [
            Expanded(
              child: viewModel.messages.isEmpty
                  ? const _AnimatedEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: viewModel.messages.length,
                      itemBuilder: (context, index) {
                        final isLast = index == viewModel.messages.length - 1;
                        return ChatBubble(
                          message: viewModel.messages[index],
                          index: index,
                          isLastMessage: isLast,
                          onQuickReply: (reply) => viewModel.sendMessage(reply),
                        );
                      },
                    ),
            ),
            
            Container(
              color: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ChatInput(
                    onSend: (text) => viewModel.sendMessage(text),
                    isLoading: viewModel.isLoading,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}


class _AnimatedEmptyState extends StatefulWidget {
  const _AnimatedEmptyState();

  @override
  State<_AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<_AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = context.read<ChatViewModel>();
        if (viewModel.animationsEnabled) {
          _fadeController.forward();
          _floatController.repeat(reverse: true);
        } else {
          _fadeController.value = 1.0;
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animationsEnabled = context.watch<ChatViewModel>().animationsEnabled;

    return Center(
      child: FadeTransition(
        opacity: _fadeController,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              animationsEnabled
                  ? AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        final value = Curves.easeInOut.transform(
                          _floatController.value,
                        );
                        return Transform.translate(
                          offset: Offset(0, -6 + (value * 12)),
                          child: child,
                        );
                      },
                      child: _buildIcon(),
                    )
                  : _buildIcon(),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context).howCanIHelp,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  AppLocalizations.of(context).assistantDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB0B0B0),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.3),
            const Color(0xFF6366F1).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, size: 50, color: Color(0xFF6366F1)),
    );
  }
}
