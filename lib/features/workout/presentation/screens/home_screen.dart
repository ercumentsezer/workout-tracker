import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import 'history_screen.dart';
import 'manage_routines_screen.dart'; // <-- New screen import
import '../widgets/select_routine_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // User data for profile picture or name (Optional, currently static)
    const userName = "Champion"; 

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome,", style: TextStyle(color: Colors.grey, fontSize: 14)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
            },
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: "History",
          ),
          const SizedBox(width: 16),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Padding(
            padding: EdgeInsets.only(left: 16, bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(userName, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            
            // --- MAIN BUTTON: START WORKOUT ---
            InkWell(
              onTap: () {
                // Open selection window
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const SelectRoutineSheet(),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.neonAccent, Color(0xFF99CC00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppTheme.neonAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 60, color: Colors.black),
                    SizedBox(height: 10),
                    Text(
                      "START WORKOUT",
                      style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    Text(
                      "Choose one of your registered programs",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- SECONDARY BUTTON: EDIT PROGRAMS ---
            InkWell(
              onTap: () {
                // Go to management screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageRoutinesScreen()),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_note, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      "Edit Programs",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}