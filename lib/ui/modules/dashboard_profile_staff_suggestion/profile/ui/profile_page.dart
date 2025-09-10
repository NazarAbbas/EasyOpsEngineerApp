import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:easy_ops/ui/modules/dashboard_profile_staff_suggestion/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    final c = controller;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,

        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        actions: const [SizedBox(width: 48)], // keep title truly centered
      ),
      body: SafeArea(
        child: Obx(() {
          final p = c.profile.value;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              children: [
                // Avatar + Edit
                _AvatarBlock(imageUrl: p.avatarUrl, onEdit: c.onEditAvatar),
                const SizedBox(height: 16),

                // ----- My Info -----
                const _SectionTitle('My Info'),
                const SizedBox(height: 8),
                _InfoCard(
                  children: [
                    _InfoRow(label: 'Name', value: p.displayName),
                    _InfoRow(label: 'Age', value: '${p.age}'),
                    _InfoRow(label: 'Blood Group', value: p.bloodGroup),
                    _InfoRow(
                      label: 'Phone No',
                      value: p.phone,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.call,
                          size: 18,
                          color: Color(0xFF2F6BFF),
                        ),
                        onPressed: () => c.callNumber(p.phone),
                        tooltip: 'Call',
                      ),
                    ),
                    _InfoRow(
                      label: 'Email',
                      value: p.email,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: Color(0xFF2F6BFF),
                        ),
                        onPressed: () => c.sendEmail(p.email),
                        tooltip: 'Email',
                      ),
                    ),
                    _InfoRow(label: 'Department', value: p.department),
                    _InfoRow(
                      label: 'Supervisor',
                      value: p.supervisorName,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.call,
                          size: 18,
                          color: Color(0xFF2F6BFF),
                        ),
                        onPressed: () => c.callNumber(p.supervisorPhone),
                        tooltip: 'Call Supervisor',
                      ),
                    ),
                    _InfoRow(label: 'Location', value: p.location),
                  ],
                ),
                const SizedBox(height: 16),

                // ----- Emergency Personal Contact -----
                const _SectionTitle('Emergency Personal Contact'),
                const SizedBox(height: 8),
                _InfoCard(
                  children: [
                    _InfoRow(label: 'Name', value: p.emergencyName),
                    _InfoRow(
                      label: 'Phone No',
                      value: p.emergencyPhone,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.call,
                          size: 18,
                          color: Color(0xFF2F6BFF),
                        ),
                        onPressed: () => c.callNumber(p.emergencyPhone),
                        tooltip: 'Call',
                      ),
                    ),
                    _InfoRow(
                      label: 'Email',
                      value: p.emergencyEmail,
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: Color(0xFF2F6BFF),
                        ),
                        onPressed: () => c.sendEmail(p.emergencyEmail),
                        tooltip: 'Email',
                      ),
                    ),
                    _InfoRow(
                      label: 'Relationship',
                      value: p.emergencyRelationship,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Collapsibles (look like your screenshot rows)
                _CollapsedRow(
                  title: 'Emergency Contact',
                  subtitle: '${p.emergencyContactsCount} Contacts',
                  expanded: c.emergencyExpanded,
                  onTap: () => c.emergencyExpanded.toggle(),
                  child: Column(
                    children: List.generate(3, (i) {
                      return _MiniContact(
                        name: 'Contact ${i + 1}',
                        phone: '+91 98XXXXXXXX',
                        onCall: () {},
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                _CollapsedRow(
                  title: 'Holiday Calendar',
                  subtitle: '${p.holidaysCount} Holidays',
                  expanded: c.holidayExpanded,
                  onTap: () => c.holidayExpanded.toggle(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _MiniLine('Jan 26 – Republic Day'),
                      _MiniLine('Mar 08 – Maha Shivratri'),
                      _MiniLine('Aug 15 – Independence Day'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Log out
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE34B3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1.5,
                    ),
                    onPressed: c.logout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// ===== Widgets =====

class _AvatarBlock extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onEdit;
  const _AvatarBlock({required this.imageUrl, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    const double size = 104; // total width/height
    const double radius = 100; // corner radius (rounded shape)

    final String url = (imageUrl?.isNotEmpty ?? false)
        ? imageUrl!
        : 'https://i.pravatar.cc/256?img=18'; // fallback avatar

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Rounded image with white ring + shadow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius - 1),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEAF2FF),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF2F6BFF),
                    size: 44,
                  ),
                ),
              ),
            ),
          ),

          // Pencil edit button
          Positioned(
            right: -2,
            bottom: -2,
            child: Material(
              color: const Color(0xFF2F6BFF),
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onEdit,
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E8F0), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7A8494),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E8F0), thickness: 1)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: -2,
            offset: Offset(0, 4),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(children: _withDividers(children)),
    );
  }

  List<Widget> _withDividers(List<Widget> kids) {
    final out = <Widget>[];
    for (var i = 0; i < kids.length; i++) {
      out.add(kids[i]);
      if (i != kids.length - 1) {
        out.add(const Divider(height: 14, color: Color(0xFFE9EEF5)));
      }
    }
    return out;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7C8698),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2F39),
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _CollapsedRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final RxBool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _CollapsedRow({
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOpen = expanded.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isOpen ? 14 : 14),
          border: Border.all(color: const Color(0xFFE9EEF5)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: -2,
              offset: Offset(0, 4),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: Color(0xFF2D2F39),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7C8698),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF7C8698),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: child,
              ),
              crossFadeState: isOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      );
    });
  }
}

class _MiniContact extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onCall;
  const _MiniContact({
    required this.name,
    required this.phone,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        name,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        phone,
        style: const TextStyle(fontSize: 12, color: Color(0xFF7C8698)),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.call, size: 18, color: Color(0xFF2F6BFF)),
        onPressed: onCall,
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  final String text;
  const _MiniLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12.5, color: Color(0xFF2D2F39)),
      ),
    );
  }
}
