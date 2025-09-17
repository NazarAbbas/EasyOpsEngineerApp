import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:easy_ops/features/maintenance_work_order/spare_cart/models/spares_models.dart';
import 'package:easy_ops/features/maintenance_work_order/start_work_order/controller/start_work_order_controller.dart';
import 'package:flutter/material.dart';

class SpareCartController extends GetxController {
  final RxList<CartLine> cart = <CartLine>[].obs;
  final RxSet<String> editingKeys = <String>{}.obs;

  // storage
  static const _kCart = 'spare_cart_v1';
  final _box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    // Load saved cart (if any)
    _loadCart();

    // Save whenever cart changes
    ever<List<CartLine>>(cart, (_) => _saveCart());

    debugPrint('[SpareCartController] onInit hash=${identityHashCode(this)}');
  }

  /* ---------- public API ---------- */
  void addOrMerge(SpareItem it, int qty, {String? cat1, String? cat2}) {
    if (qty <= 0) return;
    final key = _makeKey(it, cat1, cat2);
    final idx = cart.indexWhere((e) => e.key == key);
    if (idx >= 0) {
      cart[idx].qty += qty;
      cart.refresh();
    } else {
      cart.add(CartLine(key: key, item: it, qty: qty, cat1: cat1, cat2: cat2));
    }
  }

  List<CartGroup> grouped() {
    final map = <String, CartGroup>{};
    for (final l in cart) {
      final k = '${l.cat1 ?? "-"}|${l.cat2 ?? "-"}';
      map.putIfAbsent(k, () => CartGroup(l.cat1, l.cat2)).lines.add(l);
    }
    return map.values.toList();
  }

  void toggleEdit(String key) => editingKeys.contains(key)
      ? editingKeys.remove(key)
      : editingKeys.add(key);

  void inc(String key) {
    final i = cart.indexWhere((e) => e.key == key);
    if (i < 0) return;
    cart[i].qty++;
    cart.refresh();
  }

  void dec(String key) {
    final i = cart.indexWhere((e) => e.key == key);
    if (i < 0) return;
    if (cart[i].qty > 1) {
      cart[i].qty--;
      cart.refresh();
    }
  }

  void delete(String key) => cart.removeWhere((e) => e.key == key);

  Future<void> resetCart() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Reset Cart?'),
        content: const Text('This will remove all items from the cart.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true) cart.clear();
  }

  // spare_cart_controller.dart  (only the placeOrder part shown)
  Future<void> placeOrder() async {
    if (cart.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add items first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Ensure we reference the SAME StartWorkOrderController
    final start = Get.isRegistered<StartWorkOrderController>()
        ? Get.find<StartWorkOrderController>()
        : Get.put(StartWorkOrderController(), permanent: true);

    // Merge cart into WO page
    start.addSparesFromCart(cart.toList());

    // Now clear the cart and close the screens
    cart.clear();
    editingKeys.clear();

    if (Get.key.currentState?.canPop() ?? false) Get.back(); // close View Cart
    if (Get.key.currentState?.canPop() ?? false)
      Get.back(); // close Request Spares

    Get.snackbar(
      'Order Placed',
      'Spares added to Work Order.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /* ---------- private ---------- */
  String _makeKey(SpareItem it, String? cat1, String? cat2) =>
      '${it.id}__${cat1 ?? ""}__${cat2 ?? ""}';

  void _saveCart() {
    final data = cart.map((e) => _lineToMap(e)).toList();
    _box.write(_kCart, data);
  }

  void _loadCart() {
    final raw = _box.read<List<dynamic>>(_kCart);
    if (raw == null) return;
    final parsed = <CartLine>[];
    for (final x in raw) {
      if (x is Map) {
        parsed.add(_lineFromMap(Map<String, dynamic>.from(x)));
      }
    }
    cart.assignAll(parsed);
  }

  Map<String, dynamic> _lineToMap(CartLine l) => {
    'key': l.key,
    'qty': l.qty,
    'cat1': l.cat1,
    'cat2': l.cat2,
    'item': {
      'id': l.item.id,
      'name': l.item.name,
      'code': l.item.code,
      'stock': l.item.stock,
    },
  };

  CartLine _lineFromMap(Map<String, dynamic> m) => CartLine(
    key: m['key'] as String,
    qty: (m['qty'] as num).toInt(),
    cat1: m['cat1'] as String?,
    cat2: m['cat2'] as String?,
    item: SpareItem(
      id: (m['item']?['id'] ?? '') as String,
      name: (m['item']?['name'] ?? '') as String,
      code: (m['item']?['code'] ?? '') as String,
      stock: ((m['item']?['stock']) as num?)?.toInt() ?? 0,
    ),
  );
}

/* helper for grouped UI */
class CartGroup {
  final String? cat1;
  final String? cat2;
  final List<CartLine> lines = [];
  CartGroup(this.cat1, this.cat2);
}
