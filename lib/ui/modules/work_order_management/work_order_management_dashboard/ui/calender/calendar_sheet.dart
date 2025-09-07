// calendar_sheet.dart
import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:easy_ops/ui/modules/work_order_management/work_order_management_dashboard/controller/work_order_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarSheet extends GetView<WorkOrdersController> {
  const CalendarSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
          child: Obx(() {
            final focused = controller.focusedDay.value;
            return TableCalendar<MarkerEvent>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: focused,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              availableGestures: AvailableGestures.horizontalSwipe,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),

                // smaller icons + tighter paddings
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.primaryBlue,
                ),
                leftChevronPadding: const EdgeInsets.only(
                  right: 4,
                ), // reduce gap to title
                rightChevronPadding: const EdgeInsets.only(left: 4),

                // trim header insets
                headerPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                headerMargin: const EdgeInsets.only(
                  bottom: 6,
                ), // keep a small gap below header
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Color(0xFF99A3B0),
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: TextStyle(
                  color: Color(0xFF99A3B0),
                  fontWeight: FontWeight.w600,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: const TextStyle(color: Color(0xFF2D2F39)),
                weekendTextStyle: const TextStyle(color: Color(0xFF2D2F39)),
                todayDecoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF), // pale blue background circle
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
                cellMargin: const EdgeInsets.symmetric(vertical: 6),
              ),
              selectedDayPredicate: (day) =>
                  isSameDay(day, controller.selectedDay.value),
              eventLoader: controller.eventsFor,
              onDaySelected: (sel, foc) {
                controller.selectedDay.value = sel;
                controller.focusedDay.value = foc;
                // Close after pick (optional):
                Get.back();
              },
              onPageChanged: (foc) => controller.focusedDay.value = foc,
              calendarBuilders: CalendarBuilders<MarkerEvent>(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox.shrink();
                  // draw small colored dots centered under the number
                  return Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        events.length.clamp(0, 4), // cap to 4 dots
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            width: 4.2,
                            height: 4.2,
                            decoration: BoxDecoration(
                              color: events[i].color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
