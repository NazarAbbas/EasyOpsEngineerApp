// confirm_slot_page.dart
// Tabs moved INTO the AppBar using DefaultTabController + TabBar + TabBarView.
// Uses a lightweight local _TabsController (RxInt) so the bottom bar reacts to tab changes.
// Swipe between tabs is disabled to keep state in sync (change via tab taps).

import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:easy_ops/ui/modules/preventive_maintenance/wotk_order/controller/work_order_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const bg = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const text = Color(0xFF1F2430);
  static const muted = Color(0xFF7C8698);
  static const border = Color(0xFFE9EEF5);
  static const danger = Color(0xFFED3B40);
}

/* Tabs index (local) */
class _TabsController extends GetxController {
  final index = 0.obs; // 0=Work Order, 1=History, 2=M/C Info
  void set(int i) => index.value = i;
}

class WorkOrderPage extends GetView<WorkOrderController> {
  const WorkOrderPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final tabs = Get.put(_TabsController(), permanent: false);
    final isTablet = _isTablet(context);
    final hPad = isTablet ? 20.0 : 14.0;

    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: _C.bg,
        appBar: AppBar(
          backgroundColor: primary,
          elevation: 0.5,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Get.back<void>(),
          ),
          title: const Text(
            'Confirm Slot',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              color: primary,
              child: TabBar(
                onTap: tabs.set, // keep our Rx in sync
                indicatorColor: AppColors.white,
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.white,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Work Order'),
                  Tab(text: 'History'),
                  Tab(text: 'M/C Info'),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CupertinoActivityIndicator());
          }
          return TabBarView(
            // Disable swipe so the bottom bar state always matches onTap updates
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // ── Tab 0: Work Order ───────────────────────────────────────────
              ListView(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 120),
                children: [
                  _MachineCard(
                    machine: controller.machineName,
                    brand: controller.brand,
                    location: controller.location,
                    severityText: controller.severityText,
                    running: controller.runningStatusText,
                  ),
                  const SizedBox(height: 14),
                  const _MetricsRow(),
                  const SizedBox(height: 14),
                  _PreventiveCard(
                    onViewActivities: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Half Yearly Comprehensive\nMaintenance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Select Slot',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const _SlotDropdown(),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton.icon(
                            onPressed: () =>
                                _showProposeDialog(context, controller),
                            icon: const Icon(
                              CupertinoIcons.add_circled_solid,
                              size: 18,
                            ),
                            label: const Text('+ Propose New'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Tab 1: History ──────────────────────────────────────────────
              ListView(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                children: const [
                  _HistoryCard(
                    title: 'PM Completed',
                    subtitle: '12 Feb, 10:40 AM • Technician: Rahul',
                    pill: 'Completed',
                  ),
                  SizedBox(height: 10),
                  _HistoryCard(
                    title: 'Breakdown Fix',
                    subtitle: '05 Jan, 04:10 PM • Technician: Priya',
                    pill: 'Resolved',
                  ),
                  SizedBox(height: 10),
                  _HistoryCard(
                    title: 'Inspection',
                    subtitle: '18 Dec, 02:25 PM • Technician: Ajay',
                    pill: 'OK',
                  ),
                ],
              ),

              // ── Tab 2: M/C Info ─────────────────────────────────────────────
              ListView(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                children: [
                  _MachineInfoCard(
                    machine: controller.machineName,
                    brand: controller.brand,
                    model: 'VMC-850',
                    serial: 'SN-AX9K-3321',
                    installedOn: '12 Aug 2020',
                    dept: 'CNC Shop',
                    location: controller.location,
                    status: controller.runningStatusText,
                  ),
                ],
              ),
            ],
          );
        }),
        bottomNavigationBar: Obx(() {
          final idx = tabs.index.value;
          // Only show Confirm button on "Work Order" tab (index 0)
          if (idx != 0) return const SizedBox.shrink();

          final enabled = controller.selectedSlotId.value != null;
          return SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
              color: Colors.transparent,
              child: SizedBox(
                height: isTablet ? 56 : 52,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: enabled ? _C.primary : _C.border,
                    foregroundColor: enabled ? Colors.white : _C.muted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: enabled ? 1.5 : 0,
                  ),
                  onPressed: enabled ? controller.confirmSelection : null,
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  static Future<void> _showProposeDialog(
    BuildContext context,
    WorkOrderController c,
  ) async {
    final textCtrl = TextEditingController();
    final proposed = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Propose New Slot'),
        content: TextField(
          controller: textCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g. 17 Mar (Mon) | 11:00 AM to 01:00 PM',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, textCtrl.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (proposed != null && proposed.isNotEmpty) {
      c.addProposedSlot(proposed);
    }
  }
}

/* ───────────────────────── Widgets ───────────────────────── */

class _MachineCard extends StatelessWidget {
  final String machine;
  final String brand;
  final String location;
  final String severityText;
  final String running;

  const _MachineCard({
    required this.machine,
    required this.brand,
    required this.location,
    required this.severityText,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$machine  |  ',
                        style: const TextStyle(
                          color: _C.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: brand,
                        style: const TextStyle(
                          color: _C.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _Pill(text: severityText, color: _C.danger),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFF),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.building_2_fill,
                  size: 18,
                  color: _C.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location, style: const TextStyle(color: _C.text)),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          running,
                          style: const TextStyle(
                            color: _C.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow();

  @override
  Widget build(BuildContext context) {
    Widget metric(String title, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _C.muted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _C.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          metric('MTBF', '110 Days'),
          _DividerV(),
          metric('BD Hours', '17 Hrs'),
          _DividerV(),
          metric('MTTR', '2.4 Hrs'),
          _DividerV(),
          metric('Criticality', 'Semi'),
        ],
      ),
    );
  }
}

class _DividerV extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: _C.border,
    );
  }
}

