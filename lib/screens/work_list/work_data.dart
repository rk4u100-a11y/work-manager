class WorkProgressEntry {
  final DateTime date;
  final double progress;

  WorkProgressEntry({
    required this.date,
    required this.progress,
  });
}

class WorkData {
  // ==================================================
  // WORK LIST
  // ==================================================

  static final List<String> works = [
    'Work 1',
    'Work 2',
    'Work 3',
  ];

  // ==================================================
  // WORK-WISE PROGRESS
  // ==================================================

  static final Map<String, List<WorkProgressEntry>>
      progressData = {
    'Work 1': [],
    'Work 2': [],
    'Work 3': [],
  };

  // ==================================================
  // UPDATE WORK PROGRESS
  // ==================================================

  static void updateProgress({
    required String workName,
    required double progress,
  }) {
    progressData.putIfAbsent(
      workName,
      () => [],
    );

    progressData[workName]!.add(
      WorkProgressEntry(
        date: DateTime.now(),
        progress: progress,
      ),
    );
  }

  // ==================================================
  // GET ALL PROGRESS
  // ==================================================

  static List<WorkProgressEntry> getProgress(
    String workName,
  ) {
    return progressData[workName] ?? [];
  }

  // ==================================================
  // GET LATEST PROGRESS
  // ==================================================

  static double getLatestProgress(
    String workName,
  ) {
    final entries =
        progressData[workName];

    if (entries == null ||
        entries.isEmpty) {
      return 0;
    }

    return entries.last.progress;
  }

  // ==================================================
  // ADD NEW WORK
  // ==================================================

  static void addWork(String workName) {
    if (workName.trim().isEmpty) {
      return;
    }

    if (works.contains(workName.trim())) {
      return;
    }

    works.add(workName.trim());

    progressData.putIfAbsent(
      workName.trim(),
      () => [],
    );
  }
}