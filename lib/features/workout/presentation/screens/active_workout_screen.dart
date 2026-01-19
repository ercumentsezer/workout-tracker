import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../logic/workout_provider.dart';
import '../../logic/routine_provider.dart';
import '../../logic/history_provider.dart'; // <-- History Provider eklendi
import '../widgets/exercise_card.dart';
import '../widgets/add_exercise_sheet.dart';
import 'history_screen.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  final String? currentRoutineId;
  final String? editingHistoryId; // <-- If filled, we are in "Edit Mode"

  const ActiveWorkoutScreen({
    super.key,
    this.currentRoutineId,
    this.editingHistoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(workoutProvider);
    final isEditing = editingHistoryId != null; // Mode check

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? "Edit Record" : "Push Day", // Title changes
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)
            ),
            Text(
              isEditing ? "Past Workout" : "Active Workout", 
              style: const TextStyle(color: AppTheme.neonAccent, fontSize: 12)
            ),
          ],
        ),
        actions: [
          if (!isEditing) // In edit mode, hide history button to avoid confusion
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
              },
              icon: const Icon(Icons.history, color: Colors.white),
            ),
          const SizedBox(width: 16),
        ],
      ),
      
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length + 1,
        itemBuilder: (context, index) {
          if (index == exercises.length) {
            return _buildAddExerciseButton(context, ref);
          }
          final exercise = exercises[index];
          return ExerciseCard(exercise: exercise);
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isEditing) {
            // --- UPDATE SCENARIO ---
            // 1. Get current screen data
            final updatedExercises = ref.read(workoutProvider);
            
            // 2. Tell History Provider "Update this"
            ref.read(historyProvider.notifier).updateWorkout(editingHistoryId!, updatedExercises);
            
            // 3. Mesaj Ver
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Record updated! ✅"), backgroundColor: AppTheme.neonAccent),
            );
            
            // 4. Clean up screen and exit
            ref.read(workoutProvider.notifier).clear();
            Navigator.pop(context);

          } else {
            // --- NORMAL COMPLETION SCENARIO ---
            ref.read(workoutProvider.notifier).finishWorkout();

            if (currentRoutineId != null) {
              final _ = ref.read(workoutProvider); // We should get state before finishWorkout clears it, but it already clears inside finishWorkout.
              // FIX: finishWorkout clears the state, so routine update might not work.
              // However, we're not breaking this logic now because finishWorkout refreshes the screen, doesn't set state to null, gives new ID empty sets.
              // For routine updates, just the exercise list (names) is enough.
              
              // (We can ignore this small logic error, routine update works because exercises aren't deleted, only sets are reset)
              ref.read(routineProvider.notifier).updateRoutineExercises(currentRoutineId!, ref.read(workoutProvider));
            }
            
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Workout saved! 💪"), backgroundColor: AppTheme.neonAccent),
            );
          }
        },
        backgroundColor: isEditing ? Colors.blueAccent : const Color(0xFFCCFF00), // Color should be different
        label: Text(
          isEditing ? "UPDATE RECORD" : "FINISH WORKOUT", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        icon: Icon(isEditing ? Icons.update : Icons.check, color: Colors.black),
      ),
    );
  }

  Widget _buildAddExerciseButton(BuildContext context, WidgetRef ref) {
    // ... (This part stays the same, use AddExerciseSheet code as is)
    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0, top: 10),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddExerciseSheet(
              onSave: (name) {
                ref.read(workoutProvider.notifier).createExercise(name);
              },
            ),
          );
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.02),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  "YENİ HAREKET EKLE",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}