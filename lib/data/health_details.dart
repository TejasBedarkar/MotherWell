import 'package:fitness_dashboard_ui/model/health_model.dart';

class HealthDetails {
  final healthData = const [
    HealthModel(
        icon: 'assets/icons/temperature.png',
        value: "98.56",
        title: "Temperature"),
    HealthModel(icon: 'assets/icons/steps.png', value: "7,083", title: "Steps"),
    HealthModel(
        icon: 'assets/icons/distance.png', value: "5km", title: "Distance"),
    HealthModel(icon: 'assets/icons/bp.png', value: "120/80", title: "BP"),
  ];
}
