import 'package:fitness_dashboard_ui/data/schedule_task_data.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/widgets/custom_card_widget.dart';
import 'package:flutter/material.dart';

class Scheduled extends StatelessWidget {
  const Scheduled({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ScheduleTasksData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Appointments",
          style: MaternityTheme.headingStyle,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.scheduled.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                color: MaternityTheme.white,
                child: Stack(
                  children: [
                    Container(
                      width: 4,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: MaternityTheme.primaryPink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.scheduled[index].title,
                            style: MaternityTheme.headingStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: MaternityTheme.textLight,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data.scheduled[index].date,
                                style: MaternityTheme.subheadingStyle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
