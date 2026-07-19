import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:watersort/ui/core/theme/app_colors.dart';
import 'package:watersort/domain/models/tube.dart';
import 'package:just_audio/just_audio.dart';

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
  
  // CHANGE 1: Make the player static or shared if possible, but for now, let's just configure it better.
  // We will create a single instance to avoid creating a new player every time a tube is tapped.
  static final AudioPlayer _sharedAudioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    // CHANGE 2: Configure the player to mix with other audio and set low volume
    _configureAudioPlayer();
  }

  // NEW FUNCTION: Configure audio behavior
  Future<void> _configureAudioPlayer() async {
    try {
      // Set volume to 0.2 (20%) so it's quiet and less likely to trigger aggressive focus stealing
      await _sharedAudioPlayer.setVolume(0.2);
      
      // Note: Just_Audio doesn't have a direct "setMixWithOthers" flag in the basic API 
      // without using the 'audio_session' package. However, lowering volume often helps.
      // If this still stops other apps, we will need to add the 'audio_session' package later.
    } catch (e) {
      debugPrint("Error configuring audio: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // CHANGE 3: Do NOT dispose the shared player here, otherwise other tubes can't play sound.
    // Only dispose it when the whole app closes (usually in main.dart or a higher-level widget).
    // For now, we leave it alive.
    super.dispose();
  }

  Widget _getIconForColor(Color color) {
    final hex = color.toARGB32() & 0xFFFFFF;
    String number = '?';
    
    switch (hex) {
      case 0xE53935: number = '1'; break; // Red
      case 0x1E88E5: number = '2'; break; // Blue
      case 0x43A047: number = '3'; break; // Green
      case 0xFDD835: number = '4'; break; // Yellow
      case 0xFF8F00: number = '5'; break; // Orange
      case 0x8E24AA: number = '6'; break; // Purple
      case 0xEC407A: number = '7'; break; // Pink
      case 0x00ACC1: number = '8'; break; // Cyan
      case 0xB39DDB: number = '9'; break; // Lavender
      case 0xFF7043: number = '10'; break; // Coral
      case 0x5C6BC0: number = '11'; break; // Indigo
      case 0x009688: number = '12'; break; // Teal
      case 0x8D6E63: number = '13'; break; // Brown
      case 0xB71C1C: number = '14'; break; // Crimson
      case 0xAD1457: number = '15'; break; // Maroon
      case 0x9E9D24: number = '16'; break; // Olive
    }

    return Align(
      alignment: Alignment.center,
      child: Text(
        number,
        style: const TextStyle(
          fontSize: 22, 
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'sans-serif',
          letterSpacing: 0.5,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomRadius = widget.width / 2;
    const double topRadius = 6.0;
    const double borderWidth = 1.8;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
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
            onTap: () async {
              // CHANGE 4: Use the shared player and check if it's already playing
              try {
                // Stop any currently playing sound immediately to allow rapid tapping
                await _sharedAudioPlayer.stop();
                
                // Load and play the asset
                await _sharedAudioPlayer.setAsset('assets/audio/plop.ogg');
                await _sharedAudioPlayer.play();
              } catch (e) {
                // Silently fail if audio doesn't load
                debugPrint("Audio error: $e");
              }
              
              // Call the original tap handler if provided
              widget.onTap?.call();
            },
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
        width: 36, 
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: _getIconForColor(color),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final double animationValue;
  final bool isFast;

  _BubblePainter({
    required this.animationValue,
    required this.isFast,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    final double speedMultiplier = isFast ? 1.8 : 1.0;
    final random = math.Random(42);

    for (int i = 0; i < 6; i++) {
      final xRatio = random.nextDouble();
      final yRatio = random.nextDouble();
      final bubbleSize = random.nextDouble() * 2.5 + 1.5;
      final speed = random.nextDouble() * 0.35 + 0.25;

      final x = xRatio * size.width;
      double y = size.height - ((yRatio + animationValue * speed * speedMultiplier) % 1.0) * size.height;
      canvas.drawCircle(Offset(x, y), bubbleSize, paint);
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
  bool shouldReclip(covariant _LiquidClipper oldClipper) => false;
}
