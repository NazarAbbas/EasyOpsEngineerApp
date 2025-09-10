// start_work_order_page.dart
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_ops/route_managment/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// 👇 for optional iOS-safe remote→local audio fallback
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:easy_ops/ui/modules/maintenance_work_order/start_work_order/controller/start_work_order_controller.dart';

class StartWorkOrderPage extends GetView<StartWorkOrderController> {
  const StartWorkOrderPage({super.key});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final isTablet = _isTablet(context);
    final headerH = isTablet ? 110.0 : 96.0;
    final hPad = isTablet ? 18.0 : 14.0;
    final btnH = isTablet ? 54.0 : 50.0;
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    // key used to anchor the popup menu to the button
    final otherBtnKey = GlobalKey();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(headerH),
        child: _GradientHeader(title: 'Work Order Details', isTablet: isTablet),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: otherBtnKey,
                  icon: const Icon(CupertinoIcons.chevron_up, size: 16),
                  label: const Text(
                    'Other Options',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () =>
                      _showOtherOptionsMenu(context, otherBtnKey, controller),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(btnH),
                    side: BorderSide(color: primary, width: 1.4),
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: controller.StartOrder,
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(btnH),
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1.5,
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // No TabBar, just a single scrollable page
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 16),
        child: Column(
          children: const [
            _SummaryHeroCard(),
            _OperatorInfoCard(),
            _WorkOrderInfoCard(),
            _MediaCard(), // 👈 full-width card with images + audio stacked
            _SparesCard(),
          ],
        ),
      ),
    );
  }

  /// Anchored popup like the screenshot
  Future<void> _showOtherOptionsMenu(
    BuildContext context,
    GlobalKey anchorKey,
    StartWorkOrderController c,
  ) async {
    final button = anchorKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final btnSize = button.size;
    final btnTopLeft = button.localToGlobal(Offset.zero, ancestor: overlay);

    // ---- Menu sizing so we can place it ABOVE the button ----
    const itemHeight = 40.0;
    const verticalPadding = 8.0;
    const gap = 6.0; // small space between button and menu
    final menuHeight = (2 * itemHeight) + (2 * verticalPadding);

    // target top-left corner for the menu so it sits above the button
    double top = btnTopLeft.dy - menuHeight - gap;

    // clamp to stay on screen
    top = top.clamp(8.0, overlay.size.height - menuHeight - 8.0);

    // align left edges with the button
    final left = btnTopLeft.dx;
    final right = overlay.size.width - left - btnSize.width;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        left,
        top,
        right,
        overlay.size.height - top,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: const [
        PopupMenuItem<String>(
          value: 'hold',
          height: itemHeight,
          child: Text(
            'Hold Work Order',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        PopupMenuDivider(height: 0),
        PopupMenuItem<String>(
          value: 'cancel',
          height: itemHeight,
          child: Text(
            'Cancel Work Order',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );

    if (selected == 'hold') {
      Get.toNamed(Routes.holdWorkOrderScreen);
    } else if (selected == 'cancel') {
      Get.toNamed(Routes.cancelWorkOrderFromDiagnosticsScreen);
    }
  }
}

/* ───────────────────────── Header ───────────────────────── */

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
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary],
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

/* ───────────────────────── Hero Summary Card ───────────────────────── */

class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StartWorkOrderController>();
    final primary =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Obx(() {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [primary, primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F6BFF).withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + chips
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    c.subject.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17.5,
                      height: 1.22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _SolidPill(
                      text: c.priority.value,
                      color: const Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 6),
                    const _GlassChip(
                      text: 'In Progress',
                      icon: CupertinoIcons.checkmark_seal_fill,
                    ),
                    const SizedBox(height: 6),
                    _GlassChip(
                      text: c.elapsed.value,
                      icon: CupertinoIcons.time,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(text: c.woCode.value, icon: CupertinoIcons.number),
                _MetaChip(text: c.time.value, icon: CupertinoIcons.clock),
                _MetaChip(text: c.date.value, icon: CupertinoIcons.calendar),
                _MetaChip(
                  text: c.category.value,
                  icon: CupertinoIcons.gear_alt_fill,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }
}

class _GlassChip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _GlassChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.16),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _MetaChip extends StatelessWidget {
  final String text;
  final IconData icon;
  const _MetaChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.22)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _SolidPill extends StatelessWidget {
  final String text;
  final Color color;
  const _SolidPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
    ),
  );
}

/* ───────────────────────── Operator Info Card ───────────────────────── */

class _OperatorInfoCard extends StatelessWidget {
  const _OperatorInfoCard();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StartWorkOrderController>();
    return _Card(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Obx(
        () => Column(
          children: [
            _CardHeader(
              title: 'Operator Info',
              open: c.operatorOpen.value,
              onToggle: c.toggleOperator,
            ),
            if (c.operatorOpen.value) ...[
              const SizedBox(height: 10),
              _InfoRow(
                label: 'Reported By',
                value: c.reportedBy.value,
                onCall: () {},
              ),
              const SizedBox(height: 8),
              _InfoRow(
                label: 'Maintenance Manager',
                value: c.maintenanceManager.value,
                onCall: () {},
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── Work Order Info Card ───────────────────────── */

class _WorkOrderInfoCard extends StatelessWidget {
  const _WorkOrderInfoCard();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StartWorkOrderController>();
    return _Card(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              title: 'Work Order Info',
              open: c.workInfoOpen.value,
              onToggle: c.toggleWorkInfo,
            ),
            if (c.workInfoOpen.value) ...[
              const SizedBox(height: 10),
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
                      c.assetLine.value,
                      style: const TextStyle(
                        color: _C.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _IconChip(
                    icon: CupertinoIcons.arrow_clockwise,
                    bg: const Color(0xFFEFF3FF),
                    fg: _C.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                c.assetLocation.value,
                style: const TextStyle(
                  color: _C.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                c.description.value,
                style: const TextStyle(color: _C.text, height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── Media Card (Images + Audio) ───────────────────────── */

class _MediaCard extends StatelessWidget {
  const _MediaCard();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StartWorkOrderController>();

    return _Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Obx(() {
        final photos = c.photoPaths.where((p) => p.isNotEmpty).toList();
        final voice = c.voiceNotePath.value;

        if (photos.isEmpty && voice.isEmpty) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, box) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Media',
                  style: TextStyle(
                    color: _C.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),

                if (photos.isNotEmpty)
                  SizedBox(
                    width: box.maxWidth, // full width wrap of thumbs
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
                    width: box.maxWidth, // stretch audio bar across the card
                  ),
                ],
              ],
            );
          },
        );
      }),
    );
  }
}

/* ───────────────────────── Spares Card ───────────────────────── */

class _SparesCard extends StatelessWidget {
  const _SparesCard();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StartWorkOrderController>();
    return _Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Obx(() {
        final open = c.needSparesOpen.value;
        return InkWell(
          onTap: c.toggleSpares,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.question_circle,
                color: _C.muted,
                size: 18,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Need Spares?',
                  style: TextStyle(color: _C.text, fontWeight: FontWeight.w800),
                ),
              ),
              _IconChip(
                icon: open
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                bg: const Color(0xFFEFF3FF),
                fg: _C.primary,
              ),
            ],
          ),
        );
      }),
    );
  }
}

