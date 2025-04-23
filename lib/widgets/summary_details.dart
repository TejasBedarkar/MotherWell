import 'package:fitness_dashboard_ui/widgets/custom_card_widget.dart';
import 'package:flutter/material.dart';

class SummaryDetails extends StatelessWidget {
  const SummaryDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: const Color.fromARGB(255, 247, 175, 199),
      child: Container(), // Removed the details section
    );
  }
}
