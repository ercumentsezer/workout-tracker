import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../logic/routine_provider.dart';
import 'create_routine_screen.dart';

class ManageRoutinesScreen extends ConsumerWidget {
  const ManageRoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = ref.watch(routineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Programs", style: TextStyle(color: Colors.white)),
      ),
      body: routines.isEmpty 
        ? Center(child: Text("You don't have any programs yet.", style: TextStyle(color: Colors.grey[600])))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              
              // --- SOLA KAYDIRARAK SİLME ---
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
                      title: const Text("Delete?", style: TextStyle(color: Colors.white)),
                      content: Text("'${routine.name}' program will be deleted.", style: const TextStyle(color: Colors.grey)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  ref.read(routineProvider.notifier).deleteRoutine(routine.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Program deleted"), backgroundColor: Colors.red, duration: Duration(seconds: 1)),
                  );
                },
                child: Card(
                  color: const Color(0xFF1C1C1E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(routine.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text("${routine.exercises.length} Hareket", style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.edit, color: AppTheme.neonAccent, size: 20),
                    onTap: () {
                      // --- SEND FOR EDITING ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateRoutineScreen(routineToEdit: routine),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // NEW CREATION (routineToEdit is empty)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateRoutineScreen()),
          );
        },
        backgroundColor: AppTheme.neonAccent,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("YENİ PROGRAM", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}