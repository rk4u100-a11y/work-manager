import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BlockDetailScreen extends StatefulWidget {
  final String blockName;
  final String blockType;

  const BlockDetailScreen({
    super.key,
    required this.blockName,
    required this.blockType,
  });

  @override
  State<BlockDetailScreen> createState() => _BlockDetailScreenState();
}

class _BlockDetailScreenState extends State<BlockDetailScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  XFile? selectedPhoto;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.blockName;
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final ImagePicker picker = ImagePicker();

    final XFile? photo = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        selectedPhoto = photo;
      });
    }
  }

  void _saveBlock() {
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blockName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.blockType,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Block Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location / Chainage / Station',
                hintText: 'Enter location or chainage/station',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: selectedDate == null
                    ? 'Select Date'
                    : _formatDate(selectedDate!),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_month),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              readOnly: true,
              onTap: _selectTime,
              decoration: InputDecoration(
                labelText: 'Time',
                hintText: selectedTime == null
                    ? 'Select Time'
                    : _formatTime(selectedTime!),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _selectTime,
                  icon: const Icon(Icons.access_time),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 7,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                suffixIcon: IconButton(
                  onPressed: () {
                    FocusScope.of(context).requestFocus();
                  },
                  icon: const Icon(Icons.mic),
                  tooltip: 'Use keyboard voice typing',
                ),
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Upload Photo'),
            ),

            if (selectedPhoto != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(selectedPhoto!.path),
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveBlock,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}