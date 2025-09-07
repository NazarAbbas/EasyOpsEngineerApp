// work_order_details_page.dart
// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_ops/ui/modules/work_order_management/create_work_order/work_order_detail/controller/work_order_details_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Thumb;
import 'package:get/get.dart';

class WorkOrderDetailsPage extends GetView<WorkOrderDetailsController> {
  const WorkOrderDetailsPage({super.key});

  @override
  WorkOrderDetailsController get controller =>
      Get.put(WorkOrderDetailsController());

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double headerH = isTablet ? 120 : 110;
    final double hPad = isTablet ? 18 : 14;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: Obx(
          () => _GradientHeader(
            title: controller.title.value,
            isTablet: isTablet,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE9EEF5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Obx(() {
              final pillColor = _priorityColor(controller.priority.value);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SuccessBanner(
                    title: controller.successTitle.value,
                    sub: controller.successSub.value,
                  ),
                  const SizedBox(height: 12),

                  // Reporter
                  _KVBlock(
                    rows: [
                      _KV(
                        label: 'Reported By :',
                        value: controller.reportedBy.value.isEmpty
                            ? '—'
                            : controller.reportedBy.value,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Replace your current "Operator" KVBlock with this:
                  // Operator (left-aligned)
                  _OperatorSection(
                    name: controller.operatorName.value,
                    phone: controller.operatorPhoneNumber.value,
                    info: controller.operatorInfo.value,
                  ),

                  const _DividerPad(),

                  // Issue summary + priority pill + category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          controller.problemDescription.value.isEmpty
                              ? '—'
                              : controller.problemDescription.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _C.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 15.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Pill(
                            text: controller.priority.value.isEmpty
                                ? '—'
                                : controller.priority.value,
                            color: pillColor,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Time | Date (only render the separator if both present)
                  Row(
                    children: [
                      Text(
                        [
                          controller.time.value.isEmpty
                              ? '—'
                              : controller.time.value,
                          controller.date.value.isEmpty
                              ? '—'
                              : controller.date.value,
                        ].join(' | '),
                        style: const TextStyle(
                          color: _C.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        controller.issueType.value.isEmpty
                            ? '—'
                            : controller.issueType.value,
                        style: const TextStyle(
                          color: _C.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        size: 14,
                        color: Color(0xFFE25555),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          controller.cnc_1.value,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Line (render only if non-empty)
                  if (controller.line.value.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle_fill,
                          size: 14,
                          color: Color(0xFFE25555),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            controller.line.value,
                            style: const TextStyle(
                              color: _C.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Location
                  if (controller.location.value.isNotEmpty)
                    Text(
                      controller.location.value,
                      style: const TextStyle(
                        color: _C.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                  const _DividerPad(),

                  // Headline & Description
                  Text(
                    controller.descriptionText.value.isEmpty
                        ? '—'
                        : controller.descriptionText.value,
                    style: const TextStyle(
                      color: _C.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.problemDescription.value.isEmpty
                        ? '—'
                        : controller.problemDescription.value,
                    style: const TextStyle(color: _C.text, height: 1.35),
                  ),
                  const SizedBox(height: 12),

                  // Media row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnails
                      Expanded(
                        child: controller.photoPaths.isEmpty
                            ? const SizedBox()
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: controller.photoPaths
                                    .where((p) => p.isNotEmpty)
                                    .map((p) => _Thumb(path: p))
                                    .toList(),
                              ),
                      ),
                      const SizedBox(width: 10),
                      // Audio on the right (no Flexible)
                      _AudioTile(path: controller.voiceNotePath.value),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
        //  ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 10),
          child: SizedBox(
            height: isTablet ? 56 : 52,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: controller.goToListing,
              child: const Text(
                'Go to Work Order Listing',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ───────────────────────── Helpers ───────────────────────── */

Color _priorityColor(String s) {
  switch (s.toLowerCase()) {
    case 'high':
      return const Color(0xFFEF4444);
    case 'medium':
      return const Color(0xFFF59E0B);
    case 'low':
      return const Color(0xFF10B981);
    default:
      return const Color(0xFF9CA3AF);
  }
}

/* ───────────────────────── Widgets ───────────────────────── */

class _GradientHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isTablet;
  const _GradientHeader({required this.title, required this.isTablet});

  @override
  Size get preferredSize => Size.fromHeight(isTablet ? 120 : 110);

  @override
  Widget build(BuildContext context) {
    final btnSize = isTablet ? 48.0 : 44.0;
    final iconSize = isTablet ? 26.0 : 22.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2F6BFF), Color(0xFF3F84FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(12, isTablet ? 12 : 10, 12, 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            SizedBox(
              width: btnSize,
              height: btnSize,
              child: IconButton(
                onPressed: Get.back,
                iconSize: iconSize,
                splashRadius: btnSize / 2,
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                tooltip: 'Back',
              ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: isTablet ? 20 : 18,
                ),
              ),
            ),
            SizedBox(width: btnSize, height: btnSize),
          ],
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String title;
  final String sub;
  const _SuccessBanner({required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E8A3B), Color(0xFF0A6A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFBFEBCB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.black87, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KV {
  final String label;
  final String value;
  const _KV({required this.label, required this.value});
}

class _KVBlock extends StatelessWidget {
  final List<_KV> rows;
  const _KVBlock({required this.rows});

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: _C.muted, fontWeight: FontWeight.w800);
    const valueStyle = TextStyle(color: _C.text, fontWeight: FontWeight.w800);

    return Column(
      children: rows
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.label.isNotEmpty) ...[
                    Text(e.label, style: labelStyle),
                    const SizedBox(width: 6),
                  ],
                  Expanded(child: Text(e.value, style: valueStyle)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DividerPad extends StatelessWidget {
  const _DividerPad();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(color: _C.line, height: 1),
  );
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String path;
  const _Thumb({required this.path});
  @override
  Widget build(BuildContext context) {
    final file = File(path);
    if (!file.existsSync()) {
      // Skip invalid paths quietly
      return const SizedBox(width: 0, height: 0);
    }
    return Container(
      width: 88,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
      ),
    );
  }
}

class _AudioTile extends StatefulWidget {
  final String path;
  const _AudioTile({required this.path});

  @override
  State<_AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<_AudioTile> {
  late final AudioPlayer _player;
  bool _isPlaying = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    // Keep duration/position in sync with the actual audio
    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      // Clamp to duration to avoid weird overflows from some backends
      if (_duration != Duration.zero && p > _duration) p = _duration;
      setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _position = _duration;
      });
    });

    // Preload so total time is known before first play
    _preloadDuration();
  }

  Future<void> _preloadDuration() async {
    if (widget.path.isEmpty || !File(widget.path).existsSync()) return;
    try {
      await _player.setSource(DeviceFileSource(widget.path));
      final d = await _player.getDuration();
      if (mounted && d != null) setState(() => _duration = d);
    } catch (_) {
      // ignore preload errors
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (widget.path.isEmpty || !File(widget.path).existsSync()) return;

    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      // Resume if paused mid-way, otherwise start from the beginning
      if (_position > Duration.zero && _position < _duration) {
        await _player.resume();
      } else {
        await _player.stop();
        await _player.play(DeviceFileSource(widget.path));
      }
      setState(() => _isPlaying = true);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path.isEmpty || !File(widget.path).existsSync()) {
      return const SizedBox(); // nothing to play
    }

    const blue = _C.primary;
    final totalText = _duration == Duration.zero ? '--:--' : _fmt(_duration);
    final pos = (_duration != Duration.zero && _position > _duration)
        ? _duration
        : _position;
    final posText = _fmt(pos);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64, minWidth: 88),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        // Use a Row (not Stack) + Flexible text to avoid overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _toggle,
              icon: Icon(
                _isPlaying
                    ? CupertinoIcons.pause_fill
                    : CupertinoIcons.play_fill,
                color: blue,
                size: 28,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '$posText / $totalText',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- tiny helpers ---------- */

class _OperatorSection extends StatelessWidget {
  final String name;
  final String phone;
  final String info;
  const _OperatorSection({
    required this.name,
    required this.phone,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: _C.muted, fontWeight: FontWeight.w800);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // ← hard left
      children: [
        const Text('Operator', style: labelStyle),
        const SizedBox(height: 6),

        // Name (full width, left aligned)
        _LineWithIcon(
          icon: CupertinoIcons.person,
          text: name.isEmpty ? '—' : name,
        ),
        const SizedBox(height: 4),

        // Phone (full width, left aligned)
        _LineWithIcon(
          icon: CupertinoIcons.phone,
          text: phone.isEmpty ? '—' : phone,
        ),
        const SizedBox(height: 4),

        // Info (full width, left aligned)
        _LineWithIcon(
          icon: CupertinoIcons.location,
          text: info.isEmpty ? '—' : info,
        ),
      ],
    );
  }
}

class _LineWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const _LineWithIcon({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    const valueStyle = TextStyle(color: _C.text, fontWeight: FontWeight.w800);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _C.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

/* ───────────────────────── Style ───────────────────────── */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
}
