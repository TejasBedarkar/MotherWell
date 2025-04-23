import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final List<Map<String, dynamic>> _healthLogs = [
    {'date': 'Today', 'weight': '65 kg', 'bloodPressure': '120/80', 'mood': '😊'},
    {'date': 'Yesterday', 'weight': '65.2 kg', 'bloodPressure': '118/78', 'mood': '😴'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Tracker',
            style: MaternityTheme.headingStyle.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildQuickLogCard('Weight', '65 kg', Icons.monitor_weight_outlined),
              _buildQuickLogCard('Blood Pressure', '120/80', Icons.favorite_outline),
              _buildQuickLogCard('Sleep', '8h 30m', Icons.bedtime_outlined),
              _buildQuickLogCard('Water', '2.5L', Icons.water_drop_outlined),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Logs',
            style: MaternityTheme.headingStyle,
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _healthLogs.length,
            itemBuilder: (context, index) {
              final log = _healthLogs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: MaternityTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: MaternityTheme.primaryPink.withOpacity(0.1)),
                ),
                child: ListTile(
                  title: Text(
                    log['date'],
                    style: TextStyle(
                      color: MaternityTheme.primaryPink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Weight: ${log['weight']} • BP: ${log['bloodPressure']}',
                    style: TextStyle(color: MaternityTheme.textLight),
                  ),
                  trailing: Text(
                    log['mood'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLogCard(String title, String value, IconData icon) {
    return Card(
      color: MaternityTheme.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: MaternityTheme.primaryPink, size: 32),
            const SizedBox(height: 8),
            Text(title, style: MaternityTheme.subheadingStyle),
            Text(value, style: MaternityTheme.headingStyle),
          ],
        ),
      ),
    );
  }
}