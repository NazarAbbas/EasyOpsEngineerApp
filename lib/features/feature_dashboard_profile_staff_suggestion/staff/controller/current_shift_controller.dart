import 'package:get/get.dart';

/* ============================ MODELS ============================ */

enum Presence { present, absent }

class StaffMember {
  final String name;
  final Presence presence;
  final String discipline; // Electrical / Mechanical
  final String department; // Maintenance
  final String plant; // Plant A
  final String shift; // Shift A
  final String shop; // Assets Shop
  final String? avatarUrl; // optional

  const StaffMember({
    required this.name,
    required this.presence,
    required this.discipline,
    required this.department,
    required this.plant,
    required this.shift,
    required this.shop,
    this.avatarUrl,
  });
}

class DeptGroup {
  final String title; // "Assets Shop", "Plant B | Assets Shop", etc.
  final RxBool expanded;
  final List<StaffMember> members;

  DeptGroup({
    required this.title,
    required bool initiallyExpanded,
    required this.members,
  }) : expanded = initiallyExpanded.obs;

  int get presentCount =>
      members.where((m) => m.presence == Presence.present).length;
  int get absentCount => members.length - presentCount;

  String get countLabel => '${presentCount} Present | ${absentCount} Absent';
}

/* ============================ CONTROLLER ============================ */

class CurrentShiftController extends GetxController {
  final selectedTab = 0.obs; // 0 = Current Shift, 1 = Search (UI only here)
  final groups = <DeptGroup>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Mock members (like your screenshot)
    final g1Members = <StaffMember>[
      const StaffMember(
        name: 'Ram Kumar',
        presence: Presence.present,
        discipline: 'Electrical',
        department: 'Maintenance',
        plant: 'Plant A',
        shift: 'Shift A',
        shop: 'Assets Shop',
        avatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=128&q=80',
      ),
      const StaffMember(
        name: 'Bittu Sharma',
        presence: Presence.present,
        discipline: 'Mechanical',
        department: 'Maintenance',
        plant: 'Plant A',
        shift: 'Shift A',
        shop: 'Assets Shop',
        avatarUrl:
            'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=128&q=80',
      ),
      const StaffMember(
        name: 'Devender Loya',
        presence: Presence.present,
        discipline: 'Mechanical',
        department: 'Maintenance',
        plant: 'Plant B',
        shift: 'Shift A',
        shop: 'Branburry',
        avatarUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=128&q=80',
      ),
      const StaffMember(
        name: 'Devesh Sharma',
        presence: Presence.absent,
        discipline: 'Mechanical',
        department: 'Maintenance',
        plant: 'Plant B',
        shift: 'Shift A',
        shop: 'Branburry',
      ),
    ];

    groups.assignAll([
      DeptGroup(
        title: 'Assets Shop',
        initiallyExpanded: true,
        members: g1Members,
      ),
      DeptGroup(
        title: 'Plant B | Assets Shop',
        initiallyExpanded: false,
        members: const [
          StaffMember(
            name: 'Rakesh Kumar',
            presence: Presence.present,
            discipline: 'Mechanical',
            department: 'Maintenance',
            plant: 'Plant B',
            shift: 'Shift B',
            shop: 'Assets Shop',
          ),
          StaffMember(
            name: 'Arun Verma',
            presence: Presence.absent,
            discipline: 'Electrical',
            department: 'Maintenance',
            plant: 'Plant B',
            shift: 'Shift B',
            shop: 'Assets Shop',
          ),
        ],
      ),
      DeptGroup(
        title: 'Plant E | Branburry',
        initiallyExpanded: false,
        members: const [
          StaffMember(
            name: 'Ravi Anand',
            presence: Presence.present,
            discipline: 'Mechanical',
            department: 'Maintenance',
            plant: 'Plant E',
            shift: 'Shift C',
            shop: 'Branburry',
          ),
        ],
      ),
    ]);
  }

  void toggle(int index) => groups[index].expanded.toggle();
}
