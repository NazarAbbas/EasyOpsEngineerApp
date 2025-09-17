import 'package:easy_ops/features/dashboard_profile_staff_suggestion/suggestions_details/controller/suggestions_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuggestionDetailPage extends GetView<SuggestionDetailController> {
  const SuggestionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F6BFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Suggestions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        final d = controller.detail.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            children: [
              // Summary card
              _SummaryCard(detail: d),
              const SizedBox(height: 12),

              // Suggestion block
              _BlockCard(
                title: 'Suggestion',
                child: Text(
                  d.suggestionText,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Color(0xFF2D2F39),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Justification block
              _BlockCard(
                title: 'Justification',
                child: Text(
                  d.justificationText,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Color(0xFF2D2F39),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Reporter Info
              _BlockCard(
                title: 'Reporter Info',
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Reported By',
                      value: d.reporterName,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.call_rounded,
                          color: Color(0xFF2F6BFF),
                        ),
                        onPressed: controller.callReporter,
                        tooltip: 'Call',
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Department', value: d.reporterDepartment),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2F6BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: controller.onEdit,
              child: const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ================== WIDGETS ==================
class _SummaryCard extends StatelessWidget {
  final SuggestionDetail detail;
  const _SummaryCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final meta =
        '${detail.id}   ${_fmtTime(detail.createdAt)} | ${_fmtDate(detail.createdAt)}';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + status pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  detail.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D2F39),
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const _StatusPill(text: 'Open'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF737F93),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail.costText == null
                ? detail.category
                : '${detail.category} (${detail.costText})',
            style: const TextStyle(
              fontSize: 14.5,
              color: Color(0xFF2D2F39),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail.department,
            style: const TextStyle(
              fontSize: 14.5,
              color: Color(0xFF2D2F39),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _BlockCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D2F39),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7C8698),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2D2F39),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const ShapeDecoration(
        color: Color(0xFFEBCB50),
        shape: StadiumBorder(),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

String _fmtTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String _fmtDate(DateTime dt) {
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${dt.day.toString().padLeft(2, '0')} ${m[dt.month - 1]}';
}
