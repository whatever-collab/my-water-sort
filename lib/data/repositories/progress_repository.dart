import 'package:watersort/data/services/hive_service.dart';

class ProgressRepository {
  final HiveService hiveService;

  // Changed: Removed underscore from parameter name, kept field private if needed or made public
  ProgressRepository({required this.hiveService});

  // If other parts of your code expect _hiveService, you might need to adjust them, 
  // but usually it's better to just make the field public or use getters.
  // For now, let's keep it simple and match the usage in providers.dart later.
}
