import 'package:flutter/material.dart';

import 'add_work_screen.dart';
import 'work_detail_screen.dart';
import 'work_data.dart';

class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() =>
      _WorkListScreenState();
}

class _WorkListScreenState
    extends State<WorkListScreen> {

  // ==================================================
  // ADD NEW WORK
  // ==================================================

  Future<void> _addWork() async {
    final String? newWork =
        await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AddWorkScreen(),
      ),
    );

    if (newWork != null &&
        newWork.trim().isNotEmpty) {
      setState(() {
        WorkData.works.add(
          newWork.trim(),
        );
      });
    }
  }

  // ==================================================
  // OPEN WORK
  // ==================================================

  void _openWork(String workName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WorkDetailScreen(
          workName: workName,
        ),
      ),
    );
  }

  // ==================================================
  // DELETE WORK
  // ==================================================

  void _deleteWork(int index) {
    setState(() {
      WorkData.works.removeAt(index);
    });
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work List'),
      ),

      // ==================================================
      // WORK LIST
      // ==================================================

      body: WorkData.works.isEmpty
          ? const Center(
              child: Text(
                'No works available.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.all(12),

              itemCount:
                  WorkData.works.length,

              itemBuilder:
                  (context, index) {
                final String workName =
                    WorkData.works[index];

                return Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  child: InkWell(
                    onTap: () {
                      _openWork(workName);
                    },

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    child: Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),

                      child: Row(
                        children: [
                          // ==================================================
                          // WORK NAME
                          // No icon / tick on the left
                          // ==================================================

                          Expanded(
                            child: Text(
                              workName,
                              style:
                                  const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          // ==================================================
                          // MENU
                          // ==================================================

                          PopupMenuButton<
                              String>(
                            onSelected:
                                (value) {
                              if (value ==
                                  'edit') {
                                _openWork(
                                  workName,
                                );
                              } else if (value ==
                                  'delete') {
                                _deleteWork(
                                  index,
                                );
                              }
                            },

                            itemBuilder:
                                (context) =>
                                    const [
                              PopupMenuItem(
                                value: 'edit',
                                child:
                                    Text(
                                  'Edit',
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child:
                                    Text(
                                  'Delete',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      // ==================================================
      // NEW WORK
      // ==================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addWork,

        icon: const Icon(
          Icons.add,
        ),

        label: const Text(
          'New Work',
        ),
      ),
    );
  }
}