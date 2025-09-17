import 'package:get/get.dart';

class AlertItem {
  final String id;
  final String message;
  final DateTime timestamp;

  const AlertItem({
    required this.id,
    required this.message,
    required this.timestamp,
  });
}

class AlertsController extends GetxController {
  /// All alerts (replace with API results)
  final alerts = <AlertItem>[
    // Today (New)
    AlertItem(
      id: 'a1',
      message:
          'Boil due incentivize player-coach anomalies. Boil due incentivize player-coach anomalies. Boil due incentivize player-coach anomalies.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    AlertItem(
      id: 'a2',
      message:
          '2 hard fruit discussions sandwich playing methods. Boil due incentivize player-coach anomalies. Boil due incentivize player-coach anomalies.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 28)),
    ),
    AlertItem(
      id: 'a3',
      message:
          'Thought quarter hits these boil. Boil due incentivize player-coach anomalies. Boil due incentivize player-coach anomalies.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    // This week (older than today)
    AlertItem(
      id: 'b1',
      message:
          'Close about circle ditching economy pole w… Boil due incentivize player-coach anomalies. Boil due incentivize player-coach anomalies.',
      timestamp: DateTime.now().subtract(
        const Duration(days: 1, hours: 4, minutes: 6),
      ),
    ),
    AlertItem(
      id: 'b2',
      message:
          'About feature protocol first domains due. Boil due incentivize player-coach anomalies. Boil due incentivize player-coach anomalies.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 14)),
    ),
    AlertItem(
      id: 'b3',
      message:
          "What's meeting a alarming functional deep… Boil due incentivize player-coach anomalies. Boil due incentivize player-coach anomalies.",
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 18)),
    ),
    AlertItem(
      id: 'b4',
      message:
          'Weeks prioritize any staircase important. Boil due incentivize player-coach anomalies. Boil due incentivize player-coach anomalies.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AlertItem(
      id: 'b5',
      message:
          'Silently any were pain territories believe diligently. Boil due incentivize player-coach anomalies. Boil due incentivize player-coach anomalies.',
      timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 4)),
    ),
  ].obs;

  /// Track expand/collapse per alert
  final expandedById = <String, bool>{}.obs;

  bool get hasAlerts => alerts.isNotEmpty;

  int get totalCount => alerts.length;
  int get newCount => alerts.where(_isToday).length;
  List<AlertItem> get newAlerts => alerts.where(_isToday).toList();
  List<AlertItem> get weekAlerts => alerts
      .where((a) => !_isToday(a) && _withinThisWeek(a.timestamp))
      .toList();

  bool isExpanded(String id) => expandedById[id] ?? false;
  void toggle(String id) {
    expandedById[id] = !(expandedById[id] ?? false);
    expandedById.refresh();
  }

  bool _isToday(AlertItem a) {
    final now = DateTime.now();
    final t = a.timestamp;
    return t.year == now.year && t.month == now.month && t.day == now.day;
  }

  bool _withinThisWeek(DateTime t) {
    final now = DateTime.now();
    return t.isAfter(now.subtract(const Duration(days: 7)));
  }

  // Optional: clear all to test empty state
  void clearAll() => alerts.clear();
}
