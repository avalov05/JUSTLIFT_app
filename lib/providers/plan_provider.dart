import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan.dart';
import '../models/plan_day_instance.dart';
import '../models/day_block.dart';
import '../services/storage_service.dart';

final activePlanProvider = StateNotifierProvider<ActivePlanNotifier, Plan?>((ref) {
  return ActivePlanNotifier();
});

final planDayInstancesProvider = StateNotifierProvider<PlanDayInstancesNotifier, List<PlanDayInstance>>((ref) {
  return PlanDayInstancesNotifier();
});

final dayBlocksProvider = StateNotifierProvider<DayBlocksNotifier, List<DayBlock>>((ref) {
  return DayBlocksNotifier();
});

class ActivePlanNotifier extends StateNotifier<Plan?> {
  ActivePlanNotifier() : super(null) {
    loadActivePlan();
  }

  void loadActivePlan() {
    final activePlans = StorageService.plans.values.where((p) => p.isActive).toList();
    state = activePlans.isNotEmpty ? activePlans.first : null;
  }

  void setActivePlan(Plan plan) {
    // Deactivate all plans
    for (final p in StorageService.plans.values) {
      if (p.isActive) {
        p.isActive = false;
        StorageService.plans.put(p.id, p);
      }
    }
    plan.isActive = true;
    StorageService.plans.put(plan.id, plan);
    state = plan;
  }

  void createPlan(Plan plan) {
    StorageService.plans.put(plan.id, plan);
    setActivePlan(plan);
  }

  void deletePlan(String planId) {
    if (state?.id == planId) {
      state = null;
    }
    StorageService.plans.delete(planId);
    // Delete associated day instances
    final instances = StorageService.planDayInstances.values
        .where((i) => i.id.contains(planId))
        .toList();
    for (final instance in instances) {
      StorageService.planDayInstances.delete(instance.id);
    }
  }
}

class PlanDayInstancesNotifier extends StateNotifier<List<PlanDayInstance>> {
  PlanDayInstancesNotifier() : super([]) {
    loadInstances();
  }

  void loadInstances() {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    state = StorageService.planDayInstances.values
        .where((i) => i.date.isAfter(startOfToday.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void generateInstances(Plan plan, List<DayBlock> cycleBlocks) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final instances = <PlanDayInstance>[];
    
    for (int i = 0; i < 30; i++) {
      final date = startDate.add(Duration(days: i));
      final dayIndex = i % plan.cycleLengthDays;
      final dayBlock = cycleBlocks[dayIndex];
      
      final instance = PlanDayInstance(
        id: '${plan.id}_${date.millisecondsSinceEpoch}',
        date: date,
        dayIndexInCycle: dayIndex,
        dayBlockId: dayBlock.id,
      );
      StorageService.planDayInstances.put(instance.id, instance);
      instances.add(instance);
    }
    
    loadInstances();
  }

  void skipDay(String instanceId) {
    final instance = StorageService.planDayInstances.get(instanceId);
    if (instance != null) {
      instance.isSkipped = true;
      instance.save();
      
      // Shift all future instances forward by 1 day
      final futureInstances = state
          .where((i) => i.date.isAfter(instance.date) && !i.isSkipped)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      
      for (final futureInstance in futureInstances) {
        final newDate = futureInstance.date.add(const Duration(days: 1));
        final plan = StorageService.plans.values.where((p) => p.isActive).firstOrNull;
        if (plan != null) {
          final newId = '${plan.id}_${newDate.millisecondsSinceEpoch}';
          final updatedInstance = futureInstance.copyWith(
            id: newId,
            date: newDate,
          );
          // Delete old and save new
          StorageService.planDayInstances.delete(futureInstance.id);
          updatedInstance.save();
        }
      }
      
      // Add one more instance at the end
      final lastDate = state.isNotEmpty 
          ? state.map((i) => i.date).reduce((a, b) => a.isAfter(b) ? a : b)
          : instance.date;
      final plan = StorageService.plans.values.where((p) => p.isActive).firstOrNull;
      if (plan != null) {
        // Get cycle blocks by finding instances with matching dayIndexInCycle
        final cycleBlocks = <DayBlock>[];
        for (int i = 0; i < plan.cycleLengthDays; i++) {
          final sampleInstance = state.firstWhere(
            (inst) => inst.dayIndexInCycle == i && !inst.overridden && !inst.isSkipped,
            orElse: () => PlanDayInstance(
              id: '',
              date: DateTime.now(),
              dayIndexInCycle: i,
              dayBlockId: '',
            ),
          );
          if (sampleInstance.id.isNotEmpty) {
            final block = StorageService.dayBlocks.get(sampleInstance.dayBlockId);
            if (block != null) {
              cycleBlocks.add(block);
            }
          }
        }
        if (cycleBlocks.isNotEmpty) {
          final newDayIndex = (state.length) % plan.cycleLengthDays;
          final newDayBlock = cycleBlocks[newDayIndex % cycleBlocks.length];
          final newInstance = PlanDayInstance(
            id: '${plan.id}_${lastDate.add(const Duration(days: 1)).millisecondsSinceEpoch}',
            date: lastDate.add(const Duration(days: 1)),
            dayIndexInCycle: newDayIndex,
            dayBlockId: newDayBlock.id,
          );
          newInstance.save();
        }
      }
      
      loadInstances();
    }
  }

  void overrideDay(String instanceId, DayBlock overrideBlock) {
    final instance = StorageService.planDayInstances.get(instanceId);
    if (instance != null) {
      overrideBlock.save();
      instance.overridden = true;
      instance.overrideDayBlockId = overrideBlock.id;
      instance.save();
      loadInstances();
    }
  }
}

class DayBlocksNotifier extends StateNotifier<List<DayBlock>> {
  DayBlocksNotifier() : super([]) {
    loadDayBlocks();
  }

  void loadDayBlocks() {
    state = StorageService.dayBlocks.values.toList();
  }

  void addDayBlock(DayBlock dayBlock) {
    dayBlock.save();
    loadDayBlocks();
  }

  void updateDayBlock(DayBlock dayBlock) {
    dayBlock.save();
    loadDayBlocks();
  }

  void deleteDayBlock(String id) {
    StorageService.dayBlocks.delete(id);
    loadDayBlocks();
  }
}

