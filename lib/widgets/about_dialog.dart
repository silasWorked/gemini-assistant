import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
                      Icons.info_outlined,
                      color: Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).about,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF0F0F0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Gemini Assistant',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF0F0F0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context).appVersion} 1.0.0',
                style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).appDescription,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFB0B0B0),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF2A2A3A), height: 1),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context).developer,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'silasWorked',
                style: const TextStyle(fontSize: 13, color: Color(0xFFF0F0F0)),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).links,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _LinkButton(
                    label: AppLocalizations.of(context).github,
                    icon: Icons.code_outlined,
                    onTap: () => _launchUrl(
                      'https://github.com/silasWorked/gemini-assistant',
                    ),
                  ),
                  _LinkButton(
                    label: AppLocalizations.of(context).website,
                    icon: Icons.language,
                    onTap: () => _launchUrl('https://lonestill.uk'),
                  ),
                  _LinkButton(
                    label: AppLocalizations.of(context).telegram,
                    icon: Icons.send_outlined,
                    onTap: () => _launchUrl('https://t.me/lonestill'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                  child: Text(AppLocalizations.of(context).close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _LinkButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF3A3A4A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6366F1)),
            ),
          ],
        ),
      ),
    );
  }
}
