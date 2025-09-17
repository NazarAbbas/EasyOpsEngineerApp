// accept_work_order_page.dart
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_ops/features/maintenance_work_order/accept_work_order/controller/accept_work_order_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Thumb;
import 'package:flutter/services.dart'; // for rootBundle (asset existence)
import 'package:get/get.dart';

/* ───────────────────────── Page ───────────────────────── */

class AcceptWorkOrderPage extends GetView<AcceptWorkOrderController> {
  const AcceptWorkOrderPage({super.key});

  @override
  AcceptWorkOrderController get controller =>
      Get.put(AcceptWorkOrderController());

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final double hPad = isTablet ? 18 : 14;
    final double btnH = isTablet ? 56 : 52;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      // Bottom actions
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(btnH),
                    side: BorderSide(color: primary, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: primary,
                  ),
                  onPressed: controller.reAssignWorkOrder,
                  child: const Text(
                    'Reassign',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(btnH),
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.5,
                  ),
                  onPressed: controller.acceptWorkOrder,
                  child: const Text(
                    'Accept',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
        child: Column(
          children: [
            // Main details card (your original content minus media row)
            Container(
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

                      // Operator section
                      _OperatorSection(
                        name: controller.operatorName.value,
                        phone: controller.operatorPhoneNumber.value,
                        info: controller.operatorInfo.value,
                      ),

                      const _DividerPad(),

                      // Issue summary + priority pill
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
                          _Pill(
                            text: controller.priority.value.isEmpty
                                ? '—'
                                : controller.priority.value,
                            color: pillColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Time | Date | Status
                      Row(
                        children: [
                          Text(
                            [
                              controller.orderId.value.isEmpty
                                  ? '—'
                                  : controller.orderId.value,
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
                            controller.status.value.isEmpty
                                ? '—'
                                : controller.status.value,
                            style: const TextStyle(
                              color: _C.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Issue type + line
                      Text(
                        controller.issueType.value,
                        style: const TextStyle(
                          color: _C.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
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
                    ],
                  );
                }),
              ),
            ),

            // Media card (images + audio stacked)
            const _MediaCard(),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── Media Card ───────────────────────── */

class _MediaCard extends StatelessWidget {
  const _MediaCard();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AcceptWorkOrderController>();

    return Obx(() {
      final photos = c.photoPaths.where((p) => p.isNotEmpty).toList();
      final voice = c.voiceNotePath.value;

      if (photos.isEmpty && voice.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 12),
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
          child: LayoutBuilder(
            builder: (context, box) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Media',
                    style: TextStyle(
                      color: _C.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (photos.isNotEmpty)
                    SizedBox(
                      width: box.maxWidth,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: photos.map((p) => _Thumb(path: p)).toList(),
                      ),
                    ),

                  if (voice.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _AudioBubble(
                      path: voice,
                      width: box.maxWidth, // stretch to card width
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      );
    });
  }
}

/* ───────────────────────── Operator Section ───────────────────────── */

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Operator', style: labelStyle),
        const SizedBox(height: 6),
        _LineWithIcon(
          icon: CupertinoIcons.person,
          text: name.isEmpty ? '—' : name,
        ),
        const SizedBox(height: 4),
        _LineWithIcon(
          icon: CupertinoIcons.phone,
          text: phone.isEmpty ? '—' : phone,
        ),
        const SizedBox(height: 4),
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

/* ───────────────────────── Media helpers ───────────────────────── */

bool _isAsset(String p) => p.startsWith('assets/');
bool _isUrl(String p) => p.startsWith('http://') || p.startsWith('https://');
bool _isFilePath(String p) =>
    p.startsWith('/') || p.contains(RegExp(r'^[A-Za-z]:[\\/].+'));
String _assetKey(String assetPath) =>
    assetPath.startsWith('assets/') ? assetPath.substring(7) : assetPath;

class _Thumb extends StatelessWidget {
  final String path;
  const _Thumb({required this.path});

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return const SizedBox.shrink();

    final base = Container(
      width: 88,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Icon(
        CupertinoIcons.photo_on_rectangle,
        size: 18,
        color: _C.muted,
      ),
    );

    if (_isAsset(path)) {
      return FutureBuilder<bool>(
        future: _assetExists(path),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done || snap.data != true)
            return base;
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(path, width: 88, height: 64, fit: BoxFit.cover),
          );
        },
      );
    }

    if (_isUrl(path)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          path,
          width: 88,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => base,
        ),
      );
    }

    if (_isFilePath(path)) {
      final f = File(path);
      if (!f.existsSync()) return base;
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(f, width: 88, height: 64, fit: BoxFit.cover),
      );
    }

    return base;
  }
}

/* ───────────────────────── Audio bubble (with slider) ───────────────────────── */

class _AudioBubble extends StatefulWidget {
  final String path; // asset / file / url
  final double? width; // full width if null
  const _AudioBubble({required this.path, this.width, super.key});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Source? _currentSource;

