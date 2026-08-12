import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Conditional imports for Web and Mobile
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:js' as js;

class InspectionNoteData {
  const InspectionNoteData({
    required this.noteName,
    required this.inspectionDate,
    required this.designation,
    required this.observation,
    this.photoBytes,
  });

  final String noteName;
  final DateTime inspectionDate;
  final String designation;
  final String observation;
  final Uint8List? photoBytes;

  InspectionNoteData copyWith({
    String? noteName,
  }) {
    return InspectionNoteData(
      noteName: noteName ?? this.noteName,
      inspectionDate: inspectionDate,
      designation: designation,
      observation: observation,
      photoBytes: photoBytes,
    );
  }
}

class AddInspectionNoteScreen extends StatefulWidget {
  const AddInspectionNoteScreen({
    super.key,
    required this.noteName,
  });

  final String noteName;

  @override
  State<AddInspectionNoteScreen> createState() =>
      _AddInspectionNoteScreenState();
}

class _AddInspectionNoteScreenState extends State<AddInspectionNoteScreen> {
  final dateController = TextEditingController();
  final designationController = TextEditingController();
  final observationController = TextEditingController();

  DateTime? inspectionDate;
  Uint8List? selectedPhotoBytes;
  bool _isListening = false;

  late stt.SpeechToText _speech;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initMobileSpeech();
    }
  }

  void _initMobileSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (_) {
        setState(() => _isListening = false);
      },
    );
    setState(() {});
  }

  // Universal Voice Typing (Works on Browser for testing & Android for final app)
  void _startVoiceTyping() {
    if (kIsWeb) {
      _startWebVoiceTyping();
    } else {
      _startMobileVoiceTyping();
    }
  }

  // Web Browser Voice Typing Logic
  void _startWebVoiceTyping() {
    try {
      final dynamic speechRecognitionClass = 
          (html.window as dynamic).webkitSpeechRecognition ?? 
          (html.window as dynamic).SpeechRecognition;
      
      if (speechRecognitionClass == null) {
        _showMessage('Voice recognition is not supported in this browser.');
        return;
      }

      final dynamic recognition = js_util.callConstructor(speechRecognitionClass, []);
      
      js_util.setProperty(recognition, 'continuous', false);
      js_util.setProperty(recognition, 'interimResults', true);
      js_util.setProperty(recognition, 'lang', 'en-US');

      js_util.setProperty(recognition, 'onstart', js.allowInterop((_) {
        setState(() {
          _isListening = true;
        });
      }));

      js_util.setProperty(recognition, 'onresult', js.allowInterop((dynamic event) {
        final results = js_util.getProperty(event, 'results');
        final resultIndex = js_util.getProperty(event, 'resultIndex');
        final transcript = js_util.getProperty(
          js_util.getProperty(results, resultIndex), 
          'transcript',
        );
        
        setState(() {
          final currentText = observationController.text;
          if (currentText.isEmpty) {
            observationController.text = transcript;
          } else {
            observationController.text = '$currentText $transcript';
          }
          observationController.selection = TextSelection.fromPosition(
            TextPosition(offset: observationController.text.length),
          );
        });
      }));

      js_util.setProperty(recognition, 'onerror', js.allowInterop((_) {
        setState(() {
          _isListening = false;
        });
      }));

      js_util.setProperty(recognition, 'onend', js.allowInterop((_) {
        setState(() {
          _isListening = false;
        });
      }));

      js_util.callMethod(recognition, 'start', []);
    } catch (e) {
      _showMessage('Voice typing failed to start.');
      setState(() {
        _isListening = false;
      });
    }
  }

  // Android Mobile Voice Typing Logic
  void _startMobileVoiceTyping() async {
    if (!_speechEnabled) {
      _speechEnabled = await _speech.initialize();
    }

    if (!_speechEnabled) {
      _showMessage('Microphone permission is required.');
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            observationController.text = result.recognizedWords;
            observationController.selection = TextSelection.fromPosition(
              TextPosition(offset: observationController.text.length),
            );
          });
        },
      );
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    designationController.dispose();
    observationController.dispose();
    if (!kIsWeb) {
      _speech.stop();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: inspectionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      inspectionDate = pickedDate;
      dateController.text = _formatDate(pickedDate);
    });
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final photo = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );

    if (photo == null) return;

    final photoBytes = await photo.readAsBytes();

    if (!mounted) return;

    setState(() {
      selectedPhotoBytes = photoBytes;
    });
  }

  Future<void> _showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveNote() {
    if (inspectionDate == null) {
      _showMessage('Please select a date.');
      return;
    }

    if (designationController.text.trim().isEmpty) {
      _showMessage('Please enter the designation.');
      return;
    }

    if (observationController.text.trim().isEmpty) {
      _showMessage('Please enter the observation.');
      return;
    }

    Navigator.pop(
      context,
      InspectionNoteData(
        noteName: widget.noteName,
        inspectionDate: inspectionDate!,
        designation: designationController.text.trim(),
        observation: observationController.text.trim(),
        photoBytes: selectedPhotoBytes,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return day + '/' + month + '/' + year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Note')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.noteName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
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
              controller: designationController,
              decoration: const InputDecoration(
                labelText: 'Designation',
                hintText: 'Enter Designation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: observationController,
              maxLines: 7,
              decoration: InputDecoration(
                labelText: 'Observation',
                hintText: 'Enter inspection observation',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
                suffixIcon: IconButton(
                  onPressed: _startVoiceTyping,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : null,
                  ),
                  tooltip: 'Voice Typing',
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showPhotoOptions,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add Photo'),
            ),
            if (selectedPhotoBytes != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
                onPressed: _saveNote,
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