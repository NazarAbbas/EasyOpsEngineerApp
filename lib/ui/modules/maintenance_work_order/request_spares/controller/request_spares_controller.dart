import 'package:get/get.dart';
import 'package:easy_ops/route_managment/routes.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/spare_cart/models/spares_models.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/spare_cart/controller/spare_cart_controller.dart';

/// Use ONE shared SpareCartController across the app.
class SparesRequestController extends GetxController {
  /// Grab the global cart controller (the one registered in GlobalBindings).
  final SpareCartController cartCtrl = Get.find<SpareCartController>();

  // ───────── Filters ─────────
  final cat1List = <String>['Option 1', 'Option 2', 'Option 3'].obs;
  final cat2List = <String>['Option 1', 'Option 2', 'Option 3'].obs;
  final selectedCat1 = RxnString();
  final selectedCat2 = RxnString();

  // ───────── Results + draft quantities ─────────
  final showResults = false.obs;
  final results = <SpareItem>[].obs;

  /// Map of itemId -> quantity chosen in the UI before adding to cart
  final qtyDraft = <String, int>{}.obs;

  /// Cart badge (computed from shared cart)
  int get cartCount => cartCtrl.cart.length;

  /// Sum of draft quantities
  int get draftTotal => qtyDraft.values.fold<int>(0, (sum, v) => sum + v);

  @override
  void onInit() {
    super.onInit();
    // sensible defaults
    selectedCat1.value ??= cat1List.first;
    selectedCat2.value ??= cat2List.first;
  }

  // ───────── Actions ─────────

  /// Load filtered results (demo data)
  void go() {
    results.assignAll(const [
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
    ]);

    qtyDraft
      ..clear()
      ..addEntries(results.map((e) => MapEntry(e.id, 0)));

    showResults.value = true;
  }

  void inc(String id) {
    final it = results.firstWhereOrNull((e) => e.id == id);
    if (it == null) return;
    final cur = qtyDraft[id] ?? 0;
    if (it.stock == 0) return;
    if (cur >= it.stock) return;
    qtyDraft[id] = cur + 1;
  }

  void dec(String id) {
    final cur = qtyDraft[id] ?? 0;
    if (cur <= 0) return;
    qtyDraft[id] = cur - 1;
  }

  /// Move draft quantities to the SHARED cart and tag with cat1/cat2.
  void addToCart() {
    final c1 = selectedCat1.value;
    final c2 = selectedCat2.value;

    for (final it in results) {
      final q = qtyDraft[it.id] ?? 0;
      if (q <= 0) continue;
      cartCtrl.addOrMerge(it, q, cat1: c1, cat2: c2); // shared cart
    }

    // Reset draft + hide results
    showResults.value = false;
    qtyDraft.clear();

    Get.snackbar(
      'Added to Cart',
      'Selected items moved to cart.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show results again to add more items
  void addMore() => go();

  /// Navigate to the cart screen (NO new controller creation!)
  void viewCart() => Get.toNamed(Routes.sparesCartScreen);

  // (Optional) wrappers if you edit cart from here
  void updateLineQty(String key, int qty) {
    final i = cartCtrl.cart.indexWhere((e) => e.key == key);
    if (i < 0) return;
    cartCtrl.cart[i].qty = qty < 1 ? 1 : qty;
    cartCtrl.cart.refresh();
  }

  void removeLine(String key) => cartCtrl.delete(key);
  void resetAll() => cartCtrl.resetCart();
}
