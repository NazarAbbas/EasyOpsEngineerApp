import 'package:get/get.dart';
import 'package:easy_ops/core/route_management/routes.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/spare_cart/models/spares_models.dart';
import 'package:easy_ops/features/feature_maintenance_work_order/spare_cart/controller/spare_cart_controller.dart';

/// Use ONE shared SpareCartController across the app (bound in GlobalBindings).
class SparesRequestController extends GetxController {
  final SpareCartController cartCtrl = Get.find<SpareCartController>();

  // ───────── Filters ─────────
  final cat1List = <String>['Option 1', 'Option 2', 'Option 3'].obs;
  final cat2List = <String>['Option 1', 'Option 2', 'Option 3'].obs;
  final selectedCat1 = RxnString();
  final selectedCat2 = RxnString();

  // ───────── Results + draft quantities ─────────
  final showResults = false.obs;
  final results = <SpareItem>[].obs;
  final qtyDraft = <String, int>{}.obs; // itemId -> qty (before adding to cart)

  // ───────── Local stock tracking (UI side) ─────────
  final stockLeft = <String, int>{}.obs; // itemId -> remaining stock

  int leftFor(String id) {
    final v = stockLeft[id];
    if (v != null) return v;
    final it = results.firstWhereOrNull((e) => e.id == id);
    return it?.stock ?? 0;
  }

  // ───────── Derived ─────────
  int get cartCount => cartCtrl.cart.length;
  int get draftTotal => qtyDraft.values.fold<int>(0, (sum, v) => sum + v);

  @override
  void onInit() {
    super.onInit();
    selectedCat1.value ??= cat1List.first;
    selectedCat2.value ??= cat2List.first;
  }

  // ───────── Cart editing from summary ─────────
  void updateCartLineQty(dynamic line, int qty) {
    if (qty <= 0) {
      removeCartLine(line);
      return;
    }
    line.qty = qty;
    cartCtrl.cart.refresh();
  }

  void removeCartLine(dynamic line) {
    cartCtrl.cart.remove(line);
    cartCtrl.cart.refresh();
  }

  // ───────── Actions ─────────

  /// Load filtered results (mock data here). Seeds qtyDraft & stockLeft.
  void go() {
    final fresh = const [
      SpareItem(id: 'sm1', name: 'Spindle Motor', code: 'SM-1001', stock: 0),
      SpareItem(id: 'bs2', name: 'Ball Screws', code: 'BS-2002', stock: 20),
      SpareItem(
        id: 'lgr3',
        name: 'Linear Guide Rails',
        code: 'LGR-3003',
        stock: 30,
      ),
      SpareItem(id: 'bel4', name: 'Drive Belt', code: 'BEL-4004', stock: 12),
      SpareItem(
        id: 'brg5',
        name: 'Spindle Bearing',
        code: 'BRG-5005',
        stock: 8,
      ),
    ];

    results.assignAll(fresh);

    // init drafts
    qtyDraft
      ..clear()
      ..addEntries(results.map((e) => MapEntry(e.id, 0)));

    // seed stockLeft only if not already tracking an item
    for (final it in results) {
      stockLeft.putIfAbsent(it.id, () => it.stock);
    }

    showResults.value = true;
  }

  void inc(String id) {
    final it = results.firstWhereOrNull((e) => e.id == id);
    if (it == null) return;
    final cur = qtyDraft[id] ?? 0;
    final left = leftFor(id);
    if (left == 0) return; // out of stock
    if (cur >= left) return; // can't exceed remaining
    qtyDraft[id] = cur + 1;
  }

  void dec(String id) {
    final cur = qtyDraft[id] ?? 0;
    if (cur <= 0) return;
    qtyDraft[id] = cur - 1;
  }

  /// Move draft quantities to SHARED cart and decrement local stock.
  /// Skips any item with `toAdd == 0`.
  void addToCart() {
    final c1 = selectedCat1.value;
    final c2 = selectedCat2.value;

    for (final it in results) {
      final draft = qtyDraft[it.id] ?? 0;
      final left = leftFor(it.id);

      final int toAdd = draft <= left ? draft : left;
      if (toAdd <= 0) continue; // nothing to add / out of stock

      cartCtrl.addOrMerge(it, toAdd, cat1: c1, cat2: c2); // shared cart
      stockLeft[it.id] = left - toAdd; // reduce local stock
      qtyDraft[it.id] = 0; // clear draft
    }

    stockLeft.refresh();
    qtyDraft.refresh();

    // Hide results (optional; or keep them open if you prefer)
    showResults.value = false;
  }

  /// Show results again to add more
  void addMore() => go();

  /// Navigate to the cart screen (do not create a new controller)
  void viewCart() => Get.toNamed(Routes.sparesCartScreen);

  // Optional wrappers (if you edit cart from this screen by key)
  void updateLineQty(String key, int qty) {
    final i = cartCtrl.cart.indexWhere((e) => e.key == key);
    if (i < 0) return;
    cartCtrl.cart[i].qty = qty < 1 ? 1 : qty;
    cartCtrl.cart.refresh();
  }

  void removeLine(String key) => cartCtrl.delete(key);
  void resetAll() => cartCtrl.resetCart();
}
