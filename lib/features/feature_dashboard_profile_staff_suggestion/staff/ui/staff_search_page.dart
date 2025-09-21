import 'package:easy_ops/features/feature_dashboard_profile_staff_suggestion/staff/controller/staff_search_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaffSearchPage extends GetView<StaffSearchController> {
  const StaffSearchPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  InputDecoration _inputDecoration(
    BuildContext context,
    String hint, {
    Widget? suffixIcon,
  }) {
    final isTab = _isTablet(context);
    final radius = isTab ? 12.0 : 10.0;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFF98A2B3),
        fontSize: isTab ? 14 : 13,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTab ? 14 : 12,
        vertical: 12,
      ),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.4,
        ),
      ),
    );
  }

  TextStyle _labelStyle(BuildContext context) {
    final isTab = _isTablet(context);
    return TextStyle(
      color: const Color(0xFF344054),
      fontWeight: FontWeight.w700,
      fontSize: isTab ? 13 : 12.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTab = _isTablet(context);
    final double pad = isTab ? 18 : 16;
    final double gap = isTab ? 14 : 12;
    final double bottomBarH = isTab ? 64 : 58;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Staff Search',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                        fontSize: isTab ? 20 : 18,
                      ),
                    ),
                    SizedBox(height: gap),

                    // Search box
                    TextField(
                      controller: controller.queryCtrl,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontSize: isTab ? 14 : 13.5,
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _inputDecoration(
                        context,
                        'Search by Employee ID/ Name',
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            CupertinoIcons.search,
                            size: isTab ? 18 : 16,
                            color: const Color(0xFF98A2B3),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: gap * 1.2),

                    // Location
                    Text('Location', style: _labelStyle(context)),
                    SizedBox(height: 6),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.location.value,
                        isExpanded: true,
                        icon: const Icon(CupertinoIcons.chevron_down, size: 18),
                        decoration: _inputDecoration(context, ''),
                        items: controller.locations
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => controller.location.value = v,
                        style: TextStyle(
                          fontSize: isTab ? 14 : 13.5,
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: gap),

                    // Shift
                    Text('Shift', style: _labelStyle(context)),
                    SizedBox(height: 6),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.shift.value,
                        isExpanded: true,
                        icon: const Icon(CupertinoIcons.chevron_down, size: 18),
                        decoration: _inputDecoration(context, ''),
                        items: controller.shifts
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => controller.shift.value = v,
                        style: TextStyle(
                          fontSize: isTab ? 14 : 13.5,
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: gap),

                    // Date
                    Text('Date', style: _labelStyle(context)),
                    SizedBox(height: 6),
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.pickDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            initialValue: controller.dateLabel,
                            style: TextStyle(
                              fontSize: isTab ? 14 : 13.5,
                              color: const Color(0xFF111827),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration(
                              context,
                              '',
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  CupertinoIcons.calendar,
                                  size: isTab ? 18 : 16,
                                  color: const Color(0xFF98A2B3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: gap),

                    // Department
                    Text('Department', style: _labelStyle(context)),
                    SizedBox(height: 6),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.department.value,
                        isExpanded: true,
                        icon: const Icon(CupertinoIcons.chevron_down, size: 18),
                        decoration: _inputDecoration(context, ''),
                        items: controller.departments
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => controller.department.value = v,
                        style: TextStyle(
                          fontSize: isTab ? 14 : 13.5,
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    SizedBox(height: gap),

                    // Function
                    Text('Function', style: _labelStyle(context)),
                    SizedBox(height: 6),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.func.value,
                        isExpanded: true,
                        icon: const Icon(CupertinoIcons.chevron_down, size: 18),
                        decoration: _inputDecoration(context, ''),
                        items: controller.functions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => controller.func.value = v,
                        style: TextStyle(
                          fontSize: isTab ? 14 : 13.5,
                          color: const Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // bottom spacer so content doesn't hide behind CTA
                    SizedBox(height: bottomBarH + 12),
                  ],
                ),
              ),
            ),

            // Sticky Search button
            SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7FB),
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: SizedBox(
                  height: bottomBarH,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTab ? 14 : 12),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: isTab ? 16 : 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    child: const Text('Search'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -----------------------------
/// (Optional) Demo entry point
/// -----------------------------
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(StaffSearchController());
  runApp(const _SearchDemoApp());
}

class _SearchDemoApp extends StatelessWidget {
  const _SearchDemoApp();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Staff Search Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6BFF)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2F6BFF),
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const StaffSearchPage(),
    );
  }
}
