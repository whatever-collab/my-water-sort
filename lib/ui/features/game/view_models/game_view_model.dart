import 'package:flutter/foundation.dart';
import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/domain/models/tube.dart';
import 'package:watersort/domain/services/level_generator.dart';

class GameViewModel extends ChangeNotifier {
  final ProgressRepository _progressRepository;
  final LevelGenerator _levelGenerator;

  List<Tube> tubes = [];
  int currentLevel = 1;
  bool isWon = false;

  // Fixed: Parameter names no longer start with underscores
  GameViewModel({
    required ProgressRepository progressRepository,
    required LevelGenerator levelGenerator,
  })  : _progressRepository = progressRepository,
        _levelGenerator = levelGenerator;

  void loadLevel(int level) {
    currentLevel = level;
    tubes = _levelGenerator.generateLevel(level);
    isWon = false;
    notifyListeners();
  }

  void resetLevel() {
    loadLevel(currentLevel);
  }

  void nextLevel() async {
    await _progressRepository.incrementLevel();
    loadLevel(currentLevel + 1);
  }

  void pour(Tube source, Tube target) {
    if (source.isEmpty || target.isFull) return;

    final colorToPour = source.topColor!;
    if (target.topColor != null && target.topColor != colorToPour) return;

    final amountToPour = _calculateAmountToPour(source, target, colorToPour);
    if (amountToPour == 0) return;

    for (int i = 0; i < amountToPour; i++) {
      source.removeTop();
      target.add(colorToPour);
    }

    notifyListeners();
    _checkWinCondition();
  }

  int _calculateAmountToPour(Tube source, Tube target, Color color) {
    int count = 0;
    for (final c in source.colors.reversed) {
      if (c == color) {
        count++;
      } else {
        break;
      }
    }
    return count > (target.capacity - target.colors.length)
        ? (target.capacity - target.colors.length)
        : count;
  }

  void _checkWinCondition() {
    isWon = tubes.every((tube) => tube.isComplete);
    if (isWon) {
      // Optional: Add win logic here
    }
  }
}
