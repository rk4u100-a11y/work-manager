import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'add_inspection_note_screen.dart';
import 'site_order_screen.dart';

class InspectionScreen extends StatelessWidget {
  const InspectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Note & Site Orders'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.note_alt_outlined, size: 30),
              title: const Text(
                'Inspection Note',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InspectionNoteListScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined, size: 30),
              title: const Text(
                'Site Orders',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SiteOrderScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InspectionNoteListScreen extends StatefulWidget {
  const InspectionNoteListScreen({super.key});

  @override
  State<InspectionNoteListScreen> createState() =>
      _InspectionNoteListScreenState();
}

class _InspectionNoteListScreenState extends State<InspectionNoteListScreen> {
  static final List<InspectionNoteData> _notes = [];

  Future<void> _addNewNote() async {
    final savedNote = await Navigator.push<InspectionNoteData>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddInspectionNoteScreen(
          noteName: 'Inspection Note',
        ),
      ),
    );

    if (!mounted || savedNote == null) return;

    setState(() {
      _notes.add(savedNote);
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _openNote(InspectionNoteData note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InspectionNoteDetailsScreen(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Notes')),
      body: _notes.isEmpty
          ? Center(
              child: ElevatedButton.icon(
                onPressed: _addNewNote,
                icon: const Icon(Icons.add),
                label: const Text('New Note'),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notes.length + 1,
              itemBuilder: (context, index) {
                if (index == _notes.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ElevatedButton.icon(
                      onPressed: _addNewNote,
                      icon: const Icon(Icons.add),
                      label: const Text('New Note'),
                    ),
                  );
                }

                final note = _notes[_notes.length - 1 - index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _openNote(note),
                    leading: CircleAvatar(
                      child: Icon(
                        note.photoBytes == null
                            ? Icons.note_alt_outlined
                            : Icons.photo,
                      ),
                    ),
                    title: const Text('Inspection Note'),
                    subtitle: Text(
                      '${_formatDate(note.inspectionDate)}\n'
                      '${note.designation}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'open') {
                          _openNote(note);
                        } else if (value == 'delete') {
                          _deleteNote(_notes.indexOf(note));
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'open', child: Text('Open')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class InspectionNoteDetailsScreen extends StatelessWidget {
  const InspectionNoteDetailsScreen({
    super.key,
    required this.note,
  });

  final InspectionNoteData note;

  void _downloadPhoto() {
    if (note.photoBytes == null) return;

    final blob = html.Blob([note.photoBytes!]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..download = 'inspection_note_photo.jpg'
      ..click();

    Future<void>.delayed(
      const Duration(seconds: 1),
      () => html.Url.revokeObjectUrl(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Note Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailText(
              label: 'Date',
              value: _formatDate(note.inspectionDate),
            ),
            const SizedBox(height: 16),
            _DetailText(
              label: 'Designation',
              value: note.designation,
            ),
            const SizedBox(height: 16),
            _DetailText(
              label: 'Observation',
              value: note.observation,
            ),
            if (note.photoBytes != null) ...[
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
                      builder: (_) => FullScreenPhotoScreen(
                        photoBytes: note.photoBytes!,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    note.photoBytes!,
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

class _DetailText extends StatelessWidget {
  const _DetailText({
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

class FullScreenPhotoScreen extends StatelessWidget {
  const FullScreenPhotoScreen({
    super.key,
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