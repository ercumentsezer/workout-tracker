import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../logic/history_provider.dart';
import '../../logic/workout_provider.dart'; // <-- THIS WAS MISSING, ADDED
import 'workout_detail_screen.dart';
import 'active_workout_screen.dart'; // <-- REQUIRED FOR ActiveWorkoutScreen

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(historyProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout History", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final workout = history[index];
                final dateStr = DateFormat('d MMMM yyyy', 'tr_TR').format(workout.date);
                final dayName = DateFormat('EEEE', 'tr_TR').format(workout.date);

                return Dismissible(
                  key: Key(workout.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1C1C1E),
                        title: const Text("Silinsin mi?", style: TextStyle(color: Colors.white)),
                        content: const Text("This workout record will be permanently deleted.", style: TextStyle(color: Colors.grey)),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    ref.read(historyProvider.notifier).deleteWorkout(workout.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Workout deleted"), backgroundColor: Colors.red, duration: Duration(seconds: 1)),
                    );
                  },
                  child: Card(
                    color: const Color(0xFF1C1C1E),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workout: workout)),
                        );
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.fitness_center, color: AppTheme.neonAccent),
                      ),
                      title: Text(
                        dateStr,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dayName, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            "${workout.exercises.length} Exercises",
                            style: const TextStyle(color: AppTheme.neonAccent, fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        color: const Color(0xFF2C2C2E),
                        onSelected: (value) {
                          if (value == 'delete') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1C1C1E),
                                title: const Text("Delete?", style: TextStyle(color: Colors.white)),
                                content: const Text("This record will be deleted.", style: TextStyle(color: Colors.grey)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                                  TextButton(
                                    onPressed: () {
                                      ref.read(historyProvider.notifier).deleteWorkout(workout.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          } else if (value == 'edit') {
                            // EDITING LOGIC
                            final currentWorkout = ref.read(workoutProvider);
                            if (currentWorkout.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1C1C1E),
                                  title: const Text("Warning", style: TextStyle(color: Colors.white)),
                                  content: const Text("There is currently an open workout screen. If you proceed to edit, that screen will be cleared. Continue?", style: TextStyle(color: Colors.grey)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _startEditing(context, ref, workout);
                                      },
                                      child: const Text("Continue", style: TextStyle(color: AppTheme.neonAccent)),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              _startEditing(context, ref, workout);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text("Edit Record", style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text("Delete Record", style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text("No completed workouts yet.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- NOTE: This function is now inside the Class ---
  void _startEditing(BuildContext context, WidgetRef ref, dynamic workout) {
    // 1. Load history data into WorkoutProvider
    ref.read(workoutProvider.notifier).loadFromHistory(workout.exercises);

    // 2. Open Active Workout screen in "Edit Mode"
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutScreen(
          editingHistoryId: workout.id, // Send ID to open edit mode
        ),
      ),
    );
  }
}