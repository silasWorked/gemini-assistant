import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../l10n/app_localizations.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E)],
        ),
      ),
      child: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(color: Color(0xFF1A1A2E)),
                child: Row(
                  children: [
                    const Icon(
                      Icons.build_outlined,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context).toolsAI,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF0F0F0),
                      ),
                    ),
                    const Spacer(),
                    
                    Row(
                      children: [
                        Text(
                          viewModel.toolsEnabled
                              ? AppLocalizations.of(context).on
                              : AppLocalizations.of(context).off,
                          style: TextStyle(
                            fontSize: 12,
                            color: viewModel.toolsEnabled
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: viewModel.toolsEnabled,
                          onChanged: (v) => viewModel.setToolsEnabled(v),
                          activeColor: const Color(0xFF6366F1),
                          activeTrackColor: const Color(
                            0xFF6366F1,
                          ).withOpacity(0.3),
                          inactiveThumbColor: const Color(0xFF888888),
                          inactiveTrackColor: const Color(0xFF3A3A4A),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _ToolSection(
                      categoryId: 'files',
                      icon: Icons.folder_outlined,
                      title: l10n.categoryTitle('files'),
                      description: l10n.categoryDescription('files'),
                      enabled: viewModel.toolCategories
                          .firstWhere((c) => c.id == 'files')
                          .enabled,
                      onToggle: (v) =>
                          viewModel.setToolCategoryEnabled('files', v),
                      masterEnabled: viewModel.toolsEnabled,
                      tools: [
                        _ToolItem(
                          name: 'read_file',
                          description: l10n.toolDescription('read_file'),
                        ),
                        _ToolItem(
                          name: 'write_file',
                          description: l10n.toolDescription('write_file'),
                        ),
                        _ToolItem(
                          name: 'list_directory',
                          description: l10n.toolDescription('list_directory'),
                        ),
                        _ToolItem(
                          name: 'create_directory',
                          description: l10n.toolDescription('create_directory'),
                        ),
                        _ToolItem(
                          name: 'delete',
                          description: l10n.toolDescription('delete'),
                        ),
                        _ToolItem(
                          name: 'search_files',
                          description: l10n.toolDescription('search_files'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ToolSection(
                      categoryId: 'system',
                      icon: Icons.computer_outlined,
                      title: l10n.categoryTitle('system'),
                      description: l10n.categoryDescription('system'),
                      enabled: viewModel.toolCategories
                          .firstWhere((c) => c.id == 'system')
                          .enabled,
                      onToggle: (v) =>
                          viewModel.setToolCategoryEnabled('system', v),
                      masterEnabled: viewModel.toolsEnabled,
                      tools: [
                        _ToolItem(
                          name: 'system_info',
                          description: l10n.toolDescription('system_info'),
                        ),
                        _ToolItem(
                          name: 'disk_info',
                          description: l10n.toolDescription('disk_info'),
                        ),
                        _ToolItem(
                          name: 'network_info',
                          description: l10n.toolDescription('network_info'),
                        ),
                        _ToolItem(
                          name: 'list_processes',
                          description: l10n.toolDescription('list_processes'),
                        ),
                        _ToolItem(
                          name: 'get_process_path',
                          description: l10n.toolDescription('get_process_path'),
                        ),
                        _ToolItem(
                          name: 'kill_process',
                          description: l10n.toolDescription('kill_process'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ToolSection(
                      categoryId: 'commands',
                      icon: Icons.terminal_outlined,
                      title: l10n.categoryTitle('commands'),
                      description: l10n.categoryDescription('commands'),
                      enabled: viewModel.toolCategories
                          .firstWhere((c) => c.id == 'commands')
                          .enabled,
                      onToggle: (v) =>
                          viewModel.setToolCategoryEnabled('commands', v),
                      masterEnabled: viewModel.toolsEnabled,
                      tools: [
                        _ToolItem(
                          name: 'run_command',
                          description: l10n.toolDescription('run_command'),
                        ),
                        _ToolItem(
                          name: 'run_admin_command',
                          description: l10n.toolDescription(
                            'run_admin_command',
                          ),
                        ),
                        _ToolItem(
                          name: 'launch_app',
                          description: l10n.toolDescription('launch_app'),
                        ),
                        _ToolItem(
                          name: 'open_file',
                          description: l10n.toolDescription('open_file'),
                        ),
                        _ToolItem(
                          name: 'open_url',
                          description: l10n.toolDescription('open_url'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ToolSection(
                      categoryId: 'clipboard',
                      icon: Icons.content_paste_outlined,
                      title: l10n.categoryTitle('clipboard'),
                      description: l10n.categoryDescription('clipboard'),
                      enabled: viewModel.toolCategories
                          .firstWhere((c) => c.id == 'clipboard')
                          .enabled,
                      onToggle: (v) =>
                          viewModel.setToolCategoryEnabled('clipboard', v),
                      masterEnabled: viewModel.toolsEnabled,
                      tools: [
                        _ToolItem(
                          name: 'read_clipboard',
                          description: l10n.toolDescription('read_clipboard'),
                        ),
                        _ToolItem(
                          name: 'write_clipboard',
                          description: l10n.toolDescription('write_clipboard'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ToolSection(
                      categoryId: 'timers',
                      icon: Icons.timer_outlined,
                      title: l10n.categoryTitle('timers'),
                      description: l10n.categoryDescription('timers'),
                      enabled: viewModel.toolCategories
                          .firstWhere((c) => c.id == 'timers')
                          .enabled,
                      onToggle: (v) =>
                          viewModel.setToolCategoryEnabled('timers', v),
                      masterEnabled: viewModel.toolsEnabled,
                      tools: [
                        _ToolItem(
                          name: 'set_timer',
                          description: l10n.toolDescription('set_timer'),
                        ),
                        _ToolItem(
                          name: 'list_timers',
                          description: l10n.toolDescription('list_timers'),
                        ),
                        _ToolItem(
                          name: 'cancel_timer',
                          description: l10n.toolDescription('cancel_timer'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ToolSection(
                      categoryId: 'memory',
                      icon: Icons.psychology_outlined,
                      title: l10n.categoryTitle('memory'),
                      description: l10n.categoryDescription('memory'),
                      enabled: viewModel.toolCategories
                          .firstWhere((c) => c.id == 'memory')
                          .enabled,
                      onToggle: (v) =>
                          viewModel.setToolCategoryEnabled('memory', v),
                      masterEnabled: viewModel.toolsEnabled,
                      tools: [
                        _ToolItem(
                          name: 'save_memory',
                          description: l10n.toolDescription('save_memory'),
                        ),
                        _ToolItem(
                          name: 'recall_memory',
                          description: l10n.toolDescription('recall_memory'),
                        ),
                        _ToolItem(
                          name: 'list_memories',
                          description: l10n.toolDescription('list_memories'),
                        ),
                        _ToolItem(
                          name: 'forget_memory',
                          description: l10n.toolDescription('forget_memory'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _WarningCard(l10n: l10n),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToolSection extends StatelessWidget {
  final String categoryId;
  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final bool masterEnabled;
  final Function(bool) onToggle;
  final List<_ToolItem> tools;

  const _ToolSection({
    required this.categoryId,
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.masterEnabled,
    required this.onToggle,
    required this.tools,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = masterEnabled && enabled;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3A).withOpacity(isActive ? 0.5 : 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF3A3A4A) : const Color(0xFF2A2A3A),
        ),
      ),
      child: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF6366F1).withOpacity(0.2)
                        : const Color(0xFF3A3A4A).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isActive
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF666666),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? const Color(0xFFF0F0F0)
                              : const Color(0xFF666666),
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isActive
                              ? const Color(0xFF888888)
                              : const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: masterEnabled ? onToggle : null,
                  activeColor: const Color(0xFF6366F1),
                  activeTrackColor: const Color(0xFF6366F1).withOpacity(0.3),
                  inactiveThumbColor: const Color(0xFF555555),
                  inactiveTrackColor: const Color(0xFF3A3A4A),
                ),
              ],
            ),
          ),
          
          if (isActive)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tools
                    .map(
                      (tool) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF3A3A4A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tool.name,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'Consolas',
                                color: Color(0xFF22C55E),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tool.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolItem extends StatelessWidget {
  final String name;
  final String description;

  const _ToolItem({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); 
  }
}

class _WarningCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _WarningCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFEF4444).withOpacity(0.8),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.securityTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.securityText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0B0B0),
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
