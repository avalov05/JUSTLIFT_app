import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_session.dart';
import '../models/set_log.dart';
import '../services/storage_service.dart';

final currentWorkoutProvider = StateNotifierProvider<CurrentWorkoutNotifier, WorkoutSession?>((ref) {
  return CurrentWorkoutNotifier();
});

final workoutSessionsProvider = StateNotifierProvider<WorkoutSessionsNotifier, List<WorkoutSession>>((ref) {
  return WorkoutSessionsNotifier();
});

class CurrentWorkoutNotifier extends StateNotifier<WorkoutSession?> {
  CurrentWorkoutNotifier() : super(null) {
    loadCurrentWorkout();
  }

  void loadCurrentWorkout() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final session = StorageService.workoutSessions.values.firstWhere(
      (s) => s.date.isAfter(todayStart) && s.date.isBefore(todayEnd) && s.status == WorkoutStatus.inProgress,
      orElse: () => WorkoutSession(
        id: '',
        date: today,
        planId: '',
        dayInstanceDate: today,
      ),
    );
    
    if (session.id.isNotEmpty) {
      state = session;
    }
  }

  void startWorkout(WorkoutSession session) {
    session.startedAt = DateTime.now();
    session.status = WorkoutStatus.inProgress;
    session.save();
    state = session;
  }

  void addSetLog(SetLog setLog) {
    if (state != null) {
      setLog.save();
      state!.exercisesPerformed.add(setLog);
      state!.save();
      state = state; // Trigger rebuild
    }
  }

  void completeWorkout() {
    if (state != null) {
      state!.endedAt = DateTime.now();
      state!.status = WorkoutStatus.completed;
      state!.save();
      state = null;
    }
  }

  void abandonWorkout() {
    if (state != null) {
      state!.endedAt = DateTime.now();
      state!.status = WorkoutStatus.abandoned;
      state!.save();
      state = null;
    }
  }
}

class WorkoutSessionsNotifier extends StateNotifier<List<WorkoutSession>> {
  WorkoutSessionsNotifier() : super([]) {
    loadSessions();
  }

  void loadSessions() {
    state = StorageService.workoutSessions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void addSession(WorkoutSession session) {
    session.save();
    loadSessions();
  }
}

