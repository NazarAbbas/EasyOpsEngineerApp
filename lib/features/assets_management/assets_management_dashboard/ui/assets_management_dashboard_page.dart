// ignore_for_file: deprecated_member_use

import 'package:easy_ops/features/assets_management/assets_management_dashboard/controller/assets_management_list_controller.dart';
import 'package:easy_ops/features/assets_management/assets_management_dashboard/models/area_group.dart';
import 'package:easy_ops/features/maintenance_work_order/maintenance_wotk_order_management/ui/work_order_management_list_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/* ─── Colors ─── */
class _C {
  static const primary = Color(0xFF2F6BFF);
  static const surface = Colors.white;
  static const card = Color(0xFFF6F7FB);
  static const border = Color(0xFFE9EEF5);
  static const text = Color(0xFF2D2F39);
  static const muted = Color(0xFF7C8698);
}

/* ─── Filter helper ─── */
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

/* ─── Page ─── */
class AssetsManagementDashboardPage
    extends GetView<AssetsManagementDashboardController> {
  const AssetsManagementDashboardPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double headerH = isTablet ? 140 : 118;

    return Scaffold(
      resizeToAvoidBottomInset: false, // prevent bottom overflow on keyboard
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: const _GradientHeader(),
      ),
      body: const Column(
        children: [
          _TabsWithCounts(),
          SizedBox(height: 6),
          Expanded(child: _GroupsList()),
        ],
      ),
      // bottomNavigationBar: const BottomBar(currentIndex: 1),
    );
  }
}

/* ─── Header ─── */
class _GradientHeader extends GetView<AssetsManagementDashboardController>
    implements PreferredSizeWidget {
  const _GradientHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(118);

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // white status bar icons on blue
      child: Container(
        // Paint BLUE behind the status bar too
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withOpacity(0.94)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // Now put SafeArea inside so only content avoids the notch
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 10 + (isTablet ? 2 : 0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Assets Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Expanded(child: _SearchField()),
                    const SizedBox(width: 10),
                    _IconSquare(
                      onTap: () {},
                      bg: Colors.white.withOpacity(0.18),
                      outline: const Color(0x66FFFFFF),
                      child: const Icon(
                        CupertinoIcons.calendar,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ─── Tabs (scrollable, no overflow) ─── */
class _TabsWithCounts extends GetView<AssetsManagementDashboardController> {
  const _TabsWithCounts({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  int _countForTab(List<AreaGroup> groups, int tab) {
    var total = 0;
    for (final g in groups) {
      total += g.items.where((it) => matchesTab(it, tab)).length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double tabH = isTablet ? 36 : 32;
    final double fs = isTablet ? 14 : 13;
    final double underlineH = isTablet ? 3 : 2.5;
    final double underlineRadius = 2;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Container(
      color: primary,
      padding: EdgeInsets.only(bottom: 6), // room for underline
      child: Obx(() {
        final groups = controller.groups;
        final selected = controller.selectedTab.value;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: List.generate(controller.tabs.length, (i) {
              final count = _countForTab(groups, i);
              final active = selected == i;

              return Padding(
                padding: EdgeInsets.only(right: isTablet ? 14 : 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => controller.setSelectedTab(i),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 8,
                    ),
                    height: tabH,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fs,
                              fontWeight: active
                                  ? FontWeight.w900
                                  : FontWeight.w600,
                              height: 1.1,
                            ),
                            children: [
                              TextSpan(text: controller.tabs[i]),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: '($count)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 6 : 5),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          height: underlineH,
                          width: active ? null : 0,
                          constraints: BoxConstraints(
                            minWidth: active ? 18 : 0,
                            maxWidth: 64,
                          ),
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              underlineRadius,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

/* ─── Groups list ─── */
class _GroupsList extends GetView<AssetsManagementDashboardController> {
  const _GroupsList({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    return Obx(() {
      final tab = controller.selectedTab.value;
      final groupsToShow = controller.groups
          .where((g) => g.items.any((it) => matchesTab(it, tab)))
          .toList();

      if (groupsToShow.isEmpty) return const _EmptyState();

      return RefreshIndicator(
        onRefresh: () async {
          try {
            await controller.refreshData(); // implement in controller
          } catch (_) {}
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomSafe + 56),
          itemCount: groupsToShow.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, i) {
            final g = groupsToShow[i];
            final originalIndex = controller.groups.indexOf(g);
            return _GroupSection(
              index: originalIndex,
              group: g,
              currentTab: tab,
              onToggle: () => controller.toggle(originalIndex),
              onRowTap: () => controller.onGroupTap(g),
              onItemTap: (asset) => controller.onAssetTap(g, asset),
            );
          },
        ),
      );
    });
  }
}

/* ─── Empty state ─── */
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.cube_box, size: 36, color: _C.muted),
          SizedBox(height: 8),
          Text(
            'No assets match your filters',
            style: TextStyle(color: _C.muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/* ─── Group section ─── */
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
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                onToggle();
                onRowTap?.call();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: expanded ? _C.primary : _C.border,
                    width: expanded ? 1.4 : 1,
                  ),
                  boxShadow: [
                    if (expanded)
                      BoxShadow(
                        color: _C.primary.withOpacity(0.10),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    _CountBadge(count: filteredItems.length),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        group.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _C.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 16.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      child: const Icon(
                        CupertinoIcons.chevron_down,
                        color: _C.muted,
                        size: 18,
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
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: filteredItems
                    .map(
                      (it) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AssetCard(
                          item: it,
                          onTap: () => onItemTap?.call(it),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 160),
          ),
        ],
      );
    });
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: _C.card,
        border: Border.all(color: _C.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: _C.text,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/* ─── Asset card ─── */
class _AssetCard extends StatelessWidget {
  final AssetItem item;
  final VoidCallback? onTap;
  const _AssetCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Stack(
          children: [
            // Card
            Container(
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: borderRadius,
                border: Border.all(color: _C.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(color: item.pillColor, text: item.name),
                  const SizedBox(width: 10),
                  // Title/desc/state column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top line: LEFT = title (ellipsized) | RIGHT = pill (fixed to right)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.name} · ${item.brand}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _C.text,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _Pill(text: item.pill, color: item.pillColor),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Description
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _C.text,
                            fontSize: 14,
                            height: 1.28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Footer
                        Row(
                          children: [
                            const Spacer(),
                            const Icon(
                              CupertinoIcons.check_mark_circled_solid,
                              size: 14,
                              color: _C.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.state,
                              style: const TextStyle(
                                color: _C.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Accent stripe
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
                      left: Radius.circular(12),
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

class _Avatar extends StatelessWidget {
  final Color color;
  final String text;
  const _Avatar({required this.color, required this.text});

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty && parts.first.isNotEmpty
        ? parts.first[0]
        : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          _initials(text),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/* ─── Small bits ─── */
class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    // Max width keeps layout stable and prevents pushing title
    return Container(
      constraints: const BoxConstraints(maxWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
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
    final double h = isTablet ? 46 : 40;
    final double r = isTablet ? 10 : 8;
    final double pad = isTablet ? 14 : 12;
    final double fs = isTablet ? 14.5 : 13;
    final double icon = isTablet ? 18 : 16;

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
          contentPadding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              CupertinoIcons.search,
              color: Colors.white70,
              size: icon,
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            minHeight: h,
            minWidth: isTablet ? 44 : 38,
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
    final double size = isTablet ? 44 : 40;
    final double radius = isTablet ? 9 : 8;

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
