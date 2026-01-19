import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout_set.dart';
import '../../data/models/workout_history.dart';
import '../../logic/workout_provider.dart';
import 'machine_settings_sheet.dart';

class ExerciseCard extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseCard({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
// Header
          _buildHeader(context, ref),
          
          _buildTableHeaders(),
          const SizedBox(height: 4),

          // List sets
          ...exercise.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;

            // Ghost data (previous session info)
            final lastSet = _getLastSetLog(exercise.name, index);
            final ghostWeight = lastSet?.weight?.toString() ?? "-";
            final ghostReps = lastSet?.reps?.toString() ?? "-";

            return WorkoutSetRow(
              key: ValueKey(set.id),
              exerciseId: exercise.id,
              set: set,
              setNumber: index + 1,
              prevWeight: ghostWeight,
              prevReps: ghostReps,
            );
          }).toList(),

          const SizedBox(height: 8),

          // Add set button
          InkWell(
            onTap: () {
              ref.read(workoutProvider.notifier).addSet(exercise.id);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Text(
                  "+ SET EKLE",
                  style: TextStyle(
                    color: AppTheme.neonAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Co-methods ---

  // Find previous data
  WorkoutSet? _getLastSetLog(String exerciseName, int setIndex) {
    if (!Hive.isBoxOpen('history')) return null;
    final historyBox = Hive.box<WorkoutHistory>('history');
    if (historyBox.isEmpty) return null;

    final history = historyBox.values.toList().reversed;
    for (var workout in history) {
      try {
        final pastExercise = workout.exercises.firstWhere((e) => e.name == exerciseName);
        if (setIndex < pastExercise.sets.length) {
          final pastSet = pastExercise.sets[setIndex];
          if (pastSet.weight != null || pastSet.reps != null) {
            return pastSet;
          }
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  // Header 
  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Machine Settings
                _buildSettingsChip(context, exercise.machineSettings ?? "", ref),
              ],
            ),
          ),
          
          // 3-dot menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.grey),
            color: const Color(0xFF2C2C2E),
            onSelected: (value) {
              if (value == 'delete') {
                ref.read(workoutProvider.notifier).deleteExercise(exercise.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Egzersiz silindi"), backgroundColor: Colors.red, duration: Duration(seconds: 1)),
                );
              } else if (value == 'edit') {
                _showEditDialog(context, ref);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text("Edit", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text("Sil", style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Machine Settings
  Widget _buildSettingsChip(BuildContext context, String settings, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => MachineSettingsSheet(
            initialSettings: settings,
            onSave: (newVal) {
              ref.read(workoutProvider.notifier).updateMachineSettings(exercise.id, newVal);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune, size: 14, color: AppTheme.neonAccent),
            const SizedBox(width: 6),
            Text(
              settings.isEmpty ? "Ayar Ekle" : settings,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Table headers
  Widget _buildTableHeaders() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(width: 30, child: Center(child: Text("SET", style: TextStyle(fontSize: 10, color: Colors.grey)))),
          Spacer(),
          SizedBox(width: 60, child: Center(child: Text("KG", style: TextStyle(fontSize: 10, color: Colors.grey)))),
          SizedBox(width: 20),
          SizedBox(width: 60, child: Center(child: Text("TEKRAR", style: TextStyle(fontSize: 10, color: Colors.grey)))),
          SizedBox(width: 10), // Some space on the right side
        ],
      ),
    );
  }

  // Edit dialog
  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController(text: exercise.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text("Edit Name", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Exercise Name",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(workoutProvider.notifier).editExerciseName(exercise.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Kaydet", style: TextStyle(color: AppTheme.neonAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class WorkoutSetRow extends ConsumerWidget {
  final String exerciseId;
  final WorkoutSet set;
  final int setNumber;
  final String prevWeight;
  final String prevReps;

  const WorkoutSetRow({
    super.key,
    required this.exerciseId,
    required this.set,
    required this.setNumber,
    required this.prevWeight,
    required this.prevReps,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(set.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        ref.read(workoutProvider.notifier).deleteSet(exerciseId, set.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Set silindi"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withOpacity(0.9),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Center(
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    "$setNumber", 
                    style: const TextStyle(
                      fontSize: 12, 
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ),
            ),
            const Spacer(),
            _buildInput(
              context,
              ref,
              initialValue: set.weight?.toString(),
              hint: prevWeight,
              onChanged: (val) {
                final value = double.tryParse(val);
                ref.read(workoutProvider.notifier).updateSet(exerciseId, set.id, weight: value);
              },
            ),
            const SizedBox(width: 20),
            _buildInput(
              context,
              ref,
              initialValue: set.reps?.toString(),
              hint: prevReps,
              onChanged: (val) {
                final value = int.tryParse(val);
                ref.read(workoutProvider.notifier).updateSet(exerciseId, set.id, reps: value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    BuildContext context,
    WidgetRef ref, {
    required String? initialValue,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Container(
      width: 60,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          color: Colors.white
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.4)),
          contentPadding: const EdgeInsets.only(bottom: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}