  Source? _buildSource(String p) {
    if (p.isEmpty) return null;
    if (_isAsset(p)) return AssetSource(_assetKey(p));
    if (_isUrl(p)) return UrlSource(p);
    if (_isFilePath(p)) return DeviceFileSource(p);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

    // register with controller so it can stop us on navigation
    Get.find<AcceptWorkOrderController>().registerPlayer(_player);

    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
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

    _preload();
  }

  @override
  void dispose() {
    // best-effort stop; don't await in dispose
    _player.stop();
    // unregister from controller
    Get.find<AcceptWorkOrderController>().unregisterPlayer(_player);
    _player.dispose();
    super.dispose();
  }

  Future<void> _preload() async {
    final src = _buildSource(widget.path);
    if (src == null) return;
    try {
      await _player.setSource(src);
      final d = await _player.getDuration();
      if (mounted && d != null) setState(() => _duration = d);
      _currentSource = src;
    } catch (_) {
      // silently ignore; user can still try play (we retry there)
    }
  }

  // @override
  // void dispose() {
  //   _player.dispose();
  //   super.dispose();
  // }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      if (_isPlaying) {
        await _player.pause();
        setState(() => _isPlaying = false);
      } else {
        final src = _currentSource ?? _buildSource(widget.path);
        if (src == null) return;
        if (_position == Duration.zero) {
          await _player.stop();
          await _player.play(src);
        } else {
          await _player.resume();
        }
        setState(() => _isPlaying = true);
      }
    } catch (_) {
      try {
        final src = _buildSource(widget.path);
        if (src != null) {
          await _player.stop();
          await _player.play(src);
          setState(() => _isPlaying = true);
        }
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seek(double v) async {
    if (_duration == Duration.zero) return;
    final target = Duration(
      milliseconds: (v * _duration.inMilliseconds).round(),
    );
    await _player.seek(target);
    setState(() => _position = target);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path.isEmpty) return const SizedBox.shrink();

    final total = _duration == Duration.zero ? '00:20' : _fmt(_duration);
    final pos = _position > _duration ? _duration : _position;
    final progress = (_duration == Duration.zero)
        ? 0.0
        : pos.inMilliseconds / _duration.inMilliseconds;

    return SizedBox(
      width: widget.width ?? double.infinity,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Controls row
            Row(
              children: [
                _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: _toggle,
                        icon: Icon(
                          _isPlaying
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill,
                          color: _C.primary,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                      ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _duration == Duration.zero
                        ? total
                        : '${_fmt(pos)} / $total',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _C.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            // Slim slider
            SliderTheme(
              data: const SliderThemeData(
                trackHeight: 2,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: _seek,
                activeColor: _C.primary,
                inactiveColor: const Color(0xFFD7E2FF),
              ),
            ),
          ],
        ),
      ),
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
