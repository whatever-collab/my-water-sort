import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/domain/models/user_progress.dart';

class HomeViewModelState {
  const HomeViewModelState({
    this.progress,
    this.isLoading = false,
  });

  final UserProgress? progress;
  final bool isLoading;

  HomeViewModelState copyWith({
    UserProgress? progress,
    bool? isLoading,
  }) {
    return HomeViewModelState(
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeViewModelState> {
  // Fixed: Parameter name no longer starts with underscore
  HomeViewModel({required ProgressRepository progressRepository})
      : _progressRepository = progressRepository,
        super(const HomeViewModelState());

  final ProgressRepository _progressRepository;

  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true);
    try {
      final progress = await _progressRepository.getProgress();
      state = state.copyWith(progress: progress, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> resetProgress() async {
    await _progressRepository.resetProgress();
    state = const HomeViewModelState(progress: UserProgress());
  }
}
