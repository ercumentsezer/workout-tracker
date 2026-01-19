import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/workout_history.dart';
import '../../data/models/exercise.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutHistory workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    // Date Format
    final dateStr = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(workout.date);
    final timeStr = DateFormat('HH:mm').format(workout.date);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Workout Details", style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text(dateStr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: AppTheme.neonAccent),
                    const SizedBox(width: 8),
                    Text("Saat: $timeStr", style: const TextStyle(color: Colors.white)),
                  ],
                ),
                Text(
                  "${workout.exercises.length} Hareket",
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Egzersiz Listesi
          ...workout.exercises.map((exercise) => _buildExerciseCard(exercise)).toList(),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Name
          Text(
            exercise.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (exercise.machineSettings != null && exercise.machineSettings!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "Ayar: ${exercise.machineSettings}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          const SizedBox(height: 12),
          
          // Table Headers
          const Row(
            children: [
              SizedBox(width: 30, child: Text("SET", style: TextStyle(color: Colors.grey, fontSize: 10))),
              Spacer(),
              SizedBox(width: 60, child: Center(child: Text("KG", style: TextStyle(color: Colors.grey, fontSize: 10)))),
              SizedBox(width: 60, child: Center(child: Text("TEKRAR", style: TextStyle(color: Colors.grey, fontSize: 10)))),
            ],
          ),
          const Divider(color: Colors.white10),

          // Sets
          ...exercise.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            // Show only completed or filled-in sets
            if (set.weight == null && set.reps == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // Set No
                  SizedBox(
                    width: 30,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white10,
                      child: Text("${index + 1}", style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
                  const Spacer(),
                  // KG
                  SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        set.weight?.toString() ?? "-",
                        style: const TextStyle(color: AppTheme.neonAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Tekrar
                  SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        set.reps?.toString() ?? "-",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}