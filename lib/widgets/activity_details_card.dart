import 'package:fitness_dashboard_ui/data/health_details.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/util/responsive.dart';
import 'package:fitness_dashboard_ui/widgets/custom_card_widget.dart';
import 'package:flutter/material.dart';

class ActivityDetailsCard extends StatelessWidget {
  const ActivityDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final healthDetails = HealthDetails();

    return GridView.builder(
      itemCount: healthDetails.healthData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) => CustomCard(
        color: MaternityTheme.lightPink,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MaternityTheme.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                healthDetails.healthData[index].icon,
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              healthDetails.healthData[index].value,
              style: MaternityTheme.headingStyle,
            ),
            const SizedBox(height: 4),
            Text(
              healthDetails.healthData[index].title,
              style: MaternityTheme.subheadingStyle,
            ),
          ],
        ),
      ),
    );
  }
}
