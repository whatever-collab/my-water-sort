import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:watersort/ui/core/theme/app_colors.dart';
import 'package:watersort/domain/models/tube.dart';

class TubeWidget extends StatefulWidget {
  const TubeWidget({
    super.key,
    required this.tube,
    this.isSelected = false,
    this.isPouringSource = false,
    this.isPouringTarget = false,
    this.pourToLeft = false,
    this.onTap,
    this.height = 180,
    this.width = 56,
  });

  final Tube tube;
  final bool isSelected;
  final bool isPouringSource;
  final bool isPouringTarget;
  final bool pourToLeft;
  final VoidCallback? onTap;
  final double height;
  final double width;

  @override
  State<TubeWidget> createState() => _TubeWidgetState();
}

class _TubeWidgetState extends State<TubeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Bubble> _bubbles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Generate random bubbles
    for (int i = 0; i < 6; i++) {
      _bubbles.add(_Bubble(
        xRatio: _random.nextDouble(),
        yRatio: _random.nextDouble(),
        size: _random.nextDouble() * 2.5 + 1.5,
        speed: _random.nextDouble() * 0.35 + 0.25,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconForColor(Color color) {
    final hex = color.value & 0xFFFFFF;
    switch (hex) {
      case 0xE53935: return Icons.favorite_rounded; // Red (Heart)
      case 0x1E88E5: return Icons.water_drop_rounded; // Blue (Water droplet)
      case 0x43A047: return Icons.eco_rounded; // Green (Leaf)
      case 0xFDD835: return Icons.wb_sunny_rounded; // Yellow (Sun)
      case 0xFFFF8F00: return Icons.star_rounded; // Orange (Star)
      case 0x8E24AA: return Icons.dark_mode_rounded; // Purple (Moon)
      case 0xEC407A: return Icons.auto_awesome_rounded; // Pink (Sparkles)
      case 0x00ACC1: return Icons.ac_unit_rounded; // Cyan (Snowflake)
      case 0x7CB342: return Icons.change_history_rounded; // Lime (Triangle)
      case 0xFB8C00: return Icons.local_fire_department_rounded; // Deep Orange (Fire)
      case 0x5C6BC0: return Icons.cloud_rounded; // Indigo (Cloud)
      case 0x26A69A: return Icons.diamond_rounded; // Teal (Diamond)
      default: return Icons.brightness_1_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomRadius = widget.width / 2;
    const double topRadius = 6.0;
    const double borderWidth = 1.8;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Selection hover lift
        double yOffset = 0;
        double pulseScale = 1.0;
        if (widget.isSelected) {
          yOffset = -18 + 3.0 * math.sin(_controller.value * 2 * math.pi);
          pulseScale = 1.0 + 0.12 * math.sin(_controller.value * 2 * math.pi);
        }

        final accentColor = AppColors.accent;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                color: const Color(0xFF16161C).withOpacity(0.85),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(bottomRadius),
                  top: Radius.circular(topRadius),
                ),
                border: Border.all(
                  color: widget.isSelected ? accentColor : const Color(0xFF222222),
                  width: widget.isSelected ? 2.2 : borderWidth,
                ),
                boxShadow: [
                  if (widget.isSelected)
                    BoxShadow(
                      color: accentColor.withOpacity(0.45 * pulseScale),
                      blurRadius: 16 * pulseScale,
                      spreadRadius: 1.5 * pulseScale,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Liquid columns
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(bottomRadius - borderWidth),
                        top: Radius.circular(topRadius - borderWidth),
                      ),
                      child: Stack(
                        children: [
                          // Liquid Segments Columns
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: List.generate(
                                widget.tube.colors.length,
                                (i) {
                                  final logicalIndex = widget.tube.colors.length - 1 - i;
                                  final color = widget.tube.colors[logicalIndex];
                                  return _buildLiquidBlock(color);
                                },
                              ),
                            ),
                          ),

                          // Wave effect matching current filled height
                          if (widget.tube.colors.isNotEmpty)
                            Positioned(
                              bottom: (widget.tube.colors.length / widget.tube.capacity) * (widget.height - 12) - 4,
                              left: 0,
                              right: 0,
                              height: 10,
                              child: CustomPaint(
                                painter: _WavePainter(
                                  color: widget.tube.topColor!,
                                  animationValue: _controller.value,
                                  isFast: widget.isSelected,
                                ),
                              ),
                            ),

                          // Bubbles rising inside liquid columns
                          if (widget.tube.colors.isNotEmpty)
                            Positioned.fill(
                              child: ClipPath(
                                  clipper: _LiquidClipper(
                                    liquidHeight: (widget.tube.colors.length / widget.tube.capacity) * (widget.height - 12),
                                  ),
                                  child: CustomPaint(
                                    painter: _BubblePainter(
                                      bubbles: _bubbles,
                                      animationValue: _controller.value,
                                      isFast: widget.isSelected,
                                    ),
                                  ),
                                ),
                            ),

                          // Sheen reflection
                          Positioned(
                            top: 4,
                            left: 4,
                            bottom: 4,
                            width: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0.18),
                                    Colors.white.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lip/Rim
                  Positioned(
                    top: -2.5,
                    left: -2,
                    right: -2,
                    height: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C22),
                        borderRadius: BorderRadius.circular(2.5),
                        border: Border.all(
                          color: widget.isSelected ? accentColor : const Color(0xFF222222),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiquidBlock(Color color) {
    final segmentHeight = (widget.height - 12) / widget.tube.capacity;

    return Container(
      height: segmentHeight,
      width: widget.width,
      decoration: BoxDecoration(
        color: color,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.95),
            color,
            color.withOpacity(0.85),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIconForColor(color),
          color: Colors.white.withOpacity(0.85),
          size: widget.width * 0.36,
        ),
      ),
    );
  }
}

class _Bubble {
  final double xRatio;
  final double yRatio;
  final double size;
  final double speed;

  _Bubble({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
  });
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double animationValue;
  final bool isFast;

  _BubblePainter({
    required this.bubbles,
    required this.animationValue,
    required this.isFast,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final double speedMultiplier = isFast ? 1.8 : 1.0;

    for (final bubble in bubbles) {
      final x = bubble.xRatio * size.width;
      double y = size.height - ((bubble.yRatio + animationValue * bubble.speed * speedMultiplier) % 1.0) * size.height;
      canvas.drawCircle(Offset(x, y), bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double animationValue;
  final bool isFast;

  _WavePainter({
    required this.color,
    required this.animationValue,
    required this.isFast,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    final double amplitude = isFast ? 4.5 : 2.5;
    final double frequencyFactor = isFast ? 2.5 : 1.0;

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          math.sin((x / size.width * 2 * math.pi) + (animationValue * 2 * math.pi * frequencyFactor)) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}

class _LiquidClipper extends CustomClipper<Path> {
  final double liquidHeight;

  _LiquidClipper({required this.liquidHeight});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height - liquidHeight);
    path.lineTo(size.width, size.height - liquidHeight);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _LiquidClipper oldDelegate) =>
      oldDelegate.liquidHeight != liquidHeight;
}