/* ───────────────────────── Small Widgets / Helpers ───────────────────────── */

class _CardHeader extends StatelessWidget {
  final String title;
  final bool open;
  final VoidCallback onToggle;
  const _CardHeader({
    required this.title,
    required this.open,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(color: _C.muted, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: Icon(
            open ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
            size: 18,
            color: _C.muted,
          ),
          onPressed: onToggle,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCall;
  const _InfoRow({required this.label, required this.value, this.onCall});

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: _C.muted, fontWeight: FontWeight.w700);
    const valueStyle = TextStyle(color: _C.text, fontWeight: FontWeight.w800);

    return Row(
      children: [
        SizedBox(width: 140, child: Text(label, style: labelStyle)),
        Expanded(child: Text(value, style: valueStyle)),
        IconButton(
          onPressed: onCall,
          icon: const Icon(CupertinoIcons.phone, color: _C.primary, size: 18),
          tooltip: 'Call',
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: double.infinity,
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
      child: Padding(padding: padding, child: child),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  const _IconChip({required this.icon, required this.bg, required this.fg});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: Icon(icon, size: 16, color: fg),
  );
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

/* ───────────────────────── Audio bubble (with slider + iOS fallback) ───────────────────────── */

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
  String? _localCachePath; // used if remote fails and we download

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

  Future<void> _preload() async {
    final src = _buildSource(widget.path);
    if (src == null) return;
    try {
      await _player.setSource(src);
      final d = await _player.getDuration();
      if (mounted && d != null) setState(() => _duration = d);
      _currentSource = src;
    } catch (e) {
      // iOS sometimes fails on remote streams; fall back to temp file
      if (src is UrlSource) {
        await _downloadAndUseLocal(src.url);
      }
    }
  }

  Future<void> _downloadAndUseLocal(String url) async {
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final f = File(path);
        await f.writeAsBytes(resp.bodyBytes);
        _localCachePath = path;
        final localSrc = DeviceFileSource(path);
        await _player.setSource(localSrc);
        final d = await _player.getDuration();
        if (mounted && d != null) setState(() => _duration = d);
        _currentSource = localSrc;
      } else {
        debugPrint('Audio download failed: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Audio download exception: $e');
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
        var src = _currentSource ?? _buildSource(widget.path);

        // prefer local cache if available
        if (_localCachePath != null) {
          src = DeviceFileSource(_localCachePath!);
          _currentSource = src;
        }

        try {
          if (_position == Duration.zero) {
            await _player.stop();
            if (_currentSource == null && src != null) {
              await _player.setSource(src);
              _currentSource = src;
            }
            await _player.resume(); // start from 0
          } else {
            await _player.resume();
          }
          setState(() => _isPlaying = true);
        } catch (playErr) {
          // last-chance: if remote stream fails here, download + use local
          if (src is UrlSource) {
            await _downloadAndUseLocal(src.url);
            await _player.resume();
            setState(() => _isPlaying = true);
          } else {
            rethrow;
          }
        }
      }
    } catch (e) {
      debugPrint('Audio toggle error: $e');
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

/* ───────────────────────── Theme ───────────────────────── */

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
}
