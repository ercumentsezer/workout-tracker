import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../data/models/exercise.dart';
import '../data/models/workout_set.dart';
import '../data/models/workout_history.dart';

final workoutProvider = StateNotifierProvider<WorkoutNotifier, List<Exercise>>((ref) {
  return WorkoutNotifier();
});

class WorkoutNotifier extends StateNotifier<List<Exercise>> {
  WorkoutNotifier() : super([]);

  // --- START WORKOUT (LOAD FROM ROUTINE) ---
  void loadRoutine(List<Exercise> routineExercises) {
    // Copy with new IDs to avoid reference issues
    state = routineExercises.map((e) => Exercise(
      id: const Uuid().v4(),
      name: e.name,
      machineSettings: e.machineSettings,
      sets: e.sets.map((s) => WorkoutSet(
        id: const Uuid().v4(),
        weight: null,
        reps: null,
        isCompleted: false,
      )).toList(),
    )).toList();
  }

  // --- LOAD FROM HISTORY (FOR EDITING) ---
  void loadFromHistory(List<Exercise> historyExercises) {
    // Load history data as-is (preserving IDs)
    state = historyExercises.map((e) => Exercise(
      id: e.id,
      name: e.name,
      machineSettings: e.machineSettings,
      sets: e.sets.map((s) => WorkoutSet(
        id: s.id,
        weight: s.weight,
        reps: s.reps,
        isCompleted: s.isCompleted,
      )).toList(),
    )).toList();
  }

  // --- CLEAR SCREEN ---
  void clear() {
    state = [];
  }

  // --- ADD NEW EXERCISE ---
  void createExercise(String name) {
    final newExercise = Exercise(
      id: const Uuid().v4(),
      name: name,
      sets: [
        WorkoutSet(id: const Uuid().v4(), weight: null, reps: null),
        WorkoutSet(id: const Uuid().v4(), weight: null, reps: null),
        WorkoutSet(id: const Uuid().v4(), weight: null, reps: null),
      ],
    );
    state = [...state, newExercise];
  }

  // --- DELETE EXERCISE ---
  void deleteExercise(String exerciseId) {
    state = state.where((e) => e.id != exerciseId).toList();
  }

  // --- ADD SET ---
  void addSet(String exerciseId) {
    state = state.map((exercise) {
      if (exercise.id == exerciseId) {
        return exercise.copyWith(
          sets: [...exercise.sets, WorkoutSet(id: const Uuid().v4(), weight: null, reps: null)],
        );
      }
      return exercise;
    }).toList();
  }

  // --- DELETE SET ---
  void deleteSet(String exerciseId, String setId) {
    state = state.map((exercise) {
      if (exercise.id == exerciseId) {
        return exercise.copyWith(
          sets: exercise.sets.where((s) => s.id != setId).toList(),
        );
      }
      return exercise;
    }).toList();
  }

  // --- UPDATE SET (WEIGHT / REPS / STATUS) ---
  void updateSet(String exerciseId, String setId, {double? weight, int? reps, bool? isCompleted}) {
    state = state.map((exercise) {
      if (exercise.id == exerciseId) {
        final newSets = exercise.sets.map((set) {
          if (set.id == setId) {
            return set.copyWith(
              weight: weight ?? set.weight,
              reps: reps ?? set.reps,
              isCompleted: isCompleted ?? set.isCompleted,
            );
          }
          return set;
        }).toList();
        return exercise.copyWith(sets: newSets);
      }
      return exercise;
    }).toList();
  }

  // --- UPDATE MACHINE SETTINGS ---
  void updateMachineSettings(String exerciseId, String settings) {
    state = state.map((exercise) {
      if (exercise.id == exerciseId) {
        return exercise.copyWith(machineSettings: settings);
      }
      return exercise;
    }).toList();
  }

  // --- UPDATE NAME ---
  void editExerciseName(String exerciseId, String newName) {
    state = state.map((exercise) {
      if (exercise.id == exerciseId) {
        return exercise.copyWith(name: newName);
      }
      return exercise;
    }).toList();
  }

  // --- FINISH WORKOUT AND SAVE ---
  void finishWorkout() {
    final box = Hive.box<WorkoutHistory>('history');
    
    // Clean up empty sets
    final cleanExercises = state.map((e) {
      final validSets = e.sets.where((s) => s.weight != null || s.reps != null).toList();
      return e.copyWith(sets: validSets);
    }).where((e) => e.sets.isNotEmpty).toList();

    if (cleanExercises.isNotEmpty) {
      final history = WorkoutHistory(
        id: const Uuid().v4(),
        date: DateTime.now(),
        exercises: cleanExercises,
      );
      box.put(history.id, history);
    }

    // Reset state for a fresh start (not just an empty list)
    state = [];
  }
}