import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:easy_ops/features/feature_maintenance_work_order/spare_cart/models/spares_models.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/request_spares/controller/request_spares_controller.dart';

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const bg = Color(0xFFF6F7FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE1E7F2);
  static const text = Color(0xFF2D2F39);
  static const muted = Color(0xFF7C8698);
  static const stepBg = Color(0xFFF2F4F9);
  static const success = Color(0xFF0CB678);
  static const danger = Color(0xFFED3B40);
}

class RequestSparesPage extends GetView<SparesRequestController> {
  const RequestSparesPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final hPad = isTablet ? 20.0 : 14.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Request Spares',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primary, primary]),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        actions: [
          Obx(() {
            final lines = List.of(controller.cartCtrl.cart);
            final count = lines.length;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: controller.viewCart,
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
                if (count > 0)
                  Positioned(
                    top: 10,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: _C.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(width: 4),
        ],
      ),

      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 14),
        children: [
          const _CartSummary(),
          const SizedBox(height: 12),

          _FilterCard(isTablet: isTablet),
          const SizedBox(height: 12),

          // Results header
          Obx(() {
            if (!controller.showResults.value) return const SizedBox.shrink();
            final results = List<SpareItem>.from(controller.results);
            return _ResultsHeader(count: results.length);
          }),
          const SizedBox(height: 6),

          // Results list
          Obx(() {
            if (!controller.showResults.value) return const SizedBox.shrink();
            final results = List<SpareItem>.from(controller.results);

            if (results.isEmpty) {
              return const _EmptyState(
                title: 'No items found',
                subtitle: 'Try a different category combination.',
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...results.map((it) => _ItemRow(item: it)),
                const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 10),
          child: Obx(() {
            final showing = controller.showResults.value;
            final draftQty = controller.draftTotal;
            if (showing) {
              return SizedBox(
                height: isTablet ? 56 : 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.5,
                  ),
                  onPressed: draftQty > 0 ? controller.addToCart : null,
                  child: Text(
                    'Add To Cart${draftQty > 0 ? '  ($draftQty)' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }
            // Initial (no results being shown)
            return SizedBox(
              height: isTablet ? 56 : 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: BorderSide(color: primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: null,
                child: const Text('Add To Cart'),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/* ───────────────────────── Cart Summary (with edit/delete) ───────────────────────── */

class _CartSummary extends GetView<SparesRequestController> {
  const _CartSummary();

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Obx(() {
      final lines = List.of(controller.cartCtrl.cart);
      if (lines.isEmpty) return const SizedBox.shrink();

      int totalQty = 0;
      for (final l in lines) {
        totalQty += (l.qty ?? 0);
      }

      return Container(
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: _C.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Items in Cart',
                  style: TextStyle(fontWeight: FontWeight.w800, color: _C.text),
                ),
                const Spacer(),
                _Chip.filled('$totalQty qty'),
              ],
            ),
            const SizedBox(height: 8),

            ...lines.map((l) {
              final qty = l.qty ?? 0;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _C.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l.item.name}\n${l.item.code}',
                        style: const TextStyle(color: _C.text, height: 1.25),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x$qty',
                        style: const TextStyle(
                          color: _C.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ActionIcon(
                      tooltip: 'Edit',
                      icon: Icons.edit_outlined,
                      onTap: () => showEditCartLineSheet(
                        context: context,
                        controller: controller,
                        line: l,
                      ),
                    ),
                    const SizedBox(width: 2),
                    _ActionIcon(
                      tooltip: 'Delete',
                      icon: Icons.delete_outline,
                      color: _C.danger,
                      onTap: () => _confirmRemove(context, l),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add More'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: controller.addMore,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.shopping_cart_checkout_rounded),
                    label: const Text('View Cart'),
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1.5,
                    ),
                    onPressed: controller.viewCart,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _confirmRemove(BuildContext context, dynamic line) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove item?'),
        content: Text('Do you want to remove "${line.item.name}" from cart?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Remove',
              style: TextStyle(color: _C.danger, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (ok == true) controller.removeCartLine(line);
  }
}

/* ───────────────────────── Edit Qty Bottom Sheet ───────────────────────── */

// LIVE-SYNC BOTTOM SHEET: plus/minus immediately updates cart
void showEditCartLineSheet({
  required BuildContext context,
  required SparesRequestController controller,
  required dynamic line, // use your concrete type if available
}) {
  final Color primary =
      Theme.of(context).appBarTheme.backgroundColor ??
      Theme.of(context).colorScheme.primary;

  int q = (line.qty ?? 0) as int;
  final int max = (line.item.stock ?? 999999) is int
      ? line.item.stock as int
      : (line.item.stock ?? 999999).toInt();

  void apply(int newQ) {
    q = newQ;
    if (q <= 0) {
      controller.removeCartLine(line);
      Get.back();
      Get.snackbar(
        'Removed',
        '"${line.item.name}" removed from cart',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(12),
      );
    } else {
      controller.updateCartLineQty(line, q);
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E7F2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Text(
                  line.item.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2D2F39),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  line.item.code ?? '',
                  style: const TextStyle(color: Color(0xFF7C8698)),
                ),

                const SizedBox(height: 14),

                // Stepper (LIVE SYNC)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QtyBtn(
                      icon: Icons.remove_rounded,
                      enabled: q > 0,
                      onTap: () {
                        final next = math.max(0, q - 1);
                        setState(() => q = next);
                        apply(next); // updates cart OR removes at 0
                      },
                    ),
                    Container(
                      width: 64,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE1E7F2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        q.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D2F39),
                        ),
                      ),
                    ),
                    _QtyBtn(
                      icon: Icons.add_rounded,
                      enabled: q < max,
                      onTap: () {
                        final next = math.min(max, q + 1);
                        setState(() => q = next);
                        apply(next); // updates cart immediately
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  'Max: $max',
                  style: const TextStyle(
                    color: Color(0xFF7C8698),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 16),

                // Footer buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Get.back(), // changes already applied
                        child: const Text(
                          'Done',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFE1E7F2).withOpacity(enabled ? 1 : 0.6),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF2D2F39) : const Color(0xFF7C8698),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 22, color: color ?? _C.text);
    return Tooltip(
      message: tooltip ?? '',
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(padding: const EdgeInsets.all(6.0), child: iconWidget),
      ),
    );
  }
}

/* ───────── Results Header & Filter Card ───────── */

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.inventory_2_outlined, size: 18, color: _C.muted),
        const SizedBox(width: 8),
        const Text(
          'Results',
          style: TextStyle(color: _C.text, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 8),
        const _Chip.ghost(''),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _Chip.ghost('$count items'),
          ),
        ),
      ],
    );
  }
}

class _FilterCard extends GetView<SparesRequestController> {
  const _FilterCard({required this.isTablet});
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    final labelStyle = TextStyle(
      color: _C.muted,
      fontWeight: FontWeight.w600,
      fontSize: isTablet ? 15 : 14,
    );

    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EEF6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.apartment_rounded, size: 18, color: _C.muted),
              SizedBox(width: 8),
              Text(
                'Assets Shop',
                style: TextStyle(color: _C.text, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 8),
              _Chip.ghost('CNC 1'),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _C.border),
          const SizedBox(height: 12),

          Text('Cat 1', style: labelStyle),
          const SizedBox(height: 6),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedCat1.value,
              isExpanded: true,
              decoration: _ddDecoration(),
              items: controller.cat1List
                  .map(
                    (r) => DropdownMenuItem<String>(
                      value: r,
                      child: Text(r, style: const TextStyle(color: _C.text)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => controller.selectedCat1.value = v,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              hint: const Text('Option 1'),
            ),
          ),
          const SizedBox(height: 12),

          Text('Cat 2', style: labelStyle),
          const SizedBox(height: 6),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedCat2.value,
              isExpanded: true,
              decoration: _ddDecoration(),
              items: controller.cat2List
                  .map(
                    (r) => DropdownMenuItem<String>(
                      value: r,
                      child: Text(r, style: const TextStyle(color: _C.text)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => controller.selectedCat2.value = v,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              hint: const Text('Option 2'),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Spacer(),
              SizedBox(
                height: 44,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 1.5,
                  ),
                  onPressed: controller.go,
                  icon: const Icon(Icons.search_rounded, size: 20),
                  label: const Text(
                    'Go',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _ddDecoration() => InputDecoration(
    hintText: 'Select',
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _C.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _C.border),
    ),
  );
}

/* ───────── Result Item Row ───────── */

class _ItemRow extends GetView<SparesRequestController> {
  const _ItemRow({required this.item});
  final SpareItem item;

  @override
  Widget build(BuildContext context) {
    final left = controller.leftFor(item.id);
    final out = left == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EEF6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: out
                  ? _C.danger.withOpacity(0.9)
                  : _C.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.settings_outlined, size: 22, color: _C.muted),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _C.muted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (out)
                      const _Chip.outlined('OUT OF STOCK', color: _C.danger)
                    else
                      _Chip.outlined('$left in stock', color: _C.success),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          _Stepper(item: item),
        ],
      ),
    );
  }
}

class _Stepper extends GetView<SparesRequestController> {
  const _Stepper({required this.item});
  final SpareItem item;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final q = controller.qtyDraft[item.id] ?? 0;
      final left = controller.leftFor(item.id);

