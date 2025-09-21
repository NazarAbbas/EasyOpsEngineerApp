import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile {
  final String? avatarUrl;
  final String name;
  final String employeeCode; // e.g. (20164)
  final int age;
  final String bloodGroup;
  final String phone;
  final String email;
  final String department;
  final String supervisorName;
  final String supervisorPhone;
  final String location;

  final String emergencyName;
  final String emergencyPhone;
  final String emergencyEmail;
  final String emergencyRelationship;

  final int emergencyContactsCount;
  final int holidaysCount;

  const UserProfile({
    this.avatarUrl,
    required this.name,
    required this.employeeCode,
    required this.age,
    required this.bloodGroup,
    required this.phone,
    required this.email,
    required this.department,
    required this.supervisorName,
    required this.supervisorPhone,
    required this.location,
    required this.emergencyName,
    required this.emergencyPhone,
    required this.emergencyEmail,
    required this.emergencyRelationship,
    required this.emergencyContactsCount,
    required this.holidaysCount,
  });

  String get displayName => '$name ($employeeCode)';
}

class ProfileController extends GetxController {
  final profile = const UserProfile(
    avatarUrl:
        'https://i.pravatar.cc/256?img=12', // replace or set null to show icon
    name: 'Sanjay Kumar',
    employeeCode: '20164',
    age: 31,
    bloodGroup: 'B+',
    phone: '+91 8979065432',
    email: 'sanjaykumar222@abc.com',
    department: 'Electrical',
    supervisorName: 'Ram Sharma',
    supervisorPhone: '+91 9876543210',
    location: 'Branburry',
    emergencyName: 'Rakesh Kumar',
    emergencyPhone: '+91 9875466484',
    emergencyEmail: 'sanjaykumar222@abc.com',
    emergencyRelationship: 'Brother',
    emergencyContactsCount: 5,
    holidaysCount: 17,
  ).obs;

  final emergencyExpanded = false.obs;
  final holidayExpanded = false.obs;

  void onEditAvatar() {
    // Navigate to edit profile / image picker
  }

  void logout() {
    // your logout logic
  }

  Future<void> callNumber(String rawNumber) async {
    final sanitized = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: sanitized);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar('Failed to call', 'Could not open dialer for $rawNumber');
    }
  }

  Future<void> sendEmail(
    String address, {
    String? subject,
    String? body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: address,
      queryParameters: {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      },
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar('Failed to email', 'Could not open email app for $address');
    }
  }
}
