import 'package:easy_ops/features/assets_management/assets_dashboard/controller/assets_dashboard_controller.dart';
import 'package:easy_ops/features/assets_management/assets_details/controller/assets_details_controller.dart';
import 'package:easy_ops/features/assets_management/assets_history/controller/assets_history_controller.dart';
import 'package:easy_ops/features/assets_management/assets_management_dashboard/controller/assets_management_list_controller.dart';
import 'package:easy_ops/features/assets_management/assets_specification/controller/assets_specification_controller.dart';
import 'package:easy_ops/features/assets_management/pm_checklist/controller/pm_checklist_controller.dart';
import 'package:easy_ops/features/assets_management/pm_schedular/controller/pm_schedular_controller.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/alerts/controller/alerts_controller.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/home_dashboard/controller/home_dashboard_controller.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/new_suggestion/controller/new_suggestions_controller.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/profile/controller/profile_controller.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/suggestion/controller/suggestion_controller.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/suggestions_details/controller/suggestions_details_controller.dart';
import 'package:easy_ops/features/dashboard_profile_staff_suggestion/support/controller/support_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/WorkTabsController.dart';
import 'package:easy_ops/features/maintenance_work_order/cancel_work_order/controller/cancel_work_order_controller_from_diagnostics.dart';
import 'package:easy_ops/features/maintenance_work_order/closure/controller/closure_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/closure_signature/controller/sign_off_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/diagnostics/controller/diagnostics_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/history/controller/history_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/hold_work_order/controller/hold_work_order_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/maintenance_wotk_order_management/controller/work_order_management_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/pending_activity/controller/pending_activity_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/rca_analysis/controller/rca_analysis_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/reassign_work_order/controller/reassign_work_order_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/request_spares/controller/request_spares_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/return_spare_parts/controller/return_spare_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/spare_cart/controller/spare_cart_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/start_work_order/controller/start_work_order_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/start_work_submit/controller/start_work_submit_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/tabs/controller/work_order_details_tabs_controller.dart';
import 'package:easy_ops/features/maintenance_work_order/timeline/controller/timeline_controller.dart';
import 'package:easy_ops/features/preventive_maintenance/add_resource/controller/add_resource_controller.dart';
import 'package:easy_ops/features/preventive_maintenance/preventive_maintenance_dashboard/controller/preventive_maintenance_dashboard_controller.dart';
import 'package:easy_ops/features/preventive_maintenance/preventive_start_work/controller/preventive_start_work_controller.dart';
import 'package:easy_ops/features/preventive_maintenance/puposed_new_slot/controller/purposed_new_slot_controller.dart';
import 'package:easy_ops/features/preventive_maintenance/reschedular/controller/reschedule_controller.dart';
import 'package:easy_ops/features/preventive_maintenance/wotk_order/controller/work_order_controller.dart';
import 'package:easy_ops/features/spare_parts/consume_spare_parts/controller/consume_spare_parts_controller.dart';
import 'package:easy_ops/features/spare_parts/return_spare_parts/controller/return_spare_parts_controller.dart';
import 'package:easy_ops/features/spare_parts/tabs/controller/spare_parts_tabs_controller.dart';
import 'package:easy_ops/features/forgot_password/controller/forgot_password_controller.dart';
import 'package:easy_ops/features/login/controller/login_controller.dart';
import 'package:easy_ops/features/splash/controller/splash_controller.dart';
import 'package:easy_ops/features/update_password/controller/update_password_controller.dart';
import 'package:get/instance_manager.dart';

class ScreenBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashPageController());
    Get.lazyPut(() => LoginPageController());
    Get.lazyPut(() => ForgotPasswordController());

    Get.lazyPut(() => UpdatePasswordController());
    Get.lazyPut(() => SparePartsController());
    Get.lazyPut(() => WorkTabsController());
    Get.lazyPut(() => WorkOrderDetailsTabsController());
    Get.lazyPut(() => AssetsManagementDashboardController());
    Get.lazyPut(() => AssetsDetailController());
    Get.lazyPut(() => AssetSpecificationController());
    Get.lazyPut(() => AssetsDashboardController());
    Get.lazyPut(() => PMScheduleController());
    Get.lazyPut(() => PMChecklistController());
    Get.lazyPut(() => AssetsHistoryController());
    Get.lazyPut(() => HomeDashboardController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => SupportController());
    Get.lazyPut(() => SuggestionsController());
    Get.lazyPut(() => NewSuggestionController());
    Get.lazyPut(() => SuggestionDetailController());
    Get.lazyPut(() => AlertsController());
    Get.lazyPut(() => ReturnSparePartsController());
    Get.lazyPut(() => ConsumedSparePartsController());
    Get.lazyPut(() => WorkOrdersManagementController());
    Get.lazyPut(() => ReassignWorkOrderController());
    Get.lazyPut(() => StartWorkSubmitController());
    Get.lazyPut(() => HoldWorkOrderController());
    Get.lazyPut(() => DiagnosticsController());
    Get.lazyPut(() => CancelWorkOrderControllerFromDiagnostics());
    Get.lazyPut(() => ClosureController());
    Get.lazyPut(() => SignOffController());
    Get.lazyPut(() => ReturnSparesController());
    Get.lazyPut(() => RcaAnalysisController());
    Get.lazyPut(() => PendingActivityController());
    Get.lazyPut(() => SparesRequestController());
    Get.lazyPut(() => HistoryController());
    Get.lazyPut(() => TimelineController());
    Get.lazyPut(() => PreventiveMaintenanceDashboardController());
    Get.lazyPut(() => WorkOrderController());
    Get.lazyPut(() => PurposedNewSlotController());
    Get.lazyPut(() => PreventiveStartWorkController());
    Get.lazyPut(() => AddResourceController());
    Get.lazyPut(() => RescheduleController());
    Get.put(SpareCartController(), permanent: true); // shared cart
    // Keep ONE StartWorkOrderController for the active WO.
    // (If you support multiple WO pages at once, use tags.)
    if (!Get.isRegistered<StartWorkOrderController>()) {
      Get.put(StartWorkOrderController(), permanent: true);
    }

    //Get.lazyPut(() => SpareCartController());
  }
}
