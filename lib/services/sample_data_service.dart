import '../models/muscle_group.dart';
import '../models/day_block.dart';
import '../models/exercise_block.dart';
import '../services/storage_service.dart';

class SampleDataService {
  static Future<void> seedIfNeeded() async {
    // Check if data already exists
    if (StorageService.muscleGroups.isNotEmpty) {
      return;
    }

    // Seed muscle groups
    final muscleGroups = [
      MuscleGroup(id: 'chest', name: 'Chest', regionKey: 'chest', level: 45),
      MuscleGroup(id: 'back', name: 'Back', regionKey: 'back', level: 50),
      MuscleGroup(id: 'shoulders', name: 'Shoulders', regionKey: 'shoulders', level: 40),
      MuscleGroup(id: 'biceps', name: 'Biceps', regionKey: 'biceps', level: 35),
      MuscleGroup(id: 'triceps', name: 'Triceps', regionKey: 'triceps', level: 38),
      MuscleGroup(id: 'abs', name: 'Abs', regionKey: 'abs', level: 42),
      MuscleGroup(id: 'legs', name: 'Legs', regionKey: 'legs', level: 48),
    ];

    for (final muscle in muscleGroups) {
      await StorageService.muscleGroups.put(muscle.id, muscle);
    }

    // Seed sample day blocks (lego pieces)
    final pushDay = DayBlock(
      id: 'sample_push',
      title: 'Push Day',
      exercises: [
        ExerciseBlock(
          id: 'bench_press',
          name: 'Bench Press',
          repsTarget: 8,
          setsTarget: 4,
          restSec: 120,
        ),
        ExerciseBlock(
          id: 'shoulder_press',
          name: 'Shoulder Press',
          repsTarget: 10,
          setsTarget: 3,
          restSec: 90,
        ),
        ExerciseBlock(
          id: 'tricep_dips',
          name: 'Tricep Dips',
          repsTarget: 12,
          setsTarget: 3,
          restSec: 60,
        ),
      ],
    );

    final pullDay = DayBlock(
      id: 'sample_pull',
      title: 'Pull Day',
      exercises: [
        ExerciseBlock(
          id: 'deadlift',
          name: 'Deadlift',
          repsTarget: 5,
          setsTarget: 5,
          restSec: 180,
        ),
        ExerciseBlock(
          id: 'pull_ups',
          name: 'Pull Ups',
          repsTarget: 8,
          setsTarget: 3,
          restSec: 90,
        ),
        ExerciseBlock(
          id: 'barbell_rows',
          name: 'Barbell Rows',
          repsTarget: 10,
          setsTarget: 3,
          restSec: 90,
        ),
      ],
    );

    final legDay = DayBlock(
      id: 'sample_legs',
      title: 'Leg Day',
      exercises: [
        ExerciseBlock(
          id: 'squats',
          name: 'Squats',
          repsTarget: 10,
          setsTarget: 4,
          restSec: 120,
        ),
        ExerciseBlock(
          id: 'leg_press',
          name: 'Leg Press',
          repsTarget: 12,
          setsTarget: 3,
          restSec: 90,
        ),
        ExerciseBlock(
          id: 'calf_raises',
          name: 'Calf Raises',
          repsTarget: 15,
          setsTarget: 3,
          restSec: 60,
        ),
      ],
    );

    final restDay = DayBlock(
      id: 'sample_rest',
      title: 'Rest Day',
      isRestDay: true,
      exercises: [],
    );

    await StorageService.dayBlocks.put(pushDay.id, pushDay);
    await StorageService.dayBlocks.put(pullDay.id, pullDay);
    await StorageService.dayBlocks.put(legDay.id, legDay);
    await StorageService.dayBlocks.put(restDay.id, restDay);
  }

  static Future<void> resetAll() async {
    await StorageService.clearAll();
    await seedIfNeeded();
  }
}

