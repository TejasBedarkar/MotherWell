import 'package:fitness_dashboard_ui/data/bar_graph_data.dart';
import 'package:fitness_dashboard_ui/model/graph_model.dart';
import 'package:fitness_dashboard_ui/theme/maternity_theme.dart';
import 'package:fitness_dashboard_ui/widgets/custom_card_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarGraphCard extends StatefulWidget {
  const BarGraphCard({super.key});

  @override
  State<BarGraphCard> createState() => _BarGraphCardState();
}

class _BarGraphCardState extends State<BarGraphCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barGraphData = BarGraphData();

    return GridView.builder(
      itemCount: barGraphData.data.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 5 / 4,
      ),
      itemBuilder: (context, index) {
        return CustomCard(
          color: MaternityTheme.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                barGraphData.data[index].label,
                style: MaternityTheme.headingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ScaleTransition(
                  scale: _animation,
                  child: BarChart(
                    BarChartData(
                      barGroups: _chartGroups(
                        points: barGraphData.data[index].graph,
                        color: MaternityTheme.primaryPink,
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < barGraphData.label.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    barGraphData.label[value.toInt()],
                                    style: MaternityTheme.subheadingStyle.copyWith(fontSize: 12),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _chartGroups({
    required List<GraphModel> points,
    required Color color,
  }) {
    return points.map((point) {
      return BarChartGroupData(
        x: point.x.toInt(),
        barRods: [
          BarChartRodData(
            toY: point.y,
            width: 12,
            color: color.withOpacity(point.y.toInt() > 4 ? 1 : 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }
}
