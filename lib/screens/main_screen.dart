import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/muscle_provider.dart';
import '../providers/plan_provider.dart';
import '../providers/workout_provider.dart';
import '../models/muscle_group.dart';
import '../models/plan_day_instance.dart';
import '../models/day_block.dart';
import '../models/workout_session.dart';
import '../services/storage_service.dart';
import '../services/sample_data_service.dart';
import '../models/set_log.dart';
import 'workout_review_screen.dart';
import 'workout_exercise_screen.dart';
import 'workout_rest_screen.dart';
import 'workout_completion_screen.dart';
import 'plan_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muscleGroups = ref.watch(muscleGroupsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Levels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Settings dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('Male/Female Model'),
                        subtitle: const Text('Coming later'),
                        enabled: false,
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Reset Sample Data'),
                        onTap: () async {
                          Navigator.pop(context);
                          await SampleDataService.resetAll();
                          if (context.mounted) {
                            ref.read(muscleGroupsProvider.notifier).loadMuscleGroups();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Data reset')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Body Model Area
          Expanded(
            child: Center(
              child: _BodyModelView(muscleGroups: muscleGroups),
            ),
          ),
          // Start Workout Button
          _WorkoutButton(),
          // Legend
          _MuscleLevelLegend(),
        ],
      ),
    );
  }
}

class _BodyModelView extends StatelessWidget {
  final List<MuscleGroup> muscleGroups;

  const _BodyModelView({required this.muscleGroups});

  @override
  Widget build(BuildContext context) {
    // Simple 2D body model with tappable regions
    // This is a placeholder - can be replaced with SVG later
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Body outline
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _BodyPainter(muscleGroups: muscleGroups),
            ),
            // Tappable regions
            ...muscleGroups.map((muscle) => _MuscleRegion(
              muscle: muscle,
              constraints: constraints,
            )),
          ],
        );
      },
    );
  }
}

class _MuscleRegion extends StatelessWidget {
  final MuscleGroup muscle;
  final BoxConstraints constraints;

