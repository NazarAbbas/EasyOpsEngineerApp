import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/pm_checklist_controller.dart';

class PMChecklistPage extends GetView<PMChecklistController> {
  const PMChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    const _primary = Color(0xFF2F6BFF);
    const _bg = Color(0xFFF7F9FC);
    const _text = Color(0xFF2D2F39);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        title: const Text('PM Checklist'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final a = controller.asset.value;
        final items = controller.items;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Header card (outlined like screenshot)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primary.withOpacity(.35), width: 1),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: _text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            children: [
                              TextSpan(text: a.code),
                              const TextSpan(
                                text: '  |  ',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              TextSpan(
                                text: a.make,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          a.description,
                          style: const TextStyle(color: _text, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Working',
                          style: TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _CriticalPill(text: 'Critical'),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Checklist items
            for (final it in items) ...[
              _ChecklistTile(item: it),
              const SizedBox(height: 18),
            ],
          ],
        );
      }),
    );
  }
}

// ---- widgets ----

class _CriticalPill extends StatelessWidget {
  final String text;
  const _CriticalPill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D4F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final ChecklistItem item;
  const _ChecklistTile({required this.item});

  @override
  Widget build(BuildContext context) {
    const _text = Color(0xFF2D2F39);
    const _muted = Color(0xFF7C8698);
    const _bullet = Color(0xFF4A5568); // dark grey for info circle

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(
            color: _text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (item.meta.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            item.meta,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.info, size: 16, color: _bullet),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.description,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
