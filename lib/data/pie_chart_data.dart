import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GaugeChartData {
  final List<PieChartSectionData> sections = [
    PieChartSectionData(
      color: Colors.green, // Represents SpO2 level
      value: 40,
      showTitle: false,
      radius: 40,
    ),
    PieChartSectionData(
      color: Colors.grey.withOpacity(0.3), // Remaining part
      value: 60,
      showTitle: false,
      radius: 40,
    ),
  ];
}
