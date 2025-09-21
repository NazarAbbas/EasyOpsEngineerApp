// sign_off_page.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:easy_ops/features/feature_maintenance_work_order/closure_signature/controller/sign_off_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

/* ───────── SignaturePad external controller ───────── */
class SignaturePadController {
  _SignaturePadState? _state;

  Future<Uint8List?> exportPng() => _state?.exportPng() ?? Future.value(null);
  void clear() => _state?.clearAll();

  // internal
  void _bind(_SignaturePadState s) => _state = s;
  void _unbind(_SignaturePadState s) {
    if (identical(_state, s)) _state = null;
  }
}

class SignOffPage extends GetView<SignOffController> {
  SignOffPage({super.key});

  @override
  SignOffController get controller => Get.put(SignOffController());

  // Controller to access the pad (no GlobalKey)
  final SignaturePadController _sigController = SignaturePadController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3C4354),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sign Off'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: _SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SIGNATURE
                    Row(
                      children: [
                        const _Label('Sign'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            controller
                                .clearSignature(); // clear controller state
                            _sigController
                                .clear(); // clear pad (strokes + image)
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => _SignaturePad(
                        controller: _sigController,
                        initialBytes: controller
                            .signatureBytes
                            .value, // show existing signature
                        onChanged: (hasStrokeOrImage) =>
                            controller.hasSignature.value = hasStrokeOrImage,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const _Label('Employee Code'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller.empCodeCtrl,
                      decoration: _input().copyWith(
                        suffixIcon: Obx(
                          () => controller.isSearching.value
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onSubmitted: controller.lookupEmployee,
                    ),

                    // Lookup feedback
                    Obx(() {
                      final err = controller.searchError.value;
                      if (err.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          err,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }),

                    // Auto-filled employee details
                    const SizedBox(height: 14),
                    Obx(() {
                      final e = controller.employee.value;
                      if (e == null) return const SizedBox.shrink();
                      return _InfoGrid(e: e);
                    }),
                  ],
                ),
              ),
            ),
            if (controller.isSaving.value)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(
                      color: Color(0xFF2F6BFF),
                      width: 1.2,
                    ),
                    foregroundColor: const Color(0xFF2F6BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Discard',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final enabled =
                      controller.canSave && !controller.isSaving.value;
                  return FilledButton(
                    onPressed: enabled
                        ? () async {
                            // export PNG from signature pad
                            final bytes = await _sigController.exportPng();
                            if (bytes == null || bytes.isEmpty) {
                              Get.snackbar(
                                'Signature',
                                'Please sign inside the box to continue',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }
                            controller.signatureBytes.value = bytes;
                            await controller
                                .save(); // Get.back(result: SignatureResult)
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: const Color(0xFF2F6BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSaving.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ───────── Signature Pad (controller-based, no GlobalKey) ───────── */

class _SignaturePad extends StatefulWidget {
  final SignaturePadController controller;
  final Uint8List? initialBytes; // optional: show existing signature
  final ValueChanged<bool> onChanged;

  const _SignaturePad({
    required this.controller,
    required this.onChanged,
    this.initialBytes,
    super.key,
  });

  @override
  State<_SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<_SignaturePad> {
  final List<List<Offset>> _strokes = [];
  final ValueNotifier<int> _repaint = ValueNotifier(0);
  final GlobalKey _boundaryKey = GlobalKey(); // for PNG capture
  final GlobalKey _boxKey = GlobalKey(); // for clamping

  Uint8List? _initialBytes; // local copy so we can clear independently

  @override
  void initState() {
    super.initState();
    _initialBytes = widget.initialBytes;
    widget.controller._bind(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_hasSignature || _initialBytes != null);
    });
  }

  @override
  void didUpdateWidget(covariant _SignaturePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.initialBytes, widget.initialBytes)) {
      setState(() => _initialBytes = widget.initialBytes);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(_hasSignature || _initialBytes != null);
      });
    }
  }

  @override
  void dispose() {
    widget.controller._unbind(this);
    super.dispose();
  }

  bool get _hasSignature => _strokes.any((s) => s.length > 1);

  RenderBox? get _box =>
      _boxKey.currentContext?.findRenderObject() as RenderBox?;

  Offset _toLocalAndClamp(Offset global) {
    final box = _box;
    if (box == null) return Offset.zero;
    final local = box.globalToLocal(global);
    final size = box.size;
    return Offset(
      local.dx.clamp(0.0, size.width),
      local.dy.clamp(0.0, size.height),
    );
  }

  void _down(PointerDownEvent e) {
    _strokes.add([_toLocalAndClamp(e.position)]);
    _repaint.value++;
  }

  void _move(PointerMoveEvent e) {
    if (_strokes.isEmpty) _strokes.add(<Offset>[]);
    _strokes.last.add(_toLocalAndClamp(e.position));
    _repaint.value++;
    widget.onChanged(_hasSignature || _initialBytes != null);
  }

  void _finish() {
    if (_strokes.isNotEmpty && _strokes.last.isEmpty) {
      _strokes.removeLast();
      _repaint.value++;
    }
    widget.onChanged(_hasSignature || _initialBytes != null);
  }

  void _up(PointerUpEvent e) => _finish();
  void _cancel(PointerCancelEvent e) => _finish();

  /// Clear both strokes and any loaded initial image
  void clearAll() {
    _strokes.clear();
    _repaint.value++;
    setState(() => _initialBytes = null);
    widget.onChanged(false);
  }

  Future<Uint8List?> exportPng() async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);

    return RepaintBoundary(
      key: _boundaryKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Listener(
            onPointerDown: _down,
            onPointerMove: _move,
            onPointerUp: _up,
            onPointerCancel: _cancel,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              key: _boxKey,
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Show initial image (if any) UNDER the strokes,
                  // and only when user hasn't drawn new strokes.
                  if (_initialBytes != null && !_hasSignature)
                    FittedBox(
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      child: Image.memory(
                        _initialBytes!,
                        gaplessPlayback: true,
                      ),
                    ),

                  // Drawing layer
                  CustomPaint(
                    painter: _SignaturePainter(_strokes, repaint: _repaint),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  _SignaturePainter(this.strokes, {super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1F2430)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final s in strokes) {
      if (s.length < 2) continue;
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (var i = 1; i < s.length; i++) {
        path.lineTo(s[i].dx, s[i].dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* ───────── UI bits ───────── */

class _InfoGrid extends StatelessWidget {
  final Employee e;
  const _InfoGrid({required this.e});

  @override
  Widget build(BuildContext context) {
    const ls = TextStyle(color: _C.muted, fontWeight: FontWeight.w700);
    const vs = TextStyle(color: _C.text, fontWeight: FontWeight.w800);

    Widget row(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(l, style: ls)),
          Expanded(child: Text(v, style: vs)),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FA),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: [
          row('Name', e.name),
          row('Ph. Number', e.phone),
          row('Department', e.department),
          row('Designation', e.designation),
        ],
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  const _SoftCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE9EEF5)),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: child,
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF7C8698),
      fontWeight: FontWeight.w800,
    ),
  );
}

InputDecoration _input() => InputDecoration(
  isDense: true,
  hintText: 'Enter Employee Code',
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: Color(0xFF2F6BFF), width: 1.2),
  ),
);

class _C {
  static const primary = Color(0xFF2F6BFF);
  static const muted = Color(0xFF7C8698);
  static const text = Color(0xFF2D2F39);
  static const line = Color(0xFFE6EBF3);
}
