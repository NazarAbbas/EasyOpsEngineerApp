// general_work_orders_combined_page.dart
// Single screen: KPI strip + 3 charts + compact work-order list (pure Flutter, GetX)

import 'package:easy_ops/features/feature_general_work_order/assets/controller/general_work_order_assets_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/* ─────────────── Design tokens ─────────────── */

const kTextPrimary = Color(0xFF0F172A);
const kTextMuted = Color(0xFF6B7280);
const kBlue = Color(0xFF1E4FD6);
const kBorder = Color(0xFFE7ECF4);
const kInner = Color(0xFFF3F5F8);
const kBgPlot = Color(0xFFF8FAFD);
const kGrid = Color(0xFFE7E9EE);
const kRedLine = Color(0xFFE53935);

// tiny type scale for a compact UI
class TS {
  static const double h6 = 13.0;
  static const double h7 = 12.0;
  static const double body = 12.0;
  static const double meta = 11.0;
  static const double axis = 9.5;
  static const double axisSmall = 9.0;
}

/* ─────────────── Page ─────────────── */

class GeneralWorkOrderAssetsPage
    extends GetView<GeneralWorkOrderAssetsController> {
  const GeneralWorkOrderAssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GeneralWorkOrderAssetsController());
    const pad = 14.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2.6),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: pad),
                child: _HeaderChip(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // KPI strip
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: pad),
                child: _KpiStrip(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Chart 1
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: pad),
                child: _ChartCard(
                  title: 'Breakdown Hrs',
                  height: 200,
                  painter: _Breakdown1000Painter(
                    months: controller.months,
                    values: controller.breakdown1000,
                    target: controller.breakdownTarget,
                    leadLabels: const ['2001', '2002'],
                    leadValues: const [120, 300],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Chart 2
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: pad),
                child: _ChartCard(
                  title: 'Spares Consumption  \$',
                  height: 205,
                  painter: _SparesPainter(
                    months: controller.months,
                    values: controller.spares,
                    leadLabels: const ['2001', '2002'],
                    leadValues: const [350, 700],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // Chart 3
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: pad),
                child: _ChartCard(
                  title: 'Breadown Hrs',
                  height: 168,
                  painter: _CompactBreakdownPainter(
                    labels: controller.cncLabels,
                    values: controller.smallBreakdown,
                    maxY: 20,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // List title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: pad),
                child: Text(
                  'Recent Work Orders',
                  style: const TextStyle(
                    fontSize: TS.h7,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: pad),
              sliver: SliverList.separated(
                itemCount: controller.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _WOCard(item: controller.items[i]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        child: SizedBox(
          height: 46,
          child: FilledButton(
            onPressed: () => {controller.goBack(0)},
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              'Go Back',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: TS.h7),
            ),
          ),
        ),
      ),
    );
  }
}

/* ─────────────── Top bits ─────────────── */

class _HeaderChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D7380), Color(0xFF5B6375)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B6375).withOpacity(.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class _KpiStrip extends GetView<GeneralWorkOrderAssetsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget vDivider() =>
          Container(width: 1, height: double.infinity, color: kGrid);
      Widget kpi(String t, String v) => Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t,
              style: const TextStyle(
                color: kTextMuted,
                fontSize: TS.meta,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              v,
              style: const TextStyle(
                color: kBlue,
                fontSize: TS.h6,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 14),
            kpi('MTBF', '${controller.mtbfDays.value} Days'),
            vDivider(),
            kpi('BD Hours', '${controller.bdHours.value} Hrs'),
            vDivider(),
            kpi('MTTR', '${controller.mttrHrs.value} Hrs'),
            vDivider(),
            kpi('Criticality', controller.criticality.value),
            const SizedBox(width: 14),
          ],
        ),
      );
    });
  }
}

/* ─────────────── Chart Card ─────────────── */

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.height,
    required this.painter,
  });

  final String title;
  final double height;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: TS.h7,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: height,
              child: CustomPaint(painter: painter),
            ),
          ],
        ),
      ),
    );
  }
}

/* ─────────────── Chart Painters (Excel-like) ─────────────── */

// Chart 1: Breakdown 0–1000 with red target & 2 grey leading bars
class _Breakdown1000Painter extends CustomPainter {
  _Breakdown1000Painter({
    required this.months,
    required this.values,
    required this.target,
    this.leadLabels = const [],
    this.leadValues = const [],
  });
  final List<String> months;
  final List<double> values;
  final double target;
  final List<String> leadLabels;
  final List<double> leadValues;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTWH(42, 8, size.width - 54, size.height - 34);

    canvas.drawRRect(
      RRect.fromRectAndRadius(plot, const Radius.circular(6)),
      Paint()..color = kBgPlot,
    );
    canvas.drawRect(
      plot,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black54
        ..strokeWidth = 1.0,
    );

