import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../logic/routine_provider.dart';
import '../../logic/workout_provider.dart';
import '../screens/active_workout_screen.dart';

class SelectRoutineSheet extends ConsumerWidget {
  const SelectRoutineSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineProvider);

    return Container(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select a Program",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Routine List
          if (routines.isEmpty)
            _buildEmptyState(context)
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true, // Take up only the space needed for content
                itemCount: routines.length,
                itemBuilder: (context, index) {
                  final routine = routines[index];
                  return Dismissible(
                    key: Key(routine.id),
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
                          title: const Text("Delete Program?", style: TextStyle(color: Colors.white)),
                          content: Text("'${routine.name}' will be deleted.", style: const TextStyle(color: Colors.grey)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                       ref.read(routineProvider.notifier).deleteRoutine(routine.id);
                    },
                    child: Card(
                      color: Colors.white.withOpacity(0.05),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () {
                          ref.read(workoutProvider.notifier).loadRoutine(routine.exercises);
                          
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActiveWorkoutScreen(currentRoutineId: routine.id),
                            ),
                          );
                        },
                        title: Text(routine.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text("${routine.exercises.length} Hareket", style: const TextStyle(color: Colors.grey)),
                        trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.neonAccent, size: 14),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.fitness_center, color: Colors.grey, size: 40),
            const SizedBox(height: 10),
            const Text("You don't have any registered programs yet.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}