import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class Plan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  int cycleLengthDays; // Default 7

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  bool isActive;

  Plan({
    required this.id,
    this.name,
    this.cycleLengthDays = 7,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Plan copyWith({
    String? id,
    String? name,
    int? cycleLengthDays,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

