import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MyDashboardController extends GetxController {
  // Month axis
  final months = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // Charts data (mocked like the screenshot)
  final breakdownHrs = <double>[
    120,
    280,
    620,
    880,
    940,
    420,
    300,
    900,
    280,
    610,
    640,
    660,
  ].obs;

  // Negative/positive bars (Spares Consumption $)
  final sparesConsumption = <double>[
    200,
    4900,
    -5600,
    900,
    1800,
    500,
    -1500,
    400,
    -2200,
    100,
    600,
    900,
  ].obs;

  // Pareto-like (machines)
  final paretoLabels = const [
    'CNC1',
    'CNC2',
    'CNC3',
    'CNC4',
    'CNC5',
    'CNC6',
    'CNC7',
    'CNC8',
    'CNC9',
    'CNC10',
    'CNC11',
    'CNC12',
    'CNC13',
    'CNC14',
    'CNC15',
    'CNC16',
    'CNC17',
  ];
  final paretoValues = <double>[
    16,
    16,
    15,
    15,
    12,
    12,
    12,
    8,
    6,
    6,
    5,
    4,
    3,
    3,
    0,
    0,
    0,
  ].obs;

  // Category breakdown
  final categories = const [
    'Electrical',
    'Mechanical',
    'Utilities',
    'Safety',
    'General',
  ];
  final categoryValues = <double>[300, 120, 90, 24, 23].obs;

  // UI helpers
  bool get isTablet =>
      Get.context != null &&
      MediaQuery.of(Get.context!).size.shortestSide >= 600;
}
