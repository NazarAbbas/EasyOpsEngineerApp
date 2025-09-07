/* ========================= MODELS ========================= */

import 'dart:ui';

class TimelineEvent {
  final String time; // HH:mm
  final String date; // e.g., 14 Sep
  final List<RichLine> lines; // rich pieces (text + inplace links)
  final bool showDetails;
  final VoidCallback? onViewDetails;

  TimelineEvent({
    required this.time,
    required this.date,
    required this.lines,
    this.showDetails = false,
    this.onViewDetails,
  });
}

class RichLine {
  final String text;
  final bool isLink;
  final VoidCallback? onTap;

  const RichLine._(this.text, this.isLink, this.onTap);

  factory RichLine.text(String text) => RichLine._(text, false, null);
  factory RichLine.link(String text, {VoidCallback? onTap}) =>
      RichLine._(text, true, onTap);
}
