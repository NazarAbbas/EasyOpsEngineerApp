import 'package:get/get.dart';

enum Priority { low, medium, high }

class SpareLine {
  String partNo;
  int qty;
  SpareLine({required this.partNo, required this.qty});
}

class SpareTicket {
  final String id; // unique
  final String bdNo; // BD - 102
  final DateTime createdAt; // 18:08 | 09 Aug
  final String machine; // CNC -1

  final String issueTitle; // Latency Issue ...
  final String department; // Mechanical
  final bool resolved;
  final String agingText; // 3h 20m
  final Priority priority;

  final List<SpareLine> lines; // items to return

  SpareTicket({
    required this.id,
    required this.bdNo,
    required this.createdAt,
    required this.machine,
    required this.issueTitle,
    required this.department,
    required this.resolved,
    required this.agingText,
    required this.priority,
    required this.lines,
  });

  int get totalQty => lines.fold(0, (p, e) => p + e.qty);
}

class ReturnSparePartsController extends GetxController {
  final tabIndex = 0.obs;

  final returns = <SpareTicket>[
    SpareTicket(
      id: 't1',
      bdNo: 'BD - 102',
      createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
      machine: 'CNC -1',
      issueTitle: 'Latency Issue in web browser',
      department: 'Mechanical',
      resolved: true,
      agingText: '3h 20m',
      priority: Priority.high,
      lines: [
        SpareLine(partNo: 'J122338812', qty: 1),
        SpareLine(partNo: 'J122338812', qty: 1),
        SpareLine(partNo: 'J122338812', qty: 1),
        SpareLine(partNo: 'J122338812', qty: 2),
      ],
    ),
    SpareTicket(
      id: 't2',
      bdNo: 'BD - 102',
      createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
      machine: 'CNC -1',
      issueTitle: 'Hydraulic pressure unstable',
      department: 'Mechanical',
      resolved: false,
      agingText: '1h 05m',
      priority: Priority.medium,
      lines: [
        SpareLine(partNo: 'X445531', qty: 3),
        SpareLine(partNo: 'X445532', qty: 1),
      ],
    ),
    SpareTicket(
      id: 't3',
      bdNo: 'BD - 102',
      createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
      machine: 'CNC -1',
      issueTitle: 'Coolant pump noise',
      department: 'Mechanical',
      resolved: false,
      agingText: '42m',
      priority: Priority.low,
      lines: [SpareLine(partNo: 'P998812', qty: 5)],
    ),
  ].obs;

  // simple placeholder data for Consumed tab
  final consumed = <SpareLine>[
    SpareLine(partNo: 'AA-77881', qty: 2),
    SpareLine(partNo: 'BB-33221', qty: 1),
    SpareLine(partNo: 'CC-90110', qty: 4),
  ].obs;

  /// expansion state by ticket id
  final expanded = <String, bool>{}.obs;
  bool isExpanded(String id) => expanded[id] ?? false;
  void toggleExpand(String id) {
    expanded[id] = !(expanded[id] ?? false);
    expanded.refresh();
  }

  // actions
  void editQty(String ticketId, int lineIndex) {
    final t = returns.firstWhereOrNull((e) => e.id == ticketId);
    if (t == null) return;
    final current = t.lines[lineIndex].qty;
    final newQty = (current + 1).clamp(1, 999); // demo: +1
    t.lines[lineIndex].qty = newQty;
    returns.refresh();
  }

  void deleteLine(String ticketId, int lineIndex) {
    final t = returns.firstWhereOrNull((e) => e.id == ticketId);
    if (t == null) return;
    if (t.lines.isEmpty) return;
    t.lines.removeAt(lineIndex);
    returns.refresh();
  }

  void returnTicket(String ticketId) {
    // TODO: API call
    Get.snackbar(
      'Returned',
      'Ticket $ticketId returned',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void returnAll() {
    // TODO: API call
    Get.snackbar(
      'Return All',
      'All listed spares returned',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
