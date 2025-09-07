import 'package:easy_ops/ui/modules/assets_management/assets_dashboard/controller/assets_dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class AssetsDashboardPage extends GetView<AssetsDashboardController> {
  const AssetsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const _primary = Color(0xFF2F6BFF);
    const _border = Color(0xFFE9EEF5);
    const _bg = Color(0xFFF7F9FC);
    const _text = Color(0xFF2D2F39);
    const _muted = Color(0xFF7C8698);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        title: const Text('Assets Dashboard'),
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
              InkWell(
                onTap: controller.onHeaderTap,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: _primary.withOpacity(.25),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                            const SizedBox(height: 6),
                            Text(
                              a.description,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: controller.onStatusTap,
                              child: Text(
                                a.status,
                                style: const TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _CriticalPill(text: 'Critical'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Metrics row
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < controller.metrics.length; i++) ...[
                      Expanded(child: _MetricTile(item: controller.metrics[i])),
                      if (i != controller.metrics.length - 1)
                        Container(width: 1, height: 32, color: _border),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 10),
              Divider(color: _border, thickness: 1),
              const SizedBox(height: 10),

              // Breakdown chart (0..1000, red guide at 100)
              _BarChartCard(
                title: 'Breakdown  HRS',
                points: controller.breakdownHrs.toList(),
                minY: 0,
                maxY: 1000,
                redLineAt: 100,
              ),

              // Spares chart (-6000..+6000, red guide at 0)
              _BarChartCard(
                title: 'Spares Consumption  \$',
                points: controller.sparesConsumption.toList(),
                minY: -6000,
                maxY: 6000,
                redLineAt: 0,
                showSignedThousands: true, // 2,000 / -2,000 like the screenshot
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ===== widgets =====

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

class _MetricTile extends StatelessWidget {
  final MetricItem item;
  const _MetricTile({required this.item});

  @override
  Widget build(BuildContext context) {
    const _muted = Color(0xFF7C8698);
    const _primary = Color(0xFF2F6BFF);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.value,
          style: const TextStyle(
            color: _primary,
            fontWeight: FontWeight.w800,
            decorationThickness: 2,
          ),
        ),
      ],
    );
  }
}

class ChartPoint {
  final String x;
  final double y;
  ChartPoint(this.x, this.y);
}

class _BarChartCard extends StatelessWidget {
  final String title;
  final List<ChartPoint> points;

  /// Force exact bounds to imitate the screenshot scale.
  final double minY;
  final double maxY;

  /// Draw a thin red guide line like in the screenshots (0 for spares, 100 for breakdown).
  final double redLineAt;

  /// Format left axis as 0/2,000/4,000... and negatives in red-ish like the image
  final bool showSignedThousands;

  const _BarChartCard({
    required this.title,
    required this.points,
    required this.minY,
    required this.maxY,
    required this.redLineAt,
    this.showSignedThousands = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const blueBar = Color(0xFF2F6BFF); // same blue as page
    const border = Color(0xFFE9EEF5);
    const grid = Color(0xFFB0B7C3); // subtle gray grid (close to screenshot)
    const axis = Colors.black87;
    const redLine = Color(0xFFFF3B30); // iOS-like red, matches the guide line

    // Build bar groups
    final bars = <BarChartGroupData>[
      for (int i = 0; i < points.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: points[i].y,
              width: 12,
              borderRadius: BorderRadius.circular(3),
              color: blueBar,
            ),
          ],
        ),
    ];

    // Left labels formatter
    String _fmt(double v) {
      if (!showSignedThousands) return v.toStringAsFixed(0);
      String s = v.abs() >= 1000
          ? '${(v.abs() / 1000).toStringAsFixed(0)},000'
          : v.toStringAsFixed(0);
      return v < 0 ? '-$s' : (v == 0 ? '0' : s);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: BarChart(
              BarChartData(
                minY: minY,
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                barGroups: bars,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: grid, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= points.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            points[i].x,
                            style: const TextStyle(fontSize: 11, color: axis),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: _chooseInterval(minY, maxY),
                      getTitlesWidget: (value, meta) {
                        // Color negatives a touch red like screenshot left axis
                        final isNeg = value < 0;
                        return Text(
                          _fmt(value),
                          style: TextStyle(
                            fontSize: 11,
                            color: isNeg && showSignedThousands
                                ? const Color(0xFFD23B3B)
                                : axis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                baselineY: null, // we’re drawing our own red guide below
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: redLineAt,
                      color: redLine,
                      strokeWidth: 1.8,
                      dashArray: null, // solid like screenshot
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Choose a nice interval based on bounds (so labels look like 0/200/400 or 0/2,000...)
  double _chooseInterval(double minY, double maxY) {
    final span = (maxY - minY).abs();
    if (span <= 1000) return 200; // Breakdown: 0..1000 => 0/200/400/...
    if (span <= 12000) return 2000; // Spares: -6k..6k => -6/-4/-2/0/2/4/6
    return span / 5; // fallback
  }
}
