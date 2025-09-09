import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/diagnostics/controller/diagnostics_controller.dart';
import 'package:easy_ops/utils/loading_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DiagnosticsPage extends GetView<DiagnosticsController> {
  const DiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3C4354),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text('Diagnostics'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.wo.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.load,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WorkOrderContent(controller.wo.value!),
                    const SizedBox(height: 12),
                    _MediaSection(controller: controller),
                    const SizedBox(height: 12),
                    const _SparesSection(), // 👈 NEW: Spares card
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
      }),
      bottomNavigationBar: _BottomActions(
        onEnd: () => {
          controller.isLoading.value = true,
          const LoadingOverlay(message: 'Please wait...'),
          controller.endWork(),
          controller.isLoading.value = false,
        },

        onHold: controller.hold,
        onReassign: controller.reassign,
        onCancel: controller.cancel,
      ),
    );
  }
}

/* --------------------------- Content Body --------------------------- */

class _WorkOrderContent extends StatelessWidget {
  final WorkOrder w;
  const _WorkOrderContent(this.w);

  String _fmtDur(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}Hrs';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      w.title,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                  ),
                  _Chip(text: w.priority, color: const Color(0xFFED3B40)),
                ],
              ),
              const SizedBox(height: 8),
              // Code + date + status
              Row(
                children: [
                  Text(
                    '${w.code}   '
                    '${w.createdAt.hour.toString().padLeft(2, '0')}:'
                    '${w.createdAt.minute.toString().padLeft(2, '0')}  |  '
                    '${w.createdAt.day.toString().padLeft(2, '0')} '
                    '${_month(w.createdAt.month)}',
                    style: const TextStyle(color: Color(0xFF7C8698)),
                  ),
                  const Spacer(),
                  Text(
                    w.status,
                    style: const TextStyle(
                      color: Color(0xFF2F6BFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Tag(w.category),
                  const SizedBox(width: 8),
                  const Icon(Icons.link, size: 18, color: Color(0xFF2F6BFF)),
                  const Spacer(),
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: Color(0xFF7C8698),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${w.elapsed.inHours}h ${w.elapsed.inMinutes.remainder(60)}m',
                    style: const TextStyle(color: Color(0xFF7C8698)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        _Card(
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Estimated Time Given',
                  style: TextStyle(color: Color(0xFF7C8698)),
                ),
              ),
              Text(
                _fmtDur(w.estimated),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2430),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        _Accordion(
          title: 'Operator Info',
          initiallyOpen: true,
          content: Column(
            children: [
              _InfoRow('Reported By', w.reportedBy.name, call: true),
              const SizedBox(height: 8),
              _InfoRow('Maintenance\nManager', w.manager.name, call: true),
            ],
          ),
        ),

        const SizedBox(height: 12),
        _Accordion(
          title: 'Work Order Info',
          initiallyOpen: false,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _InfoRow(
                'Attachment',
                'Tap to view / add',
                trailingIcon: Icons.refresh,
              ),
              SizedBox(height: 12),
              Divider(height: 1),
              SizedBox(height: 12),
              Text(
                'Spindle speed issues in XYZ – check belt alignment and tension.',
                style: TextStyle(color: Color(0xFF1F2430)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _month(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[m - 1];
  }
}

/* ------------------------------ Media ------------------------------ */

class _MediaSection extends StatelessWidget {
  final DiagnosticsController controller;
  const _MediaSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final photos = controller.photoPaths.where((p) => p.isNotEmpty).toList();
      final voice = controller.voiceNotePath.value;
      if (photos.isEmpty && voice.isEmpty) return const SizedBox.shrink();

      return _Card(
        child: LayoutBuilder(
          builder: (context, c) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Media',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: c.maxWidth,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: 10,
                    runSpacing: 10,
                    children: photos.map((p) => _Thumb(path: p)).toList(),
                  ),
                ),

                if (voice.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _AudioBubble(path: voice, width: c.maxWidth),
                ],
              ],
            );
          },
        ),
      );
    });
  }
}

/* ------------------------------ Spares (NEW) ------------------------------ */

class _SparesSection extends StatefulWidget {
  const _SparesSection();

