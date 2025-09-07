import 'dart:ui';
import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class AssetItem {
  final String name;
  final String brand;
  final String description;
  final String pill; // 'Critical' | 'Semi Critical' | 'Non Critical'
  final String state; // e.g. 'Working'
  final Color pillColor;

  const AssetItem({
    required this.name,
    required this.brand,
    required this.description,
    required this.pill,
    required this.state,
    required this.pillColor,
  });
}

class AreaGroup {
  final String title;
  final RxBool expanded;
  final List<AssetItem> items;
  int get count => items.length;

  AreaGroup({required this.title, bool expanded = false, required this.items})
    : expanded = expanded.obs;
}
