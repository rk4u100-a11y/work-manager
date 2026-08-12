import 'package:flutter/material.dart';

import '../screens/work_list/work_data.dart';

class WorkProgressScreen extends StatelessWidget {
  const WorkProgressScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Work Progress & Chart',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================================================
            // WORK PROGRESS
            // ==================================================

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const WorkProgressUpdateScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.update,
              ),
              label: const Text(
                'Work Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // CHART
            // ==================================================

            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const WorkProgressChartScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.bar_chart,
              ),
              label: const Text(
                'Chart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// WORK PROGRESS UPDATE SCREEN
// ==========================================================

class WorkProgressUpdateScreen
    extends StatefulWidget {
  const WorkProgressUpdateScreen({
    super.key,
  });

  @override
  State<WorkProgressUpdateScreen> createState() =>
      _WorkProgressUpdateScreenState();
}

class _WorkProgressUpdateScreenState
    extends State<WorkProgressUpdateScreen> {
  
  void _editProgress(String workName) {
    final TextEditingController editController = TextEditingController(
      text: WorkData.getLatestProgress(workName).toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Progress for\n$workName'),
          content: TextField(
            controller: editController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter percentage',
              suffixText: '%',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? percentage = double.tryParse(
                  editController.text.trim(),
                );

                if (percentage == null ||
                    percentage < 0 ||
                    percentage > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a percentage between 0 and 100.',
                      ),
                    ),
                  );
                  return;
                }

                WorkData.updateProgress(
                  workName: workName,
                  progress: percentage,
                );

                setState(() {});
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$workName progress updated to ${percentage.toStringAsFixed(1)}%',
                    ),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Work Progress',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // CURRENT PROGRESS (LIST FIRST)
            // ==================================================

            const Text(
              'Current Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: WorkData.works.map(
                  (work) {
                    final progress =
                        WorkData.getLatestProgress(
                      work,
                    );

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),

                      child: ListTile(
                        title: Text(
                          work,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        subtitle: Text(
                          'Progress: ${progress.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),

                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editProgress(work);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// WORK PROGRESS CHART SCREEN
// ==========================================================

class WorkProgressChartScreen
    extends StatefulWidget {
  const WorkProgressChartScreen({
    super.key,
  });

  @override
  State<WorkProgressChartScreen> createState() =>
      _WorkProgressChartScreenState();
}

class _WorkProgressChartScreenState
    extends State<WorkProgressChartScreen> {
  String? selectedWork;
  String viewMode = 'Days'; // Days, Month, Year

  void _downloadChartPdf() {
    if (selectedWork == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading $selectedWork chart as PDF...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Work Progress Chart',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Work to View Chart',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Work Selection Dropdown
            DropdownButtonFormField<String>(
              value: selectedWork,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Choose a work',
              ),
              items: WorkData.works.map<DropdownMenuItem<String>>(
                (work) {
                  return DropdownMenuItem<String>(
                    value: work,
                    child: Text(work),
                  );
                },
              ).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWork = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // View Mode Selector & PDF Download Button
            if (selectedWork != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _downloadChartPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Download PDF'),
                  ),
                  Row(
                    children: [
                      const Text('View by: '),
                      ToggleButtons(
                        isSelected: [
                          viewMode == 'Days',
                          viewMode == 'Month',
                          viewMode == 'Year',
                        ],
                        onPressed: (index) {
                          setState(() {
                            if (index == 0) viewMode = 'Days';
                            if (index == 1) viewMode = 'Month';
                            if (index == 2) viewMode = 'Year';
                          });
                        },
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Days'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Month'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Year'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 16),

            Expanded(
              child: selectedWork == null
                  ? const Center(
                      child: Text(
                        'Please select a work from above to view its progress chart.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : WorkProgressLineChart(
                      workName: selectedWork!,
                      viewMode: viewMode,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// LINE CHART WIDGET
// ==========================================================

class WorkProgressLineChart extends StatelessWidget {
  const WorkProgressLineChart({
    super.key,
    required this.workName,
    required this.viewMode,
  });

  final String workName;
  final String viewMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Progress Chart: $workName ($viewMode View)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: CustomPaint(
            painter: _WorkProgressLineChartPainter(
              workName: workName,
              viewMode: viewMode,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// LINE CHART PAINTER
// ==========================================================

class _WorkProgressLineChartPainter extends CustomPainter {
  _WorkProgressLineChartPainter({
    required this.workName,
    required this.viewMode,
  });

  final String workName;
  final String viewMode;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final axisPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const double leftSpace = 50;
    const double bottomSpace = 50;
    const double topSpace = 20;

    final chartWidth = size.width - leftSpace;
    final chartHeight = size.height - bottomSpace - topSpace;

    // Draw Y and X Axis
    canvas.drawLine(
      Offset(leftSpace, topSpace),
      Offset(leftSpace, topSpace + chartHeight),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftSpace, topSpace + chartHeight),
      Offset(size.width, topSpace + chartHeight),
      axisPaint,
    );

    // Y-Axis 0 to 100%
    for (int i = 0; i <= 5; i++) {
      final value = i * 20;
      final y = topSpace + chartHeight - (chartHeight * value / 100);

      textPainter.text = TextSpan(
        text: '$value%',
        style: const TextStyle(fontSize: 11, color: Colors.black),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(4, y - textPainter.height / 2),
      );

      canvas.drawLine(
        Offset(leftSpace, y),
        Offset(size.width, y),
        axisPaint,
      );
    }

    final currentProgress = WorkData.getLatestProgress(workName);
    final List<double> points = [0.0, currentProgress > 50 ? 50.0 : currentProgress, currentProgress];

    if (points.isEmpty) return;

    final double dx = chartWidth / (points.length > 1 ? points.length - 1 : 1);

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = leftSpace + (i * dx);
      final y = topSpace + chartHeight - (chartHeight * points[i] / 100);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 5, pointPaint);

      textPainter.text = TextSpan(
        text: '${points[i].toStringAsFixed(0)}%',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 18));
    }

    canvas.drawPath(path, paint);

    for (int i = 0; i < points.length; i++) {
      final x = leftSpace + (i * dx);
      String label = 'Day ${i + 1}';
      if (viewMode == 'Month') {
        label = 'Month ${i + 1}';
      } else if (viewMode == 'Year') {
        label = '202${i + 4}';
      }

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(fontSize: 11, color: Colors.black),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, topSpace + chartHeight + 10),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}