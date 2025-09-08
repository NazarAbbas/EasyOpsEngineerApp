import 'package:easy_ops/route_managment/routes.dart';
import 'package:get/get.dart';

class DiagnosticsController extends GetxController {
  final isLoading = true.obs;
  final wo = Rxn<WorkOrder>();

  final opInfoExpanded = true.obs;
  final woInfoExpanded = false.obs;

  // Media
  final photoPaths = <String>[
    // Fallback URLs (replace with assets later if you prefer)
    'https://fastly.picsum.photos/id/459/200/200.jpg?hmac=WxFjGfN8niULmp7dDQKtjraxfa4WFX-jcTtkMyH4I-Y',
    'https://fastly.picsum.photos/id/416/200/300.jpg?hmac=KIMUiPYQ0X2OQBuJIwtfL9ci1AGeu2OqrBH4GqpE7Bc',
    'https://fastly.picsum.photos/id/459/200/200.jpg?hmac=WxFjGfN8niULmp7dDQKtjraxfa4WFX-jcTtkMyH4I-Y',
    'https://fastly.picsum.photos/id/416/200/300.jpg?hmac=KIMUiPYQ0X2OQBuJIwtfL9ci1AGeu2OqrBH4GqpE7Bc',
  ].obs;

  // You can switch to an asset later: assets/dummy/work_orders/voice_note1.m4a
  final voiceNotePath =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'.obs;

  Future<void> load() async {
    try {
      isLoading.value = true;
      wo.value = await WorkOrderApi.fetchById('WO-1');
    } catch (e) {
      Get.snackbar('Error', 'Failed to load work order');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> endWork() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    Get.toNamed(Routes.closureScreen);
    //Get.snackbar('Success', 'Work ended');
  }

  Future<void> hold() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    isLoading.value = false;
    Get.snackbar('Updated', 'Work order put on Hold');
  }

  Future<void> reassign() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    isLoading.value = false;
    Get.snackbar('Updated', 'Reassignment started');
  }

  Future<void> cancel() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 900));
    Get.toNamed(Routes.cancelWorkOrderFromDiagnosticsScreen);
    isLoading.value = false;
    // Get.snackbar('Updated', 'Work order canceled');
  }

  @override
  void onInit() {
    load();
    super.onInit();
  }
}

class Person {
  final String name;
  final String role;
  final String phone;

  const Person({required this.name, required this.role, required this.phone});
}

class WorkOrder {
  final String id;
  final String title;
  final String code;
  final String priority; // High / Medium / Low
  final String status; // In Progress / Open / Closed
  final String category; // Mechanical etc.
  final DateTime createdAt;
  final Duration elapsed;
  final Duration estimated;

  final Person reportedBy;
  final Person manager;

  const WorkOrder({
    required this.id,
    required this.title,
    required this.code,
    required this.priority,
    required this.status,
    required this.category,
    required this.createdAt,
    required this.elapsed,
    required this.estimated,
    required this.reportedBy,
    required this.manager,
  });
}

class WorkOrderApi {
  // Simulates network latency and returns fake data
  static Future<WorkOrder> fetchById(String id) async {
    await Future.delayed(const Duration(seconds: 2)); // fake delay
    final now = DateTime.now();
    return WorkOrder(
      id: id,
      title: 'Conveyor Belt Stopped\nAbruptly During Operation',
      code: 'BD-102',
      priority: 'High',
      status: 'In Progress',
      category: 'Mechanical',
      createdAt: DateTime(now.year, now.month, now.day, 18, 8),
      elapsed: const Duration(hours: 1, minutes: 20),
      estimated: const Duration(hours: 3),
      reportedBy: const Person(
        name: 'Ashwath Mohan\nMahendran',
        role: 'Reported By',
        phone: '+91-00000-00000',
      ),
      manager: const Person(
        name: 'Rajesh Kumar',
        role: 'Maintenance Manager',
        phone: '+91-11111-11111',
      ),
    );
  }
}
