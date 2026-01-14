import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class MuscleGroup extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String regionKey; // For tapping/highlighting on body model

  @HiveField(3)
  int level; // 0-100 placeholder

  @HiveField(4)
  DateTime lastUpdated;

  MuscleGroup({
    required this.id,
    required this.name,
    required this.regionKey,
    this.level = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  MuscleGroup copyWith({
    String? id,
    String? name,
    String? regionKey,
    int? level,
    DateTime? lastUpdated,
  }) {
    return MuscleGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      regionKey: regionKey ?? this.regionKey,
      level: level ?? this.level,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

