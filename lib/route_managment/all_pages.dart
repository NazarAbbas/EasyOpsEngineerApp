import 'package:easy_ops/route_managment/routes.dart';
import 'package:easy_ops/ui/binding/screen_binding.dart';
import 'package:easy_ops/ui/modules/assets_management/assets_dashboard/ui/assets_dashboard_page.dart';
import 'package:easy_ops/ui/modules/assets_management/assets_details/ui/assets_details_page.dart';
import 'package:easy_ops/ui/modules/assets_management/assets_history/ui/assets_history_page.dart';
import 'package:easy_ops/ui/modules/assets_management/assets_management_dashboard/ui/assets_management_dashboard/assets_management_dashboard_page.dart';
import 'package:easy_ops/ui/modules/assets_management/assets_specification/ui/assets_specification_page.dart';
import 'package:easy_ops/ui/modules/assets_management/pm_checklist/ui/pm_checklist_page.dart';
import 'package:easy_ops/ui/modules/assets_management/pm_schedular/ui/pm_schedular_page.dart';
import 'package:easy_ops/ui/modules/dashboard_profile_staff_suggestion/alerts/ui/alerts_page.dart';
import 'package:easy_ops/ui/modules/dashboard_profile_staff_suggestion/home_dashboard/ui/home_dashboard_page.dart';
import 'package:easy_ops/ui/modules/dashboard_profile_staff_suggestion/new_suggestion/ui/new_suggestion_page.dart';
import 'package:easy_ops/ui/modules/dashboard_profile_staff_suggestion/profile/ui/profile_page.dart';
import 'package:easy_ops/ui/modules/dashboard_profile_staff_suggestion/suggestion/ui/suggestion_page.dart';
import 'package:easy_ops/ui/modules/dashboard_profile_staff_suggestion/suggestions_details/ui/suggestions_details_page.dart';
import 'package:easy_ops/ui/modules/dashboard_profile_staff_suggestion/support/ui/support_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/cancel_work_order/ui/cancel_work_order_page_from_diagnostic.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/closure/ui/closure_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/closure_signature/ui/sign_off_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/diagnostics/ui/diagnostics_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/history/ui/history_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/hold_work_order/ui/hold_work_order_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/maintenance_wotk_order_management/ui/work_order_management_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/pending_activity/ui/panding_activity_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/rca_analysis/ui/rca_analysis_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/reassign_work_order/ui/reassign_work_order_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/request_spares/ui/request_spares_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/return_spare_parts/ui/return_spare_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/spare_cart/ui/spare_cart_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/start_work_order/ui/start_work_order_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/start_work_submit/ui/start_work_submit_page.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/tabs/ui/work_order_details_tabs_shell.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/timeline/ui/timeline_page.dart';
import 'package:easy_ops/ui/modules/preventive_maintenance/preventive_maintenance_dashboard/controller/preventive_maintenance_dashboard_controller.dart';
import 'package:easy_ops/ui/modules/preventive_maintenance/preventive_maintenance_dashboard/ui/preventive_maintenance_dashboard_page.dart';
import 'package:easy_ops/ui/modules/preventive_maintenance/wotk_order/ui/work_order_page.dart';
import 'package:easy_ops/ui/modules/spare_parts/tabs/ui/spare_parts_tabs_shell.dart';
import 'package:easy_ops/ui/modules/forgot_password/ui/forgot_password_page.dart';
import 'package:easy_ops/ui/modules/update_password/ui/update_password_page.dart';
import 'package:easy_ops/ui/modules/login/ui/login_page.dart';
import 'package:easy_ops/ui/modules/splash/ui/spalsh_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class AllPages {
  static List<GetPage> getPages() {
    return [
      GetPage(
        name: Routes.splashScreen,
        page: () => SplashPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.loginScreen,
        page: () => LoginPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.forgotPasswordScreen,
        page: () => ForgotPasswordPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.updatePasswordScreen,
        page: () => UpdatePasswordPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),

      // GetPage(
      //   name: Routes.workOrderScreen,
      //   page: () => WorkOrdersPage(),
      //   binding: ScreenBindings(),
      //   transition: Transition.zoom,
      // ),
      GetPage(
        name: Routes.workOrderManagementScreen,
        page: () => WorkOrdersManagementPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),

      GetPage(
        name: Routes.homeDashboardScreen,
        page: () => HomeDashboardPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      // GetPage(
      //   name: Routes.bottomNavigationAssetsScreen,
      //   page: () => NavigationBottomAssets(),
      //   binding: ScreenBindings(),
      //   transition: Transition.zoom,
      // ),
      // GetPage(
      //   name: Routes.workOrderInfoScreen,
      //   page: () => WorkOrderInfoPage(),
      //   binding: ScreenBindings(),
      //   transition: Transition.zoom,
      // ),
      // GetPage(
      //   name: Routes.operatorInfoScreen,
      //   page: () => OperatorInfoPage(),
      //   binding: ScreenBindings(),
      //   transition: Transition.zoom,
      // ),
      // GetPage(
      //   name: Routes.mcHistoryScreen,
      //   page: () => McHistoryPage(),
      //   binding: ScreenBindings(),
      //   transition: Transition.zoom,
      // ),
      // GetPage(
      //   name: Routes.workOrderTabShellScreen,
      //   page: () => WorkOrderTabsShell(),
      //   binding: ScreenBindings(),
      //   transition: Transition.rightToLeft,
      // ),
      // GetPage(
      //   name: Routes.workOrderDetailScreen,
      //   page: () => WorkOrderDetailsPage(),
      //   binding: ScreenBindings(),
      //   transition: Transition.rightToLeft,
      // ),
      // GetPage(
      //   name: Routes.updateWorkOrderTabScreen,
      //   page: () => WorkOrderTabsDetails(),
      //   binding: ScreenBindings(),
      //   transition: Transition.rightToLeft,
      // ),
      // GetPage(
      //   name: Routes.reOpenWorkOrderScreen,
      //   page: () => ReopenWorkOrderPage(),
      //   binding: ScreenBindings(),
      //   transition: Transition.rightToLeft,
      // ),
      // GetPage(
      //   name: Routes.closureWorkOrderScreen,
      //   page: () => ClosureWorkOrderPage(),
      //   binding: ScreenBindings(),
      //   transition: Transition.rightToLeft,
      // ),
      GetPage(
        name: Routes.assetsManagementDashboardScreen,
        page: () => AssetsManagementDashboardPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.assetsDetailsScreen,
        page: () => AssetsDetailPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.assetsSpecificationScreen,
        page: () => AssetsSpecificationPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.assetsDashboardScreen,
        page: () => AssetsDashboardPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.assetsPMSchedular,
        page: () => PMSchedulePage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.pMCheckListScreen,
        page: () => PMChecklistPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.assetsHistoryScreen,
        page: () => AssetsHistoryPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.profileScreen,
        page: () => ProfilePage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.supportScreen,
        page: () => SupportPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.suggestionScreen,
        page: () => SuggestionsPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.newSuggestionScreen,
        page: () => NewSuggestionPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.suggestionDetailsScreen,
        page: () => SuggestionDetailPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),
      GetPage(
        name: Routes.alertScreen,
        page: () => AlertsPage(),
        binding: ScreenBindings(),
        transition: Transition.zoom,
      ),

      GetPage(
        name: Routes.sparePartsTabsShellScreen,
        page: () => SparePartsTabsShell(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),

      GetPage(
        name: Routes.workOrderDetailsTabScreen,
        page: () => WorkOrderDetailsTabsShell(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),

      GetPage(
        name: Routes.startWorkOrderScreen,
        page: () => StartWorkOrderPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.reassignWorkOrderScreen,
        page: () => ReassignWorkOrderPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.startWorkSubmitScreen,
        page: () => StartWorkSubmitPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.holdWorkOrderScreen,
        page: () => HoldWorkOrderPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.diagnosticsScreen,
        page: () => DiagnosticsPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.cancelWorkOrderFromDiagnosticsScreen,
        page: () => CancelWorkOrderPageFromDiagnostic(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.closureScreen,
        page: () => ClosurePage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.signOffScreen,
        page: () => SignOffPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.returnSpareScreen,
        page: () => ReturnSparesPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.rcaAnalysisScreen,
        page: () => RcaAnalysisPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.pendingActivityScreen,
        page: () => PendingActivityPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.requestSparesScreen,
        page: () => RequestSparesPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.sparesCartScreen,
        page: () => SparesCartPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.historytScreen,
        page: () => HistoryPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.timeLineScreen,
        page: () => TimelinePage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.preventiveMaintenanceDashboardScreen,
        page: () => PreventiveMaintenanceDashboardPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: Routes.preventiveWorkOrderScreen,
        page: () => WorkOrderPage(),
        binding: ScreenBindings(),
        transition: Transition.rightToLeft,
      ),
    ];
  }
}
