import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:flutter/material.dart';

/// Left colored pill on the card
enum Priority { high } // high == Critical

/// Right-side status text
enum Status { inProgress, resolved, none }

extension RightStatusX on Status {
  String get text => switch (this) {
    Status.inProgress => 'In Progress',
    Status.none => '',
    Status.resolved => 'Resolved',
  };

  Color get color => switch (this) {
    Status.inProgress => AppColors.primary,
    Status.none => Colors.transparent,
    Status.resolved => AppColors.successGreen,
  };
}

/// UI tabs / filters you care about
enum WorkTab { today, open, escalated, critical }

class WorkOrder {
  final String title;
  final String code;
  final String time;
  final String date;
  final String department;
  final String line;
  final Priority priority;
  final Status status;
  final String duration;
  final String footerTag; // e.g. 'Escalated'

  WorkOrder({
    required this.title,
    required this.code,
    required this.time,
    required this.date,
    required this.department,
    required this.line,
    required this.priority,
    required this.status,
    required this.duration,
    required this.footerTag,
  });
}

/// Convenience helpers for filtering
extension WorkOrderX on WorkOrder {
  bool get isInProgress => status == Status.inProgress;

  /// Per spec: "today means none"
  bool get isToday => status == Status.none;

  bool get isEscalated => footerTag.toLowerCase() == 'escalated';

  /// Critical maps to the left pill (StatusPill.high)
  bool get isCritical => priority == Priority.high;

  /// Matches a tab category
  bool matches(WorkTab tab) {
    switch (tab) {
      case WorkTab.today:
        return isToday;
      case WorkTab.open:
        return isInProgress;
      case WorkTab.escalated:
        return isEscalated;
      case WorkTab.critical:
        return isCritical;
    }
  }
}
