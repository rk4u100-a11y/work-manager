import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SiteOrderScreen extends StatefulWidget {
  const SiteOrderScreen({super.key});

  @override
  State<SiteOrderScreen> createState() => _SiteOrderScreenState();
}

class _SiteOrderScreenState extends State<SiteOrderScreen> {
  static final List<_SiteOrder> _savedOrders = [];

  final _dateController = TextEditingController();
  final _designationController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _orderDate;
  Uint8List? _selectedPhotoBytes;
  bool _showNewOrderForm = false;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
    setState(() {});
  }

  void _startVoiceTyping() async {
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
            _descriptionController.text = result.recognizedWords;
            _descriptionController.selection = TextSelection.fromPosition(
              TextPosition(offset: _descriptionController.text.length),
            );
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _designationController.dispose();
    _descriptionController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _orderDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      _orderDate = pickedDate;
      _dateController.text = _formatDate(pickedDate);
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
      _selectedPhotoBytes = photoBytes;
    });
  }

  void _openNewOrderForm() {
    setState(() {
      _showNewOrderForm = true;
    });
  }

  void _cancelNewOrderForm() {
    setState(() {
      _clearForm();
      _showNewOrderForm = false;
    });
  }

  void _saveSiteOrder() {
    if (_orderDate == null) {
      _showMessage('Please select the Date.');
      return;
    }

    if (_designationController.text.trim().isEmpty) {
      _showMessage('Please enter the Designation.');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showMessage('Please enter the Description.');
      return;
    }

    setState(() {
      _savedOrders.add(
        _SiteOrder(
          date: _orderDate!,
          designation: _designationController.text.trim(),
          description: _descriptionController.text.trim(),
          photoBytes: _selectedPhotoBytes,
        ),
      );

      _clearForm();
      _showNewOrderForm = false;
    });

    _showMessage('Site Order saved successfully.');
  }

  void _clearForm() {
    _dateController.clear();
    _designationController.clear();
    _descriptionController.clear();
    _orderDate = null;
    _selectedPhotoBytes = null;
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

  void _openOrderDetails(_SiteOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SiteOrderDetailsScreen(
          order: order,
          formattedDate: _formatDate(order.date),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Site Orders')),
      body: SafeArea(
        child: _showNewOrderForm ? _buildNewOrderForm() : _buildOrderList(),
      ),
    );
  }

  Widget _buildOrderList() {
    if (_savedOrders.isEmpty) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: _openNewOrderForm,
          icon: const Icon(Icons.add),
          label: const Text('New Site Order'),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._savedOrders.reversed.map(_buildOrderCard),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _openNewOrderForm,
            icon: const Icon(Icons.add),
            label: const Text('New Site Order'),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(_SiteOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _openOrderDetails(order),
        leading: CircleAvatar(
          child: Icon(
            order.photoBytes == null
                ? Icons.description_outlined
                : Icons.photo,
          ),
        ),
        title: Text(order.designation),
        subtitle: Text(
          '${_formatDate(order.date)}\n${order.description}',
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildNewOrderForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New Site Order',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _dateController,
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
            controller: _designationController,
            decoration: const InputDecoration(
              labelText: 'Designation',
              hintText: 'Enter Designation',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter Site Order Description',
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
            onPressed: () => _pickPhoto(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Take Photo'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _pickPhoto(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Upload Photo'),
          ),
          if (_selectedPhotoBytes != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _selectedPhotoBytes!,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveSiteOrder,
              icon: const Icon(Icons.save),
              label: const Text(
                'Save',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _cancelNewOrderForm,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _SiteOrder {
  const _SiteOrder({
    required this.date,
    required this.designation,
    required this.description,
    this.photoBytes,
  });

  final DateTime date;
  final String designation;
  final String description;
  final Uint8List? photoBytes;
}

class _SiteOrderDetailsScreen extends StatelessWidget {
  const _SiteOrderDetailsScreen({
    required this.order,
    required this.formattedDate,
  });

  final _SiteOrder order;
  final String formattedDate;

  void _downloadPhoto() {
    if (order.photoBytes == null) return;

    final blob = html.Blob([order.photoBytes!]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..download = 'site_order_photo.jpg'
      ..click();

    Future<void>.delayed(
      const Duration(seconds: 1),
      () => html.Url.revokeObjectUrl(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Site Order Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailRow(label: 'Date', value: formattedDate),
            const SizedBox(height: 16),
            _DetailRow(label: 'Designation', value: order.designation),
            const SizedBox(height: 16),
            _DetailRow(label: 'Description', value: order.description),
            if (order.photoBytes != null) ...[
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
                        photoBytes: order.photoBytes!,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    order.photoBytes!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Tap photo to view full screen'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _downloadPhoto,
                icon: const Icon(Icons.download),
                label: const Text('Download Photo'),
              ),
            ],
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