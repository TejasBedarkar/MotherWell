import 'package:fitness_dashboard_ui/widgets/pie_chart_widget.dart';
import 'package:fitness_dashboard_ui/widgets/scheduled_widget.dart';
import 'package:fitness_dashboard_ui/widgets/summary_details.dart';
import 'package:flutter/material.dart';

class SummaryWidget extends StatelessWidget {
  const SummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
        color: const Color.fromARGB(255, 247, 175, 199),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            SemiCircleGaugeChart(),
            SizedBox(height: 16),
            SummaryDetails(),
            SizedBox(height: 40),
            Scheduled(),
          ],
        ),
      ),
    );
  }
}
