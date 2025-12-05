import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../models/app_settings.dart';
import '../l10n/app_localizations.dart';
import 'api_key_dialog.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF3A3A4A), width: 1),
      ),
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                      Icons.settings_outlined,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).settings,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF0F0F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              
              _SettingsSection(
                title: AppLocalizations.of(context).apiKey,
                child: Consumer<ChatViewModel>(
                  builder: (context, viewModel, child) {
                    final l10n = AppLocalizations.of(context);
                    return _SettingsItem(
                      icon: Icons.vpn_key_outlined,
                      title: 'Google Gemini API',
                      subtitle: viewModel.isApiKeySet
                          ? l10n.apiKeyConfigured
                          : l10n.apiKeyNotConfigured,
                      trailing: FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.5),
                            builder: (context) => const ApiKeyDialog(),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          viewModel.isApiKeySet ? l10n.change : l10n.configure,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              
              _SettingsSection(
                title: AppLocalizations.of(context).proxy,
                child: const _ProxySettingsWidget(),
              ),

              const SizedBox(height: 16),

              
              _SettingsSection(
                title: AppLocalizations.of(context).appearance,
                child: Consumer<ChatViewModel>(
                  builder: (context, viewModel, child) {
                    final l10n = AppLocalizations.of(context);
                    return Column(
                      children: [
                        _SettingsItem(
                          icon: Icons.animation_outlined,
                          title: l10n.animations,
                          subtitle: l10n.animationsDesc,
                          trailing: Switch(
                            value: viewModel.animationsEnabled,
                            onChanged: (value) {
                              viewModel.setAnimationsEnabled(value);
                            },
                            activeColor: const Color(0xFF6366F1),
                            activeTrackColor: const Color(
                              0xFF6366F1,
                            ).withOpacity(0.3),
                            inactiveThumbColor: const Color(0xFF888888),
                            inactiveTrackColor: const Color(0xFF3A3A4A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsItem(
                          icon: Icons.language_outlined,
                          title: l10n.languageLabel,
                          subtitle: viewModel.language == AppLanguage.ru
                              ? l10n.russian
                              : l10n.english,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A3A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF3A3A4A),
                              ),
                            ),
                            child: DropdownButton<AppLanguage>(
                              value: viewModel.language,
                              dropdownColor: const Color(0xFF2A2A3A),
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white54,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: AppLanguage.ru,
                                  child: Text(
                                    '🇷🇺 Русский',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: AppLanguage.en,
                                  child: Text(
                                    '🇬🇧 English',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                              onChanged: (lang) {
                                if (lang != null) viewModel.setLanguage(lang);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB0B0B0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).close,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProxySettingsWidget extends StatefulWidget {
  const _ProxySettingsWidget();

  @override
  State<_ProxySettingsWidget> createState() => _ProxySettingsWidgetState();
}

class _ProxySettingsWidgetState extends State<_ProxySettingsWidget> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isEditing = false;

  
  bool _isChecking = false;
  String? _checkResult;
  bool? _checkSuccess;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController();
    _portController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkProxy(ProxySettings proxy, AppLocalizations l10n) async {
    if (proxy.host.isEmpty) {
      setState(() {
        _checkResult = l10n.proxyHostRequired;
        _checkSuccess = false;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _checkResult = null;
      _checkSuccess = null;
    });

    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 10);

      
      final proxyUrl = proxy.proxyUrl;
      if (proxyUrl != null) {
        httpClient.findProxy = (uri) => 'PROXY ${proxy.host}:${proxy.port}';

        
        if (proxy.username != null && proxy.username!.isNotEmpty) {
          httpClient.addProxyCredentials(
            proxy.host,
            proxy.port,
            'Basic',
            HttpClientBasicCredentials(proxy.username!, proxy.password ?? ''),
          );
        }
      }

      
      final request = await httpClient.getUrl(
        Uri.parse('https://generativelanguage.googleapis.com'),
      );
      final response = await request.close();

      httpClient.close();

      if (response.statusCode == 200 ||
          response.statusCode == 404 ||
          response.statusCode == 401) {
        setState(() {
          _checkResult = l10n.proxyWorking;
          _checkSuccess = true;
        });
      } else {
        setState(() {
          _checkResult = '${l10n.error}: ${response.statusCode}';
          _checkSuccess = false;
        });
      }
    } on SocketException catch (e) {
      setState(() {
        _checkResult = '${l10n.connectionFailed}: ${e.message}';
        _checkSuccess = false;
      });
    } on HttpException catch (e) {
      setState(() {
        _checkResult = '${l10n.httpError}: ${e.message}';
        _checkSuccess = false;
      });
    } catch (e) {
      setState(() {
        _checkResult = '${l10n.error}: $e';
        _checkSuccess = false;
      });
    } finally {
      setState(() => _isChecking = false);
    }
  }

  void _loadSettings(ProxySettings settings) {
    _hostController.text = settings.host;
    _portController.text = settings.port.toString();
    _usernameController.text = settings.username ?? '';
    _passwordController.text = settings.password ?? '';
  }

  void _saveSettings(ChatViewModel viewModel) {
    final settings = ProxySettings(
      enabled: viewModel.proxySettings.enabled,
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text) ?? 8080,
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      password: _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim(),
    );
    viewModel.setProxySettings(settings);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        final proxy = viewModel.proxySettings;
        final l10n = AppLocalizations.of(context);

        return Column(
          children: [
            _SettingsItem(
              icon: Icons.public_outlined,
              title: l10n.httpProxy,
              subtitle: proxy.enabled
                  ? (proxy.host.isNotEmpty
                        ? '${proxy.host}:${proxy.port}'
                        : l10n.notConfigured)
                  : l10n.off,
              trailing: Switch(
                value: proxy.enabled,
                onChanged: (value) {
                  viewModel.setProxySettings(
                    ProxySettings(
                      enabled: value,
                      host: proxy.host,
                      port: proxy.port,
                      username: proxy.username,
                      password: proxy.password,
                    ),
                  );
                },
                activeColor: const Color(0xFF6366F1),
                activeTrackColor: const Color(0xFF6366F1).withOpacity(0.3),
                inactiveThumbColor: const Color(0xFF888888),
                inactiveTrackColor: const Color(0xFF3A3A4A),
              ),
            ),
            if (proxy.enabled) ...[
              const Divider(color: Color(0xFF3A3A4A), height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: _isEditing
                    ? _buildEditForm(viewModel)
                    : _buildDisplayInfo(viewModel, proxy),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDisplayInfo(ChatViewModel viewModel, ProxySettings proxy) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proxy.host.isEmpty ? l10n.hostNotSpecified : proxy.host,
                    style: TextStyle(
                      fontSize: 13,
                      color: proxy.host.isEmpty
                          ? const Color(0xFF888888)
                          : const Color(0xFFF0F0F0),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.proxyPort}: ${proxy.port}${proxy.username != null ? ' • ${l10n.auth}' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            
            if (proxy.host.isNotEmpty) ...[
              _isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6366F1),
                      ),
                    )
                  : IconButton(
                      onPressed: () => _checkProxy(proxy, l10n),
                      icon: const Icon(
                        Icons.wifi_tethering,
                        size: 18,
                        color: Color(0xFF888888),
                      ),
                      tooltip: l10n.checkProxy,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
              const SizedBox(width: 4),
            ],
            TextButton(
              onPressed: () {
                _loadSettings(proxy);
                setState(() => _isEditing = true);
              },
              child: Text(
                l10n.change,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6366F1)),
              ),
            ),
          ],
        ),
        
        if (_checkResult != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  (_checkSuccess == true
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444))
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color:
                    (_checkSuccess == true
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444))
                        .withOpacity(0.3),
              ),
            ),
            child: Text(
              _checkResult!,
              style: TextStyle(
                fontSize: 12,
                color: _checkSuccess == true
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEditForm(ChatViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                controller: _hostController,
                label: l10n.proxyHost,
                hint: 'proxy.example.com',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                controller: _portController,
                label: l10n.proxyPort,
                hint: '8080',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _usernameController,
                label: l10n.loginOptional,
                hint: '',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(
                controller: _passwordController,
                label: l10n.passwordOptional,
                hint: '',
                obscureText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: Text(
                l10n.cancel,
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => _saveSettings(viewModel),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(l10n.save, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 13, color: Color(0xFFF0F0F0)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF3A3A4A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF3A3A4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3A).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3A3A4A), width: 1),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF888888)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF0F0F0),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
