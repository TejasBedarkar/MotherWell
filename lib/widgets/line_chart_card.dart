import 'package:fitness_dashboard_ui/data/line_chart_data.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/widgets/custom_card_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartCard extends StatelessWidget {
  const LineChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = HeartRateData();

    return CustomCard(
      color: MaternityTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Heart Rate", style: MaternityTheme.headingStyle),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 16 / 7,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                  ),
                ),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return data.leftTitle.containsKey(value.toInt())
                            ? Text(
                                data.leftTitle[value.toInt()].toString(),
                                style: MaternityTheme.subheadingStyle,
                              )
                            : const SizedBox();
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    color: MaternityTheme.primaryPink,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          MaternityTheme.primaryPink.withOpacity(0.3),
                          MaternityTheme.primaryPink.withOpacity(0.05),
                        ],
                      ),
                    ),
                    spots: data.spots,
                  ),
                ],
                minX: 1,
                maxX: 25,
                minY: 60,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
