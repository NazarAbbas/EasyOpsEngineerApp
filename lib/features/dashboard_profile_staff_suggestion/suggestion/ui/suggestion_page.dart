import 'package:easy_ops/features/dashboard_profile_staff_suggestion/suggestion/controller/suggestion_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuggestionsPage extends GetView<SuggestionsController> {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'Suggestions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        final list = controller.items;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (ctx, i) {
            final s = list[i];
            return Obx(
              () => _SuggestionCard(
                suggestion: s,
                isOpen: controller.isOpen(s.id),
                onOpenToggle: () => controller.toggleOpen(s.id),
                onTap: () => controller.openSuggestion(s),
                onCallReporter: () => controller.callReporter(s.reporterPhone),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: list.length,
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: controller.addNew,
              child: const Text(
                'Add New',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ======================= WIDGETS =======================

class _SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  final VoidCallback onTap;
  final bool isOpen;
  final VoidCallback onOpenToggle;
  final VoidCallback onCallReporter;

  const _SuggestionCard({
    required this.suggestion,
    required this.onTap,
    required this.isOpen,
    required this.onOpenToggle,
    required this.onCallReporter,
  });

  @override
  Widget build(BuildContext context) {
    final meta =
        '${suggestion.id}   ${_fmtTime(suggestion.createdAt)} | ${_fmtDate(suggestion.createdAt)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Status pill (tap pill to expand)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      suggestion.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D2F39),
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onOpenToggle,
                    child: _StatusPill(text: suggestion.status),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Meta row
              Text(
                meta,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF737F93),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              // Category (+ optional cost)
              Text(
                suggestion.costText == null
                    ? suggestion.category
                    : '${suggestion.category} (${suggestion.costText})',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D2F39),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              // Department
              Text(
                suggestion.department,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D2F39),
                  fontWeight: FontWeight.w700,
                ),
              ),

              // ===== Expanded content (Suggestion + Justification + Reporter Info) =====
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: isOpen
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const SizedBox(height: 12),
                    _SoftBlock(
                      title: 'Suggestion',
                      text: suggestion.suggestionText,
                    ),
                    const SizedBox(height: 8),
                    _SoftBlock(
                      title: 'Justification',
                      text: suggestion.justificationText,
                    ),
                    const SizedBox(height: 8),
                    _ReporterInfoBlock(
                      name: suggestion.reporterName,
                      department: suggestion.reporterDepartment,
                      onCall: onCallReporter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftBlock extends StatelessWidget {
  final String title;
  final String text;
  const _SoftBlock({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FB),
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: Color(0xFF2D2F39),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReporterInfoBlock extends StatelessWidget {
  final String name;
  final String department;
  final VoidCallback onCall;
  const _ReporterInfoBlock({
    required this.name,
    required this.department,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reporter Info',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D2F39),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(
                width: 110,
                child: Text(
                  'Reported By',
                  style: TextStyle(
                    color: Color(0xFF7C8698),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF2D2F39),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                onPressed: onCall,
                icon: const Icon(Icons.call_rounded, color: Color(0xFF2F6BFF)),
                tooltip: 'Call',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(
                width: 110,
                child: Text(
                  'Department',
                  style: TextStyle(
                    color: Color(0xFF7C8698),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  department,
                  style: const TextStyle(
                    color: Color(0xFF2D2F39),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// ======================= UTILS =======================

String _fmtTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _fmtDate(DateTime dt) {
  const months = [
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
  final d = dt.day.toString().padLeft(2, '0');
  return '$d ${months[dt.month - 1]}';
}
