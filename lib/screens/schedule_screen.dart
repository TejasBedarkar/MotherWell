import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _firstDay = DateTime.now().subtract(const Duration(days: 365));
    _lastDay = DateTime.now().add(const Duration(days: 365));
    
    // Sample appointments with proper date handling
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _events = {
      today: ['Prenatal Checkup - 10:00 AM'],
      today.add(const Duration(days: 7)): ['Ultrasound - 2:00 PM'],
      today.add(const Duration(days: 14)): ['Nutrition Consultation - 11:30 AM'],
    };
  }

  List<String> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Your Schedule',
              style: MaternityTheme.headingStyle.copyWith(fontSize: 24),
            ),
          ),
          Card(
            elevation: 0,
            color: MaternityTheme.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: TableCalendar(
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: MaternityTheme.primaryPink,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: MaternityTheme.lightPink,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: MaternityTheme.primaryPink,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: MaternityTheme.headingStyle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_getEventsForDay(_selectedDay).isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                'Appointments',
                style: MaternityTheme.headingStyle,
              ),
            ),
            ..._getEventsForDay(_selectedDay).map((event) => Card(
                  elevation: 0,
                  color: MaternityTheme.white,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.event, color: MaternityTheme.primaryPink),
                    title: Text(event),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder set for this appointment'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // Show options menu
                          },
                        ),
                      ],
                    ),
                  ),
                )),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No appointments for this day',
                  style: MaternityTheme.subheadingStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}