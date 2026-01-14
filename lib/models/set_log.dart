import 'package:hive/hive.dart';

@HiveType(typeId: 5)
class SetLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exerciseName;

  @HiveField(2)
  final int setNumber;

  @HiveField(3)
  final int repsTarget;

  @HiveField(4)
  int repsDone;

  @HiveField(5)
  int? difficulty; // 1-10 or RPE

  @HiveField(6)
  final DateTime timestamp;

  SetLog({
    required this.id,
    required this.exerciseName,
    required this.setNumber,
    required this.repsTarget,
    required this.repsDone,
    this.difficulty,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  SetLog copyWith({
    String? id,
    String? exerciseName,
    int? setNumber,
    int? repsTarget,
    int? repsDone,
    int? difficulty,
    DateTime? timestamp,
  }) {
    return SetLog(
      id: id ?? this.id,
      exerciseName: exerciseName ?? this.exerciseName,
      setNumber: setNumber ?? this.setNumber,
      repsTarget: repsTarget ?? this.repsTarget,
      repsDone: repsDone ?? this.repsDone,
      difficulty: difficulty ?? this.difficulty,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