  @override
  State<_SparesSection> createState() => _SparesSectionState();
}

class _SparesSectionState extends State<_SparesSection> {
  bool open = true;

  // Demo data; replace with your real spares
  final List<_SpareGroup> groups = const [
    _SpareGroup(
      cat1: 'Hydraulics',
      cat2: 'Pump',
      items: [
        _SpareItem('SM-1001', 4),
        _SpareItem('BS-2002', 3),
        _SpareItem('LGR-3003', 2),
        _SpareItem('TH-4004', 1),
      ],
    ),
    _SpareGroup(
      cat1: 'Conveyor',
      cat2: 'Belt',
      items: [
        _SpareItem('CT-5005', 1),
        _SpareItem('CV-6106', 2),
        _SpareItem('CV-7107', 1),
      ],
    ),
  ];

  int get totalQty =>
      groups.fold(0, (sum, g) => sum + g.items.fold(0, (s, i) => s + i.qty));

  String _qtyTxt(int n) => '${n.toString().padLeft(2, '0')} nos';

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          // Header row: "Spares" + chevron + tool/edit badge
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Spares',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2430),
                  ),
                ),
              ),
              // tools/edit pill
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.wrench_fill,
                      color: _C.primary,
                      size: 18,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.pencil_ellipsis_rectangle,
                        size: 12,
                        color: _C.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => setState(() => open = !open),
                icon: Icon(
                  open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF7C8698),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            crossFadeState: open
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 180),
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spares Requested + total qty
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spares Requested',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3C4354),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '20 nos', // you can show "unique items" here; screenshot shows 20
                              style: TextStyle(
                                color: Color(0xFF7C8698),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Render each category group
                  for (final g in groups) ...[
                    _CatHeader(g.cat1, g.cat2),
                    const Divider(color: _C.line, height: 20),
                    _TableHeader(),
                    const SizedBox(height: 6),
                    for (final it in g.items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                it.partNo,
                                style: const TextStyle(
                                  color: Color(0xFF3C4354),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              _qtyTxt(it.qty),
                              style: const TextStyle(
                                color: Color(0xFF3C4354),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CatHeader extends StatelessWidget {
  final String c1;
  final String c2;
  const _CatHeader(this.c1, this.c2);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Cat 1: $c1',
              style: const TextStyle(
                color: Color(0xFF3C4354),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Cat 2: $c2',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF3C4354),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'Part No.',
            style: TextStyle(
              color: Color(0xFF7C8698),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          'Quantity',
          style: TextStyle(
            color: Color(0xFF7C8698),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SpareGroup {
  final String cat1;
  final String cat2;
  final List<_SpareItem> items;
  const _SpareGroup({
    required this.cat1,
    required this.cat2,
    required this.items,
  });
}

class _SpareItem {
  final String partNo;
  final int qty;
  const _SpareItem(this.partNo, this.qty);
}

/* ------------------------------ Widgets ------------------------------ */

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EEF5)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7E7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Mechanical',
        style: TextStyle(color: Color(0xFF2F6BFF), fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool call;
  final IconData? trailingIcon;

  const _InfoRow(
    this.label,
    this.value, {
    this.call = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final right = trailingIcon != null
        ? Icon(trailingIcon, color: const Color(0xFF2F6BFF))
        : (call ? const Icon(Icons.call, color: Color(0xFF2F6BFF)) : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF7C8698), height: 1.2),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2430),
              height: 1.25,
            ),
          ),
        ),
        if (right != null) right,
      ],
    );
  }
}

class _Accordion extends StatefulWidget {
  final String title;
  final bool initiallyOpen;
  final Widget content;
  const _Accordion({
    required this.title,
    required this.content,
    this.initiallyOpen = false,
  });

  @override
  State<_Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<_Accordion> {
  late bool open;

  @override
  void initState() {
    open = widget.initiallyOpen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => open = !open),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2430),
                    ),
                  ),
                ),
                Icon(
                  open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF7C8698),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            crossFadeState: open
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 180),
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: widget.content,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/* --------------------------- Bottom Actions --------------------------- */

class _BottomActions extends StatelessWidget {
  final VoidCallback onEnd;
  final VoidCallback onHold;
  final VoidCallback onReassign;
  final VoidCallback onCancel;

