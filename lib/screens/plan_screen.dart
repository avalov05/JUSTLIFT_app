import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/plan_provider.dart';
import '../models/plan_day_instance.dart';
import '../services/storage_service.dart';
import 'day_box_screen.dart';
import 'create_plan_screen.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reload plans when screen is built to ensure fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activePlanProvider.notifier).loadActivePlan();
      ref.read(planDayInstancesProvider.notifier).loadInstances();
    });
    
    final activePlan = ref.watch(activePlanProvider);
    final dayInstances = ref.watch(planDayInstancesProvider);

    if (activePlan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Plan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active plan'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreatePlanScreen()),
                  );
                },
                child: const Text('Start a plan'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePlan.name ?? 'Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Plan'),
                  content: const Text('Are you sure? Day blocks will be saved as templates.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(activePlanProvider.notifier).deletePlan(activePlan.id);
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: dayInstances.isEmpty
          ? const Center(child: Text('No days generated'))
          : ListView.builder(
              itemCount: dayInstances.length,
              itemBuilder: (context, index) {
                final instance = dayInstances[index];
                return _DayInstanceTile(instance: instance);
              },
            ),
    );
  }
}

class _DayInstanceTile extends ConsumerWidget {
  final PlanDayInstance instance;

  const _DayInstanceTile({required this.instance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayBlock = StorageService.dayBlocks.get(
      instance.overridden ? instance.overrideDayBlockId! : instance.dayBlockId,
    );

    final dateFormat = DateFormat('MMM d, yyyy');
    final isToday = instance.date.year == DateTime.now().year &&
        instance.date.month == DateTime.now().month &&
        instance.date.day == DateTime.now().day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isToday ? Theme.of(context).colorScheme.primaryContainer : null,
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          dateFormat.format(instance.date),
          style: TextStyle(
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: dayBlock == null
            ? const Text('Loading...')
            : dayBlock.isRestDay
                ? const Text('Rest day')
                : Text('${dayBlock.exercises.length} exercises'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (instance.isSkipped)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text('Skipped', style: TextStyle(color: Colors.grey)),
              )
            else
              TextButton(
                onPressed: () {
                  ref.read(planDayInstancesProvider.notifier).skipDay(instance.id);
                },
                child: const Text('Skip'),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DayBoxScreen(
                      dayInstance: instance,
                      dayBlock: dayBlock,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          if (dayBlock != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DayBoxScreen(
                  dayInstance: instance,
                  dayBlock: dayBlock,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

