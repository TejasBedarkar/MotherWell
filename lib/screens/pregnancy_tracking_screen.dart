import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/data/pregnancy_updates.dart';

class PregnancyTrackingScreen extends StatefulWidget {
  const PregnancyTrackingScreen({super.key});

  @override
  State<PregnancyTrackingScreen> createState() => _PregnancyTrackingScreenState();
}

class _PregnancyTrackingScreenState extends State<PregnancyTrackingScreen> {
  DateTime? _dueDate;
  int _weeksPregant = 0;
  List<DateTime> _kickTimes = [];
  List<Map<String, dynamic>> _contractions = [];
  bool _isTimingContraction = false;
  DateTime? _contractionStart;
  Map<String, String>? _weeklyUpdate;  // Move this declaration here

  void _calculateWeeks() {
    if (_dueDate != null) {
      final difference = _dueDate!.difference(DateTime.now());
      _weeksPregant = 40 - (difference.inDays ~/ 7);
      _updateWeeklyInfo();
    }
  }

  String _getBabySize() {
    final sizes = {
      8: 'Raspberry (1.6 cm)',
      12: 'Lime (5.4 cm)',
      16: 'Avocado (11.6 cm)',
      20: 'Banana (16.5 cm)',
      24: 'Corn (21.6 cm)',
      28: 'Eggplant (35.6 cm)',
      32: 'Squash (40.3 cm)',
      36: 'Honeydew melon (45.7 cm)',
      40: 'Small pumpkin (51 cm)',
    };
    
    for (var week in sizes.keys) {
      if (_weeksPregant <= week) {
        return sizes[week]!;
      }
    }
    return sizes[40]!;
  }

