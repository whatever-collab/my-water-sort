import 'package:flutter/material.dart';

@immutable
class Tube {
  const Tube({
    required this.colors,
    this.capacity = 4,
  });

  final List<Color> colors;
  final int capacity;

  bool get isFull => colors.length >= capacity;
  bool get isEmpty => colors.isEmpty;
  bool get isSolved => colors.length == capacity && _allSameColor;

  bool get _allSameColor {
    if (colors.isEmpty) return true;
    final first = colors.first;
    return colors.every((c) => c == first);
  }

  Color? get topColor => isEmpty ? null : colors.last;

  bool canReceive(Color color) {
    if (isFull) return false;
    if (isEmpty) return true;
    return topColor == color;
  }

  Tube copyWith({List<Color>? colors, int? capacity}) {
    return Tube(
      colors: colors ?? this.colors,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tube &&
          runtimeType == other.runtimeType &&
          _listEquals(colors, other.colors) &&
          capacity == other.capacity;

  @override
  int get hashCode => Object.hash(Object.hashAll(colors), capacity);

  bool _listEquals(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
