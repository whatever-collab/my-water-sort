import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:watersort/ui/core/theme/app_colors.dart';
import 'package:watersort/ui/core/widgets/tangible_button.dart';
import 'package:watersort/ui/features/game/views/game_view.dart';
import 'package:watersort/ui/features/how_to_play/views/how_to_play_view.dart';
import 'package:watersort/ui/features/level_select/views/level_select_view.dart';
import 'package:watersort/ui/providers.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeViewModelProvider.notifier).loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Tactile Glass Droplet Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF18181E),
                  border: Border.all(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.water_drop_rounded,
                      size: 52,
                      color: AppColors.accent,
                    ),
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Game Title
              const Text(
                'WATER SORT',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingWhite,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'A COZY COLOR SORTING GAME',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.subtext,
                  letterSpacing: 1.2,
                ),
              ),

              const Spacer(flex: 2),

              // Single line Level Panel (Pill style)
              if (state.progress != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    'Level ${state.progress!.currentLevel}',
                    style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ] else ...[
                const Spacer(flex: 5),
              ],

              // Play Button (Primary CTA)
              TangibleButton(
                text: state.progress == null || state.progress!.currentLevel <= 1 ? 'Start Game' : 'Continue',
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameView(levelNumber: state.progress?.currentLevel ?? 1),
                          ),
                        );
                        ref.read(homeViewModelProvider.notifier).loadProgress();
                      },
              ),

              const SizedBox(height: 12),

              // Level Select Button
              TangibleButton(
                text: 'Select Level',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LevelSelectView(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Random Puzzle Button
              TangibleButton(
                text: 'Random Puzzle',
                isSecondary: true,
                onPressed: () => _showDifficultyDialog(context),
              ),

              const SizedBox(height: 12),

              // How to Play Button (Secondary Button)
              TangibleButton(
                text: 'How to Play',
                isSecondary: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HowToPlayView(),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
              const Text(
                'CHOOSE DIFFICULTY',
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.headingWhite,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Play a dynamically generated water sort puzzle.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext,
                ),
              ),
              const SizedBox(height: 24),
              TangibleButton(
                text: 'Easy (3 Colors)',
                isSecondary: true,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameView(
                        levelNumber: 0,
                        isRandom: true,
                        randomDifficulty: 'Easy',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TangibleButton(
                text: 'Medium (6 Colors)',
                isSecondary: true,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameView(
                        levelNumber: 0,
                        isRandom: true,
                        randomDifficulty: 'Medium',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TangibleButton(
                text: 'Hard (9 Colors)',
                isSecondary: true,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameView(
                        levelNumber: 0,
                        isRandom: true,
                        randomDifficulty: 'Hard',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TangibleButton(
                text: 'Super Hard (12 Colors)',
                isSecondary: true,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameView(
                        levelNumber: 0,
                        isRandom: true,
                        randomDifficulty: 'Super Hard',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    fontFamily: 'BebasNeue',
                    color: AppColors.subtext,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
