import 'package:easy_ops/features/feature_assets_management/assets_specification/controller/assets_specification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetsSpecificationPage extends GetView<AssetSpecificationController> {
  const AssetsSpecificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2F6BFF);
    const _border = Color(0xFFE9EEF5);
    const _card = Color(0xFFF6F7FB);
    const _text = Color(0xFF2D2F39);
    const _muted = Color(0xFF7C8698);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        title: const Text('Assets Specification'),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final a = controller.asset.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header card
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  children: [
                                    TextSpan(text: a.code),
                                    const TextSpan(
                                      text: '  |  ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                      ),
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
                              const SizedBox(height: 8),
                              Text(
                                a.description,
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: Color(0xFF15C66B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    a.status,
                                    style: const TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _CriticalPill(text: a.criticality),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Docs row
                    Container(
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _border),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: controller.docs.map((d) {
                          return _DocChip(
                            title: d.title,
                            pages: d.pages,
                            progress: controller.progress[d.id],
                            onTap: () => controller.downloadAndOpen(d),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Technical Data
              _SectionCard(
                title: 'Technical Data',
                items: a.technicalData,
                primary: primary,
                border: _border,
                text: _text,
                muted: _muted,
              ),
              const SizedBox(height: 12),

              // Commercial Data
              _SectionCard(
                title: 'Commercial Data',
                items: a.commercialData,
                primary: primary,
                border: _border,
                text: _text,
                muted: _muted,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}

// ---------- UI atoms ----------

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

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

class _DocChip extends StatelessWidget {
  final String title;
  final int pages;
  final double? progress; // null = idle, 0..1 = downloading, -1 = opening
  final VoidCallback onTap;

  const _DocChip({
    required this.title,
    required this.pages,
    required this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    const _border = Color(0xFFE9EEF5);

    Widget trailing;
    if (progress == null) {
      trailing = const Icon(Icons.download_rounded, size: 18);
    } else if (progress == -1) {
      trailing = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (progress! >= 0 && progress! < 1) {
      trailing = SizedBox(
        width: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            Text(
              '${(progress! * 100).toInt()}%',
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    } else {
      trailing = const Icon(Icons.check_circle, size: 18, color: Colors.green);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 170,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            const Icon(
              Icons.picture_as_pdf_rounded,
              size: 18,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$pages Pages',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Map<String, String> items;
  final Color primary, border, text, muted;

  const _SectionCard({
    required this.title,
    required this.items,
    required this.primary,
    required this.border,
    required this.text,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: border)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: TextStyle(color: primary, fontWeight: FontWeight.w800),
                ),
              ),
              Expanded(child: Divider(color: border)),
            ],
          ),
          const SizedBox(height: 6),
          ...items.entries
              .map(
                (e) => _KVRow(
                  label: e.key,
                  value: e.value,
                  text: text,
                  muted: muted,
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _KVRow extends StatelessWidget {
  final String label, value;
  final Color text, muted;
  const _KVRow({
    required this.label,
    required this.value,
    required this.text,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 48,
            child: Text(
              label,
              style: TextStyle(
                color: muted,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 52,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
