import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  final Color? accentColor; // optional, defaults to theme primary
  final bool dismissible; // if you ever want to use it as a sheet

  const LoadingOverlay({
    super.key,
    required this.message,
    this.accentColor,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(18);
    final Color accent = accentColor ?? Theme.of(context).colorScheme.primary;
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Block touches
        ModalBarrier(
          dismissible: dismissible,
          color: Colors.black.withOpacity(dark ? 0.12 : 0.06),
        ),

        // Subtle blur + glass tint
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),
        ),

        // Glass card with 3D loader
        Positioned.fill(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: 260),
              decoration: BoxDecoration(
                borderRadius: r,
                // glassy gradient
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? [
                          Colors.white.withOpacity(0.06),
                          Colors.white.withOpacity(0.02),
                        ]
                      : [
                          Colors.white.withOpacity(0.85),
                          Colors.white.withOpacity(0.65),
                        ],
                ),
                border: Border.all(
                  color: dark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.white.withOpacity(0.35),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.35 : 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(dark ? 0.08 : 0.45),
                    blurRadius: 12,
                    offset: const Offset(-2, -2),
                    spreadRadius: -2,
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ThreeDLoader(size: 52, accent: accent, dark: dark),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: dark ? Colors.white : const Color(0xFF1F2430),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* =========================== 3D Loader =========================== */

class _ThreeDLoader extends StatefulWidget {
  final double size;
  final Color accent;
  final bool dark;

  const _ThreeDLoader({
    required this.size,
    required this.accent,
    required this.dark,
  });

  @override
  State<_ThreeDLoader> createState() => _ThreeDLoaderState();
}

class _ThreeDLoaderState extends State<_ThreeDLoader>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spin.dispose();
    _breathe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final baseLight = _shade(Theme.of(context).colorScheme.surface, 0.14);
    final baseDark = _shade(Theme.of(context).colorScheme.surface, -0.10);

    return AnimatedBuilder(
      animation: Listenable.merge([_spin, _breathe]),
      builder: (_, __) {
        final pulse = 0.92 + _breathe.value * 0.08; // 0.92..1.0
        return Transform.scale(
          scale: pulse,
          child: Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Raised 3D base (neumorphic)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [baseLight, baseDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.dark ? 0.25 : 0.15),
                  offset: const Offset(6, 6),
                  blurRadius: 16,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(widget.dark ? 0.10 : 0.70),
                  offset: const Offset(-6, -6),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner bevel
                Container(
                  width: s * 0.86,
                  height: s * 0.86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(widget.dark ? 0.20 : 0.85),
                        _shade(Theme.of(context).colorScheme.surface, -0.06),
                      ],
                      stops: const [0.55, 1.0],
                    ),
                  ),
                ),

                // Rotating shiny arc
                Transform.rotate(
                  angle: _spin.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size.square(s * 0.88),
                    painter: _ArcPainter3D(
                      colorStart: _tint(widget.accent, 0.35),
                      colorEnd: _shade(widget.accent, -0.22),
                      strokeWidth: math.max(3.0, s * 0.11),
                      specularOpacity: widget.dark ? 0.22 : 0.28,
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
}

class _ArcPainter3D extends CustomPainter {
  final Color colorStart;
  final Color colorEnd;
  final double strokeWidth;
  final double specularOpacity;

  _ArcPainter3D({
    required this.colorStart,
    required this.colorEnd,
    required this.strokeWidth,
    required this.specularOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Gradient wedge (looks like a glossy 3D arc)
    final shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [Colors.transparent, colorStart, colorEnd, Colors.transparent],
      stops: const [0.00, 0.18, 0.42, 1.0],
    ).createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final inset = strokeWidth / 2 + 1;
    final r = Rect.fromLTWH(
      inset,
      inset,
      size.width - 2 * inset,
      size.height - 2 * inset,
    );

    // Base arc (full circle; only wedge visible due to gradient)
    canvas.drawArc(r, 0, 2 * math.pi, false, paint);

    // Specular highlight for extra shine
    final highlight = Paint()
      ..color = Colors.white.withOpacity(specularOpacity)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, strokeWidth * 0.35);

    canvas.drawArc(
      r.deflate(strokeWidth * 0.22),
      -math.pi / 3,
      math.pi / 10,
      false,
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter3D old) =>
      old.colorStart != colorStart ||
      old.colorEnd != colorEnd ||
      old.strokeWidth != strokeWidth ||
      old.specularOpacity != specularOpacity;
}

/* =========================== Color helpers =========================== */

Color _shade(Color c, double amount) {
  final h = HSLColor.fromColor(c);
  final l = (h.lightness + amount).clamp(0.0, 1.0);
  return h.withLightness(l).toColor();
}

Color _tint(Color c, double amount) => _shade(c, amount);
