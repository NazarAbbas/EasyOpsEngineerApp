import 'package:get/get.dart';

enum Priority { low, medium, high }

enum RepairChoice { none, scrap, repair }

class ConsumedLine {
  final String partNo;
  final int qty;
  final Rx<RepairChoice> choice;
  ConsumedLine({
    required this.partNo,
    required this.qty,
    RepairChoice initial = RepairChoice.none,
  }) : choice = initial.obs;
}

class ConsumedTicket {
  final String id;
  final String bdNo;
  final DateTime createdAt;
  final String machine;

  final String issueTitle;
  final String department;
  final bool resolved;
  final String agingText;
  final Priority priority;

  final List<ConsumedLine> lines;

  ConsumedTicket({
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

class ConsumedSparePartsController extends GetxController {
  /// 0 = Returns, 1 = Consumed
  final tabIndex = 1.obs; // start on Consumed for this flow

  // Minimal placeholder for Returns tab
  final returns = [].obs;

  // --- Consumed tickets (mock) ---
  final consumedTickets = <ConsumedTicket>[
    ConsumedTicket(
      id: 'c1',
      bdNo: 'BD - 102',
      createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
      machine: 'CNC -1',
      issueTitle: 'Latency Issue in web browser',
      department: 'Mechanical',
      resolved: true,
      agingText: '3h 20m',
      priority: Priority.high,
      lines: [
        ConsumedLine(partNo: 'J122338812', qty: 1, initial: RepairChoice.scrap),
        ConsumedLine(
          partNo: 'J122338812',
          qty: 1,
          initial: RepairChoice.repair,
        ),
        ConsumedLine(partNo: 'J122338812', qty: 1, initial: RepairChoice.scrap),
        ConsumedLine(
          partNo: 'J122338812',
          qty: 1,
          initial: RepairChoice.repair,
        ),
      ],
    ),
    ConsumedTicket(
      id: 'c2',
      bdNo: 'BD - 102',
      createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
      machine: 'CNC -1',
      issueTitle: 'Hydraulic pressure unstable',
      department: 'Mechanical',
      resolved: false,
      agingText: '1h 05m',
      priority: Priority.medium,
      lines: [
        ConsumedLine(partNo: 'AA-77881', qty: 2),
        ConsumedLine(partNo: 'BB-33221', qty: 1),
      ],
    ),
    ConsumedTicket(
      id: 'c3',
      bdNo: 'BD - 102',
      createdAt: DateTime(DateTime.now().year, 8, 9, 18, 8),
      machine: 'CNC -1',
      issueTitle: 'Coolant pump noise',
      department: 'Mechanical',
      resolved: false,
      agingText: '42m',
      priority: Priority.low,
      lines: [
        ConsumedLine(partNo: 'P998812', qty: 5, initial: RepairChoice.repair),
      ],
    ),
  ].obs;

  /// expansion state for Consumed cards
  final expandedConsumed = <String, bool>{}.obs;
  bool isExpandedConsumed(String id) => expandedConsumed[id] ?? false;
  void toggleExpandedConsumed(String id) {
    expandedConsumed[id] = !(expandedConsumed[id] ?? false);
    expandedConsumed.refresh();
  }

  void setChoice(String ticketId, int lineIndex, RepairChoice value) {
    final t = consumedTickets.firstWhereOrNull((e) => e.id == ticketId);
    if (t == null) return;
    t.lines[lineIndex].choice.value = value;
  }

  void submitConsumed(String ticketId) {
    // TODO: hook API here
    Get.snackbar(
      'Submitted',
      'Consumed ticket $ticketId submitted',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
