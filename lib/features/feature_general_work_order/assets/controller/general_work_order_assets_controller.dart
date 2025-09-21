// general_work_orders_combined_page.dart
// Single screen: KPI strip + 3 Excel-like charts + work-order list.
// Pure Flutter (CustomPainter), GetX for state.

import 'package:easy_ops/features/feature_general_work_order/tabs/controller/general_work_order_details_tabs_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/* =========================== Palette / Tokens =========================== */

const kTextPrimary = Color(0xFF101828);
const kTextMuted = Color(0xFF6B7280);
const kBlue = Color(0xFF1E4FD6);
const kBorder = Color(0xFFE9EEF5);
const kInner = Color(0xFFF2F4F7);
const kBgPlot = Color(0xFFF8FAFD);
const kGrid = Color(0xFFE5E7EB);
const kRedLine = Color(0xFFE53935);

/* ================================ Model ================================ */

class WOItem {
  final String date; // e.g. "09 Aug 2024"
  final String type; // "Breakdown" / "Preventive"
  final String category; // "Mechanical" / "Scheduled"
  final String title; // multi-line title
  final String assignee; // "Rahul Singh"
  final String duration; // "03h 20m"
  const WOItem({
    required this.date,
    required this.type,
    required this.category,
    required this.title,
    required this.assignee,
    required this.duration,
  });
}

/* ============================== Controller ============================= */

class GeneralWorkOrderAssetsController extends GetxController {
  final loading = true.obs;

  // KPI
  final mtbfDays = 110.obs;
  final bdHours = 17.obs;
  final mttrHrs = 2.4.obs;
  final criticality = 'Semi'.obs;

  // Chart 1 + 2 common months (Jan..Dec)
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

  // Chart 1: Breakdown 0..1000
  final breakdown1000 = <double>[
    280,
    620,
    910,
    650,
    1000,
    1000,
    460,
    1000,
    320,
    780,
    540,
    600,
  ];
  final breakdownTarget = 250.0;

  // Chart 2: Spares ±6000 (blue up/down, red zero)
  final spares = <double>[
    1200,
    -1800,
    4800,
    -5200,
    2000,
    900,
    700,
    300,
    2100,
    -1200,
    600,
    700,
  ];

  // Chart 3: compact “Breadown Hrs”
  final cncLabels = const [
    'CNC21',
    'CNC 18',
    'CNC',
    'CNC 2',
    'CNC 10',
    'CNC 12',
    'CNC 9',
    'CNC 13',
    'CNC',
    'CNC 8',
    'CNC 5',
    'CNC 14',
    'CNC 3',
    'CNC 7',
  ];
  final smallBreakdown = <double>[
    16,
    15,
    15,
    12,
    12,
    12,
    8,
    6,
    5,
    4,
    3,
    3,
    0,
    0,
  ];

  // List items
  final items = const <WOItem>[
    WOItem(
      date: '09 Aug 2024',
      type: 'Breakdown',
      category: 'Mechanical',
      title: 'Safety Guard on Equipment Found Damaged and Needs Replacement',
      assignee: 'Rahul Singh',
      duration: '03h 20m',
    ),
    WOItem(
      date: '10 Jul 2024',
      type: 'Preventive',
      category: 'Scheduled',
      title:
          'CNC Assets spindle speed fluctuating during precision cutting operations',
      assignee: 'Rahul Singh',
      duration: '08h 00m',
    ),
    WOItem(
      date: '09 Aug 2024',
      type: 'Breakdown',
      category: 'Mechanical',
      title: 'Unusual vibration in motor shaft during operation',
      assignee: 'Rahul Singh',
      duration: '01h 30m',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _fakeLoad();
  }

  Future<void> _fakeLoad() async {
    await Future.delayed(const Duration(milliseconds: 600));
    loading.value = false;
  }

  void goBack(int i) => Get.find<GenreralOrderDetailsTabsController>().goTo(i);
}
