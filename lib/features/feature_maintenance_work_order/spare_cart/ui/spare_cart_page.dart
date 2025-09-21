import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:easy_ops/features/feature_maintenance_work_order/spare_cart/models/spares_models.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/spare_cart/controller/spare_cart_controller.dart';

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const bg = Color(0xFFF6F7FB);
  static const surface = Colors.white;
  static const border = Color(0xFFE1E7F2);
  static const text = Color(0xFF2D2F39);
  static const muted = Color(0xFF7C8698);
  static const appbarGrey = Color(0xFF5B6472);
  static const pill = Color(0xFFF4F6FA);
  static const stepBg = Color(0xFFF2F4F9);
  static const danger = Color(0xFFED3B40);
}

class SparesCartPage extends GetView<SpareCartController> {
  const SparesCartPage({super.key});

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
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleSpacing: 0,
        title: const Text(
          'View Cart',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
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
        // snapshot to avoid mid-build mutations
        final groups = List.of(controller.grouped());
        final isEmpty = groups.isEmpty;

        int totalLines = 0;
        int totalQty = 0;
        for (final g in groups) {
          totalLines += g.lines.length;
          for (final l in g.lines) totalQty += l.qty;
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 14),
          children: [
            _SummaryRow(totalLines: totalLines, totalQty: totalQty),
            const SizedBox(height: 12),
            Container(
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
                  // location header
                  Row(
                    children: const [
                      Icon(Icons.apartment_rounded, size: 18, color: _C.muted),
                      SizedBox(width: 8),
                      Text(
                        'Assets Shop',
                        style: TextStyle(
                          color: _C.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      _Chip(text: 'CNC 1', bg: _C.pill, fg: _C.muted),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: _C.border),
                  const SizedBox(height: 10),

                  if (isEmpty)
                    const _EmptyState(
                      title: 'Your cart is empty',
                      subtitle: 'Go back and add spares to see them here.',
                    ),

                  // groups
                  for (int gi = 0; gi < groups.length; gi++) ...[
                    if (gi > 0) const SizedBox(height: 12),
                    _GroupHeader(cat1: groups[gi].cat1, cat2: groups[gi].cat2),
                    const SizedBox(height: 8),
                    const _ListHeader(),
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
          child: Obx(() {
            final groups = List.of(controller.grouped());
            final disabled = groups.isEmpty;

            int totalQty = 0;
            for (final g in groups) {
              for (final l in g.lines) totalQty += l.qty;
            }

            return SizedBox(
              height: isTablet ? 56 : 52,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: primary, width: 1.5),
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
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1.5,
                      ),
                      onPressed: disabled ? null : controller.placeOrder,
                      child: Text(
                        disabled ? 'Place Order' : 'Place Order  ($totalQty)',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

/* ───────────────────────── Pieces ───────────────────────── */

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.totalLines, required this.totalQty});
  final int totalLines;
  final int totalQty;

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _C.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: _C.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      children: [
        cell('Lines', '$totalLines'),
        const SizedBox(width: 10),
        cell('Total Qty', '$totalQty'),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.cat1, required this.cat2});
  final String? cat1;
  final String? cat2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.category_outlined, size: 18, color: _C.muted),
        const SizedBox(width: 6),
        _Chip(text: 'Cat 1: ${cat1 ?? "-"}', bg: _C.pill, fg: _C.text),
        const SizedBox(width: 6),
        _Chip(text: 'Cat 2: ${cat2 ?? "-"}', bg: _C.pill, fg: _C.text),
      ],
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'Part No.',
            style: TextStyle(color: _C.muted, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Required',
            textAlign: TextAlign.right,
            style: TextStyle(color: _C.muted, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/* ───────── Line Row (with swipe-to-delete + inline edit) ───────── */

class _CartLineRow extends GetView<SpareCartController> {
  const _CartLineRow({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = controller.editingKeys.contains(line.key);

      return Dismissible(
        key: ValueKey('cart-line-${line.key}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          return await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Remove item?'),
              content: Text('Remove "${line.item.code}" from cart?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      color: _C.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) {
          controller.delete(line.key);
          Get.snackbar(
            'Removed',
            '"${line.item.code}" removed from cart',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(12),
          );
        },
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: _C.danger.withOpacity(.1),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: const Icon(Icons.delete_outline, color: _C.danger),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Code (and optional name)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.item.code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Uncomment to show name
                    // const SizedBox(height: 2),
                    // Text(line.item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _C.muted)),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Qty / editor + actions
              FittedBox(
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _C.pill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${line.qty.toString().padLeft(2, '0')} nos',
                          style: const TextStyle(
                            color: _C.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: isEditing
                          ? Icons.check_rounded
                          : Icons.edit_outlined,
                      tooltip: isEditing ? 'Done' : 'Edit',
                      onTap: () => controller.toggleEdit(line.key),
                    ),
                    const SizedBox(width: 6),
                    _IconBtn(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete',
                      color: _C.danger,
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Remove item?'),
                            content: Text(
                              'Remove "${line.item.code}" from cart?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(
                                    color: _C.danger,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) controller.delete(line.key);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
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
    final child = ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: 18, color: color ?? _C.primary),
          ),
        ),
      ),
    );
    return (tooltip == null || tooltip!.isEmpty)
        ? child
        : Tooltip(message: tooltip!, child: child);
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
        color: _C.stepBg,
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

/* ───────── Chips & Empty state ───────── */

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
      ),
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
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
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
