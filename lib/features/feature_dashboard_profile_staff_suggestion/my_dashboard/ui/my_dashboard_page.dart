// ignore_for_file: deprecated_member_use
import 'package:easy_ops/features/feature_dashboard_profile_staff_suggestion/my_dashboard/controller/my_dashboard_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class MyDashboardPage extends GetView<MyDashboardController> {
  const MyDashboardPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTab = _isTablet(context);
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    final headerH = isTab ? 84.0 : 72.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: _CompactHeader(primary: primary, title: 'My Dashboard'),
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          final pad = EdgeInsets.symmetric(horizontal: isTab ? 16 : 12);
          final gap = SizedBox(height: isTab ? 14 : 12);

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                gap,
                Padding(
                  padding: pad,
                  child: _ChartCard(
                    title: 'Breakdown  HRS',
                    child: _MonthlyBars(
                      labels: controller.months,
                      values: controller.breakdownHrs,
                      avgLine: _avg(controller.breakdownHrs),
                    ),
                  ),
                ),
                gap,
                Padding(
                  padding: pad,
                  child: _ChartCard(
                    title: 'Spares Consumption  \$',
                    child: _MonthlyBars(
                      labels: controller.months,
                      values: controller.sparesConsumption,
                      zeroLine: true,
                    ),
                  ),
                ),
                gap,
                Padding(
                  padding: pad,
                  child: _ChartCard(
                    title: 'Breakdown Hrs',
                    child: _SlimBars(
                      labels: controller.paretoLabels,
                      values: controller.paretoValues,
                      barWidth: 10,
                      maxHeight: isTab ? 220 : 190,
                      showTopLabels: true,
                      topLabelStyle: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      axisLabelEvery: 2,
                    ),
                  ),
                ),
                gap,
                Padding(
                  padding: pad,
                  child: _ChartCard(
                    title: 'Breakdown Hrs',
                    child: _SlimBars(
                      labels: controller.paretoLabels,
                      values: controller.paretoValues,
                      barWidth: 10,
                      maxHeight: isTab ? 220 : 190,
                      showTopLabels: true,
                      topLabelStyle: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      axisLabelEvery: 2,
                    ),
                  ),
                ),
                gap,
                Padding(
                  padding: pad,
                  child: _ChartCard(
                    title: 'Breakdown Hrs',
                    child: _CategoryBars(
                      labels: controller.categories,
                      values: controller.categoryValues,
                      maxHeight: isTab ? 230 : 200,
                    ),
                  ),
                ),
                gap,
                Padding(
                  padding: pad,
                  child: _ChartCard(
                    title: 'Reason Analysis Hrs',
                    child: _CategoryBars(
                      labels: controller.categories,
                      values: controller.categoryValues,
                      maxHeight: isTab ? 230 : 200,
                      showNumbersOnTop: true,
                    ),
                  ),
                ),
                gap,
              ],
            ),
          );
        }),
      ),
    );
  }

  static double _avg(List<double> v) =>
      v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;
}

/* -------------------------- Header -------------------------- */

class _CompactHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color primary;
  const _CompactHeader({required this.primary, required this.title});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isTab = _isTablet(context);
    final top = MediaQuery.of(context).padding.top;
    final rowH = isTab ? 40.0 : 36.0;
    final slot = isTab ? 44.0 : 40.0;

    return Container(
      padding: EdgeInsets.fromLTRB(12, top + 4, 12, 8),
      decoration: BoxDecoration(color: primary),
      child: Row(
        children: [
          SizedBox(
            width: slot,
            height: rowH,
            child: Material(
              color: Colors.white.withOpacity(0.18),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: Get.back,
                child: Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                  size: isTab ? 20 : 18,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTab ? 17 : 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: slot, height: rowH),
        ],
      ),
    );
  }
}

/* -------------------------- Cards -------------------------- */

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isTab = MediaQuery.of(context).size.shortestSide >= 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: isTab ? 40 : 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE9EEF5))),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: isTab ? 13.5 : 12.5,
                color: const Color(0xFF2D2F39),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
            child: child,
          ),
        ],
      ),
    );
  }
}

/* -------------------------- Charts -------------------------- */

