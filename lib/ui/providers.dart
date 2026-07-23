import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/data/services/hive_service.dart';
import 'package:watersort/domain/services/level_generator.dart';
import 'package:watersort/ui/features/game/view_models/game_view_model.dart';
import 'package:watersort/ui/features/home/view_models/home_view_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Inject HiveService at root');
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

// Use StateNotifierProvider for HomeViewModel so it has .notifier
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeViewState>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  return HomeViewModel(progressRepository: progressRepository);
});

final levelGeneratorProvider = Provider<LevelGenerator>((ref) {
  return LevelGenerator();
});

// Use StateNotifierProvider for GameViewModel
final gameViewModelProvider = StateNotifierProvider<GameViewModel, GameState>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final levelGenerator = ref.watch(levelGeneratorProvider);
  
  return GameViewModel(
    progressRepository: progressRepository,
    levelGenerator: levelGenerator,
  );
});
