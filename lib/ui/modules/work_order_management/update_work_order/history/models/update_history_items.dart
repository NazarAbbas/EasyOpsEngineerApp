class UpdateHistoryItem {
  final String date; // e.g., "09 Aug 2024"
  final String category; // e.g., "Breakdown" / "Preventive"
  final String type; // e.g., "Mechanical" / "Scheduled"
  final String title;
  final String person;
  final String duration; // e.g., "03h 20m"
  UpdateHistoryItem({
    required this.date,
    required this.category,
    required this.type,
    required this.title,
    required this.person,
    required this.duration,
  });
}

final updateSampleHistory = <UpdateHistoryItem>[
  UpdateHistoryItem(
    date: '09 Aug 2024',
    category: 'Breakdown',
    type: 'Mechanical',
    title: 'Safety Guard on Equipment Found Damaged and Needs Replacement',
    person: 'Rahul Singh',
    duration: '03h 20m',
  ),
  UpdateHistoryItem(
    date: '10 Jul 2024',
    category: 'Preventive',
    type: 'Scheduled',
    title:
        'CNC Assets spindle speed fluctuating during precision cutting operations',
    person: 'Rahul Singh',
    duration: '08h 00m',
  ),
  UpdateHistoryItem(
    date: '09 Aug 2024',
    category: 'Breakdown',
    type: 'Mechanical',
    title:
        'Tool Misalignment in the CNC Assets resulting in inaccurate and rejected workpieces',
    person: 'Rahul Singh',
    duration: '03h 20m',
  ),
];
