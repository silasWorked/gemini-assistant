import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tools/memory_tools.dart';
import '../l10n/app_localizations.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  final MemoryManager _memory = MemoryManager();
  List<MemoryEntry> _entries = [];
  bool _loading = true;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _loading = true);
    await _memory.initialize();
    final entries = await _memory.listAll(
      type: _selectedType != null ? _parseType(_selectedType!) : null,
    );
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  MemoryType? _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'file_path':
        return MemoryType.filePath;
      case 'command':
        return MemoryType.command;
      case 'preference':
        return MemoryType.preference;
      case 'fact':
        return MemoryType.fact;
      case 'shortcut':
        return MemoryType.shortcut;
      case 'project':
        return MemoryType.project;
      default:
        return MemoryType.other;
    }
  }

  Future<void> _deleteMemory(String key) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3A),
        title: Text(
          l10n.deleteMemory,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '${l10n.deleteMemoryConfirm} "$key"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _memory.forget(key);
      _loadMemories();
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).copiedToClipboard),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  IconData _getTypeIcon(MemoryType type) {
    switch (type) {
      case MemoryType.filePath:
        return Icons.folder_outlined;
      case MemoryType.command:
        return Icons.terminal;
      case MemoryType.preference:
        return Icons.settings_outlined;
      case MemoryType.fact:
        return Icons.lightbulb_outline;
      case MemoryType.shortcut:
        return Icons.link;
      case MemoryType.project:
        return Icons.work_outline;
      case MemoryType.other:
        return Icons.bookmark_outline;
    }
  }

  Color _getTypeColor(MemoryType type) {
    switch (type) {
      case MemoryType.filePath:
        return Colors.blue;
      case MemoryType.command:
        return Colors.orange;
      case MemoryType.preference:
        return Colors.purple;
      case MemoryType.fact:
        return Colors.yellow;
      case MemoryType.shortcut:
        return Colors.cyan;
      case MemoryType.project:
        return Colors.green;
      case MemoryType.other:
        return Colors.grey;
    }
  }

  String _getTypeName(MemoryType type, AppLocalizations l10n) {
    return l10n.memoryTypeName(type.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.purple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).memory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context).savedInfo,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A3A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String?>(
                        value: _selectedType,
                        hint: Text(
                          AppLocalizations.of(context).allTypes,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        dropdownColor: const Color(0xFF2A2A3A),
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.filter_list,
                          color: Colors.white54,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              AppLocalizations.of(context).allTypes,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          ...MemoryType.values.map(
                            (t) => DropdownMenuItem(
                              value: t.name,
                              child: Row(
                                children: [
                                  Icon(
                                    _getTypeIcon(t),
                                    size: 16,
                                    color: _getTypeColor(t),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getTypeName(
                                      t,
                                      AppLocalizations.of(context),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          setState(() => _selectedType = v);
                          _loadMemories();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.psychology_outlined,
                              size: 64,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).memoryEmpty,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).memoryEmptyHint,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadMemories,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _entries.length,
                          itemBuilder: (ctx, i) => _MemoryCard(
                            entry: _entries[i],
                            typeIcon: _getTypeIcon(_entries[i].type),
                            typeColor: _getTypeColor(_entries[i].type),
                            typeName: _getTypeName(
                              _entries[i].type,
                              AppLocalizations.of(context),
                            ),
                            onCopy: () => _copyToClipboard(_entries[i].value),
                            onDelete: () => _deleteMemory(_entries[i].key),
                          ),
                        ),
                      ),
              ),

              
              if (_entries.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3A).withOpacity(0.5),
                    border: const Border(
                      top: BorderSide(color: Color(0xFF3A3A4A)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_entries.length} ${AppLocalizations.of(context).entriesCount(_entries.length)}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryEntry entry;
  final IconData typeIcon;
  final Color typeColor;
  final String typeName;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _MemoryCard({
    required this.entry,
    required this.typeIcon,
    required this.typeColor,
    required this.typeName,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, size: 16, color: typeColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        typeName,
                        style: TextStyle(color: typeColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  color: Colors.white54,
                  onPressed: onCopy,
                  tooltip: l10n.copy,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.red.withOpacity(0.7),
                  onPressed: onDelete,
                  tooltip: l10n.delete,
                ),
              ],
            ),
          ),

          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  entry.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
                if (entry.aliases.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.aliases
                        .map(
                          (alias) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              alias,
                              style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (entry.description != null &&
                    entry.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.description!,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${l10n.created}: ${_formatDate(entry.createdAt)} • ${l10n.used}: ${entry.accessCount} ${l10n.times}',
                  style: const TextStyle(color: Colors.white30, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
