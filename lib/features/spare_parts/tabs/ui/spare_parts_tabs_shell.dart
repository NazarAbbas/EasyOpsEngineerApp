// The screen with header tabs + body that swaps content
import 'package:easy_ops/core/theme/app_colors.dart';
import 'package:easy_ops/features/spare_parts/consume_spare_parts/ui/consume_spare_parts_page.dart';
import 'package:easy_ops/features/spare_parts/return_spare_parts/ui/return_spare_parts_page.dart';
import 'package:easy_ops/features/spare_parts/tabs/controller/spare_parts_tabs_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SparePartsTabsShell extends GetView<SparePartsController> {
  const SparePartsTabsShell({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    // ... inside SparePartsTabsShell.build(...)
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 140 : 120),
        child: Builder(
          builder: (context) {
            final canPop = Navigator.of(context).canPop();
            final top = MediaQuery.of(context).padding.top;
            final double btnSize = isTablet ? 40 : 36;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: EdgeInsets.fromLTRB(12, top + (isTablet ? 8 : 6), 12, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rounded back + perfectly centered title (Stack avoids overflow)
                  SizedBox(
                    height: btnSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Left: rounded back (only if can pop)
                        if (canPop)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _CircleButton(
                              size: btnSize,
                              icon: CupertinoIcons.chevron_back,
                              onTap: Get.back,
                            ),
                          ),

                        // Center: title
                        Center(
                          child: Text(
                            'Spare Parts',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        // Right: keep empty so the title stays centered
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const _HeaderTabs(),
                ],
              ),
            );
          },
        ),
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedTab.value,
          children: const [ReturnSparePartsPage(), ConsumedSparePartsPage()],
        ),
      ),
    );
  }
}

class _HeaderTabs extends GetView<SparePartsController> {
  const _HeaderTabs();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final segW = c.maxWidth / controller.tabs.length;

        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: List.generate(controller.tabs.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.selectedTab.value = i,
                      child: SizedBox(
                        height: 38,
                        child: Center(
                          child: Obx(() {
                            final active = controller.selectedTab.value == i;
                            return Text(
                              controller.tabs[i],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: active
                                    ? FontWeight.w700
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
            // underline
            Obx(() {
              final left = controller.selectedTab.value * segW;
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: left + (segW * 0.15), // center it a bit
                bottom: 0,
                width: segW * 0.7, // 70% of tab width
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