  const _MuscleRegion({
    required this.muscle,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate position based on regionKey
    final position = _getMusclePosition(muscle.regionKey, constraints);
    
    return Positioned(
      left: position['x'],
      top: position['y'],
      width: position['width'],
      height: position['height'],
      child: GestureDetector(
        onTap: () {
          _showMuscleInfo(context, muscle);
        },
        child: Container(
          decoration: BoxDecoration(
            color: _getMuscleColor(muscle.level).withOpacity(0.3),
            border: Border.all(
              color: _getMuscleColor(muscle.level),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Map<String, double> _getMusclePosition(String regionKey, BoxConstraints constraints) {
    // Simple positioning - can be enhanced with actual body model coordinates
    final positions = {
      'chest': {'x': constraints.maxWidth * 0.3, 'y': constraints.maxHeight * 0.2, 'width': constraints.maxWidth * 0.4, 'height': constraints.maxHeight * 0.15},
      'back': {'x': constraints.maxWidth * 0.3, 'y': constraints.maxHeight * 0.2, 'width': constraints.maxWidth * 0.4, 'height': constraints.maxHeight * 0.15},
      'shoulders': {'x': constraints.maxWidth * 0.25, 'y': constraints.maxHeight * 0.15, 'width': constraints.maxWidth * 0.5, 'height': constraints.maxHeight * 0.1},
      'biceps': {'x': constraints.maxWidth * 0.2, 'y': constraints.maxHeight * 0.3, 'width': constraints.maxWidth * 0.15, 'height': constraints.maxHeight * 0.2},
      'triceps': {'x': constraints.maxWidth * 0.65, 'y': constraints.maxHeight * 0.3, 'width': constraints.maxWidth * 0.15, 'height': constraints.maxHeight * 0.2},
      'abs': {'x': constraints.maxWidth * 0.35, 'y': constraints.maxHeight * 0.35, 'width': constraints.maxWidth * 0.3, 'height': constraints.maxHeight * 0.15},
      'legs': {'x': constraints.maxWidth * 0.3, 'y': constraints.maxHeight * 0.5, 'width': constraints.maxWidth * 0.4, 'height': constraints.maxHeight * 0.4},
    };
    return positions[regionKey] ?? {'x': 0.0, 'y': 0.0, 'width': 0.0, 'height': 0.0};
  }

  Color _getMuscleColor(int level) {
    // Color gradient from low (red) to high (green)
    if (level < 33) return Colors.red;
    if (level < 66) return Colors.orange;
    return Colors.green;
  }

  void _showMuscleInfo(BuildContext context, MuscleGroup muscle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(muscle.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Level: ${muscle.level}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: muscle.level / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getMuscleColor(muscle.level)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  final List<MuscleGroup> muscleGroups;

  _BodyPainter({required this.muscleGroups});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Simple body outline
    final path = Path();
    // Head
    path.addOval(Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.1),
      width: size.width * 0.2,
      height: size.height * 0.15,
    ));
    // Torso
    path.addRect(Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.3,
    ));
    // Legs
    path.addRect(Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.5,
      size.width * 0.15,
      size.height * 0.4,
    ));
    path.addRect(Rect.fromLTWH(
      size.width * 0.5,
      size.height * 0.5,
      size.width * 0.15,
      size.height * 0.4,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MuscleLevelLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LegendItem(color: Colors.red, label: 'Low'),
          _LegendItem(color: Colors.orange, label: 'Medium'),
          _LegendItem(color: Colors.green, label: 'High'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _WorkoutButton extends ConsumerWidget {
  const _WorkoutButton();

  Future<void> _startTodayWorkout(
    BuildContext context,
    WidgetRef ref,
    dynamic activePlan,
    PlanDayInstance todayInstance,
    DayBlock todayDayBlock,
  ) async {
    final today = DateTime.now();
    
    // Check if workout already in progress
    final currentWorkout = ref.read(currentWorkoutProvider);
    if (currentWorkout != null && currentWorkout.status == WorkoutStatus.inProgress) {
      // Navigate to active workout
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _WorkoutFlowScreen(
            session: currentWorkout,
            dayBlock: todayDayBlock,
          ),
        ),
      );
      return;
    }

    // Create session and go to review
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: today,
      planId: activePlan.id,
      dayInstanceDate: todayInstance.date,
    );
    StorageService.workoutSessions.put(session.id, session);
    
    final shouldStart = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutReviewScreen(
          session: session,
          dayBlock: todayDayBlock,
        ),
      ),
    );

    if (shouldStart == true && context.mounted) {
      ref.read(currentWorkoutProvider.notifier).startWorkout(session);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _WorkoutFlowScreen(
              session: session,
              dayBlock: todayDayBlock,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlan = ref.watch(activePlanProvider);
    final dayInstances = ref.watch(planDayInstancesProvider);

    if (activePlan == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: OutlinedButton.icon(
          onPressed: () {
            // Navigate to plan screen to create a plan
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlanScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Create a Plan to Start'),
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
      return const SizedBox.shrink();
    }

    final todayDayBlock = StorageService.dayBlocks.get(
      todayInstance.overridden ? todayInstance.overrideDayBlockId! : todayInstance.dayBlockId,
    );

    if (todayDayBlock == null || todayDayBlock.isRestDay) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _startTodayWorkout(context, ref, activePlan, todayInstance, todayDayBlock),
        icon: const Icon(Icons.fitness_center),
        label: const Text('Start Workout'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
      repsDone: exercise.repsTarget,
    );
    ref.read(currentWorkoutProvider.notifier).addSetLog(setLog);

    setState(() {
      currentSetIndex++;
      if (currentSetIndex >= exercise.setsTarget) {
        if (currentExerciseIndex < widget.dayBlock.exercises.length - 1) {
          currentExerciseIndex++;
          currentSetIndex = 0;
          isResting = true;
        } else {
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

