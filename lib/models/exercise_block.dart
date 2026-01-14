import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class ExerciseBlock extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  int repsTarget;

  @HiveField(3)
  int setsTarget;

  @HiveField(4)
  int restSec;

  @HiveField(5)
  String? notes;

  ExerciseBlock({
    required this.id,
    required this.name,
    required this.repsTarget,
    required this.setsTarget,
    required this.restSec,
    this.notes,
  });

  ExerciseBlock copyWith({
    String? id,
    String? name,
    int? repsTarget,
    int? setsTarget,
    int? restSec,
    String? notes,
  }) {
    return ExerciseBlock(
      id: id ?? this.id,
      name: name ?? this.name,
      repsTarget: repsTarget ?? this.repsTarget,
      setsTarget: setsTarget ?? this.setsTarget,
      restSec: restSec ?? this.restSec,
      notes: notes ?? this.notes,
    );
  }
}

