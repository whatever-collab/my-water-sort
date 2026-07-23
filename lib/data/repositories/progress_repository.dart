import 'package:watersort/domain/models/user_progress.dart';
import '../services/hive_service.dart';

class ProgressRepository {
  // Fixed: Parameter name no longer starts with underscore
  ProgressRepository({required HiveService hiveService}) : _hiveService = hiveService;

  final HiveService _hiveService;
  UserProgress? _cachedProgress;

  Future<UserProgress> getProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;
    _cachedProgress = await _hiveService.getProgress();
    return _cachedProgress!;
  }

  Future<void> saveProgress(UserProgress progress) async {
    _cachedProgress = progress;
    await _hiveService.saveProgress(progress);
  }

  Future<void> completeLevel(int moves) async {
    final current = await getProgress();
    final updated = current.incrementLevel().addMoves(moves);
    await saveProgress(updated);
  }

  Future<void> addRandomLevelMoves(int moves) async {
    final current = await getProgress();
    final updated = current.addMoves(moves);
    await saveProgress(updated);
  }

  Future<void> resetProgress() async {
    _cachedProgress = null;
    await _hiveService.clearProgress();
  }
}
