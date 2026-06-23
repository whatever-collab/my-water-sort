import 'package:flutter/material.dart';

import 'tube.dart';

@immutable
class GameLevel {
  const GameLevel({
    required this.levelNumber,
    required this.tubes,
    this.totalMoves = 0,
  });

  final int levelNumber;
  final List<Tube> tubes;
  final int totalMoves;

  int get colorCount =>
      tubes.expand((t) => t.colors).toSet().length;

  int get tubeCount => tubes.length;

  bool get isComplete => tubes.every((t) => t.isSolved || t.isEmpty);

  GameLevel copyWith({
    int? levelNumber,
    List<Tube>? tubes,
    int? totalMoves,
  }) {
    return GameLevel(
      levelNumber: levelNumber ?? this.levelNumber,
      tubes: tubes ?? this.tubes,
      totalMoves: totalMoves ?? this.totalMoves,
    );
  }
}
