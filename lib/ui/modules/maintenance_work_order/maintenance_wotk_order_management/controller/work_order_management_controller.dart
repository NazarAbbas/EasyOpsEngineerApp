import 'package:easy_ops/ui/modules/maintenance_work_order/maintenance_wotk_order_management/models/work_order.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkOrdersManagementController extends GetxController {
  // ---------------- UI state ----------------
  final loading = true.obs; // first-load spinner
  final isRefreshing = false.obs; // pull-to-refresh spinner (if you show one)

  // Calendar state
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;

  // Tabs / search
  final tabs = const ['Today', 'Open', 'Escalated', 'Critical'];
  final selectedTab = 0.obs;
  final query = ''.obs;

  // Data
  final orders = <WorkOrder>[].obs; // full dataset
  final visibleOrders = <WorkOrder>[].obs; // filtered for UI

  // ---------------- Lifecycle ----------------
  @override
  void onInit() {
    super.onInit();

    // Recompute visible list whenever any of these change
    everAll([orders, query, selectedTab], (_) => _recomputeVisible());

    // First load (simulate API)
    _loadInitial();
  }

  // ---------------- API Simulations ----------------
  Future<void> _loadInitial() async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 900));

    // Mock data (replace with your API result)
    orders.assignAll(_mockOrders);

    loading.value = false;
    _recomputeVisible();
  }

  /// Pull-to-refresh handler used by the UI (RefreshIndicator, etc).
  Future<void> refreshOrders() async {
    isRefreshing.value = true;
    await Future.delayed(const Duration(milliseconds: 900));

    // TODO: Replace with repository/API call
    // For demo: shuffle to show change
    final shuffled = orders.toList()..shuffle();
    orders.assignAll(shuffled);

    isRefreshing.value = false;
    _recomputeVisible();
  }

  // ---------------- Filters ----------------
  void setSelectedTab(int i) => selectedTab.value = i;
  void setQuery(String v) => query.value = v;

  void _recomputeVisible() {
    List<WorkOrder> src = orders;

    // 1) Filter by tab
    switch (selectedTab.value) {
      case 0: // Today
        // If your model had DateTime, you'd compare to selectedDay.
        // With string dates like '09 Aug', we'll just passthrough for now.
        // Customize here when you have a proper date field.
        break;
      case 1: // Open
        src = src.where((w) => !_isResolved(w)).toList();
        break;
      case 2: // Escalated
        src = src
            .where((w) => (w.footerTag).toLowerCase().contains('escalated'))
            .toList();
        break;
      case 3: // Critical
        src = src.where((w) => w.priority == Priority.high).toList();
        break;
    }

    // 2) Filter by search query (title)
    final q = query.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      src = src.where((w) => w.title.toLowerCase().contains(q)).toList();
    }

    visibleOrders.assignAll(src);
  }

  bool _isResolved(WorkOrder w) => w.priority == Priority.high;

  // ---------------- Calendar markers (TableCalendar) ----------------
  DateTime _d(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  final Map<DateTime, List<MarkerEvent>> eventMap = {
    DateTime.utc(2025, 8, 25): [
      MarkerEvent(Colors.red),
      MarkerEvent(Colors.red),
    ],
    DateTime.utc(2025, 9, 6): [MarkerEvent(Colors.amber)],
    DateTime.utc(2025, 9, 10): [MarkerEvent(Colors.blue)],
    DateTime.utc(2025, 9, 14): [
      MarkerEvent(Colors.red),
      MarkerEvent(Colors.red),
      MarkerEvent(Colors.red),
    ],
    DateTime.utc(2025, 9, 26): [
      MarkerEvent(Colors.red),
      MarkerEvent(Colors.red),
    ],
  };

  List<MarkerEvent> eventsFor(DateTime day) => eventMap[_d(day)] ?? [];
}

// Simple event marker for the calendar
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
    department: 'Mechanical',
    line: 'CNC - 1',
    priority: Priority.high,
    status: Status.inProgress,
    duration: '3h 20m',
    footerTag: 'Escalated',
  ),
  WorkOrder(
    title:
        'Hydraulic Press Not Generating Adequate Force and Conveyor Belt Stopped Abruptly During Operation',
    code: 'BD-118',
    time: '14:12',
    date: '10 Aug',
    department: 'Electrical',
    line: 'CNC - 7',
    priority: Priority.high,
    status: Status.resolved,
    duration: '1h 20m',
    footerTag: '',
  ),
  WorkOrder(
    title: 'Unusual Grinding Noise from CNC Assets During Cutting',
    code: 'BD-131',
    time: '09:45',
    date: '11 Aug',
    department: 'Mechanical',
    line: 'CNC - 1',
    priority: Priority.high,
    status: Status.inProgress,
    duration: '3h 20m',
    footerTag: 'Escalated',
  ),
  WorkOrder(
    title: 'Unusual Grinding Noise from CNC Assets During Cutting',
    code: 'BD-131',
    time: '09:45',
    date: '11 Aug',
    department: 'Mechanical',
    line: 'CNC - 1',
    priority: Priority.high,
    status: Status.inProgress,
    duration: '3h 20m',
    footerTag: 'Critial',
  ),
];
