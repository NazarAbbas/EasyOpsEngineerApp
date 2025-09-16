import 'package:easy_ops/ui/modules/preventive_maintenance/preventive_maintenance_dashboard/models/preventive_maintenance_dashboard_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PreventiveMaintenanceDashboardController extends GetxController {
  // ---------------- UI state ----------------
  final loading = true.obs;
  final isRefreshing = false.obs;

  // Calendar state
  final selectedDay = DateTime.now().obs;
  final focusedDay = DateTime.now().obs;

  // Tabs / search
  final tabs = const ['Approved', 'Overdue', 'Pending', 'Completed'];
  final selectedTab = 0.obs;
  final query = ''.obs;

  // Data
  final orders = <PreventiveMaintenanceDashboardModel>[].obs;
  final visibleOrders = <PreventiveMaintenanceDashboardModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    everAll([orders, query, selectedTab], (_) => _recomputeVisible());
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    orders.assignAll(_mockOrders);
    loading.value = false;
    _recomputeVisible();
  }

  Future<void> refreshOrders() async {
    isRefreshing.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    final shuffled = orders.toList()..shuffle();
    orders.assignAll(shuffled);
    isRefreshing.value = false;
    _recomputeVisible();
  }

  // ---------------- Filters ----------------
  void setSelectedTab(int i) => selectedTab.value = i;
  void setQuery(String v) => query.value = v;

  void _recomputeVisible() {
    List<PreventiveMaintenanceDashboardModel> src = orders;

    switch (selectedTab.value) {
      case 0: // Approved
        src = src.where((o) => o.status == Status.approved).toList();
        break;
      case 1: // Overdue
        src = src.where(_isOverdue).toList();
        break;
      case 2: // Pending (but not overdue)
        src = src
            .where((o) => o.status == Status.pending && !_isOverdue(o))
            .toList();
        break;
      case 3: // Completed
        src = src.where((o) => o.status == Status.resolved).toList();
        break;
    }

    // Search filter
    final q = query.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      src = src.where((o) => o.title.toLowerCase().contains(q)).toList();
    }

    visibleOrders.assignAll(src);
  }

  bool _isOverdue(PreventiveMaintenanceDashboardModel o) {
    if (o.status != Status.pending) return false;
    if (o.dueBy == null || o.dueBy!.isEmpty) return false;
    final dt = DateTime.tryParse(o.dueBy!);
    if (dt == null) return false;
    final today = DateTime.now();
    final a = DateTime(dt.year, dt.month, dt.day);
    final b = DateTime(today.year, today.month, today.day);
    return a.isBefore(b);
  }

  // Calendar markers
  DateTime _d(DateTime d) => DateTime.utc(d.year, d.month, d.day);
  final Map<DateTime, List<MarkerEvent>> eventMap = {
    DateTime.utc(2025, 10, 30): [MarkerEvent(Colors.red)],
    DateTime.utc(2025, 10, 29): [MarkerEvent(Colors.orange)],
  };
  List<MarkerEvent> eventsFor(DateTime day) => eventMap[_d(day)] ?? [];
}

class MarkerEvent {
  final Color color;
  final String tag;
  MarkerEvent(this.color, [this.tag = '']);
}

// ---------------- Mock data ----------------
final _mockOrders = <PreventiveMaintenanceDashboardModel>[
  // Overdue (pending + due date in past)
  PreventiveMaintenanceDashboardModel(
    title: 'Half Yearly Comprehensive Maintenance',
    priority: Priority.high,
    status: Status.overdue,
    duration: '4H',
    machine: 'CNC-1',
    make: 'Siemens',
    planCode: 'PM-402',
    scheduleKind: ScheduleKind.dueBy,
    dueBy: '2024-10-30',
  ),
  // Approved
  PreventiveMaintenanceDashboardModel(
    title: 'Quarterly Safety Inspection',
    priority: Priority.high,
    status: Status.approved,
    duration: '2H',
    machine: 'CNC-2',
    make: 'Fanuc',
    planCode: 'PM-210',
    scheduleKind: ScheduleKind.scheduled,
    scheduledAt: '2025-10-10 10:00',
  ),
  // Completed
  PreventiveMaintenanceDashboardModel(
    title: 'Monthly Filter Replacement',
    priority: Priority.high,
    status: Status.resolved,
    duration: '1H',
    machine: 'Boiler-1',
    make: 'Bosch',
    planCode: 'PM-109',
    scheduleKind: ScheduleKind.scheduled,
    scheduledAt: '2025-09-10 14:00',
  ),
  // Pending but not overdue (future due date)
  PreventiveMaintenanceDashboardModel(
    title: 'Quarterly Lubrication Check',
    priority: Priority.high,
    status: Status.pending,
    duration: '2H',
    machine: 'CNC-3',
    make: 'Mitsubishi',
    planCode: 'PM-301',
    scheduleKind: ScheduleKind.dueBy,
    dueBy: '2030-01-10',
  ),
];
