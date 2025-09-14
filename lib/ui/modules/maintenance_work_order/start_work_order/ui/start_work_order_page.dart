// start_work_order_page.dart
// NOTE: No import of request_spares_controller.dart here.

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_ops/route_managment/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:easy_ops/ui/modules/maintenance_work_order/start_work_order/controller/start_work_order_controller.dart';
import 'package:easy_ops/ui/modules/maintenance_work_order/spare_cart/models/spares_models.dart';

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

    final otherBtnKey = GlobalKey();

    return WillPopScope(
      onWillPop: () async {
        await controller.stopAllAudio(); // stop audio on system back
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(headerH),
          child: _GradientHeader(
            title: 'Work Order Details',
            isTablet: isTablet,
            onBack: () async {
              await controller.stopAllAudio(); // stop before back
              Get.back();
            },
          ),
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
                    onPressed: controller.startOrder, // controller stops audio
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
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 16),
          child: Column(
            children: const [
              _SummaryHeroCard(),
              _OperatorInfoCard(),
              _WorkOrderInfoCard(),
              _MediaCard(),
              _SparesCard(), // shows placed items here
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showOtherOptionsMenu(
    BuildContext context,
    GlobalKey anchorKey,
    StartWorkOrderController c,
  ) async {
    final button = anchorKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final btnSize = button.size;
    final btnTopLeft = button.localToGlobal(Offset.zero, ancestor: overlay);

    const itemHeight = 40.0;
    const verticalPadding = 8.0;
    const gap = 6.0;
    final menuHeight = (2 * itemHeight) + (2 * verticalPadding);

    double top = btnTopLeft.dy - menuHeight - gap;
    top = top.clamp(8.0, overlay.size.height - menuHeight - 8.0);

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
      await c.stopAllAudio();
      Get.toNamed(Routes.holdWorkOrderScreen);
    } else if (selected == 'cancel') {
      await c.stopAllAudio();
      Get.toNamed(Routes.cancelWorkOrderFromDiagnosticsScreen);
    }
  }
}

/* ───────── Header ───────── */
class _GradientHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isTablet;
  final VoidCallback? onBack;
  const _GradientHeader({
    required this.title,
    required this.isTablet,
    this.onBack,
  });

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
        gradient: LinearGradient(colors: [primary, primary]),
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
                onPressed: onBack,
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
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

/* ───────── Hero Card (beautiful, screenshot-like) ───────── */
class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard();

  String _shortDate(String s) {
    final p = s.trim().split(RegExp(r'\s+'));
    return p.length >= 2 ? '${p[0]} ${p[1]}' : s;
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StartWorkOrderController>();
    final blue =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;

    return Obx(() {
      final title = c.subject.value.isEmpty
          ? 'Conveyor Belt Stopped Abruptly During Operation'
          : c.subject.value;
      final code = c.woCode.value.isEmpty ? 'BD-102' : c.woCode.value;
      final time = c.time.value.isEmpty ? '18:08' : c.time.value;
      final date = c.date.value.isEmpty ? '09 Aug' : _shortDate(c.date.value);
      final prio = c.priority.value.isEmpty ? 'High' : c.priority.value;
      final status = 'In Progress';
      final cat = c.category.value.isEmpty ? 'Mechanical' : c.category.value;
      final elapsed = c.elapsed.value.isEmpty ? '1h 20m' : c.elapsed.value;

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9EEF5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + red priority pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _C.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _Badge(text: prio, bg: const Color(0xFFED3B40)),
                  ],
                ),

                const SizedBox(height: 10),

                // Code + time | date  …  status
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$code   $time | $date',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _C.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      status,
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom row: category + small blue tile … clock + elapsed
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              cat,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _C.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF3FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.sync_alt_rounded,
                              size: 14,
                              color: blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(CupertinoIcons.time, size: 16, color: _C.muted),
                    const SizedBox(width: 6),
                    Text(
                      elapsed,
                      style: const TextStyle(
                        color: _C.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Small notch decoration (optional, nice touch)
          const Positioned(top: -8, left: 24, right: 24, child: _Notch()),
        ],
      );
    });
  }
}

