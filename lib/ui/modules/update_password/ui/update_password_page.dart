// ignore_for_file: deprecated_member_use

import 'package:easy_ops/ui/modules/update_password/controller/update_password_controller.dart';
import 'package:easy_ops/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdatePasswordPage extends GetView<UpdatePasswordController> {
  UpdatePasswordPage({super.key});

  // Local reactive UI state (no controller changes needed)
  final RxDouble _strength = 0.0.obs;
  final RxBool _hasMinLen = false.obs;
  final RxBool _hasUpperLower = false.obs;
  final RxBool _hasNumber = false.obs;
  final RxBool _hasSpecial = false.obs;
  final RxBool _matches = false.obs;

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  void _evaluate(String pass, String confirm) {
    _hasMinLen.value = pass.length >= 8;
    _hasUpperLower.value = RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(pass);
    _hasNumber.value = RegExp(r'\d').hasMatch(pass);
    _hasSpecial.value = RegExp(
      r'[!@#\$%^&*(),.?":{}|<>_\-+=/\\\[\]]',
    ).hasMatch(pass);
    _matches.value = pass.isNotEmpty && pass == confirm;

    final satisfied = [
      _hasMinLen.value,
      _hasUpperLower.value,
      _hasNumber.value,
      _hasSpecial.value,
    ].where((x) => x).length;
    _strength.value = satisfied / 4.0;
  }

  Color _strengthColor(double v) {
    if (v < 0.34) return const Color(0xFFE94141); // weak
    if (v < 0.67) return const Color(0xFFFFA000); // medium
    return const Color(0xFF22C55E); // strong
  }

  String _strengthLabel(double v) {
    if (v < 0.34) return 'Weak';
    if (v < 0.67) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Update Password',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4285F4), Color(0xFF6EA8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        final loading = controller.isUpdating.value;

        final form = _FormCard(
          controller: controller,
          onChanged: () => _evaluate(
            controller.passwordController.text,
            controller.confirmPasswordController.text,
          ),
        );

        final requirements = _RequirementsCard(
          strength: _strength,
          hasMinLen: _hasMinLen,
          hasUpperLower: _hasUpperLower,
          hasNumber: _hasNumber,
          hasSpecial: _hasSpecial,
          matches: _matches,
          strengthColor: _strengthColor,
          strengthLabel: _strengthLabel,
        );

        return Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 28 : 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isTablet ? 980 : 560),
                  child: isTablet
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: form),
                            const SizedBox(width: 16),
                            SizedBox(width: 360, child: requirements),
                          ],
                        )
                      : Column(
                          children: [
                            form,
                            const SizedBox(height: 12),
                            requirements,
                          ],
                        ),
                ),
              ),
            ),

            if (loading) const LoadingOverlay(message: 'Updating…'),
          ],
        );
      }),
    );
  }
}

/* ------------------------------ Widgets ------------------------------ */

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _CardShell({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? const EdgeInsets.fromLTRB(18, 18, 18, 18);
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6EBF3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: pad,
        child: child,
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final UpdatePasswordController controller;
  final VoidCallback onChanged;
  const _FormCard({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return _CardShell(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 24 : 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.lock_outline, color: Color(0xFF4285F4)),
              SizedBox(width: 8),
              Text(
                'Create a new password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Use at least 8 characters. Include upper & lower case letters, a number, and a symbol.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 18),

          // New Password
          Obx(() {
            return TextField(
              controller: controller.passwordController,
              obscureText: controller.isPasswordHidden.value,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                labelText: 'New Password',
                hintText: '********',
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: const Color(0xFF4285F4),
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF4285F4),
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // Confirm Password
          Obx(() {
            return TextField(
              controller: controller.confirmPasswordController,
              obscureText: controller.isConfirmPasswordHidden.value,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                hintText: '********',
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordHidden.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: const Color(0xFF4285F4),
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF4285F4),
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            );
          }),
          const SizedBox(height: 22),

          // Submit
          Obx(() {
            final isLoading = controller.isUpdating.value;
            return SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : controller.updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  disabledBackgroundColor: const Color(
                    0xFF4285F4,
                  ).withOpacity(0.6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  final RxDouble strength;
  final RxBool hasMinLen;
  final RxBool hasUpperLower;
  final RxBool hasNumber;
  final RxBool hasSpecial;
  final RxBool matches;
  final Color Function(double) strengthColor;
  final String Function(double) strengthLabel;

  const _RequirementsCard({
    required this.strength,
    required this.hasMinLen,
    required this.hasUpperLower,
    required this.hasNumber,
    required this.hasSpecial,
    required this.matches,
    required this.strengthColor,
    required this.strengthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return _CardShell(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 22 : 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Password strength',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Obx(() {
            final v = strength.value.clamp(0.0, 1.0);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    color: strengthColor(v),
                    backgroundColor: const Color(0xFFF1F5FB),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  strengthLabel(v),
                  style: TextStyle(
                    color: strengthColor(v),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'Recommended',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Obx(
            () => _ReqRow(ok: hasMinLen.value, text: 'At least 8 characters'),
          ),
          Obx(
            () => _ReqRow(
              ok: hasUpperLower.value,
              text: 'Upper & lower case letters',
            ),
          ),
          Obx(() => _ReqRow(ok: hasNumber.value, text: 'At least one number')),
          Obx(() => _ReqRow(ok: hasSpecial.value, text: 'At least one symbol')),
          Obx(() => _ReqRow(ok: matches.value, text: 'Passwords match')),
        ],
      ),
    );
  }
}

class _ReqRow extends StatelessWidget {
  final bool ok;
  final String text;
  const _ReqRow({required this.ok, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: ok ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: ok ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
              fontWeight: ok ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
