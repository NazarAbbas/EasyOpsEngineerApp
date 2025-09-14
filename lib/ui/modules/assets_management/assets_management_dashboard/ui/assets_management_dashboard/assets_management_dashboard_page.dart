// ignore_for_file: deprecated_member_use

import 'package:easy_ops/ui/modules/assets_management/assets_management_dashboard/controller/assets_management_list_controller.dart';
import 'package:easy_ops/ui/modules/assets_management/assets_management_dashboard/models/area_group.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/maintenance_wotk_order_management/ui/work_order_management_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/* ---------------- Colors ---------------- */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const surface = Colors.white;
  static const card = Color(0xFFF6F7FB);
  static const border = Color(0xFFE9EEF5);
  static const text = Color(0xFF2D2F39);
  static const muted = Color(0xFF7C8698);
}

/* ---------------- Tab filter helper ---------------- */

bool matchesTab(AssetItem it, int tabIndex) {
  // 0: All, 1: Critical, 2: Semi Critical, 3: Non Critical
  if (tabIndex == 0) return true;
  final label = it.pill.trim().toLowerCase();
  switch (tabIndex) {
    case 1:
      return label == 'critical';
    case 2:
      return label == 'semi critical' ||
          label == 'semi-critical' ||
          label == 'semi';
    case 3:
      return label == 'non critical' ||
          label == 'non-critical' ||
          label == 'non';
    default:
      return true;
  }
}

/* ---------------- Page ---------------- */

class AssetsManagementDashboardPage
    extends GetView<AssetsManagementDashboardController> {
  const AssetsManagementDashboardPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double headerH = isTablet ? 148 : 120;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: const _GradientHeader(),
      ),
      body: Column(
        children: [
          const _Tabs(),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final tab = controller.selectedTab.value;

              final groupsToShow = controller.groups
                  .where((g) => g.items.any((it) => matchesTab(it, tab)))
                  .toList();

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                itemCount: groupsToShow.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 28, color: _C.border),
                itemBuilder: (_, i) {
                  final g = groupsToShow[i];
                  final originalIndex = controller.groups.indexOf(g);
                  return _GroupSection(
                    index: originalIndex,
                    group: g,
                    currentTab: tab,
                    onToggle: () => controller.toggle(originalIndex),
                    onRowTap: () => controller.onGroupTap(g), // optional
                    onItemTap: (asset) =>
                        controller.onAssetTap(g, asset), // ROW TAP
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 1),
    );
  }
}

/* ---------------- Header ---------------- */

