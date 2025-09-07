import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:easy_ops/route_managment/routes.dart';
import 'package:easy_ops/ui/modules/work_order_management/create_work_order/work_order_info/ui/work_order_info_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WorkorderInfoController extends GetxController {
  // ─────────────────────────────────────────────────────────────────────────
  // Operator footer (the three values you want to save & restore)
  // Use updateOperatorFooter(...) to change & persist them from anywhere.
  // ─────────────────────────────────────────────────────────────────────────
  final operatorName = 'Ajay Kumar (MP18292)'.obs;
  final operatorMobileNumber = '9876543211'.obs;
  final operatorInfo = 'Assets Shop | 12:20 | 03 Sept | A'.obs;

  // ───────── Media
  final photos = <String>[].obs; // file paths
  final voiceNotePath = ''.obs; // recorded audio file path
  final isRecording = false.obs; // UI state flag (not persisted)

  // ───────── Draft storage (work-order draft + a small operator-only blob)
  static const _draftKey = 'work_order_info_draft_v1';
  static const _operatorKey = 'operator_footer_v1';
  final _box = GetStorage();

  // ───────── Dropdown values
  final issueType = ''.obs; // e.g., Electrical / Mechanical / Instrumentation
  final impact = ''.obs; // e.g., Low / Medium / High

  // ───────── Inputs
  final assetsCtrl = TextEditingController();
  final problemCtrl = TextEditingController();

  // ───────── Derived tiles (read-only on UI)
  final typeText = 'Critical for testing'.obs;
  final descriptionText =
      'CNC Vertical Assets Center where we make housing for testing'.obs;

  // ───────── Sample dropdown options
  final issueTypes = const ['Electrical', 'Mechanical', 'Instrumentation'];
  final impacts = const ['Low', 'Medium', 'High'];

  // Keep a reference to the listener so we can remove it correctly onClose
  late final VoidCallback _assetListener;

  // ───────── Lifecycle
  @override
  void onInit() {
    super.onInit();
    _loadDraft(); // load work-order draft (also tries operator fields)
    // _loadOperatorFooter(); // specifically load operator footer if stored separately

    // Auto-bind type & description whenever asset number changes
    _assetListener = () => applyAssetMetaFor(assetsCtrl.text);
    assetsCtrl.addListener(_assetListener);
  }

  @override
  void onClose() {
    assetsCtrl
      ..removeListener(_assetListener)
      ..dispose();
    problemCtrl.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PERSISTENCE: what we save in the work-order draft (includes operator too)
  // ─────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> _operatorPayload() => {
    'operatorName': operatorName.value,
    'operatorMobileNumber': operatorMobileNumber.value,
    'operatorInfo': operatorInfo.value,
  };

  Map<String, dynamic> payload() => {
    // form fields
    'issueType': issueType.value,
    'impact': impact.value,
    'assetsNumber': assetsCtrl.text.trim(),
    'problemDescription': problemCtrl.text.trim(),
    'typeText': typeText.value,
    'descriptionText': descriptionText.value,
    // media
    'photos': photos.toList(),
    'voiceNotePath': voiceNotePath.value,
    // operator footer (so details page also receives them via arguments)
    ..._operatorPayload(),
  };

  /// Save the entire draft (form fields + media + operator footer).
  void saveDraft() => _box.write(_draftKey, payload());

  /// ONLY save the operator footer to its small, dedicated blob.
  /// Useful when you change operator fields from another screen.
  void saveOperatorFooter() => _box.write(_operatorKey, _operatorPayload());

  /// Load everything from the big draft (if present).
  /// Also reads operator footer from the draft if it exists there.
  void _loadDraft() {
    final data = _box.read(_draftKey);
    if (data is! Map) return;

    final json = Map<String, dynamic>.from(data);

    // form fields
    issueType.value = (json['issueType'] ?? '') as String;
    impact.value = (json['impact'] ?? '') as String;

    assetsCtrl.text = (json['assetsNumber'] ?? '') as String;
    problemCtrl.text = (json['problemDescription'] ?? '') as String;

    typeText.value = (json['typeText'] ?? '-') as String;
    descriptionText.value = (json['descriptionText'] ?? '-') as String;

    final ph = json['photos'];
    if (ph is List) photos.assignAll(ph.map((e) => e.toString()));

    voiceNotePath.value = (json['voiceNotePath'] ?? '') as String;

    // operator footer (if present in the same draft)
    operatorName.value = (json['operatorName'] ?? operatorName.value) as String;
    operatorMobileNumber.value =
        (json['operatorMobileNumber'] ?? operatorMobileNumber.value) as String;
    operatorInfo.value = (json['operatorInfo'] ?? operatorInfo.value) as String;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API for operator footer (update + persist)
  // Call from UI or another controller when user changes operator details.
  // ─────────────────────────────────────────────────────────────────────────
  void updateOperatorFooter({
    String? name,
    String? mobile,
    String? info,
    bool persistDraft = true, // also keep the big draft in sync
    bool persistOperatorOnly = true, // and/or the small operator blob
  }) {
    if (name != null) operatorName.value = name;
    if (mobile != null) operatorMobileNumber.value = mobile;
    if (info != null) operatorInfo.value = info;

    if (persistOperatorOnly) saveOperatorFooter();
    if (persistDraft) saveDraft();
  }

  // ───────── Helpers (call these from the page UI)
  void setAssetMeta({required String type, required String description}) {
    typeText.value = type;
    descriptionText.value = description;
    saveDraft();
  }

  void applyAssetMetaFor(String input) {
    final hit = AssetsCatalog.find(input); // trims & uppercases inside
    if (hit != null) {
      setAssetMeta(type: hit.type, description: hit.description);
    }
    // If not found, keep current values (no auto-clear).
  }

  // Expose asset numbers to the page for pickers/autocomplete
  List<String> get assetNumbers =>
      AssetsCatalog.items.map((e) => e.number).toList();

  // ───────── Media mutations
  void addPhoto(String path) {
    photos.add(path);
    saveDraft();
  }

  void addPhotos(Iterable<String> paths) {
    photos.addAll(paths);
    saveDraft();
  }

  void removePhotoAt(int index) {
    if (index < 0 || index >= photos.length) return;
    photos.removeAt(index);
    saveDraft();
  }

  void clearPhotos() {
    photos.clear();
    saveDraft();
  }

  void setVoiceNote(String path) {
    voiceNotePath.value = path;
    saveDraft();
  }

  void clearVoiceNote() {
    voiceNotePath.value = '';
    saveDraft();
  }

  // ───────── Submit / Navigate
  void goToWorkOrderDetailScreen() {
    final missing = <String>[];
    if (issueType.value.isEmpty) missing.add('Issue Type');
    if (impact.value.isEmpty) missing.add('Impact');
    if (assetsCtrl.text.trim().isEmpty) missing.add('Assets Number');
    if (problemCtrl.text.trim().isEmpty) missing.add('Problem Description');

    if (missing.isNotEmpty) {
      Get.snackbar(
        'Missing Info',
        'Please fill: ${missing.join(', ')}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: AppColors.white,
      );
      return;
    }

    // Persist both stores before leaving
    saveOperatorFooter();
    saveDraft();

    Get.snackbar(
      'Create',
      'Work order saved',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryBlue,
      colorText: AppColors.white,
    );

    // Pass everything forward (includes operator footer + media)
    Get.toNamed(Routes.workOrderDetailScreen, arguments: payload());
  }

  // ───────── Shared picker wrapper (already used by your page)
  Future<void> openAssetPicker(BuildContext context) async {
    await pickFromList(
      context: context,
      title: 'Select Asset Number',
      items: AssetsCatalog.items.map((e) => e.number).toList(),
      onSelected: (selectedNumber) {
        assetsCtrl.text = selectedNumber; // fill the field
        applyAssetMetaFor(selectedNumber); // bind type + description
      },
    );
  }
}

/* ───────────────────────── Asset catalog (sample) ───────────────────────── */

class Asset {
  final String number;
  final String type;
  final String description;
  const Asset(this.number, this.type, this.description);
}

class AssetsCatalog {
  // In-memory catalog (sample data — replace with real values)
  static const List<Asset> items = [
    Asset(
      '1001',
      'High',
      'High - CNC Vertical Assets Center where we make housing',
    ),
    Asset(
      '1002',
      'Critical',
      'Critical - CNC Vertical Assets Center where we make housing',
    ),
    Asset(
      '1003',
      'Medium',
      'Medium - CNC Vertical Assets Center where we make housing',
    ),
    Asset(
      '1004',
      'Low',
      'Low CNC Vertical Assets Center where we make housing',
    ),
  ];

  // Quick index for lookups by number (case-insensitive)
  static final Map<String, Asset> index = {
    for (final a in items) a.number.toUpperCase(): a,
  };

  static Asset? find(String number) => index[number.trim().toUpperCase()];
}