    const maxY = 1000.0, step = 200.0;

    for (double y = 0; y <= maxY; y += step) {
      final ry = plot.bottom - (y / maxY) * plot.height;
      canvas.drawLine(
        Offset(plot.left, ry),
        Offset(plot.right, ry),
        Paint()
          ..color = kGrid
          ..strokeWidth = 1,
      );
      _label(
        canvas,
        y.toInt().toString(),
        Offset(plot.left - 8, ry - 7),
        align: TextAlign.right,
        size: TS.axis,
        color: Colors.black87,
        weight: FontWeight.w600,
      );
    }

    final labels = [...leadLabels, ...months];
    final data = [...leadValues, ...values];
    final n = labels.length;
    const gap = 8.0;
    final barW = (plot.width - gap * (n + 1)) / n;

    for (int i = 0; i < n; i++) {
      final x = plot.left + gap + i * (barW + gap) + barW / 2;
      _label(
        canvas,
        labels[i],
        Offset(x, plot.bottom + 3),
        align: TextAlign.center,
        size: TS.axis,
        color: kTextMuted,
        weight: FontWeight.w600,
      );
    }

    final ty = plot.bottom - (target / maxY).clamp(0, 1) * plot.height;
    canvas.drawLine(
      Offset(plot.left, ty),
      Offset(plot.right, ty),
      Paint()
        ..color = kRedLine
        ..strokeWidth = 2,
    );

    final blue = Paint()..color = kBlue;
    final grey = Paint()..color = const Color(0xFFBDBDBD);

    for (int i = 0; i < n; i++) {
      final v = data[i].clamp(0, maxY);
      final h = (v / maxY) * plot.height;
      final r = Rect.fromLTWH(
        plot.left + gap + i * (barW + gap),
        plot.bottom - h,
        barW,
        h,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        i < leadValues.length ? grey : blue,
      );
    }

