import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../models/day_block.dart';

class WorkoutRestScreen extends StatefulWidget {
  final WorkoutSession session;
  final DayBlock dayBlock;
  final int currentExerciseIndex;
  final int currentSetIndex;
  final int? previousExerciseIndex;
  final VoidCallback onContinue;
  final VoidCallback onEndWorkout;

  const WorkoutRestScreen({
    super.key,
    required this.session,
    required this.dayBlock,
    required this.currentExerciseIndex,
    required this.currentSetIndex,
    this.previousExerciseIndex,
    required this.onContinue,
    required this.onEndWorkout,
  });

  @override
  State<WorkoutRestScreen> createState() => _WorkoutRestScreenState();
}

class _WorkoutRestScreenState extends State<WorkoutRestScreen> {
  int restSeconds = 60;
  Timer? _timer;
  int _elapsedSeconds = 0;
  int? _repsDone;
  int? _difficulty;

  @override
  void initState() {
    super.initState();
    if (widget.previousExerciseIndex != null) {
      final exercise = widget.dayBlock.exercises[widget.previousExerciseIndex!];
      restSeconds = exercise.restSec;
    } else if (widget.currentExerciseIndex > 0) {
      final exercise = widget.dayBlock.exercises[widget.currentExerciseIndex - 1];
      restSeconds = exercise.restSec;
    }
    _startTimer();
    _loadPreviousSet();
  }

  void _loadPreviousSet() {
    // Find the last set log for the previous exercise
    if (widget.previousExerciseIndex != null) {
      final exercise = widget.dayBlock.exercises[widget.previousExerciseIndex!];
      final setLogs = widget.session.exercisesPerformed
          .where((log) => log.exerciseName == exercise.name)
          .toList();
      if (setLogs.isNotEmpty) {
        final lastLog = setLogs.last;
        setState(() {
          _repsDone = lastLog.repsDone;
          _difficulty = lastLog.difficulty;
        });
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
          if (_elapsedSeconds >= restSeconds) {
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updatePreviousSet() {
    if (widget.previousExerciseIndex != null && _repsDone != null) {
      final exercise = widget.dayBlock.exercises[widget.previousExerciseIndex!];
      final setLogs = widget.session.exercisesPerformed
          .where((log) => log.exerciseName == exercise.name)
          .toList();
      if (setLogs.isNotEmpty) {
        final lastLog = setLogs.last;
        lastLog.repsDone = _repsDone!;
        if (_difficulty != null) {
          lastLog.difficulty = _difficulty;
        }
        lastLog.save();
      }
    }
  }

  void _endBreak() {
    _updatePreviousSet();
    _timer?.cancel();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final previousExercise = widget.previousExerciseIndex != null
        ? widget.dayBlock.exercises[widget.previousExerciseIndex!]
        : null;
    final nextExercise = widget.currentExerciseIndex < widget.dayBlock.exercises.length
        ? widget.dayBlock.exercises[widget.currentExerciseIndex]
        : null;

    // Calculate progress
    int totalSets = 0;
    int completedSets = 0;
    for (int i = 0; i < widget.dayBlock.exercises.length; i++) {
      final ex = widget.dayBlock.exercises[i];
      totalSets += ex.setsTarget;
      if (i < widget.currentExerciseIndex) {
        completedSets += ex.setsTarget;
      } else if (i == widget.currentExerciseIndex) {
        completedSets += widget.currentSetIndex;
      }
    }
    final progress = totalSets > 0 ? completedSets / totalSets : 0.0;

    final currentExercise = widget.dayBlock.exercises[widget.currentExerciseIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Previous and next exercise names
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      previousExercise?.name ?? '---',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      nextExercise?.name ?? '---',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text('${(progress * 100).toInt()}% complete'),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Set info
            Text(
              'Set ${widget.currentSetIndex + 1} of ${currentExercise.setsTarget}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            // Rest timer
            Text(
              '${restSeconds - _elapsedSeconds}s',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const Spacer(),
            // Previous exercise data
            if (previousExercise != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'Previous: ${previousExercise.name}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              _repsDone = (_repsDone ?? previousExercise.repsTarget) - 1;
                            });
                          },
                        ),
                        Text('${_repsDone ?? previousExercise.repsTarget} reps'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              _repsDone = (_repsDone ?? previousExercise.repsTarget) + 1;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Difficulty:'),
                    Slider(
                      value: (_difficulty ?? 5).toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _difficulty?.toString() ?? '5',
                      onChanged: (value) {
                        setState(() {
                          _difficulty = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onEndWorkout,
                          child: const Text('End Workout'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Skip next exercise - simplified for now
                            widget.onContinue();
                          },
                          child: const Text('Skip Next'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _endBreak,
                      child: const Text('End Break'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

