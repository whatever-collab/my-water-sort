import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/data/services/hive_service.dart';
import 'package:watersort/domain/use_cases/level_generator.dart';
import 'package:watersort/ui/features/game/view_models/game_view_model.dart';
import 'package:watersort/ui/features/home/view_models/home_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  // Fixed: Passes argument correctly now that constructor accepts 'hiveService'
  return ProgressRepository(hiveService: hiveService);
});

final levelGeneratorProvider = Provider<LevelGenerator>((ref) {
  return LevelGenerator();
});

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, HomeViewModelState>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  // Fixed: Passes argument correctly now that constructor accepts 'progressRepository'
  return HomeViewModel(progressRepository: progressRepository);
});

final gameViewModelProvider =
    StateNotifierProvider.autoDispose<GameViewModel, GameViewModelState>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final levelGenerator = ref.watch(levelGeneratorProvider);
  // Fixed: Passes arguments correctly now that constructor accepts these names
  return GameViewModel(
    progressRepository: progressRepository,
    levelGenerator: levelGenerator,
  );
});