    final ax = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      ax,
    );
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      ax,
    );
  }

  @override
  bool shouldRepaint(covariant _Breakdown1000Painter old) =>
      old.values != values ||
      old.target != target ||
      old.leadValues != leadValues;

  void _label(
    Canvas c,
    String t,
    Offset p, {
    TextAlign align = TextAlign.left,
    double size = TS.axis,
    Color color = kTextPrimary,
    FontWeight weight = FontWeight.w700,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(fontSize: size, color: color, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    final off = align == TextAlign.right
        ? Offset(p.dx - tp.width, p.dy)
        : align == TextAlign.center
        ? Offset(p.dx - tp.width / 2, p.dy)
        : p;
    tp.paint(c, off);
  }
}

// Chart 2: Spares ±6000 with zero red baseline & grey leads
class _SparesPainter extends CustomPainter {
  _SparesPainter({
    required this.months,
    required this.values,
    this.leadLabels = const [],
    this.leadValues = const [],
  });
  final List<String> months;
  final List<double> values;
  final List<String> leadLabels;
  final List<double> leadValues;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTWH(54, 8, size.width - 66, size.height - 34);

    canvas.drawRRect(
      RRect.fromRectAndRadius(plot, const Radius.circular(6)),
      Paint()..color = kBgPlot,
    );
    canvas.drawRect(
      plot,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black54
        ..strokeWidth = 1.0,
    );

    const maxAbs = 6000.0;

    for (int i = 1; i < 6; i++) {
      final y = plot.top + plot.height * i / 6;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..color = kGrid
          ..strokeWidth = 1,
      );
    }

    for (final v in [6000, 4000, 2000, 0, -2000, -4000, -6000]) {
      final frac = (v + maxAbs) / (2 * maxAbs);
      final y = plot.bottom - frac * plot.height;
      _label(
        canvas,
        _comma(v.abs()),
        Offset(plot.left - 12, y - 7),
        align: TextAlign.right,
        size: TS.axis,
        color: v < 0 ? Colors.red : Colors.black87,
        weight: FontWeight.w700,
      );
    }

    final labels = [...leadLabels, ...months];
    final data = [...leadValues, ...values];
    final n = labels.length;
    const gap = 8.0;
    final barW = (plot.width - gap * (n + 1)) / n;

    for (int i = 0; i < n; i++) {
      final x = plot.left + gap + i * (barW + gap) + barW / 2;
      _label(
        canvas,
        labels[i],
        Offset(x, plot.bottom + 3),
        align: TextAlign.center,
        size: TS.axis,
        color: kTextMuted,
        weight: FontWeight.w600,
      );
    }

    final zeroY = plot.top + plot.height / 2;
    canvas.drawLine(
      Offset(plot.left, zeroY),
      Offset(plot.right, zeroY),
      Paint()
        ..color = kRedLine
        ..strokeWidth = 2,
    );

    final blue = Paint()..color = kBlue;
    final grey = Paint()..color = const Color(0xFFBDBDBD);

    for (int i = 0; i < n; i++) {
      final v = data[i].clamp(-maxAbs, maxAbs);
      final frac = (v + maxAbs) / (2 * maxAbs);
      final y = plot.bottom - frac * plot.height;
      final x = plot.left + gap + i * (barW + gap);
      final paint = i < leadValues.length ? grey : blue;

      if (v >= 0) {
        final r = Rect.fromLTWH(x, y, barW, zeroY - y);
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(3)),
          paint,
        );
      } else {
        final r = Rect.fromLTWH(x, zeroY, barW, y - zeroY);
        canvas.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(3)),
          paint,
        );
      }
    }

    final ax = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      ax,
    );
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      ax,
    );
  }

  @override
  bool shouldRepaint(covariant _SparesPainter old) =>
      old.values != values || old.leadValues != leadValues;

  String _comma(int v) {
    final s = v.toString();
    return s.length > 3
        ? '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}'
        : s;
  }

  void _label(
    Canvas c,
    String t,
    Offset p, {
    TextAlign align = TextAlign.left,
    double size = TS.axis,
    Color color = kTextPrimary,
    FontWeight weight = FontWeight.w700,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(fontSize: size, color: color, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout();
    final off = align == TextAlign.right
        ? Offset(p.dx - tp.width, p.dy)
        : align == TextAlign.center
        ? Offset(p.dx - tp.width / 2, p.dy)
        : p;
    tp.paint(c, off);
  }
}

// Chart 3: Compact breakdown with values top + rotated CNC labels
class _CompactBreakdownPainter extends CustomPainter {
  _CompactBreakdownPainter({
    required this.labels,
    required this.values,
    required this.maxY,
  });
  final List<String> labels;
  final List<double> values;
  final double maxY;

  @override
  void paint(Canvas canvas, Size size) {
    const topSpace = 16.0, bottomSpace = 20.0;
    final plot = Rect.fromLTWH(
      34,
      topSpace,
      size.width - 42,
      size.height - (topSpace + bottomSpace),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(plot, const Radius.circular(6)),
      Paint()..color = kBgPlot,
    );
    canvas.drawRect(
      plot,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black54
        ..strokeWidth = 1.0,
    );

    for (int i = 1; i <= 4; i++) {
      final y = plot.top + plot.height * i / 5;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        Paint()
          ..color = kGrid
          ..strokeWidth = 1,
      );
    }

    final n = values.length;
    const gap = 6.0;
    final barW = (plot.width - gap * (n + 1)) / n;
    final bar = Paint()..color = kBlue;

    for (int i = 0; i < n; i++) {
      final v = values[i].clamp(0, maxY);
      final x = plot.left + gap + i * (barW + gap);
      final h = (v / maxY) * (plot.height * 0.98);
      final r = Rect.fromLTWH(x, plot.bottom - h, barW, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)),
        bar,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(v % 1 == 0 ? 0 : 1),
          style: const TextStyle(
            fontSize: TS.axis,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + (barW - tp.width) / 2, plot.bottom - h - 11));
    }

    for (final yVal in [0, 5, 10, 15, 20]) {
      final y = plot.bottom - (yVal / maxY) * plot.height;
      final tp = TextPainter(
        text: TextSpan(
          text: '$yVal',
          style: const TextStyle(
            fontSize: TS.axis,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(plot.left - tp.width - 6, y - 7));
    }

    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 1.0,
    );

    for (int i = 0; i < n; i++) {
      final x = plot.left + gap + i * (barW + gap) + barW / 2;
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: TS.axis,
            color: kTextMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 58);
      canvas.save();
      canvas.translate(x, plot.top - 3);
      canvas.rotate(-1.55);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CompactBreakdownPainter old) =>
      old.values != values || old.labels != labels;
}

/* ─────────────── List Card ─────────────── */

class _WOCard extends StatelessWidget {
  const _WOCard({required this.item});
  final WOItem item; // from your controller

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Container(
              decoration: BoxDecoration(
                color: kInner,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _pill(item.date),
                      _pill(item.type),
                      _pill(item.category),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: TS.h6,
                      fontWeight: FontWeight.w800,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.person,
                        size: 14,
                        color: kTextPrimary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.assignee,
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: TS.body,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: kBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.time,
                              size: 13,
                              color: kTextPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.duration,
                              style: const TextStyle(
                                color: kTextPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: TS.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String text) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: kBorder),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        text,
        style: const TextStyle(
          color: kTextMuted,
          fontWeight: FontWeight.w800,
          fontSize: TS.meta,
        ),
      ),
    ),
  );
}
