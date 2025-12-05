import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../models/app_settings.dart';

class ProxySetupDialog extends StatefulWidget {
  final bool isFromRussia;

  const ProxySetupDialog({super.key, this.isFromRussia = true});

  @override
  State<ProxySetupDialog> createState() => _ProxySetupDialogState();
}

class _ProxySetupDialogState extends State<ProxySetupDialog> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '8080');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isChecking = false;
  String? _checkResult;
  bool? _checkSuccess;

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkProxy() async {
    final host = _hostController.text.trim();
    if (host.isEmpty) {
      setState(() {
        _checkResult = 'Укажите адрес прокси';
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
      final port = int.tryParse(_portController.text) ?? 8080;
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 10);
      httpClient.findProxy = (uri) => 'PROXY $host:$port';

      if (username.isNotEmpty) {
        httpClient.addProxyCredentials(
          host,
          port,
          'Basic',
          HttpClientBasicCredentials(username, password),
        );
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
          _checkResult = 'Прокси работает! ✓';
          _checkSuccess = true;
        });
      } else {
        setState(() {
          _checkResult = 'Ошибка: код ${response.statusCode}';
          _checkSuccess = false;
        });
      }
    } on SocketException {
      setState(() {
        _checkResult = 'Не удалось подключиться';
        _checkSuccess = false;
      });
    } catch (e) {
      setState(() {
        _checkResult = 'Ошибка: ${e.toString().substring(0, 50)}...';
        _checkSuccess = false;
      });
    } finally {
      setState(() => _isChecking = false);
    }
  }

  void _saveAndContinue() {
    final host = _hostController.text.trim();
    final port = int.tryParse(_portController.text) ?? 8080;
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final settings = ProxySettings(
      enabled: host.isNotEmpty,
      host: host,
      port: port,
      username: username.isEmpty ? null : username,
      password: password.isEmpty ? null : password,
    );

    context.read<ChatViewModel>().setProxySettings(settings);
    context.read<ChatViewModel>().markFirstLaunchComplete();
    Navigator.of(context).pop();
  }

  void _skipProxy() {
    context.read<ChatViewModel>().markFirstLaunchComplete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF3A3A4A), width: 1),
      ),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.vpn_key_outlined,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Настройка прокси',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF0F0F0),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Требуется для работы AI',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: const Color(0xFFEF4444).withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Google Gemini API недоступен в вашем регионе. '
                      'Для работы приложения необходимо настроить прокси-сервер.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB0B0B0),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller: _hostController,
                    label: 'Адрес прокси',
                    hint: 'proxy.example.com',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _portController,
                    label: 'Порт',
                    hint: '8080',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _usernameController,
                    label: 'Логин (опционально)',
                    hint: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _passwordController,
                    label: 'Пароль (опционально)',
                    hint: '',
                    obscureText: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            
            if (_checkResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:
                      (_checkSuccess == true
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444))
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
                    fontSize: 13,
                    color: _checkSuccess == true
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),

            
            Row(
              children: [
                
                OutlinedButton.icon(
                  onPressed: _isChecking ? null : _checkProxy,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF6366F1),
                          ),
                        )
                      : const Icon(Icons.wifi_tethering, size: 18),
                  label: Text(_isChecking ? 'Проверка...' : 'Проверить'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const Spacer(),

                
                TextButton(
                  onPressed: _skipProxy,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF888888),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Пропустить'),
                ),

                const SizedBox(width: 8),

                
                FilledButton(
                  onPressed: _saveAndContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
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
      style: const TextStyle(fontSize: 14, color: Color(0xFFF0F0F0)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A3A4A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A3A4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}