  const _BottomActions({
    required this.onEnd,
    required this.onHold,
    required this.onReassign,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE9EEF5))),
        ),
        child: Row(
          children: [
            Expanded(
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'Hold Work Order':
                      onHold();
                      break;
                    case 'Reassign Work Order':
                      onReassign();
                      break;
                    case 'Cancel Work Order':
                      onCancel();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'Hold Work Order',
                    child: Text('Hold Work Order'),
                  ),
                  PopupMenuItem(
                    value: 'Reassign Work Order',
                    child: Text('Reassign Work Order'),
                  ),
                  PopupMenuItem(
                    value: 'Cancel Work Order',
                    child: Text('Cancel Work Order'),
                  ),
                ],
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE9EEF5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: const Color(0xFF1F2430),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: null,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Other Options'),
                      SizedBox(width: 6),
                      Icon(Icons.expand_more, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onEnd,
                child: const Text(
                  'End Work',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── Audio bubble (with slider) ───────────────────────── */

bool _isAsset(String p) => p.startsWith('assets/');
bool _isUrl(String p) => p.startsWith('http://') || p.startsWith('https://');
bool _isFilePath(String p) =>
    p.startsWith('/') || p.contains(RegExp(r'^[A-Za-z]:[\\/].+'));
String _assetKey(String assetPath) =>
    assetPath.startsWith('assets/') ? assetPath.substring(7) : assetPath;

/* ───────────────────────── Audio bubble (iOS-safe) ───────────────────────── */

class _AudioBubble extends StatefulWidget {
  final String path; // asset / file / url
  final double width; // control width
  const _AudioBubble({required this.path, this.width = 180, super.key});

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  late final AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // what we actually loaded into the player (always local if the source was a URL)
  String? _localPath;

  bool get _hasSource => _localPath != null;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

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

    _prepare(); // pre-cache if possible
  }

  // Convert any remote URL to a local temp file; assets/files are passed through.
  Future<String?> _materializeToLocal(String path) async {
    try {
      if (path.isEmpty) return null;

      // Asset -> copy to temp once so DeviceFileSource works uniformly
      if (_isAsset(path)) {
        final data = await rootBundle.load(path);
        final dir = await getTemporaryDirectory();
        final f = File('${dir.path}/${_assetKey(path)}');
        if (!await f.exists()) {
          await f.create(recursive: true);
          await f.writeAsBytes(data.buffer.asUint8List());
        }
        return f.path;
      }

      // Already a file path
      if (_isFilePath(path)) {
        final f = File(path);
        if (await f.exists()) return f.path;
        return null;
      }

      // Remote URL -> download once
      if (_isUrl(path)) {
        final dir = await getTemporaryDirectory();
        final name = Uri.parse(path).pathSegments.isNotEmpty
            ? Uri.parse(path).pathSegments.last
            : 'voice_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final f = File('${dir.path}/$name');
        if (!await f.exists()) {
          final res = await http.get(Uri.parse(path));
          if (res.statusCode != 200) return null;
          await f.writeAsBytes(res.bodyBytes);
        }
        return f.path;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _prepare() async {
    if (widget.path.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final local = await _materializeToLocal(widget.path);
      if (local == null) return;
      await _player.setSource(DeviceFileSource(local));
      _localPath = local;
      // duration event will arrive soon; ask once explicitly:
      final d = await _player.getDuration();
      if (mounted && d != null) setState(() => _duration = d);
    } catch (e) {
      // swallow – we’ll retry on play
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

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
        // ensure we have a local source ready
        if (!_hasSource) await _prepare();
        if (!_hasSource) return;

        if (_position == Duration.zero) {
          await _player.stop();
          await _player.resume(); // start from 0
        } else {
          await _player.resume();
        }
        setState(() => _isPlaying = true);
      }
    } catch (_) {
      // no-op: keep UI responsive
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
      width: widget.width,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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

/* ───────────────────────── Media helpers ───────────────────────── */

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
          if (snap.connectionState != ConnectionState.done ||
              snap.data != true) {
            return base;
          }
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

/* ───────────────────────── Theme ───────────────────────── */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
}
