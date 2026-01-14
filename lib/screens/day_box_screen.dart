import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/day_block.dart';
import '../models/exercise_block.dart';
import '../models/plan_day_instance.dart';
import '../providers/plan_provider.dart';
import '../services/storage_service.dart';
import 'exercise_setup_screen.dart';

class DayBoxScreen extends ConsumerStatefulWidget {
  final DayBlock? dayBlock;
  final PlanDayInstance? dayInstance;
  final bool isCreating;

  const DayBoxScreen({
    super.key,
    this.dayBlock,
    this.dayInstance,
    this.isCreating = false,
  });

  static Widget createForPlanCreation({
    required DayBlock dayBlock,
  }) {
    return DayBoxScreen(dayBlock: dayBlock, isCreating: true);
  }

  @override
  ConsumerState<DayBoxScreen> createState() => _DayBoxScreenState();
}

class _DayBoxScreenState extends ConsumerState<DayBoxScreen> {
  late DayBlock currentDayBlock;

  @override
  void initState() {
    super.initState();
    if (widget.dayBlock != null) {
      currentDayBlock = widget.dayBlock!.copyWith(
        exercises: List.from(widget.dayBlock!.exercises),
      );
    } else {
      currentDayBlock = DayBlock(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        exercises: [],
      );
    }
  }

  Future<void> _addExercise() async {
    final result = await Navigator.push<ExerciseBlock>(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseSetupScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        currentDayBlock.exercises.add(result);
      });
      _autoSave();
    }
  }

  void _toggleRestDay() {
    setState(() {
      currentDayBlock = currentDayBlock.copyWith(
        isRestDay: !currentDayBlock.isRestDay,
        exercises: currentDayBlock.isRestDay ? currentDayBlock.exercises : [],
      );
    });
    _autoSave();
  }

  void _deleteExercise(int index) {
    setState(() {
      currentDayBlock.exercises.removeAt(index);
    });
    _autoSave();
  }

  void _autoSave() {
    if (widget.isCreating) {
      // For plan creation, just update the local copy - will be saved when plan is finished
      // But we can save to a temporary storage for recovery
      StorageService.dayBlocks.put(currentDayBlock.id, currentDayBlock);
      return;
    }

    // Save immediately for existing day blocks
    if (widget.dayInstance == null) {
      // Standalone day block
      StorageService.dayBlocks.put(currentDayBlock.id, currentDayBlock);
      ref.read(dayBlocksProvider.notifier).loadDayBlocks();
    } else {
      // Part of a plan - save as override if we're editing
      StorageService.dayBlocks.put(currentDayBlock.id, currentDayBlock);
    }
  }

  void _saveDayBlock() {
    if (widget.isCreating) {
      Navigator.pop(context, currentDayBlock);
      return;
    }

    if (widget.dayInstance == null) {
      StorageService.dayBlocks.put(currentDayBlock.id, currentDayBlock);
      ref.read(dayBlocksProvider.notifier).loadDayBlocks();
      Navigator.pop(context);
      return;
    }

    // Ask if just this day or all next days
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply changes'),
        content: const Text('Apply to:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveJustThisDay();
            },
            child: const Text('Just this day'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveAllNextDays();
            },
            child: const Text('This and all next days'),
          ),
        ],
      ),
    );
  }

  void _saveJustThisDay() {
    // Create override block
    final overrideBlock = currentDayBlock.copyWith(
      id: '${widget.dayInstance!.id}_override',
    );
    StorageService.dayBlocks.put(overrideBlock.id, overrideBlock);
    
    ref.read(planDayInstancesProvider.notifier).overrideDay(
      widget.dayInstance!.id,
      overrideBlock,
    );
    
    Navigator.pop(context);
  }

  void _saveAllNextDays() {
    // Update the underlying day block
    final originalBlock = StorageService.dayBlocks.get(widget.dayInstance!.dayBlockId);
    if (originalBlock != null) {
      final updatedBlock = originalBlock.copyWith(
        exercises: currentDayBlock.exercises,
        isRestDay: currentDayBlock.isRestDay,
      );
      StorageService.dayBlocks.put(updatedBlock.id, updatedBlock);
      
      // Update all future instances with the same dayIndexInCycle
      final dayIndex = widget.dayInstance!.dayIndexInCycle;
      final instances = ref.read(planDayInstancesProvider);
      for (final inst in instances) {
        if (inst.dayIndexInCycle == dayIndex && 
            inst.date.isAfter(widget.dayInstance!.date) &&
            !inst.overridden) {
          // Update to use the updated block
          inst.dayBlockId = updatedBlock.id;
          inst.save();
        }
      }
      ref.read(planDayInstancesProvider.notifier).loadInstances();
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dayBlock?.title ?? 'Day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveDayBlock,
          ),
        ],
      ),
      body: currentDayBlock.isRestDay
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Rest day', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _toggleRestDay,
                    child: const Text('Remove rest day'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Toggle rest day button
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: OutlinedButton.icon(
                    onPressed: _toggleRestDay,
                    icon: const Icon(Icons.bedtime),
                    label: const Text('Mark as rest day'),
                  ),
                ),
                const Divider(),
                // Exercises list
                Expanded(
                  child: currentDayBlock.exercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No exercises'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _addExercise,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Exercise'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: currentDayBlock.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = currentDayBlock.exercises[index];
                            return ListTile(
                              title: Text(exercise.name),
                              subtitle: Text(
                                '${exercise.setsTarget} sets × ${exercise.repsTarget} reps',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteExercise(index),
                              ),
                              onTap: () async {
                                final result = await Navigator.push<ExerciseBlock>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExerciseSetupScreen(
                                      exercise: exercise,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {
                                    currentDayBlock.exercises[index] = result;
                                  });
                                  _autoSave();
                                }
                              },
                            );
                          },
                        ),
                ),
                // Add exercise button
                if (currentDayBlock.exercises.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addExercise,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Exercise'),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

