import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/models/workout_history.dart';
import '../data/models/exercise.dart'; // <-- Exercise model added

final historyProvider = StateNotifierProvider<HistoryNotifier, List<WorkoutHistory>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<WorkoutHistory>> {
  final Box<WorkoutHistory> _box = Hive.box<WorkoutHistory>('history');

  HistoryNotifier() : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    // Sort history in reverse order (newest first)
    state = _box.values.toList().reversed.toList();
  }

  // --- DELETE WORKOUT ---
  void deleteWorkout(String historyId) {
    final keyToDelete = _box.keys.firstWhere(
      (k) => _box.get(k)?.id == historyId, 
      orElse: () => null
    );

    if (keyToDelete != null) {
      _box.delete(keyToDelete);
      _loadHistory(); // Refresh list
    }
  }

  // --- UPDATE WORKOUT ---
  void updateWorkout(String historyId, List<Exercise> newExercises) {
    // 1. Find the relevant record in the box
    final keyToUpdate = _box.keys.firstWhere(
      (k) => _box.get(k)?.id == historyId, 
      orElse: () => null
    );

    if (keyToUpdate != null) {
      final oldHistory = _box.get(keyToUpdate)!;
      
      // 2. Create object with new data
      // NOTE: durationInSeconds is not here because we removed it from the model
      final updatedHistory = WorkoutHistory(
        id: oldHistory.id,
        date: oldHistory.date,
        exercises: newExercises,
      );

      // 3. Save and refresh list
      _box.put(keyToUpdate, updatedHistory);
      _loadHistory();
    }
  }
  
  void refresh() {
    _loadHistory();
  }
}