class _MonthlyBars extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final double? avgLine;
  final bool zeroLine;

  const _MonthlyBars({
    required this.labels,
    required this.values,
    this.avgLine,
    this.zeroLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTab = MediaQuery.of(context).size.shortestSide >= 600;
    final max = values
        .fold<double>(0, (m, e) => m.abs() > e.abs() ? m : e)
        .abs();
    final maxY = (max == 0 ? 100 : max) * 1.2;

    final height = isTab ? 220.0 : 190.0;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: zeroLine ? maxY : null,
          minY: zeroLine ? -maxY * 0.6 : null,
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (y) =>
                const FlLine(color: Color(0xFFE9EEF5), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 28,
                showTitles: true,
                getTitlesWidget: (v, m) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(fontSize: 9, color: Color(0xFF7C8698)),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 26,
                showTitles: true,
                getTitlesWidget: (v, m) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      labels[i],
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF7C8698),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE1E7F2)),
              left: BorderSide(color: Color(0xFFE1E7F2)),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          barGroups: List.generate(labels.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: i < values.length ? values[i] : 0,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  color: const Color(0xFF2F6BFF),
                  backDrawRodData: zeroLine
                      ? null
                      : BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: const Color(0xFFF3F5F9),
                        ),
                ),
              ],
            );
          }),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (avgLine != null)
                HorizontalLine(
                  y: avgLine!,
                  color: const Color(0xFFDB3A34),
                  strokeWidth: 2,
                ),
              if (zeroLine)
                HorizontalLine(
                  y: 0,
                  color: Color(0xFFDB3A34),
                  strokeWidth: 1.5,
                ),
            ],
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

class _SlimBars extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final double barWidth;
  final double maxHeight;
  final bool showTopLabels;
  final TextStyle? topLabelStyle;
  final int axisLabelEvery;

  const _SlimBars({
    required this.labels,
    required this.values,
    this.barWidth = 10,
    this.maxHeight = 200,
    this.showTopLabels = false,
    this.topLabelStyle,
    this.axisLabelEvery = 2,
  });

  @override
  Widget build(BuildContext context) {
    final max = values.isEmpty
        ? 20
        : values.reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: maxHeight,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 14),
            child: BarChart(
              BarChartData(
                maxY: max.toDouble(),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (y) =>
                      const FlLine(color: Color(0xFFE9EEF5), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 26,
                      showTitles: true,
                      getTitlesWidget: (v, m) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF7C8698),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 30,
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length)
                          return const SizedBox.shrink();
                        if (i % axisLabelEvery != 0)
                          return const SizedBox.shrink();
                        return Transform.rotate(
                          angle: -0.9,
                          child: Text(
                            labels[i],
                            style: const TextStyle(
                              fontSize: 8.5,
                              color: Color(0xFF7C8698),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(labels.length, (i) {
                  final v = i < values.length ? values[i] : 0.0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: v,
                        width: barWidth,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                        color: const Color(0xFF2F6BFF),
                      ),
                    ],
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 220),
            ),
          ),

          if (showTopLabels)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 8, 30),
                  child: Row(
                    children: List.generate(labels.length, (i) {
                      final v = i < values.length ? values[i] : 0.0;
                      return Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            v > 0 ? v.toInt().toString() : '',
                            style:
                                topLabelStyle ??
                                const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D2F39),
                                ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryBars extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final double maxHeight;
  final bool showNumbersOnTop;

  const _CategoryBars({
    required this.labels,
    required this.values,
    this.maxHeight = 220,
    this.showNumbersOnTop = false,
  });

  @override
  Widget build(BuildContext context) {
    final max = values.isEmpty
        ? 100
        : values.reduce((a, b) => a > b ? a : b) * 1.25;

    return SizedBox(
      height: maxHeight,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 22),
            child: BarChart(
              BarChartData(
                maxY: max.toDouble(),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (y) =>
                      const FlLine(color: Color(0xFFE9EEF5), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 30,
                      showTitles: true,
                      getTitlesWidget: (v, m) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF7C8698),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 26,
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length)
                          return const SizedBox.shrink();
                        return Text(
                          labels[i],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF7C8698),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(labels.length, (i) {
                  final v = i < values.length ? values[i] : 0.0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: v,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        color: const Color(0xFF2F6BFF),
                      ),
                    ],
                  );
                }),
              ),
              swapAnimationDuration: const Duration(milliseconds: 220),
            ),
          ),
          if (showNumbersOnTop)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 12, 26),
                  child: Row(
                    children: List.generate(labels.length, (i) {
                      final v = i < values.length ? values[i] : 0.0;
                      return Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            v > 0 ? v.toInt().toString() : '',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2F39),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
