import 'package:flutter/material.dart';
import '../models/workout_session.dart';

class WorkoutCompletionScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutCompletionScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final duration = session.endedAt != null && session.startedAt != null
        ? session.endedAt!.difference(session.startedAt!)
        : const Duration(seconds: 0);

    final exercisesCompleted = session.exercisesPerformed
        .map((log) => log.exerciseName)
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Complete')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Workout Complete!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            Text('Duration: ${_formatDuration(duration)}'),
            const SizedBox(height: 8),
            Text('Exercises: $exercisesCompleted'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

