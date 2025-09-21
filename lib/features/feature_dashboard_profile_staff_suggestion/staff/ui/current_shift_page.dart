// features/staff/ui/staff_current_shift_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/current_shift_controller.dart';

class StaffCurrentShiftPage extends GetView<CurrentShiftController> {
  const StaffCurrentShiftPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    Get.put(CurrentShiftController(), permanent: true);

    final isTab = _isTablet(context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      itemCount: controller.groups.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Department Status',
              style: TextStyle(
                color: const Color(0xFF2D2F39),
                fontSize: isTab ? 18 : 16,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          );
        }
        final g = controller.groups[i - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _GroupCard(group: g, onToggle: () => controller.toggle(i - 1)),
        );
      },
    );
  }
}

/* ---------- Cards ---------- */

class _GroupCard extends StatelessWidget {
  final DeptGroup group;
  final VoidCallback onToggle;
  const _GroupCard({required this.group, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isTab = MediaQuery.of(context).size.shortestSide >= 600;

    return Obx(() {
      final expanded = group.expanded.value;

      return Column(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: expanded
                        ? const Color(0xFF2F6BFF)
                        : const Color(0xFFE1E7F2),
                    width: expanded ? 1.2 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            group.title,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF2D2F39),
                              fontWeight: FontWeight.w800,
                              fontSize: isTab ? 15 : 14,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            group.countLabel,
                            style: TextStyle(
                              color: const Color(0xFF7C8698),
                              fontWeight: FontWeight.w700,
                              fontSize: isTab ? 12.5 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 160),
                      child: const Icon(
                        CupertinoIcons.chevron_down,
                        color: Color(0xFF2F6BFF),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 160),
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: group.members
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StaffCard(member: m),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _StaffCard extends StatelessWidget {
  final StaffMember member;
  const _StaffCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final isTab = MediaQuery.of(context).size.shortestSide >= 600;
    final statusColor = member.presence == Presence.present
        ? const Color(0xFF1D7A3D)
        : const Color(0xFFE25555);
    final statusText = member.presence == Presence.present
        ? 'Present'
        : 'Absent';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: member.name, url: member.avatarUrl),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: isTab ? 15 : 14,
                          color: const Color(0xFF111827),
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      CupertinoIcons.phone_fill,
                      color: Color(0xFF2F6BFF),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${member.discipline} | ${member.department}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF2D2F39),
                    fontWeight: FontWeight.w600,
                    fontSize: isTab ? 12.5 : 12,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${member.plant}  |  ${member.shift}  |  ${member.shop}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF2D2F39),
                    fontWeight: FontWeight.w600,
                    fontSize: isTab ? 12.5 : 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: isTab ? 12.5 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? url;
  const _Avatar({required this.name, this.url});

  String _initials(String s) {
    final p = s.trim().split(RegExp(r'\s+'));
    final a = p.isNotEmpty && p.first.isNotEmpty ? p.first[0] : '';
    final b = p.length > 1 && p.last.isNotEmpty ? p.last[0] : '';
    return (a + b).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide >= 600 ? 44.0 : 40.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: const Color(0xFFE1E7F2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null
          ? Image.network(url!, fit: BoxFit.cover)
          : Center(
              child: Text(
                _initials(name),
                style: const TextStyle(
                  color: Color(0xFF7C8698),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
    );
  }
}
