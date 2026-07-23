import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:watersort/data/repositories/progress_repository.dart';
import 'package:watersort/domain/models/game_level.dart';
import 'package:watersort/domain/models/tube.dart';
import 'package:watersort/domain/use_cases/level_generator.dart';

@immutable
class MoveSnapshot {
  const MoveSnapshot({required this.tubes, required this.moveCount});
  final List<Tube> tubes;
  final int moveCount;
}

@immutable
class GameViewModelState {
  const GameViewModelState({
    this.level,
    this.isLoading = false,
    this.isComplete = false,
    this.selectedTubeIndex,
    this.pouringFromIndex,
    this.pouringToIndex,
    this.moveCount = 0,
    this.error,
    this.isRandomMode = false,
    this.randomDifficulty,
    this.randomSeed,
    this.moveHistory = const [],
    this.timeLeft,
    this.isTimeOut = false,
  });

  final GameLevel? level;
  final bool isLoading;
  final bool isComplete;
  final int? selectedTubeIndex;
  final int? pouringFromIndex;
  final int? pouringToIndex;
  final int moveCount;
  final String? error;
  final bool isRandomMode;
  final String? randomDifficulty;
  final int? randomSeed;
  final List<MoveSnapshot> moveHistory;
  final int? timeLeft;
  final bool isTimeOut;

  bool get canUndo => moveHistory.isNotEmpty && !isComplete && !isTimeOut;

  GameViewModelState copyWith({
    GameLevel? level,
    bool? isLoading,
    bool? isComplete,
    int? Function()? selectedTubeIndex,
    int? Function()? pouringFromIndex,
    int? Function()? pouringToIndex,
    int? moveCount,
    String? error,
    bool? isRandomMode,
    String? randomDifficulty,
    int? randomSeed,
    List<MoveSnapshot>? moveHistory,
    int? Function()? timeLeft,
    bool? isTimeOut,
  }) {
    return GameViewModelState(
      level: level ?? this.level,
      isLoading: isLoading ?? this.isLoading,
      isComplete: isComplete ?? this.isComplete,
      selectedTubeIndex:
          selectedTubeIndex != null ? selectedTubeIndex() : this.selectedTubeIndex,
      pouringFromIndex:
          pouringFromIndex != null ? pouringFromIndex() : this.pouringFromIndex,
      pouringToIndex:
          pouringToIndex != null ? pouringToIndex() : this.pouringToIndex,
      moveCount: moveCount ?? this.moveCount,
      error: error,
      isRandomMode: isRandomMode ?? this.isRandomMode,
      randomDifficulty: randomDifficulty ?? this.randomDifficulty,
      randomSeed: randomSeed ?? this.randomSeed,
      moveHistory: moveHistory ?? this.moveHistory,
      timeLeft: timeLeft != null ? timeLeft() : this.timeLeft,
      isTimeOut: isTimeOut ?? this.isTimeOut,
    );
  }
}

class GameViewModel extends StateNotifier<GameViewModelState> {
  // Fixed: Parameter names no longer start with underscores
  GameViewModel({
    required ProgressRepository progressRepository,
    required LevelGenerator levelGenerator,
  })  : _progressRepository = progressRepository,
        _levelGenerator = levelGenerator,
        super(const GameViewModelState());

  final ProgressRepository _progressRepository;
  final LevelGenerator _levelGenerator;

  Timer? _timer;

  bool _shouldHaveTimer({required bool isRandom, required int levelNumber, required String difficulty}) {
    if (isRandom) {
      return difficulty != 'Easy';
    } else {
      return levelNumber >= 4;
    }
  }

  int _calculateTimerDuration(int colorCount) {
    return ((30 + (colorCount * 15)) * 1.5).round();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    state = state.copyWith(timeLeft: () => seconds, isTimeOut: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft == null || state.timeLeft! <= 0) {
        timer.cancel();
        return;
      }
      final newTime = state.timeLeft! - 1;
      if (newTime == 0) {
        timer.cancel();
        state = state.copyWith(
          timeLeft: () => 0,
          isTimeOut: true,
        );
        HapticFeedback.heavyImpact();
      } else {
        state = state.copyWith(timeLeft: () => newTime);
      }
    });
  }

  Future<void> loadLevel(int levelNumber) async {
    _timer?.cancel();
    state = const GameViewModelState(isLoading: true);

    try {
      final level = _levelGenerator.generate(levelNumber);
      state = GameViewModelState(level: level);

      if (_shouldHaveTimer(isRandom: false, levelNumber: levelNumber, difficulty: '')) {
        _startTimer(_calculateTimerDuration(level.colorCount));
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load level: $e');
    }
  }

  Future<void> loadRandomLevel(String difficulty, {int? seed}) async {
    _timer?.cancel();
    final int levelSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    state = GameViewModelState(
      isLoading: true,
      isRandomMode: true,
      randomDifficulty: difficulty,
      randomSeed: levelSeed,
    );

    try {
      int colorCount = 3;
      if (difficulty == 'Medium') {
        colorCount = 6;
      } else if (difficulty == 'Hard') {
        colorCount = 9;
      } else if (difficulty == 'Super Hard') {
        colorCount = 12;
      } else if (difficulty == 'Super Duper Hard') {
        colorCount = 16;
      }

      final level = _levelGenerator.generateRandom(
        colorCount: colorCount,
        seed: levelSeed,
      );

      state = state.copyWith(
        level: level,
        isLoading: false,
      );
