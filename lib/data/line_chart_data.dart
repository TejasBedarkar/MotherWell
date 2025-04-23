import 'package:fl_chart/fl_chart.dart';

class HeartRateData {
  final spots = const [
    // Day 1: 2025-03-20
    FlSpot(1, 72), // 10:00 AM
    FlSpot(2, 75), // 11:00 AM
    FlSpot(3, 78), // 12:00 PM
    FlSpot(4, 76), // 1:00 PM
    FlSpot(5, 80), // 2:00 PM

    // Day 2: 2025-03-21
    FlSpot(6, 74), // 10:00 AM
    FlSpot(7, 79), // 11:00 AM
    FlSpot(8, 81), // 12:00 PM
    FlSpot(9, 77), // 1:00 PM
    FlSpot(10, 83), // 2:00 PM

    // Day 3: 2025-03-22
    FlSpot(11, 76), // 10:00 AM
    FlSpot(12, 80), // 11:00 AM
    FlSpot(13, 85), // 12:00 PM
    FlSpot(14, 79), // 1:00 PM
    FlSpot(15, 87), // 2:00 PM

    // Day 4: 2025-03-23
    FlSpot(16, 75), // 10:00 AM
    FlSpot(17, 78), // 11:00 AM
    FlSpot(18, 82), // 12:00 PM
    FlSpot(19, 80), // 1:00 PM
    FlSpot(20, 85), // 2:00 PM

    // Day 5: 2025-03-24
    FlSpot(21, 73), // 10:00 AM
    FlSpot(22, 76), // 11:00 AM
    FlSpot(23, 79), // 12:00 PM
    FlSpot(24, 81), // 1:00 PM
    FlSpot(25, 84), // 2:00 PM
  ];

  final leftTitle = {
    60: '60',
    70: '70',
    80: '80',
    90: '90',
    100: '100',
  };

  final bottomTitle = {
    1: '10 AM',
    2: '11 AM',
    3: '12 PM',
    4: '1 PM',
    5: '2 PM',
    6: '10 AM',
    7: '11 AM',
    8: '12 PM',
    9: '1 PM',
    10: '2 PM',
    11: '10 AM',
    12: '11 AM',
    13: '12 PM',
    14: '1 PM',
    15: '2 PM',
    16: '10 AM',
    17: '11 AM',
    18: '12 PM',
    19: '1 PM',
    20: '2 PM',
    21: '10 AM',
    22: '11 AM',
    23: '12 PM',
    24: '1 PM',
    25: '2 PM',
  };
}
