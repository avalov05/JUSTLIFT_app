import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/plan_provider.dart';
import '../models/plan.dart';
import '../models/day_block.dart';
import '../services/storage_service.dart';
import 'day_box_screen.dart';

class CreatePlanScreen extends ConsumerStatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  ConsumerState<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends ConsumerState<CreatePlanScreen> {
  int cycleLength = 7;
  final List<DayBlock> cycleBlocks = [];
  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    // Initialize empty day blocks
    for (int i = 0; i < cycleLength; i++) {
      cycleBlocks.add(DayBlock(
        id: 'temp_$i',
        title: 'Day ${i + 1}',
        exercises: [],
      ));
    }
  }

  void _updateCycleLength(int newLength) {
    setState(() {
      if (newLength > cycleLength) {
        // Add new empty days
        for (int i = cycleLength; i < newLength; i++) {
          cycleBlocks.add(DayBlock(
            id: 'temp_$i',
            title: 'Day ${i + 1}',
            exercises: [],
          ));
        }
      } else if (newLength < cycleLength) {
        // Remove excess days
        cycleBlocks.removeRange(newLength, cycleLength);
      }
      cycleLength = newLength;
    });
  }

  Future<void> _editDay(int index) async {
    final result = await Navigator.push<DayBlock>(
      context,
      MaterialPageRoute(
        builder: (context) => DayBoxScreen.createForPlanCreation(
          dayBlock: cycleBlocks[index],
        ),
      ),
    );
    
    if (result != null) {
      setState(() {
        cycleBlocks[index] = result;
      });
      // Auto-save the day block being edited
      StorageService.dayBlocks.put(result.id, result);
    }
  }

  void _finishCreatingPlan() {
    if (isCreating) return;
    
    setState(() => isCreating = true);
    
    // Create plan
    final plan = Plan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cycleLengthDays: cycleLength,
    );
    
    // Save day blocks with proper IDs
    final savedDayBlocks = <DayBlock>[];
    for (int i = 0; i < cycleBlocks.length; i++) {
      final dayBlock = cycleBlocks[i].copyWith(
        id: '${plan.id}_day_$i',
      );
      // Add to box first, then save
      StorageService.dayBlocks.put(dayBlock.id, dayBlock);
      savedDayBlocks.add(dayBlock);
    }
    
    // Create plan
    ref.read(activePlanProvider.notifier).createPlan(plan);
    
    // Generate instances
    ref.read(planDayInstancesProvider.notifier).generateInstances(plan, savedDayBlocks);
    
    // Ensure plan is set as active and saved
    ref.read(activePlanProvider.notifier).loadActivePlan();
    
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Plan')),
      body: Column(
        children: [
          // Cycle length selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Cycle length (days): '),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: cycleLength.toDouble(),
                    min: 3,
                    max: 14,
                    divisions: 11,
                    label: cycleLength.toString(),
                    onChanged: (value) {
                      _updateCycleLength(value.toInt());
                    },
                  ),
                ),
                Text(cycleLength.toString()),
              ],
            ),
          ),
          const Divider(),
          // Day blocks list
          Expanded(
            child: ListView.builder(
              itemCount: cycleBlocks.length,
              itemBuilder: (context, index) {
                final dayBlock = cycleBlocks[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(dayBlock.title ?? 'Day ${index + 1}'),
                    subtitle: dayBlock.isRestDay
                        ? const Text('Rest day')
                        : Text('${dayBlock.exercises.length} exercises'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _editDay(index),
                  ),
                );
              },
            ),
          ),
          // Finish button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCreating ? null : _finishCreatingPlan,
                child: const Text('Finish Creating Plan'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

