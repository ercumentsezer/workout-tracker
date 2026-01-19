import 'package:hive/hive.dart';
import 'workout_set.dart';

part 'exercise.g.dart';

@HiveType(typeId: 2)
class Exercise {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<WorkoutSet> sets;

  // USP: Machine Settings (We'll keep as String like JSON, so it's flexible)
  // Example: "Seat: 4, Angle: 110"
  @HiveField(3)
  final String? machineSettings; 

  @HiveField(4)
  final String? note; // Ekstra notlar

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    this.machineSettings,
    this.note,
  });
  
  // For adding new sets or updating settings
  Exercise copyWith({
    String? id,
    String? name,
    List<WorkoutSet>? sets,
    String? machineSettings,
    String? note,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      machineSettings: machineSettings ?? this.machineSettings,
      note: note ?? this.note,
    );
  }
}