class _PreventiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback onViewActivities;
  const _PreventiveCard({required this.child, required this.onViewActivities});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Preventive',
                  style: TextStyle(
                    fontSize: 13,
                    color: _C.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewActivities,
                child: const Text(
                  'View Activities',
                  style: TextStyle(
                    color: _C.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SlotDropdown extends GetView<WorkOrderController> {
  const _SlotDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedSlotId.value;
      final items = controller.slots;

      if (items.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.border),
          ),
          child: const Text('No slots available'),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected,
            isExpanded: true,
            hint: const Text('Select'),
            icon: const Icon(CupertinoIcons.chevron_down),
            items: [
              for (final s in items)
                DropdownMenuItem<String>(
                  value: s.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      s.label,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
            ],
            onChanged: controller.selectSlot,
          ),
        ),
      );
    });
  }
}

/* ---- Extra sample cards for other tabs ---- */

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String pill;
  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.pill,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.doc_text, color: _C.muted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: _C.muted)),
              ],
            ),
          ),
          _Pill(text: pill, color: _C.primary),
        ],
      ),
    );
  }
}

class _MachineInfoCard extends StatelessWidget {
  final String machine,
      brand,
      model,
      serial,
      installedOn,
      dept,
      location,
      status;
  const _MachineInfoCard({
    required this.machine,
    required this.brand,
    required this.model,
    required this.serial,
    required this.installedOn,
    required this.dept,
    required this.location,
    required this.status,
  });

  Widget row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(k, style: const TextStyle(color: _C.muted)),
        ),
        Expanded(
          child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$machine  |  $brand',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _Pill(
                text: status,
                color: status.toLowerCase() == 'working'
                    ? _C.primary
                    : _C.danger,
              ),
            ],
          ),
          const SizedBox(height: 10),
          row('Model', model),
          row('Serial No.', serial),
          row('Installed On', installedOn),
          row('Department', dept),
          row('Location', location),
        ],
      ),
    );
  }
}
