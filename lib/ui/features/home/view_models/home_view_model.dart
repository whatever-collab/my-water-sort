import 'package:flutter/foundation.dart';
import 'package:watersort/data/repositories/progress_repository.dart';

// Define the state class
class HomeViewState {
  final bool isLoading;
  final dynamic progress; // Placeholder for whatever progress object was used
  
  HomeViewState({this.isLoading = false, this.progress});
}

class HomeViewModel extends StateNotifier<HomeViewState> {
  final ProgressRepository _progressRepository;

  HomeViewModel({required ProgressRepository progressRepository})
      : _progressRepository = progressRepository,
        super(HomeViewState());

  Future<void> loadProgress() async {
    state = HomeViewState(isLoading: true);
    // Simulate loading or fetch real data
    // For now, just set a dummy progress or null
    state = HomeViewState(isLoading: false, progress: null);
  }
}
