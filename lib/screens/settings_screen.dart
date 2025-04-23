import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;
  String _language = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Language', style: MaternityTheme.headingStyle),
              const SizedBox(height: 20),
              ...List.generate(
                _languages.length,
                (index) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _languages[index],
                    style: MaternityTheme.headingStyle.copyWith(fontSize: 16),
                  ),
                  trailing: _languages[index] == _language
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MaternityTheme.lightPink,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, color: MaternityTheme.primaryPink, size: 16),
                        )
                      : null,
                  onTap: () {
                    setState(() => _language = _languages[index]);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: MaternityTheme.headingStyle.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: MaternityTheme.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: MaternityTheme.primaryPink.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    'Notifications',
                    'Get important updates',
                    Icons.notifications_outlined,
                    trailing: Switch.adaptive(
                      value: _notifications,
                      onChanged: (value) => setState(() => _notifications = value),
                      activeColor: MaternityTheme.primaryPink,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    'Dark Mode',
                    'Enable dark theme',
                    Icons.dark_mode_outlined,
                    trailing: Switch.adaptive(
                      value: _darkMode,
                      onChanged: (value) => setState(() => _darkMode = value),
                      activeColor: MaternityTheme.primaryPink,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    'Language',
                    _language,
                    Icons.language_outlined,
                    onTap: _showLanguageDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: MaternityTheme.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: MaternityTheme.primaryPink.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    'Privacy Policy',
                    'Read our privacy policy',
                    Icons.privacy_tip_outlined,
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    'Terms of Service',
                    'View terms of service',
                    Icons.description_outlined,
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    'App Version',
                    '1.0.0',
                    Icons.info_outline,
                    showArrow: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, color: MaternityTheme.primaryPink),
                    const SizedBox(width: 8),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: MaternityTheme.primaryPink,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon,
      {Widget? trailing, VoidCallback? onTap, bool showArrow = true}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: MaternityTheme.lightPink.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: MaternityTheme.primaryPink),
      ),
      title: Text(
        title,
        style: MaternityTheme.headingStyle.copyWith(fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: MaternityTheme.subheadingStyle,
      ),
      trailing: trailing ??
          (showArrow
              ? Icon(Icons.arrow_forward_ios,
                  size: 16, color: MaternityTheme.textLight)
              : null),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: MaternityTheme.lightPink.withOpacity(0.1),
      indent: 20,
      endIndent: 20,
    );
  }
}