import 'package:flutter/material.dart';
import '../models/exercise_block.dart';

class WorkoutExerciseScreen extends StatefulWidget {
  final ExerciseBlock exercise;
  final int setNumber;
  final int totalSets;
  final VoidCallback onCompleteSet;
  final VoidCallback onEndWorkout;

  const WorkoutExerciseScreen({
    super.key,
    required this.exercise,
    required this.setNumber,
    required this.totalSets,
    required this.onCompleteSet,
    required this.onEndWorkout,
  });

  @override
  State<WorkoutExerciseScreen> createState() => _WorkoutExerciseScreenState();
}

class _WorkoutExerciseScreenState extends State<WorkoutExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exercise name
            Text(
              widget.exercise.name,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Set info
            Text(
              'Set ${widget.setNumber} of ${widget.totalSets}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Reps target
            Text(
              '${widget.exercise.repsTarget} reps',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 48),
            // In-progress animation
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(
                          0.3 + (_animationController.value * 0.3),
                        ),
                  ),
                );
              },
            ),
            const Spacer(),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onEndWorkout,
                      child: const Text('End Workout'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onCompleteSet,
                      child: const Text('Complete Set'),
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

