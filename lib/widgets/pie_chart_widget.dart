import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';

class SemiCircleGaugeChart extends StatefulWidget {
  const SemiCircleGaugeChart({super.key});

  @override
  State<SemiCircleGaugeChart> createState() => _SemiCircleGaugeChartState();
}

class _SemiCircleGaugeChartState extends State<SemiCircleGaugeChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 48).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {});
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = _animation.value;
    double filledValue = (percentage / 100) * 180;
    double emptyValue = 180 - filledValue;

    return Container(
      height: 230,
      width: 250,
      decoration: BoxDecoration(
        color: MaternityTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.5,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 65,
                  startDegreeOffset: 180,
                  sections: [
                    PieChartSectionData(
                      color: MaternityTheme.primaryPink,
                      value: filledValue,
                      showTitle: false,
                      radius: 45,
                    ),
                    PieChartSectionData(
                      color: MaternityTheme.lightPink,
                      value: emptyValue,
                      showTitle: false,
                      radius: 45,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Column(
              children: [
                Text(
                  "${percentage.toStringAsFixed(0)}%",
                  style: MaternityTheme.headingStyle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  "Oxygen Level",
                  style: MaternityTheme.subheadingStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
