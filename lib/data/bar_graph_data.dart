import 'package:fitness_dashboard_ui/model/bar_graph_model.dart';
import 'package:fitness_dashboard_ui/model/graph_model.dart';
import 'package:flutter/material.dart';

class BarGraphData {
  final data = [
    const BarGraphModel(
        label: "Activity Level",
        color: Color.fromARGB(255, 255, 255, 255),
        graph: [
          GraphModel(x: 0, y: 8),
          GraphModel(x: 1, y: 10),
          GraphModel(x: 2, y: 7),
          GraphModel(x: 3, y: 4),
          GraphModel(x: 4, y: 4),
          GraphModel(x: 5, y: 6),
        ]),
    const BarGraphModel(
        label: "Sleep score",
        color: Color.fromARGB(255, 255, 255, 255),
        graph: [
          GraphModel(x: 0, y: 8),
          GraphModel(x: 1, y: 10),
          GraphModel(x: 2, y: 9),
          GraphModel(x: 3, y: 6),
          GraphModel(x: 4, y: 6),
          GraphModel(x: 5, y: 7),
        ]),
    const BarGraphModel(
        label: "Stress score",
        color: Color.fromARGB(255, 255, 255, 255),
        graph: [
          GraphModel(x: 0, y: 7),
          GraphModel(x: 1, y: 10),
          GraphModel(x: 2, y: 7),
          GraphModel(x: 3, y: 4),
          GraphModel(x: 4, y: 4),
          GraphModel(x: 5, y: 10),
        ]),
  ];

  final label = ['M', 'T', 'W', 'T', 'F', 'S'];
}
