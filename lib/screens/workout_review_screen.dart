import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../models/day_block.dart';

class WorkoutReviewScreen extends StatelessWidget {
  final WorkoutSession session;
  final DayBlock dayBlock;

  const WorkoutReviewScreen({
    super.key,
    required this.session,
    required this.dayBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Column(
        children: [
          // AI Suggestions placeholder
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Suggestions (coming later)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('No suggestions at this time.'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text('Decline'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          // Workout summary
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Workout Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text('Exercises: ${dayBlock.exercises.length}'),
                const SizedBox(height: 8),
                ...dayBlock.exercises.map((exercise) => ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.setsTarget} sets × ${exercise.repsTarget} reps',
                      ),
                    )),
              ],
            ),
          ),
          // Start button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Start Workout'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