/* ───────── Operator Info (with call buttons) ───────── */
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
              _CallRow(
                label: 'Reported By',
                value: c.reportedBy.value,
                phone: c.reportedByPhone.value,
              ),
              const SizedBox(height: 8),
              _CallRow(
                label: 'Maintenance Manager',
                value: c.maintenanceManager.value,
                phone: c.maintenanceManagerPhone.value,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CallRow extends StatelessWidget {
  final String label;
  final String value;
  final String phone;
  const _CallRow({
    required this.label,
    required this.value,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(color: _C.muted, fontWeight: FontWeight.w700);
    const valueStyle = TextStyle(color: _C.text, fontWeight: FontWeight.w800);

    final canCall = phone.trim().isNotEmpty;

    return Row(
      children: [
        SizedBox(width: 140, child: Text(label, style: labelStyle)),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
        ),
        const SizedBox(width: 8),
        _CallBtn(
          enabled: canCall,
          onTap: () async {
            if (!canCall) return;
            final uri = Uri(scheme: 'tel', path: phone.trim());
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              Get.snackbar(
                'Unable to place call',
                'Phone dialer not available',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
        ),
      ],
    );
  }
}

class _CallBtn extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _CallBtn({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFEFF3FF) : const Color(0xFFF2F4F7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? _C.primary.withOpacity(0.18)
                : _C.muted.withOpacity(0.18),
          ),
        ),
        child: Icon(
          CupertinoIcons.phone,
          size: 18,
          color: enabled ? _C.primary : _C.muted,
        ),
      ),
    );
  }
}

/* ───────── Work Order Info (with history icon) ───────── */
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
                  Expanded(
                    child: Text(
                      c.assetLine.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _C.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _HistoryBtn(onTap: c.openAssetHistory),
                ],
              ),
              const SizedBox(height: 6),
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

class _HistoryBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _HistoryBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.line),
        ),
        child: const Icon(CupertinoIcons.time, size: 18, color: _C.primary),
      ),
    );
  }
}

/* ───────── Media Card (images + audio) ───────── */
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
                    width: box.maxWidth,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: photos.map((p) => _Thumb(path: p)).toList(),
                    ),
                  ),
                if (voice.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _AudioBubble(path: voice, width: box.maxWidth),
                ],
              ],
            );
          },
        );
      }),
    );
  }
}

/* ───────── Spares Card (shows placed items) ───────── */
class _SparesCard extends StatelessWidget {
  const _SparesCard();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<StartWorkOrderController>();
    return _Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Obx(() {
        final lines = c.requestedSpares;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: c.needSpares, // controller will stop audio before nav
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: const [
                  Icon(
                    CupertinoIcons.question_circle,
                    color: _C.muted,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Need Spares?',
                      style: TextStyle(
                        color: _C.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _IconChip(
                    icon: CupertinoIcons.settings,
                    bg: Color(0xFFEFF3FF),
                    fg: _C.primary,
                  ),
                ],
              ),
            ),
            if (lines.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFE6EBF3)),
              const SizedBox(height: 6),
              const Text(
                'Requested Spares',
                style: TextStyle(color: _C.muted, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lines.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _SpareLine(line: lines[i]),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _SpareLine extends StatelessWidget {
  const _SpareLine({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final title = line.item.name.isNotEmpty ? line.item.name : line.item.code;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _C.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                line.item.code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _C.text),
              ),
              if ((line.cat1 ?? '').isNotEmpty || (line.cat2 ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Cat 1: ${line.cat1 ?? "-"}   ·   Cat 2: ${line.cat2 ?? "-"}',
                    style: const TextStyle(color: _C.muted, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${line.qty.toString().padLeft(2, '0')} nos',
          style: const TextStyle(
            color: _C.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/* ───────── Shared small widgets / helpers ───────── */
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

/* ====== Media helpers (images + audio) ====== */
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

/* ───────── Audio bubble ───────── */

class _AudioBubble extends StatefulWidget {
  final String path; // asset / file / url
  final double? width;
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
  String? _localCachePath;

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

    // Register with controller so it can stop us on navigation
    Get.find<StartWorkOrderController>().registerPlayer(_player);

    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      if (_duration != Duration.zero && p > _duration) p = _duration;
      setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = _duration;
        });
      }
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
    } catch (_) {
      if (src is UrlSource) await _downloadAndUseLocal(src.url);
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
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      _player.stop();
    } catch (_) {}
    Get.find<StartWorkOrderController>().unregisterPlayer(_player);
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
            await _player.resume();
          } else {
            await _player.resume();
          }
          setState(() => _isPlaying = true);
        } catch (_) {
          if (src is UrlSource) {
            await _downloadAndUseLocal(src.url);
            await _player.resume();
            setState(() => _isPlaying = true);
          }
        }
      }
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

/* ───────── tiny helpers ───────── */
class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  const _Badge({required this.text, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
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

class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFFE3E8F2),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────── Local theme ───────── */
class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
}
