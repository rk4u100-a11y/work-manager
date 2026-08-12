import 'package:flutter/material.dart';

import 'event_detail_screen.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() =>
      _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {
  static final List<EventData> _events = [];

  Future<void> _addEvent() async {
    final newEvent = await Navigator.push<EventData>(
      context,
      MaterialPageRoute(
        builder: (_) => const EventFormScreen(),
      ),
    );

    if (!mounted || newEvent == null) return;

    setState(() {
      _events.add(newEvent);
    });
  }

  Future<void> _editEvent(int index) async {
    final updatedEvent = await Navigator.push<EventData>(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(event: _events[index]),
      ),
    );

    if (!mounted || updatedEvent == null) return;

    setState(() {
      _events[index] = updatedEvent;
    });
  }

  void _deleteEvent(int index) {
    setState(() {
      _events.removeAt(index);
    });
  }

  void _openEvent(EventData event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(event: event),
      ),
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
      appBar: AppBar(
        title: const Text('Upcoming Events'),
      ),
      body: _events.isEmpty
          ? const Center(
              child: Text('No events added yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[_events.length - 1 - index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _openEvent(event),
                    leading: CircleAvatar(
                      child: Icon(
                        event.photoBytes == null
                            ? Icons.event_outlined
                            : Icons.photo,
                      ),
                    ),
                    title: Text(event.name),
                    subtitle: Text(
                      '${_formatDate(event.date)}  •  '
                      '${event.time.format(context)}\n'
                      '${event.location}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        final actualIndex = _events.indexOf(event);

                        if (value == 'edit') {
                          _editEvent(actualIndex);
                        } else if (value == 'delete') {
                          _deleteEvent(actualIndex);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEvent,
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }
}