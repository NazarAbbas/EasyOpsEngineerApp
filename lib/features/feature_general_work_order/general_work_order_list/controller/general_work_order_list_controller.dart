import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralWorkOrderListController extends GetxController {
  // ---------------- UI state ----------------
  final loading = true.obs;
  final isRefreshing = false.obs;

  // Calendar state
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;

  // Tabs / search
  final tabs = const ['All', 'Open', 'Closed'];
  final selectedTab = 0.obs;
  final query = ''.obs;

  // Data
  final orders = <WorkOrder>[].obs;
  final visibleOrders = <WorkOrder>[].obs;

  @override
  void onInit() {
    super.onInit();
    everAll([orders, query, selectedTab], (_) => _recomputeVisible());
    _loadInitial();
  }

  void goToAnotherScreen(WorkOrder order) {
    // if (order.status.name == 'inprogress') {
    //   Get.toNamed(Routes.updateWorkOrderTabScreen, arguments: order);
    // } else {
    //   Get.toNamed(Routes.workOrderDetailsTabScreen, arguments: order);
    // }
    Get.toNamed(Routes.generalWorkOrderDetailScreen, arguments: order);
  }

  Future<void> _loadInitial() async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    orders.assignAll(_mockOrders);
    loading.value = false;
    _recomputeVisible();
  }

  Future<void> refreshOrders() async {
    isRefreshing.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    orders.assignAll(orders.toList()..shuffle());
    isRefreshing.value = false;
    _recomputeVisible();
  }

  void setSelectedTab(int i) => selectedTab.value = i;
  void setQuery(String v) => query.value = v;

  void _recomputeVisible() {
    List<WorkOrder> src = orders;

    switch (selectedTab.value) {
      case 1: // Open
        src = src.where((w) => w.status == Status.open).toList();
        break;
      case 2: // Closed
        src = src.where((w) => w.status == Status.closed).toList();
        break;
      default:
        break;
    }

    final q = query.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      src = src.where((w) => w.title.toLowerCase().contains(q)).toList();
    }

    visibleOrders.assignAll(src);
  }

  // Calendar markers
  DateTime _d(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  final Map<DateTime, List<MarkerEvent>> eventMap = {
    DateTime.utc(2025, 8, 25): [
      MarkerEvent(Colors.red),
      MarkerEvent(Colors.red),
    ],
    DateTime.utc(2025, 9, 6): [MarkerEvent(Colors.amber)],
    DateTime.utc(2025, 9, 10): [MarkerEvent(Colors.blue)],
  };

  List<MarkerEvent> eventsFor(DateTime day) => eventMap[_d(day)] ?? [];
}

class MarkerEvent {
  final Color color;
  final String tag;
  MarkerEvent(this.color, [this.tag = '']);
}

// ---------------- Mock data ----------------
final _mockOrders = <WorkOrder>[
  WorkOrder(
    title: 'Conveyor Belt Stopped Abruptly During Operation',
    code: 'BD-102',
    time: '18:08',
    date: '09 Aug',
    line: 'CNC - 1',
    priority: Priority.high,
    status: Status.open,
  ),
  WorkOrder(
    title: 'Hydraulic Press Not Generating Adequate Force',
    code: 'BD-118',
    time: '14:12',
    date: '10 Aug',
    line: 'CNC - 7',
    priority: Priority.high,
    status: Status.closed,
  ),
];

enum Priority { high }

enum Status { open, closed, none }

extension StatusX on Status {
  String get text => switch (this) {
    Status.open => 'Open',
    Status.closed => 'Closed',
    Status.none => '',
  };

  Color get color => switch (this) {
    Status.open => AppColors.primary,
    Status.closed => AppColors.successGreen,
    Status.none => Colors.transparent,
  };
}

class WorkOrder {
  final String title;
  final String code;
  final String time;
  final String date;
  final String line;
  final Priority priority;
  final Status status;

  WorkOrder({
    required this.title,
    required this.code,
    required this.time,
    required this.date,
    required this.line,
    required this.priority,
    required this.status,
  });
}
