import 'package:flutter/material.dart';

import '../work_list/work_list_screen.dart';
import '../inspection/inspection_screen.dart';
import '../events_blocks/events_blocks_screen.dart';
import '../check_list/check_list_screen.dart';
import '../diary/diary_screen.dart';
import '../../work_progress/work_progress_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              // ================================
              // WORK LIST
              // ================================
              _MainButton(
                title: 'Work List',
                icon: Icons.work_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const WorkListScreen(),
                    ),
                  );
                },
              ),

              // ================================
              // INSPECTION NOTE & SITE ORDERS
              // ================================
              _MainButton(
                title: 'Inspection Note & Site Orders',
                icon: Icons.note_alt_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const InspectionScreen(),
                    ),
                  );
                },
              ),

              // ================================
              // EVENTS & BLOCKS
              // ================================
              _MainButton(
                title: 'Events & Blocks',
                icon: Icons.event_note_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const EventsBlocksScreen(),
                    ),
                  );
                },
              ),

              // ================================
              // CHECK LIST
              // ================================
              _MainButton(
                title: 'Check List',
                icon: Icons.checklist_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CheckListScreen(),
                    ),
                  );
                },
              ),

              // ================================
              // DIARY
              // ================================
              _MainButton(
                title: 'Diary',
                icon: Icons.menu_book_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const DiaryScreen(),
                    ),
                  );
                },
              ),

              // ================================
              // WORK PROGRESS & CHART
              // ================================
              _MainButton(
                title: 'Work Progress & Chart',
                icon: Icons.bar_chart_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const WorkProgressScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// MAIN BUTTON
// ==========================================================

class _MainButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MainButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}