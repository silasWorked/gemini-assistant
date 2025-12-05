import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../l10n/app_localizations.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isValidating = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context);
    final apiKey = _controller.text.trim();
    if (apiKey.isEmpty) {
      setState(() {
        _error = l10n.enterApiKey;
      });
      return;
    }

    setState(() {
      _isValidating = true;
      _error = null;
    });

    final viewModel = context.read<ChatViewModel>();
    final success = await viewModel.setApiKey(apiKey);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isValidating = false;
        _error = viewModel.errorMessage ?? l10n.invalidApiKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.apiKeySetup,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Segoe UI',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.apiKeySetupDesc,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF5E5E5E),
                fontFamily: 'Segoe UI',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              enabled: !_isValidating,
              decoration: InputDecoration(
                labelText: 'API Key',
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Segoe UI',
                ),
                errorText: _error,
                errorStyle: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Segoe UI',
                ),
              ),
              obscureText: true,
              style: const TextStyle(fontSize: 14, fontFamily: 'Segoe UI'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isValidating
                      ? null
                      : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1F1F1F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isValidating ? null : _handleSave,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: _isValidating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.save,
                          style: const TextStyle(
                            fontFamily: 'Segoe UI',
                            fontSize: 13,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