class _GradientHeader extends GetView<AssetsManagementDashboardController>
    implements PreferredSizeWidget {
  const _GradientHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 12),
      child: Column(
        children: [
          const Center(
            child: Text(
              'Assets Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: _SearchField()),
              const SizedBox(width: 12),
              _IconSquare(
                onTap: () {},
                bg: Colors.white.withOpacity(0.18),
                outline: const Color(0x66FFFFFF),
                child: const Icon(CupertinoIcons.calendar, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------------- Tabs ---------------- */

class _Tabs extends GetView<AssetsManagementDashboardController> {
  const _Tabs({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double tabH = isTablet ? 28 : 18;
    final double fs = isTablet ? 15 : 13.5;
    final double uThick = isTablet ? 3.5 : 3;
    final double uSide = isTablet ? 12 : 10;
    final double uGap = isTablet ? 8 : 6;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Container(
      color: primary,
      padding: const EdgeInsets.only(bottom: 10),
      child: LayoutBuilder(
        builder: (context, c) {
          final count = controller.tabs.length;
          final segW = c.maxWidth / count;

          return Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: uGap + uThick),
                child: Row(
                  children: List.generate(count, (i) {
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => controller.setSelectedTab(i),
                        child: SizedBox(
                          height: tabH,
                          child: Center(
                            child: Obx(() {
                              final active = controller.selectedTab.value == i;
                              return Text(
                                controller.tabs[i],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fs,
                                  fontWeight: active
                                      ? FontWeight.w900
                                      : FontWeight.w500,
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Obx(() {
                final left = uSide + controller.selectedTab.value * segW;
                final width = segW - uSide * 2;
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  left: left,
                  bottom: 0,
                  width: width,
                  height: uThick,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

/* ---------------- Group Section ---------------- */

class _GroupSection extends StatelessWidget {
  final int index;
  final AreaGroup group;
  final int currentTab;
  final VoidCallback onToggle;
  final VoidCallback? onRowTap; // header optional
  final ValueChanged<AssetItem>? onItemTap; // row press

  const _GroupSection({
    super.key,
    required this.index,
    required this.group,
    required this.currentTab,
    required this.onToggle,
    this.onRowTap,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = group.expanded.value;
      final filteredItems = group.items
          .where((it) => matchesTab(it, currentTab))
          .toList();
      if (filteredItems.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          // Header (expand/collapse)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                onToggle();
                onRowTap?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: expanded ? _C.primary : _C.border,
                    width: expanded ? 1.6 : 1,
                  ),
                  boxShadow: [
                    if (expanded)
                      BoxShadow(
                        color: _C.primary.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            group.title,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _C.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${filteredItems.length} nos',
                            style: const TextStyle(
                              color: _C.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: const Icon(
                        CupertinoIcons.chevron_down,
                        color: _C.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Items
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                children: filteredItems
                    .map(
                      (it) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _AssetCard(
                          item: it,
                          onTap: () => onItemTap?.call(it), // PRESS ROW
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      );
    });
  }
}

/* ---------------- Asset Card (pressable row) ---------------- */

class _AssetCard extends StatelessWidget {
  final AssetItem item;
  final VoidCallback? onTap;
  const _AssetCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Stack(
          children: [
            // Soft card
            Container(
              decoration: BoxDecoration(
                color: _C.card,
                borderRadius: borderRadius,
                border: Border.all(color: _C.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: name | brand + pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: _C.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.2,
                            ),
                            children: [
                              TextSpan(text: item.name),
                              const TextSpan(text: '   |   '),
                              TextSpan(
                                text: item.brand,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Pill(text: item.pill, color: item.pillColor),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: _C.text,
                      fontSize: 15,
                      height: 1.28,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Footer: state link right
                  Row(
                    children: [
                      const Spacer(),
                      const Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        size: 14,
                        color: _C.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.state,
                        style: const TextStyle(
                          color: _C.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Accent stripe (based on pill color)
            Positioned.fill(
              left: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 3,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: item.pillColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- Small bits ---------------- */

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
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

class _SearchField extends GetView<AssetsManagementDashboardController> {
  const _SearchField({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double h = isTablet ? 52 : 44;
    final double r = isTablet ? 12 : 10;
    final double pad = isTablet ? 16 : 12;
    final double fs = isTablet ? 16 : 14;
    final double icon = isTablet ? 20 : 18;

    return Container(
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: TextField(
        onChanged: controller.setQuery,
        textInputAction: TextInputAction.search,
        style: TextStyle(color: Colors.white, fontSize: fs),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Search assets',
          hintStyle: TextStyle(color: Colors.white70, fontSize: fs),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: pad, vertical: 10),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              CupertinoIcons.search,
              color: Colors.white70,
              size: icon,
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            minHeight: h,
            minWidth: isTablet ? 48 : 40,
          ),
        ),
      ),
    );
  }
}

class _IconSquare extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? bg;
  final Color? outline;
  const _IconSquare({
    super.key,
    required this.child,
    required this.onTap,
    this.bg,
    this.outline,
  });

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double size = isTablet ? 52 : 44;
    final double radius = isTablet ? 10 : 8;

    return Material(
      color: bg ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: outline ?? const Color(0xFFDFE5F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: size,
          width: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

/* ---------------- Demo main (optional) ---------------- */

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AssetsManagementDashboardController());
  runApp(const _DemoApp());
}

class _DemoApp extends StatelessWidget {
  const _DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Assets Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _C.primary),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: _C.primary,
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AssetsManagementDashboardPage(),
    );
  }
}