  Widget _buildDueDateCalculator() {
    return Card(
      elevation: 0,
      color: MaternityTheme.white, // Add this
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: MaternityTheme.primaryPink.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: MaternityTheme.primaryPink,
                ),
                const SizedBox(width: 12),
                Text(
                  'Due Date Calculator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MaternityTheme.primaryPink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 280)),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                    _calculateWeeks();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MaternityTheme.primaryPink,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _dueDate == null 
                    ? 'Select Your Due Date'
                    : 'Update Due Date',
                style: const TextStyle(fontSize: 16,
                color: Colors.white),
                
              ),
            ),
            if (_dueDate != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildInfoCard(
                    'Baby Size',
                    _getBabySize(),
                    Icons.child_care,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKickCounter() {
    final todayKicks = _kickTimes.where((kick) => kick.day == DateTime.now().day).length;
    
    return SizedBox(
      height: 280, // Fixed height
      child: Card(
        elevation: 0,
        color: MaternityTheme.white, // Add this
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: MaternityTheme.primaryPink.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.baby_changing_station, color: MaternityTheme.primaryPink),
                  const SizedBox(width: 12),
                  Text(
                    'Kick Counter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MaternityTheme.lightPink.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          todayKicks.toString(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: MaternityTheme.primaryPink,
                          ),
                        ),
                        Text(
                          'kicks today',
                          style: TextStyle(
                            color: MaternityTheme.primaryPink,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _kickTimes.add(DateTime.now());
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MaternityTheme.primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Record Kick',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContractionTimer() {
    return SizedBox(
      height: 280, // Fixed height
      child: Card(
        elevation: 0,
        color: MaternityTheme.white, // Add this
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: MaternityTheme.primaryPink.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.timer, color: MaternityTheme.primaryPink),
                  const SizedBox(width: 12),
                  Text(
                    'Contraction\nTimer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                    ),
                  ),
                ],
              ),
              // Content
              Expanded(
                child: Center(
                  child: _contractions.isNotEmpty
                      ? SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildContractionInfo('Duration', 
                                '${_contractions.last['duration']} sec', 
                                Icons.hourglass_bottom),
                              const SizedBox(height: 12),
                              _buildContractionInfo('Interval', 
                                '${_contractions.length > 1 ? _contractions.last['interval'] : 'N/A'} min', 
                                Icons.repeat),
                            ],
                          ),
                        )
                      : Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: MaternityTheme.lightPink.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.timer_outlined,
                              size: 48,
                              color: MaternityTheme.primaryPink,
                            ),
                          ),
                        ),
                ),
              ),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_isTimingContraction) {
                      _contractionStart = DateTime.now();
                    } else {
                      final duration = DateTime.now().difference(_contractionStart!).inSeconds;
                      final interval = _contractions.isNotEmpty
                          ? DateTime.now().difference(_contractions.last['endTime']).inMinutes
                          : 0;
                      
                      setState(() {
                        _contractions.add({
                          'startTime': _contractionStart,
                          'endTime': DateTime.now(),
                          'duration': duration,
                          'interval': interval,
                        });
                      });
                    }
                    setState(() {
                      _isTimingContraction = !_isTimingContraction;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTimingContraction ? Colors.red : MaternityTheme.primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isTimingContraction ? 'Stop Timer' : 'Start Timer',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContractionInfo(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MaternityTheme.lightPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: MaternityTheme.primaryPink, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: MaternityTheme.primaryPink,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: MaternityTheme.primaryPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add this method after _calculateWeeks()
  void _updateWeeklyInfo() {
    if (_weeksPregant > 0) {
      for (var week in PregnancyUpdates.weeklyUpdates.keys.toList()..sort()) {
        if (_weeksPregant <= week) {
          setState(() => _weeklyUpdate = PregnancyUpdates.weeklyUpdates[week]);
          break;
        }
      }
    }
  }

  // Add this widget before _buildKickCounter
  Widget _buildWeeklyUpdate() {
    if (_weeklyUpdate == null) return const SizedBox();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: MaternityTheme.primaryPink.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.update, color: MaternityTheme.primaryPink),
                const SizedBox(width: 12),
                Text(
                  'Week $_weeksPregant Updates',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MaternityTheme.primaryPink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildWeeklyUpdateCard(
              'Baby Development',
              _weeklyUpdate!['baby']!,
              Icons.child_care,
              MaternityTheme.primaryPink.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            _buildWeeklyUpdateCard(
              'Growth Progress',
              _weeklyUpdate!['development']!,
              Icons.trending_up,
              MaternityTheme.lightPink.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            _buildWeeklyUpdateCard(
              'Mother\'s Changes',
              _weeklyUpdate!['mother']!,
              Icons.favorite,
              MaternityTheme.primaryPink.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyUpdateCard(String title, String content, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MaternityTheme.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: MaternityTheme.primaryPink, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: MaternityTheme.primaryPink,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: MaternityTheme.textLight,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Pregnancy Journey',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: MaternityTheme.primaryPink,
              ),
            ),
            Text(
              'Track your beautiful journey to motherhood',
              style: TextStyle(
                fontSize: 16,
                color: MaternityTheme.textLight,
              ),
            ),
            const SizedBox(height: 32),
            if (_dueDate != null) _buildProgressIndicator(),
            const SizedBox(height: 24),
            _buildDueDateCalculator(),
            if (_weeklyUpdate != null) ...[
              const SizedBox(height: 24),
              _buildWeeklyUpdate(),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildKickCounter()),
                const SizedBox(width: 16),
                Expanded(child: _buildContractionTimer()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MaternityTheme.primaryPink.withOpacity(0.2),
            MaternityTheme.lightPink.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week $_weeksPregant',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MaternityTheme.primaryPink,
                    ),
                  ),
                  Text(
                    'of 40 weeks',
                    style: TextStyle(
                      color: MaternityTheme.textLight,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Due Date',
                    style: TextStyle(
                      color: MaternityTheme.textLight,
                    ),
                  ),
                  Text(
                    _dueDate!.toString().split(' ')[0],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: MaternityTheme.primaryPink,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _weeksPregant / 40,
            backgroundColor: MaternityTheme.lightPink.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(MaternityTheme.primaryPink),
          ),
        ],
      ),
    );
  }

  
  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MaternityTheme.lightPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: MaternityTheme.primaryPink),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: MaternityTheme.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle( // Update this
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: MaternityTheme.primaryPink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
