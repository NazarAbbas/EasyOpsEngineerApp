import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/spare_cart/models/spares_models.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/request_spares/controller/request_spares_controller.dart';

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const bg = Color(0xFFF6F7FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE1E7F2);
  static const text = Color(0xFF2D2F39);
  static const muted = Color(0xFF7C8698);
  static const stepBg = Color(0xFFF2F4F9);
}

class RequestSparesPage extends GetView<SparesRequestController> {
  const RequestSparesPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final hPad = isTablet ? 20.0 : 14.0;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B6472),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Request Spares'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        actions: [
          // Badge listens to the SHARED cart directly
          Obx(() {
            final count = controller.cartCtrl.cart.length;
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
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 14),
        children: [
          // Cart summary (uses SHARED cart)
          Obx(() {
            final lines = controller.cartCtrl.cart;
            if (lines.isEmpty) return const SizedBox.shrink();
            return Container(
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
              ),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items in Cart',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _C.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...lines.map(
                    (l) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${l.item.name}\n${l.item.code}',
                              style: const TextStyle(
                                color: _C.text,
                                height: 1.2,
                              ),
                            ),
                          ),
                          Text(
                            'x${l.qty}',
                            style: const TextStyle(
                              color: _C.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          _FilterCard(isTablet: isTablet),
          const SizedBox(height: 16),

          // Results list (after Go)
          Obx(
            () => controller.showResults.value
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Divider(color: _C.border, thickness: 1),
                      const SizedBox(height: 8),
                      ...controller.results.map((it) => _ItemRow(item: it)),
                      const SizedBox(height: 8),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 10),
          child: Obx(() {
            final showing = controller.showResults.value;
            final draftQty = controller.draftTotal;
            final hasCart = controller.cartCtrl.cart.isNotEmpty;

            if (showing) {
              return SizedBox(
                height: isTablet ? 56 : 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: draftQty > 0 ? controller.addToCart : null,
                  child: Text(
                    'Add To Cart${draftQty > 0 ? '  ($draftQty)' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }

            if (hasCart) {
              return SizedBox(
                height: isTablet ? 56 : 52,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.primary,
                          side: const BorderSide(color: _C.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: controller.addMore,
                        child: const Text(
                          'Add More',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _C.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: controller.viewCart,
                        child: const Text(
                          'View Cart',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Initial state
            return SizedBox(
              height: isTablet ? 56 : 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _C.primary,
                  side: const BorderSide(color: _C.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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

/* ───────── Widgets ───────── */

class _FilterCard extends GetView<SparesRequestController> {
  const _FilterCard({required this.isTablet});
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Assets Shop',
            style: TextStyle(color: _C.text, fontWeight: FontWeight.w700),
          ),
          const Text('CNC 1', style: TextStyle(color: _C.text)),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _C.border),
          const SizedBox(height: 12),

          // Cat 1
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

          // Cat 2
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

          const SizedBox(height: 12),

          // Go button aligned to right
          Row(
            children: [
              const Spacer(),
              SizedBox(
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: controller.go,
                  child: const Text(
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

class _ItemRow extends GetView<SparesRequestController> {
  const _ItemRow({required this.item});
  final SpareItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EEF6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: name + code + stock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: _C.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(item.code, style: const TextStyle(color: _C.text)),
                const SizedBox(height: 2),
                Text(
                  '${item.stock} nos',
                  style: TextStyle(
                    color: item.stock == 0 ? Colors.red : _C.muted,
                    fontSize: 12,
                  ),
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
    final disabled = item.stock == 0;

    return Obx(() {
      final q = controller.qtyDraft[item.id] ?? 0;
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
              onTap: q > 0 ? () => controller.dec(item.id) : null,
            ),
            Container(
              width: 36,
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
              onTap: (!disabled && q < item.stock)
                  ? () => controller.inc(item.id)
                  : null,
            ),
          ],
        ),
      );
    });
  }

  Widget _stepBtn({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
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
