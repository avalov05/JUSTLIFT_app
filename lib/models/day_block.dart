import 'package:hive/hive.dart';
import 'exercise_block.dart';

@HiveType(typeId: 2)
class DayBlock extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  List<ExerciseBlock> exercises;

  @HiveField(3)
  bool isRestDay;

  DayBlock({
    required this.id,
    this.title,
    List<ExerciseBlock>? exercises,
    this.isRestDay = false,
  }) : exercises = exercises ?? [];

  DayBlock copyWith({
    String? id,
    String? title,
    List<ExerciseBlock>? exercises,
    bool? isRestDay,
  }) {
    return DayBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      exercises: exercises ?? this.exercises,
      isRestDay: isRestDay ?? this.isRestDay,
    );
  }
}

