import 'package:watersort/data/services/hive_service.dart';

class ProgressRepository {
  final HiveService hiveService;

  ProgressRepository({required this.hiveService});

  int get currentLevel => hiveService.getCurrentLevel();
  int get highestLevel => hiveService.getHighestLevel();

  Future<void> incrementLevel() async {
    await hiveService.setCurrentLevel(currentLevel + 1);
    if (currentLevel > highestLevel) {
      await hiveService.setHighestLevel(currentLevel);
    }
  }

  Future<void> resetProgress() async {
    await hiveService.resetData();
  }
}
