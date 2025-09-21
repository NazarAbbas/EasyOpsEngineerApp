import 'package:easy_ops/features/feature_maintenance_work_order/cancel_work_order/controller/cancel_work_order_controller_from_diagnostics.dart';
import 'package:easy_ops/core/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CancelWorkOrderPageFromDiagnostic
    extends GetView<CancelWorkOrderControllerFromDiagnostics> {
  const CancelWorkOrderPageFromDiagnostic({super.key});

  @override
  Widget build(BuildContext context) {
    const bgHeader = Color(0xFF3C4354);
    const cardBorder = Color(0xFFE9EEF5);
    const fieldBg = Color(0xFFF7F8FA);

    final radius = BorderRadius.circular(14);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Cancel Work Order'),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
              child: Container(
                decoration: BoxDecoration(color: fieldBg, borderRadius: radius),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Reason'),
                    const SizedBox(height: 8),
                    _ReasonDropdown(
                      value: controller.selectedReason.value,
                      items: controller.reasons,
                      onChanged: controller.isLoading.value
                          ? null
                          : controller.onReasonChanged,
                    ),
                    const SizedBox(height: 16),
                    const _Label('Remarks (Optional)'),
                    const SizedBox(height: 8),
                    _RemarksField(
                      enabled: !controller.isLoading.value,
                      onChanged: (v) => controller.remarks.value = v,
                    ),
                  ],
                ),
              ),
            ),

            // Thin top progress bar while submitting
            if (controller.isLoading.value)
              LoadingOverlay(message: 'Cancelling work order…'),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: cardBorder)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.discard,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Cancel Work Order',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/* -------------------------- Small UI helpers -------------------------- */

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2430),
      ),
    );
  }
}

class _ReasonDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const _ReasonDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _RemarksField extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String>? onChanged;
  const _RemarksField({required this.enabled, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      minLines: 3,
      maxLines: 6,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
