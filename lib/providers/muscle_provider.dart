import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/muscle_group.dart';
import '../services/storage_service.dart';

final muscleGroupsProvider = StateNotifierProvider<MuscleGroupsNotifier, List<MuscleGroup>>((ref) {
  return MuscleGroupsNotifier();
});

class MuscleGroupsNotifier extends StateNotifier<List<MuscleGroup>> {
  MuscleGroupsNotifier() : super([]) {
    loadMuscleGroups();
  }

  void loadMuscleGroups() {
    state = StorageService.muscleGroups.values.toList();
  }

  void updateMuscleLevel(String id, int level) {
    final muscle = StorageService.muscleGroups.get(id);
    if (muscle != null) {
      muscle.level = level;
      muscle.lastUpdated = DateTime.now();
      muscle.save();
      loadMuscleGroups();
    }
  }

  MuscleGroup? getMuscleByRegionKey(String regionKey) {
    return state.firstWhere(
      (m) => m.regionKey == regionKey,
      orElse: () => MuscleGroup(id: '', name: '', regionKey: ''),
    );
  }
}

