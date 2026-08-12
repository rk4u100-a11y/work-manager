import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart';

class DiaryEntryScreen extends StatefulWidget {
  final DateTime? initialDate;

  const DiaryEntryScreen({
    super.key,
    this.initialDate,
  });

  @override
  State<DiaryEntryScreen> createState() =>
      _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  late DateTime selectedDate;
  late DateTime displayedMonth;

  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  final SpeechToText speechToText = SpeechToText();

  XFile? selectedPhoto;

  bool geoTagEnabled = false;
  bool isListening = false;
  bool speechAvailable = false;
  bool isGettingLocation = false;

  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();

    final date = widget.initialDate ?? DateTime.now();

    selectedDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    displayedMonth = DateTime(
      date.year,
      date.month,
      1,
    );

    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      speechAvailable = await speechToText.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      speechAvailable = false;
    }
  }

  // ==================================================
  // DATE CALENDAR
  // ==================================================

  void _previousMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + 1,
        1,
      );
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
    });
  }

  Widget _buildCalendar() {
    final DateTime firstDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );

    final int daysInMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    ).day;

    final int firstWeekday = firstDayOfMonth.weekday;

    final int totalCells =
        ((firstWeekday - 1 + daysInMonth) + 6) ~/ 7;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          // ----------------------------------------------
          // MONTH HEADER
          // ----------------------------------------------

          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(
                  Icons.chevron_left,
                  size: 30,
                ),
              ),

              Expanded(
                child: Center(
                  child: Text(
                    '${_monthName(displayedMonth.month)} '
                    '${displayedMonth.year}',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(
                  Icons.chevron_right,
                  size: 30,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ----------------------------------------------
          // WEEK DAYS
          // ----------------------------------------------

          Row(
            children: const [
              _WeekDay('Sun'),
              _WeekDay('Mon'),
              _WeekDay('Tue'),
              _WeekDay('Wed'),
              _WeekDay('Thu'),
              _WeekDay('Fri'),
              _WeekDay('Sat'),
            ],
          ),

          const SizedBox(height: 6),

          // ----------------------------------------------
          // DATE GRID
          // ----------------------------------------------

          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: totalCells * 7,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final int dayNumber =
                  index - (firstWeekday - 1) + 1;

              if (dayNumber < 1 ||
                  dayNumber > daysInMonth) {
                return const SizedBox();
              }

              final DateTime date = DateTime(
                displayedMonth.year,
                displayedMonth.month,
                dayNumber,
              );

              final bool isSelected =
                  _sameDate(date, selectedDate);

              final bool isToday =
                  _sameDate(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  _selectDate(date);
                },
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                          : null,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .onPrimary
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================================================
  // GEO TAG
  // ==================================================

  Future<void> _toggleGeoTag(bool value) async {
    if (!value) {
      setState(() {
        geoTagEnabled = false;
        latitude = null;
        longitude = null;
      });

      return;
    }

    setState(() {
      geoTagEnabled = true;
      isGettingLocation = true;
    });

    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        setState(() {
          geoTagEnabled = false;
          isGettingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enable location service.',
            ),
          ),
        );

        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        if (!mounted) return;

        setState(() {
          geoTagEnabled = false;
          isGettingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is required.',
            ),
          ),
        );

        return;
      }

      final Position position =
          await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location captured successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        geoTagEnabled = false;
        isGettingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to get current location.',
          ),
        ),
      );
    }
  }

  // ==================================================
  // CAMERA
  // ==================================================

  Future<void> _takePhoto() async {
    try {
      final XFile? photo =
          await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        setState(() {
          selectedPhoto = photo;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb
                ? 'Camera access is controlled by the browser in Preview.'
                : 'Unable to open camera.',
          ),
        ),
      );
    }
  }

  // ==================================================
  // GALLERY
  // ==================================================

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo =
          await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        setState(() {
          selectedPhoto = photo;
        });
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to select photo.',
          ),
        ),
      );
    }
  }

  // ==================================================
  // VOICE TYPING
  // ==================================================

  Future<void> _toggleVoiceTyping() async {
    if (!speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Voice typing is not available.',
          ),
        ),
      );

      return;
    }

    if (isListening) {
      await speechToText.stop();

      if (mounted) {
        setState(() {
          isListening = false;
        });
      }

      return;
    }

    setState(() {
      isListening = true;
    });

    await speechToText.listen(
      onResult: (result) {
        if (!mounted) return;

        setState(() {
          descriptionController.text =
              result.recognizedWords;

          descriptionController.selection =
              TextSelection.fromPosition(
            TextPosition(
              offset:
                  descriptionController.text.length,
            ),
          );
        });
      },
    );
  }

  // ==================================================
  // SAVE
  // ==================================================

  void _saveEntry() {
    if (locationController.text.trim().isEmpty &&
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter location or description.',
          ),
        ),
      );

      return;
    }

    Navigator.pop(context);
  }

  // ==================================================
  // HELPERS
  // ==================================================

  bool _sameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  void dispose() {
    locationController.dispose();
    descriptionController.dispose();
    speechToText.stop();
    super.dispose();
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Diary Entry'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // DATE
            // ==================================================

            const Text(
              'Date',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // Selected date display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _formatDate(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Full-width calendar
            _buildCalendar(),

            const SizedBox(height: 20),

            // ==================================================
            // WORK LOCATION
            // ==================================================

            const Text(
              'Work Location',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter work location',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Enter diary description',
                suffixIcon: IconButton(
                  onPressed: _toggleVoiceTyping,
                  icon: Icon(
                    isListening
                        ? Icons.mic
                        : Icons.mic_none,
                  ),
                  tooltip: 'Voice Typing',
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // GEO TAG TOGGLE
            // ==================================================

            Card(
              child: SwitchListTile(
                title: const Text(
                  'Geo-tagged Photo',
                ),
                subtitle: Text(
                  isGettingLocation
                      ? 'Getting current location...'
                      : 'Use current location with the photo',
                ),
                value: geoTagEnabled,
                onChanged: isGettingLocation
                    ? null
                    : _toggleGeoTag,
              ),
            ),

            if (geoTagEnabled &&
                latitude != null &&
                longitude != null)
              Padding(
                padding:
                    const EdgeInsets.only(top: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(10),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  child: Text(
                    'Location: '
                    '${latitude!.toStringAsFixed(6)}, '
                    '${longitude!.toStringAsFixed(6)}',
                  ),
                ),
              ),

            const SizedBox(height: 18),

            // ==================================================
            // CAMERA + GALLERY
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                    ),
                    label: const Text(
                      'Take Photo',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(
                      Icons.photo_library_outlined,
                    ),
                    label: const Text(
                      'Gallery',
                    ),
                  ),
                ),
              ],
            ),

            // ==================================================
            // PHOTO PREVIEW
            // ==================================================

            if (selectedPhoto != null) ...[
              const SizedBox(height: 16),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(12),
                child: FutureBuilder<List<int>>(
                  future:
                      selectedPhoto!.readAsBytes(),
                  builder:
                      (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 180,
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      );
                    }

                    return Image.memory(
                      Uint8List.fromList(
                        snapshot.data!,
                      ),
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 28),

            // ==================================================
            // SAVE
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveEntry,
                icon: const Icon(
                  Icons.save_outlined,
                ),
                label: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// WEEK DAY
// ==================================================

class _WeekDay extends StatelessWidget {
  final String text;

  const _WeekDay(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}