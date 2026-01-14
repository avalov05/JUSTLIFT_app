import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_provider.dart';
import '../providers/plan_provider.dart';
import '../models/workout_session.dart';
import '../models/plan_day_instance.dart';
import '../models/day_block.dart';
import '../models/set_log.dart';
import '../services/storage_service.dart';
import 'workout_review_screen.dart';
import 'workout_exercise_screen.dart';
import 'workout_rest_screen.dart';
import 'workout_completion_screen.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWorkout = ref.watch(currentWorkoutProvider);
    final activePlan = ref.watch(activePlanProvider);
    final dayInstances = ref.watch(planDayInstancesProvider);

    if (activePlan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active plan'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to plan screen
                },
                child: const Text('Start a plan'),
              ),
            ],
          ),
        ),
      );
    }

    // Find today's workout
    final today = DateTime.now();
    final todayInstance = dayInstances.firstWhere(
      (i) => i.date.year == today.year &&
          i.date.month == today.month &&
          i.date.day == today.day,
      orElse: () => PlanDayInstance(
        id: '',
        date: today,
        dayIndexInCycle: 0,
        dayBlockId: '',
      ),
    );

    if (todayInstance.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('No workout scheduled for today')),
      );
    }

    final dayBlock = StorageService.dayBlocks.get(
      todayInstance.overridden ? todayInstance.overrideDayBlockId! : todayInstance.dayBlockId,
    );

    if (dayBlock == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('Loading...')),
      );
    }

    if (dayBlock.isRestDay) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('Rest day')),
      );
    }

    // If workout in progress, show current screen
    if (currentWorkout != null && currentWorkout.status == WorkoutStatus.inProgress) {
      return _WorkoutFlowScreen(session: currentWorkout, dayBlock: dayBlock);
    }

    // Show start screen
    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Today\'s Workout',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('${dayBlock.exercises.length} exercises'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // Create session and go to review
                final session = WorkoutSession(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: today,
                  planId: activePlan.id,
                  dayInstanceDate: todayInstance.date,
                );
                session.save();
                
                final shouldStart = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutReviewScreen(
                      session: session,
                      dayBlock: dayBlock,
                    ),
                  ),
                );

                if (shouldStart == true) {
                  ref.read(currentWorkoutProvider.notifier).startWorkout(session);
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _WorkoutFlowScreen(
                          session: session,
                          dayBlock: dayBlock,
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Start Workout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutFlowScreen extends ConsumerStatefulWidget {
  final WorkoutSession session;
  final DayBlock dayBlock;

  const _WorkoutFlowScreen({
    required this.session,
    required this.dayBlock,
  });

  @override
  ConsumerState<_WorkoutFlowScreen> createState() => _WorkoutFlowScreenState();
}

class _WorkoutFlowScreenState extends ConsumerState<_WorkoutFlowScreen> {
  int currentExerciseIndex = 0;
  int currentSetIndex = 0;
  bool isResting = false;

  @override
  void initState() {
    super.initState();
    // Determine current position from session
    final completedSets = widget.session.exercisesPerformed.length;
    int totalSets = 0;
    for (int i = 0; i < widget.dayBlock.exercises.length; i++) {
      final exercise = widget.dayBlock.exercises[i];
      totalSets += exercise.setsTarget;
      if (completedSets < totalSets) {
        currentExerciseIndex = i;
        currentSetIndex = completedSets - (totalSets - exercise.setsTarget);
        break;
      }
    }
  }

  void _completeSet() {
    final exercise = widget.dayBlock.exercises[currentExerciseIndex];
    final setLog = SetLog(
      id: '${widget.session.id}_${DateTime.now().millisecondsSinceEpoch}',
      exerciseName: exercise.name,
      setNumber: currentSetIndex + 1,
      repsTarget: exercise.repsTarget,
      repsDone: exercise.repsTarget, // Default, can be edited in rest screen
    );
    ref.read(currentWorkoutProvider.notifier).addSetLog(setLog);

    setState(() {
      currentSetIndex++;
      if (currentSetIndex >= exercise.setsTarget) {
        // Move to next exercise or finish
        if (currentExerciseIndex < widget.dayBlock.exercises.length - 1) {
          currentExerciseIndex++;
          currentSetIndex = 0;
          isResting = true;
        } else {
          // Workout complete
          ref.read(currentWorkoutProvider.notifier).completeWorkout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutCompletionScreen(session: widget.session),
            ),
          );
          return;
        }
      } else {
        isResting = true;
      }
    });

    if (isResting && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutRestScreen(
            session: widget.session,
            dayBlock: widget.dayBlock,
            currentExerciseIndex: currentExerciseIndex,
            currentSetIndex: currentSetIndex,
            previousExerciseIndex: currentExerciseIndex > 0 ? currentExerciseIndex - 1 : null,
            onContinue: () {
              setState(() {
                isResting = false;
              });
              Navigator.pop(context);
            },
            onEndWorkout: () {
              ref.read(currentWorkoutProvider.notifier).abandonWorkout();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isResting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final exercise = widget.dayBlock.exercises[currentExerciseIndex];
    
    return WorkoutExerciseScreen(
      exercise: exercise,
      setNumber: currentSetIndex + 1,
      totalSets: exercise.setsTarget,
      onCompleteSet: _completeSet,
      onEndWorkout: () {
        ref.read(currentWorkoutProvider.notifier).abandonWorkout();
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    );
  }
}

