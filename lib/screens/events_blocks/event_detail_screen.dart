import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EventData {
  const EventData({
    required this.name,
    required this.date,
    required this.time,
    required this.location,
    required this.description,
    this.photoBytes,
  });

  final String name;
  final DateTime date;
  final TimeOfDay time;
  final String location;
  final String description;
  final Uint8List? photoBytes;
}

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({
    super.key,
    this.event,
    this.eventName,
  });

  final EventData? event;
  final String? eventName;

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: Text(eventName ?? 'Event')),
        body: const Center(
          child: Text('Event details will appear here.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(event!.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailRow(label: 'Date', value: _formatDate(event!.date)),
            const SizedBox(height: 16),
            _DetailRow(
              label: 'Time',
              value: event!.time.format(context),
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Location', value: event!.location),
            const SizedBox(height: 16),
            _DetailRow(label: 'Details', value: event!.description),
            if (event!.photoBytes != null) ...[
              const SizedBox(height: 24),
              const Text(
                'Photo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _FullScreenPhotoScreen(
                        photoBytes: event!.photoBytes!,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    event!.photoBytes!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap photo to view full screen'),
            ],
          ],
        ),
      ),
    );
  }
}

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({
    super.key,
    this.event,
  });

  final EventData? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Uint8List? selectedPhotoBytes;

  @override
  void initState() {
    super.initState();

    final event = widget.event;
    if (event == null) return;

    selectedDate = event.date;
    selectedTime = event.time;
    selectedPhotoBytes = event.photoBytes;

    nameController.text = event.name;
    dateController.text = _formatDate(event.date);
    timeController.text = _formatTime(event.time);
    locationController.text = event.location;
    descriptionController.text = event.description;
  }

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
      dateController.text = _formatDate(pickedDate);
    });
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      selectedTime = pickedTime;
      timeController.text = _formatTime(pickedTime);
    });
  }

  Future<void> _pickPhoto() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (photo == null) return;

    final photoBytes = await photo.readAsBytes();
    if (!mounted) return;

    setState(() {
      selectedPhotoBytes = photoBytes;
    });
  }

  void _saveEvent() {
    if (nameController.text.trim().isEmpty) {
      _showMessage('Please enter the Event Name.');
      return;
    }

    if (selectedDate == null) {
      _showMessage('Please select the Date.');
      return;
    }

    if (selectedTime == null) {
      _showMessage('Please select the Time.');
      return;
    }

    if (locationController.text.trim().isEmpty) {
      _showMessage('Please enter the Location.');
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      _showMessage('Please enter the Details.');
      return;
    }

    Navigator.pop(
      context,
      EventData(
        name: nameController.text.trim(),
        date: selectedDate!,
        time: selectedTime!,
        location: locationController.text.trim(),
        description: descriptionController.text.trim(),
        photoBytes: selectedPhotoBytes,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'New Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                hintText: 'Enter event name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'Select Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_month),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              readOnly: true,
              onTap: _selectTime,
              decoration: InputDecoration(
                labelText: 'Time',
                hintText: 'Select Time',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _selectTime,
                  icon: const Icon(Icons.access_time),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter event location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'Description / Details',
                hintText: 'Enter event details',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Upload Photo'),
            ),
            if (selectedPhotoBytes != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  selectedPhotoBytes!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveEvent,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}

class _FullScreenPhotoScreen extends StatelessWidget {
  const _FullScreenPhotoScreen({
    required this.photoBytes,
  });

  final Uint8List photoBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(photoBytes, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();

  return day + '/' + month + '/' + year;
}