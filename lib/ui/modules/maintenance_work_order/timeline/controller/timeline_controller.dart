// timeline_page.dart
// flutter pub add get
import 'package:easy_ops/ui/modules/maintenance_work_order/WorkTabsController.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/timeline/models/timeline.dart';
import 'package:get/get.dart';

/* ======================= CONTROLLER ======================= */

class TimelineController extends GetxController {
  // Header (mock/demo)
  final pageTitle = 'Work Order Details'.obs;
  final woId = 'BD-102'.obs;
  final summary = 'Tool misalignment and spindle speed issues in Bay 3.'.obs;
  final priority = 'High'.obs;
  final status = 'In Progress'.obs;
  final duration = '1h 20m'.obs;
  final time = '18:08'.obs;
  final date = '09 Aug'.obs;
  final category = 'Mechanical'.obs;

  // Timeline data
  final items = <TimelineEvent>[
    TimelineEvent(
      time: '21:08',
      date: '14 Sep',
      lines: [
        RichLine.text('Work Order closed by '),
        RichLine.link('Rajesh', onTap: () => Get.snackbar('User', 'Rajesh')),
      ],
      showDetails: true,
      onViewDetails: () => Get.snackbar('Details', 'Close details'),
    ),
    TimelineEvent(
      time: '18:08',
      date: '14 Sep',
      lines: [
        RichLine.text('Work Order assigned to '),
        RichLine.link('Rajesh', onTap: () => Get.snackbar('User', 'Rajesh')),
      ],
    ),
    TimelineEvent(
      time: '18:08',
      date: '14 Sep',
      lines: [
        RichLine.text('Work Order type changed to electrical\n'),
        RichLine.link('Dilip', onTap: () => Get.snackbar('User', 'Dilip')),
        RichLine.text(' Reassigned the Work Order'),
      ],
      showDetails: true,
      onViewDetails: () => Get.snackbar('Details', 'Reassign details'),
    ),
    TimelineEvent(
      time: '18:08',
      date: '14 Sep',
      lines: [
        RichLine.text('Work Order Accepted by '),
        RichLine.link('Dilip', onTap: () => Get.snackbar('User', 'Dilip')),
      ],
    ),
    TimelineEvent(
      time: '18:08',
      date: '14 Sep',
      lines: [
        RichLine.text('Work Order Assigned to '),
        RichLine.link('Dilip', onTap: () => Get.snackbar('User', 'Dilip')),
      ],
    ),
    TimelineEvent(
      time: '18:08',
      date: '14 Sep',
      lines: [RichLine.text('Work Order Created')],
    ),
  ].obs;

  //void goBack() => Get.back();

  void goBack(int i) => Get.find<WorkTabsController>().goTo(i);
}
