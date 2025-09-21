import 'package:easy_ops/features/feature_preventive_maintenance/add_resource/controller/add_resource_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const bg = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const text = Color(0xFF1F2430);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE9EEF5);
}

class AddResourcePage extends GetView<AddResourceController> {
  const AddResourcePage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    Get.put(AddResourceController(), permanent: false);

    final isTablet = _isTablet(context);
    final hPad = isTablet ? 20.0 : 14.0;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Get.back<void>(),
        ),
        title: const Text(
          'Add Resources',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 120),
        children: const [
          _AddedList(), // initially hidden; appears after first Add
          SizedBox(height: 12),
          _FormCard(),
        ],
      ),
      bottomNavigationBar: Obx(() {
        // Read reactive fields *inside* Obx so it rebuilds correctly
        final hasAny = controller.added.isNotEmpty;
        final canAdd = controller.canAdd; // uses nameRx + selectedType
        final canSubmit = controller.canSubmit; // uses added + isSubmitting
        final loading = controller.isSubmitting.value;
        final kb = MediaQuery.of(context).viewInsets.bottom;

        final enabled = hasAny ? canSubmit : canAdd;
        final label = loading ? null : (hasAny ? 'Submit' : 'Add');

        return AnimatedPadding(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.only(bottom: kb > 0 ? kb - 6 : 0),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 12),
              child: SizedBox(
                height: isTablet ? 56 : 52,
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: enabled ? primary : _C.border,
                    foregroundColor: enabled ? Colors.white : _C.muted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: !enabled
                      ? null
                      : (hasAny ? controller.submit : controller.addToList),
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          label!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/* ─────────────────────── Added list on top ─────────────────────── */

class _AddedList extends GetView<AddResourceController> {
  const _AddedList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.added.isEmpty) return const SizedBox.shrink();
      return _SoftCard(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Added Resources',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3C4658),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.added.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 16, color: _C.border),
              itemBuilder: (_, i) => _AddedRowTile(index: i),
            ),
          ],
        ),
      );
    });
  }
}

/// Row that mirrors the "default" style:
///   "type | code" + location + assignee + date
class _AddedRowTile extends GetView<AddResourceController> {
  final int index;
  const _AddedRowTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final item = controller.added[index];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title: type | code
          Text(
            '${item.type}  |  ${item.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          // Location (static like default row)
          Obx(
            () => Text(
              controller.location.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _C.muted),
            ),
          ),
          const SizedBox(height: 8),
          // Assignee + date
          Row(
            children: [
              const Icon(CupertinoIcons.person, size: 16, color: _C.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.assignee ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _C.text),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.calendar, size: 16, color: _C.muted),
              const SizedBox(width: 6),
              Text(
                controller.fmtDate(item.targetDate),
                style: const TextStyle(color: _C.text),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Remove',
                onPressed: () => controller.removeAt(index),
                icon: const Icon(CupertinoIcons.trash, size: 18),
                color: Colors.redAccent,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Form card ───────────────────────── */

class _FormCard extends GetView<AddResourceController> {
  const _FormCard();

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Name'),
          const SizedBox(height: 6),
          TextField(
            controller: controller.nameCtrl,
            onChanged: (v) => controller.nameRx.value = v, // <-- important
            decoration: _inputDecoration(hint: 'Enter name'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          _label('Resource Type'),
          const SizedBox(height: 6),
          Obx(
            () => _DropdownBox<String>(
              value: controller.selectedType.value,
              hint: 'Select',
              items: controller.resourceTypes
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => controller.selectedType.value = v,
            ),
          ),
          const SizedBox(height: 14),

          _label('Assign To (Optional)'),
          const SizedBox(height: 6),
          Obx(
            () => _DropdownBox<String>(
              value: controller.selectedAssignee.value,
              hint: 'Select',
              items: controller.assignees
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (v) => controller.selectedAssignee.value = v,
            ),
          ),
          const SizedBox(height: 14),

          _label('Target Date (Optional)'),
          const SizedBox(height: 6),
          Obx(() {
            final label = controller.fmtDate(controller.targetDate.value);
            return _TappableBox(
              label: label,
              icon: CupertinoIcons.calendar,
              onTap: () => controller.pickDate(context),
            );
          }),
          const SizedBox(height: 14),

          _label('Add Note (Optional)'),
          const SizedBox(height: 6),
          TextField(
            controller: controller.noteCtrl,
            maxLines: 4,
            decoration: _inputDecoration(hint: ''),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(fontWeight: FontWeight.w700, color: _C.text),
  );
}

/* ───────────────────────── Shared UI helpers ───────────────────────── */

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: child,
    );
  }
}

class _DropdownBox<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const _DropdownBox({
    super.key,
    this.value,
    required this.hint,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _inputDecoration(hint: hint),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          items: items,
          onChanged: onChanged,
          icon: const Icon(CupertinoIcons.chevron_down),
        ),
      ),
    );
  }
}

class _TappableBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _TappableBox({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: label == 'DD/MM/YYYY' ? _C.muted : _C.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: _C.muted),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String hint = ''}) => InputDecoration(
  hintText: hint.isEmpty ? null : hint,
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _C.border),
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _C.border),
  ),
);
