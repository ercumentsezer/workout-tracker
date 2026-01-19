import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout_routine.dart';
import '../../data/models/workout_set.dart';
import '../../logic/routine_provider.dart';
import '../widgets/add_exercise_sheet.dart';

class CreateRoutineScreen extends ConsumerStatefulWidget {
  final WorkoutRoutine? routineToEdit; // Parameter required for editing

  const CreateRoutineScreen({super.key, this.routineToEdit});

  @override
  ConsumerState<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends ConsumerState<CreateRoutineScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<Exercise> _tempExercises = [];

  @override
  void initState() {
    super.initState();
    // IF IN EDIT MODE, FILL IN THE DATA
    if (widget.routineToEdit != null) {
      _nameController.text = widget.routineToEdit!.name;
      // Copy the list (so references don't get mixed up)
      _tempExercises = List.from(widget.routineToEdit!.exercises);
    }
  }

  void _addExercise(String name) {
    setState(() {
      _tempExercises.add(
        Exercise(
          id: const Uuid().v4(),
          name: name,
          sets: List.generate(3, (_) => WorkoutSet(id: const Uuid().v4(), weight: null, reps: null)),
        ),
      );
    });
  }

  void _updateSetCount(int exerciseIndex, int newCount) {
    setState(() {
      final oldExercise = _tempExercises[exerciseIndex];
      List<WorkoutSet> currentSets = List.from(oldExercise.sets);

      if (newCount > currentSets.length) {
        final diff = newCount - currentSets.length;
        for (var i = 0; i < diff; i++) {
          currentSets.add(WorkoutSet(id: const Uuid().v4(), weight: null, reps: null));
        }
      } else if (newCount < currentSets.length) {
        currentSets = currentSets.sublist(0, newCount);
      }

      _tempExercises[exerciseIndex] = oldExercise.copyWith(sets: currentSets);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _tempExercises.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.routineToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Program" : "New Program", style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please give the program a name.")));
                return;
              }
              if (_tempExercises.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must add at least one exercise.")));
                return;
              }

              if (isEditing) {
                // UPDATE OPERATION
                ref.read(routineProvider.notifier).updateRoutine(
                  widget.routineToEdit!.id,
                  _nameController.text, 
                  _tempExercises
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Program updated! ✅")));
              } else {
                // CREATE NEW OPERATION
                ref.read(routineProvider.notifier).createRoutine(_nameController.text, _tempExercises);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Program created! 🎉")));
              }
              
              Navigator.pop(context);
            },
            child: Text(isEditing ? "UPDATE" : "SAVE", style: const TextStyle(color: AppTheme.neonAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                hintText: "Program Name (E.g.: Push A)",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF1C1C1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
              ),
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: _tempExercises.isEmpty 
            ? const Center(child: Text("You haven't added any exercises yet.", style: TextStyle(color: Colors.grey)))
            : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tempExercises.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = _tempExercises.removeAt(oldIndex);
                  _tempExercises.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final exercise = _tempExercises[index];
                return Card(
                  key: ValueKey(exercise.id),
                  color: const Color(0xFF1C1C1E),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(exercise.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red, size: 20),
                              onPressed: () => _removeExercise(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text("Set Count:", style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 16),
                            InkWell(
                              onTap: () {
                                if (exercise.sets.length > 1) _updateSetCount(index, exercise.sets.length - 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                                child: const Icon(Icons.remove, color: Colors.white, size: 16),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text("${exercise.sets.length}", style: const TextStyle(color: AppTheme.neonAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                if (exercise.sets.length < 10) _updateSetCount(index, exercise.sets.length + 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                                child: const Icon(Icons.add, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddExerciseSheet(
                      onSave: (name) => _addExercise(name),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text("HAREKET EKLE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}