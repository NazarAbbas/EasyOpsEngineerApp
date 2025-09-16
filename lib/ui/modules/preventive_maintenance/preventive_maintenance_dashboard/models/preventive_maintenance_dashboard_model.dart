import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:flutter/material.dart';

/// Left colored pill on the card (Critical only in the current design)
enum Priority { high } // high == "Critical"

/// Status text shown on the bottom-left line
enum Status { pending, timeSlotProposed, approved, overdue, resolved, none }

extension RightStatusX on Status {
  String get text => switch (this) {
    Status.pending => 'Pending',
    Status.timeSlotProposed => 'Time Slot Proposed',
    Status.approved => 'Approved',
    Status.resolved => 'Resolved',
    Status.none => 'overdue',
    Status.overdue => throw UnimplementedError(),
  };

  Color get color => switch (this) {
    Status.pending => const Color(0xFF6B7280),
    Status.timeSlotProposed => const Color(0xFF6B7280),
    Status.approved => const Color(0xFF6B7280),
    Status.none => Colors.transparent,
    Status.resolved => AppColors.successGreen,
    Status.overdue => const Color.fromARGB(255, 170, 42, 6),
  };
}

/// What kind of schedule text to show on the card
enum ScheduleKind { dueBy, proposed, scheduled }

/// Minimal model for the screenshot UI
class PreventiveMaintenanceDashboardModel {
  // Primary text
  final String title;

  // Right-side pill + bottom-left status
  final Priority priority; // Critical
  final Status status; // Pending / Time Slot Proposed / Approved / Resolved

  // Bottom-right text (e.g., "4H required")
  final String duration; // e.g., "4H"

  // Meta row: "CNC-1  |  Siemens  |  PM-402"
  final String machine;
  final String make;
  final String planCode;

  // Schedule section
  final ScheduleKind scheduleKind;
  final String? dueBy; // for dueBy
  final String? proposedSlot1; // for proposed (line 1)
  final String? proposedSlot2; // for proposed (line 2, optional)
  final String? scheduledAt; // for scheduled

  const PreventiveMaintenanceDashboardModel({
    required this.title,
    required this.priority,
    required this.status,
    required this.duration,
    required this.machine,
    required this.make,
    required this.planCode,
    required this.scheduleKind,
    this.dueBy,
    this.proposedSlot1,
    this.proposedSlot2,
    this.scheduledAt,
  });

  // ── Computed strings used by the card ──────────────────────────────────────

  /// "CNC-1  |  Siemens  |  PM-402"
  String get machineLine => "$machine  |  $make  |  $planCode";

  /// First schedule line
  String get scheduleLine1 => switch (scheduleKind) {
    ScheduleKind.dueBy => 'Due by ${dueBy ?? ''}'.trim(),
    ScheduleKind.proposed => 'Proposed: ${proposedSlot1 ?? ''}'.trim(),
    ScheduleKind.scheduled => 'Scheduled: ${scheduledAt ?? ''}'.trim(),
  };

  /// Second schedule line (only for Proposed)
  String? get scheduleLine2 =>
      scheduleKind == ScheduleKind.proposed ? proposedSlot2 : null;

  /// "4H required"
  String get durationLine => '$duration required';
}
