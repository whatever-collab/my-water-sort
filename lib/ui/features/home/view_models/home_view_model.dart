import 'package:flutter/foundation.dart';
import 'package:watersort/data/repositories/progress_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final ProgressRepository _progressRepository;

  // Fixed: Parameter name no longer starts with underscore
  HomeViewModel({required ProgressRepository progressRepository})
      : _progressRepository = progressRepository;

  int get currentLevel => _progressRepository.currentLevel;
  int get highestLevel => _progressRepository.highestLevel;

  Future<void> incrementLevel() async {
    await _progressRepository.incrementLevel();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    await _progressRepository.resetProgress();
    notifyListeners();
  }
}
