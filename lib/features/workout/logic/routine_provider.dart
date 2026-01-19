import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../data/models/workout_routine.dart';
import '../data/models/exercise.dart';

final routineProvider = StateNotifierProvider<RoutineNotifier, List<WorkoutRoutine>>((ref) {
  return RoutineNotifier();
});

class RoutineNotifier extends StateNotifier<List<WorkoutRoutine>> {
  final Box<WorkoutRoutine> _box = Hive.box<WorkoutRoutine>('routines');

  RoutineNotifier() : super([]) {
    // Load registered routines initially
    state = _box.values.toList();
  }

  // --- CREATE NEW ROUTINE (E.g.: "Push A") ---
  void createRoutine(String name, List<Exercise> exercises) {
    final newRoutine = WorkoutRoutine(
      id: const Uuid().v4(),
      name: name,
      exercises: exercises, 
    );
    _box.put(newRoutine.id, newRoutine);
    state = [...state, newRoutine];
  }

  // --- UPDATE ROUTINE (When exercises inside change) ---
  void updateRoutineExercises(String routineId, List<Exercise> exercises) {
    final routine = state.firstWhere((r) => r.id == routineId);
    final updatedRoutine = WorkoutRoutine(
      id: routine.id, 
      name: routine.name, 
      exercises: exercises
    );
    _box.put(routineId, updatedRoutine);
    state = [
      for (final r in state) if (r.id == routineId) updatedRoutine else r
    ];
  }

  // --- delete routine ---
  void deleteRoutine(String id) {
    _box.delete(id);
    state = state.where((r) => r.id != id).toList();
  }

  void updateRoutine(String id, String name, List<Exercise> exercises) {
    // 1. Find the old record
    final routineIndex = state.indexWhere((r) => r.id == id);
    if (routineIndex == -1) return;

    // 2. Update with new data (ID should stay the same!)
    final updatedRoutine = WorkoutRoutine(
      id: id, 
      name: name,
      exercises: exercises,
    );

    // 3. Write to database and State
    _box.put(id, updatedRoutine);
    
    // Update list
    state = [
      for (final routine in state)
        if (routine.id == id) updatedRoutine else routine
    ];
  }
}