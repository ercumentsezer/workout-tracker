import 'package:hive/hive.dart';
import 'exercise.dart';

part 'workout_routine.g.dart';

@HiveType(typeId: 4) 
class WorkoutRoutine {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<Exercise> exercises;

  WorkoutRoutine({
    required this.id,
    required this.name,
    required this.exercises,
  });
}