      final canInc = left > 0 && q < left;
      final canDec = q > 0;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: _C.stepBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _stepBtn(
              icon: Icons.remove_rounded,
              enabled: canDec,
              onTap: canDec ? () => controller.dec(item.id) : null,
            ),
            Container(
              width: 38,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _C.border),
              ),
              child: Text(
                q.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: _C.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _stepBtn(
              icon: Icons.add_rounded,
              enabled: canInc,
              onTap: canInc ? () => controller.inc(item.id) : null,
            ),
          ],
        ),
      );
    });
  }

  Widget _stepBtn({
    required IconData icon,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Icon(icon, size: 22, color: enabled ? _C.text : _C.muted),
      ),
    );
  }
}

/* ───────── Chips & Empty state ───────── */

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final bool outline;

  const _Chip({
    required this.text,
    required this.bg,
    required this.fg,
    this.outline = false,
    super.key,
  });

  const _Chip.filled(String t, {Key? key})
    : this(text: t, bg: const Color(0xFFEFF4FF), fg: _C.primary, key: key);
  const _Chip.ghost(String t, {Key? key})
    : this(text: t, bg: const Color(0xFFF4F6FA), fg: _C.muted, key: key);
  const _Chip.outlined(String t, {required Color color, Key? key})
    : this(text: t, bg: Colors.transparent, fg: color, outline: true, key: key);

  @override
  Widget build(BuildContext context) {
    final content = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: outline
          ? BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: fg.withOpacity(0.75), width: 1.2),
            )
          : BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: content,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, color: _C.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _C.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: _C.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
