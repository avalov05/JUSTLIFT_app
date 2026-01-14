import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class PlanDayInstance extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int dayIndexInCycle; // 0 to cycleLength-1

  @HiveField(3)
  String dayBlockId; // Reference to DayBlock

  @HiveField(4)
  bool isSkipped;

  @HiveField(5)
  bool overridden; // If true, uses a custom DayBlock copy

  @HiveField(6)
  String? overrideDayBlockId; // Custom DayBlock if overridden

  PlanDayInstance({
    required this.id,
    required this.date,
    required this.dayIndexInCycle,
    required this.dayBlockId,
    this.isSkipped = false,
    this.overridden = false,
    this.overrideDayBlockId,
  });

  PlanDayInstance copyWith({
    String? id,
    DateTime? date,
    int? dayIndexInCycle,
    String? dayBlockId,
    bool? isSkipped,
    bool? overridden,
    String? overrideDayBlockId,
  }) {
    return PlanDayInstance(
      id: id ?? this.id,
      date: date ?? this.date,
      dayIndexInCycle: dayIndexInCycle ?? this.dayIndexInCycle,
      dayBlockId: dayBlockId ?? this.dayBlockId,
      isSkipped: isSkipped ?? this.isSkipped,
      overridden: overridden ?? this.overridden,
      overrideDayBlockId: overrideDayBlockId ?? this.overrideDayBlockId,
    );
  }
}

