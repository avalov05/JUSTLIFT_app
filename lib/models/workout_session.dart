import 'package:hive/hive.dart';
import 'set_log.dart';

@HiveType(typeId: 6)
enum WorkoutStatus {
  @HiveField(0)
  notStarted,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  completed,
  @HiveField(3)
  abandoned,
}

@HiveType(typeId: 7)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String planId;

  @HiveField(3)
  final DateTime dayInstanceDate;

  @HiveField(4)
  DateTime? startedAt;

  @HiveField(5)
  DateTime? endedAt;

  @HiveField(6)
  WorkoutStatus status;

  @HiveField(7)
  List<SetLog> exercisesPerformed;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.planId,
    required this.dayInstanceDate,
    this.startedAt,
    this.endedAt,
    this.status = WorkoutStatus.notStarted,
    List<SetLog>? exercisesPerformed,
  }) : exercisesPerformed = exercisesPerformed ?? [];

  WorkoutSession copyWith({
    String? id,
    DateTime? date,
    String? planId,
    DateTime? dayInstanceDate,
    DateTime? startedAt,
    DateTime? endedAt,
    WorkoutStatus? status,
    List<SetLog>? exercisesPerformed,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      date: date ?? this.date,
      planId: planId ?? this.planId,
      dayInstanceDate: dayInstanceDate ?? this.dayInstanceDate,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      exercisesPerformed: exercisesPerformed ?? this.exercisesPerformed,
    );
  }
}

