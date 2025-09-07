import 'dart:io';
import 'package:easy_ops/constants/values/app_colors.dart';
import 'package:easy_ops/ui/modules/work_order_management/create_work_order/work_order_info/controller/work_order_info_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';

class WorkOrderInfoPage extends GetView<WorkorderInfoController> {
  WorkOrderInfoPage({super.key});
  @override
  WorkorderInfoController get controller => Get.put(WorkorderInfoController());

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  // Ephemeral helpers (UI layer only)
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _rec = AudioRecorder(); // record v6+
  final AudioPlayer _player = AudioPlayer(); // playback
  final RxBool _isPlaying = false.obs; // local playback state

  /* -------------------- Photos -------------------- */

  Future<void> _pickFromCamera(WorkorderInfoController c) async {
    final XFile? f = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (f != null) c.addPhoto(f.path);
  }

  Future<void> _pickFromGallery(WorkorderInfoController c) async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isNotEmpty) c.addPhotos(files.map((e) => e.path));
  }

  Future<void> _showPhotoPickerSheet(
    BuildContext context,
    WorkorderInfoController c,
  ) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(CupertinoIcons.camera),
              title: const Text('Camera'),
              onTap: () async {
                Get.back();
                await _pickFromCamera(c);
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.photo_on_rectangle),
              title: const Text('Gallery'),
              onTap: () async {
                Get.back();
                await _pickFromGallery(c);
              },
            ),
            if (c.photos.isNotEmpty)
              ListTile(
                leading: const Icon(CupertinoIcons.trash),
                title: const Text('Clear Photos'),
                onTap: () {
                  c.clearPhotos();
                  Get.back();
                },
              ),
          ],
        ),
      ),
    );
  }

  /* -------------------- Voice record + play -------------------- */

  Future<void> _toggleRecording(WorkorderInfoController c) async {
    // Stop playback if playing
    if (_isPlaying.value) {
      await _player.stop();
      _isPlaying.value = false;
    }

    if (!c.isRecording.value) {
      if (!await _rec.hasPermission()) {
        Get.snackbar(
          'Permission',
          'Microphone access denied',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final path = p.join(
        dir.path,
        'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );

      await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      c.isRecording.value = true;
    } else {
      final saved = await _rec.stop(); // -> path (or null)
      c.isRecording.value = false;
      if (saved != null) {
        c.setVoiceNote(saved);
        Get.snackbar(
          'Voice note',
          'Recording has been saved successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryBlue,
          colorText: Colors.white,
        );
      }
    }
  }

  // NEW: stop button logic (stops & saves if recording)
  Future<void> _stopAndSaveRecording(WorkorderInfoController c) async {
    if (!c.isRecording.value) {
      Get.snackbar(
        'Recorder',
        'No active recording',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
      return;
    }
    final saved = await _rec.stop();
    c.isRecording.value = false;
    if (saved != null) {
      c.setVoiceNote(saved);
      Get.snackbar(
        'Voice note',
        'Recording has been saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryBlue,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _playOrPauseVoice(WorkorderInfoController c) async {
    final path = c.voiceNotePath.value;
    if (path.isEmpty) return;

    if (_isPlaying.value) {
      await _player.pause();
      _isPlaying.value = false;
    } else {
      await _player.stop(); // ensure fresh start
      await _player.play(DeviceFileSource(path));
      _isPlaying.value = true;

      _player.onPlayerComplete.listen((_) {
        _isPlaying.value = false;
      });
    }
  }

  Future<void> _removeVoice(WorkorderInfoController c) async {
    if (_isPlaying.value) {
      await _player.stop();
      _isPlaying.value = false;
    }
    c.clearVoiceNote();
    Get.snackbar(
      'Voice note',
      'Removed, and a new recording has started.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  Future<void> _removedRecording(WorkorderInfoController c) async {
    if (_isPlaying.value) {
      await _player.stop();
      _isPlaying.value = false;
    }
    c.clearVoiceNote();
    Get.snackbar(
      'Voice note',
      'Recording has been removed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }

  Future<void> _reRecord(WorkorderInfoController c) async {
    await _removeVoice(c);
    await _toggleRecording(c);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double hPad = isTablet ? 20 : 14;
    final double cardRadius = isTablet ? 16 : 12;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Work Order card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFFFFF), Color(0xFFF7FAFF)],
                  ),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: const Color(0xFFE9EEF6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _CardTitle('Work Order Info'),
                      const SizedBox(height: 12),

                      // Issue Type | Impact
                      _Row2(
                        left: _Label(
                          'Issue Type',
                          _TapField(
                            textRx: controller.issueType,
                            placeholder: 'Select',
                            onTap: () => pickFromList(
                              context: context,
                              title: 'Select Issue Type',
                              items: controller.issueTypes,
                              onSelected: (v) {
                                controller.issueType.value = v;
                                controller.saveDraft();
                              },
                            ),
                          ),
                        ),
                        right: _Label(
                          'Impact',
                          _TapField(
                            textRx: controller.impact,
                            placeholder: 'Select',
                            onTap: () => pickFromList(
                              context: context,
                              title: 'Select Impact',
                              items: controller.impacts,
                              onSelected: (v) {
                                controller.impact.value = v;
                                controller.saveDraft();
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const _Hr(),

                      // Assets Number | Type + clock square
                      // const double _fieldH = 48;
                      _Row2(
                        left: _Label(
                          'Assets Number',
                          SizedBox(
                            height: 48,
                            child: TextField(
                              controller: controller.assetsCtrl,
                              onChanged: (txt) {
                                controller.saveDraft();
                                controller.applyAssetMetaFor(
                                  txt,
                                ); // auto bind type + description
                              },
                              decoration: _D.field(
                                hint: 'Search / type number',
                                prefix: const Padding(
                                  padding: EdgeInsets.only(left: 12, right: 6),
                                  child: Icon(
                                    CupertinoIcons.number,
                                    size: 18,
                                    color: _C.muted,
                                  ),
                                ),
                                suffix: GestureDetector(
                                  onTap: () =>
                                      controller.openAssetPicker(context),
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      CupertinoIcons.search,
                                      color: _C.muted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        right: _Label(
                          'Type',
                          SizedBox(
                            height: 48,
                            child: Obx(
                              () => _ValueTile(controller.typeText.value),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      const _Hr(),

                      // Description (read-only tile)
                      _Label(
                        'Description',
                        Obx(() => _ValueTile(controller.descriptionText.value)),
                      ),

                      const SizedBox(height: 20),

                      // Problem Description
                      _Label(
                        'Problem Description',
                        TextField(
                          controller: controller.problemCtrl,
                          onChanged: (_) => controller.saveDraft(),
                          minLines: 5,
                          maxLines: 8,
                          decoration: _D.field(hint: 'Write here'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Upload photos + mic + stop buttons
                      Row(
                        children: [
                          Expanded(
                            child: _UploadPhotosBox(
                              onTap: () =>
                                  _showPhotoPickerSheet(context, controller),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Stack mic + stop
                          Column(
                            children: [
                              Obx(
                                () => _IconSquare(
                                  tooltip: controller.isRecording.value
                                      ? 'Stop recording'
                                      : 'Record voice note',
                                  onTap: () => _toggleRecording(controller),
                                  child: Icon(
                                    controller.isRecording.value
                                        ? CupertinoIcons.mic_fill
                                        : CupertinoIcons.mic,
                                    color: controller.isRecording.value
                                        ? Colors.red
                                        : _C.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Obx(
                                () => _IconSquare(
                                  tooltip: 'Stop & save',
                                  onTap: () =>
                                      _stopAndSaveRecording(controller),
                                  child: Icon(
                                    CupertinoIcons.stop_circle,
                                    color: controller.isRecording.value
                                        ? _C.primary
                                        : _C.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Photo previews
                      Obx(() {
                        if (controller.photos.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(
                                controller.photos.length,
                                (i) {
                                  final path = controller.photos[i];
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(path),
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        right: -8,
                                        top: -8,
                                        child: GestureDetector(
                                          onTap: () =>
                                              controller.removePhotoAt(i),
                                          child: const CircleAvatar(
                                            radius: 10,
                                            backgroundColor: Colors.black54,
                                            child: Icon(
                                              Icons.close,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }),

                      // Voice note controls
                      Obx(() {
                        final path = controller.voiceNotePath.value;
                        final playing = _isPlaying.value;
                        if (path.isEmpty) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9F5FF),
                              border: Border.all(
                                color: const Color(0xFFD6EAFB),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.waveform_circle,
                                  size: 16,
                                  color: _C.primary,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Voice note saved',
                                  style: TextStyle(
                                    color: _C.text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Play / Pause
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  iconSize: 20,
                                  splashRadius: 18,
                                  onPressed: () =>
                                      _playOrPauseVoice(controller),
                                  icon: Icon(
                                    playing
                                        ? CupertinoIcons.pause_circle
                                        : CupertinoIcons.play_circle,
                                    color: _C.primary,
                                  ),
                                ),

                                // Delete
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  iconSize: 20,
                                  splashRadius: 18,
                                  onPressed: () =>
                                      _removedRecording(controller),
                                  icon: const Icon(
                                    CupertinoIcons.trash,
                                    color: Colors.redAccent,
                                  ),
                                ),

                                // Re-record
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  iconSize: 20,
                                  splashRadius: 18,
                                  onPressed: () => _reRecord(controller),
                                  icon: const Icon(
                                    CupertinoIcons.mic_circle,
                                    color: _C.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Operator Info footer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: const Color(0xFFE9EEF6)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _OperatorInfoFooter()),
                    const SizedBox(width: 10),
                    _IconSquare(
                      tooltip: 'Edit',
                      onTap: () {},
                      child: const Icon(
                        CupertinoIcons.pencil,
                        color: _C.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // Bottom CTA
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 10),
          child: SizedBox(
            height: isTablet ? 56 : 52,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1.5,
              ),
              onPressed: () => controller.goToWorkOrderDetailScreen(),
              child: const Text(
                'Create',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ─────────────── pieces ─────────────── */

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _C.text,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            color: _C.primary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _OperatorInfoFooter extends GetView<WorkorderInfoController> {
  const _OperatorInfoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = controller.operatorName.value.trim();
      final mobile = controller.operatorMobileNumber.value.trim();
      final info = controller.operatorInfo.value.trim();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operator Info',
            style: TextStyle(
              color: Color(0xFF5B667A),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name.isEmpty ? '—' : name,
            style: const TextStyle(color: _C.text, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            mobile.isEmpty ? '—' : mobile,
            style: const TextStyle(color: _C.text, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            info.isEmpty ? '—' : info,
            style: const TextStyle(color: _C.text, fontWeight: FontWeight.w700),
          ),
        ],
      );
    });
  }
}

class _Label extends StatelessWidget {
  final String title;
  final Widget child;
  const _Label(this.title, this.child);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _C.text,
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _TapField extends StatelessWidget {
  final RxString textRx;
  final String placeholder;
  final VoidCallback onTap;
  const _TapField({
    required this.textRx,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEmpty = textRx.value.isEmpty;
      final text = isEmpty ? placeholder : textRx.value;
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: InputDecorator(
          decoration: _D.field(
            suffix: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(CupertinoIcons.chevron_down, color: _C.muted),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isEmpty ? _C.muted : _C.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }
}

class _ValueTile extends StatelessWidget {
  final String value;
  const _ValueTile(this.value);
  @override
  Widget build(BuildContext context) {
    return Text(value, style: const TextStyle(color: _C.text));
  }
}

class _UploadPhotosBox extends StatelessWidget {
  final VoidCallback onTap;
  const _UploadPhotosBox({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFE1E6EF), width: 1.4),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.upload_circle, color: _C.primary),
                SizedBox(width: 8),
                Text(
                  'Upload photos',
                  style: TextStyle(
                    color: _C.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              'Format : jpeg, jpg, png',
              style: TextStyle(color: _C.muted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconSquare extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? tooltip;
  const _IconSquare({required this.child, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: const Color(0xFFEFF3FF),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Color(0xFFE1E6EF), width: 1.4),
          ),
          child: Center(child: child),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

class _Hr extends StatelessWidget {
  const _Hr();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 6),
    child: Divider(color: _C.line, height: 1),
  );
}

class _Row2 extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Row2({required this.left, required this.right});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(fit: FlexFit.tight, child: left),
        const SizedBox(width: 12),
        Flexible(fit: FlexFit.tight, child: right),
      ],
    );
  }
}

/* ─────────────── style helpers ─────────────── */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF8A94A6);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
}

class _D {
  static InputDecoration field({String? hint, Widget? prefix, Widget? suffix}) {
    return const InputDecoration(
      isDense: true,
      hintText: null,
      hintStyle: TextStyle(color: _C.muted, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      prefixIcon: null,
      suffixIcon: null,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE1E6EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE1E6EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE1E6EF)),
      ),
    ).copyWith(hintText: hint, prefixIcon: prefix, suffixIcon: suffix);
  }
}

/* -------------------- Picker Sheet -------------------- */
Future<void> pickFromList({
  required BuildContext context,
  required String title,
  required List<String> items,
  required ValueChanged<String> onSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final maxH = MediaQuery.of(ctx).size.height * 0.60;
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFE9EEF6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(CupertinoIcons.xmark, size: 18),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.line),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF2F5FA)),
                  itemBuilder: (_, i) => ListTile(
                    dense: true,
                    title: Text(
                      items[i],
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      onSelected(items[i]);
                      Get.back();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
