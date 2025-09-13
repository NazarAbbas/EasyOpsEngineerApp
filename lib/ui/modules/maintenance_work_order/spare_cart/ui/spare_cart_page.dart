import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:easy_ops/ui/modules/maintenance_work_order/spare_cart/models/spares_models.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/spare_cart/controller/spare_cart_controller.dart';

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const bg = Color(0xFFF6F7FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE1E7F2);
  static const text = Color(0xFF2D2F39);
  static const muted = Color(0xFF7C8698);
  static const appbarGrey = Color(0xFF5B6472);
}

class SparesCartPage extends GetView<SpareCartController> {
  const SparesCartPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final hPad = isTablet ? 20.0 : 14.0;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.appbarGrey,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('View Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        actions: [
          TextButton(
            onPressed: controller.resetCart,
            child: const Text(
              'Reset Cart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final groups = controller.grouped();
        return ListView(
          padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 14),
          children: [
            Container(
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
                    'Assets Shop',
                    style: TextStyle(
                      color: _C.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text('CNC 1', style: TextStyle(color: _C.text)),
                  const SizedBox(height: 12),
                  if (groups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Your cart is empty',
                        style: TextStyle(color: _C.muted),
                      ),
                    ),
                  for (int gi = 0; gi < groups.length; gi++) ...[
                    if (gi > 0)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, color: _C.border),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Cat 1: ${groups[gi].cat1 ?? "-"}',
                            style: const TextStyle(color: _C.text),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Cat 2: ${groups[gi].cat2 ?? "-"}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: _C.text),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: _C.border),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Part No.',
                            style: TextStyle(
                              color: _C.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Required',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: _C.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    for (final line in groups[gi].lines)
                      _CartLineRow(line: line),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 10),
          child: SizedBox(
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
                    onPressed: Get.back,
                    child: const Text(
                      'Go Back',
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
                    onPressed: controller.placeOrder,
                    child: const Text(
                      'Place Order',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartLineRow extends GetView<SpareCartController> {
  const _CartLineRow({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = controller.editingKeys.contains(line.key);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                line.item.code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _C.text),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEditing)
                      _StepperInline(
                        qty: line.qty,
                        onInc: () => controller.inc(line.key),
                        onDec: () => controller.dec(line.key),
                      )
                    else
                      Text(
                        '${line.qty.toString().padLeft(2, '0')} nos',
                        style: const TextStyle(
                          color: _C.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: Icons.edit,
                      onTap: () => controller.toggleEdit(line.key),
                    ),
                    const SizedBox(width: 6),
                    _IconBtn(
                      icon: Icons.delete_outline,
                      onTap: () => controller.delete(line.key),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(child: Icon(icon, size: 18, color: _C.primary)),
        ),
      ),
    );
  }
}

class _StepperInline extends StatelessWidget {
  const _StepperInline({
    required this.qty,
    required this.onInc,
    required this.onDec,
  });
  final int qty;
  final VoidCallback onInc;
  final VoidCallback onDec;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(icon: Icons.remove_rounded, onTap: qty > 1 ? onDec : null),
          Container(
            width: 34,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _C.border),
            ),
            child: Text(
              qty.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: _C.text,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          _btn(icon: Icons.add_rounded, onTap: onInc),
        ],
      ),
    );
  }

  Widget _btn({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Icon(icon, size: 18, color: enabled ? _C.text : _C.muted),
      ),
    );
  }
}
