import 'package:hive/hive.dart';
import 'exercise.dart'; 

part 'workout_history.g.dart';

@HiveType(typeId: 3) 
class WorkoutHistory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date; 
  @HiveField(2)
  final List<Exercise> exercises; 

  WorkoutHistory({
    required this.id,
    required this.date,
    required this.exercises,
  });
}