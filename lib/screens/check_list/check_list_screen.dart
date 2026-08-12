import 'package:flutter/material.dart';

class CheckListScreen extends StatefulWidget {
  const CheckListScreen({super.key});

  @override
  State<CheckListScreen> createState() => _CheckListScreenState();
}

class _CheckListScreenState extends State<CheckListScreen> {
  final List<CheckListWork> works = [
    CheckListWork(
      name: 'Work 1',
      items: [
        CheckListItem(name: 'Checklist Item 1'),
        CheckListItem(name: 'Checklist Item 2'),
      ],
    ),
    CheckListWork(
      name: 'Work 2',
      items: [
        CheckListItem(name: 'Checklist Item 1'),
      ],
    ),
    CheckListWork(
      name: 'Work 3',
      items: [],
    ),
  ];

  Future<void> _addWork() async {
    final controller = TextEditingController();

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Work'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Work Name',
              hintText: 'Enter work name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name != null && name.isNotEmpty) {
      setState(() {
        works.add(
          CheckListWork(
            name: name,
            items: [],
          ),
        );
      });
    }
  }

  Future<void> _editWork(int index) async {
    final controller = TextEditingController(
      text: works[index].name,
    );

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Work'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Work Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name != null && name.isNotEmpty) {
      setState(() {
        works[index].name = name;
      });
    }
  }

  void _deleteWork(int index) {
    setState(() {
      works.removeAt(index);
    });
  }

  void _openWork(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckListDetailScreen(
          work: works[index],
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check List'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: works.length,
        itemBuilder: (context, index) {
          final work = works[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _openWork(index);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.checklist_outlined,
                      size: 30,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        work.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editWork(index);
                        } else if (value == 'delete') {
                          _deleteWork(index);
                        }
                      },
                      itemBuilder: (context) => const [
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
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWork,
        icon: const Icon(Icons.add),
        label: const Text('New Work'),
      ),
    );
  }
}

class CheckListDetailScreen extends StatefulWidget {
  final CheckListWork work;

  const CheckListDetailScreen({
    super.key,
    required this.work,
  });

  @override
  State<CheckListDetailScreen> createState() =>
      _CheckListDetailScreenState();
}

class _CheckListDetailScreenState
    extends State<CheckListDetailScreen> {
  Future<void> _addItem() async {
    final controller = TextEditingController();

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Checklist Item'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Checklist Item',
              hintText: 'Enter checklist item',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name != null && name.isNotEmpty) {
      setState(() {
        widget.work.items.add(
          CheckListItem(name: name),
        );
      });
    }
  }

  Future<void> _editItem(int index) async {
    final controller = TextEditingController(
      text: widget.work.items[index].name,
    );

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Checklist Item'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Checklist Item',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (name != null && name.isNotEmpty) {
      setState(() {
        widget.work.items[index].name = name;
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      widget.work.items.removeAt(index);
    });
  }

  void _toggleItem(int index, bool? value) {
    setState(() {
      widget.work.items[index].completed = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.work.name),
      ),
      body: widget.work.items.isEmpty
          ? const Center(
              child: Text(
                'No checklist items yet',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.work.items.length,
              itemBuilder: (context, index) {
                final item = widget.work.items[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.completed,
                      onChanged: (value) {
                        _toggleItem(index, value);
                      },
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editItem(index);
                        } else if (value == 'delete') {
                          _deleteItem(index);
                        }
                      },
                      itemBuilder: (context) => const [
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
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('New Item'),
      ),
    );
  }
}

class CheckListWork {
  String name;
  final List<CheckListItem> items;

  CheckListWork({
    required this.name,
    required this.items,
  });
}

class CheckListItem {
  String name;
  bool completed;

  CheckListItem({
    required this.name,
    this.completed = false,
  });
}