import 'package:flutter/material.dart';
import 'block_detail_screen.dart';

class LineBlockScreen extends StatefulWidget {
  const LineBlockScreen({super.key});

  @override
  State<LineBlockScreen> createState() => _LineBlockScreenState();
}

class _LineBlockScreenState extends State<LineBlockScreen> {
  final List<String> blocks = [
    'Block 1',
    'Block 2',
  ];

  Future<void> _addBlock() async {
    final controller = TextEditingController();

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Line Block'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Block Name',
              hintText: 'Enter block name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
        blocks.add(name);
      });
    }
  }

  Future<void> _editBlock(int index) async {
    final controller = TextEditingController(
      text: blocks[index],
    );

    final String? name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Block'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Block Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
        blocks[index] = name;
      });
    }
  }

  void _deleteBlock(int index) {
    setState(() {
      blocks.removeAt(index);
    });
  }

  void _openBlock(String blockName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlockDetailScreen(
          blockName: blockName,
          blockType: 'Line Block',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Line Block'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: blocks.length,
        itemBuilder: (context, index) {
          final blockName = blocks[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _openBlock(blockName),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.train,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        blockName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editBlock(index);
                        } else if (value == 'delete') {
                          _deleteBlock(index);
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addBlock,
        icon: const Icon(Icons.add),
        label: const Text('New Block'),
      ),
    );
  }
}