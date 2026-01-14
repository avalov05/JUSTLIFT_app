import 'package:hive/hive.dart';
import 'muscle_group.dart';
import 'exercise_block.dart';
import 'day_block.dart';
import 'plan.dart';
import 'plan_day_instance.dart';
import 'set_log.dart';
import 'workout_session.dart';

// Manual TypeAdapters (temporary until code generation is run)
class MuscleGroupAdapter extends TypeAdapter<MuscleGroup> {
  @override
  final int typeId = 0;

  @override
  MuscleGroup read(BinaryReader reader) {
    return MuscleGroup(
      id: reader.readString(),
      name: reader.readString(),
      regionKey: reader.readString(),
      level: reader.readInt(),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, MuscleGroup obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.regionKey);
    writer.writeInt(obj.level);
    writer.writeInt(obj.lastUpdated.millisecondsSinceEpoch);
  }
}

class ExerciseBlockAdapter extends TypeAdapter<ExerciseBlock> {
  @override
  final int typeId = 1;

  @override
  ExerciseBlock read(BinaryReader reader) {
    return ExerciseBlock(
      id: reader.readString(),
      name: reader.readString(),
      repsTarget: reader.readInt(),
      setsTarget: reader.readInt(),
      restSec: reader.readInt(),
      notes: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseBlock obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.repsTarget);
    writer.writeInt(obj.setsTarget);
    writer.writeInt(obj.restSec);
    writer.writeBool(obj.notes != null);
    if (obj.notes != null) writer.writeString(obj.notes!);
  }
}

class DayBlockAdapter extends TypeAdapter<DayBlock> {
  @override
  final int typeId = 2;

  @override
  DayBlock read(BinaryReader reader) {
    final id = reader.readString();
    final hasTitle = reader.readBool();
    final title = hasTitle ? reader.readString() : null;
    final isRestDay = reader.readBool();
    final exerciseCount = reader.readInt();
    final exercises = <ExerciseBlock>[];
    for (int i = 0; i < exerciseCount; i++) {
      exercises.add(ExerciseBlockAdapter().read(reader));
    }
    return DayBlock(
      id: id,
      title: title,
      isRestDay: isRestDay,
      exercises: exercises,
    );
  }

  @override
  void write(BinaryWriter writer, DayBlock obj) {
    writer.writeString(obj.id);
    writer.writeBool(obj.title != null);
    if (obj.title != null) writer.writeString(obj.title!);
    writer.writeBool(obj.isRestDay);
    writer.writeInt(obj.exercises.length);
    for (final exercise in obj.exercises) {
      ExerciseBlockAdapter().write(writer, exercise);
    }
  }
}

class PlanAdapter extends TypeAdapter<Plan> {
  @override
  final int typeId = 3;

  @override
  Plan read(BinaryReader reader) {
    final id = reader.readString();
    final hasName = reader.readBool();
    final name = hasName ? reader.readString() : null;
    final cycleLengthDays = reader.readInt();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final isActive = reader.readBool();
    return Plan(
      id: id,
      name: name,
      cycleLengthDays: cycleLengthDays,
      createdAt: createdAt,
      isActive: isActive,
    );
  }

  @override
  void write(BinaryWriter writer, Plan obj) {
    writer.writeString(obj.id);
    writer.writeBool(obj.name != null);
    if (obj.name != null) writer.writeString(obj.name!);
    writer.writeInt(obj.cycleLengthDays);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.isActive);
  }
}

class PlanDayInstanceAdapter extends TypeAdapter<PlanDayInstance> {
  @override
  final int typeId = 4;

  @override
  PlanDayInstance read(BinaryReader reader) {
    return PlanDayInstance(
      id: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      dayIndexInCycle: reader.readInt(),
      dayBlockId: reader.readString(),
      isSkipped: reader.readBool(),
      overridden: reader.readBool(),
      overrideDayBlockId: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, PlanDayInstance obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeInt(obj.dayIndexInCycle);
    writer.writeString(obj.dayBlockId);
    writer.writeBool(obj.isSkipped);
    writer.writeBool(obj.overridden);
    writer.writeBool(obj.overrideDayBlockId != null);
    if (obj.overrideDayBlockId != null) writer.writeString(obj.overrideDayBlockId!);
  }
}

class SetLogAdapter extends TypeAdapter<SetLog> {
  @override
  final int typeId = 5;

  @override
  SetLog read(BinaryReader reader) {
    return SetLog(
      id: reader.readString(),
      exerciseName: reader.readString(),
      setNumber: reader.readInt(),
      repsTarget: reader.readInt(),
      repsDone: reader.readInt(),
      difficulty: reader.readBool() ? reader.readInt() : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, SetLog obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.exerciseName);
    writer.writeInt(obj.setNumber);
    writer.writeInt(obj.repsTarget);
    writer.writeInt(obj.repsDone);
    writer.writeBool(obj.difficulty != null);
    if (obj.difficulty != null) writer.writeInt(obj.difficulty!);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}

class WorkoutStatusAdapter extends TypeAdapter<WorkoutStatus> {
  @override
  final int typeId = 6;

  @override
  WorkoutStatus read(BinaryReader reader) {
    return WorkoutStatus.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, WorkoutStatus obj) {
    writer.writeInt(obj.index);
  }
}

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 7;

  @override
  WorkoutSession read(BinaryReader reader) {
    final id = reader.readString();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final planId = reader.readString();
    final dayInstanceDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasStartedAt = reader.readBool();
    final startedAt = hasStartedAt ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    final hasEndedAt = reader.readBool();
    final endedAt = hasEndedAt ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null;
    final status = WorkoutStatus.values[reader.readInt()];
    final setLogCount = reader.readInt();
    final exercisesPerformed = <SetLog>[];
    for (int i = 0; i < setLogCount; i++) {
      exercisesPerformed.add(SetLogAdapter().read(reader));
    }
    return WorkoutSession(
      id: id,
      date: date,
      planId: planId,
      dayInstanceDate: dayInstanceDate,
      startedAt: startedAt,
      endedAt: endedAt,
      status: status,
      exercisesPerformed: exercisesPerformed,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.planId);
    writer.writeInt(obj.dayInstanceDate.millisecondsSinceEpoch);
    writer.writeBool(obj.startedAt != null);
    if (obj.startedAt != null) writer.writeInt(obj.startedAt!.millisecondsSinceEpoch);
    writer.writeBool(obj.endedAt != null);
    if (obj.endedAt != null) writer.writeInt(obj.endedAt!.millisecondsSinceEpoch);
    writer.writeInt(obj.status.index);
    writer.writeInt(obj.exercisesPerformed.length);
    for (final log in obj.exercisesPerformed) {
      SetLogAdapter().write(writer, log);
    }
  }
}

