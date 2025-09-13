import 'package:flutter/foundation.dart';

@immutable
class SpareItem {
  final String id;
  final String name;
  final String code;
  final int stock;

  const SpareItem({
    required this.id,
    required this.name,
    required this.code,
    required this.stock,
  });
}

class CartLine {
  final String key; // unique = itemId + cat1 + cat2
  final SpareItem item;
  int qty;
  final String? cat1;
  final String? cat2;

  CartLine({
    required this.key,
    required this.item,
    required this.qty,
    required this.cat1,
    required this.cat2,
  });
}
