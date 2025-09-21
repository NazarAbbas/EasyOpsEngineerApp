class AcceptedBy {
  final String dept;
  final String name;
  final String phone;
  AcceptedBy(this.dept, this.name, this.phone);
}

class ResourceItem {
  final String name;
  final int qty;
  ResourceItem(this.name, this.qty);
}

class ActivityItem {
  final String title;
  final String code; // e.g., AC-302
  final String time; // "18:08"
  final String date; // "09 Aug"
  final String status; // "In Progress"
  final String type; // "Preventive"
  final String bdCode; // "BD 102"
  ActivityItem({
    required this.title,
    required this.code,
    required this.time,
    required this.date,
    required this.status,
    required this.type,
    required this.bdCode,
  });
}
