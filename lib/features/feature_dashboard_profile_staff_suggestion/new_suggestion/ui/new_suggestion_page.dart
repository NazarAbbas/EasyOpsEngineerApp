import 'package:easy_ops/features/feature_dashboard_profile_staff_suggestion/new_suggestion/controller/new_suggestions_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class NewSuggestionPage extends GetView<NewSuggestionController> {
  const NewSuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'New Suggestion',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            children: [
              // Reporter Info (collapsible)
              Obx(
                () => _ReporterInfoCard(
                  expanded: c.reporterExpanded.value,
                  onToggle: c.toggleReporter,
                  name: c.reporterName.value,
                  code: c.employeeCode.value,
                  role: c.role.value,
                  department: c.reporterDept.value,
                ),
              ),
              const SizedBox(height: 14),

              // Form
              Form(
                key: c.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Department'),
                    DropdownButtonFormField<String>(
                      value: c.department.value,
                      decoration: _inputDecoration(),
                      items: c.departments
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) => c.department.value = v,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Type'),
                    DropdownButtonFormField<String>(
                      value: c.type.value,
                      decoration: _inputDecoration(),
                      items: c.types
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => c.type.value = v,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Title'),
                    TextFormField(
                      controller: c.titleC,
                      validator: c.validateTitle,
                      decoration: _inputDecoration(
                        hint: 'Explain your summary in one line',
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Description'),
                    TextFormField(
                      controller: c.descriptionC,
                      validator: c.validateDesc,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        hint: 'Provide as detailed summary of your suggestion.',
                      ),
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Justification'),
                    TextFormField(
                      controller: c.justificationC,
                      validator: c.validateJust,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        hint: 'Provide details of the impact amount.',
                      ),
                    ),
                    const SizedBox(height: 14),

                    _FieldLabel('Impact Amount (₹)'),
                    TextFormField(
                      controller: c.amountC,
                      validator: c.validateAmount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                      ],
                      decoration: _inputDecoration(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: c.submit,
              child: const Text(
                'Submit',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// =================== UI HELPERS ===================

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D2F39),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hint}) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(
    color: Color(0xFF9AA4B2),
    fontWeight: FontWeight.w500,
  ),
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFE3E9F4)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFF2F6BFF), width: 1.5),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFE34B3B)),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFE34B3B), width: 1.2),
  ),
);

class _ReporterInfoCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final String name;
  final String code;
  final String role;
  final String department;

  const _ReporterInfoCard({
    required this.expanded,
    required this.onToggle,
    required this.name,
    required this.code,
    required this.role,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _InitialsAvatar(text: name, size: 36),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Reporter Info',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D2F39),
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: expanded ? 0.5 : 0, // rotate chevron
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF7C8698),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Body
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E9F4)),
            ),
            child: Column(
              children: [
                _KVRow(
                  label: 'Reported By',
                  value: '$name ($code)',
                  subtitleChip: role, // small chip under name
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE9EEF5)),
                const SizedBox(height: 10),
                _KVRow(label: 'Department', value: department),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Small label/value row with optional chip subtitle.
class _KVRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitleChip;
  const _KVRow({required this.label, required this.value, this.subtitleChip});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: subtitleChip == null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF7C8698),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D2F39),
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitleChip != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFEAF2FF),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    subtitleChip!,
                    style: const TextStyle(
                      color: Color(0xFF2F6BFF),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Circle avatar with initials + subtle ring.
class _InitialsAvatar extends StatelessWidget {
  final String text;
  final double size;
  const _InitialsAvatar({required this.text, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final initials = text.trim().isEmpty
        ? 'U'
        : text
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((e) => e[0])
              .join()
              .toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFFEAF2FF),
        foregroundColor: const Color(0xFF2F6BFF),
        child: Text(
          initials,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
