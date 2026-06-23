import 'dart:math';

import 'package:flutter/material.dart';

import 'package:watersort/domain/models/game_level.dart';
import 'package:watersort/domain/models/tube.dart';
import 'package:watersort/ui/core/theme/app_colors.dart';

class LevelGenerator {
  static const int _baseColors = 3;
  static const int _maxColors = 12;

  GameLevel generate(int levelNumber) {
    final random = Random(levelNumber);
    final colorCount = _getColorCount(levelNumber);
    final tubeCount = _getTubeCount(levelNumber);
    const capacity = 4;

    final colors = _pickColors(colorCount, random);

    final tubes = _generatePuzzle(
      colorCount: colorCount,
      tubeCount: tubeCount,
      capacity: capacity,
      colors: colors,
      random: random,
    );

    return GameLevel(
      levelNumber: levelNumber,
      tubes: tubes,
    );
  }

  GameLevel generateRandom({required int colorCount, required int seed}) {
    final random = Random(seed);
    final tubeCount = colorCount + 2;
    const capacity = 4;

    final colors = _pickColors(colorCount, random);

    final tubes = _generatePuzzle(
      colorCount: colorCount,
      tubeCount: tubeCount,
      capacity: capacity,
      colors: colors,
      random: random,
    );

    return GameLevel(
      levelNumber: -1, // Special flag for random free play levels
      tubes: tubes,
    );
  }

  int _getColorCount(int level) {
    final count = _baseColors + (level - 1) ~/ 5;
    return count.clamp(_baseColors, _maxColors);
  }

  int _getTubeCount(int level) {
    final colorCount = _getColorCount(level);
    return colorCount + 2;
  }

  List<Color> _pickColors(int count, Random random) {
    final indices = List.generate(AppColors.waterColors.length, (i) => i)
      ..shuffle(random);
    return indices.take(count).map((i) => AppColors.waterColors[i]).toList();
  }

  List<Tube> _generatePuzzle({
    required int colorCount,
    required int tubeCount,
    required int capacity,
    required List<Color> colors,
    required Random random,
  }) {
    final colorSegments = <Color>[];
    for (final color in colors) {
      for (int i = 0; i < capacity; i++) {
        colorSegments.add(color);
      }
    }
    colorSegments.shuffle(random);

    final tubeColors = List.generate(
      tubeCount,
      (index) => <Color>[],
    );

    int segmentIndex = 0;
    for (int i = 0; i < tubeCount - 2; i++) {
      for (int j = 0; j < capacity; j++) {
        if (segmentIndex < colorSegments.length) {
          tubeColors[i].add(colorSegments[segmentIndex]);
          segmentIndex++;
        }
      }
    }

    return tubeColors
        .map((colors) => Tube(colors: colors, capacity: capacity))
        .toList();
  }
}
