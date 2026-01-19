import 'package:hive/hive.dart';

// This file will be auto-generated (Don't worry if there's an error, we'll fix it soon)
part 'workout_set.g.dart';

@HiveType(typeId: 1) // Unique ID
class WorkoutSet {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double? weight; // Weight (Can be empty)

  @HiveField(2)
  final int? reps; // Repetitions

  @HiveField(3)
  final bool isCompleted; // Completed?

  WorkoutSet({
    required this.id,
    this.weight,
    this.reps,
    this.isCompleted = false,
  });

  // Copy method (Important for immutability)
  WorkoutSet copyWith({
    String? id,
    double? weight,
    int? reps,
    bool? isCompleted,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}