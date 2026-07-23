import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/data/services/hive_service.dart';
import 'package:watersort/domain/services/level_generator.dart';
import 'package:watersort/ui/features/game/view_models/game_view_model.dart';
import 'package:watersort/ui/features/home/view_models/home_view_model.dart';

// Provider for Hive Service
final hiveServiceProvider = Provider<HiveService>((ref) {
  throw UnimplementedError('Inject HiveService at root');
});

// Provider for Progress Repository
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return ProgressRepository(hiveService: hiveService);
});

// Provider for Home View Model
final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  return HomeViewModel(progressRepository: progressRepository);
});

// Provider for Level Generator
final levelGeneratorProvider = Provider<LevelGenerator>((ref) {
  return LevelGenerator();
});

// Provider for Game View Model
final gameViewModelProvider = Provider<GameViewModel>((ref) {
  final progressRepository = ref.watch(progressRepositoryProvider);
  final levelGenerator = ref.watch(levelGeneratorProvider);
  
  return GameViewModel(
    progressRepository: progressRepository,
    levelGenerator: levelGenerator,
  );
});
