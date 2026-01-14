import 'package:flutter/material.dart';
import '../models/exercise_block.dart';

class ExerciseSetupScreen extends StatefulWidget {
  final ExerciseBlock? exercise;

  const ExerciseSetupScreen({super.key, this.exercise});

  @override
  State<ExerciseSetupScreen> createState() => _ExerciseSetupScreenState();
}

class _ExerciseSetupScreenState extends State<ExerciseSetupScreen> {
  late TextEditingController nameController;
  late TextEditingController repsController;
  late TextEditingController setsController;
  late TextEditingController restController;
  bool isRestDay = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.exercise?.name ?? '');
    repsController = TextEditingController(text: widget.exercise?.repsTarget.toString() ?? '10');
    setsController = TextEditingController(text: widget.exercise?.setsTarget.toString() ?? '3');
    restController = TextEditingController(text: widget.exercise?.restSec.toString() ?? '60');
  }

  @override
  void dispose() {
    nameController.dispose();
    repsController.dispose();
    setsController.dispose();
    restController.dispose();
    super.dispose();
  }

  void _save() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter exercise name')),
      );
      return;
    }

    final exercise = ExerciseBlock(
      id: widget.exercise?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text,
      repsTarget: int.tryParse(repsController.text) ?? 10,
      setsTarget: int.tryParse(setsController.text) ?? 3,
      restSec: int.tryParse(restController.text) ?? 60,
    );

    Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Exercise name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: repsController,
            decoration: const InputDecoration(
              labelText: 'Reps',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: setsController,
            decoration: const InputDecoration(
              labelText: 'Sets',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: restController,
            decoration: const InputDecoration(
              labelText: 'Rest (seconds)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

