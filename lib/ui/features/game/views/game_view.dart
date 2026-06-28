import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:watersort/ui/core/theme/app_colors.dart';
import 'package:watersort/ui/core/widgets/tangible_button.dart';
import 'package:watersort/ui/core/widgets/tube_widget.dart';
import 'package:watersort/ui/features/game/view_models/game_view_model.dart';
import 'package:watersort/ui/providers.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({
    super.key,
    required this.levelNumber,
    this.isRandom = false,
    this.randomDifficulty = 'Easy',
  });

  final int levelNumber;
  final bool isRandom;
  final String randomDifficulty;

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.isRandom) {
        ref.read(gameViewModelProvider.notifier).loadRandomLevel(widget.randomDifficulty);
      } else {
        ref.read(gameViewModelProvider.notifier).loadLevel(widget.levelNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameViewModelProvider);

    ref.listen<GameViewModelState>(gameViewModelProvider, (prev, next) {
      if (next.isComplete && !(prev?.isComplete ?? false)) {
        _showCompleteDialog();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF222222),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    state.isRandomMode
                        ? '${state.randomDifficulty?.toUpperCase() ?? "RANDOM"} PUZZLE'
                        : 'LEVEL ${widget.levelNumber}',
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.headingWhite,
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(gameViewModelProvider.notifier).resetLevel(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF222222),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Game body
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(gameViewModelProvider.notifier)
                                    .resetLevel(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _buildGame(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame(GameViewModelState state) {
    final level = state.level;
    if (level == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF222222),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('MOVES', '${state.moveCount}', Icons.trending_up_rounded),
              _verticalDivider(),
              _stat('COLORS', '${level.colorCount}', Icons.palette_rounded),
              _verticalDivider(),
              _stat('TUBES', '${level.tubeCount}', Icons.science_rounded),
            ],
          ),
        ),

        // Tubes Container
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double containerWidth = constraints.maxWidth;
                final double containerHeight = constraints.maxHeight;

                final int tubeCount = level.tubes.length;
                final int maxPerRow;
                if (tubeCount <= 6) {
                  maxPerRow = tubeCount;
                } else if (tubeCount <= 8) {
                  maxPerRow = 4;
                } else if (tubeCount <= 12) {
                  maxPerRow = 5;
                } else {
                  maxPerRow = 6;
                }
                final int rows = (tubeCount / maxPerRow).ceil();
                final int cols = (tubeCount / rows).ceil();

                const double spacing = 8.0;
                const double aspectRatio = 3.2;

                final double maxTubeWidth = (containerWidth - (cols + 1) * spacing) / cols;
                final double maxTubeHeight = (containerHeight - rows * spacing) / rows;

                double tubeWidth = maxTubeWidth.clamp(0.0, 52.0);
                double tubeHeight = tubeWidth * aspectRatio;

                if (tubeHeight > maxTubeHeight) {
                  tubeHeight = maxTubeHeight.clamp(0.0, 166.0);
                  tubeWidth = tubeHeight / aspectRatio;
                }

                final List<List<int>> tubeRows = [];
                for (int r = 0; r < rows; r++) {
                  final start = r * maxPerRow;
                  final end = (start + maxPerRow).clamp(0, tubeCount);
                  tubeRows.add(List.generate(end - start, (i) => start + i));
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: tubeRows.map((rowIndices) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: spacing / 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: rowIndices.map((i) {
                          final isSource = state.pouringFromIndex == i;
                          final isTarget = state.pouringToIndex == i;
                          final pourToLeft = isSource &&
                              state.pouringToIndex != null &&
                              state.pouringToIndex! < i;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: spacing / 2),
                            child: TubeWidget(
                              tube: level.tubes[i],
                              isSelected: state.selectedTubeIndex == i,
                              isPouringSource: isSource,
                              isPouringTarget: isTarget,
                              pourToLeft: pourToLeft,
                              height: tubeHeight,
                              width: tubeWidth,
                              onTap: () => ref.read(gameViewModelProvider.notifier).selectTube(i),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.accent,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.headingWhite,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'BebasNeue',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.subtext,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1.0,
      height: 30,
      color: AppColors.gridLines,
    );
  }

  void _showCompleteDialog() {
    final state = ref.read(gameViewModelProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF181818),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFF222222),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.accent,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'LEVEL COMPLETE!',
                style: const TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingWhite,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.isRandomMode
                    ? 'You sorted this ${state.randomDifficulty} puzzle in ${state.moveCount} moves.'
                    : 'You sorted Level ${widget.levelNumber} in ${state.moveCount} moves.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TangibleButton(
                      text: 'Home',
                      isSecondary: true,
                      height: 50,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TangibleButton(
                      text: state.isRandomMode ? 'Play Again' : 'Next Level',
                      height: 50,
                      onPressed: () async {
                        final notifier = ref.read(gameViewModelProvider.notifier);
                        await notifier.completeLevel();
                        if (!mounted) return;
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (state.isRandomMode) {
                            notifier.loadRandomLevel(state.randomDifficulty ?? 'Easy');
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameView(levelNumber: widget.levelNumber + 1),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
